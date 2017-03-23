package src3d.lines
{
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.events.MouseEvent3D;
	import away3d.events.Object3DEvent;
	import away3d.primitives.Plane;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.SSPEvent;
	import src3d.SessionScreen;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.LineUtils;
	
	public class AreaBase extends LineBase {
		
		protected var areaData:Vector.<Vector3D> = new Vector.<Vector3D>();
		protected var areaPlane:Plane;
		
		protected var newAreaBounds:AreaBounds = new AreaBounds();
		protected var oldAreaPosition:Vector3D = new Vector3D();
		protected var newAreaTopLeft:Vector3D = new Vector3D(); // top-left.
		protected var newAreaTopRight:Vector3D = new Vector3D(); // top-right.
		protected var newAreaBtmLeft:Vector3D = new Vector3D(); // btn-right.
		protected var newAreaBtmRight:Vector3D = new Vector3D(); // btn-right.
		
		public function AreaBase(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings)
		{
			super(sessionScreen, objSettings);
			this.lineAlpha = .3;
			this.useArrowHead = false;
			this.ownCanvas = true;
			this._colorable = true;
			//this.debugbb = true;
			
			initMaterials();
			init2DButtons();
		}
		
		// ------------------------------- Inits ------------------------------- //
		protected override function initMainLineMesh():void {
			areaPlane = new Plane({material:lineMat, segmentsH:1, segmentsV:1});
			areaPlane.width = 0;
			areaPlane.height = 0;
			areaPlane.bothsides = true; // Needed.
			areaPlane.useHandCursor = true;
			areaPlane.ownCanvas = true;
			this.addChild(areaPlane);
			//areaPlane.material = lineMat;
			//this.position = containerPos;
			mainLineMesh = areaPlane;
		}
		protected override function initDragDropTarget():void {
			dragDropTarget = areaPlane; // The plane will trigger the mouse down event.
			dragDropContainer = areaPlane; // The plane will be dragged, while this.position stays the same.
		}
		// ----------------------------- End Inits ----------------------------- //
		
		
		
		// ----------------------------- Mouse ----------------------------- //
		protected override function onDragDropTargetMouseDown(e:MouseEvent3D):void {
			trace("AreaBase.onThisMouseDown()");
			oldAreaPosition = areaPlane.position.clone();
			super.onDragDropTargetMouseDown(e);
		}
		// --------------------------- End Mouse --------------------------- //
		
		
		// ----------------------------- Drawing ----------------------------- //
		public override function drawLine(newPath:Path):void {
			if (!newPath) {
				trace("newPath is null");
				return;
			}
			linePathData = newPath;
			updateLine();
		}
		
		protected override function updateLine():void {
			//trace("updateLine()");
			if (linePathData == null) {
				// If there is nothing to draw, return.
				linePathData = new Path();
				return;
			}
			if (linePathData.length == 0 || linePathData.length > 2) {
				trace("Invalid path data. drawing area ignored.");
				return;
			}
			
			updateAreaPathData();
			
			areaPlane.width = newAreaBounds.areaWidth;
			areaPlane.height = newAreaBounds.areaDepth;
			areaPlane.position = newAreaBounds.areaPosition.clone();
			areaPlane.material = lineMat;
			
			bringHandlesToFront();
		}
		
		private function updateAreaPathData():void {
			var pSegment:PathCommand = linePathData.aSegments[1];
			
			var newOffset:Vector3D = new Vector3D;
			newOffset.x = oldAreaPosition.x - areaPlane.position.x;
			newOffset.y = oldAreaPosition.y - areaPlane.position.y;
			newOffset.z = oldAreaPosition.z - areaPlane.position.z;
			
			// Update pathData offset if any.
			pSegment.pStart.decrementBy(newOffset);
			pSegment.pControl.decrementBy(newOffset);
			pSegment.pEnd.decrementBy(newOffset);
			
			newAreaTopLeft = new Vector3D(pSegment.pStart.x, 0, pSegment.pStart.z); // top-left.
			newAreaTopRight = new Vector3D(pSegment.pEnd.x, 0, pSegment.pStart.z); // top-right.
			newAreaBtmLeft = new Vector3D(pSegment.pEnd.x, 0, pSegment.pEnd.z); // btn-right.
			newAreaBtmRight = new Vector3D(pSegment.pStart.x, 0, pSegment.pEnd.z); // btn-right.
			
			newAreaBounds._maxX = newAreaTopRight.x;
			newAreaBounds._minX = newAreaTopLeft.x;
			newAreaBounds._maxZ = newAreaTopRight.z;
			newAreaBounds._minZ = newAreaBtmRight.z;
			
			
			areaData = new Vector.<Vector3D>();
			// The points for the plane will be stored this way: top-left, top-right, btm-right, btn-left. To use in repositionHandles.
			areaData.push(newAreaTopLeft); // top-left.
			areaData.push(newAreaTopRight); // top-right.
			areaData.push(newAreaBtmLeft); // btn-right.
			areaData.push(newAreaBtmRight); // btn-right.
			
			oldAreaPosition = newAreaBounds.areaPosition.clone();
		}
		// --------------------------- End Drawing --------------------------- //
		
		
		
		// ----------------------------- Selecting ----------------------------- //
		protected override function updateLinePosition(newPos:Vector3D = null):void {
			trace("updateAreaPosition()");
			updateAreaPathData();
			repositionHandles();
		}
		
		public override function moveLineTo(newPos:Vector3D):void {
			// Get the center offset.
			//var pBounds:Object = LineUtils.getPathBounds(linePathData);
			var currentAreaBounds:Object = this.areaBounds;
			if (!currentAreaBounds) return;
			var pCenter:Vector3D = currentAreaBounds.areaPosition.clone();
			// Change the pos to: -centerPos + newPos.
			pCenter.negate();
			areaPlane.position = newPos.clone();
			updateLinePosition(pCenter.add(newPos));
			//updateAreaPosition(newPos);
//			updateAreaPathData();
			handlesVisible(false);
			updateLine();
		}
		
		public override function get areaBounds():AreaBounds {
			var lb:AreaBounds = new AreaBounds();
			lb.maxX = -areaPlane.width/2 + areaPlane.position.x;
			lb.minX = areaPlane.width/2 + areaPlane.position.x;
			lb.maxZ = -areaPlane.height/2 + areaPlane.position.z;
			lb.minZ = areaPlane.height/2 + areaPlane.position.z;
			//lb.pWidth = areaPlane.width;
			//lb.pDepth = areaPlane.height;
			//lb.position = areaPlane.position;
			//lb.centerOffsetX = this.position.x; 
			//lb.centerOffsetZ = this.position.z;
			return lb;
		}
		// --------------------------- End Selecting --------------------------- //
		
		
		
		
		
		// ----------------------------- Handles ----------------------------- //
		protected override function createHandles():void {
			//updateAreaPosition(areaPlane.position);
			updateAreaPathData();
			var hP:LineHandle;
			aHandles = new Vector.<LineHandle>;
			for (var i:int=0;i<areaData.length;i++) {
				hP = new LineHandle(i, HandleLibrary.P_NONE);
				hP.x = areaData[i].x;
				hP.y = areaData[i].y;
				hP.z = areaData[i].z;
				aHandles.push(hP);
				this.addChild(hP);
				hP.pushfront = true;
			}
			handlesToggleListeners(true);
		}
		
		protected override function repositionHandles():void {
			//trace("repositionHandles");
			if (!aHandles || aHandles.length == 0) return;
			updateAreaPathData();
			for (var i:int=0;i<areaData.length;i++) {
				aHandles[i].x = areaData[i].x;
				aHandles[i].y = areaData[i].y;
				aHandles[i].z = areaData[i].z;
				aHandles[i].pushfront = true;
			}
		}
		
		protected override function onHPMouseDown(e:MouseEvent3D):void {
			//trace("onHPMouseDown");
			if (areaData.length < 4) return;
			super.onHPMouseDown(e);
		}
		
		protected override function onHPMouseMove(e:MouseEvent):void {
			trace("onHPMouseMove");
			// update the path and redraw the ref line.
			// Todo: stop updating if mouse stop moving while keeping mouse down.
			
			/*if (lineCurrentSettings._lineType != LineLibrary.TYPE_GRID) {
				cancelEdit();
				return;
			}*/
			
			newPos3D = drag3d.getIntersect().clone();
			
			trace("Position Before: "+areaPlane.position.x+","+this.areaPlane.z);
			
			if (selectedHandle.handleIndex == 0) {
				linePathData.aSegments[1].pStart = newPos3D.clone();
				linePathData.aSegments[1].pControl = newPos3D.clone();
			}
			
			if (selectedHandle.handleIndex == 2) {
				linePathData.aSegments[1].pEnd = newPos3D.clone();
			}
			
			if (selectedHandle.handleIndex == 1) {
				linePathData.aSegments[1].pStart.z = newPos3D.z;
				linePathData.aSegments[1].pControl.z = newPos3D.z;
				linePathData.aSegments[1].pEnd.x = newPos3D.x;
			}
			
			if (selectedHandle.handleIndex == 3) {
				linePathData.aSegments[1].pStart.x = newPos3D.x;
				linePathData.aSegments[1].pControl.x = newPos3D.x;
				linePathData.aSegments[1].pEnd.z = newPos3D.z;
			}
			updateLine();
			
			trace("Position After: "+this.areaPlane.x+","+this.areaPlane.z);
		}
		// --------------------------- End Handles --------------------------- //
		
		
		
		public override function dispose():void {
			this.selected = false;
			removeHandles();
			if (areaPlane) this.removeChild(areaPlane);
			
			super.dispose();
			
			areaData = null;
			areaPlane = null;
			
			newAreaBounds = null;
			oldAreaPosition = null;
			newAreaTopLeft = null;
			newAreaTopRight = null;
			newAreaBtmLeft = null;
			newAreaBtmRight = null;
		}
		
		
	}
}