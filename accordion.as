package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.mainmenu.MainMenuPanelTeam;
	import src.mainmenu.MainMenuTab;
	import src.minutes.MinutesGlobals;
	
	import src3d.SessionGlobals;
	
	public class accordion extends MovieClip
	{
		public static const MENU_1_PLAYERS:String		= "button1";
		public static const MENU_2_EQUIPMENT:String		= "button2";
		public static const MENU_3_LINES:String			= "button3";
		public static const MENU_4_TEXT:String			= "button4";
		public static const MENU_5_TEAM:String			= "button5";
		
		// Menu Settings.
		public var speed:Number = 0.3;
		public var _kits:kits;
		private var _equipment:equipment;
		private var _lines:lines;
		private var _texts:texts;
		private var _menuTeam:MainMenuPanelTeam;
		public var _accordion:MovieClip;
		
		//players panel vars
		private var current_panel = 1;
		
		private var _selectedTab:String = "";
		private var _previousTab:String = MENU_1_PLAYERS;
		private var vTabs:Vector.<MainMenuTab>;
		private var sessionType:String;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
				
		public function accordion(ref:main)
		{
			sessionType = sG.sessionDataXML.session._sessionType.text();
			_accordion = new mc_accordion();
			_accordion.x 			= 1;
			_accordion.y 			= 35;
			ref._mainContainer.addChild(_accordion);
			_accordion.mask = _accordion.acc_mask;
			
			// Create content.
			_kits = new kits(_accordion,ref);
			_equipment = new equipment(_accordion);
			_lines = new lines(ref,_accordion);
			_texts = new texts(_accordion, ref);
			
			vTabs = Vector.<MainMenuTab>([
				_accordion.button1,
				_accordion.button2,
				_accordion.button3,
				_accordion.button4
			]);
			
			if (sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				MinutesGlobals.getInstance().matchMinutes = sG.sessionDataXML.session._matchMinutes.text();
				_menuTeam = new MainMenuPanelTeam();
				_menuTeam.name = "panel5";
				_accordion.addChild(_menuTeam);
				vTabs.push(_accordion.button5);
				_accordion.setChildIndex(_accordion.mcTabBgFoot, _accordion.numChildren-1); // Bring footer to top.
			} else {
				_accordion.button5.visible = false;
			}
			
			_accordion.button1.label = sG.interfaceLanguageDataXML.menu[0]._titlePlayers.text();
			_accordion.button2.label = sG.interfaceLanguageDataXML.menu[0]._titleEquipment.text();
			_accordion.button3.label = sG.interfaceLanguageDataXML.menu[0]._titleLines.text();
			_accordion.button4.label = sG.interfaceLanguageDataXML.menu[0]._titleText.text();
			if (sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				_accordion.button5.label = sG.interfaceLanguageDataXML.menu[0]._titleMatchDay.text();
				
			}
			
			//Text panel needs integration with 3D
			//_accordion.panel4.placetext_title.text = "PLACE TEXT";
			
			for each (var tab:MainMenuTab in vTabs) {
				tab.addEventListener(MouseEvent.CLICK, clickHandler);
			}
			
			if (sG.sessionType == SessionGlobals.SESSION_TYPE_TRAINING) {
				slider(MENU_1_PLAYERS); // Players menu.
			} else {
				slider(MENU_5_TEAM); // Team menu.
			}
			
			var tf:TextFormat = new TextFormat(SSPSettings.DEFAULT_FONT, null, null, true);
			TextField(_accordion.txtTitle).defaultTextFormat = tf;
		}
		protected function clickHandler(event:MouseEvent):void {
			if (!event.target.parent) return;
			var tab:MainMenuTab = event.target.parent as MainMenuTab;
			if (!tab) return;
			slider(tab.name);
		}
		
		private function resetButtonStatus():void {
			for each (var tab:MainMenuTab in vTabs) {
				tab.buttonSelected = false;
			}
			_accordion.txtTitle.text = "";
		}
		
		private function hidePanels():void {
			var panel:MovieClip;
			for (var i:uint = 1;i<vTabs.length+1;i++) {
				panel = _accordion.getChildByName("panel"+i) as MovieClip;
				if (panel) {
					panel.visible = false;
				}
			}
		}
		
		private function selectTab(tabName:String):void {
			var tab:MainMenuTab = getTab(tabName);
			if (!tab) return;
			tab.buttonSelected = true;
			_accordion.txtTitle.text = tab.label;
		}
		
		private function displayTopBg(topNumber:uint):void {
			var mcTop:MovieClip;
			for (var i:uint;i<6;i++) {
				mcTop = _accordion.getChildByName("mcMainMenuTop"+i) as MovieClip;
				if (mcTop) mcTop.visible = false;
			}
			mcTop = _accordion.getChildByName("mcMainMenuTop"+topNumber) as MovieClip;
			if (mcTop) mcTop.visible = true;
		}
		
		public function slider(tabName:String):void
		{
			var panel:MovieClip;
			var topName:String;
			for (var i:uint = 1;i<vTabs.length+1;i++) {
				if (tabName == "button"+i) {
					panel = _accordion.getChildByName("panel"+i) as MovieClip;
					if (panel) {
						resetButtonStatus();
						selectTab(tabName);
						hidePanels();
						_previousTab = _selectedTab;
						panel.visible = true;
						_selectedTab = tabName;
						displayTopBg(i);
					}
				}
			}
		}
		
		private function getTab(tabName:String):MainMenuTab {
			for each (var tab:MainMenuTab in vTabs) {
				if (tab.name == tabName) return tab;
			}
			return null;
		}
		
		private function getPanel(pName:String):MainMenuPanelTeam {
			return _accordion.getChildByName(pName) as MainMenuPanelTeam;
		}
		
		// ----------------------------- Team Menu ----------------------------- //
		public function showTeamSettings():void {
			if (_menuTeam) _menuTeam.showTeamSettings();
		}
		public function showTeamOurTeam():void {
			if (_menuTeam) _menuTeam.showOurTeam();
		}
		public function showTeamOppTeam():void {
			if (_menuTeam) _menuTeam.showOppTeam();
		}
		public function isOurTeamDisplayed():Boolean {
			return (_menuTeam)? _menuTeam.isOurTeamDisplayed() : false;
		}
		public function isOppTeamDisplayed():Boolean {
			return (_menuTeam)? _menuTeam.isOppTeamDisplayed() : false;
		}
		public function isTeamSettingsDisplayed():Boolean {
			return (_menuTeam)? _menuTeam.isTeamSettingsDisplayed() : false;
		}
		public function updateScreenSettings(sId:uint, tabGroupChanged:Boolean):void {
			if (_menuTeam) _menuTeam.updateScreenSettings(sId, tabGroupChanged);
		}
		public function updateTeamLists():void {
			if (_menuTeam) _menuTeam.updateTeamLists();
		}

		public function get previousTab():String { return _previousTab; }
		public function get selectedTab():String { return _selectedTab; }
		// -------------------------- End of Team Menu ------------------------- //
		
	}
	
}