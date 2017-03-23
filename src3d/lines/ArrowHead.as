package src3d.lines
{
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Segment;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.materials.Material;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import src3d.utils.LineUtils;
	import src3d.utils.MiscUtils;
	
	public class ArrowHead extends Mesh
	{
		private var _arrowHead:Mesh = new Mesh();
		
		var _v1a:Vector3D;
		var _v1b:Vector3D;
		var _v1c:Vector3D;
		var _arrowHeadFace:Face;
		
		public function ArrowHead(arrowThickness:int, matline:Material = null) {
			this.arrowSize = arrowThickness;
			this.bothsides = false;
			this.scaleX *= -1;
			if (matline != null) {
				this.material = matline;
			}
		}
		
		public function set arrowSize(arrowThickness:int):void {
			var arrowSettings:Object = new LineSettings().getArrowSize(arrowThickness);
			var w:int = arrowSettings.arrowWidth/2;
			var l:int = arrowSettings.arrowLength;
			
			_v1a = new Vector3D(0,0,l/1.6);
			_v1b = new Vector3D(w,0,-l);
			_v1c = new Vector3D(-w,0,-l);
			if (_arrowHeadFace) {
				this.removeFace(_arrowHeadFace);
			}
			_arrowHeadFace = new Face();
			_arrowHeadFace.moveTo(_v1a.x,_v1a.y, _v1a.z);
			_arrowHeadFace.lineTo(_v1b.x,_v1b.y, _v1b.z);
			_arrowHeadFace.lineTo(_v1c.x,_v1c.y, _v1c.z);
			_arrowHeadFace.lineTo(_v1a.x,_v1a.y, _v1a.z);
			this.addFace(_arrowHeadFace);
		}
		
		public function rotateArrowHead(path:Path, atStart:Boolean = false):void {
			var pFirst:Vector3D;
			var pLast:Vector3D;
			var newPos:Vector3D = new Vector3D();
			var minSegment:int = 2; // The segment length to take the arrow direction from.
			var lineDist:Number;
			
			// If we are loading an old line format, pControl will have the same value as pEnd, so we have to use pStart as reference.
			var useControl:Boolean = (path.aSegments[path.aSegments.length-1].pEnd.equals(path.aSegments[path.aSegments.length-1].pControl))? false : true;
			
			// Place the arrow head on position.
			if (!atStart) {
				newPos.x = path.aSegments[path.aSegments.length-1].pEnd.x;
				newPos.y = path.aSegments[path.aSegments.length-1].pEnd.y;
				newPos.z = path.aSegments[path.aSegments.length-1].pEnd.z;
				if (!isNaN(newPos.x) && !isNaN(newPos.y) && !isNaN(newPos.z)) {
					this.x = newPos.x
					this.y = newPos.y;
					this.z = newPos.z;
				}else {
					return;
				}

				// Get the arrow direction from the last segments.
				if (path.aSegments.length > 2) {
					for (var i:int = 0;i<minSegment;i++) {
						if (path.aSegments.length > minSegment) {
							pFirst = (useControl)? path.aSegments[path.aSegments.length-1].pControl : path.aSegments[path.aSegments.length-minSegment].pStart;
							pLast = path.aSegments[path.aSegments.length-1].pEnd;
							break;
						}
						minSegment--;
					}
				}else {
					if (path.aSegments.length < 2) {
						// If the path is made of a single segment (straight line), get the arrow direction from it.
						pFirst = (useControl)? path.aSegments[path.aSegments.length-1].pControl : path.aSegments[path.aSegments.length-1].pStart;
						pLast = path.aSegments[path.aSegments.length-1].pEnd;
					} else {
						// If the path is made of two segments. get the direction from them, to get a more accurate angle.
						pFirst = (useControl)? path.aSegments[path.aSegments.length-1].pControl : path.aSegments[path.aSegments.length-2].pStart;
						pLast = path.aSegments[path.aSegments.length-1].pEnd;
					}
				}
				
				// Work out arrow angle.
				lineDist = Vector3D.distance(pFirst, pLast);
				//this.rotationX = Math.acos((pEnd.y - pStart.y)/lineDist)*180/Math.PI;
				if ( pLast.y > pFirst.y) {
					this.rotationX = Math.acos(Math.cos((pLast.y - pFirst.y)/lineDist))*180/Math.PI;
				} else if ( pLast.y < pFirst.y ) {
					this.rotationX = - Math.acos(Math.cos((pFirst.y - pLast.y)/lineDist))*180/Math.PI;
				}
			} else {
				if (useControl) {
					newPos.x = path.aSegments[0].pControl.x;
					newPos.y = path.aSegments[0].pControl.y;
					newPos.z = path.aSegments[0].pControl.z;
				} else {
					newPos.x = path.aSegments[0].pStart.x;
					newPos.y = path.aSegments[0].pStart.y;
					newPos.z = path.aSegments[0].pStart.z;
				}
				if (!isNaN(newPos.x) && !isNaN(newPos.y) && !isNaN(newPos.z)) {
					this.x = newPos.x
					this.y = newPos.y;
					this.z = newPos.z;
				}else {
					return;
				}
				if (path.aSegments.length >= 2) {
					// Get the average direction of the first two segment to get a more accurate angle.
					pFirst = (useControl)? path.aSegments[0].pControl : path.aSegments[0].pStart;
					pLast = path.aSegments[1].pEnd;
				} else {
					pFirst = (useControl)? path.aSegments[0].pControl : path.aSegments[0].pStart;
					pLast = path.aSegments[0].pEnd;
				}
				
				// Work out arrow angle.
				lineDist = Vector3D.distance(pFirst, pLast);
				//this.rotationX = Math.acos((pEnd.y - pStart.y)/lineDist)*180/Math.PI;
				if ( pLast.y > pFirst.y) {
					this.rotationX = - Math.acos(Math.cos((pLast.y - pFirst.y)/lineDist))*180/Math.PI;
				} else if ( pLast.y < pFirst.y ) {
					this.rotationX = Math.acos(Math.cos((pFirst.y - pLast.y)/lineDist))*180/Math.PI;
				}
			}
			this.pivotPoint = new Vector3D(0,0,0);

			//this.lookAt(new Vector3D(pEnd.x,pEnd.y,pEnd.z));
			
			// work out the rotation of the end arrow
			if( (pLast.x > pFirst.x) && (pLast.z > pFirst.z) ) {
				this.rotationY = 90 - Math.atan((pLast.z - pFirst.z)/(pLast.x - pFirst.x))*180/Math.PI;
			} else if((pLast.x > pFirst.x) && (pLast.z <= pFirst.z) ) {
				this.rotationY = 90 + Math.atan((pFirst.z - pLast.z)/(pLast.x - pFirst.x))*180/Math.PI;
			} else if( (pLast.x < pFirst.x) && (pLast.z <= pFirst.z) ) {
				this.rotationY = 270 - Math.atan((pFirst.z - pLast.z)/(pFirst.x - pLast.x))*180/Math.PI;
			} else {
				this.rotationY = 270 + Math.atan((pLast.z - pFirst.z)/(pFirst.x - pLast.x))*180/Math.PI;
			}
			
			if (atStart) {
				this.rotationY += 180;
			}
			
		}
		
		public function dispose():void {
			if (_arrowHeadFace) {
				this.removeFace(_arrowHeadFace);
			}
			_arrowHeadFace.material = null;
			_arrowHeadFace = null;
			_v1a = null;
			_v1b = null;
			_v1c = null;
		}
	}
}