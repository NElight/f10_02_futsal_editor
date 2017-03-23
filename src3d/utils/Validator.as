package src3d.utils
{
	import src.controls.mixedslider.MixedSlider;
	import src.controls.mixedslider.MixedSliderValues;
	import src.team.TeamGlobals;
	
	import src3d.ScreenSettingsDefault;
	import src3d.SessionGlobals;

	public class Validator
	{
		private static var logger:Logger = Logger.getInstance();
		private static var sG:SessionGlobals = SessionGlobals.getInstance();
		private static var sL:XML = SessionGlobals.getInstance().interfaceLanguageDataXML;
		
		public function Validator()
		{
		}
		
		public static function validateAll(checkIfEmpty:Boolean, defaultIfEmpty:Boolean, createMissing:Boolean):void {
			var settingsOK:Boolean = true;
			var defVal:String = "";
			var tagXML:XML;
			
			// Team Settings.
			if (sG.sessionTypeIsMatch) {
				tagXML = sG.sessionDataXML.session[0];
				defVal = (createMissing)? sL.titles._teamNameOursDefault.text() : "";
				settingsOK = validateTag(tagXML, "_teamNameOurs", false, defaultIfEmpty, defVal, createMissing, false);
				
				//tagXML = sG.sessionDataXML.session[0];
				defVal = (createMissing)? sL.titles._teamNameOppositionDefault.text() : "";
				settingsOK = validateTag(tagXML, "_teamNameOpposition", false, defaultIfEmpty, defVal, createMissing, false);
				
				//tagXML = sG.sessionDataXML.session[0];
				defVal = (createMissing)? TeamGlobals.getInstance().aPlayersPerTeam[0] : "";
				settingsOK = validateTag(tagXML, "_teamPlayersPerTeam", checkIfEmpty, defaultIfEmpty, defVal, createMissing, false);
			}
			
			// User Video Settings (Overall Session).
			tagXML = sG.sessionDataXML.session[0];
			defVal = ScreenSettingsDefault.USER_VIDEO;
			settingsOK = validateTag(tagXML, "user_video", checkIfEmpty, defaultIfEmpty, defVal, createMissing, false, false);
		}
		
		/**
		 * @param xml XML. Main XML.
		 * @param tagName String.
		 * @param checkIfEmpty Boolean. Check if no tag exist or is empty.
		 * @param defaultIfEmpty Boolean. Use specified value if empty.
		 * @param defVal String. default value for the tag.
		 * @param createMissing Boolean. Create if not exist.
		 * @param asNumber Boolean. True to validate tag value as Number.
		 * @param errorMissing Boolean. True to log an error if tag is missing.
		 * @return True if no errors.
		 */		
		public static function validateTag(xml:XML, tagName:String, checkIfEmpty:Boolean, defaultIfEmpty:Boolean, defaultVal:String, createMissing:Boolean, asNumber:Boolean = false, errorIfEmpty:Boolean = true):Boolean {
			var settingOK:Boolean = true;
			var sId:String = xml._screenId.text();
			var sSO:String = xml._screenSortOrder.text();
			var screenInfo:String = (sId != "" || sSO != "")? "("+sId+","+sSO+") - " : "";
			var tagValue:String = getTagValue(xml, tagName);
			var tagsFound:uint = getTagsFound(xml, tagName);
			var msg:String;
			var defVal:XMLList = new XMLList(defaultVal);
			
			// If tag doesn't exist or default value is forced.
			if (createMissing && tagsFound == 0) {
				xml[tagName] = ""; // If tag doesn't exists, create it with empty val.
				msg = screenInfo+tagName+" not found. Created (empty).";
				logger.addAlert(msg);
			}
			
			if (asNumber) {
				// Validate as Number.
				if (checkIfEmpty) {
					if (tagValue == "" || tagsFound == 0) {
						settingOK = false;
						msg = screenInfo+tagName+" Missing or Empty tag.";
						if (errorIfEmpty) {
							logger.addError(msg);
						} else {
							logger.addAlert(msg);
						}
						if (defaultIfEmpty) {
							xml[tagName] = defVal; // If tag doesn't exists, it will be created with default value.
							msg = screenInfo+tagName+" value set to '"+defVal+"'";
							logger.addAlert(msg);
						}
					}
				} else {
					if (isNaN(Number( tagValue )) || tagsFound == 0) {
						settingOK = false;
						msg = screenInfo+tagName+" Missing or Incorrect value.";
						logger.addAlert(msg);
					}
				}
			} else {
				// Validate as String.
				if (checkIfEmpty) {
					if (tagValue == "" || tagsFound == 0) {
						settingOK = false;
						msg = screenInfo+tagName+" Missing or Empty tag.";
						if (errorIfEmpty) {
							logger.addError(msg);
						} else {
							logger.addAlert(msg);
						}
						if (defaultIfEmpty) {
							xml[tagName] = defVal; // If tag doesn't exists, it will be created with default value.
							msg = screenInfo+tagName+" value set to '"+defaultVal+"'";
							logger.addAlert(msg);
						}
					}
				} else {
					if (tagsFound == 0) {
						settingOK = false;
						msg = screenInfo+tagName+" Missing.";
						logger.addAlert(msg);
					}
				}
			}
			
			return settingOK;
		}
		
		private static function getTagsFound(xml:XML, tagName:String):uint {
			var _tagsFound:uint = xml.children().(localName() == tagName).length();
			return _tagsFound;
		}
		
		private static function getTagValue(xml:XML, tagName:String):String {
			var tagList:XMLList = xml.children().(localName() == tagName);
			var _tagValue:String = "";
			if (tagList.length() > 0) {
				if (tagList.children().length() == 1) {
					_tagValue = String(tagList[0].text());
				} else {
					_tagValue = tagList.toString();
				}
			}
			return _tagValue;
		}
		
		public static function validateSkillsMix(sXML:XML):void {
			try {
				var mixedSliderValues:MixedSliderValues = new MixedSliderValues(MixedSlider.barW);
				var strTec:String = sXML._skillsTechnical.text();
				var strTac:String = sXML._skillsTactical.text();
				var strPhy:String = sXML._skillsPhysical.text();
				var strPsy:String = sXML._skillsPsychological.text();
				var strSoc:String = sXML._skillsSocial.text();
				
				logger.addInfo("Checking Skills Mix values (Tec:"+strTec+", Tac:"+strTac+", Phy:"+strPhy+", Psy:"+strPsy+", Soc:"+strSoc+").");
				
				if (strTec == "" || strTac == "" || strPhy == "" || strPsy == "" || strSoc == "") {
					logger.addError("Empty Skills Mix values found. Using default (-1).");
					sXML._skillsTechnical = "-1";
					sXML._skillsTactical = "-1";
					sXML._skillsPhysical = "-1";
					sXML._skillsPsychological = "-1";
					sXML._skillsSocial = "-1";
					return;
				}
				
				var cPerc:Object;
				var pTec:Number = Number(strTec);
				var pTac:Number = Number(strTac);
				var pPhy:Number = Number(strPhy);
				var pPsy:Number = Number(strPsy);
				var pSoc:Number = Number(strSoc);
				
				if (pTec+pTac+pPhy+pPsy+pSoc == -5) {
					Logger.getInstance().addInfo("Default values in Skills Mix. No fix done.");
					return;
				}
				
				mixedSliderValues.setPercents(strTec, strTac, strPhy, strPsy, strSoc);
				
				if (!mixedSliderValues.hasCorrectValues) {
					logger.addError("Invalid Skills Mix values (Tec:"+strTec+", Tac:"+strTac+", Phy:"+strPhy+", Psy:"+strPsy+", Soc:"+strSoc+"). Using default (-1).");
					sXML._skillsTechnical = "-1";
					sXML._skillsTactical = "-1";
					sXML._skillsPhysical = "-1";
					sXML._skillsPsychological = "-1";
					sXML._skillsSocial = "-1";
					return;
				}
				
				// Get percentages. An Object with the following properties: tec, tac, phy, psy, soc (in String format).
				cPerc = mixedSliderValues.getPercents();
				
				if (cPerc) {
					// Save skill mix percentages.
					sXML._skillsTechnical = cPerc.tec;
					sXML._skillsTactical = cPerc.tac;
					sXML._skillsPhysical = cPerc.phy;
					sXML._skillsPsychological = cPerc.psy;
					sXML._skillsSocial = cPerc.soc;
				} else {
					logger.addError("Can't validate Skills Mix (Tec:"+pTec+", Tac:"+pTac+", Phy:"+pPhy+", Psy:"+pPsy+", Soc:"+pSoc+").");
				}
			} catch (error:Error) {
				var errorStr:String = "Skills Mix Validation - Error ("+error.errorID+"): "+error.message;
				logger.addError(errorStr);
			}
		}
	}
}