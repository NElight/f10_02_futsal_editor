package src3d.lines
{
	import away3d.core.geom.PathCommand;
	import away3d.events.MouseEvent3D;
	import away3d.events.Object3DEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.SSPEvent;
	import src3d.SessionScreen;
	import src3d.models.SSPObjectBaseSettings;
	
	public class CustomLine extends DynamicLine
	{
		// Line Scaling Properties (see CustomLines.as).
		private var posA:Vector3D;
		private var posP:Vector3D;
		private var posB:Vector3D;
		private var distABOld:Vector3D; // Distance between start and end point.
		private var distABNew:Vector3D; // Distance between start and end point after mouse move.
		private var distAPOld:Vector3D; // Distance between start and inner point.
		private var distAPNew:Vector3D; // Distance between start and inner point after mouse move.
		private var changeY:Boolean = false; // Set if Y axis should be scaled too.
		
		public function CustomLine(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings)
		{
			super(sessionScreen, objSettings);
		}

		protected override function onHPMouseDown(e:MouseEvent3D):void {
			//trace("CustomLine.onHPMouseDown()");
			logger.addUser("Using handle to modify custom line '"+this.name+"'.");
			// Get the selected Handle array index, it's the same than the aSegment index.
			var hIdx:int = aHandles.indexOf(e.target);
			if (hIdx > -1) {
				this.updateRefLine();
				pCommand2 = null;
				pCommand1 = null;
				
				// Get the First and Last handler point positions. posA will be the static point.
				if (hIdx == 0) {
					posA = aHandles[aHandles.length-1].position;
					posB = aHandles[0].position;
				} else {
					posA = aHandles[0].position;
					posB = aHandles[aHandles.length-1].position;
				}
				// Get the distance between the first and last handler point.
				distABOld = posA.subtract(posB);
				
				// Get the selected Handle.
				selectedHandle = aHandles[hIdx];

				// We need to modify two path commands: pC1.pEnd and (pC2.pStart, pC2.pControl);
				pCommand1 = linePathData.aSegments[hIdx];
				// Store the next path only if it exists.
				if (hIdx < linePathData.aSegments.length-1) {
					pCommand2 = linePathData.aSegments[hIdx+1];
				}
				
				handlesVisible(false); // hides handles and remove listeners.
				main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onHPMouseMove);
				main.stage.addEventListener(MouseEvent.MOUSE_UP, onHPStageMouseUp);
				drag3d.object3d = null;
				drag3d.removeOffsetCenter();
				// Listen if SessionView orders to cancel all edits.
				sspEventHandler.addEventListener(SSPEvent.CONTROL_CANCEL, onCancelEditMode, false, 0, true);
				toggleEditMode(true);
			} else {
				trace("Can't select Handler Point");
			}
		}
		
		protected override function onHPMouseMove(e:MouseEvent):void {
			//trace("onHPMouseMove");
			// NOTE:
			// (distAPOld / distAPNew) = (distABOld / distABNew).
			
			distAPOld = new Vector3D();
			distAPNew = new Vector3D();
			var distAPNewFinal:Vector3D = new Vector3D();
			// Store the actual position.
			posB = drag3d.getIntersect().clone();
			// Get new AB distance.
			distABNew = posA.subtract(posB);

			// The first PathCommand is 'Move'. So we ignore it, but take the next segment's starting point from it.
			var pc:PathCommand = linePathData.aSegments[0];
//			var newPStart:Vector3D = pc.pEnd.clone();
			// Set the current segment's starting point.
//			pc.pStart = newPStart.clone();
			//pc.pControl = newPStart.clone();
			// Process the rest of segments.
			for (var i:int=0; i<linePathData.aSegments.length; i++) {
				pc = linePathData.aSegments[i];
				
					// ------ pStart ------ //
					
					// Get current segment's end point.
					posP = pc.pStart.clone();
					// Get distance between posA and current point.
					distAPOld = posA.subtract(posP);
					
					// -- X Axis -- //
					// Get distance between posA and point's new position.
					distAPNew.x = (distABNew.x * distAPOld.x) / distABOld.x;
					// Get the distance that pc should be moved.
					distAPNewFinal.x = distAPOld.x - distAPNew.x;
					pc.pStart.x += distAPNewFinal.x;
					
					// -- Z Axis -- //
					// Get distance between posA and point's new position.
					distAPNew.z = (distABNew.z * distAPOld.z) / distABOld.z;
					// Get the distance that pc should be moved.
					distAPNewFinal.z = distAPOld.z - distAPNew.z;
					pc.pStart.z += distAPNewFinal.z;
					
					if (changeY) {}
					
					
					// ------ pEnd ------ //
					
					// Get current segment's end point.
					posP = pc.pEnd.clone();
					// Get distance between posA and current point.
					distAPOld = posA.subtract(posP);
					
					// -- X Axis -- //
					// Get distance between posA and point's new position.
					distAPNew.x = (distABNew.x * distAPOld.x) / distABOld.x;
					// Get the distance that pc should be moved.
					distAPNewFinal.x = distAPOld.x - distAPNew.x;
					pc.pEnd.x += distAPNewFinal.x;
					
					// -- Z Axis -- //
					// Get distance between posA and point's new position.
					distAPNew.z = (distABNew.z * distAPOld.z) / distABOld.z;
					// Get the distance that pc should be moved.
					distAPNewFinal.z = distAPOld.z - distAPNew.z;
					pc.pEnd.z += distAPNewFinal.z;
					
					if (changeY) {}
					
					// ------ pControl ------ //
					
					// Get current segment's end point.
					posP = pc.pControl.clone();
					// Get distance between posA and current point.
					distAPOld = posA.subtract(posP);
					
					// -- X Axis -- //
					// Get distance between posA and point's new position.
					distAPNew.x = (distABNew.x * distAPOld.x) / distABOld.x;
					// Get the distance that pc should be moved.
					distAPNewFinal.x = distAPOld.x - distAPNew.x;
					pc.pControl.x += distAPNewFinal.x;
					
					// -- Z Axis -- //
					// Get distance between posA and point's new position.
					distAPNew.z = (distABNew.z * distAPOld.z) / distABOld.z;
					// Get the distance that pc should be moved.
					distAPNewFinal.z = distAPOld.z - distAPNew.z;
					pc.pControl.z += distAPNewFinal.z;
					
					if (changeY) {}
					
					// Store the next segment's starting point.
					//newPStart = pc.pEnd.clone();
			}
			distABOld = distABNew.clone();

			//this.updateLine(true);
			this.updateRefLine();
		}
		
		protected override function onHPStageMouseUp(e:MouseEvent):void {
			logger.addUser("Finished modifying custom line '"+this.name+"'.");
			super.onHPStageMouseUp(e);
		}
	}
}