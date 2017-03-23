package src3d
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import src.popup.MessageBox;
	import src.team.PRTeamManager;
	
	import src3d.lines.LineSettings;
	import src3d.models.KitsLibrary;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.equipment.EquipmentSettings;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.text.TextSettings;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.Validator;
	
	public class SessionLoader extends EventDispatcher {
		
		// PseudoThread.
		private var timeOutLimit:uint = 60;
		private var timerTimeOut:Timer;
		private var timerTimeOutIndex:uint;
		private var timerScreens:Timer;
		private var timerScreensIndex:uint;
		private var timerObjects:Timer;
		private var timerObjectsIndex:uint;

		// Global variables.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		// Session Data References.
		private var sS:XML;// Session Screen XML.
		// Logger.
		private var logger:Logger = Logger.getInstance();
		
		// Loader variables.
		private var screenIdx:int;
		private var firstLoad:Boolean = true;
		private var includeObjects:Boolean;
		private var includeDefaultObjects:Boolean;
		private var newScreenIdx:int;
		
		private var oList:XMLList;
		private var oXML:XML;
		
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
		
		// Loaded object variables.
		private var sScreen:SessionScreen;
		private var sessionView:SessionView;
		private var strObjType:String;
		private var pS:PlayerSettings;
		private var eS:EquipmentSettings;
		private var lS:LineSettings;
		private var tS:TextSettings;
		
		// Msg Box.
		private var msgBox:MessageBox;
		
		public function SessionLoader(sessionView:SessionView) {
			this.sessionView = sessionView;
			this.msgBox = main.msgBox;
			this.timerScreens = new Timer(500, 0);
			this.timerObjects = new Timer(500, 0);
			this.timerTimeOut = new Timer(1000, timeOutLimit); // 1min Time out.
		}
		
		private function showMsg(newMsg:String, isError:Boolean = false, useBreak:Boolean = true, buttons:String = "BUTTONS_UNCHANGED"):void {
			logger.addText(newMsg, isError);
			msgBox.addMsg(newMsg, useBreak, buttons);
		}
		
		public function loadScreen(screenIdx:uint):void {
			msgBox.popupEnabled = false; // Do not show messages while loading single screens.
			firstLoad = false;
			
			// Setup Load.
			this.screenIdx = screenIdx;
			this.includeObjects = true;
			this.includeDefaultObjects = true;

			startLoad();
		}
		
		public function startSessionLoad():void {
			if (!firstLoad) {
				logger.addText("(A) - Session already started.", false);
				return;
			}
			
			// Setup Load.
			this.screenIdx = 0;
			this.includeObjects = true;
			this.includeDefaultObjects = true;
			
			startLoad();
		}
		
		private function startLoad():void {
			// Reset Counters.
			this.totalScreens = (firstLoad)? sD.session.screen.length() : 1;
			this.processScreen = 0;
			this.currentProcessScreen = -1;
			
			// Reset Timers.
			timerScreens.reset();
			timerObjects.reset();
			timerTimeOut.reset();
			
			// Start Load.
			if (firstLoad) {
				showMsg("Loading Session...");
				Validator.validateAll(true, true, true);
				KitsLibrary.getInstance().initKitsLibrary(); // Init Player kits library.
				// Validate Screen Defaults if Match session.
				if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
					ScreenSettings.validateScreenDefaultsSettings();
				}
			} else {
				showMsg("Creating Screen...", false);
			}
			timerScreens.addEventListener(TimerEvent.TIMER, checkScreenProgress);
			timerScreens.start();
		}
		
		private function checkTimeOut(e:TimerEvent):void {
			if (timerTimeOutIndex < timeOutLimit) {
				timerTimeOut.stop();
				timerScreens.stop();
				//timerObjects.stop();
				timerTimeOut.removeEventListener(TimerEvent.TIMER, checkTimeOut);
				timerScreens.removeEventListener(TimerEvent.TIMER, checkScreenProgress);
				//timerObjects.removeEventListener(TimerEvent.TIMER, checkObjectProgress);
				showMsg("ERROR: Session Load Timed Out.", true);
			}
		}
		
		private function stopTimers():void {
			timerTimeOut.stop();
			timerScreens.stop();
			//timerObjects.stop();
			timerTimeOut.removeEventListener(TimerEvent.TIMER, checkTimeOut);
			timerScreens.removeEventListener(TimerEvent.TIMER, checkScreenProgress);
			//timerObjects.removeEventListener(TimerEvent.TIMER, checkObjectProgress);
		}

		private function checkScreenProgress(e:TimerEvent):void {
			if (processScreen < totalScreens) {
				if (currentProcessScreen == processScreen) return;
				if (firstLoad) {
					showMsg(" - Loading Screen "+(processScreen+1)+"/"+totalScreens+".", false);
				} else {
					//showMsg(" - Loading Screen", false);
					//logger.addText(" - Loading Screen (Id: "+screenIdx+").", false);
				}
				
				currentProcessScreen = processScreen;
				try {
					if (!startScreenLoad()) {
						showMsg(" Error.", true, false);
					}
				} catch (error:Error) {
					var errorStr:String = " Error ("+error.errorID+"): "+error.message;
					showMsg(errorStr, true);
				}
				processScreen++;
			} else {
				stopTimers();
				msgBox.popupVisible = false;
				if (firstLoad) newScreenIdx = getFirstScreenId();
				firstLoad = false;
				sS = null; // Clear the temporary session screen XML;
				this.dispatchEvent(new SSPEvent(SSPEvent.LOADING_DONE, newScreenIdx)); // Includes screenId to be selected and unlocked.
			}
		}
		
		private function startScreenLoad():Boolean {
			var strNewScreenId:String;
			if (firstLoad) {
				screenIdx = processScreen; // If not new screen, load screens from the XML sequentially.
				newScreenIdx = screenIdx;
				strNewScreenId = newScreenIdx.toString();
				sS = sD.session[0].screen[newScreenIdx];
				// Log Total Objects.
				var tP:uint = sS.children().(localName() == "player").length();
				var tE:uint = sS.children().(localName() == "equipment").length();
				var tL:uint = sS.children().(localName() == "line").length();
				var tT:uint = sS.children().(localName() == "text").length();
				var tO:uint = tP + tE + tL + tT;
				logger.addText(" - Id("+sS._screenId+"), SO("+sS._screenSortOrder+") - Pl("+tP+") , Eq("+tE+"), Li("+tL+"), Te("+tT+"), Total("+tO+").", false);
				// Reset screenId and sortOrder to avoid the bug in some old sessions with lowest screenId = 1.
				sS._screenId = strNewScreenId;
				sS._screenSortOrder = strNewScreenId;
				sS._screenComments = MiscUtils.removeCarriageReturnsAndNewLines(sS._screenComments.toString());
			} else {
				newScreenIdx = screenIdx;
				strNewScreenId = newScreenIdx.toString();
				sS = sD.session[0].screen.(_screenId == strNewScreenId)[0];
			}
			
			// Validate screen data (Creates missing tags and add default values).
			ScreenSettings.validateScreenSettings(sS, true, true, true, true);
			
			// View Renderer Issue Fix.
			// SSPCameraUpdater.updatePitchTargets(sS);
			
			if (firstLoad) {
				// If not a new session XML.
				if (sG.sspXMLVersion > 0) {
					// Get Application Version.
					var strXMLToolVersion:String = sG.sspXMLVersion.toString();
					var numXMLMayorVersion:Number = Number( strXMLToolVersion.substr(0,1) );
					var numToolVersion:Number = sG.sspToolVersion;
					var strToolFullVersion:String = sG.sspToolVersion.toString()+"."+sG.sspToolMinorVersion.toString();
					
					if (numToolVersion>numXMLMayorVersion) {
						// Fix Old Zoom if needed (mayor version > 1). Flash 11 and higher needs Zoom to FOV conversion.
						logger.addText("(I) - Loading an older version of session data ("+strXMLToolVersion+").", false);
					} else if (numToolVersion<numXMLMayorVersion) {
						logger.addText("(A) - Session Data v"+strXMLToolVersion+" is newer than this SSP Tool v"+strToolFullVersion+".", false);
					}
				}
				sG.globalFlipH = MiscUtils.stringToBoolean( sD.session._globalFlipH.text() );
			}
			
			// Create Session Screen
			sScreen = sessionView.addScreen(sS);
			if (!sScreen) return false;
//d			sScreen.disableScreen();
			
//d			sessionView = new SessionView(sWidth, sHeight, sXPos, sYPos, _ref, sS, newSessionScreen);
//d			sessionView.name = "Screen3D";
			
			// Start Session Objects Loading.
//d			setupCamera();
			loadPlayers();
			
			// Set Camera Pos.
//d			sessionView.initCamera();
			
			return true;
		}
		
