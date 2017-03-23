package src3d
{
	import src.team.TeamGlobals;
	
	import src3d.utils.Logger;
	import src3d.utils.Validator;
	
	public class ScreenSettings
	{
		private static var logger:Logger = Logger.getInstance();
		
		public function ScreenSettings()
		{
		}
		
		/**
		 * Validates <screen> settings. 
		 * @param sS <screen> XML.
		 * @param checkIfEmpty Boolean. It will check if the field if empty.
		 * @param defaultIfEmpty Boolean. It will apply a default value if tag is empty. If the tag can have an empty value, this setting will be ignored for that specific tag.
		 * @param createMissing Boolean. True to create an empty tag if it doesn't exist.
		 * @param includeCameraSettings Boolean. True to include camera settings check.
		 * @return
		 */		
		public static function validateScreenSettings(sS:XML, checkIfEmpty:Boolean, defaultIfEmpty:Boolean, createMissing:Boolean, includeCameraSettings:Boolean):Boolean {
			var settingsOK:Boolean = true;
			var defVal:String = "";
			var strDbTransitionId:String = "0"; // 0 is the default value for all new screens.
			
			defVal = (createMissing)? "0" : "";
			settingsOK = Validator.validateTag(sS, "_dbTransitionId", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			if (uint(sS._dbTransitionId.text()) <= 10) sS._dbTransitionId = strDbTransitionId; // Fix to solve _dbTransition > 0 server issue.
			
			defVal = (createMissing)? "0" : "";
			settingsOK = Validator.validateTag(sS, "_globalObjScale", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			
			defVal = (createMissing)? "0" : "";
			settingsOK = Validator.validateTag(sS, "_globalRotationY", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			
			defVal = (createMissing)? "0" : "";
			settingsOK = Validator.validateTag(sS, "_pitchFloorId", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			
			defVal = (createMissing)? "0" : "";
			settingsOK = Validator.validateTag(sS, "_pitchMarksId", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			
			if (SessionGlobals.getInstance().sessionTypeIsMatch) {
				defVal = "0";
				if (sS._screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					settingsOK = Validator.validateTag(sS, "_screenCategoryId", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
					sS._screenCategoryId = defVal; // Force _screenCategoryId = 0 for all Periods.
				} else {
					settingsOK = Validator.validateTag(sS, "_screenCategoryId", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
				}
			} else {
				defVal = (createMissing)? getDefaultScreenCategoryId() : "";
				settingsOK = Validator.validateTag(sS, "_screenCategoryId", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			}
			
			defVal = "";
			settingsOK = Validator.validateTag(sS, "_screenTitle", false, false, defVal, createMissing, false);
			
			defVal = "";
			settingsOK = Validator.validateTag(sS, "_screenComments", false, false, defVal, createMissing, false); // Do not validate as number because it can be an empty tag.
			
			// These tags are ignored. They can be empty or use increasing values.
			//defVal = (createMissing)? "0" : "";
			//settingsOK = Validator.validateTag(sS, "_screenId");
			
			//defVal = (createMissing)? "0" : "";
			//settingsOK = Validator.validateTag(sS, "_screenSortOrder");
			
			//defVal = (createMissing)? "TRUE" : "";
			//settingsOK = Validator.validateTag(sS, "_screenChangedFlag");
			
			// Validate Camera Settings if needed.
			if (includeCameraSettings) {
				defVal = (createMissing)? SSPCameraSettings.DEFAULT_CAM_PAN_ANGLE.toString() : "";
				settingsOK = Validator.validateTag(sS, "_cameraPanAngle", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
				
				defVal = (createMissing)? SSPCameraSettings.DEFAULT_CAM_TILT_ANGLE.toString() : "";
				settingsOK = Validator.validateTag(sS, "_cameraTiltAngle", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
				
				defVal = (createMissing)? SSPCameraSettings.DEFAULT_CAM_ZOOM.toString() : "";
				settingsOK = Validator.validateTag(sS, "_cameraZoom", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
				
				defVal = (createMissing)? SSPCameraSettings.DEFAULT_CAM_TARGET.toString() : "";
				settingsOK = Validator.validateTag(sS, "_cameraTarget", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
				
				// F11 (v2) settings.
				defVal = (createMissing)? SSPCameraSettings.DEFAULT_CAM_FOV.toString() : "";
				settingsOK = Validator.validateTag(sS, "_cameraFOV", false, false, defVal, createMissing, true); // Do not validate as number because it can be an empty tag.
				
				defVal = (createMissing)? SSPCameraSettings.DEFAULT_CAM_TYPE.toString() : "";
				settingsOK = Validator.validateTag(sS, "_cameraType", checkIfEmpty, defaultIfEmpty, defVal, createMissing, true);
			}
			
			// Validate Match Settings.
			if (SessionGlobals.getInstance().sessionTypeIsMatch) {
				if (sS._screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					defVal = (createMissing)? TeamGlobals.SCREEN_FORMATION_P2 : "";
					settingsOK = Validator.validateTag(sS, "_screenFormat", checkIfEmpty, defaultIfEmpty, defVal, createMissing, false, false);
					defVal = (createMissing)? TeamGlobals.vFormations[0].name : "";
					settingsOK = Validator.validateTag(sS, "_screenFormationOurs", checkIfEmpty, defaultIfEmpty, defVal, createMissing, false, false);
					defVal = (createMissing)? TeamGlobals.vFormations[0].name : "";
					settingsOK = Validator.validateTag(sS, "_screenFormationOpposition", checkIfEmpty, defaultIfEmpty, defVal, createMissing, false, false);
				} else {
					defVal = "";
					settingsOK = Validator.validateTag(sS, "_screenFormat", false, defaultIfEmpty, defVal, createMissing, false, false);
					defVal = "";
					settingsOK = Validator.validateTag(sS, "_screenFormationOurs", false, defaultIfEmpty, defVal, createMissing, false, false);
					defVal = "";
					settingsOK = Validator.validateTag(sS, "_screenFormationOpposition", false, defaultIfEmpty, defVal, createMissing, false, false);
				}
			}
			
			// User Image and Video Settings.
			defVal = "";
			settingsOK = Validator.validateTag(sS, "_userImageLocation", false, defaultIfEmpty, defVal, createMissing, false, false);
			defVal = ScreenSettingsDefault.USER_VIDEO;
			settingsOK = Validator.validateTag(sS, "user_video", checkIfEmpty, defaultIfEmpty, defVal, createMissing, false, false);
			
			return settingsOK;
		}
		
		private static function getDefaultScreenCategoryId():String {
			var strDefGlob:String = "2"; // It may not exist in all global data's but it may avoid some saving errors in some sports.
			var strDefId:String = SessionGlobals.getInstance().sessionDataXML.session[0]._sessionCategoryId.text();
			if (strDefId == null || strDefId == "") {
				logger.addText("(A) - Can't get _sessionCategoryId from session data, using "+strDefGlob+" as default.", false);
				strDefId = strDefGlob;
				//strDefId = SessionGlobals.getInstance().menuDataXML.meta_data[0].children().(localName() == "category")[0].@_globCategoryId[0];
				//if (strDefId == null || strDefId == "") {
				//	logger.addText("(A) - Can't get lower _globCategoryId from global data, using "+strDefGlob+" as default.", false);
				//	strDefId = strDefGlob;
				//}
			}
			return strDefId;
		}
		
		public static function validateScreenDefaultsSettings():void {
			// If <screen_defaults> does not exists, create it.
			var sessionXML:XML = SessionGlobals.getInstance().sessionDataXML.session[0];
			if (sessionXML.children().(localName() == "screen_defaults").length() <= 1) {
				logger.addText("No screen_defaults tags found in session data. Creating with internal defaults.", true);
				var pXML:XML = new XML(<screen_defaults/>);
				pXML._screenType = SessionGlobals.SCREEN_TYPE_PERIOD;
				pXML._screenPlayerNameFormat = TeamGlobals.DEFAULTS_PLAYER_NAME_FORMAT;
				pXML._screenPlayerModelFormat = TeamGlobals.DEFAULTS_PLAYER_MODEL_FORMAT;
				sessionXML.appendChild(pXML);
				var sXML:XML = new XML(<screen_defaults/>);
				sXML._screenType = SessionGlobals.SCREEN_TYPE_SET_PIECE;
				sXML._screenPlayerNameFormat = TeamGlobals.DEFAULTS_PLAYER_NAME_FORMAT;
				sXML._screenPlayerModelFormat = TeamGlobals.DEFAULTS_PLAYER_MODEL_FORMAT;
				sessionXML.appendChild(sXML);
			}
		}
	}
}