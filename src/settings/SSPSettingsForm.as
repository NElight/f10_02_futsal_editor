package src.settings
{
	import fl.controls.List;
	import fl.controls.ScrollPolicy;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import src.tabbar.SSPTabBarBase;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	
	public class SSPSettingsForm extends MovieClip
	{
		private var _ref:main;
		private var _stage:Stage;
		private var tabBar:SSPTabBarBase;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var containerXPos:Number = 214;
		private var containerYPos:Number = 0;
		private var generalSettingsName:String = "generalSettings";
		private var matchSettingsName:String = "matchSettings";
		private var videoSettingsName:String = "videoSettings";
		
		// Form Controls.
		private var generalSettingsContainer:GeneralSettingsContainer;
		private var screenSettingsContainer:ScreenSettingsContainerBase;
		private var videoSettingsContainer:UserSettingsContainer;
		private var sidebarList:List;
		
		private var lblReqField:TextField;
		private var txtAppInfo:TextField;
		private var btnSaveExit:MovieClip;
		
		// Form Settings.
		private var sspSettings:SSPSettings = new SSPSettings();
		
		public function SSPSettingsForm(ref:main)
		{
			this._ref = ref;
			this._stage = _ref.stage;
			this.tabBar = _ref.tabBar;
			
			//this.addEventListener(Event.ADDED_TO_STAGE, init);
			init();
		}
		
		private function init():void {
			//this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.name = "settings_form";
			
			// General Settings Refs.
			generalSettingsContainer = new GeneralSettingsContainer();
			generalSettingsContainer.x = containerXPos;
			generalSettingsContainer.y = containerYPos;
			this.addChild(generalSettingsContainer);
			screenSettingsContainer = (sG.sessionTypeIsMatch)? new MatchSettingsContainer() : new ScreenSettingsContainer();
			screenSettingsContainer.x = containerXPos;
			screenSettingsContainer.y = containerYPos;
			this.addChild(screenSettingsContainer);
			videoSettingsContainer = new UserSettingsContainer(this, tabBar);
			videoSettingsContainer.x = containerXPos;
			videoSettingsContainer.y = containerYPos;
			this.addChild(videoSettingsContainer);
			sidebarList = this.lstSidebarMenu;
			btnSaveExit = this.saveExitButton;
			txtAppInfo = this.txtAppVersion;
			lblReqField = this.lblRequiredField;
			
			// Setup.
			sidebarList.focusEnabled = false;
			var sbMenu:SidebarMenuCellRenderer = new SidebarMenuCellRenderer();
			sidebarList.setStyle("cellRenderer", SidebarMenuCellRenderer);
			sidebarList.verticalScrollPolicy = ScrollPolicy.AUTO;
			sidebarList.rowHeight = sbMenu.height;
			var bgTransparent:Shape = new Shape();
			sidebarList.setStyle("skin", bgTransparent);
			sidebarList.setStyle("upSkin", bgTransparent);
			sidebarList.addEventListener(ListEvent.ITEM_CLICK, onSidebarItemClick, false, 0, true);
			
			generalSettingsContainer.initGeneralSettings(this, tabBar);
			screenSettingsContainer.initGeneralSettings(this, tabBar);
			
			btnSaveExit.visible = false;
			addSaveExitContextMenu();
			txtAppInfo.text = sG.sspApplicationInfo;
			lblReqField.htmlText = SSPSettings.mandatoryCharacterStr+" "+sG.interfaceLanguageDataXML.titles._interfaceRequiredField.text();
			
			updateSidebarMenu();
			
			generalSettingsContainer.settingsEnabled = true;
			screenSettingsContainer.settingsEnabled = false;
			videoSettingsContainer.settingsEnabled = false;
			
			sidebarList.selectedIndex = 0;
		}
		
		public function updateSidebarMenu():void {
			// Sidebar.
			var aDP:Array = [];
			var strGeneralSettings:String = sG.interfaceLanguageDataXML.titles._filingGeneralSettings.text();
			aDP.push({
				label:strGeneralSettings,
				data:generalSettingsName
			});
			
			
			if (sG.sessionTypeIsMatch) {
				var strMatchSettings:String = sG.interfaceLanguageDataXML.titles._filingMatchSettings.text();
				aDP.push({
					label:strMatchSettings,
					data:matchSettingsName
				});
			} 
			
			var strVideoSettings:String = sG.interfaceLanguageDataXML.titles._filingVideoSettings.text();
			aDP.push({
				label:strVideoSettings,
				data:videoSettingsName
			});
			
			if (!sG.sessionTypeIsMatch) {
				for (var i:uint;i<tabBar.aTabs.length;i++) {
					aDP.push({
						label:MiscUtils.cropText(tabBar.aTabs[i].tabLabel, 15),
						data:tabBar.aTabs[i].tabScreenId
					});
				}
			}
			sidebarList.dataProvider = new DataProvider(aDP);
		}
		
		private function addSaveExitContextMenu():void {
			var saveToPCStr:String = sG.interfaceLanguageDataXML.buttons._btnInterfaceSaveToPC.text();
			if (saveToPCStr == "") saveToPCStr = "Save to PC";
			var cMenu:ContextMenu = new ContextMenu();
			var itemSaveToPC:ContextMenuItem = new ContextMenuItem(saveToPCStr);
			
			itemSaveToPC.separatorBefore = true;
			itemSaveToPC.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSaveToPCContextHandler, false, 0, true);
			
			cMenu.hideBuiltInItems();
			cMenu.customItems = [itemSaveToPC];
			
			btnSaveExit.save_button.contextMenu = cMenu;
		}
		
/*		private function addCommonListners():void {
			generalSettingsContainer.addEventListener(FocusEvent.FOCUS_OUT, onContainerFocusOutHandler, false, 0, true);
			screenSettingsContainer.addEventListener(FocusEvent.FOCUS_OUT, onContainerFocusOutHandler, false, 0, true);
		}
		
		private function removeCommonListeners():void {
			generalSettingsContainer.removeEventListener(FocusEvent.FOCUS_OUT, onContainerFocusOutHandler);
			screenSettingsContainer.removeEventListener(FocusEvent.FOCUS_OUT, onContainerFocusOutHandler);
		}
		
		private function onContainerFocusOutHandler(event:FocusEvent):void {
			updateContainers();
			updateExternalControlSettings();
			// TODO: loop all screens.
			//sG.sessionDataXML.session.screen.(_screenId == strId)._screenCategoryId = screenCb.selectedItem.data.toString();
		}*/
		
		
		
		// ----------------------------- Sidebar Menu ----------------------------- //
		private function onSidebarItemClick(e:ListEvent):void {
			var cData:Object = sidebarList.getItemAt(e.index);
			if (!cData) return;
			if (cData.data == generalSettingsName) {
				generalSettingsContainer.settingsEnabled = true;
				screenSettingsContainer.settingsEnabled = false;
				videoSettingsContainer.settingsEnabled = false;
				logger.addText("(U) - General Settings selected", false);
			} else if (cData.data == videoSettingsName) {
				generalSettingsContainer.settingsEnabled = false;
				screenSettingsContainer.settingsEnabled = false;
				videoSettingsContainer.settingsEnabled = true;
				logger.addText("(U) - User's Video Settings selected", false);
			} else {
				generalSettingsContainer.settingsEnabled = false;
				screenSettingsContainer.selectedScreenId = cData.data;
				screenSettingsContainer.settingsEnabled = true;
				videoSettingsContainer.settingsEnabled = false;
				if (sG.sessionTypeIsMatch) {
					logger.addText("(U) - Match Settings selected", false);
				} else {
					logger.addText("(U) - Screen Settings of screenId "+screenSettingsContainer.selectedScreenId+" selected.", false);
				}
				
			}
		}
		// -------------------------- End of Sidebar Menu ------------------------- //
		
		
		
		// ----------------------------- Update Settings ----------------------------- //
		public function updateCommonSettings():void {
			updateExternalControlSettings();
			updateSidebarMenuTitles();
		}
		private function updateSidebarMenuTitles():void {
			if (sG.sessionTypeIsMatch) return;
			var numScreenId:Number;
			var strScreenId:String;
			var strScreenTitle:String;
			var tmpTxtField:TextField = new TextField();
			for (var i:uint = 1;i<sidebarList.length;i++) {
				numScreenId = sidebarList.getItemAt(i).data;
				if (!isNaN(numScreenId)) {
					strScreenId = numScreenId.toString();
					tmpTxtField.htmlText = sG.sessionDataXML.session.screen.(_screenId == strScreenId)[0]._screenTitle.text();
					sidebarList.getItemAt(i).label = MiscUtils.cropText(tmpTxtField.text, 25);
				}
			}
			sidebarList.invalidateList();
		}
		private function updateContainers():void {
/*			generalSettingsContainer.updateScreensList();
			screenSettingsContainer.updateSettings();*/
		}
		private function updateExternalControlSettings():void {
			updateHeaderSessionTitle();
			updateTabTitles();
		}
		private function updateHeaderSessionTitle():void {
			_ref._header.setHeaderSessionTitle(generalSettingsContainer.txtSessionTitle.htmlText);
		}
		private function updateTabTitles():void {
			var strScreenId:String;
			var strScreenTitle:String;
			for (var i:uint = 0;i<tabBar.aTabs.length;i++) {
				strScreenId = tabBar.aTabs[i].tabScreenId.toString();
				if (strScreenId && strScreenId != "") {
					strScreenTitle = String(sG.sessionDataXML.session.screen.(_screenId == strScreenId)[0]._screenTitle.text());
					tabBar.aTabs[i].tabLabel = strScreenTitle;
				}
			}
		}
		public function refreshSettings():void {
			updateSidebarMenu();
			generalSettingsContainer.updateScreensList();
			videoSettingsContainer.updateList();
		}
		// -------------------------- End of Update Settings ------------------------- //
		
		
		
		// TODO: Add listener for metainfo errors?
		public function toggleSaveButton(t:Boolean):void {
			if (t) {
				btnSaveExit.visible = true;
				btnSaveExit.save_button.addEventListener(MouseEvent.CLICK, onSessionSaveExit);
			} else {
				btnSaveExit.visible = false;
				btnSaveExit.save_button.removeEventListener(MouseEvent.CLICK, onSessionSaveExit);
			}
		}
		
		public function onSessionSaveExit(e:MouseEvent):void {
			this.logger.addText("(I) - User has clicked 'Save and Exit' in Settings", false);
			sG.textEditing = false;
			this._ref.startSessionSave(true);
		}
		
		public function onSaveToPCContextHandler(e:ContextMenuEvent):void {
			this.logger.addText("(I) - User has clicked 'Save To PC' in Settings", false);
			sG.textEditing = false;
			this._ref.startSessionSave(false);
		}
		
		public function checkMetaInfo():Boolean {
			if (!generalSettingsContainer.initialized) generalSettingsContainer.forceInit();
			generalSettingsContainer.settingsEnabled = true;
			screenSettingsContainer.settingsEnabled = false;
			videoSettingsContainer.settingsEnabled = false;
			updateExternalControlSettings();
			return generalSettingsContainer.checkMetaInfo();
		}
		
		private function setFormFocus():void {
			_ref.stage.focus = generalSettingsContainer.txtSessionTitle;
		}
		
		public function formOpen():void {
			logger.addText("(U) - Settings Form open", false);
			sG.textEditing = true;
			updateSidebarMenu();
			videoSettingsContainer.settingsEnabled = false;
			screenSettingsContainer.settingsEnabled = false;
			generalSettingsContainer.settingsEnabled = true;
			sidebarList.selectedIndex = 0;
//			addCommonListners();
			setFormFocus();
		}
		
		public function formClose():void {
			logger.addText("(U) - Settings Form close", false);
//			removeCommonListeners();
			sG.textEditing = false;
		}
	}
}