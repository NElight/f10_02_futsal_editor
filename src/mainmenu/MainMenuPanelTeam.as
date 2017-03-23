package src.mainmenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import src.buttons.SSPSimpleButton;
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	import src.team.PRTeamSettings;
	import src.team.SSPTeamEvent;
	import src.team.TeamGlobals;
	import src.team.list.PRCContainerOpposition;
	import src.team.list.PRCContainerOurTeam;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.MiscUtils;
	
	public class MainMenuPanelTeam extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var tG:TeamGlobals = TeamGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		// Tabs.
		private var tabOurTeam:MainMenuPanelTab;
		private var tabOppTeam:MainMenuPanelTab;
		private var tabSettings:MainMenuPanelTab;
		
		// Panels.
		private var listOurTeam:PRCContainerOurTeam;
		private var listOppTeam:PRCContainerOpposition;
		private var teamSettings:PRTeamSettings;
		
		// Common Controls.
		private var _btnTogglePlayerModel:SSPSimpleButton;
		private var _btnTogglePlayerNumber:SSPSimpleButton;
		private var _btnTogglePlayerDetailsExpanded:SSPSimpleButton;
		private var _btnTogglePlayerDetailsCondensed:SSPSimpleButton;
		private var _btnCyclePlayerNameFormat:SSPSimpleButton;
		
		// Current values.
		private var currentNameFormatIdx:uint;
		private var currentNumberFormatIdx:uint;
		private var currentListExpanded:Boolean;
		
		public function MainMenuPanelTeam()
		{
			super();
			this.y = 24;
			this.x = 24;
			
			tabOurTeam = this.btnTabOurTeam;
			tabOppTeam = this.btnTabOppTeam;
			tabSettings = this.btnTabSettings;
			
			listOurTeam = this.mcPlayerRecordsOurTeam as PRCContainerOurTeam;
			listOppTeam = this.mcPlayerRecordsOpposition as PRCContainerOpposition;
			teamSettings = this.mcTeamSettings as PRTeamSettings;
			
			_btnTogglePlayerModel = this.btnTogglePlayerModel;
			_btnTogglePlayerNumber = this.btnTogglePlayerNumber;
			_btnTogglePlayerDetailsExpanded = this.btnTogglePlayerDetailsExpanded;
			_btnTogglePlayerDetailsCondensed = this.btnTogglePlayerDetailsCondensed;
			_btnCyclePlayerNameFormat = this.btnCyclePlayerNameFormat;
			
			teamSettings.initSettings(listOurTeam, listOppTeam);
			
			initControls();
		}
		
		
		
		// ----------------------------------- List Format ----------------------------------- //
		protected function initControls():void {
			// Tab.
			tabOurTeam.label = sG.interfaceLanguageDataXML.titles._titleTeamOurs.text();
			tabOppTeam.label = sG.interfaceLanguageDataXML.titles._titleTeamOpposition.text();
			
			// Tooltips.
			_btnTogglePlayerModel.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTeamListTogglePoseNumber.text());
			_btnTogglePlayerNumber.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTeamListTogglePoseNumber.text());
			_btnTogglePlayerDetailsExpanded.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTeamListToggleCompactLong.text());
			_btnTogglePlayerDetailsCondensed.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTeamListToggleCompactLong.text());
			_btnCyclePlayerNameFormat.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTeamListCycleNameStyle.text());
			
			var vSettings:Vector.<SSPToolTipSettings> = new Vector.<SSPToolTipSettings>();
			vSettings.push(new SSPToolTipSettings(tabSettings, sG.interfaceLanguageDataXML.tags[0]._btnTeamSettings.text()));
			SSPToolTip.getInstance().addToolTips(vSettings);
			
			// Listeners.
			tabOurTeam.addEventListener(SSPEvent.MAIN_MENU_PANEL_TAB_CLICK, onPanelTabClick);
			tabOppTeam.addEventListener(SSPEvent.MAIN_MENU_PANEL_TAB_CLICK, onPanelTabClick);
			tabSettings.addEventListener(SSPEvent.MAIN_MENU_PANEL_TAB_CLICK, onPanelTabClick);
			//_btnTogglePlayerModel.addEventListener(MouseEvent.CLICK, onTogglePlayerModelFormat);
			//_btnTogglePlayerNumber.addEventListener(MouseEvent.CLICK, onTogglePlayerModelFormat);
			_btnTogglePlayerDetailsExpanded.addEventListener(MouseEvent.CLICK, onTogglePlayerDetails);
			_btnTogglePlayerDetailsCondensed.addEventListener(MouseEvent.CLICK, onTogglePlayerDetails);
			_btnCyclePlayerNameFormat.addEventListener(MouseEvent.CLICK, onCyclePlayerNameFormat);
			
			// Team - Name Format (full name, initial+name, etc.).
			currentNameFormatIdx = uint(sG.sessionDataXML.session._teamPlayerNameFormat.text());
			
			// Team - Number Format (show number or pose).
			currentNumberFormatIdx = uint(sG.sessionDataXML.session._teamPlayerNumberFormat.text());
			
			// Team - Display Position (show or hide player details).
			currentListExpanded = MiscUtils.stringToBoolean(sG.sessionDataXML.session._teamPlayerPositionDisplay.text());
			
			saveToXML();
			updateControls();
			showTeamSettings();
		}
		
		private function onCyclePlayerNameFormat(e:MouseEvent):void {
			// Cycle Player Name format (given name + family name, initial + family name, etc.).
			currentNameFormatIdx = MiscUtils.cycleArrayIdx(tG.aNameFormat, currentNameFormatIdx);
			saveToXML();
			updateControls();
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_SETTINGS_CHANGE_NAME_FORMAT, currentNameFormatIdx));
		}
		
		private function onTogglePlayerModelFormat(e:MouseEvent):void {
			// Toggle between Number or Pose (0 or 1).
			//currentNumberFormatIdx = (currentNumberFormatIdx == 0)? 1 : 0;
			currentNumberFormatIdx = MiscUtils.cycleArrayIdx(tG.aNumberFormat, currentNumberFormatIdx);
			saveToXML();
			updateControls();
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_SETTINGS_CHANGE_NUMBER_FORMAT, currentNumberFormatIdx));
		}
		
		private function onTogglePlayerDetails(e:MouseEvent):void {
			currentListExpanded = (currentListExpanded)? false : true;
			saveToXML();
			updateControls();
		}
		
		private function updateControls():void {
			listOurTeam.listExpanded = currentListExpanded;
			listOppTeam.listExpanded = currentListExpanded;
			// 0 = Pose, 1 = Number.
			if (currentNumberFormatIdx == 0) {
				_btnTogglePlayerModel.visible = true;
				_btnTogglePlayerNumber.visible = false;
			} else {
				_btnTogglePlayerModel.visible = false;
				_btnTogglePlayerNumber.visible = true;
			}
			
			if (currentListExpanded) {
				_btnTogglePlayerDetailsExpanded.visible = false;
				_btnTogglePlayerDetailsCondensed.visible = true;
				_btnTogglePlayerModel.enabled = true;
				_btnTogglePlayerNumber.enabled = true;
				_btnTogglePlayerModel.alpha = 1;
				_btnTogglePlayerNumber.alpha = 1;
				_btnTogglePlayerModel.addEventListener(MouseEvent.CLICK, onTogglePlayerModelFormat);
				_btnTogglePlayerNumber.addEventListener(MouseEvent.CLICK, onTogglePlayerModelFormat);
			} else {
				_btnTogglePlayerDetailsExpanded.visible = true;
				_btnTogglePlayerDetailsCondensed.visible = false;
				_btnTogglePlayerModel.enabled = false;
				_btnTogglePlayerNumber.enabled = false;
				_btnTogglePlayerModel.alpha = .3;
				_btnTogglePlayerNumber.alpha = .3;
				_btnTogglePlayerModel.removeEventListener(MouseEvent.CLICK, onTogglePlayerModelFormat);
				_btnTogglePlayerNumber.removeEventListener(MouseEvent.CLICK, onTogglePlayerModelFormat);
			}
		}
		
		private function saveToXML():void {
			var sXML:XML = sG.sessionDataXML.session[0];
			// Team - Name Format (full name, initial+name, etc.).
			sXML._teamPlayerNameFormat = currentNameFormatIdx.toString();
			
			// Team - Number Format (show number or pose).
			sXML._teamPlayerNumberFormat = currentNumberFormatIdx.toString();
			
			
			sXML._teamPlayerPositionDisplay = MiscUtils.booleanToString(currentListExpanded);
			
			// Team - Display Position (show or hide player details).
			currentListExpanded = MiscUtils.stringToBoolean(sG.sessionDataXML.session._teamPlayerPositionDisplay.text());
			listOurTeam.listExpanded = currentListExpanded;
			listOppTeam.listExpanded = currentListExpanded;
		}
		// -------------------------------- End of List Format ------------------------------- //
		
		
		
		// ----------------------------------- Tabs ----------------------------------- //
		private function onPanelTabClick(e:SSPEvent):void {
			switch(e.target) {
				case tabOurTeam:
					showOurTeam();
					break;
				case tabOppTeam:
					showOppTeam();
					break;
				case tabSettings:
					showTeamSettings();
					break;
			}
		}
		private function deselectAll():void {
			tabOurTeam.buttonSelected = false;
			tabOppTeam.buttonSelected = false;
			tabSettings.buttonSelected = false;
			listOurTeam.visible = false;
			listOppTeam.visible = false;
			teamSettings.visible = false;
		}
		// -------------------------------- End of Tabs ------------------------------- //
		
		
		
		// ----------------------------------- Public ----------------------------------- //
		public function showTeamSettings():void {
			deselectAll();
			tabSettings.buttonSelected = true;
			teamSettings.visible = true;
		}
		public function showOurTeam():void {
			deselectAll();
			tabOurTeam.buttonSelected = true;
			listOurTeam.visible = true;
		}
		public function showOppTeam():void {
			deselectAll();
			tabOppTeam.buttonSelected = true;
			listOppTeam.visible = true;
		}
		public function isOurTeamDisplayed():Boolean {
			return tabOurTeam.buttonSelected;
		}
		public function isOppTeamDisplayed():Boolean {
			return tabOppTeam.buttonSelected;
		}
		public function isTeamSettingsDisplayed():Boolean {
			return tabSettings.buttonSelected;
		}
		public function updateScreenSettings(sId:uint, tabGroupChanged:Boolean):void {
			teamSettings.updateScreenSettings(sId, tabGroupChanged);
		}
		public function updateTeamLists():void {
			listOurTeam.updateTeamListStyle();
			listOppTeam.updateTeamListStyle();
		}
		// -------------------------------- End of Public ------------------------------- //
	}
}