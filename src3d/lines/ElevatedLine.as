package src3d.lines
{
	import away3d.core.geom.PathCommand;
	import away3d.events.MouseEvent3D;
	
	import flash.events.MouseEvent;
	
	import src3d.SessionScreen;
	import src3d.models.SSPObjectBaseSettings;
	
	public class ElevatedLine extends DynamicLine
	{
		protected var aElevationHandles:Vector.<ElevatedLineHandle> = new Vector.<ElevatedLineHandle>;
		protected var currentLineIdx:int;
		protected var oldYPos:Number;
		protected var maxElevation:Number = 200;
		
		public function ElevatedLine(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings)
		{
			super(sessionScreen, objSettings);
		}
		
		protected override function displayHandles(disp:Boolean):void {
			super.displayHandles(disp);
			displayElevationHandles(disp);
		}
		
		private function displayElevationHandles(disp:Boolean):void {
			if (disp) {
				if (objSettingsRef._useHandles == "TRUE") {
					createHandles();
					for each(var h:ElevatedLineHandle in aElevationHandles) {
						h.visible = true;
						h.pushfront = true;
					}
				}
			} else {
				for (var i:int =0;i<aElevationHandles.length;i++){
					aElevationHandles[i].visible = false;
				}
			}
			eHandlesEnableListeners(disp);
		}
		
		private function eHandlesEnableListeners(lEnabled:Boolean):void {
			trace("eHandlesEnableListeners()");
			for each(var h:ElevatedLineHandle in aElevationHandles) {
				if (lEnabled) {
					if (!h.hasEventListener(MouseEvent3D.MOUSE_DOWN))
						h.addEventListener(MouseEvent3D.MOUSE_DOWN, onEHMouseDown);
				} else {
					h.removeEventListener(MouseEvent3D.MOUSE_DOWN, onEHMouseDown);
				}
			}
		}
		
		private function handlesVisible(hVisible:Boolean):void {
			for each(var eH:ElevatedLineHandle in aElevationHandles) {
				eH.visible = hVisible;
				eH.pushfront = true;
			}
			for each(var lH:LineHandle in aHandles) {
				lH.visible = hVisible;
				lH.pushfront = true;
			}
		}
		
		protected override function bringHandlesToFront():void {
			if (!objSettingsRef._useHandles == "TRUE") return;
			super.bringHandlesToFront();
			for each(var h:ElevatedLineHandle in aElevationHandles) {
				h.pushfront = true;
			}
		}
		
		protected override function createHandles():void {
			if (!objSettingsRef._useHandles == "TRUE") return;
			super.createHandles();
			if (aElevationHandles.length == 0) {
				var cmd:Vector.<PathCommand> = _linePathData.aSegments;
				var eH:ElevatedLineHandle;
				
				// Create the Start Elevation Handle.
				eH = new ElevatedLineHandle(0);
				aElevationHandles.push(eH);
				this.addChild(eH);
				eH.pushfront = true;

				// Create the End Elevation Handle.
				eH = new ElevatedLineHandle(1);
				aElevationHandles.push(eH);
				this.addChild(eH);
				eH.pushfront = true;
				
				// Reposition handles.
				repositionElevationHandles();
			} else {
				repositionElevationHandles();
			}
		}
		
		protected function repositionElevationHandles():void {
			//trace("repositionHandles");
			var cmd:Vector.<PathCommand> = _linePathData.aSegments;
			if (cmd != null) {
				if (cmd.length <= 1) return;
				// Reposition handles.
				aElevationHandles[0].x = cmd[0].pStart.x;
				aElevationHandles[0].y = cmd[0].pStart.y+40;
				aElevationHandles[0].z = cmd[0].pStart.z;
				aElevationHandles[0].pushfront = true;
				aElevationHandles[1].x = cmd[cmd.length-1].pEnd.x;
				aElevationHandles[1].y = cmd[cmd.length-1].pEnd.y+40;
				aElevationHandles[1].z = cmd[cmd.length-1].pEnd.z;
				aElevationHandles[1].pushfront = true;
			}
		}
		
		protected override function removeHandles():void {
			displayElevationHandles(false);
			selectedHandle = null;
			for each(var h:ElevatedLineHandle in aElevationHandles) {
				//eH.removeEventListener(MouseEvent3D.MOUSE_DOWN, onEHMouseDown);
				//eH.removeEventListener(Object3DEvent.POSITION_CHANGED, onEHMouseMove);
				//eH.removeEventListener(SSPEvent.CONTROL_CANCEL, onCancelEditMode);
				h.dispose();
				h = null;
			}
		}
		
		protected override function onMouseUp(e:MouseEvent):void {
			trace("ElevatedLine.onStageMouseUp()");
			//eHandlesEnableListeners(false);
			main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onEHMouseMove);
			main.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			repositionElevationHandles();
			repositionHandles();
			handlesVisible(true);
			eHandlesEnableListeners(true);
			sG.editMode = false;
		}
		
		protected function onEHMouseDown(e:MouseEvent3D):void {
			trace("ElevatedLine.onEHMouseDown()");
			// Get the selected Handle array index, it's the same than the aSegment index.
			var hP:ElevatedLineHandle = e.target as ElevatedLineHandle;
			currentLineIdx = hP.handleIndex;
			if (currentLineIdx < 0) return;
			
			disableHPMoves();
			eHandlesEnableListeners(false);
			handlesVisible(false);
			oldYPos = main.stage.mouseY;
			main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onEHMouseMove);
			main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			sScreen.drag3d.object3d = null;
			sG.editMode = true;
		}
		
		protected function onEHMouseMove(e:MouseEvent):void {
			var mouseYPos:Number = main.stage.mouseY;
			var newYDistance:Number = (isNaN(oldYPos))? 0 : oldYPos - mouseYPos;
			var newLineYPos:Number;
			
			if (currentLineIdx == 0) {
				newLineYPos = _linePathData.aSegments[currentLineIdx].pStart.y + newYDistance; 
				if (newLineYPos < 0) newLineYPos = 0;
				if (newLineYPos > maxElevation) newLineYPos = maxElevation;
				_linePathData.aSegments[currentLineIdx].pStart.y = newLineYPos;
				_linePathData.aSegments[currentLineIdx].pControl.y = newLineYPos;
				_linePathData.aSegments[currentLineIdx].pEnd.y = newLineYPos;
				_linePathData.aSegments[1].pStart.y = newLineYPos;
				_linePathData.aSegments[1].pControl.y = newLineYPos;
			} else {
				newLineYPos = _linePathData.aSegments[currentLineIdx].pEnd.y + newYDistance; 
				if (newLineYPos < 0) newLineYPos = 0;
				if (newLineYPos > maxElevation) newLineYPos = maxElevation;
				_linePathData.aSegments[currentLineIdx].pEnd.y = newLineYPos;
			}
			oldYPos = mouseYPos;
			// Update the main line, but the shadow.
			this.updateLine(false, false);
		}
	}
}