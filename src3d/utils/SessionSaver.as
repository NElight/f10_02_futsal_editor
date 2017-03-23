package src3d.utils
{
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import src.minutes.MinutesGlobals;
	import src.minutes.MinutesManager;
	import src.popup.MessageBox;
	import src.user.UserMediaManager;
	import src.utils.VideoValidatorEvent;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionView;

	public class SessionSaver
	{
		private var _ref:main;
		private var saveBtn:MovieClip;
		private var sessionView:SessionView;
		private var msgBox:MessageBox;
		
		private var sessionDataSaver:SessionDataSaver;
		private var sessionDataSaverTimeOut:int = -1;
		
		private var logger:Logger = Logger.getInstance();
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var uM:UserMediaManager = UserMediaManager.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		private var videoValidatorEventHandler:EventHandler = new EventHandler(uM);
		
		private var saveToServer:Boolean;
		
		private var saveToServerAutoRetryCounter:uint = 0;
		private var saveToServerManualRetry:Boolean = false;
		
		public function SessionSaver(ref:main, saveBtn:MovieClip, msgBox:MessageBox, sessionView:SessionView)
		{
			this._ref = ref;
			this.saveBtn = saveBtn;
			this.sessionView = sessionView;
			this.msgBox = msgBox;
			
			addSaveContextMenu();
			saveBtnEnabled(true);
		}
		
		private function saveBtnEnabled(enabled:Boolean):void {
			if (!enabled) {
				// Main Save Button.
				saveBtn.save_button.removeEventListener(MouseEvent.CLICK, onSessionSave);
				saveBtn.save_button.enabled = false;
				// Save to PC Shortcut.
				//_ref.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
				// Settings Save Button.
				//this._screens.settings_screen.saveExitButton.save_button.removeEventListener(MouseEvent.CLICK, onSessionSave);
				//this._screens.settings_screen.saveExitButton.visible = false;
			} else {
				// Main Save Button.
				saveBtn.save_button.enabled = true;
				saveBtn.save_button.addEventListener(MouseEvent.CLICK, onSessionSave, false, 0, true);
				// Save to PC Shortcut.
				//_ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler, false, 0, false);
				// Settings Save Button.
				//this._screens.settings_screen.saveExitButton.visible = true;
				//this._screens.settings_screen.saveExitButton.save_button.addEventListener(MouseEvent.CLICK, onSessionSave, false, 0, true);
			}
		}
		
		private function getSaverTimeOut():int {
			if (sessionDataSaverTimeOut > 0) {
				// Set Increased value.
				sessionDataSaverTimeOut = 200;
			} else {
				// Set Starting value.
				sessionDataSaverTimeOut = 40;
			}
			return sessionDataSaverTimeOut;
		}
		
		public function onSessionSaveExit(e:MouseEvent):void {
			logger.addUser("User has clicked 'Save and Exit'");
			startSessionSave(true);
		}
		
		private function onSessionSave(e:MouseEvent):void {
			if (e.target.name == "save_button") {
				logger.addUser("User has clicked 'Save'");
				startSessionSave(true);
			} else {
				logger.addUser("User has clicked 'Save To PC'");
				startSessionSave(false);
			}
		}
		
		private function onSessionSaveSaveToPC(e:Event):void {
			logger.addUser("User has clicked Save To PC in Message Box");
			removeSaveListeners();
			startSessionSave(false);
		}
		
		private function onSessionSaveRetry(e:Event):void {
			logger.addUser("User has clicked Retry Session Save in Message Box");
			removeSaveListeners();
			startSessionSave(true, true);
		}
		
		private function sessionSaveAutoRetry():void {
			logger.addAlert("Auto-retrying save ("+saveToServerAutoRetryCounter+")...");
			removeSaveListeners();
			startSessionSave(true, true);
		}
		
		private function onSessionSaveCancel(e:Event):void {
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onSessionSaveCancel);
			logger.addAlert("User has clicked Cancel Session Save in Message Box");
			removeSaveListeners();
			msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onBackToSession, false, 0, true);
			_ref.showMsg("Canceled.", false, true, MessageBox.BUTTONS_OK);
			saveBtnEnabled(true);
		}
		
		public function startSessionSave(saveToServer:Boolean, retrySave:Boolean = false):void {
			this.saveToServer = saveToServer;
			if (!retrySave) saveToServerAutoRetryCounter = 0;
			_ref.stage.focus = null; // Lose Focus to force settings fields to get updated.
			if (MinutesGlobals.getInstance().useMinutes) MinutesManager.getInstance().stopClock();
			if (sG.textEditing) return;
			msgBox.popupEnabled = true;
			
			// Disable Save buttons to avoid duplicated clicks.
			saveBtnEnabled(false);
			
			// Deselect the objects to take the screenshot.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, null));
			// Update the camera settings first.
			
			msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onSessionSaveCancel, false, 0, true);
			if (retrySave && saveToServerAutoRetryCounter > 0) {
				var strSaving:String = "Retrying save ("+saveToServerAutoRetryCounter+")...";
				_ref.showMsg(strSaving, false, true, MessageBox.BUTTONS_NONE, false, Logger.TYPE_ALERT);
			} else {
				_ref.showMsg("Saving Session...", false, false, MessageBox.BUTTONS_NONE, true);
			}
			
			// Check that the meta info in settings has been completed.
			_ref.showMsg("Checking Metadata.", false, true, MessageBox.BUTTONS_NONE);
			sG.showErrorOnSave = true;
			if (!_ref.checkMetaInfo()) {
				saveBtnEnabled(true);
				return;
			} else {
				_ref.settingsForm.popupVisible = false;
			}
			
			try {
				_ref.showMsg("Validating User Videos...", false, true);
				videoValidatorEventHandler.addEventListener(VideoValidatorEvent.VALIDATION_ALL_COMPLETE, onVideoValidationAllComplete);
				uM.validateAllUserVideos();
			} catch (e:Error) {
				videoValidatorEventHandler.RemoveEvents();
				logger.addError("Error validating user videos on saving. Continue saving data.");
				startDataSaving();
			}
		}
		
		private function onVideoValidationAllComplete(e:VideoValidatorEvent):void {
			videoValidatorEventHandler.RemoveEvents();
			var strDone:String = "Done.";
			var strWithErrors:String = "*";
			if (!e.eventData) strDone += strWithErrors;
			_ref.showMsg(strDone, false, false);
			startDataSaving();
		}
		
		private function startDataSaving():void {
			sessionDataSaver = new SessionDataSaver(_ref, sessionView);
			if (saveToServer) {
				sessionDataSaver.addEventListener(SSPEvent.SUCCESS, onDataSavingOK, false, 0, true);
				sessionDataSaver.addEventListener(SSPEvent.TIMEOUT, onDataSavingTimeOut, false, 0, true);
				sessionDataSaver.addEventListener(SSPEvent.ERROR, onDataSavingError, false, 0, true);
				sessionDataSaver.startSessionSave(false, getSaverTimeOut()); // save to server.
			}else {
				sessionDataSaver.addEventListener(SSPEvent.SUCCESS, onSaveToPCReturn, false, 0, true);
				sessionDataSaver.addEventListener(SSPEvent.CANCEL, onSaveToPCReturn, false, 0, true);
				sessionDataSaver.addEventListener(SSPEvent.ERROR, onDataSavingError, false, 0, true);
				sessionDataSaver.startSessionSave(true, -1); // save to pc.
			}
		}
		
		private function onDataSavingOK(e:SSPEvent):void {
			if (!sG.isLocal) {
				if (!sessionDataSaver.waitingLateSuccess) {
					sessionExit();
				} else {
					// Show late success message.
					var msg:String = sG.interfaceLanguageDataXML.messages._interfaceLateSaveSuccess.text();
					msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onSessionLateExit, false, 0, true);
					_ref.showMsg(msg, false, true, MessageBox.BUTTONS_OK, true);
				}
			} else {
				msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onBackToSession, false, 0, true);
				_ref.showMsg("Session Saved.", false, true, MessageBox.BUTTONS_OK);
			}
			removeSaveListeners();
			saveBtnEnabled(true);
			logger.addSeparator();
		}
		
		private function onSessionExit(e:Event):void {
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onSessionExit);
			sessionExit();
		}
		private function onSessionLateExit(e:Event):void {
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onSessionLateExit);
			sessionExit();
		}
		
		private function sessionExit():void {
			if (SSPSettings.noRedirectOnSave) {
				msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onBackToSession, false, 0, true);
				_ref.showMsg("Session Saved.", false, true, MessageBox.BUTTONS_OK);
			} else {
				sessionExitRedirect();
			}
		}
		
		private function sessionExitRedirect():void {
			try {
				trace("Redirecting");
				var urlBase:String = sG.sessionDataXML.session._interfaceBaseUrl.text();
				var url:String = sG.sessionDataXML.session._xmlMySessionsRedirect.text();
				var request:URLRequest = new URLRequest(urlBase+"/"+url);
				navigateToURL(request, "_self");
				_ref.showMsg("Done.\nRedirecting you to 'My Sessions'. Please wait...", false, true, MessageBox.BUTTONS_NONE);
			} catch (error:Error) {
				logger.addError("Error redirecting. "+error);
				onDataSavingError(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR, "\nError Details: "+error) ));
			}
		}
		
		private function onSaveToPCReturn(e:SSPEvent):void {
			// Save To PC Only.
			removeSaveListeners();
			saveBtnEnabled(true);
			logger.addSeparator();
		}
		
		private function onDataSavingTimeOut(e:SSPEvent):void {
			removeSaveListeners();
			msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, onSessionSaveRetry, false, 0, true);
			msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onBackToSession, false, 0, true);
			_ref.showMsg("There was a problem uploading your session.  Click 'Retry' to try again.", true, true, MessageBox.BUTTONS_RETRY_CANCEL);
			saveBtnEnabled(true);
		}
		
		private function onDataSavingError(e:SSPEvent):void {
			removeSaveListeners();
			saveBtnEnabled(true);
			var sspError:SSPError = e.eventData;
			var errorMsg:String = sspError.fullErrorMessage;
			// If unexpected error, display 'save to pc'.
			if (sspError.errorCode == SSPError.ERROR_CODE_ID_001_UNEXPECTED_ERROR) {
				msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onBackToSession, false, 0, true);
				msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_SAVE_TO_PC, onSessionSaveSaveToPC, false, 0, true);
				_ref.showMsg(errorMsg, true, true, MessageBox.BUTTONS_OK_SAVE_TO_PC);
			} else if (sspError.errorCode == SSPError.ERROR_CODE_ID_000_RETRY_TRIGGERED) {
				updateAutoRetry();
				if (saveToServerManualRetry) {
					msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, onSessionSaveRetry, false, 0, true);
					msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_SAVE_TO_PC, onSessionSaveSaveToPC, false, 0, true);
					_ref.showMsg(errorMsg, true, true, MessageBox.BUTTONS_RETRY_SAVE_TO_PC);
				} else {
					sessionSaveAutoRetry();
				}
			} else {
				msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onBackToSession, false, 0, true);
				_ref.showMsg(errorMsg, true, true, MessageBox.BUTTONS_OK_COPY);
			}
			
			logger.addSeparator();
		}
		
		private function removeSaveListeners():void {
			sessionDataSaver.removeEventListener(SSPEvent.SUCCESS, onSaveToPCReturn);
			sessionDataSaver.removeEventListener(SSPEvent.ERROR, onDataSavingError);
			sessionDataSaver.removeEventListener(SSPEvent.CANCEL, onSaveToPCReturn);
			sessionDataSaver.removeEventListener(SSPEvent.TIMEOUT, onDataSavingTimeOut);
			if (!sessionDataSaver.waitingLateSuccess) {
				sessionDataSaver.removeEventListener(SSPEvent.SUCCESS, onDataSavingOK);
				sessionDataSaver.stopSaver();
				msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onSessionLateExit);
			}
			
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onBackToSession);
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, onSessionSaveRetry);
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onBackToSession);
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_SAVE_TO_PC, onSessionSaveSaveToPC);
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onSessionSaveCancel);
			msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onSessionExit);
		}
		
		private function onBackToSession(e:Event):void {
			removeSaveListeners();
		}
		
		private function updateAutoRetry():void {
			saveToServerAutoRetryCounter ++;
			if (saveToServerAutoRetryCounter > SSPSettings.saveToServerAutoRetryMax) {
				if (saveToServerAutoRetryCounter == SSPSettings.saveToServerAutoRetryMax + 1) {
					logger.addError("Error saving session: auto-retry limit reached.");
				}
				//saveToServerAutoRetryCounter = 0;
				saveToServerManualRetry = true;
			} else {
				//saveToServerManualRetry = (SSPSettings.saveToServerAutoRetryAlways)? false : true;
			}
		}
		
		private function addSaveContextMenu():void {
			var saveToPCStr:String = sG.interfaceLanguageDataXML.buttons[0]._btnInterfaceSaveToPC.text();
			if (saveToPCStr == "") saveToPCStr = "Save to PC";
			var cMenu:ContextMenu = new ContextMenu();
			var itemSaveToPC:ContextMenuItem = new ContextMenuItem(saveToPCStr);
			
			itemSaveToPC.separatorBefore = true;
			itemSaveToPC.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSaveToPCContextHandler, false, 0, true);
			
			cMenu.hideBuiltInItems();
			cMenu.customItems = [itemSaveToPC];
			
			saveBtn.save_button.contextMenu = cMenu;
		}
		public function onSaveToPCContextHandler(e:ContextMenuEvent):void {
			startSessionSave(false);
		}
		
		
	}
}