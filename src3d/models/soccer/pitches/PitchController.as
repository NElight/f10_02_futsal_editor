package src3d.models.soccer.pitches
{
	import away3d.cameras.HoverCamera3D;
	import away3d.containers.ObjectContainer3D;
	
	import src3d.SSPCameraController;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.utils.MiscUtils;

	public class PitchController
	{
		// SESSION DATA VARS.
		private var _cameraTarget:int; // Current Camera Target Id.
		private var _pitchMarksId:int = 1; // Current Pitch Marks Id.
		private var _pitchFloorId:int = 1; // Current Pitch Texture Id.
		private var _pitch:Pitch;
		private var _camControl:SSPCameraController;
		private var _camSlowMotion:int = 40;
		private var _prevPitchViewId:int; // Previous 'pitch view' button pressed.
		private var _prevPitchMarksId:int = -1;
		
		public function PitchController(pitch:Pitch, camControl:SSPCameraController)
		{
			_pitch = pitch;
			_camControl = camControl;
		}
			
		/**
		 * 
		 * @param viewBtn String. The name of the pitch view button ("btnPitch01", "btnPitch02", etc.).
		 * @param altAngle Boolean. True to use the secondary camera position.
		 * @param allowSwitchAngle. True to allow auto-switch to the secondary camera position if the pitch view button is clicked the second time.
		 * @return int. The new cameraTargetId.
		 * 
		 */
		public function changePitchView(viewBtn:String, forceAltAngle:Boolean, allowSwitchAngle:Boolean):int {
			var currentCamTarget:int = _pitch.cameraTargetId;
			var currentPanAngle:Number = _camControl.panAngle;
			
			var aPV:Vector.<PitchViewSettings> = PitchViewLibrary.getInstance().aPV;
			var newPVSettings:PitchViewSettings = new PitchViewSettings(PitchLibrary.MARKS_ID_STANDARD,PitchTargets.TARGET_CENTER,PitchTargets.TARGET_CENTER,0,0,0,8,true); // Initialized with dummy values.
			newPVSettings.camTargetId = currentCamTarget;
			newPVSettings.camPanAngle = currentPanAngle;
			var newCamTargetId:int;
			var newPanAngle:Number;
			
			var pVId:int = int(viewBtn.substr(viewBtn.length-2)); // Get the Id from the instance name (last 2 digits).
			
			if (!aPV || pVId >= aPV.length || pVId < 0) return 0; // if not a valid pitch view, return.
			
			// Store Selected Pitch View Settings.
			newPVSettings.pitchMarksId = aPV[pVId].pitchMarksId;
			newPVSettings.showDefaultEquipment = aPV[pVId].showDefaultEquipment; 
			newPVSettings.camTiltAngle = aPV[pVId].camTiltAngle;
			newPVSettings.camZoom = aPV[pVId].camZoom;
			
			// Camera switches angle and target if pitch view button is clicked twice (if available).
			if (allowSwitchAngle && pVId == _prevPitchViewId) {
				if (currentCamTarget == aPV[pVId].camTargetId && currentPanAngle == aPV[pVId].camPanAngle) {
					newCamTargetId = aPV[pVId].camTargetIdAlt;
					newPanAngle = aPV[pVId].camPanAngleAlt;
				} else {
					if (forceAltAngle) {
						newCamTargetId = aPV[pVId].camTargetIdAlt;
						newPanAngle = aPV[pVId].camPanAngleAlt;
					} else {
						newCamTargetId = aPV[pVId].camTargetId;
						newPanAngle = aPV[pVId].camPanAngle;
					}
				}
			} else {
				if (forceAltAngle) {
					newCamTargetId = aPV[pVId].camTargetIdAlt;
					newPanAngle = aPV[pVId].camPanAngleAlt;
				} else {
					newCamTargetId = aPV[pVId].camTargetId;
					newPanAngle = aPV[pVId].camPanAngle;
				}
			}
			
			newPVSettings.camTargetId = newCamTargetId;
			newPVSettings.camPanAngle = newPanAngle;
			
			// Process Pitch View Settings.
			_camControl.clearViewBuffer(); // Clear View buffer to avoid black pitch effect bug.
			if (newPVSettings.pitchMarksId != _prevPitchMarksId) {
				changePitchMarks(newPVSettings.pitchMarksId);
			}
			showDefaultEquipment(newPVSettings.showDefaultEquipment);
			// Update camera after all object changes are made.
			changeCamTarget(newPVSettings.camTargetId, false);
			_camControl.targetId = newPVSettings.camTargetId;
			_camControl.panAngle = newPVSettings.camPanAngle;
			_camControl.tiltAngle = newPVSettings.camTiltAngle;
			_camControl.zoom = newPVSettings.camZoom; // Note F10 uses camera.zoon, F11 uses camera.camFOV.
			/*trace("panAngle: "+_camControl.panAngle+
				", tiltAngle: "+_camControl.tiltAngle+
				", zoom: "+_camControl.zoom
			);*/
			_camControl.forceHover(true);
			_prevPitchMarksId = newPVSettings.pitchMarksId;
			_prevPitchViewId = pVId;
			return newPVSettings.pitchMarksId; // Return the id to store it in the correct <screen> xml.
		}
		
		private function showDefaultEquipment(show:Boolean):void {
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.EQUIPMENT_TOGGLE_DEFAULT,{equipVisible:show, pitchSelected:_pitch}));
		}
		
		public function changePitchMarks(newPitchMarksId:int):int {
			return _pitch.setPitchMarks(newPitchMarksId); // Return the id to store it in the correct <screen> xml.
		}
		
		public function changePitchFloor(newPitchFloorId:int):int {
			return _pitch.setPitchFloor(newPitchFloorId);
		}
		
		public function set pitchEnabled(pEnabled:Boolean):void {
			_pitch.pitchEnabled = pEnabled;
		}
		public function get pitchEnabled():Boolean {
			return _pitch.pitchEnabled;
		}
		
		public function changeCamTarget(newCamTargetId:int, updateCam:Boolean = true):int {
			_pitch.cameraTargetId = newCamTargetId;
			_camControl.target = _pitch.getCamTarget(newCamTargetId);
			_camControl.targetId = newCamTargetId; // To store XML Settings.
			/*trace("CamTargetId: "+newCamTargetId+
				", x: "+_camControl.target.position.x+
				", y: "+_camControl.target.position.y+
				", z: "+_camControl.target.position.z
			);*/
			//if (updateCam) _camControl.update();
			if (updateCam) {
				_camControl.forceHover(true);
			} else {
				_camControl.forceStoreSettings(); // Store current screen settings.
			}
			return newCamTargetId; // Return the id to store it in the correct <screen> xml.
		}
		
		public function dispose():void {
			_pitch = null;
			_camControl = null;
		}
	}
}