package src3d.utils
{
	import com.adobe.crypto.MD5;
	import com.adobe.utils.XMLUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.aszip.compression.CompressionMethod;
	import org.aszip.saving.Method;
	import org.aszip.zip.ASZip;
	
	import ru.inspirit.net.MultipartURLLoader;
	import ru.inspirit.net.events.MultipartURLLoaderEvent;
	
	import src.images.SSPImageItem;
	import src.minutes.MinutesManager;
	import src.popup.MessageBox;
	import src.team.PRTeamManager;
	import src.user.UserMediaManager;
	import src.videos.SSPVideoItem;
	
	import src3d.SSPEvent;
	import src3d.ScreenSettings;
	import src3d.ScreenSettingsDefault;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.SessionView;

	public class SessionDataSaver extends EventDispatcher
	{
		// PseudoThread.
		private var timerXMLTimeOutLimit:uint = 60;
		private var timerXMLTimeOut:Timer;
		private var timerXMLTimeOutIndex:uint;
		private var timerXMLScreens:Timer;
		private var timerXMLScreensIndex:uint;
		/*private var timerXMLObjects:Timer;
		private var timerXMLObjectsIndex:uint;*/
		
		private var totalScreens:int;
		private var processScreen:int;
		private var currentProcessScreen:int = -1;
		private var totalEquipment:int;
		private var processEquipment:int;
		private var totalPlayers:int;
		private var processPlayers:int;
		private var totalLines:int;
		private var processLines:int;
		private var totalTexts:int;
		private var processTexts:int;
		
		// Saving Timer.
		private var timeOutLimitSaver:int = -1;
		private var timerSaverTimeOut:Timer;
		private var timerProgress:Timer;
		private var timerProgressInterval:uint = 5;
		
		private var saveToLocal:Boolean;
		private var _waitingLateSuccess:Boolean;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		private var uM:UserMediaManager = UserMediaManager.getInstance();
		private var _sessionToken:String;
		
		// Saving / Loading Variables.
		private var xmlResponse:XML; // XML Response from server.
		private var fr:FileReference;
		private var urlLoader:URLLoader;
		private var mpLoader:MultipartURLLoader; // Method 2 (Working).
		//private var mpLoader:SocketURLLoader; // Method 3
		private var _outputURL:String = "";
		private var _ref:main;
		private var aScreenshots:Array = []; // Session Screenshots Array.
		private var msgBox:MessageBox;
		private var logger:Logger = Logger.getInstance();
		
		// XML Variables.
		private var newXML:XML;
		private var tmpXMLList:XMLList;
		private var missingDataXMLList:XMLList;
		
		private var sV:SessionView;
		private var aScreens:Array; // 3D Screens Array.
		private var sScreen:SessionScreen;
		
		// Error control.
		private var errorPreparingData:Boolean;
		private var errorPreparingDataCount:uint;

		public function SessionDataSaver(ref:main, sessionView:SessionView)
		{
			sV = sessionView;
			_ref = ref;
			msgBox = main.msgBox;
			initTimers();
		}
		
		private function initTimers():void {
			timerXMLScreens = new Timer(500, 0);
			//timerXMLObjects = new Timer(500, 0);
			timerXMLTimeOut = new Timer(1000, timerXMLTimeOutLimit); // 1min Time outs.
		}
		
		private function resetTimers():void {
			timerXMLScreens.reset();
			//timerXMLObjects.reset();
			timerXMLTimeOut.reset();
		}
		
		private function showMsg(newMsg:String, isError:Boolean = false, useBreak:Boolean = true, buttons:String = "BUTTONS_UNCHANGED", msgType:String = Logger.TYPE_TEXT):void {
			logger.addText(newMsg, isError, false, true, false, msgType);
			if (!this._waitingLateSuccess) {
				msgBox.addMsg(newMsg, useBreak, buttons);
			}
		}
		
		public function startSessionSave(saveToLocal:Boolean, saverTimeOut:int = -1):void {
			this.saveToLocal = saveToLocal;
			timeOutLimitSaver = saverTimeOut;
			var aXML:Array = new Array();
			var aImg:Array = new Array();
			
			// Reset error counter.
			errorPreparingData = false;
			
			// Init Screenshots.
			aScreenshots = [];
			
			// Init Timers.
			initSaverTimers();
			
			// Get Total Screens.
			totalScreens = sG.sessionDataXML.session[0].screen.length();
			
			// Get session token.
			_sessionToken = sG.sessionDataXML.session[0]._sessionToken.text();

			// Get the path to save.
			var _interfaceBaseURL:String = sG.sessionDataXML.session[0]._interfaceBaseUrl.text();
			var _xmlSendBase:String =  sG.sessionDataXML.session[0]._xmlSendBase.text();
	
			//_outputURL = "http://ssp.dev.kyosei-systems.com/xml.mpl?a=submit_data";
			_outputURL = _interfaceBaseURL+"/"+_xmlSendBase;
			
			if (SSPSettings.resendSameDataFile && sG.zipData) {
				// Sends the same zip file again. Debug only.
				showMsg("Re-sending the same Data file...");
				startDataSend();
				return;
			}
			
			/*if (reUseSessionData && SSPSettings.reUseSessionDataOnRetry && newXML) {
				// Creates a new zip with previously prepared data and includes error.txt if exists.
				logger.addInfo("Re-using Prepared Data...");
				logger.addText("RAM: "+new SysUtils().getSystemRAM(), false); // Used by Flash app (without free memory) / Total memory including browser and garbage collection.
				startDataSend();
				return;
			}*/
			
			// Get the Session Data XML.
			showMsg("Preparing Data...");
			logger.addInfo("RAM: "+new SysUtils().getSystemRAM()); // Used by Flash app (without free memory) / Total memory including the one used by garbage collection and the web browser.
			startXMLParse();
		}
		
		private function startXMLParse():void {
			showMsg(" - Settings. ");
			var sessionXML:XML = sG.sessionDataXML.copy();
			
			// ------ Main Settings ----- //
			_ref._comments.updateCommentsXML(); // Update comments data.
			
			//_ref.settingsForm.form.updateSettings(); // Update settings form data.
			//var sspSettings:SSPSettings = _ref.settingsForm.form.getSettings(); // Session Settings.
			
			var strToSanitize:String;
			strToSanitize = sessionXML.session._sessionTitle.text();
			sessionXML.session._sessionTitle = TextUtils.sanitizeHTMLToNonHTML(strToSanitize);
			strToSanitize = sessionXML.session._sessionLanguageCode.text();
			sessionXML.session._sessionLanguageCode = TextUtils.sanitize(strToSanitize);
			strToSanitize = sessionXML.session._sessionCategoryId.text();
			sessionXML.session._sessionCategoryId = TextUtils.sanitize(strToSanitize);
			strToSanitize = sessionXML.session._sessionSkillLevelId.text();
			sessionXML.session._sessionSkillLevelId = TextUtils.sanitize(strToSanitize);
			strToSanitize = sessionXML.session._sessionDifficultyLevelId.text();
			sessionXML.session._sessionDifficultyLevelId = TextUtils.sanitize(strToSanitize);
			strToSanitize = sessionXML.session._sessionOverallDescription.text();
			if (sG.errorSavingOverallDescription) {
				sessionXML.session._sessionOverallDescription = TextUtils.sanitizeHTMLToNonHTML(strToSanitize);
			} else {
				sessionXML.session._sessionOverallDescription = TextUtils.sanitize(strToSanitize);
			}
			strToSanitize = sessionXML.session._sessionStartTime.text();
			sessionXML.session._sessionStartTime = TextUtils.sanitize(strToSanitize);
			sessionXML.session._globalSspToolVersion = sG.sspToolVersion;
			if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				sessionXML.session._fixtureId = teamMgr.getFixtureId();
				strToSanitize = sessionXML.session._teamNameOurs.text();
				sessionXML.session._teamNameOurs = TextUtils.sanitize(strToSanitize);
				strToSanitize = sessionXML.session._teamNameOpposition.text();
				sessionXML.session._teamNameOpposition = TextUtils.sanitize(strToSanitize);
			}
			// User Video.
			var userVideoItem:SSPVideoItem = uM.getUserVideo(-1);
			sessionXML.session.user_video = ScreenSettingsDefault.USER_VIDEO;
			sessionXML.session.user_video._videoCode = userVideoItem.videoCode;
			sessionXML.session.user_video._videoDuration = userVideoItem.videoDuration;
			sessionXML.session.user_video._videoSource = userVideoItem.videoSource;
			strToSanitize = userVideoItem.videoTitle;
			strToSanitize = TextUtils.sanitize(strToSanitize);
			sessionXML.session.user_video._videoTitle = strToSanitize;
			// ------ End Main Settings ----- //
			
			showMsg("Done.", false, false);
			
			newXML = new XML(<session_data><session/></session_data>);
			missingDataXMLList = new XMLList();
			
			// Get all but screens, screen_defaults, pr_team_player, nonpr_team_player, pr_minutes, session_minutes
			tmpXMLList = sessionXML.session.children().(
				localName() != "screen"
				&& localName() != "pr_team_player"
				&& localName() != "nonpr_team_player"
				//&& localName() != "screen_defaults"
				//&& localName() != "pr_minutes"
				//&& localName() != "session_minutes"
			);

			
//			newXML.session.appendChild(tmpXMLList);
			
			// Add (or update if retrying save) System Info. Server needs to be trimmed to <15 char.
			var trimLength:uint = 15;
			var procType:String = (sG.clientProcessorType != "")? " "+sG.clientProcessorType: "";
			newXML.session._clientFlashVersion = sG.clientFlashVersion.substr(0, trimLength);
			newXML.session._clientPlayerType = sG.clientPlayerType.substr(0, trimLength);
			newXML.session._clientOS = String(sG.clientOS + procType).substr(0, trimLength);
			newXML.session._clientBrowserLanguage = sG.clientBrowserLanguage.substr(0, trimLength);
			newXML.session._clientRAM = new SysUtils().getSystemRAM().substr(0, trimLength); // Get current RAM.
			newXML.session._clientScreen = sG.clientScreen.substr(0, trimLength);
			
			// Validate Session Data.
			Validator.validateAll(true, true, true);
			
			// Validate Minutes.
			if (sG.sessionTypeIsMatch) MinutesManager.getInstance().validateMinutes();
			
			// -------- SCREENS --------- //
			
			// Clean Screen3D list of incorrectly disposed screens, if any.
			aScreens = [];
			for each (var s:SessionScreen in sV.aScreens) {
				if (s && !s.disposeFlag) {
					aScreens.push(s);
				} else {
					logger.addError("Incorrectly disposed Screen3D found. Ignored.");
				}
			}
			
			// Sort array by screenSortOrder.
			aScreens.sortOn("screenSortOrder",Array.NUMERIC);
			
			if (totalScreens != aScreens.length) {
				logger.addError("The number of screens in XML ("+totalScreens+") is different than the number of 3D screens ("+aScreens.length+").");
				totalScreens = aScreens.length; // This 'if' should never happen, but avoids a bigger error if it does.
				// Save source screens XML to missing data tag.
				missingDataXMLList += sessionXML.session[0].screen.copy();
			}
			
			// Start Screens Parse.
			processScreen = 0;
			currentProcessScreen = -1;
			timerXMLScreens.addEventListener(TimerEvent.TIMER, checkScreenProgress);
			timerXMLScreens.start();
		}
		
		private function checkTimeOut(e:TimerEvent):void {
			if (timerXMLTimeOutIndex < timerXMLTimeOutLimit) {
				stopTimersListeners();
				showMsg("XML Creation Timed Out.", true);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nXML Creation Timed Out.", _sessionToken) ));
			}
		}
		
		private function checkScreenProgress(e:TimerEvent):void {
			if (processScreen < totalScreens) {
				if (currentProcessScreen == processScreen) return;
				// Parse screen.
				currentProcessScreen = processScreen;
				try {
					showMsg(" - Screen "+(processScreen+1)+"/"+totalScreens+". ");
					xmlScreenDataParse(processScreen);
				} catch (error:Error) {
					errorPreparingData = true;
					var errorStr:String = "Error ("+error.errorID+"): "+error.message;
					logger.addAlert(errorStr);
				}
				processScreen++;
			} else {
				timerXMLScreens.stop();
				timerXMLScreens.removeEventListener(TimerEvent.TIMER, checkScreenProgress);
				
				// ----- Team Data ----- //
				if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
					showMsg(" - Team Data. ");
					var teamDataXMLList:XMLList = teamMgr.getTeamDataXML().children().(
							localName() != "pr_minutes"
							&& localName() != "session_minutes"
						); // Without the initial minutes.
					tmpXMLList += teamDataXMLList;
//					newXML.session.appendChild(teamDataXMLList);
					
					// If <screen_defaults> exists, sanitize them.
					if (tmpXMLList.(localName() == "screen_defaults").length() > 0) {
						var strScreenType:String;
						var strToSanitize:String;
						var sdXML:XML;
						// Screen Settings Defaults (Period).
						strScreenType = SessionGlobals.SCREEN_TYPE_PERIOD;
						sdXML = tmpXMLList.(localName() == "screen_defaults").(_screenType == strScreenType)[0];
						strToSanitize = sdXML._screenPlayerNameFormat.text();
						sdXML._screenPlayerNameFormat = TextUtils.sanitize(strToSanitize);
						strToSanitize = sdXML._screenPlayerModelFormat.text();
						sdXML._screenPlayerModelFormat = TextUtils.sanitize(strToSanitize);
						// Screen Settings Defaults (Set-piece).
						strScreenType = SessionGlobals.SCREEN_TYPE_SET_PIECE;
						sdXML = tmpXMLList.(localName() == "screen_defaults").(_screenType == strScreenType)[0];
						strToSanitize = sdXML._screenPlayerNameFormat.text();
						sdXML._screenPlayerNameFormat = TextUtils.sanitize(strToSanitize);
						strToSanitize = sdXML._screenPlayerModelFormat.text();
						sdXML._screenPlayerModelFormat = TextUtils.sanitize(strToSanitize);
					} else {
						logger.addError("No <screen_defaults> to save.");
					}
					
					showMsg("Done.", false, false);
				}
				
				//trace("------------ XML CONTENT ------------\n"+newXML.toString()+"\n------------ END XML CONTENT ------------");
				// XML Data Ready, Sending.
				
				if (missingDataXMLList.length() > 0) {
					tmpXMLList += new XML("<missingData>"+missingDataXMLList.toXMLString()+"</missingData>");
//					newXML.session.appendChild(missingDataXML);
				}
				
				newXML.session.appendChild(tmpXMLList);
				
				// Sort XML by Elements name.
				newXML = sortXML(newXML);
				
				startDataSend();
			}
		}
		
		private function sortXML(sourceXML:XML):XML {
			logger.addEntry("Sorting XML...");
			var sortedXMLValid:Boolean;
			var sortedXMLLengthOK:Boolean;
			var sortedXML:XML;
			var numElementsBefore:int = sourceXML.descendants().length()
			var numElementsAfter:int;
				
			var sortedXMLList:XMLList = SSPXMLSort.sortSSPXML(newXML);
			if (sortedXMLList) {
				sortedXML = new XML(sortedXMLList);
				numElementsAfter = sortedXML.descendants().length();
				if (XMLUtil.isValidXML(sortedXML.toXMLString())) {
					sortedXMLValid = true;
				} else {
					logger.addError("Invalid sorted XML.");
				}
				
				if (numElementsAfter == numElementsBefore) {
					sortedXMLLengthOK = true;
				} else {
					logger.addError("XML length is different after sorting.");
				}
			}
			
			if (sortedXMLValid && sortedXMLLengthOK) {
				logger.addEntry("Done.", true);
			} else {
				errorPreparingData = true;
				logger.addError("XML sorting failed. Using source XML.");
			}
			
			return (sortedXMLValid)? sortedXML : sourceXML;
		}
		
		private function xmlScreenDataParse(h:int):void {
			var newScreenXML:XML;
			var screenId:int;
			var screenSO:int;
//d			sScreen = getScreenFromArray(aScreens, h);
			sScreen = aScreens[h];
			if (sScreen == null) {
				errorPreparingData = true;
				logger.addError("Can't find screenId "+h+". Skipped.");
				return;
			} else {
				screenId = sScreen.screenId;
				screenSO = sScreen.screenSortOrder;
				
				// Update and get screen XML Data.
				newScreenXML = sScreen.getScreenXML(true, true); // Work with a cloned xml to avoid xml lock.
				
				if (!newScreenXML || newScreenXML.length() == 0 || newScreenXML[0].children().length() == 0) {
					errorPreparingData = true;
					showMsg("Done.", false, false);
					logger.addError("Screen sortOrder "+h+": Error getting updated data. Using non-updated data instead.");
					newScreenXML = sScreen.getScreenXML(false, true); // Use a cloned xml, but not updated.
				}
				
				// Log Total Objects.
				var tP:uint = newScreenXML.children().(localName() == "player").length();
				var tE:uint = newScreenXML.children().(localName() == "equipment").length();
				var tL:uint = newScreenXML.children().(localName() == "line").length();
				var tT:uint = newScreenXML.children().(localName() == "text").length();
				var tO:uint = tP + tE + tL + tT;
				Logger.getInstance().addText(" - Id("+screenId+"), SO("+screenSO+") - Pl("+tP+") , Eq("+tE+"), Li("+tL+"), Te("+tT+"), Total("+tO+").", false);
				newScreenXML._screenChangedFlag = "TRUE"; // TODO.
				var strToSanitize:String;
				strToSanitize = newScreenXML._screenComments.text();
				//strToSanitize.replace("<![CDATA[", "");
				//strToSanitize.replace("]]>", "");
				if (sG.errorSavingScreenComments) {
					strToSanitize = TextUtils.sanitizeHTMLToNonHTML(strToSanitize);
				} else {
					strToSanitize = TextUtils.sanitize(strToSanitize);
				}
				newScreenXML._screenComments = strToSanitize;
				strToSanitize = newScreenXML._screenTitle.text();
				newScreenXML._screenTitle = TextUtils.sanitizeHTMLToNonHTML(strToSanitize); // Escape text.
				strToSanitize = newScreenXML._screenCategoryId.text();
				newScreenXML._screenCategoryId = TextUtils.sanitize(strToSanitize);
				newScreenXML._screenId = h.toString();
				newScreenXML._screenSortOrder = h.toString();
				//newScreenXML._dbTransitionId;
				
				// Validate SkillsMix.
				Validator.validateSkillsMix(newScreenXML);
				
				strToSanitize = newScreenXML._skillsPhysical.text();
				newScreenXML._skillsPhysical = TextUtils.sanitize(strToSanitize);
				strToSanitize = newScreenXML._skillsPsychological.text();
				newScreenXML._skillsPsychological = TextUtils.sanitize(strToSanitize);
				strToSanitize = newScreenXML._skillsSocial.text();
				newScreenXML._skillsSocial = TextUtils.sanitize(strToSanitize);
				strToSanitize = newScreenXML._skillsTactical.text();
				newScreenXML._skillsTactical = TextUtils.sanitize(strToSanitize);
				strToSanitize = newScreenXML._skillsTechnical.text();
				newScreenXML._skillsTechnical = TextUtils.sanitize(strToSanitize);
				
				strToSanitize = newScreenXML._skillsPhysicalComment.text();
				newScreenXML._skillsPhysicalComment = TextUtils.sanitizeHTMLToNonHTML(strToSanitize); // Escape text.
				strToSanitize = newScreenXML._skillsPsychologicalComment.text();
				newScreenXML._skillsPsychologicalComment = TextUtils.sanitizeHTMLToNonHTML(strToSanitize); // Escape text.
				strToSanitize = newScreenXML._skillsSocialComment.text();
				newScreenXML._skillsSocialComment = TextUtils.sanitizeHTMLToNonHTML(strToSanitize); // Escape text.
				strToSanitize = newScreenXML._skillsTacticalComment.text();
				newScreenXML._skillsTacticalComment = TextUtils.sanitizeHTMLToNonHTML(strToSanitize); // Escape text.
				strToSanitize = newScreenXML._skillsTechnicalComment.text();
				newScreenXML._skillsTechnicalComment = TextUtils.sanitizeHTMLToNonHTML(strToSanitize); // Escape text.
				
				strToSanitize = newScreenXML._timeSpent.text();
				newScreenXML._timeSpent = TextUtils.sanitize(strToSanitize);
				
				// User Image Info.
				var userImageItem:SSPImageItem = uM.getUserImage(screenId);
				newScreenXML._userImageExists = MiscUtils.booleanToString(userImageItem.imageExists);
				newScreenXML._userImageLocation = ""; // Clear tag. not used by server.
				
				// User Video Info.
				var userVideoItem:SSPVideoItem = uM.getUserVideo(screenId);
				newScreenXML.user_video = ScreenSettingsDefault.USER_VIDEO;
				newScreenXML.user_video._videoCode = userVideoItem.videoCode;
				newScreenXML.user_video._videoDuration = userVideoItem.videoDuration;
				newScreenXML.user_video._videoSource = userVideoItem.videoSource;
				strToSanitize = userVideoItem.videoTitle;
				strToSanitize = TextUtils.sanitize(strToSanitize);
				newScreenXML.user_video._videoTitle = strToSanitize;
				
				// Validate screen data (Fixes certain issues if necessary).
				ScreenSettings.validateScreenSettings(newScreenXML, true, true, true, true);
//				newXML.session.appendChild(newScreenXML); // Use updated screen data.
				tmpXMLList += newScreenXML;
				
				// ---- IMAGES ---- //
				if (userImageItem.imageExists && !userImageItem.fromServer) addUserImage(userImageItem, screenId, h);
				takeScreenshot(screenId, h);
				
				showMsg("Done.", false, false);
			}
		}
		
		private function takeScreenshot(sId:uint, idx:uint):void {
			// Store Color Image.
			var imageData:Object = new Object();
			var imageBmd:BitmapData = sV.takeScreenshot(sId);
			if (!imageBmd) {
				errorPreparingData = true;
				logger.addError("Invalid bitmapdata in screenId "+sId.toString()+" screenshot.");
				return;
			}
			logger.addEntry("Compressing Screenshot to JPG...");
			var imageBa:ByteArray = ImageUtils.bmdToJPG(imageBmd, SSPSettings.userImageJPGQuality);
			if (!imageBa) {
				errorPreparingData = true;
				logger.addError("Can't create JPG for screenId "+sId.toString()+".");
				return;
			}
			logger.addEntry("Image Compression Done.");
			imageData.jpgData = imageBa;
			imageData.jpgName = "image"+idx+"full.jpg";
			aScreenshots.push(imageData);
		}
		
		private function addUserImage(userImageItem:SSPImageItem, sId:uint, idx:uint):void {
			logger.addEntry("Adding user image for screenId "+sId.toString()+"...");
			var imageData:Object = new Object();
			var imageBmp:Bitmap = userImageItem.data;
			if (!imageBmp) {
				errorPreparingData = true;
				logger.addError("Invalid user image bitmap in screenId "+sId.toString()+".");
				return;
			}
			var imageBmd:BitmapData = imageBmp.bitmapData;
			if (!imageBmd) {
				errorPreparingData = true;
				logger.addError("Invalid user image bitmapdata in screenId "+sId.toString()+".");
				return;
			}
			// If loaded from server, do not compress.
			//var imageBa:ByteArray = (userImageItem.fromServer)? imageBmd.getPixels(imageBmd.rect) : ImageUtils.bmdToJPG(imageBmd, SSPSettings.userImageJPGQuality);
			logger.addEntry("Compressing User Image to JPG...");
			var imageBa:ByteArray = (userImageItem.fromServer)? ImageUtils.bmdToJPG(imageBmd, 100) : ImageUtils.bmdToJPG(imageBmd, SSPSettings.userImageJPGQuality);
			if (!imageBa) {
				errorPreparingData = true;
				logger.addError("Can't create JPG for screenId "+sId.toString()+".");
				return;
			}
			logger.addEntry("Image Compression Done.");
			imageData.jpgData = imageBa;
			imageData.jpgName = "user_image"+idx+"full.jpg";
			aScreenshots.push(imageData);
			logger.addEntry("User image added OK.");
		}
		
		private function getZip(newZip:Boolean):void {
			if (!newZip) {
				if (!sG.zipData) {
					//showMsg("No previous zip exists.", true);
				} else {
					showMD5(sG.zipData);
					return;
				}
			}

			showMsg("Compressing...");
			/*put $xml into "xml_content" field
			then put images into "image+$_screenID+$type" field
			e.g. image1full, image1bw, image2full, image2wb*/
			
			// ----- Prepare XML ----- //
			//_noCacheVar = "?nocache=" + String(new Date().getTime());
			//_urlReq = new URLRequest(_outputURL + _noCacheVar);
			var xmlData:ByteArray = new ByteArray();
			xmlData.writeUTFBytes(SSPSettings.xmlDeclaration+"\n"+newXML.toXMLString());
			//xmlData.writeUTFBytes("<_testingParsingError></testingParsingError>"+SSPSettings.xmlDeclaration+"\n"+newXML.toXMLString()); // Debug. Forced Parsing Error.

			// start an empty zip file
			// first param : comment
			// second param : compression method
			var myZip:ASZip = new ASZip ( CompressionMethod.GZIP );
			myZip.addFile (  xmlData, "xml_content.xml" );
			for (var i:int = 0;i<aScreenshots.length;i++) {
				myZip.addFile(aScreenshots[i].jpgData, aScreenshots[i].jpgName);
			}
			//myZip.addFile (  jpgColorData, "image1full.jpg" );
			//myZip.addFile (  jpgBWData, "image1bw.jpg" );
			
			// Add Error Log if any.
			//logger.setError(); // Debug Hack.
			if (logger.hasErrors) {
				var myLog:ByteArray = new ByteArray();
				myLog.writeUTFBytes(logger.mainLog);
				myZip.addFile (  myLog, "error.txt" );
			}
			
			sG.zipData = myZip.saveZIP(Method.LOCAL);
			
			showMsg("Done.", false, false);
			
			showMD5(sG.zipData);
		}
		
		private function showMD5(byteArray:ByteArray):void {
			var strUTF8:String = MD5.hashBytes(byteArray); // Get MD5 Hash.
			showMsg("MD5: " + strUTF8, false);
			//showMsg("XML Header: " + SSPSettings.xmlDeclaration, false);
		}
		
		/*private function sendZip():void {
			try {
				trace("Sending zip file.");
				var _noCacheVar:String = "";
				if (!Globals3D.getInstance().getValue("isLocal")) {
					_noCacheVar = "?nocache=" + String(new Date().getTime());
				}
				var urlReq = new URLRequest(_outputURL + _noCacheVar);
				urlReq.contentType = "application/zip";
				var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/zip");
				urlReq.requestHeaders.push (header);
				urlReq.method = URLRequestMethod.POST;
				urlReq.data = getZip();
				
				urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
				//urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
				urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);
				urlLoader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				showMsg("Sending Data...");
				urlLoader.load(urlReq);
			} catch (error:Error) {
				trace("Error Sending ZIP: "+e);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nError Sending Data: "+error.message, _sessionToken) ));
				return;
			}
		}*/
		
		private function startDataSend():void {
			var newZip:Boolean = (SSPSettings.resendSameDataFile && sG.zipData)? false : true;
			try {
				getZip(newZip);
			} catch (error:Error) {
				errorPreparingData = true;
				logger.addAlert("Can't create zip file.");
			}
			
			//errorPreparingData = true; // Debug.
			
			if (errorPreparingData && errorPreparingDataCount < SSPSettings.errorPreparingDataMax) {
				stopSaver();
				errorPreparingDataCount++;
				showMsg("Error occurred while preparing data.", true, true, MessageBox.BUTTONS_UNCHANGED, Logger.TYPE_ALERT);
				showMsg(" Retrying ("+errorPreparingDataCount+" of "+SSPSettings.errorPreparingDataMax+")...", false, false);
				this.startSessionSave(this.saveToLocal, this.timeOutLimitSaver);
				return;
			}
			
			if (saveToLocal) {
				saveZipToPC();
			} else {
				sendZip();
			}
		}
		
		private function sendZip():void {
			try {
				// -- Multipart Mode Method 2 (Working) -- //
				var fileName:String = "xml_content.zip";
				
				mpLoader = new MultipartURLLoader();
				mpLoader.dataFormat = URLLoaderDataFormat.TEXT;
				mpLoader.addVariable('a', 'submit_data');
				//mpLoader.addVariable('POSTDATA', fileName);
				mpLoader.addFile(sG.zipData, fileName, "POSTDATA");
				mpLoader.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
				
				mpLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, false);
				mpLoader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, false);
				mpLoader.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData, false, 0, false);
				mpLoader.addEventListener(Event.OPEN, onOpen, false, 0, false);
				mpLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, false);
				mpLoader.addEventListener(Event.COMPLETE, onComplete, false, 0, false);
				mpLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, false);
				
				mpLoader.addEventListener(MultipartURLLoaderEvent.DATA_PREPARE_COMPLETE, onDataPrepareComplete, false, 0, false);
				//mpLoader.addEventListener(MultipartURLLoaderEvent.DATA_PREPARE_PROGRESS, onDataPrepareProgress, false, 0, false);
				
				mpLoader.load(getDestinationURL(), true);
				
			} catch (error:Error) {
				stopSaver();
				logger.addError("Sending Data (1): "+error.message);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nError Sending Data: "+error.message, _sessionToken) ));
				return;
			}
		}
		private function onDataPrepareProgress(e:MultipartURLLoaderEvent):void {
			showMsg("Preparing: "+e.bytesWritten+" of "+e.bytesTotal);
		}
		private function onDataPrepareComplete(e:MultipartURLLoaderEvent):void {
			// -- Multipart Mode Method 2 (Working) -- //
			var kbTotal:Number = Math.round(e.bytesTotal/1024);
			showMsg("Data Size: "+kbTotal.toString()+"Kb");
			
			startSaverTimer();
			//showMsg("Sending Data...("+timeOutLimitSaver+")");
			showMsg("Sending Data ");
			try {
				mpLoader.startLoad();
			} catch (error:Error) {
				stopSaver();
				logger.addError("Sending Data (2): "+error.message);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nError Sending Data: "+error.message, _sessionToken) ));
				return;
			}
		}
		
		private function getDestinationURL():String {
			var _noCacheVar:String = "";
			if (!sG.isLocal) {
				_noCacheVar = "?nocache=" + String(new Date().getTime());
			}
			var url:String = _outputURL + _noCacheVar;
			return url;
		}
		
		private function saveZipToPC():void {
			showMsg("Data Size: "+Math.round(sG.zipData.length/1024)+"Kb");
			msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_SAVE_TO_PC, onSaveToPC, false, 0, true);
			showMsg("Click to Save to PC.", false, true, MessageBox.BUTTONS_SAVE_TO_PC);
			if (logger.hasErrors) showMsg("*", false, false);
		}
		private function onSaveToPC(e:Event):void {
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_SAVE_TO_PC, onSaveToPC);
			logger.addUser("User has clicked 'Save to PC'");
			fr = new FileReference();
			fr.addEventListener(Event.SELECT, onRefSelect, false, 0, true);
			fr.addEventListener(Event.CANCEL, onRefCancel, false, 0, true);
			fr.save(sG.zipData, "my_session_data.zip");
		}
		
		private function onComplete(evt:Event):void {
			stopAllListeners();
			var strResponse:String; // Response from server.
			try {
				strResponse = new XML(evt.target.loader.data); // Method 2 (Working).
				//strResponse = new XML(evt.target.data); // Method 3 (Working).
				logger.addInfo("Completed. Response from Server: \n"+strResponse);
				checkResponse(strResponse);
			} catch (error:TypeError) {
				logger.addError("Error while retreiving loader data: \n" + error.message);
			}
		}
		private function checkResponse(fullResp:String):void {
			var trimmedResp:String = fullResp.substr(0, 9); // Ignores extra info.
			var checkedFullResp:Boolean;
			
			showMsg("Response: "+fullResp+".");
			
			// Check for specific data in response.
			if(fullResp.indexOf("screen._dbTransitionId") >= 0){
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_101_SESSION_TRANSITION, "\nServer Response: "+fullResp, _sessionToken) ));
				return;
			}
			
			// Check for custom response.
			switch(fullResp) {
				case "DONE":
					checkedFullResp = true;
					this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS));
					break;
				case "DONE: 900 OK":
					checkedFullResp = true;
					this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS));
					break;
				case "DONE: 901 Repeat":
					checkedFullResp = true;
					this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS));
					break;
				case "ERROR:101 _sessionOverallDescription":
					checkedFullResp = true;
					sG.errorSavingOverallDescription = true;
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_000_RETRY_TRIGGERED) ));
					break;
				case "ERROR:101 _screenComments":
					checkedFullResp = true;
					sG.errorSavingScreenComments = true;
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_000_RETRY_TRIGGERED) ));
					break;
				case "ERROR:100 can't parse":
					checkedFullResp = true;
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_000_RETRY_TRIGGERED) ));
					break;
			}
			if (checkedFullResp) return; // If already found a match, return.
			
			// Check main data in response.
			switch(trimmedResp) {	
				case "ERROR:001":
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR) ));
					break;
				case "ERROR:100":
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_100_INVALID_TOKEN) ));
					break;
				case "ERROR:101":
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_101_VALIDATION_ERROR, "\nServer Response: "+fullResp, _sessionToken) ));
					break;
				case "ERROR:104":
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_104_ACCOUNT_NO_LONGER_ACTIVE) ));
					break;
				case "ERROR:200":
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_200_SERVER_TIME_OUT) ));
					break;
				case "ERROR:201":
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_201_CONNECTION_ERROR) ));
					break;
				default:
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nServer Response: "+fullResp, _sessionToken) ));
			}
		}
		private function onSecurityError(e:SecurityErrorEvent):void {
			logger.addError("Security Error Occurred.");
			stopAllListeners();
			this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_201_CONNECTION_ERROR, "\nSecError Details: "+e.text, _sessionToken) ));
		}
		private function onIOError(e:IOErrorEvent):void {
			logger.addError("IO Error Occurred.");
			stopAllListeners();
			this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_201_CONNECTION_ERROR, "\nIOError Details: "+e.text, _sessionToken) ));
		}
		private function onProgress(e:ProgressEvent):void {
			//trace("onProgress() Bytes Total: "+e.bytesTotal);
			//showMsg("Progress: "+e.bytesTotal+"bytes.");
			//showMsg("Progress: "+e.bytesLoaded+" of "+e.bytesTotal);
			/*var percent:Number = Math.floor((e.bytesLoaded*100)/e.bytesTotal );
			var kbLoaded:String = String(e.bytesLoaded);
			var kbTotal:String = String(e.bytesTotal);
			trace("Uploading: ("+percent+"%) \nKbytes Total: "+kbTotal+"\nKbytes Loaded: "+kbLoaded);*/
		}
		private function onSocketData(e:ProgressEvent):void {
			trace("onSocketData()"); // In Flash10, no socket data like progress is received.
			//showMsg("Socket Data Received.");
		}
		private function onOpen(e:Event):void {
			logger.addInfo("Connection Open.");
			//showMsg("Connection Open.");
		}
		private function onHTTPStatus(e:HTTPStatusEvent):void {
			//logger.addText("HTTPStatus "+e.status.toString()+" Received", false)
			if (!sG.isLocal) {
				if(e.status < 100) {
					trace("httpStatus (non standard error): "+e);
					/*this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, SSPEvent.ERROR_CODE_ID_201_CONNECTION_ERROR, _sessionToken+
						"\nHTTPStatus: "+e.status.toString() ));*/
					showMsg("HTTPStatus: "+e.status.toString()+".", true);
				} else if(e.status < 200) {
					trace("httpStatus (info): "+e);
					showMsg("HTTPStatus: "+e.status.toString()+".", false);
					/*this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, SSPEvent.ERROR_CODE_ID_001_UNEXPECTED_ERROR, _sessionToken+
						"\nHTTPStatus: "+e.status.toString() ));*/
				} else if(e.status < 300) {
					trace("httpStatus (success): "+e);
					showMsg("HTTPStatus: "+e.status.toString()+" OK.", false);
				} else if(e.status < 400) {
					trace("httpStatus (redirection): "+e);
					showMsg("HTTPStatus: "+e.status.toString()+" Redirection.", true);
				} else if(e.status < 500) {
					trace("httpStatus (clientError): "+e);
					showMsg("HTTPStatus: "+e.status.toString()+".", true);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nHTTPStatus: "+e.status.toString(), _sessionToken)) );
				} else if(e.status < 600) {
					trace("httpStatus (serverError): "+e);
					showMsg("HTTPStatus: "+e.status.toString()+".", true);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nHTTPStatus: "+e.status.toString(), _sessionToken)) );
				} else if (e.status > 600) {
					trace("httpStatus (non standard error): "+e);
					showMsg("HTTPStatus: "+e.status.toString()+".", true);
				}
			}
		}
		
		private function onRefSelect(e:Event):void {
			//trace("File Saved to PC.");
			showMsg("Saved.");
			msgBox.showButtons(MessageBox.BUTTONS_OK);
			fr.removeEventListener(Event.SELECT, onRefSelect);
			fr.removeEventListener(Event.CANCEL, onRefCancel);
			this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS));
		}
		private function onRefCancel(e:Event):void {
			//trace("Saving to PC Canceled.");
			showMsg("Canceled.", false);
			msgBox.showButtons(MessageBox.BUTTONS_OK);
			fr.removeEventListener(Event.SELECT, onRefSelect);
			fr.removeEventListener(Event.CANCEL, onRefCancel);
			this.dispatchEvent(new SSPEvent(SSPEvent.CANCEL));
		}
		
		private function startSaverTimer():void {
			//trace("startSaverTimer()");
			_waitingLateSuccess = false;
			if (timeOutLimitSaver > 0) {
				timerSaverTimeOut.start();
				timerProgress.start();
			}
		}
		private function saverTimeOut(e:TimerEvent):void {
			//trace("saverTimeOut()");
			timerSaverTimeOut.stop();
			timerProgress.stop();
			
			stopTimersListeners(); // Note that Saver Listeners are not stopped to allow late save detection.
			_waitingLateSuccess = true;
			
			showMsg("Timed Out.", true);
			this.dispatchEvent(new SSPEvent(SSPEvent.TIMEOUT));
		}
		
		private function initSaverTimers():void {
			if (timeOutLimitSaver > 0) {
				timerSaverTimeOut = new Timer(timeOutLimitSaver * 1000, 1);
				timerSaverTimeOut.addEventListener(TimerEvent.TIMER, saverTimeOut);
				timerProgress = new Timer(timerProgressInterval * 1000, timeOutLimitSaver/timerProgressInterval);
				timerProgress.addEventListener(TimerEvent.TIMER, showTimerProgress);
			}
		}
		
		private function showTimerProgress(e:TimerEvent):void {
			msgBox.addMsg(".", false, MessageBox.BUTTONS_UNCHANGED);
		}
		
		private function stopTimersListeners():void {
			if (timerSaverTimeOut) {
				timerSaverTimeOut.stop();
				timerSaverTimeOut.removeEventListener(TimerEvent.TIMER, saverTimeOut);
			}
			if (timerXMLTimeOut) {
				timerXMLTimeOut.stop();
				timerXMLTimeOut.removeEventListener(TimerEvent.TIMER, checkTimeOut);
			}
			if (timerXMLScreens) {
				timerXMLScreens.stop();
				timerXMLScreens.removeEventListener(TimerEvent.TIMER, checkScreenProgress);
			}
			//if (timerXMLObjects) {
				//timerXMLObjects.stop();
				//timerXMLObjects.removeEventListener(TimerEvent.TIMER, checkObjectProgress);
			//}
			if (timerProgress) {
				timerProgress.stop();
				timerProgress.removeEventListener(TimerEvent.TIMER, showTimerProgress);
			}
		}
		
		private function stopSaverListeners():void {
			if (mpLoader) {
				mpLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				mpLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				mpLoader.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
				mpLoader.removeEventListener(Event.OPEN, onOpen);
				mpLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				mpLoader.removeEventListener(Event.COMPLETE, onComplete);
				mpLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}
		
		private function stopAllListeners():void {
			stopTimersListeners();
			stopSaverListeners();
		}
		
		public function stopSaver():void {
			stopAllListeners();
			if (mpLoader) {
				//mpLoader.close();
				//mpLoader.dispose();
				//mpLoader = null;
			}
		}
		
		public function get waitingLateSuccess():Boolean {
			return _waitingLateSuccess;
		}
	}
}