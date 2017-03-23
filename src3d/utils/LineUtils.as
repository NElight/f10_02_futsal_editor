package src3d.utils
{
	import away3d.animators.utils.PathUtils;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import src3d.lines.LineLibrary;
	import src3d.lines.SlicedPath;
 
	public class LineUtils
	{
		public function LineUtils()
		{
		}
 
		public static function getPoint(t:Number, points:Array):Point
		{
			var x:Number = 0;
			var y:Number = 0;
			var n:uint = points.length-1;
			var factn:Number = factoral(n);
			for (var i:uint=0;i<=n;i++)
			{
				var b:Number = factn/(factoral(i)*factoral(n-i));
				var k:Number = Math.pow(1-t, n-i)*Math.pow(t, i);
				x += b*k*points[i].x;
				y += b*k*points[i].y;
			}
			// Round points.
			x = Math.round(x);
			y = Math.round(y);
			
			return new Point(x, y);
		}
		
		/*		public static function getVector(t:Number, vector:Vector.<Vector3D>):Vector3D
		{
			var x:Number = 0;
			var y:Number = 0;
			var n:uint = vector.length-1;
			var factn:Number = factoral(n);
			for (var i:uint=0;i<=n;i++)
			{
				var b:Number = factn/(factoral(i)*factoral(n-i));
				var k:Number = Math.pow(1-t, n-i)*Math.pow(t, i);
				x += b*k*vector[i].x;
				y += b*k*points[i].y;
				z += b*k*points[i].z;
			}
			// Round points.
			x = Math.round(x);
			y = Math.round(y);
			z = Math.round(z);
			
			return new Vector3D(x, y, z);
		}*/
 
		private static function factoral(value:uint):Number
		{
			if (value==0)
				return 1;
			var total:Number = value;
			while (--value>1)
				total *= value;
			return total;
		}
		
		/**
		 * Returns an array of points from the given vector.
		 * Vector values needs to be in pairs. 
		 * @param v Vector.<Number>.
		 * @return Array of points.
		 * 
		 */		
		public static function vectorToPoints(v:Vector.<Number>):Array {
			var a:Array = new Array();
			if (v.length % 2 != 0) { trace("This is not a Vector with an even length!"); }
			
			for (var i:int = 0; i < v.length; i+=2) {
				a.push(new Point(v[i],v[i+1]));
			}
			
			return a;
		}
		
		/**
		 * Insert a new point in the given line at the specified distance.
		 * @param t Number between 0 (min distance) and 1 (max distance).
		 * @param points Array of Points.
		 * @return A new array of Points with the inserted Point.
		 * 
		 */		
		public static function insertPointInLine(t:Number, points:Array):Array
		{
			var nL:Array = new Array();
			var _pPos:int = 0; // The position after which the new point will be inserted.
			
			// Get the new point to be inserted.
			var _newPoint:Point = getPoint(t, points);
				
			_pPos = Math.round(points.length*t);

			nL = points.slice(0,_pPos);
			var lastSlice:Array = points.slice(_pPos,points.length);
			
			nL.push(_newPoint);
			nL = nL.concat(lastSlice);
			
			return nL;
		}

		/**
		 * Insert a new Point in the given Vector at the specified distance.
		 * @param t Number between 0 (min distance) and 1 (max distance).
		 * @param vector Vector of Points.
		 * @return A new Vector with the inserted Point.
		 * 
		 */		
		public static function insertPointInVector(t:Number, vector:Vector.<Number>):Vector.<Number>
		{
			var nV:Vector.<Number> = new Vector.<Number>;
			var _pPos:int = 0; // The position after which the new point will be inserted.
			
			// Get the new point to be inserted.
			var _points:Array = vectorToPoints(vector);
			var _newPoint:Point = getPoint(t, _points);

			_pPos = Math.round(vector.length*t);
			
			// Round the insertion point to an even number if needed.
			if (_pPos % 2 != 0) {_pPos+=1;}

			nV = vector.slice(0,_pPos);
			var _lastSlice:Vector.<Number> = vector.slice(_pPos,vector.length);
			
			nV.push(_newPoint.x, _newPoint.y);
			nV = nV.concat(_lastSlice);
			
			return nV;
		}
		
		public static function smoothCurve(points:Array, threshold:int = 2):Array {
			var nP:Array = new Array();
			var d:Number;
			var prevPoint:Point = points[0];
			//trace("Smoothing curve from "+points.length+" points.");
			nP.push(points[0]);
			for (var i:int = 1; i < points.length-1; i+=2) {
			
				d = Point.distance(prevPoint, points[i]);
				if(d>threshold){
					nP.push(points[i]);
				}
				prevPoint = points[i];
			}
			nP.push(points[points.length-1]);
			//trace("to "+nP.length+" points.");
			//trace("Points: "+nP);
			return nP;
		}
		
		/* The next code is unfinished. Left here for future reference.
		public static function smoothPath(path:Path, threshold:int = 10):void {
			smoothPathSegments(path.aSegments, threshold);
		}
		
		public static function smoothPathSegments(aSegments:Vector.<PathCommand>, threshold:int = 2):void {
			if(aSegments.length <= 2) return;
			//trace("Smoothing path from "+pData.length+" points.");
			
			var d:Number;
			var newPControl:Vector3D;
			var tmp:Array = [];
			
			tmp.push(aSegments[0].pStart); // New Start.
			
			for (var i:int = 1; i < aSegments.length-1; i++) {
				tmp.push(aSegments[i].pEnd); // New Control.
				tmp.push(aSegments[i+1].pControl); // New End.
				tmp.push(aSegments[i+1].pControl); // New End.
				
				d = Vector3D.distance(pData[i].pStart, pData[i].pEnd);
				if(d>threshold){
					// Remove the command.
					pData.splice(i,1);
				}

				//aSegments = new Vector.<PathCommand>();
				aSegments.length = 0;
				
				for(i = 0; i<tmp.length; i+=3)
					aSegments.push( new PathCommand(PathCommand.CURVE, tmp[i], tmp[i+1], tmp[i+2]) );
				tmp[i] = tmp[i+1] = tmp[i+2] = null;
				
				tmp = null;
				
			}
			//trace("to "+pData.length+" points.");
		}
		*/
		
		public static function convertSegmentsToSmoothCurves(aSegments:Vector.<PathCommand>):void {
			//if(aSegments.length <= 2) return;
			//trace("Smoothing path from "+pData.length+" points.");
			
			var d:Number;
			var pStart:Vector3D;
			var pControl:Vector3D;
			var pEnd:Vector3D;
			var tmp:Array = [];
			
			for (var i:int = 0; i < aSegments.length; i+=2) {
				// If it's a Move command, ignore it.
				if (aSegments[i].type == PathCommand.MOVE) i+= 1;
				
				pStart = aSegments[i].pStart;
				if (i+1 >= aSegments.length) {
					// If this is the last segment, don't calculate pControl.
					pControl = aSegments[i].pStart;
					pEnd = aSegments[i].pEnd;
				} else {
					pControl = LineUtils.getControlPoint(
						aSegments[i].pStart,
						aSegments[i].pEnd,
						aSegments[i+1].pEnd
					);
					// If all points have the same position, NaN will be returned.
					if (isNaN(pControl.x) || isNaN(pControl.y) || isNaN(pControl.z)) {
						pControl = aSegments[i+1].pStart;
					}
					pEnd = aSegments[i+1].pEnd;
				}
				
				tmp.push(pStart, pControl, pEnd);
			}
			
			aSegments.length = 0; // Reset aSegments.
			
			
			
/*			for(i = 0; i<tmp.length; i+=3) {
				trace("Segment "+i+":");
				trace("\npStart: "+tmp[i]);
				trace("\npControl: "+tmp[i+1]);
				trace("\npEnd: "+tmp[i+2]);
			}*/
			
			for(i = 0; i<tmp.length; i+=3) {
				aSegments.push( new PathCommand(PathCommand.CURVE, tmp[i], tmp[i+1], tmp[i+2]) );
				tmp[i] = tmp[i+1] = tmp[i+2] = null;
			}
			tmp = null;
			//trace("to "+pData.length+" points.");
		}
		
		public static function getControlPoint(p0:Vector3D, pT:Vector3D, p2:Vector3D):Vector3D {
			var p1:Vector3D = new Vector3D();
			var dP0T:Number = Vector3D.distance(p0,pT);
			var dTP2:Number = Vector3D.distance(pT,p2);
			var totalDistance:Number = dP0T + dTP2;
			var t:Number = dP0T / totalDistance;
			
			// This formula to get a point in 't' having P0, p1, p2 and t:
			// Bt = (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
			// Becomes:
			// p1 = ( ( (1-t) * (1-t) * p0 + t * t * p2  ) - Bt ) / ( 2 * (1-t) * t );
			// To get the control point position (p1).
			p1.x = - ( ( (1-t) * (1-t) * p0.x + t * t * p2.x  ) - pT.x ) / ( 2 * (1-t) * t );
			p1.z = - ( ( (1-t) * (1-t) * p0.z + t * t * p2.z  ) - pT.z ) / ( 2 * (1-t) * t );
			
			return p1;
		}
		
		public static function getPointOnCurve(pStart:Vector3D, pControl:Vector3D, pEnd:Vector3D, t:Number):Vector3D {
			return PathUtils.getNewPoint(pStart.x, pStart.y, pStart.z, pControl.x, pControl.y, pControl.z, pEnd.x, pEnd.y, pEnd.z, t)
			
		}

		public static function pathDataToString(p:Path, newFormat:Boolean = false):String {
			return pathDataSegmentsToString(p.aSegments, newFormat);
		}
		
		public static function pathDataSegmentsToString(pData:Vector.<PathCommand>, newFormat:Boolean = false):String {
			if (!pData) return "";
			var aString:Array = [];
			var str:String = "";
			for (var i:int = 0;i<pData.length;i++) {
				if (!newFormat) aString.push(pData[i].type);
				aString.push(pData[i].pStart.x.toFixed(2));
				aString.push(pData[i].pStart.y.toFixed(2));
				aString.push(pData[i].pStart.z.toFixed(2));
				aString.push(pData[i].pControl.x.toFixed(2));
				aString.push(pData[i].pControl.y.toFixed(2));
				aString.push(pData[i].pControl.z.toFixed(2));
				aString.push(pData[i].pEnd.x.toFixed(2));
				aString.push(pData[i].pEnd.y.toFixed(2));
				aString.push(pData[i].pEnd.z.toFixed(2));
			}
			str = aString.join("|");
			return str;
		}
		
		public static function stringToPathData(str:String):Path {
			if (!str) str = "";
			var aString:Array = [];
			var p:Path = new Path();
			var pc:PathCommand;
			var i:int;
			//var pcType:String;

			aString = str.split("|");
			
			// If it doesn't contain the right amount of data, return null.
			if (aString.length%10 != 0) {
				return null;
			}
			
			// If it doesn't contain valid data, return null.
			for(i = 0; i<aString.length; i++) {
				if (aString[i] != "M") {
					if (aString[i] != "L") {
						if (aString[i] != "C") {
							if (isNaN(Number(aString[i]))) return null;
						}
					}
				}
			}
			
			//pcType = String(aString[0]);
			for(i = 0; i<aString.length; i+=10) {
				pc = new PathCommand(
					String(aString[i]),
					new Vector3D(Number(aString[i+1]), Number(aString[i+2]), Number(aString[i+3])),
					new Vector3D(Number(aString[i+4]), Number(aString[i+5]), Number(aString[i+6])),
					new Vector3D(Number(aString[i+7]), Number(aString[i+8]), Number(aString[i+9]))
				);
				/*if (pc.type = PathCommand.MOVE) {
					if (!pathCommandZeroLength(pc)) {
						p.aSegments.push(pc);
					}
				} else {
					p.aSegments.push(pc);
				}*/
				
				p.aSegments.push(pc);
			}
			//if (p.aSegments.length > 0)	p.aSegments[0].type = pcType;
			return p;

		}
		
		/**
		 * Converts a path data string from away3D v4 format (no PathCommand type included). 
		 * @param str
		 * @return Returns a Path using Curved PathCommands.
		 * 
		 */		
		public static function stringToPathDataNew(str:String):Path {
			if (!str) str = "";
			var aString:Array = [];
			var p:Path = new Path();
			var pc:PathCommand;
			var i:int;
			//var pcType:String;
			
			aString = str.split("|");
			
			// If it doesn't contain the right amount of data, return null.
			if (aString.length%9 != 0) {
				return null;
			}
			
			// If it doesn't contain valid data, return null.
			if (isNaN(Number(aString[i]))) return null;
			
			//pcType = String(aString[0]);
			for(i = 0; i<aString.length; i+=9) {
				pc = new PathCommand(
					PathCommand.CURVE,
					new Vector3D(Number(aString[i]), Number(aString[i+1]), Number(aString[i+2])),
					new Vector3D(Number(aString[i+3]), Number(aString[i+4]), Number(aString[i+5])),
					new Vector3D(Number(aString[i+6]), Number(aString[i+7]), Number(aString[i+8]))
				);
				p.aSegments.push(pc);
			}
			return p;
		}
		
		public static function trimPath(path:Path, trimSegments:uint):Boolean {
			var trimOK:Boolean = true;
			var newLength:int = path.aSegments.length - trimSegments;
			if (newLength < 0) {
				trimOK = false;
				newLength = 0;
			}
			path.aSegments.length = newLength;
			return trimOK;
		}
		
		public static function pathCommandZeroLength(p:PathCommand, includeControl:Boolean = false):Boolean {
			// Validate first segment.
			/*var v:uint = 0;
			if (String(aString[v]) == "M") {
			var vStart:Vector3D = new Vector3D(Number(aString[v+1]), Number(aString[v+2]), Number(aString[v+3]));
			//var vControl:Vector3D = new Vector3D(Number(aString[v+4]), Number(aString[v+5]), Number(aString[v+6]));
			var vEnd:Vector3D = new Vector3D(Number(aString[v+7]), Number(aString[v+8]), Number(aString[v+9]));
			if (vStart.equals(vEnd)) {
			// 
			}
			}*/
			
			var zero:Boolean;
			var startEndEqual:Boolean;
			var startControlEqual:Boolean;
			var vStart:Vector3D = p.pStart;
			var vControl:Vector3D = p.pControl;
			var vEnd:Vector3D = p.pEnd;
			
			startEndEqual = vStart.equals(vEnd);
			if (includeControl) {
				startControlEqual = vStart.equals(vControl);
				zero = (startEndEqual && startControlEqual)? true : false;
			} else {
				zero = startEndEqual;
			}
			return zero;
		}
		
		public static function getPathBounds(path:Path):Object {
			var minX:Number;
			var maxX:Number;
			var minZ:Number;
			var maxZ:Number;
			var pInfo:Object = {};
			
			if (!path) return null;
			if (path.aSegments.length == 0) return null;
			
			for each(var pc:PathCommand in path.aSegments) {
				if (isNaN(maxX)) {
					maxX = pc.pStart.x;
					minX = maxX;
					maxZ = pc.pStart.z;
					minZ = maxZ;
				} else {
					if (pc.pStart.x > maxX) maxX = pc.pStart.x;
					if (pc.pStart.x < minX) minX = pc.pStart.x;
					if (pc.pStart.z > maxZ) maxZ = pc.pStart.z;
					if (pc.pStart.z < minZ) minZ = pc.pStart.z;
				}
				
				if (pc.pControl.x > maxX) maxX = pc.pControl.x;
				if (pc.pControl.x < minX) minX = pc.pControl.x;
				if (pc.pControl.z > maxZ) maxZ = pc.pControl.z;
				if (pc.pControl.z < minZ) minZ = pc.pControl.z;
				
				if (pc.pEnd.x > maxX) maxX = pc.pEnd.x;
				if (pc.pEnd.x < minX) minX = pc.pEnd.x;
				if (pc.pEnd.z > maxZ) maxZ = pc.pEnd.z;
				if (pc.pEnd.z < minZ) minZ = pc.pEnd.z;
			}
			pInfo.maxX = maxX;
			pInfo.minX = minX;
			pInfo.maxZ = maxZ;
			pInfo.minZ = minZ;
			pInfo.pWidth = (maxX - minX);
			pInfo.pDepth = (maxZ - minZ);
			pInfo.pCenterX = maxX - (pInfo.pWidth / 2);
			pInfo.pCenterZ = maxZ - (pInfo.pDepth / 2);
			pInfo.pCenter = new Vector3D(pInfo.pCenterX, 0, pInfo.pCenterZ);
			return pInfo;
		}
		
		public static function getMiddlePointOfVectors(v0:Vector3D, v1:Vector3D):Vector3D {
			var newX:Number = (v1.x - v0.x) / 2;
			var newY:Number = (v1.y - v0.y) / 2;
			var newZ:Number = (v1.z - v0.z) / 2;
			return new Vector3D(newX, newY, newZ);
		}
		
		public static function makePlainPath(p:Path):Path {
			if (!p) return null;
			var yPos:Number = 0;
			var newPath:Path = new Path();
			var newPathCommand:PathCommand;
			for each(var pc:PathCommand in p.aSegments) {
				newPathCommand = new PathCommand(
					pc.type,
					pc.pStart.clone(),
					pc.pControl.clone(),
					pc.pEnd.clone()
				);
				newPathCommand.pStart.y = yPos;
				newPathCommand.pControl.y = yPos;
				newPathCommand.pEnd.y = yPos;	
				newPath.add(newPathCommand);
			}
			return newPath;
		}
		
		public static function getPathLength(p:Path):Number {
			return getPathSegmentsLength(p.aSegments);
		}
		
		public static function getPathSegmentsLength(aSegments:Vector.<PathCommand>):Number {
			var dist:Number = 0;
			for each(var pc:PathCommand in aSegments) {
				if (pc) {
					dist += Vector3D.distance(pc.pStart, pc.pControl);
					dist += Vector3D.distance(pc.pControl, pc.pEnd);
				} else {
					trace("Error getPathSegmentsLength(): PathCommand is null");
				}
			}
			return dist;
		}
		
		public static function getRotationAngle (p1:Vector3D, p2:Vector3D):Number
		{
			var dx:Number = p2.x - p1.x;
			var dz:Number = p2.z - p1.z;
			return Math.atan2(dz,dx) * 180 / Math.PI; // Radians to Degrees.
		}
		
		public static function radiansToDegrees(radians:Number):Number {
			var degrees:Number = radians * 180 / Math.PI;
			return degrees;
		}
		
		public static function degreesToRadians(degrees:Number):Number {
			var radians:Number = degrees * Math.PI / 180;
			return radians;
		}
		
		// --------------- Flash 11 converted to F10 --------------- //
		
		public static function getSegmentLength(pS:Vector3D, pE:Vector3D):Number {
			/*var x1:Number = pS.x;
			var y1:Number = pS.y;
			var z1:Number = pS.z;
			var x2:Number = pE.x;
			var y2:Number = pE.y;
			var z2:Number = pE.z;
			return Math.sqrt( Math.pow(x2-x1,2) + Math.pow(y2-y1,2) + Math.pow(z2-z1,2) );*/
			return Math.sqrt( 
				Math.pow(pE.x-pS.x,2) + 
				Math.pow(pE.y-pS.y,2) + 
				Math.pow(pE.z-pS.z,2) 
			);
		}
		public static function vectorFromVectorVector3D(aVecOfVec:Vector.<Vector.<Vector3D>>):Vector.<Vector3D> {
			// Get the array of vectors.
			var newAvector:Vector.<Vector3D> = new Vector.<Vector3D>;
			// Create curves (straight curves) with the given points to get the PathSegments correctly.
			for(var j:int = 0;j<aVecOfVec.length; j++) {
				// First segment in the curve.
				if (aVecOfVec[j].length == 1) {
					newAvector.push(aVecOfVec[j][0],aVecOfVec[j][0],aVecOfVec[j][0]);// pStart, pControl, pEnd
				} else {
					newAvector.push(aVecOfVec[j][0],aVecOfVec[j][0],aVecOfVec[j][0+1]);// pStart, pControl, pEnd
				}
				// Next segments.
				for(var h:int = 1;h<aVecOfVec[j].length-1; h++) {
					if (aVecOfVec[j].length == 1) {
						newAvector.push(aVecOfVec[j][h],aVecOfVec[j][h],aVecOfVec[j][h]);// pStart, pControl, pEnd
					} else {
						newAvector.push(aVecOfVec[j][h],aVecOfVec[j][h],aVecOfVec[j][h+1]);// pStart, pControl, pEnd
					}
				}
			}
			return newAvector; 
		}
		public static function arrayFromVector3D(aVector3D:Array, asCurves:Boolean = true):Array {
			var newVVector3D:Array = [];
			// Create curves (straight curves) with the given points to get the PathSegments correctly.
			var h:int
			if (asCurves) {
				var newPath:Path = new Path();
				newPath.continuousCurve(aVector3D);
				//newPath.smoothPath();
				aVector3D = pathSegmentsToVector3D(newPath.aSegments);
				
				if(aVector3D.length < 3)
					trace("Path Vector.<Vector3D> must contain at least 3 Vector3D's to get a curve");
				
				for(h = 0;h<aVector3D.length-2; h+=3) {
					if (aVector3D.length == 1) {
						newVVector3D.push(aVector3D[h],aVector3D[h],aVector3D[h]);// pStart, pControl, pEnd
					} else {
						newVVector3D.push(aVector3D[h],aVector3D[h+1],aVector3D[h+2]);// pStart, pControl, pEnd
					}
				}
			} else {
				for(h = 0;h<aVector3D.length-1; h++) {
					if (aVector3D.length == 1) {
						newVVector3D.push(aVector3D[h],aVector3D[h],aVector3D[h]);// pStart, pControl, pEnd
					} else {
						newVVector3D.push(aVector3D[h],aVector3D[h],aVector3D[h+1]);// pStart, pControl, pEnd
					}
				}
			}
			
			// Avoid error.
			if (aVector3D.length == 1) newVVector3D.push(aVector3D[0],aVector3D[0],aVector3D[0]);// pStart, pControl, pEnd
			
			return newVVector3D;
		}
		public static function pathSegmentsToVector3D(aPS:Vector.<PathCommand>):Array {
			var vVector3D:Array = [];
			
			for (var i:int;i<aPS.length;i++) {
				vVector3D.push(aPS[i].pStart,aPS[i].pControl,aPS[i].pEnd);
			}
			
			return vVector3D;
		}
		public static function lineToCurve(pS:Vector3D, pE:Vector3D):Vector.<Vector3D> {
			
			var aVectors:Vector.<Vector3D> = new Vector.<Vector3D>();
			var X:Number;
			var Y:Number;
			var Z:Number;
			var midPoint:Vector3D;
			
			X = (pS.x + pE.x)/2;
			Y = (pS.y + pE.y)/2;
			Z = (pS.z + pE.z)/2;
			midPoint = new Vector3D(X, Y, Z);
			
			aVectors.push(pS, midPoint, pE);
			return aVectors;
		}
	}
}