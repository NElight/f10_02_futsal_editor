package  {
	import fl.controls.ComboBox;
	import fl.controls.List;
	import fl.controls.TextArea;
	import fl.managers.StyleManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.KeysManager;
	import src.MenusManager;
	import src.SSPBottomContainer;
	import src.ScreensController;
	import src.StageManager;
	import src.controls.datechooser.SSPCalendar;
	import src.controls.texteditor.SSPCommentsEditor;
	import src.controls.tooltip.SSPToolTip;
	import src.images.SSPImageViewer;
	import src.minutes.SSPMinutesEditor;
	import src.popup.MessageBox;
	import src.popup.PopupToolbar;
	import src.popup.ScribblePad;
	import src.print.SSPPrinter;
	import src.settings.SSPSettingsFormPopup;
	import src.tabbar.SSPTabBar;
	import src.tabbar.SSPTabBarBase;
	import src.tabbar.SSPTabBarDual;
	import src.videos.SSPVideoPlayer;
	
	import src3d.SSPCursors;
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.SessionLoader;
	import src3d.SessionView;
	import src3d.context.SSPContextMenu;
	import src3d.utils.Logger;
	import src3d.utils.SSPError;
	import src3d.utils.SessionDataLoader;
	import src3d.utils.SessionSaver;
	import src3d.utils.SysUtils;
	
	public class main extends MovieClip {
		private static var _sessionView:SessionView;
		internal var _pitchSlider:pitchSlider;
		internal var _save:MovieClip;
		internal var _clearpitch:MovieClip;
		internal var num_screens = 1;
		public var _menu:accordion;
		public var _comments:SSPCommentsEditor;
		public var _minutes:SSPMinutesEditor;
		public var _header:header;
		public var _controls:controls;
		public var _screen_holder:MovieClip;
		public var _pad:ScribblePad;
		public var tabBar:SSPTabBarBase;
		internal var popupToolbar:PopupToolbar;
		public var settingsForm:SSPSettingsFormPopup;
		private var screenController:ScreensController;

		// Containers
		internal var _mainContainer:MovieClip; // Contains 3D Scren holders, tabbar, save, clear pitch.
		internal var _headerContainer:MovieClip; // Contains header with full screen, full pitch, settings and scribble pad buttons.
		internal var _padContainer:MovieClip; // Contains scribble pad area.
		internal var _popupToolbarContainer:MovieClip; // Contains 3D popup toolbar.
		internal var _bottomContainer:SSPBottomContainer; // Contains comments and minutes.
		private var _mainContainerNormal:Rectangle; // Not used in F10.
		
		private var sL:SessionLoader;
		private var _sessionSaver:SessionSaver;
		private var sspPrinter:SSPPrinter;
		
		private var sessionGlobals:SessionGlobals = SessionGlobals.getInstance();
		private var sessionDataLoader:SessionDataLoader = new SessionDataLoader();
		private var logger:Logger = Logger.getInstance();
		
		private static var _stage:Stage;
		private static var _msgBox:MessageBox;
		private static var _keysManager:KeysManager;
		private static var _videoPlayer:SSPVideoPlayer;
		private static var _imageViewer:SSPImageViewer;
		private static var _sspContextMenu:SSPContextMenu = new SSPContextMenu();
		
		public function main():void 
		{ 
			if(!this.stage)  {
				this.addEventListener(Event.ADDED_TO_STAGE, initSessionLoad); 
			} else { 
				initSessionLoad();
			}
		}

		
		
		// ----------------------------- App Initialization ----------------------------- //
		private function initSessionLoad(e:Event = null) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, initSessionLoad);
			_stage = this.stage;
			
			var globalFormat:TextFormat = new TextFormat("_sans");
			StyleManager.setStyle("textFormat", globalFormat);
			StyleManager.setStyle("textPadding", 1); // Texts and Cell renderers default padding.
			StyleManager.setComponentStyle(TextArea, "textFormat", TextFormat);
			
			for each (var strURL:String in SSPSettings.aAllowedDomains) {
				Security.allowDomain(strURL);
				//Security.allowInsecureDomain(strURL);
			}
			
			initUIContainers();
			_sspContextMenu.applyToTarget(this,null,true);
			
			// Init Keys Manager.
			_keysManager = KeysManager.getInstance(this.stage);
			
			// Init Video Player.
			_videoPlayer = SSPVideoPlayer.getInstance(this);
			
			// Store System Info.
			var sysUtils:SysUtils = new SysUtils();
			if (sysUtils.storeSystemInfo()) {
				logger.addSysInfo("Flash Player: "+sessionGlobals.clientFlashFullVersion+" ("+sessionGlobals.clientPlayerType+")");
				logger.addSysInfo("OS: "+sessionGlobals.clientOS+" ("+sessionGlobals.clientBrowserLanguage+") ("+sessionGlobals.clientProcessorType+")");
				logger.addSysInfo("Screen: "+sessionGlobals.clientScreen);
				logger.addSysInfo("CPU Architecture: "+sessionGlobals.clientCPUArchitecture);
			} else {
				logger.addSysInfo("(A) - Can't collect System Info.");
			}
			
			if (!_msgBox) {
				// Init Message Box.
				//_msgBox = new MessageBox(MovieClip(this), new Point(500, 300), true);
				_msgBox = new MessageBox(this.stage);
				_msgBox.showMsg("Loading Interface...", MessageBox.BUTTONS_NONE, "SSP", true);
				logger.addText("Loading Interface...", false);
			}else {
				// If retry has been clicked.
				_msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, initSessionLoad); 
				_msgBox.showMsg("Retrying Session Load...", MessageBox.BUTTONS_NONE);
				logger.addText("Retrying Session Load...", true);
			}
			
			sessionGlobals.isLocal = checkLocal();
			
			var sessionDataURL:String = "";
			var sspRevision:String = ""; // Store revision number in Session Globals.
			var sessionType:String = ""; // Training or Match Day.
			
			try {
				sessionDataURL = String(stage.loaderInfo.parameters.xmlRequestFile);
				// If there is a path from flashvars, work from server.
				if (sessionDataURL != "undefined" && sessionDataURL != null && sessionDataURL != "") {
					sessionGlobals.sessionDataURL = sessionDataURL;
					//sessionGlobals.isLocal = false;
				} else {
					sessionGlobals.isLocal = true;
				}
				
				sspRevision = String(stage.loaderInfo.parameters.revision);
				if (sspRevision != "undefined" && sspRevision != null && sspRevision != "") {
					sessionGlobals.sspRevision = sspRevision;
				} else {
					sessionGlobals.sspRevision = "";
				}
				
				/*sessionType = String(stage.loaderInfo.parameters.is_match);
				if (sessionType != "undefined" && sessionType != null && sessionType != "") {
					if (sessionType == "1") {
						sessionGlobals.sessionType = SessionGlobals.SESSION_TYPE_MATCH;
					} else {
						sessionGlobals.sessionType = SessionGlobals.SESSION_TYPE_TRAINING;
					}
				} else {
					sessionGlobals.sessionType = SessionGlobals.SESSION_TYPE_TRAINING;
				}*/
			}catch(e:Error) {
				logger.addText("Can't load FlashVars.\n"+e, true);
				sessionGlobals.isLocal = true;
				logger.addText("(A) - xmlRequestFile from Local: "+ sessionGlobals.sessionDataURL, false);
				
				sessionGlobals.sspRevision = "";
			}
			
			sessionGlobals.sspFlashVersion = Capabilities.version;
			
			sessionDataLoader.addEventListener(SSPEvent.SUCCESS, init, false, 0, true);
			sessionDataLoader.addEventListener(SSPEvent.ERROR, onDataLoadingError, false, 0, true);
			sessionDataLoader.startSessionLoad(sessionGlobals.sessionDataURL);
		}
		
		private function onDataLoadingError(e:SSPEvent):void {
			sessionDataLoader.removeEventListener(SSPEvent.SUCCESS, init);
			sessionDataLoader.removeEventListener(SSPEvent.ERROR, onDataLoadingError);
			var sspError:SSPError = e.eventData;
			var errorMsg:String = sspError.fullErrorMessage;
			_msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, initSessionLoad, false, 0, true);
			showMsg(errorMsg, true, true, MessageBox.BUTTONS_RETRY_COPY);
		}

		private function init(event:SSPEvent):void 
		{
			sessionDataLoader.removeEventListener(SSPEvent.SUCCESS, init);
			sessionDataLoader.removeEventListener(SSPEvent.ERROR, onDataLoadingError);
			System.useCodePage=true;
			
			// Log Session Id.
			var sId:String = sessionGlobals.sessionDataXML.session._sessionToken.text();
			if (sId == "") {
				logger.addText("Missing or Empty _sessionToken", true);
			} else {
				logger.addText("Session Id: "+sId, false);
			}
			
			getNumScreens();
			
			// Init Stage Manager.  是否全屏控制
			StageManager.getInstance().initialize(this);
			
			// Init Menus Manager.  是否把场地全屏
			MenusManager.getInstance().initialize(this);
			
			// Init Tooltips.  鼠标悬停提示文字组件
			SSPToolTip.getInstance().initToolTips(this.stage);
			
			// Init calendar. 
			SSPCalendar.getInstance().initCalendar(this.stage);
			
			// Init printer.
			sspPrinter = new SSPPrinter(this.stage);
			
			// Translate Message Box Labels.
			_msgBox.setButtonsLabels(
				sessionGlobals.interfaceLanguageDataXML.buttons[0]._btnInterfaceOk.text(),
				sessionGlobals.interfaceLanguageDataXML.buttons[0]._btnInterfaceCancel.text(),
				sessionGlobals.interfaceLanguageDataXML.buttons[0]._btnInterfaceRetry.text(),
				sessionGlobals.interfaceLanguageDataXML.buttons[0]._InterfaceCopyClipboard.text(),
				"",
				sessionGlobals.interfaceLanguageDataXML.buttons[0]._btnInterfaceSaveToPC.text()
				);
			
			_screen_holder = new mc_screen_holder();
			_screen_holder.x 			= 224;
			_screen_holder.y 			= 66;
			_mainContainer.addChild(_screen_holder);
			
			// Full Pitch Popup Toolbar.
			popupToolbar = new PopupToolbar(this, this, this.stage.stageWidth/2, this.stage.stageHeight);
			_popupToolbarContainer.addChild(popupToolbar);
			
			
			// Init Image Viewer.
			_imageViewer = new SSPImageViewer(this.stage, this, 1);
			
			// Save Button.
			_save = new mc_save();
			_save.x 			= 124;
			_save.y 			= 570;
			_save.save_title.text = sessionGlobals.interfaceLanguageDataXML.buttons[0]._save.text();
			_mainContainer.addChild(_save);
			
			// Clear All Button.
			_clearpitch = new mc_clear_pitch();
			_clearpitch.x 			= 1;
			_clearpitch.y 			= 570;
			_clearpitch.clearpitch_title.text = sessionGlobals.interfaceLanguageDataXML.buttons[0]._clear.text();
			_mainContainer.addChild(_clearpitch);
			
			_menu 			= new accordion(this);
			_pitchSlider	= new pitchSlider(this);
			//_comments		= new comments(this,stage);
			_bottomContainer = new SSPBottomContainer();
			_mainContainer.addChild(_bottomContainer);
			_comments		= _bottomContainer.comments;
			_minutes		= _bottomContainer.minutes;
			_controls		= new controls(this,stage);
			_header			= new header(this,stage);
			
			if (sessionGlobals.sessionType == SessionGlobals.SESSION_TYPE_TRAINING) {
				tabBar = new SSPTabBar(new Point(249,35));
				_mainContainer.addChild(tabBar);
			} else {
				tabBar = new SSPTabBarDual(new Point(249,35));
				_mainContainer.addChild(tabBar);
			}
			
			_pad			= new ScribblePad(this,_padContainer,_headerContainer.height);
			settingsForm	= new SSPSettingsFormPopup(this);
			
			// Init Custom Cursors.
			SSPCursors.getInstance().initCustomCursors(stage);
			
			// Init 3D Screens.
			init3DScreens();
			
			bringHeaderToFront();
			
			bringMainContainerToFront();
			
			// Session Saver.
			_sessionSaver = new SessionSaver(this, this._save, _msgBox, _sessionView);
			
			// Screen Controller.
			screenController = new ScreensController(this, _sessionView);
			
			settingsForm.formContent.refreshSettings();
		}
		
		private function getNumScreens():void {
			var sessionXML:XML = SessionGlobals.getInstance().sessionDataXML;
			var tmpXMLList:XMLList = sessionXML.session.screen;
			if (tmpXMLList.length() < 1) {
				// Maybe thrown an error here, but this should never happen anyway
				logger.addText("Error: No screens loaded", true);
				num_screens = 0;
			} else {
				num_screens = tmpXMLList.length();
			}
		}
		
		private function init3DScreens():void {
			trace("init3DScreens()");
			_sessionView = new SessionView(662, 387, 249, 67, this);
			this.addChild(_sessionView);
		}
		// --------------------------- End App Initialization --------------------------- //
		
		
		
		public function showMsg(newMsg:String, isError:Boolean = false, useBreak:Boolean = true, buttons:String = "BUTTONS_UNCHANGED", clearMsgBox:Boolean = false, entryType:String = "T"):void {
			_msgBox.popupEnabled = true;
			logger.addText(newMsg, isError, false, true, false, entryType);
			if (!clearMsgBox) {
				_msgBox.addMsg(newMsg, useBreak, buttons);
			} else {
				_msgBox.showMsg(newMsg, buttons);
			}
		}
		
		public function bringToFront(dObj:DisplayObjectContainer):void {
			if (!dObj) return;
			if (this.contains(dObj)) {
				this.setChildIndex(dObj, this.numChildren -1);
				dObj.visible = true;
			}
		}
		
		public function updateToolbars():void {
			var sId:uint = sessionView.currentScreenId;
			_controls.updateControls(sId);
			popupToolbar.updateControls(sId);
		}
		
		
		
		// ----------------------------- UI Containers ----------------------------- //
		/**
		 * Creates a transparent movieclip, use to resize the whole 2D objects.
		 * To use full screen, Stage3D needs "stage.scaleMode = StageScaleMode.NO_SCALE;".
		 * This mode doesn't scale the 2D stage, so we need to put all the 2D objects
		 * in a main movieclip container and scale it when the fullscreen command is called.
		 * Check proportionalScale() for more info.
		 */		
		private function initUIContainers():void {
			// -- Main 2D Interface -- //
			// var tBg:Sprite = new Sprite(); // Transparent bg to resize the movieclip.
			//tBg.graphics.lineStyle(0,0xffffff,0);
			// tBg.graphics.beginFill(0xFFFFFF,1); // Set alpha to 0 for transparent.
			// tBg.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			// tBg.graphics.endFill();
			// tBg.x = stage.stageWidth/2-tBg.width/2;
			// tBg.y = stage.stageHeight/2-tBg.height/2;
			_mainContainer = new MovieClip();
			//_mainContainer.addChildAt(tBg,0);
			_mainContainer.name = "_mainContainer";
			_mainContainerNormal = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
			this.addChild(_mainContainer);
			
			// -- Header -- //
			_headerContainer = new MovieClip();
			_headerContainer.name = "_headerContainer";
			this.addChild(_headerContainer);
			
			// -- ScribblePad -- //
			_padContainer = new MovieClip();
			_padContainer.name = "_padContainer";
			this.addChild(_padContainer);
			
			// -- Popup Toolbar -- //
			_popupToolbarContainer = new MovieClip();
			_popupToolbarContainer.name = "popupToolbarContainer";
			this.addChild(_popupToolbarContainer);
		}
		
		public function bringHeaderToFront():void {
			this.setChildIndex(_headerContainer, this.numChildren -1);
			_headerContainer.visible = true;
		}
		public function bringMainContainerToFront():void {
			this.setChildIndex(_mainContainer, this.numChildren -1);
			_mainContainer.visible = true;
		}
		public function bringPadContainerToFront():void {
			this.setChildIndex(_padContainer, this.numChildren -1);
			_padContainer.visible = true;
		}
		public function bringPopupToolbarContainerToFront():void {
			this.setChildIndex(_popupToolbarContainer, this.numChildren -1);
			_popupToolbarContainer.visible = true;
		}
		// --------------------------- End UI Containers --------------------------- //
		
		
		
		public function startSessionSave(saveToServer:Boolean):void {
			sessionSaver.startSessionSave(saveToServer);
		}
		
		public function checkMetaInfo():Boolean {
			if (!settingsForm.checkMetaInfo()) {
				_msgBox.popupVisible = false;
				settingsForm.popupVisible = true;
				logger.addText("(A) - Metadata is Incomplete. Displayed Settings Screen.", false);
				return false;
			}
			return true;
		}
		
		private function checkLocal():Boolean {
			var doMain:String = this.stage.loaderInfo.url;
			//trace("Running from: "+doMain);
			var doMainArray:Array = doMain.split("/");
			var local:Boolean = false;
			if (doMainArray[0] == "file:") {
				//trace("Local debug mode.");
				local = true;
			}else{
				//trace("Web host mode");
				local = false;
				var tmpURL:String = doMain.substr(0,33);
				if (tmpURL == "http://ssp.dev.kyosei-systems.com") {
					sessionGlobals.isDev = true;
				}
			}
			return local;
		}
		public function get sessionSaver():SessionSaver { return _sessionSaver; }
		public function get bottom():SSPBottomContainer { return _bottomContainer; }
		
		public static function get stage():Stage { return _stage; }
		public static function get msgBox():MessageBox { return _msgBox; }
		public static function get sessionView():SessionView { return _sessionView; }
		public static function get keysManager():KeysManager { return _keysManager; }
		public static function get videoPlayer():SSPVideoPlayer { return _videoPlayer; }
		public static function get imageViewer():SSPImageViewer { return _imageViewer; }
		/*public static function get debugMode():Boolean {
			return Globals3D.getInstance().isDebug;
		}*/

		
	}
}