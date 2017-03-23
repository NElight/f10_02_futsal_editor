package
{
	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import src3d.ButtonSettings;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.lines.LineLibrary;
	import src.buttons.SSPButtonBase;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	
	public class lines extends MovieClip
	{
	
		private var _ref:main;
		private var _acc:MovieClip;
		private var _acclines:MovieClip;
		private var selected_button:MovieClip;
		private var linesHelp:Array = [];
		private var selectedHelp:String = "";
		private var line_edit:MovieClip;
		
		private var aLineButtons:Array = LineLibrary.aLineButtons;
		private var lines_library:Array = [];
		private var initial_lines_library:Array = [];
		private var line_settings:Object = new Object;
		private var sport:String = SSPSettings._tagSportName; // Sport name used in language tags for lines.
		
		private var default_lines_help:String = "";
		private var line_colour:ColorPicker;
		private var bf:BlurFilter;
		private var _line_list:MovieClip;
		private var linesTotal:int; // From <initial_lines_library> in global_data xml.
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		// 3D Toolbar Buttons.
		protected var _btnSettingsVector = new Vector.<ButtonSettings>();
		
		public function lines(ref:main, acc:MovieClip) {
		
			_ref = ref;
			_acc = acc.panel3; // Get panel3 from mc_accordion.
			
			checkAndFixLinesList();
			
			_line_list = new mc_line_list();
			addChild(_line_list);
			_acc.line_scroller.source = _line_list;
			_acclines = _acc.line_scroller.content;
			
			//Add reset lines listener
			_acc.btn_line_reset.button.addEventListener(MouseEvent.MOUSE_DOWN, reset_lines);
			_acc.btn_line_reset.button.addEventListener(MouseEvent.MOUSE_OVER, reset_lines_hover);
			_acc.btn_line_reset.button.addEventListener(MouseEvent.MOUSE_OUT, reset_lines_out);
			
			//Store Defaults
			//store_initial_lines_library();
			
			bf = new BlurFilter(2,2,1);
			
			//Get session line styles
			var line_styles:XMLList = sG.sessionDataXML.session.lines_library;
			var strLineId:String;
			var line_style:XMLList;
			var lineName:String;
			var line_attributes:Object;
			for (var i:int = 0; i < aLineButtons.length; i++) {
				lineName = aLineButtons[i].name;
				strLineId = String(aLineButtons[i].id);
				line_style = line_styles.(_linesLibraryId == strLineId);
				if (!line_style || line_style.length() == 0) {
					Logger.getInstance().addText("Error loading lines_library settings (_linesLibraryId "+strLineId+").", true);
					break;
				}
				line_attributes = new Object();
				line_attributes["_lineName"] = lineName;
				line_attributes["_arrowThickness"] = line_style._arrowThickness;
				line_attributes["_lineStyle"] = line_style._lineStyle;
				line_attributes["_lineColor"] = line_style._lineColor;
				line_attributes["_lineThickness"] = line_style._lineThickness;
				line_attributes["_lineType"] = line_style._lineType;
				line_attributes["_linesLibraryId"] = line_style._linesLibraryId;
				line_attributes["_useArrowHead"] = line_style._useArrowHead;
				lines_library[i] = line_attributes;
				
				//Grids doesn't have settings button.
				if (lineName == "grid") {
					_acclines["btn_line_" + lineName].edit.enabled = false;
					_acclines["btn_line_" + lineName].edit.visible = false;
				}
				
				//Set up event listeners
				_acclines["btn_line_" + lineName].edit.addEventListener(MouseEvent.CLICK, show_edit_options);
				_acclines["btn_line_" + lineName].button.addEventListener(MouseEvent.MOUSE_OVER, button_hover);
				_acclines["btn_line_" + lineName].button.addEventListener(MouseEvent.MOUSE_OUT, button_out);
				_acclines["btn_line_" + lineName].button.addEventListener(MouseEvent.CLICK, button_click);
				_acclines["btn_line_" + lineName].button.addEventListener(MouseEvent.MOUSE_DOWN, button_down);
				
				//Add language tag
				_acclines["btn_line_" + lineName].line_title.text = sG.interfaceLanguageDataXML.menu[0]["_"+sport+"_lines_" + lineName].text();
				_acclines["btn_line_" + lineName].line_title.autoSize = TextFieldAutoSize.CENTER;
				_acclines["btn_line_" + lineName].line_title.y = 17 - (_acclines["btn_line_" + lineName].line_title.height * 0.5);
				
				// Add Context Menu.
				addContextMenuItems(_acclines["btn_line_" + lineName]);
				
				//Turn all line elements off
				hide_elements(_acclines["btn_line_" + lineName].line);
				
				//Turn relevant line elements on
				turn_elements_on(i,line_attributes["_lineStyle"],line_attributes["_lineType"],line_attributes["_lineThickness"],line_attributes["_useArrowHead"],line_attributes["_arrowThickness"]);
				
				//Change colors
				change_line_color(_acclines["btn_line_" + lineName].line,line_attributes["_lineColor"]);
				
				//Add help tag
				linesHelp["_"+sport+"_lines_help_" + lineName] = sG.interfaceLanguageDataXML.menu[0]["_"+sport+"_lines_help_" + lineName].text();
				//i++;
				
				// Deselect buttons.
				sspEventDispatcher.addEventListener(SSPEvent.LINE_CREATE_FINISHED, onLineCreateFinished, false, 0, true);
			}

			//Add default line help
			default_lines_help = sG.interfaceLanguageDataXML.menu[0]._lines_help_click.text();
			_acc.help_text.text = default_lines_help;
			_acc.btn_line_reset.button_label.text = sG.interfaceLanguageDataXML.buttons[0]._btnLinesReset.text();
			
		}
		
		private function get_line_styles():void {
			//Get session line styles
			var line_styles:XMLList = sG.sessionDataXML.session.lines_library;
			var strLineId:String;
			var line_style:XMLList;
			var lineName:String;
			var line_attributes:Object;
			for (var i:int = 0; i < aLineButtons.length; i++) {
				lineName = aLineButtons[i].name;
				strLineId = String(aLineButtons[i].id);
				line_style = line_styles.(_linesLibraryId == strLineId);
				if (!line_style || line_style.length() == 0) {
					Logger.getInstance().addText("Error loading lines_library settings (_linesLibraryId "+strLineId+").", true);
					break;
				}
				line_attributes = new Object();
				line_attributes["_lineName"] = lineName;
				line_attributes["_arrowThickness"] = line_style._arrowThickness;
				line_attributes["_lineStyle"] = line_style._lineStyle;
				line_attributes["_lineColor"] = line_style._lineColor;
				line_attributes["_lineThickness"] = line_style._lineThickness;
				line_attributes["_lineType"] = line_style._lineType;
				line_attributes["_linesLibraryId"] = line_style._linesLibraryId;
				line_attributes["_useArrowHead"] = line_style._useArrowHead;
				lines_library[i] = line_attributes;
			}
		}
		
		private function reset_lines_hover(event:MouseEvent):void {
			event.target.parent.gotoAndStop(2);
		}
		private function reset_lines_out(event:MouseEvent):void {
			event.target.parent.gotoAndStop(1);
		}
		
		//Function to store initial lines library
		/*private function store_initial_lines_library() {
			var iline_styles:XMLList = sG.menuDataXML.meta_data[0].initial_lines_library;
			var strLineId:String;
			var iline_style:XMLList;
			var lineName:String
			for (var i:int = 0; i < aLineButtons.length; i++) {
				lineName = aLineButtons[i].name;
				strLineId = String(aLineButtons[i].id);
				iline_style = iline_styles.(@_linesLibraryId == strLineId);
				if (!iline_style || iline_style.length() == 0) {
					Logger.getInstance().addText("Error loading initial_lines_library settings (_linesLibraryId "+strLineId+").", true);
					break;
				}
				var iline_attributes:Object = new Object();
				iline_attributes["_lineName"] = lineName;
				iline_attributes["_arrowThickness"] = iline_style.attribute("_arrowThickness");
				iline_attributes["_lineStyle"] = iline_style.attribute("_lineStyle");
				iline_attributes["_lineColor"] = iline_style.attribute("_lineColor");
				iline_attributes["_lineThickness"] = iline_style.attribute("_lineThickness");
				iline_attributes["_lineType"] = iline_style.attribute("_lineType");
				iline_attributes["_linesLibraryId"] = iline_style.attribute("_linesLibraryId");
				iline_attributes["_useArrowHead"] = iline_style.attribute("_useArrowHead");
				initial_lines_library[i] = iline_attributes;
			}
		}*/
		
		//Function to turn all line elements off
		private function hide_elements(element:MovieClip) {
			for (var x:int = 0; x < element.numChildren; x++) {
				element.getChildAt(x).visible = false;
			}
		}
		
		//Function to turn individual line elements on
		private function turn_elements_on(i:int, line_style, line_type, line_thickness, use_arrow:int, arrow_thickness) {
			var lineName = aLineButtons[i].name;
			var arrow_left:MovieClip;
			var arrow_right:MovieClip;
			var arrow_left_shadow:MovieClip;
			var arrow_right_shadow:MovieClip;
			
			_acclines["btn_line_" + lineName].line["line_" + line_style + "_" + line_type + "_" + line_thickness].visible = true;
			_acclines["btn_line_" + lineName].line["line_" + line_style + "_" + line_type + "_" + line_thickness + "_shadow"].visible = true;
			
			if(line_type == 3 || line_type == 4) {
				arrow_left = _acclines["btn_line_" + lineName].line["arrow_left_" + arrow_thickness + "_" + line_type];
				arrow_right = _acclines["btn_line_" + lineName].line["arrow_right_" + arrow_thickness + "_" + line_type];
				arrow_left_shadow = _acclines["btn_line_" + lineName].line["arrow_left_" + arrow_thickness + "_" + line_type + "_shadow"];
				arrow_right_shadow = _acclines["btn_line_" + lineName].line["arrow_right_" + arrow_thickness + "_" + line_type + "_shadow"];
			} else {
				arrow_left = _acclines["btn_line_" + lineName].line["arrow_left_" + arrow_thickness];
				arrow_right = _acclines["btn_line_" + lineName].line["arrow_right_" + arrow_thickness];
				arrow_left_shadow = _acclines["btn_line_" + lineName].line["arrow_left_" + arrow_thickness + "_shadow"];
				arrow_right_shadow = _acclines["btn_line_" + lineName].line["arrow_right_" + arrow_thickness + "_shadow"];
			}
			
			switch(use_arrow) {
				case 3:
					arrow_left.visible = true;
					arrow_left_shadow.visible = true;
					arrow_right.visible = true;
					arrow_right_shadow.visible = true;

					break;
				case 1:
					arrow_right.visible = true;
					arrow_right_shadow.visible = true;

					break;
			}
		}
		
		//Function to change the colour of line elements
		private function change_line_color(line:MovieClip,new_color) {
			for (var x:int = 0; x < line.numChildren; x++) {
				var line_element = line.getChildAt(x);
				if(line_element.name.search("_shadow") == -1) {
					var line_colour:ColorTransform = line_element.transform.colorTransform;
					line_colour.color = new_color;
					line_element.transform.colorTransform = line_colour;
				} else {
					line_element.filters = [bf];
				}
			}
		}
		
		private function reset_lines(event:MouseEvent):void {
			resetLinesLibrary();
			var lineName:String;
			for (var i:int = 0; i < aLineButtons.length; i++) {
				lineName = aLineButtons[i].name;
				hide_elements(_acclines["btn_line_" + lineName].line);
				//initial_to_current(i);
				turn_elements_on(i,lines_library[i]._lineStyle,lines_library[i]._lineType,lines_library[i]._lineThickness,lines_library[i]._useArrowHead,lines_library[i]._arrowThickness);
				change_line_color(_acclines["btn_line_" + lineName].line,lines_library[i]._lineColor);
				// Update 3D Lines.
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.LINE_UPDATE_DEFAULT_SETTINGS,lines_library[i]._linesLibraryId));
			}
		}
		
		/*private function initial_to_current(i:int) {
			lines_library[i]._lineName = initial_lines_library[i]._lineName;
			lines_library[i]._arrowThickness = initial_lines_library[i]._arrowThickness;
			lines_library[i]._lineStyle = initial_lines_library[i]._lineStyle;
			lines_library[i]._lineColor = initial_lines_library[i]._lineColor;
			lines_library[i]._lineThickness = initial_lines_library[i]._lineThickness;
			lines_library[i]._lineType = initial_lines_library[i]._lineType;
			lines_library[i]._linesLibraryId = initial_lines_library[i]._linesLibraryId;
			lines_library[i]._useArrowHead = initial_lines_library[i]._useArrowHead;
			
			// Update XML.
			var initialLinesLibraryXML:XMLList;
			var linesLibraryXML:XMLList;
			var lineIdStr:String = String(i+1);
			initialLinesLibraryXML = sG.menuDataXML.meta_data.initial_lines_library.(@_linesLibraryId == lineIdStr);
			linesLibraryXML = sG.sessionDataXML.session.lines_library.(_linesLibraryId == lineIdStr);
			linesLibraryXML._arrowThickness = initialLinesLibraryXML.@_arrowThickness;
			linesLibraryXML._lineStyle = initialLinesLibraryXML.@_lineStyle;
			linesLibraryXML._lineColor = initialLinesLibraryXML.@_lineColor;
			linesLibraryXML._lineThickness = initialLinesLibraryXML.@_lineThickness;
			linesLibraryXML._lineType = initialLinesLibraryXML.@_lineType;
			linesLibraryXML._useArrowHead = initialLinesLibraryXML.@_useArrowHead;
		}*/
		
		private function resetLinesLibrary():void {
			var initialLinesLibraryXML:XMLList;
			var linesLibraryXML:XMLList;
			var tmpXML:XML;
			var atName:String;
			
			// First compare user and initial lines data length.
			initialLinesLibraryXML = sG.menuDataXML.meta_data.initial_lines_library;
			linesLibraryXML = sG.sessionDataXML.session.lines_library;
			
			var lLLength:uint = linesLibraryXML.length(); // Lines Library Length.
			var iLLLength:uint = initialLinesLibraryXML.length(); // Initial Lines Library Length.
			
			if (iLLLength == 0) {
				Logger.getInstance().addText("no <initial_lines_library> found.", true);
			}
			
			if (lLLength != iLLLength) {
				Logger.getInstance().addText("(A) - lines_library length ("+lLLength+") doesn't match initial_lines_library length ("+iLLLength+").", false);
			}
			
			// Remove <lines_library> from Session Data.
			delete sG.sessionDataXML.session.lines_library;
			
			// Create new <lines_library>'s from Global Data.
			for (var i:uint = 0;i<iLLLength;i++) {
				tmpXML = new XML(<lines_library/>);
				for each (var at:XML in initialLinesLibraryXML[i].attributes()) {
					atName = at.name();
					tmpXML.appendChild( new XML("<" + atName + "/>") );
					tmpXML.elements(atName)[0] = at.toString();
				}
				sG.sessionDataXML.session.appendChild(tmpXML);
			}
			
			// Update styles array.
			get_line_styles();
		}
		
		private function button_hover(event:MouseEvent):void {
			var lineButton = event.target.parent;
			lineButton.gotoAndStop(2);
		}
		
		private function button_out(event:MouseEvent):void {
			var lineButton = event.target.parent;
			lineButton.gotoAndStop(1);
		}
		
		private function button_down(event:MouseEvent):void {
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, null));
		}
		
		private function button_click(event:MouseEvent):void {
			startDrawing(event.target.parent, false);
		}
		
		private function startDrawing(btn:MovieClip, multi:Boolean):void {
			trace("startDrawing(). Button: "+btn.name+". Multi: "+multi);
			resetLineButtons();
			selected_button = btn;
			
			var lId:int = -1;
			var btnName:String = selected_button.name;
			var lineName:String = btnName.substr("btn_line_".length);
			var idx:int = MiscUtils.indexInArray(aLineButtons, "name", lineName);
			if (idx == -1) {
				Logger.getInstance().addText("Lines.startDrawing(). Can't resolve line id for '"+lineName+".", true);
				return;
			}
			lId = aLineButtons[idx].id;
			
			// Setup line button.
			selected_button.gotoAndStop(3);
			selected_button.button.removeEventListener(MouseEvent.MOUSE_OVER, button_hover);
			selected_button.button.removeEventListener(MouseEvent.MOUSE_OUT, button_out);
			showHelp(selected_button.name);
			// Show the 3D Toolbar button.
			toggle3DButton(true);

			// Sends the event including the lineID and if multiple lines will be drawn.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_LINE, {lineId:lId, multiple:multi}));
		}
		
		private function resetLineButtons():void {
			if(selected_button != null) {
				selected_button.button.addEventListener(MouseEvent.MOUSE_OVER, button_hover);
				selected_button.button.addEventListener(MouseEvent.MOUSE_OUT, button_out);
				//selected_button = null;
			}
			var lineName:String;
			for (var i:int = 0; i < aLineButtons.length; i++) {
				lineName = aLineButtons[i].name;
				_acclines["btn_line_" + lineName].gotoAndStop(1);
			}
		}
		
		private function showHelp(button:String) {
			if (!linesHelp) return;
			var lineName:String = button.substr("btn_line_".length);
			//if (lineName.indexOf("custom") == 0) lineName = lineName.substr(0,"custom".length-1);
			if (lineName != "line" && lineName.indexOf("line") == 0) lineName = "line";
			var tagName:String = "_"+sport+"_lines_help_" + lineName;
			_acc.help_text.text = (linesHelp[tagName])? linesHelp[tagName] : "";
		}
		
		private function show_edit_options(event:MouseEvent) {

			var line:String = event.target.parent.name;
			var line_name:String = event.target.parent.line_title.text;
			
			var line_bits:Array = line.split("_");
			line = line_bits[line_bits.length-1];
			get_line_settings(line);
			
			//Configure popup
			line_edit = new mc_line_popup();
			line_edit.name = "line_edit_popup";
			line_edit.line_name.text = line_name;
			line_edit.btn_lines_cancel.addEventListener(MouseEvent.CLICK, clear_line_settings);
			line_edit.btn_lines_save.addEventListener(MouseEvent.CLICK, save_line_settings);
			
			// Set labels.
			line_edit.editLineAppearanceLabel.text = sG.interfaceLanguageDataXML.titles[0]._titleEditLineAppearance.text();
			line_edit.lineNameLabel.text = sG.interfaceLanguageDataXML.titles[0]._titleLineName.text();
			line_edit.lineColourLabel.text = sG.interfaceLanguageDataXML.titles[0].	_titleLineColour.text();
			line_edit.lineWidthLabel.text = sG.interfaceLanguageDataXML.titles[0]._titleLineWidth.text();
			line_edit.arrowheadSizeLabel.text = sG.interfaceLanguageDataXML.titles[0]._titleArrowheadSize.text();
			line_edit.arrowheadPositionLabel.text = sG.interfaceLanguageDataXML.titles[0]._titleArrowheadPosition.text();
			line_edit.btn_lines_cancel.label = sG.interfaceLanguageDataXML.buttons[0]._btnInterfaceCancel.text();
			line_edit.btn_lines_save.label = sG.interfaceLanguageDataXML.buttons[0]._btnInterfaceSave.text();
			
			//Hide Dropdowns
			line_edit.line_width_dropdown.visible = false;
			line_edit.arrow_size_dropdown.visible = false;
			line_edit.arrow_pos_dropdown.visible = false;
			
			//Disable Mouse for selected lines
			line_edit.chosen_line_width.mouseEnabled = false;
			line_edit.chosen_arrow_pos.mouseEnabled = false;
			line_edit.chosen_arrow_size.mouseEnabled = false;
			line_edit.chosen_line_width.mouseChildren = false;
			line_edit.chosen_arrow_pos.mouseChildren = false;
			line_edit.chosen_arrow_size.mouseChildren = false;

			//Hide selected line attributes
			hide_elements(line_edit.chosen_line_width);
			hide_elements(line_edit.chosen_arrow_pos);
			hide_elements(line_edit.chosen_arrow_size);
			
			//Show correct line attributes
			line_edit.chosen_line_width["line_width_" + line_settings["_lineThickness"]].visible = true;
			line_edit.chosen_arrow_pos["arrow_pos_" + line_settings["_useArrowHead"]].visible = true;
			line_edit.chosen_arrow_size["arrow_size_" + line_settings["_arrowThickness"]].visible = true;
			
			//Add pop up listeners
			line_edit.line_width_selector.addEventListener(MouseEvent.MOUSE_UP, choose_line_width);
			line_edit.arrow_size_selector.addEventListener(MouseEvent.MOUSE_UP, choose_arrow_size);
			line_edit.arrow_pos_selector.addEventListener(MouseEvent.MOUSE_UP, choose_arrow_pos);
			line_edit.line_popup_container.addEventListener(MouseEvent.MOUSE_UP, hide_edit_options);
			
			line_colour = new ColorPicker();
			line_colour.editable = true;
			line_colour.move(385,162);
			line_colour.selectedColor = line_settings["_lineColor"];
			line_edit.addEventListener(ColorPickerEvent.CHANGE, update_line_colour);
			line_edit.addChild(line_colour);

			//Add to screen
			line_edit.x = 0;
			line_edit.y = 0;
			_ref._mainContainer.addChild(line_edit);
			_ref.bringMainContainerToFront(); // Place _main_container on top of _session_view.
			
		}
		
		//Function that takes chosen line attributes and maps them to the temporary line_settings array
		private function get_line_settings(lineName:String) {
			var idx:int = MiscUtils.indexInArray(aLineButtons, "name", lineName);
			// Note that line_settings length and sort order matches LinesLibrary.aLineButtons.
			line_settings["_index"] = idx;
			line_settings["_arrowThickness"] = lines_library[idx]._arrowThickness;
			line_settings["_lineStyle"] = lines_library[idx]._lineStyle;
			line_settings["_lineColor"] = lines_library[idx]._lineColor;
			line_settings["_lineThickness"] = lines_library[idx]._lineThickness;
			line_settings["_lineType"] = lines_library[idx]._lineType;
			line_settings["_linesLibraryId"] = lines_library[idx]._linesLibraryId;
			line_settings["_useArrowHead"] = lines_library[idx]._useArrowHead;
		}
		
		private function clear_line_settings(event:MouseEvent):void {
			line_settings = new Object();
			_ref._mainContainer.removeChild(line_edit);
			_ref.stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide_edit_options);
		}
		
		private function save_line_settings(event:MouseEvent):void {
			var i:int = line_settings["_index"];
			lines_library[i]._arrowThickness = line_settings["_arrowThickness"];
			lines_library[i]._lineStyle = line_settings["_lineStyle"];
			lines_library[i]._lineColor = line_settings["_lineColor"];
			lines_library[i]._lineThickness = line_settings["_lineThickness"];
			lines_library[i]._lineType = line_settings["_lineType"];
			lines_library[i]._linesLibraryId = line_settings["_linesLibraryId"];
			lines_library[i]._useArrowHead = line_settings["_useArrowHead"];
			
			var lineName = aLineButtons[i].name;
			hide_elements(_acclines["btn_line_" + lineName].line);
			turn_elements_on(i,lines_library[i]._lineStyle,lines_library[i]._lineType,lines_library[i]._lineThickness,lines_library[i]._useArrowHead,lines_library[i]._arrowThickness);
			change_line_color(_acclines["btn_line_" + lineName].line,lines_library[i]._lineColor);
			
			_ref._mainContainer.removeChild(line_edit);
			_ref.stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide_edit_options);
			
			// Store current user default settings on XML.
			var linesLibraryXML:XMLList = sG.sessionDataXML.session.lines_library.(_linesLibraryId == lines_library[i]._linesLibraryId);
			linesLibraryXML._arrowThickness = String(lines_library[i]._arrowThickness);
			linesLibraryXML._lineStyle = String(lines_library[i]._lineStyle);
			linesLibraryXML._lineColor = String(lines_library[i]._lineColor);
			linesLibraryXML._lineThickness = String(lines_library[i]._lineThickness);
			linesLibraryXML._lineType = String(lines_library[i]._lineType);
			linesLibraryXML._useArrowHead = String(lines_library[i]._useArrowHead);
			
			// Update 3D Lines.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.LINE_UPDATE_DEFAULT_SETTINGS,lines_library[i]._linesLibraryId));

		}

		
		private function hide_edit_options(event:MouseEvent):void {
			_ref._mainContainer.removeChild(line_edit);
			_ref.stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide_edit_options);
		}																																																																																																																																																																																															
		
		private function choose_line_width(event:MouseEvent) {
			line_edit.line_width_dropdown.visible = true;
			line_edit.line_width_dropdown.addEventListener(MouseEvent.MOUSE_UP, update_line_width);
			line_edit.addEventListener(MouseEvent.MOUSE_DOWN,hide_line_width);

		}

		private function hide_line_width(event:MouseEvent) {
			if(event.target.parent.name != "line_width_dropdown") {
				line_edit.line_width_dropdown.visible = false;
				line_edit.removeEventListener(MouseEvent.MOUSE_DOWN,hide_line_width);
			}
			
		}
		
		private function update_line_width(event:MouseEvent) {
			
			line_edit.line_width_dropdown.visible = false;
			line_edit.line_width_dropdown.removeEventListener(MouseEvent.MOUSE_UP, update_line_width);
			
			hide_elements(line_edit.chosen_line_width);
			
			var line_width:String = event.target.name;
			var line_bits:Array = line_width.split("_");
			line_width = line_bits[line_bits.length-1];

			line_edit.chosen_line_width["line_width_" + line_width].visible = true;
			line_settings["_lineThickness"] = line_width;
			
		}
		
		private function choose_arrow_size(event:MouseEvent) {
			line_edit.arrow_size_dropdown.visible = true;
			line_edit.arrow_size_dropdown.addEventListener(MouseEvent.MOUSE_UP, update_arrow_size);
			line_edit.addEventListener(MouseEvent.MOUSE_DOWN,hide_arrow_size);

		}

		private function hide_arrow_size(event:MouseEvent) {
			if(event.target.parent.name != "arrow_size_dropdown") {
				line_edit.arrow_size_dropdown.visible = false;
				line_edit.removeEventListener(MouseEvent.MOUSE_DOWN,hide_arrow_size);
			}
			
		}
		
		private function update_arrow_size(event:MouseEvent) {
			line_edit.arrow_size_dropdown.visible = false;
			line_edit.arrow_size_dropdown.removeEventListener(MouseEvent.MOUSE_UP, update_arrow_size);
			
			hide_elements(line_edit.chosen_arrow_size);

			var arrow_size:String = event.target.name;
			var line_bits:Array = arrow_size.split("_");
			arrow_size = line_bits[line_bits.length-1];
			
			line_edit.chosen_arrow_size["arrow_size_" + arrow_size].visible = true;
			line_settings["_arrowThickness"] = arrow_size;
			
		}
		
		private function choose_arrow_pos(event:MouseEvent) {
			line_edit.arrow_pos_dropdown.visible = true;
			line_edit.arrow_pos_dropdown.addEventListener(MouseEvent.MOUSE_DOWN, update_arrow_pos);
			line_edit.addEventListener(MouseEvent.MOUSE_DOWN,hide_arrow_pos);

		}

		private function hide_arrow_pos(event:MouseEvent) {
			if(event.target.parent.name != "arrow_pos_dropdown") {
				line_edit.arrow_pos_dropdown.visible = false;
				line_edit.removeEventListener(MouseEvent.MOUSE_DOWN,hide_arrow_pos);
			}
			
		}
		
		
		private function update_arrow_pos(event:MouseEvent) {
			
			line_edit.arrow_pos_dropdown.visible = false;
			line_edit.arrow_pos_dropdown.removeEventListener(MouseEvent.MOUSE_UP, update_arrow_pos);
			
			hide_elements(line_edit.chosen_arrow_pos);
			
			var arrow_pos:String = event.target.name;
			var line_bits:Array = arrow_pos.split("_");
			arrow_pos = line_bits[line_bits.length-1];
			
			line_edit.chosen_arrow_pos["arrow_pos_" + arrow_pos].visible = true;
			line_settings["_useArrowHead"] = arrow_pos;	
			
		}
		
		private function update_line_colour(event:ColorPickerEvent):void {
			var lc:String = "0x" + line_colour.hexValue;
			line_settings["_lineColor"] = lc;	
		}
		
		/**
		 * If the session <library_settings> is incomplete (because it's an old saved session 
		 * that doesn't include the new lines), get <library_settings> data from global_data.xml.
		 * Note: Not implementable in viewer.
		 */		
		private function checkAndFixLinesList():void {
			// Get session line styles.
			var line_styles:XMLList = sG.sessionDataXML.session.lines_library;
			// Get total lines from global library.
			var initial_line_styles:XMLList = sG.menuDataXML.meta_data[0].initial_lines_library;
			var dd:XMLList;
			// Check we have the right amount of data. Some old saved session could have new lines missing.
			if (line_styles.length() != initial_line_styles.length()) {
				var newNode:XML;
				var lineIdStr:String;
				// Get the missing lines from global data xml.
				for (var i:int=0;i<initial_line_styles.length();i++) {
					lineIdStr = initial_line_styles[i].@_linesLibraryId;
					dd = line_styles.(_linesLibraryId == lineIdStr);
					if (line_styles.(_linesLibraryId == lineIdStr).length() == 0) {
						// Pass attributes to nodes.
						newNode = new XML(<lines_library/>);
						newNode._linesLibraryId = initial_line_styles[i].@_linesLibraryId;
						newNode._lineStyle 		= initial_line_styles[i].@_lineStyle;
						newNode._lineType 		= initial_line_styles[i].@_lineType;
						newNode._lineColor 		= initial_line_styles[i].@_lineColor;
						newNode._useArrowHead 	= initial_line_styles[i].@_useArrowHead;
						newNode._lineThickness 	= initial_line_styles[i].@_lineThickness;
						newNode._arrowThickness = initial_line_styles[i].@_arrowThickness;
						newNode._useHandles 	= initial_line_styles[i].@_useHandles;
						sG.sessionDataXML.session.appendChild(newNode);
					} else {
						Logger.getInstance().addText("(A) - Can't get line styles", false);
					}
				}
			}
			
			// Store total lines.
			linesTotal = sG.sessionDataXML.session.lines_library.length();
		}
		
		private function onLineCreateFinished(e:SSPEvent):void {
			trace("onLineCreateFinished()");
			// Hide the 3D Toolbar button.
			toggle3DButton(false);
			resetLineButtons();
		}
		
		private function onMultiLineDrawing(e:SSPEvent):void {
			trace("onMultiLineDrawing(): "+e.eventData);
			startMultiDraw(e.eventData);
		}
		
		private function startMultiDraw(multi:Boolean):void {
			trace("startMultiDraw(): "+multi);
			// Re-dispatch the last drawing event.
			if (selected_button && multi == true) {
				//SSPButtonBase(_ref._controls._controls.ctrl_item_pin).buttonSelected = true;
				startDrawing(selected_button, multi);
			}
			if (!multi) {
				// Hide the 3D Toolbar button.
				toggle3DButton(false);
				resetLineButtons();
			}
		}
		
		/**
		 * Shows/Hide the 'pin' button in the 3D toolbar. 
		 */		
		private function toggle3DButton(show:Boolean):void {
			trace("toggle3DButton(): "+show);
			if (show) {
				SSPButtonBase(_ref._controls._controls.ctrl_item_pin).buttonEnabled = true;
				// Check if pin button is pressed in the 3D Toolbar.
				sspEventDispatcher.addEventListener(SSPEvent.LINE_CREATE_BY_PINNING, onMultiLineDrawing, false, 0, true);
			} else {
				sspEventDispatcher.removeEventListener(SSPEvent.LINE_CREATE_BY_PINNING, onMultiLineDrawing);
				// Hide all 3D buttons.
//				SSPButtonBase(_ref._controls._controls.ctrl_item_pin).buttonEnabled = false;
				//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_CANCEL,""));
			}
		}
		
		private function addContextMenuItems(target:DisplayObjectContainer):void {
			var pinToCursorLabelStr:String = sG.interfaceLanguageDataXML.menu[0]._rclickPinToCursor.text();
			if (pinToCursorLabelStr == "") pinToCursorLabelStr = "Pin to Cursor";
			var cMenu:ContextMenu = new ContextMenu();
			var pinToCursor:ContextMenuItem = new ContextMenuItem(pinToCursorLabelStr);
			//cloneScreenOptions = new ContextMenuItem("Clone Screen with Options");
			
			pinToCursor.separatorBefore = true;
			pinToCursor.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onPinToCursor, false, 0, true);
			
			cMenu.hideBuiltInItems();
			cMenu.customItems = [pinToCursor];
			
			target.contextMenu = cMenu;
		}
		private function onPinToCursor(e:ContextMenuEvent):void {
			selected_button = MovieClip(e.mouseTarget.parent);
			startMultiDraw(true);
		}
	}
}