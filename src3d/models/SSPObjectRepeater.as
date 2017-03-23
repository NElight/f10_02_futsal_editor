package src3d.models
{
	import flash.geom.Vector3D;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.utils.Dragger;

	public class SSPObjectRepeater
	{
		public static const AXIS_X:String = "x";
		public static const AXIS_Y:String = "y";
		public static const AXIS_Z:String = "z";
		
		// Targets.
		private var mainObject:Equipment;
		//private var mainObject:ObjectContainer3D;
		
		// Settings.
		private var pStart:Vector3D;
		private var pControl:Vector3D;
		private var pEnd:Vector3D;
		private var maxFullDistance:Number = 1000; // Max distance to repeat objects.
		private var maxSpace:Number = 100; // Max space between objects.
		private var lastDistance:Number = 0;
		private var objAxis:String;
		private var rEnabled:Boolean;
		private var handlePos:Vector3D;
		private var oldPointsAmount:uint;
		private var drag3d:Dragger;
		
		private var rHandle1:SSPObjectRepeaterHandle;
		
		public function SSPObjectRepeater(mainObject:Equipment, drag3d:Dragger, maxSpace:Number = 100, maxFullDistance:Number = 1000, objAxis:String = AXIS_Z) {
			this.mainObject = mainObject;
			this.drag3d = drag3d;
			this.objAxis = objAxis;
			this.maxSpace = maxSpace;
			this.maxFullDistance = maxFullDistance;
			init();
		}
		
		private function init():void {
			// Repeater handle.
			rHandle1 = new SSPObjectRepeaterHandle(this, mainObject.mainContainerHeight);
			mainObject.addChild(rHandle1);
			// Path Points.
			pStart = mainObject.pathData.aSegments[0].pStart;
			pControl = pStart.clone();
			pEnd = mainObject.pathData.aSegments[0].pEnd;
		}
		
		public function startRepeater():void {
			if (!mainObject.repeatable) return;
			var newDistance:Number = Vector3D.distance(pStart,pEnd);
			if (isNaN(newDistance)) return;
			if ( newDistance > (pEnd.z+(maxSpace*mainObject.getGlobalScale())) || newDistance < (pEnd.z-(maxSpace*mainObject.getGlobalScale())) ) {
				pEnd.z = -newDistance;
				pControl.z = -newDistance/2;
				lastDistance = newDistance;
				updateObjects();
			}
		}
		
		public function updateRepeater(useMousePos:Boolean, useSteps:Boolean):void {
			if (!mainObject || !mainObject.repeatable || !rEnabled) return;
			var newDistance:Number = 0;
			if (useMousePos) {
				var MousePos:Vector3D = drag3d.getIntersect();
				var finalDistance:Number = Math.abs(Vector3D.distance(mainObject.position,MousePos));
				if (finalDistance > maxFullDistance) finalDistance = maxFullDistance;
				if (finalDistance == lastDistance) return; // Avoid repeating commands.
				handlePos = mainObject.position.clone();
				newDistance = finalDistance;
				
				// Update rotation.
				//mainObject.objectRotationY = Math.atan2(mainObject.x-MousePos.x,mainObject.z-MousePos.z)*180/Math.PI;
				mainObject.rotator.rotateObject(true, useSteps);
			} else {
				newDistance = lastDistance;
			}
			
			if ( newDistance > (pEnd.z+(maxSpace*mainObject.getGlobalScale())) || newDistance < (pEnd.z-(maxSpace*mainObject.getGlobalScale())) ) {
				handlePos = drag3d.getIntersect().clone();
				pEnd.z = -newDistance;
				pControl.z = -newDistance/2;
				
				lastDistance = newDistance;
				updateObjects();
			}
		}
		
		private function updateObjects():void {
			if (mainObject) mainObject.repeatObjects(maxSpace,lastDistance);
		}
		
		public function repeaterEnabled(enableRepeater:Boolean):void {
			this.rEnabled = enableRepeater;
			updateObjects();
			if (rHandle1) rHandle1.handleEnabled(enableRepeater);
		}
		
		public function toggleEditMode(editMode:Boolean):void {
			if (mainObject) mainObject.toggleEditMode(editMode);
		}
		
		public function dispose():void {
			repeaterEnabled(false);
			rHandle1.dispose();
			rHandle1 = null;
			mainObject = null;
			pStart = null;
			pControl = null;
			pEnd = null;
			handlePos = null;
			drag3d = null;
		}
	}
}