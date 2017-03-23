package src3d.utils
{
	import flash.events.EventDispatcher;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	

	public class SessionDataLoader extends EventDispatcher
	{
		// Get the Main Session Data Globals Container (it will be used by 2D and 3D).
		private var sG:SessionGlobals = SessionGlobals.getInstance();

		// XML Loader vars.
		private var objLoader:ObjectLoader = new ObjectLoader();
		private var _sessionDataURL:String = sG.sessionDataURL;
		private var _iLangURL:String = sG.interfaceLanguageURL;// Interface Language URL from Session Data XML.
		private var _gDataURL:String = sG.menuDataURL; // Menu Data URL from Session Data XML.
		
		public function SessionDataLoader() {
		}
		
		public function startSessionLoad(path:String):void {
			initLoadSessionData(path);
		}
		
		private function removeListeners():void {
			objLoader.removeEventListener(SSPEvent.SUCCESS, onSessionDataXMLParse);
			objLoader.removeEventListener(SSPEvent.SUCCESS, onInterfaceLanguageParse);
			objLoader.removeEventListener(SSPEvent.SUCCESS, onMenuDataParse);
			objLoader.removeEventListener(SSPEvent.ERROR, onObjectLoadError);
		}
		
		public function initLoadSessionData(path:String):void {
			try {
				//var _path:String = (!sG.isLocal)? path : _sessionDataURL;
				var _path:String = (path != "undefined" && path != null && path != "")? path : _sessionDataURL;
				trace("Loading "+_path);
				objLoader.addEventListener(SSPEvent.SUCCESS, onSessionDataXMLParse, false, 0, true);
				objLoader.addEventListener(SSPEvent.ERROR, onObjectLoadError, false, 0, true);
				objLoader.loadXML(_path);
			} catch (error:Error) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, error.message) ));
				return;
			}
		}
		private function onSessionDataXMLParse(e:SSPEvent):void {
			removeListeners();
			trace("Parsing SessionData.");
			XML.ignoreWhitespace = true;
			// Get the loaded xml
			try {
				sG.sessionDataXML = e.eventData as XML;
			} catch (error:Error) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, error.message) ));
				return;
			}
			
			// If xml content is ok
			if (xmlContentOK()) {
				// Store Application Info.
				setApplicationInfo();
				// Get the Interface Language and Global Data.
				getExtraPaths();
				// Next Step.
				loadInterfaceLanguage();
			}
		}
		private function getExtraPaths():void {
			try {
				var _interfaceBaseURL:String = sG.sessionDataXML.session[0]._interfaceBaseUrl.text();
				var _xmlReceiveBase:String = sG.sessionDataXML.session[0]._xmlReceiveBase.text();
				var _interfaceLanguageCode:String = sG.sessionDataXML.session[0]._interfaceLanguageCode.text();
				var _sessionSport:String = sG.sessionDataXML.session[0]._sessionSport.text();
			} catch (error:Error) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA) ));
				return;
			}
			
			if (!sG.isLocal) {
				// USE: [_interfaceBaseUrl]+[_xmlReceiveBase]+[_interfaceLanguageCode]+"/language_tags"+[_sessionSport]+".xml"
				_iLangURL = _interfaceBaseURL + _xmlReceiveBase + _interfaceLanguageCode +"/language_tags_"+ _sessionSport +".xml";
			}
			
			if (!sG.isLocal) {
				// USE: [_interfaceBaseUrl].[_xmlReceiveBase]."/".[_interfaceLanguageCode]]."/global_data_".[sessionSport].".xml"
				_gDataURL = _interfaceBaseURL + _xmlReceiveBase + _interfaceLanguageCode +"/global_data_"+ _sessionSport +".xml";
			}
			
			if (_iLangURL == "/language_tags_.xml") {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_301_LOADING_LANGUAGE_DATA, "Can't parse language file path.") ));
				return;
			};
			
			if (_gDataURL == "/global_data_.xml") {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_302_LOADING_MENU_DATA, "Can't parse global data file path.") ));
				return;
			};
		}

		
		
		// ----------------------------- Language Data ----------------------------- //
		private function loadInterfaceLanguage():void {
			try {
				// Get Interface Language.
				objLoader.addEventListener(SSPEvent.SUCCESS, onInterfaceLanguageParse, false, 0, true);
				objLoader.addEventListener(SSPEvent.ERROR, onObjectLoadError, false, 0, true);
				trace("Loading "+_iLangURL);
				objLoader.loadXML(_iLangURL);
			} catch (error:Error) {
				trace("Error Loading XML: "+error.message);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_301_LOADING_LANGUAGE_DATA, error.message) ));
				return;
			}
		}
		private function onInterfaceLanguageParse(e:SSPEvent):void {
			removeListeners();
			trace("Parsing Interface Language.");
			try {
				// Store the loaded interface language XML into the global container.
				sG.interfaceLanguageDataXML = e.eventData as XML;
			} catch (error:Error) {
				trace("Error Parsing XML: "+error.message);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_301_LOADING_LANGUAGE_DATA, error.message) ));
				return;
			}
			// Next Step.
			loadMenuData();
		}
		// -------------------------- End of Language Data ------------------------- //
		
		
		
		// ----------------------------- Menu Data ----------------------------- //
		private function loadMenuData():void {
			try {
				// Get Global Menu Data.
				objLoader.addEventListener(SSPEvent.SUCCESS, onMenuDataParse, false, 0, true);
				objLoader.addEventListener(SSPEvent.ERROR, onObjectLoadError, false, 0, true);
				trace("Loading "+_gDataURL);
				objLoader.loadXML(_gDataURL);
			} catch (error:Error) {
				trace("Error Parsing XML: "+error.message);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_302_LOADING_MENU_DATA, error.message) ));
				return;
			}
		}
		private function onMenuDataParse(e:SSPEvent):void {
			removeListeners();
			trace("Parsing Global Menu Data.");
			try {
				// Store the loaded menu data XML into the global container.
				sG.menuDataXML = e.eventData as XML;
			} catch (error:Error) {
				trace("Error Parsing XML: "+error.message);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_302_LOADING_MENU_DATA, error.message) ));
				return;
			}
			
			this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS)); // Final Step.
		}
		// -------------------------- End of Menu Data ------------------------- //
		
		
		
		private function onObjectLoadError(e:SSPEvent):void {
			removeListeners();
			// Re-dispatch the received SSPEvent.
			this.dispatchEvent(e);
		}
		
		private function xmlContentOK():Boolean {
			var contentOK:Boolean = true;
			var xmlSessionSport:uint = uint( sG.sessionDataXML.session._sessionSport.text() );
			var strErrorMsg:String;
			// If xml doesn't contain <session>, then error.
			
			if (sG.sessionDataXML.session.length() < 1) {
				strErrorMsg = "Empty session data file.";
				contentOK = false;
			}
			
			if (xmlSessionSport != SSPSettings._sessionSport) {
				strErrorMsg = "Incorrect Sport code. Editor sport code: "+SSPSettings._sessionSport+". Data sport code: "+xmlSessionSport+".";
				contentOK = false;
			}
			
			if (contentOK == false) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, strErrorMsg) ));
			}

			return contentOK;
		}
		
		private function setApplicationInfo():void {
			// Session Type.
			sG.sessionType = sG.sessionDataXML.session._sessionType.text();
			// Store Loaded XML Version.
			sG.sspXMLVersion = Number(sG.sessionDataXML.session._globalSspToolVersion.text());
			// Store Application Info String.
			var appInfo:String = "SSP v"+sG.sspToolVersion.toString()+".0";
			if (sG.sspRevision && sG.sspRevision.toString() != "") {
				appInfo += " r"+sG.sspRevision;
			}
			if (sG.sspXMLVersion && sG.sspXMLVersion.toString() != "") {
				appInfo += " - Data v"+sG.sspXMLVersion.toString()+".0";
			}
			appInfo += " - Flash: "+sG.sspFlashVersion;
			sG.sspApplicationInfo = appInfo;
		}
	}
}