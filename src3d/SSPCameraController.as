package src3d
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.HoverCamera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.events.CameraEvent;
	import away3d.events.ViewEvent;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class SSPCameraController
	{
		// Controller vars.
		private var camera:HoverCamera3D;
		private var objDrag:*;
		private var _stage:Stage;
		private var _camLocked:Boolean; // Mainly used by 3D button 'camera lock'. The user can lock the camera to drag objects. See camLock() and camUnlock().
		private var cameraSteps:uint = 1;
		private var _cameraType:uint;
		
		// Camera settings.
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var newPanAngle:Number;
		private var newTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var _cameraTarget:uint = SSPCameraSettings.DEFAULT_CAM_TARGET;
		private var _fullScreen:Boolean;
		
		// SSP Camera controls.
		private var camZoomIn:Boolean;
		private var camZoomOut:Boolean;
		private var camTiltUp:Boolean;
		private var camTiltDown:Boolean;
		private var camPanLeft:Boolean;
		private var camPanRight:Boolean;
		private var _previousTarget:Object3D;
		private var _previousPanAngle:Number;
		private var _previousTiltAngle:Number;
		private var _previousZoom:Number;
		
		private var camRotateWithMouse:Boolean;
		private var cS:SSPCameraSettings = new SSPCameraSettings();
		private var sSXML:XML;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		// List of problematic tilt angles in Away3D 3.6.
		public static var aTiltAngles:Array = [
			4.2,5.1,15.1,17.2,20.2,20.3,29.8,29.9,30,30.7,34.8,37.7,37.9,38,
			40.2,42.2,44.4,44.8,45.4,47.2,48.3,49,49.6,51,51.3,52.7,53.2,53.4,54.9,55.9,56.1,56.2,57.9,
			72.3,73.6,75.1,76.9,77,77.3,77.7,77.8,78.3,79,81.7,83.5,83.8,88,88.7,88.9];
		public static var tiltAngleFix:Number = 0.03;
		
		public function SSPCameraController(view3d:View3D, objToDragFrom:*, stage:Stage):void
		{
			view3d.camera = new HoverCamera3D({
				distance:SSPCameraSettings.DEFAULT_CAM_DISTANCE, // With distance 2000 we avoid missing vector pitch marks.
				focus:SSPCameraSettings.DEFAULT_CAM_FOCUS,
				zoom:SSPCameraSettings.DEFAULT_CAM_ZOOM, // Always > 0 or scene rendering won't work.
				minTiltAngle:SSPCameraSettings.DEFAULT_CAM_MIN_TILT_ANGLE,
				maxTiltAngle:SSPCameraSettings.DEFAULT_CAM_MAX_TILT_ANGLE,
				panAngle:SSPCameraSettings.DEFAULT_CAM_PAN_ANGLE,
				tiltAngle:SSPCameraSettings.DEFAULT_CAM_TILT_ANGLE,
				steps:SSPCameraSettings.DEFAULT_CAM_STEPS,
				lens:new PerspectiveLens(),
				name:"SSPCamera"
			});
			this.camera = view3d.camera as HoverCamera3D;
			camera.lookAt(new Vector3D(0,100,0));
			//camera.addOnCameraUpdate(onCameraUpdate);
			//view3d.addOnViewUpdate(onViewUpdate);
			
			this.objDrag = objToDragFrom;
			this._stage = stage;
			this._cameraType = SSPCameraSettings.CAM_TYPE_HOVER;
			
			_previousTarget = camera.target;
			_previousPanAngle = camera.panAngle;
			_previousTiltAngle = camera.tiltAngle;
			_previousZoom = camera.zoom;
			initListeners();
		}
		
		private function onCameraUpdate(e:CameraEvent):void {
			trace("onCameraUpdate()");
		}
		
		private function onViewUpdate(e:ViewEvent):void {
			trace("onViewUpdate()");
		}
		
		private function initListeners():void {
			// Setup event listeners
			objDrag.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			objDrag.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelHandler);
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			_stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeaveHandler);
			
			// 2D Control listeners.
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_ZOOM_IN, onCamZoomIn);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_ZOOM_OUT, onCamZoomOut);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_CAMERA_UP, onCamTiltUp); // includes: true.
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_CAMERA_DOWN, onCamTiltDown); // includes: true.
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_CAMERA_LEFT, onCamPanLeft); // includes: true.
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_CAMERA_RIGHT, onCamPanRight); // includes: true.
			//sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_CAMERA_LOCK, onLockCamera); // Do not remove this event.
			sspEventHandler.addEventListener(SSPEvent.CAMERA_STOP_MOVING, onCameraStop);
			
			// Setup render enter frame event listener
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		/* Camera Controls */
		private function onCamZoomIn(e:SSPEvent):void {camZoomIn = e.eventData;}
		private function onCamZoomOut(e:SSPEvent):void {camZoomOut = e.eventData;}
		private function onCamTiltUp(e:SSPEvent):void {camTiltUp = e.eventData;}
		private function onCamTiltDown(e:SSPEvent):void {camTiltDown = e.eventData;}
		private function onCamPanLeft(e:SSPEvent):void {camPanLeft = e.eventData;}
		private function onCamPanRight(e:SSPEvent):void {camPanRight = e.eventData;}
		/*private function onLockCamera(e:SSPEvent):void {
			trace("Camera locked: "+e.eventData);
			if (e.eventData == true) {
				camLocked = true;
			} else {
				camLocked = false;
			}
		}*/
		
		private function onMouseUpHandler(e:MouseEvent):void { stopMoving(); }
		private function onStageMouseLeaveHandler(e:Event):void { stopMoving(); }
		private function onCameraStop(e:SSPEvent):void {stopMoving();}
		
		/**
		 * Start dragging.
		 */
		private function onMouseDownHandler(e:MouseEvent) : void {
			if (!sG.camLocked) {
				//trace("Camera Drag.");
				lastPanAngle = camera.panAngle;
				lastTiltAngle = camera.tiltAngle;
				lastMouseX = _stage.mouseX;
				lastMouseY = _stage.mouseY;
				camRotateWithMouse = true;
			}
		}
		
		/**
		 * Updates camera distance.
		 */
		private function onMouseWheelHandler(e:MouseEvent) : void
		{
			var currentZoom:Number = camera.zoom;
			if (currentZoom < SSPCameraSettings.DEFAULT_CAM_MIN_ZOOM && e.delta < 1) return;
			if (currentZoom > SSPCameraSettings.DEFAULT_CAM_MAX_ZOOM && e.delta > 1) return;
			
			var nz:Number = e.delta / 2;
			
			if ((currentZoom + nz) < SSPCameraSettings.DEFAULT_CAM_MIN_ZOOM) nz = 0;
			if ((currentZoom + nz) > SSPCameraSettings.DEFAULT_CAM_MAX_ZOOM) nz = 0;
			this.zoom += nz;
			
			// Debug traces for LODObjects.
			/*trace("Pan: "+camera.panAngle+", Tilt: "
			+camera.tiltAngle+", Zoom: "
			+camera.zoom+", Dist: "
			+camera.distance+" nz: "
			+nz);*/
			var persp:Number = camera.zoom / (1 + camera.distance / camera.focus);
			//trace("Perspective: "+persp);
			var distCam:Number = (1 / persp * camera.zoom -1) * camera.focus;
			//trace("Distance from Cam: "+distCam);
		}
		
		/**
		 * Update cam movement towards its target position.
		 */
		private function onEnterFrameHandler(e:Event) : void {
			if (sG.camLocked) return;
			var camMoved:Boolean;
			// Update camera.
			if (camPanLeft) {
				this.panAngle -= 4;
				camMoved = true;
			}
			if (camPanRight) {
				this.panAngle += 4;
				camMoved = true;
			}
			if (camTiltUp) {
				this.tiltAngle += 2;
				camMoved = true;
			}
			if (camTiltDown) {
				this.tiltAngle -= 2;
				camMoved = true;
			}
			if (camZoomIn && camera.zoom < SSPCameraSettings.DEFAULT_CAM_MAX_ZOOM) camera.zoom += 0.5;
			if (camZoomOut && camera.zoom > SSPCameraSettings.DEFAULT_CAM_MIN_ZOOM) camera.zoom -= 0.5;
			if (camRotateWithMouse) {
				newPanAngle = 0.3 * (_stage.mouseX - lastMouseX) + lastPanAngle;
				newTiltAngle = 0.3 * (_stage.mouseY - lastMouseY) + lastTiltAngle;
				this.panAngle = newPanAngle;
				if (newTiltAngle <= SSPCameraSettings.DEFAULT_CAM_MAX_TILT_ANGLE) this.tiltAngle = newTiltAngle;
				camMoved = true;
			}
			
			if (camera.target != _previousTarget ||
				camera.panAngle != _previousPanAngle ||
				camera.tiltAngle != _previousTiltAngle ||
				camera.zoom != _previousZoom) {
				_previousTarget = camera.target;
				_previousPanAngle = camera.panAngle;
				_previousTiltAngle = camera.tiltAngle;
				_previousZoom = camera.zoom;
				this.storeCameraSettings();
			}
			
			if (camMoved) sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CAMERA_MOVED));
			
			hover(false);
		}
		
		/* Called by SessionView */
		private function hover(jump:Boolean):void {
			/*trace("panAngle: "+panAngle+
				", tiltAngle: "+tiltAngle+
				", zoom: "+zoom+
				" | CamTargetId: "+_cameraTarget+
				", x: "+this.lookingAtTarget.x+
				", y: "+this.lookingAtTarget.y+
				", z: "+this.lookingAtTarget.z+
				" | Jump: "+jump
			);*/
			camera.hover(jump);
			if (jump) storeCameraSettings(); // If forced jump, store current settings.
		}
		
		/**
		 * Camera moving triggers are disabled.
		 * If no 'jump' is used, the smooth camera moves won't stop inmediatly, but when destination is reached. 
		 */		
		private function stopMoving():void {
			//trace("Camera stopMoving()");
			camRotateWithMouse = false;
			camZoomIn = false;
			camZoomOut = false;
			camTiltUp = false;
			camTiltDown = false;
			camPanLeft = false;
			camPanRight = false;
		}
		
		// Controlled by Session Globals now.
		/*public function set camLocked(cLocked:Boolean):void {
			if (!cLocked) {
				trace("CAMERA unlocked now");
			} else {
				trace("CAMERA locked");
			}
			_camLocked = cLocked;
		}
		public function get camLocked():Boolean {return _camLocked;}*/
		
		private function storeCameraSettings():void {
			//trace("storeCameraSettings()");
			if (!sSXML) return;
			sSXML._cameraTarget = _cameraTarget.toFixed(2);
			sSXML._cameraTiltAngle = this.tiltAngle.toFixed(2);
			sSXML._cameraPanAngle = MiscUtils.wrapAngle( this.panAngle ).toFixed(2);
			sSXML._cameraZoom = this.zoom.toFixed(2);
			sSXML._cameraFOV = ""; // F11 setting.
			sSXML._cameraType = this.camType;
		}
		
		private function checkSettings():Boolean {
			var settingsOK:Boolean = true;
			if (cS._cameraPanAngle != MiscUtils.wrapAngle( camera.panAngle ) ||
				cS._cameraTiltAngle != camera.tiltAngle ||
				cS._cameraZoom != camera.zoom ||
				cS._cameraFOV != "" ||
				cS._cameraTarget != _cameraTarget ||
				cS._cameraType != _cameraType)
			{
				settingsOK = false;
			}
			return settingsOK;
		}
		
		private function updateSettings():void {
			// Update settings.
			cS._cameraPanAngle = MiscUtils.wrapAngle( camera.panAngle );
			cS._cameraTiltAngle = camera.tiltAngle;
			cS._cameraZoom = camera.zoom;
			cS._cameraFOV = ""; // F11 setting.
			cS._cameraTarget = _cameraTarget;
			cS._cameraType = _cameraType;
		}
		
		public function moveCameraToXMLSettings(sScreenXML:XML, cameraJump:Boolean = true) {
			sSXML = sScreenXML;
			_cameraTarget = uint( sSXML._cameraTarget.text() );
			this.panAngle = Number( sScreenXML._cameraPanAngle.text() );
			this.tiltAngle = Number( sScreenXML._cameraTiltAngle.text() );
			this.zoom = Number( sScreenXML._cameraZoom.text() );
			//camera.camFOV = Number( sScreenXML._cameraFOV.text() );
			//if (cameraJump) camUpdate();
			hover(cameraJump);
		}
		
		/*public function camUpdate(camSteps:int = -1):void {
			if (camSteps > -1) {
				camera.steps = camSteps;
				camera.hover();
				camera.steps = cameraSteps;
			} else {
				camera.hover(true);
			}
		}*/
		
		public function lookAtObject(obj:ObjectContainer3D):void {
			if (!obj) return;
			lookAtVector3D(obj.position);
		}
		
		public function lookAtVector3D(v:Vector3D):void {
			if (camera.lookingAtTarget != v) {
				camera.lookAt(v, Vector3D.Z_AXIS);
			}
		}
		
		public function forceHover(jump:Boolean):void {
			hover(jump);
		}
		
		public function forceStoreSettings():void {
			storeCameraSettings();
		}
		
		public function clearViewBuffer():void {
			camera.view.clear(); // Clear View buffer to avoid black pitch effect bug.
		}
		
		public function get lookingAtTarget():Vector3D {
			return camera.lookingAtTarget;
		}
		
		public function get cameraPos():Vector3D {
			return camera.position;
		}
		
		public function set targetId(tId:uint):void {
			_cameraTarget = tId;
			if (sSXML) sSXML._cameraTarget = tId.toString();
		}
		
		public function set target(t:Object3D):void {camera.target = t;}
		public function get target():Object3D {return camera.target;}
		public function set tiltAngle(tA:Number):void {
			// View Renderer Issue Fix.
			for (var i:int=0; i<aTiltAngles.length; i++) {
				if (tA == aTiltAngles[i]) {
					tA += tiltAngleFix;
					break;
				}
			}
			camera.tiltAngle = tA;
		}
		public function get tiltAngle():Number {return camera.tiltAngle;}
		public function set panAngle(pA:Number):void {camera.panAngle = pA;}
		public function get panAngle():Number {return camera.panAngle;}
		public function set zoom(z:Number):void {camera.zoom = z;}
		public function get zoom():Number {return camera.zoom;}
		public function get camType():uint {return _cameraType;}
		
		public function get settings():SSPCameraSettings {
			updateSettings();
			return cS;
		}
		
		public function camStopMoves():void {
			hover(true); // Move camera to final position in case it is moving.
			stopMoving();
		}
	}
}