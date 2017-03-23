package src3d.lines
{
	import away3d.animators.utils.PathUtils;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	
	import flash.geom.Vector3D;
	
	import src3d.utils.LineUtils;

	public class SlicedPath
	{
		public var totalLength:Number = 0;
		public var segmentsPoints:Vector.<Vector3D> = new Vector.<Vector3D>();
		public var segmentsLengths:Vector.<Number> = new Vector.<Number>();
		public var segmentsDistances:Vector.<Number> = new Vector.<Number>(); // Distances of every segment from 0.
		
		private var _slicedVector3D:Vector.<Vector3D> = new Vector.<Vector3D>();
		private var _accuracy:uint; // subsegments in which divide the array of segments.
		private var _path:Path;
		private var _dashLength:Number;
		private var _gapLength:Number;
		
		private var dirty:Boolean = true;
		
		public function SlicedPath(path:Path, dashLength:Number = 30, gapLength:Number = 20, accuracy:uint = 50)
		{
			this._path = path;
			this._dashLength = dashLength;
			this._gapLength = gapLength;
			this._accuracy = accuracy;
			dirty = true;
		}
		
		public function get slices():Vector.<Vector3D> {
			if (dirty) makeNewSlicedPath();
			return _slicedVector3D;
		}
		
		public function set path(p:Path):void {
			_path = p;
			dirty = true;
		}
		public function set dashLength(dl:Number):void {
			_dashLength = dl;
			dirty = true;
		}
		public function set gapLength(gl:Number):void {
			_gapLength = gl;
			dirty = true;
		}
		public function set accuracy(a:uint):void {
			_accuracy = a;
			dirty = true;
		}
		public function get path():Path { return _path; }
		public function get dashLength():Number { return _dashLength; }
		public function get gapLength():Number { return _gapLength; }
		public function get accuracy():uint { return _accuracy; }
		
		protected function makeNewSlicedPath():void {
			//TODO: - Use _gapLength. - Add the last segment if there is space for it.
			trace("makeDashedExtrudeLine()");
			//_path.smoothPath(); // Not sure if I should use it in this part.
			
			// Get sliced path data: segments points, distances, length, and total length. 
			getSlicedPathData();
			if (segmentsPoints == null || segmentsPoints.length == 0) {
				segmentsPoints = new Vector.<Vector3D>();
				return;
			}
			// Get the divisions needed for the given dash and gap length.
			//var pathDivisions:int = Math.floor(slicedPath.totalLength / (_dashLength+_gapLength));
			var pathDivisions:int = Math.floor(totalLength / (_dashLength));
			var pointIndex:int;
			var dashDistance:Number = 0;
			var slicedPoints:Array = [];
			slicedPoints.push(segmentsPoints[0]);
			
			for(var i:int;i<=pathDivisions;i++) {
				dashDistance+=_dashLength;
				for(var j:int = 1;j<segmentsDistances.length;j++) {
					if (segmentsDistances[j] > dashDistance) {
						slicedPoints.push(segmentsPoints[j-1]);
						break;
					}
				}
			}
			
			var slicedPointsAsSegments:Array = LineUtils.arrayFromVector3D(slicedPoints);
			var slicedVector3D:Vector.<Vector3D> = new Vector.<Vector3D>();
			// Create Dashed Line Path.
			for(var h:int = 0;h<slicedPointsAsSegments.length; h+=6) {
				if (h+2 >= slicedPointsAsSegments.length) break;
				slicedVector3D.push(slicedPointsAsSegments[h],slicedPointsAsSegments[h+1],slicedPointsAsSegments[h+2]);// pStart, pControl, pEnd
			}
			_slicedVector3D = slicedVector3D;
			dirty = false;
		}
		
		protected function getSlicedPathData():void {
			var vPathSegments:Vector.<PathCommand> = _path.aSegments;
			var segmentLengthTemp:Number = 0;
			var segmentDistanceTemp:Number = 0;
			var segmentPointTemp:Vector3D;
			var vSegmentPoints:Array;
			
			// Get Points in all of the vPathSegments.
			for (var i:uint = 0; i < vPathSegments.length; ++i) {
				// If segment length is 0, do not process it.
				if (LineUtils.getSegmentLength(vPathSegments[i].pStart, vPathSegments[i].pEnd) != 0) {
					// Get points in the segment.
					vSegmentPoints = PathUtils.getSegmentPoints(vPathSegments[i].pStart, vPathSegments[i].pControl, vPathSegments[i].pEnd, accuracy, (i ==vPathSegments.length-1));
					segmentPointTemp = vSegmentPoints[0];
					// Get the distances between every point of the segment.
					for(var j:int = 0;j<vSegmentPoints.length; j++) {
						segmentsPoints.push(vSegmentPoints[j]);
						//segmentsLengths.push(LineUtils.getSegmentLength(segmentPointTemp, vSegmentPoints[j]));
						segmentsLengths.push(Vector3D.distance(segmentPointTemp, vSegmentPoints[j]));
						
						segmentsDistances.push(segmentDistanceTemp+segmentsLengths[segmentsLengths.length-1]);
						segmentPointTemp = vSegmentPoints[j];
						segmentLengthTemp = segmentsLengths[segmentsLengths.length-1];
						totalLength+=segmentLengthTemp;
						segmentDistanceTemp+=segmentLengthTemp;
					}
				}
			}
		}
	}
}