/*d		private function setupCamera():void {
			// ---- CAMERA ---- //
			SessionView.camController.panAngle = Number( sS._cameraPanAngle.text() );
			SessionView.camController.tiltAngle = Number( sS._cameraTiltAngle.text() );
			SessionView.camController.camZoom(Number( sS._cameraZoom.text()) );
			//SessionView.camController.camFOV = Number( sS._cameraFOV.text() );
			SessionView.camController.camUpdate(0);
		}*/
		
		/* ---- PLAYERS ---- */
		private function loadPlayers():void {
			// ---- PLAYERS ---- //
			if (includeObjects) {
				strObjType = ObjectTypeLibrary.OBJECT_TYPE_PLAYER;
				oList = sS.children().(localName() == strObjType);
				for each(oXML in oList) {
					// Player Settings
					pS = new PlayerSettings();
					pS._screenId = int( sS._screenId.text() );
					pS._objectType = strObjType;
					pS._libraryId = Number( oXML._playerLibraryId.text() );
					pS._x = Number( oXML._x.text() );
					//pS._y = Number( oXML._y.text() );
					pS._elevationNumber = Number( oXML._y.text() );
					pS._z = Number( oXML._z.text() );
					pS._rotationY = Number( oXML._rotationY.text() );
					pS._flipH = MiscUtils.stringToBoolean( oXML._flipH.text() );
					pS._transparency = MiscUtils.stringToBoolean( oXML._transparency.text() );
					pS._accessories = oXML._accessories.text();
					// Player Kit Settings.
					pS._cKit._kitId = int( oXML._kitId.text() );
					pS._cKit._kitTypeId = int( oXML._kitTypeId.text() );
					pS._cKit._topColor = int( oXML._topColor.text() );
					pS._cKit._bottomColor = int( oXML._bottomColor.text() );
					pS._cKit._socksColor = int( oXML._socksColor.text() );
					pS._cKit._skinColor = int( oXML._skinColor.text() );
					pS._cKit._shoesColor = int( oXML._shoesColor.text() );
					// Team Settings.
					pS._teamPlayerId = oXML._teamPlayerId.text();
					pS._teamPlayer = (pS._teamPlayerId != "")? true : false;
					pS._playerPositionId = oXML._playerPositionId.text();
					pS._playerNumber = oXML._playerNumber.text();
					if (pS._teamPlayerId != "") {
						pS._playerGivenName = PRTeamManager.getInstance().getGivenName(pS._teamPlayerId, pS._cKit._kitId.toString());
						pS._playerFamilyName = PRTeamManager.getInstance().getFamilyName(pS._teamPlayerId, pS._cKit._kitId.toString());
					}
					sScreen.createNewObject3D(pS, false);
				}
			}
			loadEquipment();
		}
		
		/* ---- EQUIPMENT ---- */
		private function loadEquipment():void {
			// ---- EQUIPMENT ---- //
			strObjType = ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT;
			oList = sS.children().(localName() == strObjType);
			for each(oXML in oList) {
				// Equipment Settings.
				eS = new EquipmentSettings();
				eS._screenId = int( sS._screenId.text() );
				eS._objectType = strObjType;
				eS._libraryId = Number( oXML._equipmentLibraryId.text() );
				eS._onlyDefaultPitches = MiscUtils.stringToBoolean( oXML._onlyDefaultPitches.text() );
				eS._x = Number( oXML._x.text() );
				//eS._y = Number( oXML._y.text() );
				eS._elevationNumber = Number( oXML._y.text() );
				eS._size = Number( oXML._size.text() );
				eS._z = Number( oXML._z.text() );
				eS._rotationY = Number( oXML._rotationY.text() );
				eS._flipH = MiscUtils.stringToBoolean(  oXML._flipH.text() );
				eS._transparency = MiscUtils.stringToBoolean( oXML._transparency.text() );
				eS._equipColor = oXML._equipColor.text();
				eS._pathData = String( oXML._pathData.text() );
				if (includeObjects) {
					sScreen.createNewObject3D(eS, false);
				} else if (includeDefaultObjects) {
					if (eS._onlyDefaultPitches) {
						sScreen.createNewObject3D(eS, false);
					}
				}
			}
			loadLines();
		}
		
		
		private function loadLines():void {
			// ---- LINES ---- //
			if (includeObjects) {
				strObjType = ObjectTypeLibrary.OBJECT_TYPE_LINE;
				oList = sS.children().(localName() == strObjType);
				for each(oXML in oList) {
					lS = new LineSettings();
					lS._screenId = int( sS._screenId.text() );
					lS._objectType = strObjType;
					lS._libraryId = Number( oXML._linesLibraryId.text() );
					lS._pathData = String( oXML._pathData.text() );
					lS._pathCommands = String( oXML._pathCommands.text() );
					lS._lineStyle = Number(oXML._lineStyle.text());
					lS._lineType = Number(oXML._lineType.text());
					lS._lineColor = Number(oXML._lineColor.text());
					lS._lineThickness = Number(oXML._lineThickness.text());
					lS._useArrowHead = Number(oXML._useArrowHead.text());
					lS._arrowThickness = Number(oXML._arrowThickness.text());
					lS._useHandles = String(oXML._useHandles.text());
					sScreen.createNewLine3D(lS);
				}
			}
			loadTexts();
		}
		
		private function loadTexts():void {
			// ---- TEXT ---- //
			if (includeObjects) {
				//showMsg(" - Loading Texts...");
				strObjType = ObjectTypeLibrary.OBJECT_TYPE_TEXT;
				oList = sS.children().(localName() == strObjType);
				for each(oXML in oList) {
					tS = new TextSettings();
					tS._screenId = int( sS._screenId.text() );
					tS._objectType = strObjType;
					tS._libraryId = Number( oXML._textLibraryId.text() );
					tS._x = Number( oXML._x.text() );
					tS._y = Number( oXML._y.text() );
					tS._z = Number( oXML._z.text() );
					tS._textContent = String( oXML._textContent.text() );
					tS._textContent2 = String( oXML._textContent2.text() );
					tS._textStyle = oXML._textStyle.text();
					sScreen.createNewText(tS, false);
				}
				showMsg("Done.", false, false);
			}
		}
		
		private function getFirstScreenId():uint {
			var firstScreenId:uint = uint(sD.session.screen[0]._screenSortOrder.text());
			for each (var s:XML in sD.session.screen) {
				if (uint(s._screenSortOrder.text()) < firstScreenId) firstScreenId = uint(s._screenSortOrder.text());
			}
			return firstScreenId;
		}
		
		private function getLastScreenId():uint {
			var lastScreenId:uint = uint(sD.session.screen[0]._screenSortOrder.text());
			for each (var s:XML in sD.session.screen) {
				if (uint(s._screenSortOrder.text()) > lastScreenId) lastScreenId = uint(s._screenSortOrder.text());
			}
			return lastScreenId;
		}
		
		/*private function debugShowScreenId():void {
			// SessionScreen Debug.
			var mcObj:MovieClip;
			var _newBmp:Bitmap;
			mcObj = MovieClip(panelText.getChildByName("text_"+String(int(sS._screenId.text())+1)));
			_newBmp = MiscUtils.takeScreenshot(mcObj);
			_newBmp.name = mcObj.name;
			sScreen.addNewSprite3D(_newBmp, new Vector3D(), TextLibrary.TYPE_TEXT_CHAR, false, false);
		}*/
	}
}