package
{
	//import flash.events.Event;
	import fl.containers.ScrollPane;
	import fl.controls.CheckBox;
	import fl.events.ColorPickerEvent;
	
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.models.KitColorSettings;
	import src3d.models.soccer.AccessoriesLibrary;
	import src3d.models.soccer.players.MCPlayer;
	import src3d.models.soccer.players.Player;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.utils.MiscUtils;
	
	public class kits extends MovieClip
	{
		private var _kits_panel:MovieClip;
		
		private var player_actions:Vector.<MCPlayer> = new Vector.<MCPlayer>();
		private var keeper_actions:Vector.<MCPlayer> = new Vector.<MCPlayer>();
		private var official_actions:Vector.<MCPlayer> = new Vector.<MCPlayer>();
		private	var kit_designs:Array = [];
		private var kit_colours:Array = [];
		private var customKitColours:Array = ["0xFF0000","0xFF0000","0xFF0000","0xFF0000","0xFF0000","0xFF0000"];
		private var cKit:PlayerKitSettings = new PlayerKitSettings(); // Stores the selected 3D Player kit.
		private var selectedPlayer:Player; // The selected player.
		
		//Default kit colours
		private var shirt_color = "0xFF0000";
		private var bottoms_color = "0x00FF00";
		private var socks_color = "0xFF0000";
		private var shoes_color = "0x000000";
		private var skin_color = "0xFFCCCC";
		private var hair_color = "0x000000";
		
		private var _ref:main;
		private var _menu:MovieClip;
		private var _kit_ref;
		private var _players_actions_ref:MovieClip; // Stores Players and Goalkeepers icons MC.
		private var _officials_actions_ref:MovieClip; // Stores Officials icons MC.
		
		private var selected_item;
		private var color_info:ColorTransform;
		private var lastScrollItem:int;
		private var aScrollItems:Array = [];
		
		private var current_panel = 1;
		private var previous_panel:Number;
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		
		private var showCustomKit = false;
		
		public function kits(accmenu:MovieClip,ref:main)
		{
			
			_ref = ref;
			_menu = accmenu;
			
			//Add kits panel movieclip
			_kits_panel = new mc_kits_panel();
			_kits_panel.x 			= 0;
			_kits_panel.y 			= 0;
			_menu.panel1.addChild(_kits_panel);
			
			//Prepare panels
			_kits_panel.players_kits_tab.kit_types_bar.kit1.gotoAndStop(2);
			_kits_panel.players_kits_tab.kit_types_bar.kit1.btn_label.textColor = 0xD0FE89;
			_kits_panel.players_actions_tab.player_kit_buttons.kit1.gotoAndStop(2);
			_kits_panel.players_actions_tab.player_kit_buttons.kit1.btn_label.textColor = 0xD0FE89;
			
			// Add labels.
			_kits_panel.players_actions_tab.btn_label.text = sG.interfaceLanguageDataXML.titles[0]._titlePlayerActions.text();
			//_kits_panel.players_actions_tab.mirror_button.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnMirror.text();
			_kits_panel.players_actions_tab.player_kit_buttons.kit1.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnKit1.text();
			_kits_panel.players_actions_tab.player_kit_buttons.kit2.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnKit2.text();
			_kits_panel.players_actions_tab.player_kit_buttons.kit3.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnOfficials.text();
			
			_kits_panel.players_kits_tab.btn_label.text = sG.interfaceLanguageDataXML.titles[0]._titlePlayerKit.text();
			_kits_panel.players_kits_tab.kit_types_bar.kit1.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnKit1.text();
			_kits_panel.players_kits_tab.kit_types_bar.kit2.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnKit2.text();
			_kits_panel.players_kits_tab.kit_types_bar.kit3.btn_label.text = sG.interfaceLanguageDataXML.buttons[0]._menuBtnOfficials.text();
			
			_kits_panel.player_custom_tab.cbSemiTransparent.label = sG.interfaceLanguageDataXML.menu[0]._optionSemiTransparent.text();
			_kits_panel.player_custom_tab.cbSpeedChute.label = sG.interfaceLanguageDataXML.menu[0]._optionSpeedChute.text();
			
			//shorter vars
			_kit_ref 		= _kits_panel.players_kits_tab.kits;
			//_actions_ref 	= _kits_panel.players_actions_tab.players_scroller.mc_players_list;
			
			// Store _globalFlipH.
			sG.globalFlipH = (MiscUtils.stringToBoolean( sG.sessionDataXML.session[0]._globalFlipH.text() ))? true : false;
			
			// Add scroller content.
			_players_actions_ref = new mc_players_list();
			_officials_actions_ref = new mc_officials_list();
			//addChild(_players_actions_ref);
			setMenuToScroll(_players_actions_ref);
			
			//Display correct kits
			_kit_ref.kit1_a.visible = true;
			_kit_ref.kit1_b.visible = true;
			_kit_ref.kit2_a.visible = false;
			_kit_ref.kit2_b.visible = false;
			_kit_ref.kit3_a.visible = false;
			
			//Add tab listeners
			_kits_panel.players_kits_tab.button.addEventListener(MouseEvent.CLICK, switch_panel);
			_kits_panel.players_actions_tab.button.addEventListener(MouseEvent.CLICK, switch_panel);
			
			// Store players and officials actions mc's on the corresponding array.
			var i:int;
			var mc:MCPlayer;
			var mcName:String;
			var vTooltipSettings:Vector.<SSPToolTipSettings> = new Vector.<SSPToolTipSettings>();
			for(i=0; i<_players_actions_ref.numChildren; i++) {
				mc = _players_actions_ref.getChildAt(i) as MCPlayer;
				if (mc != null) {
					// Player names can have this format: "player###", "keeper###", "referee###"
					mcName = mc.name.substr(0,mc.name.length - SSPSettings.namesDigits); // Get all but 3 last digits.
					if (mcName == MCPlayer.NAME_PLAYER) {
						player_actions.push(mc);
						vTooltipSettings.push(new SSPToolTipSettings(mc, getToolTipText(mc)));
					} else if (mcName == MCPlayer.NAME_KEEPER) {
						keeper_actions.push(mc);
						vTooltipSettings.push(new SSPToolTipSettings(mc, getToolTipText(mc)));
					}
				}
			}
			for(i=0; i<_officials_actions_ref.numChildren; i++) {
				mc = _officials_actions_ref.getChildAt(i) as MCPlayer;
				if (mc != null) {
					// Player names can have this format: "player###", "keeper###", "referee###"
					mcName = mc.name.substr(0,mc.name.length - SSPSettings.namesDigits); // Get all but 3 last digits.
					if (mcName == MCPlayer.NAME_OFFICIAL) {
						official_actions.push(mc);
						vTooltipSettings.push(new SSPToolTipSettings(mc, getToolTipText(mc)));
					}
				}
			}
			
			//Creat array to hold player kit design
			kit_designs = [_kit_ref.kit1_a, _kit_ref.kit1_b, _kit_ref.kit2_a, _kit_ref.kit2_b, _kit_ref.kit3_a];
							
			//For each kit design, add multiply effect, ddd colorPicker listers and add default color to swatch
			for (var k in kit_designs) {
				
				kit_designs[k].kit_top.blendMode = BlendMode.MULTIPLY;
				kit_designs[k].kit_bottom.blendMode = BlendMode.MULTIPLY;
				kit_designs[k].kit_socks.blendMode = BlendMode.MULTIPLY;
				kit_designs[k].kit_shoes.blendMode = BlendMode.MULTIPLY;
				kit_designs[k].kit_skin.blendMode = BlendMode.MULTIPLY;
				kit_designs[k].kit_hair.blendMode = BlendMode.MULTIPLY;
				
				//kit_designs[k].cp_hair.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
				kit_designs[k].cp_skin.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
				kit_designs[k].cp_shoes.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
				kit_designs[k].cp_socks.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
				kit_designs[k].cp_bottom.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
				kit_designs[k].cp_top.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
				
				kit_designs[k].cp_skin.selectedColor = skin_color;
				kit_designs[k].cp_top.selectedColor = shirt_color;
				kit_designs[k].cp_bottom.selectedColor = bottoms_color;
				kit_designs[k].cp_socks.selectedColor = socks_color;
				kit_designs[k].cp_shoes.selectedColor = shoes_color;
			
			}
			
			//Add event listeners, and color effect to custom kit 
			_kits_panel.player_custom_tab.customKit.kit_top.blendMode = BlendMode.MULTIPLY;
			_kits_panel.player_custom_tab.customKit.kit_bottom.blendMode = BlendMode.MULTIPLY;
			_kits_panel.player_custom_tab.customKit.kit_socks.blendMode = BlendMode.MULTIPLY;
			_kits_panel.player_custom_tab.customKit.kit_shoes.blendMode = BlendMode.MULTIPLY;
			_kits_panel.player_custom_tab.customKit.kit_skin.blendMode = BlendMode.MULTIPLY;
			_kits_panel.player_custom_tab.customKit.kit_hair.blendMode = BlendMode.MULTIPLY;
			
			//_kits_panel.player_custom_tab.customKit.cp_hair.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
			_kits_panel.player_custom_tab.customKit.cp_skin.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
			_kits_panel.player_custom_tab.customKit.cp_shoes.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
			_kits_panel.player_custom_tab.customKit.cp_socks.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
			_kits_panel.player_custom_tab.customKit.cp_bottom.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
			_kits_panel.player_custom_tab.customKit.cp_top.addEventListener (ColorPickerEvent.CHANGE, colorChanged);
			
			_kits_panel.player_custom_tab.customKit.cp_skin.selectedColor = skin_color;
			_kits_panel.player_custom_tab.customKit.cp_top.selectedColor = shirt_color;
			_kits_panel.player_custom_tab.customKit.cp_bottom.selectedColor = bottoms_color;
			_kits_panel.player_custom_tab.customKit.cp_socks.selectedColor = socks_color;
			_kits_panel.player_custom_tab.customKit.cp_shoes.selectedColor = shoes_color;
			
			_kits_panel.player_custom_tab.customkit_help.text = sG.interfaceLanguageDataXML.menu[0]._custom_player_help.text();
			
			// Add custom settings events.
			CheckBox(_kits_panel.player_custom_tab.cbSemiTransparent).addEventListener(MouseEvent.CLICK, onCheckBoxClick);
			CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).addEventListener(MouseEvent.CLICK, onCheckBoxClick);
			
			//Add kit types listeners (home, away, officials) to actions panel
			_kits_panel.players_kits_tab.kit_types_bar.kit1.button.addEventListener(MouseEvent.CLICK, select_kit_type1);
			_kits_panel.players_kits_tab.kit_types_bar.kit2.button.addEventListener(MouseEvent.CLICK, select_kit_type2);
			_kits_panel.players_kits_tab.kit_types_bar.kit3.button.addEventListener(MouseEvent.CLICK, select_kit_type3);
			
			//Add kit types listeners (home, away, officials) to kit design panel
			_kits_panel.players_actions_tab.player_kit_buttons.kit1.button.addEventListener(MouseEvent.CLICK, choose_actions_type1);
			_kits_panel.players_actions_tab.player_kit_buttons.kit2.button.addEventListener(MouseEvent.CLICK, choose_actions_type2);
			_kits_panel.players_actions_tab.player_kit_buttons.kit3.button.addEventListener(MouseEvent.CLICK, choose_actions_type3);
			
			//Add listener to Mirror button (football and futsal)
			_kits_panel.players_actions_tab.mirror_button.mirror.addEventListener(MouseEvent.CLICK, mirrorPlayers);
			vTooltipSettings.push(new SSPToolTipSettings(
				_kits_panel.players_actions_tab.mirror_button.mirror,
				sG.interfaceLanguageDataXML.tags[0]._btnPlayersMirror.text()
			));
			
			//Add listener to Scroll Loop button (hockey).
			//_kits_panel.players_actions_tab.scroll_loop_button.button.addEventListener(MouseEvent.CLICK, scrollLoop);
			/*vTooltipSettings.push(new SSPToolTipSettings(
				_kits_panel.players_actions_tab.scroll_loop_button.button,
				sG.interfaceLanguageDataXML.tags[0]._btnCyclePlayerType.text()
			));*/

			//GO!
			set_panel(); 				//Display panel (set to 1, player actions, in vars)
			set_kit_colours_from_xml();
			
			//Map colours store in kit colours to player actions Movieclips
			map_actions_colours(0);		//Accepts kit 0,1,2
			
			var j:int;
			for (i=0; i<3; i++) {
				for(j=0; j<2; j++) {
					map_design_colours(i,j);
				}
			}
			
			SSPToolTip.getInstance().addToolTips(vTooltipSettings);

		}
		
		//Change colours on kit
		private function colorChanged (event:ColorPickerEvent):void {

			var kit_group:uint = 0; // 0 = Kit1, 1 = Kit2, 2 = Officials.
			var kit_subgroup:uint = 0; // 0 = Players, 1 = Keepers.
			
			var kit_type_name:String = event.target.parent.name;
			
			var kit_type = event.target.parent;
			var selected_cp = event.target;

			var i = 0;
			
			/*
			trace(color_info); 
			color_info.color = selected_item.selectedColor;
			
			trace(selected_item.selectedColor);
			*/

			if(kit_type_name != "customKit") {
				
				switch(kit_type_name) {
					case "kit1_a":
						kit_group = 0;
						kit_subgroup = 0;
						break;
					case "kit1_b":
						kit_group = 0;
						kit_subgroup = 1;
						break;
					case "kit2_a":
						kit_group = 1;
						kit_subgroup = 0;
						break;
					case "kit2_b":
						kit_group = 1;
						kit_subgroup = 1;
						break;	
					case "kit3_a":
						kit_group = 2;
						kit_subgroup = 0;
						break;
				}	

				var hex_color = "";
			
				if(selected_cp.name == "cp_top") {
				
					color_info = kit_type.kit_top.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_top.transform.colorTransform = color_info;
				
					hex_color = "0x" + selected_cp.hexValue;
				
					kit_colours[kit_group][kit_subgroup]['shirt'] = hex_color;
				}
			
				if(selected_cp.name == "cp_bottom") {
				
					color_info = kit_type.kit_bottom.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_bottom.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
				
					kit_colours[kit_group][kit_subgroup]['bottoms'] = hex_color;
				}
				if(selected_cp.name == "cp_socks") {
				
					color_info = kit_type.kit_socks.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_socks.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
				
					kit_colours[kit_group][kit_subgroup]['socks'] = hex_color;
				}
				if(selected_cp.name == "cp_skin") {
				
					color_info = kit_type.kit_skin.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_skin.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
				
					kit_colours[kit_group][kit_subgroup]['skin'] = hex_color;
				}
				if(selected_cp.name == "cp_shoes") {
				
					color_info = kit_type.kit_shoes.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_shoes.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
				
					kit_colours[kit_group][kit_subgroup]['shoes'] = hex_color;
				}
				if(selected_cp.name == "cp_hair") {
				
					color_info = kit_type.kit_hair.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_hair.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
				
					kit_colours[kit_group][kit_subgroup]['hair'] = hex_color;
				}
				
				save_colours_to_xml(kit_group);
				
				map_actions_colours(kit_group);
				
				// Dispatch the Custom Kit update event.
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.PLAYERS_UPDATE_DEFAULT_KITS));

			} else {
				
				
				if(selected_cp.name == "cp_top") {
					color_info = kit_type.kit_top.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_top.transform.colorTransform = color_info;	
					hex_color = "0x" + selected_cp.hexValue;
					cKit._topColor = selected_cp.selectedColor;
				}
			
				if(selected_cp.name == "cp_bottom") {
					color_info = kit_type.kit_bottom.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_bottom.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
					cKit._bottomColor = selected_cp.selectedColor;
				}
				if(selected_cp.name == "cp_socks") {
					color_info = kit_type.kit_socks.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_socks.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
					cKit._socksColor = selected_cp.selectedColor;
				}
				if(selected_cp.name == "cp_skin") {
					color_info = kit_type.kit_skin.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_skin.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
					cKit._skinColor = selected_cp.selectedColor;
				}
				if(selected_cp.name == "cp_shoes") {
					color_info = kit_type.kit_shoes.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_shoes.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
					cKit._shoesColor = selected_cp.selectedColor;
				}
				if(selected_cp.name == "cp_hair") {
					color_info = kit_type.kit_hair.transform.colorTransform;
					color_info.color = selected_cp.selectedColor;
					kit_type.kit_hair.transform.colorTransform = color_info;
					hex_color = "0x" + selected_cp.hexValue;
					//cKit._hairColor = selected_cp.selectedColor;
				}
				
				// Dispatch the Custom Kit update event.
				selectedPlayer.setCustomKit(cKit);
				//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.PLAYER_UPDATE_SINGLE_CUSTOM_KIT,cKit));
			}
		}
		private function switch_panel(event:MouseEvent):void {
			set_panel();
		}
		
		//Select actions or kits panel
		public function set_panel(panel = 0):void {

			if(panel != 0) {
				if(panel == 1) {
					current_panel = 2;
				} else {
					current_panel = 1;
				}
			}
			
			// Update Toggle Buttons.
			/*if (sG.flipH) {
				_kits_panel.players_actions_tab.mirror_button.gotoAndStop(2);
			} else {
				_kits_panel.players_actions_tab.mirror_button.gotoAndStop(1);
			}*/
			
			_kits_panel.setChildIndex(_kits_panel.player_custom_tab, 1);
			
			if(current_panel == 1) {
				_kits_panel.setChildIndex(_kits_panel.players_actions_tab, 3);
				_kits_panel.players_actions_tab.button.removeEventListener(MouseEvent.CLICK, switch_panel);
				_kits_panel.players_actions_tab.gotoAndStop(1);
				
				_kits_panel.setChildIndex(_kits_panel.players_kits_tab, 2);
				_kits_panel.players_kits_tab.button.addEventListener(MouseEvent.CLICK, switch_panel);
				_kits_panel.players_kits_tab.gotoAndStop(2);
				current_panel = 2;
			} else if(current_panel == 2) {
				_kits_panel.setChildIndex(_kits_panel.players_actions_tab, 2);
				_kits_panel.players_actions_tab.button.addEventListener(MouseEvent.CLICK, switch_panel);
				_kits_panel.players_actions_tab.gotoAndStop(2);
				
				_kits_panel.setChildIndex(_kits_panel.players_kits_tab, 3);
				_kits_panel.players_kits_tab.button.removeEventListener(MouseEvent.CLICK, switch_panel);
				_kits_panel.players_kits_tab.gotoAndStop(1);
				current_panel = 1;
			}
		}
		
		
		//Map kit colours to actions
		private function map_actions_colours(j:int) {
			var i:int = 0;
			var mc:MCPlayer;
			// If Not Referees chosen.
			if(j < 2) {
				// Load the players container in the scroller.
				setMenuToScroll(_players_actions_ref);
				
				for each(mc in player_actions) {
					apply_kit_colours(mc, j, 0);
					//mc.visible = true;
				}
				for each(mc in keeper_actions) {
					apply_kit_colours(mc, j, 1);
					//mc.visible = true;
				}
				//for each(mc in official_actions) mc.visible = false; // Hide officials icons.
			} else {
				// If Referees tab chosen.
				
				// Load the officials container in the scroller.
				setMenuToScroll(_officials_actions_ref);
				
				// Apply kit colours.
				for each(mc in official_actions) {
					apply_kit_colours(mc, j, 0);
					//mc.visible = true;
				}
				//for each(mc in player_actions) mc.visible = false;
				//for each(mc in keeper_actions) mc.visible = false;
			}
		}
		
		private function apply_kit_colours(mc:MCPlayer, kit_group:int, kit_subgroup:int):void {
			// Apply colours to 2D player poses icons.
			var kc:KitColorSettings = new KitColorSettings(
				kit_colours[kit_group][kit_subgroup]['hair'],
				kit_colours[kit_group][kit_subgroup]['skin'],
				kit_colours[kit_group][kit_subgroup]['shirt'],
				kit_colours[kit_group][kit_subgroup]['bottoms'],
				kit_colours[kit_group][kit_subgroup]['socks'],
				kit_colours[kit_group][kit_subgroup]['shoes']
			);
			mc.setKitColor(kc);
		}
		
		
		private function map_design_colours(i:int,j:int) {
			
			if(i == 2 && j == 1) {
				
			} else {
				var shirt_colour:ColorTransform = new ColorTransform();
				var bottoms_colour:ColorTransform = new ColorTransform();
				var socks_colour:ColorTransform = new ColorTransform();
				var shoes_colour:ColorTransform = new ColorTransform();
				var skin_colour:ColorTransform = new ColorTransform();
				var hair_colour:ColorTransform = new ColorTransform();
			
				shirt_colour.color = kit_colours[i][j]['shirt'];
				bottoms_colour.color = kit_colours[i][j]['bottoms'];
				socks_colour.color = kit_colours[i][j]['socks'];
				shoes_colour.color = kit_colours[i][j]['shoes'];
				skin_colour.color = kit_colours[i][j]['skin'];
				hair_colour.color = kit_colours[i][j]['hair'];
				
				var kitIndex = kit_colours[i][j]['kitIndex'];
			
				kit_designs[kitIndex].kit_top.transform.colorTransform = shirt_colour;
				kit_designs[kitIndex].kit_bottom.transform.colorTransform = bottoms_colour;
				kit_designs[kitIndex].kit_socks.transform.colorTransform = socks_colour;
				kit_designs[kitIndex].kit_shoes.transform.colorTransform = shoes_colour;
				kit_designs[kitIndex].kit_skin.transform.colorTransform = skin_colour;
				//kit_designs[kitIndex].kit_hair.transform.colorTransform = hair_colour;
			}
			
		}
		
		// Save colours to xml.
		private function save_colours_to_xml(kit_group:int):void {
			var kitXML:XMLList;
			for (var i:int = 0;i<2;i++) {
				//kitXML = sG.sessionDataXML.session.children().(localName() == "kit").(_kitId == String(kit_group) && _kitTypeId == String(i));
				kitXML = sG.sessionDataXML.session.kit.(_kitId == String(kit_group) && _kitTypeId == String(i));
				kitXML._topColor = String(kit_colours[kit_group][i]['shirt']);
				kitXML._bottomColor = String(kit_colours[kit_group][i]['bottoms']);
				kitXML._socksColor = String(kit_colours[kit_group][i]['socks']);
				kitXML._shoesColor = String(kit_colours[kit_group][i]['shoes']);
				kitXML._skinColor = String(kit_colours[kit_group][i]['skin']);
				//kitXML._hairColor = String(kit_colours[kit_group][i]['hair']);
			}
		}
		
		//Set up kit colour array and defaults
		private function set_kit_colours_from_xml() {
			
			//Kit colour defaults
			
			var i = 0;
			var j = 0;
			var y = 0;
			
			var kitXML:XMLList;
			var letter:String;
			var color_info:ColorTransform;
			var kit_type:MovieClip;
			
			
			for (i=0; i<3; i++) {
				kit_colours[i] = new Array();

				for(j=0; j<2; j++) {
					// Get the kit colors from SessionGlobals.
					kitXML = sG.sessionDataXML.session.kit.(_kitId == String(i) && _kitTypeId == String(j));
					// Player Actions Tab.
					kit_colours[i][j] = new Array();
					kit_colours[i][j]['shirt'] = kitXML._topColor;
					kit_colours[i][j]['bottoms'] = kitXML._bottomColor;
					kit_colours[i][j]['socks'] = kitXML._socksColor;
					kit_colours[i][j]['shoes'] = kitXML._shoesColor;
					kit_colours[i][j]['skin'] = kitXML._skinColor;
					kit_colours[i][j]['hair'] = kitXML._hairColor;
					kit_colours[i][j]['kitIndex'] = y;

					if(i == 2 && j == 1) {
						
					} else {
						kit_designs[y].cp_skin.selectedColor = kitXML._skinColor;
						kit_designs[y].cp_top.selectedColor = kitXML._topColor;
						kit_designs[y].cp_bottom.selectedColor = kitXML._bottomColor;
						kit_designs[y].cp_socks.selectedColor = kitXML._socksColor;
						kit_designs[y].cp_shoes.selectedColor = kitXML._shoesColor;
						//kit_designs[y].cp_hair.selectedColor = kitXML._hairColor;
					}
					
					y++;
					/*
					// Player Kit Designer Tab
					letter = (j==0)? "a" : "b";
					if (_kit_ref["kit"+(i+1)+"_"+letter]) {
						kit_type = _kit_ref["kit"+(i+1)+"_"+letter];
						
						color_info = kit_type.kit_top.transform.colorTransform;
						color_info.color = kitXML._topColor;
						kit_type.kit_top.transform.colorTransform = color_info;
						
						color_info = kit_type.kit_bottom.transform.colorTransform;
						color_info.color = kitXML._bottomColor;
						kit_type.kit_bottom.transform.colorTransform = color_info;
						
						color_info = kit_type.kit_socks.transform.colorTransform;
						color_info.color = kitXML._socksColor;
						kit_type.kit_socks.transform.colorTransform = color_info;
						
						color_info = kit_type.kit_shoes.transform.colorTransform;
						color_info.color = kitXML._shoesColor;
						kit_type.kit_shoes.transform.colorTransform = color_info;
						
						color_info = kit_type.kit_skin.transform.colorTransform;
						color_info.color = kitXML._skinColor;
						kit_type.kit_skin.transform.colorTransform = color_info;
						
						kit_type.cp_top.selectedColor = kitXML._topColor;
						kit_type.cp_bottom.selectedColor = kitXML._bottomColor;
						kit_type.cp_socks.selectedColor = kitXML._socksColor;
						kit_type.cp_shoes.selectedColor = kitXML._shoesColor;
						kit_type.cp_skin.selectedColor = kitXML._skinColor;
						
					}
					*/
				}
				
			}

		}
		
		
		//Kit design button actions
		private function select_kit_type1(event:MouseEvent):void {
			resetScroll();
			deselect_kit_buttons();
			default_kits_button(0);
			default_actions_button(0);
			map_actions_colours(0);
			sG.currentKitId = 0;
		}
		private function select_kit_type2(event:MouseEvent):void {
			resetScroll();
			deselect_kit_buttons();
			default_kits_button(1);
			default_actions_button(1);
			map_actions_colours(1);
			sG.currentKitId = 1;
		}
		private function select_kit_type3(event:MouseEvent):void {
			resetScroll();
			deselect_kit_buttons();
			default_kits_button(2);
			default_actions_button(2);
			map_actions_colours(2);
			sG.currentKitId = 2;
		}
		
		private function deselect_kit_buttons():void {
			var tc:uint = 0x555555;
			_kits_panel.players_kits_tab.kit_types_bar.kit1.gotoAndStop(1);
			_kits_panel.players_kits_tab.kit_types_bar.kit2.gotoAndStop(1);
			_kits_panel.players_kits_tab.kit_types_bar.kit3.gotoAndStop(1);
			_kits_panel.players_kits_tab.kit_types_bar.kit1.btn_label.textColor = tc;
			_kits_panel.players_kits_tab.kit_types_bar.kit2.btn_label.textColor = tc;
			_kits_panel.players_kits_tab.kit_types_bar.kit3.btn_label.textColor = tc;
			
		}
		
		//Actions button actions
		private function choose_actions_type1(event:MouseEvent) {
			resetScroll();
			deselect_actions_buttons();
			default_kits_button(0);
			default_actions_button(0);
			map_actions_colours(0);
			sG.currentKitId = 0;
		}
		private function choose_actions_type2(event:MouseEvent) {
			resetScroll();
			deselect_actions_buttons();
			default_kits_button(1);
			default_actions_button(1);
			map_actions_colours(1);
			sG.currentKitId = 1;
		}
		private function choose_actions_type3(event:MouseEvent) {
			resetScroll();
			deselect_actions_buttons();
			default_kits_button(2);
			default_actions_button(2);
			map_actions_colours(2);
			sG.currentKitId = 2;
		}
		
		private function deselect_actions_buttons():void {
			var tc:uint = 0x555555;
			_kits_panel.players_actions_tab.player_kit_buttons.kit1.gotoAndStop(1);
			_kits_panel.players_actions_tab.player_kit_buttons.kit2.gotoAndStop(1);
			_kits_panel.players_actions_tab.player_kit_buttons.kit3.gotoAndStop(1);
			_kits_panel.players_actions_tab.player_kit_buttons.kit1.btn_label.textColor = tc;
			_kits_panel.players_actions_tab.player_kit_buttons.kit2.btn_label.textColor = tc;
			_kits_panel.players_actions_tab.player_kit_buttons.kit3.btn_label.textColor = tc;
		}
		
		private function default_actions_button(kit_type:int) {
			deselect_actions_buttons();
			switch(kit_type) {
				case 0:
					_kits_panel.players_actions_tab.player_kit_buttons.kit1.gotoAndStop(2);
					_kits_panel.players_actions_tab.player_kit_buttons.kit1.btn_label.textColor = 0xD0FE89;
					break;
				case 1:
					_kits_panel.players_actions_tab.player_kit_buttons.kit2.gotoAndStop(2);
					_kits_panel.players_actions_tab.player_kit_buttons.kit2.btn_label.textColor = 0xD0FE89;
					break;
				case 2:
					_kits_panel.players_actions_tab.player_kit_buttons.kit3.gotoAndStop(2);
					_kits_panel.players_actions_tab.player_kit_buttons.kit3.btn_label.textColor = 0xD0FE89;
					break;
			}
		}

		private function default_kits_button(kit_type:int) {
			deselect_kit_buttons();
			switch(kit_type) {
				case 0:
					_kits_panel.players_kits_tab.kit_types_bar.kit1.gotoAndStop(2);
					_kits_panel.players_kits_tab.kit_types_bar.kit1.btn_label.textColor = 0xD0FE89;
					_kit_ref.kit1_a.visible = true;
					_kit_ref.kit1_b.visible = true;
					_kit_ref.kit2_a.visible = false;
					_kit_ref.kit2_b.visible = false;
					_kit_ref.kit3_a.visible = false;
					selected_item = null;
					break;
				case 1:
					_kits_panel.players_kits_tab.kit_types_bar.kit2.gotoAndStop(2);
					_kits_panel.players_kits_tab.kit_types_bar.kit2.btn_label.textColor = 0xD0FE89;
					_kit_ref.kit1_a.visible = false;
					_kit_ref.kit1_b.visible = false;
					_kit_ref.kit2_a.visible = true;
					_kit_ref.kit2_b.visible = true;
					_kit_ref.kit3_a.visible = false;
					selected_item = null;
					break;
				case 2:
					_kits_panel.players_kits_tab.kit_types_bar.kit3.gotoAndStop(2);
					_kits_panel.players_kits_tab.kit_types_bar.kit3.btn_label.textColor = 0xD0FE89;
					_kit_ref.kit1_a.visible = false;
					_kit_ref.kit1_b.visible = false;
					_kit_ref.kit2_a.visible = false;
					_kit_ref.kit2_b.visible = false;
					_kit_ref.kit3_a.visible = true;
					selected_item = null;
					break;
			}
		}
		
		private function getToolTipText(mc:MovieClip):String {
			var objId:String = mc.name.substr(mc.name.length-SSPSettings.namesDigits); // Get the Id from the instance name (last digits).
			var tagName:String = "_tagPosition"+objId;
			var ttText:String = sG.interfaceLanguageDataXML.tags[0][tagName].text();
			return ttText;
		}
		
		private function mirrorPlayers(event:MouseEvent):void {
			
			var movedist:int = 0;
			var pAction;
			
			// Update Global FlipH.
			sG.globalFlipH = (sG.globalFlipH)? false : true;

			for (pAction in player_actions) {				
				player_actions[pAction].scaleX *= -1;
				player_actions[pAction].x = player_actions[pAction].x + movedist;	
			}
			for (pAction in keeper_actions) {				
				keeper_actions[pAction].scaleX *= -1;
				keeper_actions[pAction].x = keeper_actions[pAction].x + movedist;	
			}
			for (pAction in official_actions) {				
				official_actions[pAction].scaleX *= -1;
				official_actions[pAction].x = official_actions[pAction].x + movedist;	
			}
		}
		
		public function openCustomKit(playerCustomKit:Object = null) {

			_kits_panel.players_actions_tab.gotoAndStop(2);
			_kits_panel.players_actions_tab.button.addEventListener(MouseEvent.CLICK, switch_panel);
			_kits_panel.players_kits_tab.gotoAndStop(1);
			_kits_panel.players_kits_tab.button.removeEventListener(MouseEvent.CLICK, switch_panel);
			previous_panel = current_panel;
			current_panel = 1;
			showCustomKit = true;
			
			if (playerCustomKit) {
				// Store Selected Player.
				selectedPlayer = playerCustomKit.player as Player;
				// Store the Player's Custom Kit to be modified later.
				cKit = playerCustomKit.cKit as PlayerKitSettings;
				
				// Get Default Kit Colours first.
				var kitXML:XMLList = sG.sessionDataXML.session.kit.(_kitId == String(cKit._kitId) && _kitTypeId == String(cKit._kitTypeId));
				
				
				// Populates customKitColours array. If some colour value is -1, use it's default kit colour.
				customKitColours[0] = (cKit._topColor != -1)? cKit._topColor : kitXML._topColor;
				customKitColours[1] = (cKit._bottomColor != -1)? cKit._bottomColor : kitXML._bottomColor;
				customKitColours[2] = (cKit._socksColor != -1)? cKit._socksColor : kitXML._socksColor;
				customKitColours[3] = (cKit._shoesColor != -1)? cKit._shoesColor : kitXML._shoesColor;
				customKitColours[4] = (cKit._skinColor != -1)? cKit._skinColor : kitXML._skinColor;
			}
			updateCheckBoxes();
			
			var c_shirt_color:ColorTransform = new ColorTransform();
			var c_bottoms_color:ColorTransform = new ColorTransform();
			var c_socks_color:ColorTransform = new ColorTransform();
			var c_shoes_color:ColorTransform = new ColorTransform();
			var c_skin_color:ColorTransform = new ColorTransform();
			//var hair_color:ColorTransform = new ColorTransform();
				
			c_shirt_color.color = customKitColours[0];
			c_bottoms_color.color = customKitColours[1];
			c_socks_color.color = customKitColours[2];
			c_shoes_color.color = customKitColours[3];
			c_skin_color.color = customKitColours[4];
			//hair_color.color = customKitColours[5];
			
			_kits_panel.player_custom_tab.customKit.kit_top.transform.colorTransform = c_shirt_color;
			_kits_panel.player_custom_tab.customKit.kit_bottom.transform.colorTransform = c_bottoms_color;
			_kits_panel.player_custom_tab.customKit.kit_socks.transform.colorTransform = c_socks_color;
			_kits_panel.player_custom_tab.customKit.kit_shoes.transform.colorTransform = c_shoes_color;
			_kits_panel.player_custom_tab.customKit.kit_skin.transform.colorTransform = c_skin_color;
			//_kits_panel.player_custom_tab.customKit.kit_hair.transform.colorTransform = hair_color;
			
			
			_kits_panel.player_custom_tab.customKit.cp_top.selectedColor = customKitColours[0];
			_kits_panel.player_custom_tab.customKit.cp_bottom.selectedColor = customKitColours[1];
			_kits_panel.player_custom_tab.customKit.cp_socks.selectedColor = customKitColours[2];
			_kits_panel.player_custom_tab.customKit.cp_shoes.selectedColor = customKitColours[3];
			_kits_panel.player_custom_tab.customKit.cp_skin.selectedColor = customKitColours[4];
			
			_kits_panel.setChildIndex(_kits_panel.player_custom_tab, 3);
			_kits_panel.setChildIndex(_kits_panel.players_actions_tab, 1);
			_kits_panel.setChildIndex(_kits_panel.players_kits_tab, 2);
			if(_ref._menu.selectedTab != accordion.MENU_1_PLAYERS) {
				_ref._menu.slider(accordion.MENU_1_PLAYERS);
			}
			
		}
		
		public function getCustomKitState():Boolean {
			return showCustomKit;
		}
		
		public function setCustomKitState(state:Boolean) {
			showCustomKit = state;
		}
		
		public function getPreviousPanel():Number {
			return previous_panel;
		}
		
		private function updateCheckBoxes():void {
			if (selectedPlayer) {
				CheckBox(_kits_panel.player_custom_tab.cbSemiTransparent).selected = selectedPlayer.transparency;
				// Set Speed Chute if Needed.
				if (selectedPlayer.hasAccessory(AccessoriesLibrary.ACCESSORY_CHUTE)) {
					CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).selected = selectedPlayer.useSpeedChute;
					CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).visible = true;
				} else {
					CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).selected = false;
					CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).visible = false;
				}
			} else {
				CheckBox(_kits_panel.player_custom_tab.cbSemiTransparent).selected = false;
				CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).selected = false;
				CheckBox(_kits_panel.player_custom_tab.cbSpeedChute).visible = false;
			}
		}
		
		private function onCheckBoxClick(e:MouseEvent):void {
			var cbName:String = e.target.name;
			var settings:Object = {};
			switch(cbName) {
				case "cbSemiTransparent":
					selectedPlayer.transparency = CheckBox(e.target).selected;
					break;
				case "cbSpeedChute":
					selectedPlayer.useSpeedChute = CheckBox(e.target).selected;
					break;
			}
		}
		
		private function resetScroll():void {
			ScrollPane(_kits_panel.players_actions_tab.players_scroller).verticalScrollPosition = 0;
			ScrollPane(_kits_panel.players_actions_tab.players_scroller).update();
		}
		
		private function setMenuToScroll(newSource:MovieClip):void {
			_kits_panel.players_actions_tab.players_scroller.source = newSource;
			lastScrollItem = 0;
			aScrollItems = [];
			
			// Get scroll items from current source.
			var tf:TextField; // Stores the list header text field.
			var tfName:String;
			for(var i=0; i<newSource.numChildren; i++) {
				tf = newSource.getChildAt(i) as TextField;
				if (tf != null) {
					// Player names can have this format: "player###", "keeper###", "referee###, header###"
					tfName = tf.name.substr(0,tf.name.length - SSPSettings.namesDigits); // Get all but 3 last digits.
					if (tfName == MCPlayer.NAME_LIST_HEADER) {
						aScrollItems.push(tf);
					}
				}
			}
			aScrollItems.sortOn(["name"]); // Sort movie clips by name.
		}
		
		private function scrollLoop(event:MouseEvent):void {
			if (aScrollItems.length == 0) return;
			var newItem:uint = (lastScrollItem+1 >= aScrollItems.length)? 0 : lastScrollItem+1;
			ScrollPane(_kits_panel.players_actions_tab.players_scroller).verticalScrollPosition = aScrollItems[newItem].y;
			ScrollPane(_kits_panel.players_actions_tab.players_scroller).update();
			lastScrollItem = newItem;
		}
	}
}