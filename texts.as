package
{
	import fl.controls.Button;
	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.text.MCTextCustom;
	import src3d.text.TextLibrary;
	import src3d.text.TextSettings;

	public class texts extends MovieClip
	{
		
		private var _ref:main;
		private var _texts_panel:MovieClip
		private var _popupBox:MovieClip;
		
		// Text Field.
		private var tf1:TextField;
		private var tf2:TextField;
		private var tform1:TextFormat = new TextFormat();
		private var tform2:TextFormat = new TextFormat();
		private var prevText1:String = "";
		private var prevText2:String = "";
		private var prevTextSizeId1:uint = 1;
		private var prevTextSizeId2:uint = 1;
		private var textSizes:int = 2; // Amount of available text sizes. 0 = Small, 1 = Medium, 2 = Big.
		
		// Text Style Settings.
		private var ts:TextSettings = new TextSettings();

		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var _sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		public function texts(acc:MovieClip, ref:main) {
			_ref = ref;
			
			//Add kits panel movieclip
			_texts_panel = new mc_texts_panel();
			_texts_panel.x 			= 0;
			_texts_panel.y 			= 0;
			acc.panel4.addChild(_texts_panel);
			
			// Add tags.
			_texts_panel.btn_edit.label = sG.interfaceLanguageDataXML.menu[0]._menuBtnEditText.text();
			_texts_panel.txtDragOntoPitch.text = sG.interfaceLanguageDataXML.menu[0]._menuTextDragOntoPitch.text();
			
			// Set up event listeners
			_texts_panel.btn_edit.addEventListener(MouseEvent.CLICK, onShowEditOptions);
			
			// Set popup box reference.
			_popupBox = new mc_text_popup();
			_popupBox.name = "line_text_popup";
			
			// Init Text Formats.
			tform1 = new TextFormat();
			tform1.size = TextLibrary.getFontSizeFromId(TextLibrary.FONT_SIZE_ID_MEDIUM);
			tform2 = new TextFormat();
			tform2.size = tform1.size;
			
			// Set up popup text fields.
			tf1 = _popupBox.txtContent;
			tf1.defaultTextFormat = tform1;
			tf1.addEventListener(Event.CHANGE, onTextFieldUpdate);
			tf2 = _popupBox.txtContent2;
			tf2.defaultTextFormat = tform2;
			tf2.addEventListener(Event.CHANGE, onTextFieldUpdate);
			
			// Set up text panel.
			MCTextCustom(_texts_panel.customText).txtField1.defaultTextFormat = tform1;
			MCTextCustom(_texts_panel.customText).txtField2.defaultTextFormat = tform2;
		}
		
		private function startListeners():void {
			// Set Listeners.
			_popupBox.btn_cancel.addEventListener(MouseEvent.CLICK, onCancel);
			_popupBox.btn_save.addEventListener(MouseEvent.CLICK, onSave);
			_popupBox.colorPicker1.addEventListener (ColorPickerEvent.CHANGE, onColorChange);
			_popupBox.colorPicker2.addEventListener (ColorPickerEvent.CHANGE, onColorChange);
			_popupBox.btnBold1.addEventListener(MouseEvent.CLICK, onBoldChange);
			_popupBox.btnBold2.addEventListener(MouseEvent.CLICK, onBoldChange);
			_popupBox.btnTextSize1.addEventListener(MouseEvent.CLICK, onTextChange);
			_popupBox.btnTextSize2.addEventListener(MouseEvent.CLICK, onTextChange);
		}
		
		private function stopListeners():void {
			// Remove Listeners.
			_popupBox.btn_cancel.removeEventListener(MouseEvent.CLICK, onCancel);
			_popupBox.btn_save.removeEventListener(MouseEvent.CLICK, onSave);
			_popupBox.colorPicker1.removeEventListener (ColorPickerEvent.CHANGE, onColorChange);
			_popupBox.colorPicker2.removeEventListener (ColorPickerEvent.CHANGE, onColorChange);
			_popupBox.btnBold1.removeEventListener(MouseEvent.CLICK, onBoldChange);
			_popupBox.btnBold2.removeEventListener(MouseEvent.CLICK, onBoldChange);
			_popupBox.btnTextSize1.removeEventListener(MouseEvent.CLICK, onTextChange);
			_popupBox.btnTextSize2.removeEventListener(MouseEvent.CLICK, onTextChange);
		}
		
		private function onShowEditOptions(event:MouseEvent) {
			_texts_panel.btn_edit.removeEventListener(MouseEvent.CLICK, onShowEditOptions);

			// Configure popup.
			var customText:MCTextCustom = MCTextCustom(_texts_panel.customText);
			_popupBox.txtContent.text = customText.txtField1.text;
			_popupBox.txtContent2.text = customText.txtField2.text;
			
			// Get TextFormats.
			tform1 = customText.txtField1.getTextFormat();
			tform2 = customText.txtField2.getTextFormat();
			
			//Add to screen
			_popupBox.x = 0;
			_popupBox.y = 0;
			_ref._mainContainer.addChild(_popupBox);
			_ref.bringMainContainerToFront(); // Place _main_container on top of _session_view.
			
			updateControls();
			
			// Start popup box listeners.
			startListeners();
		}
		
		private function updateControls():void {
			// Set Bold Buttons.
			_popupBox.btnBold1.selected = (tform1.bold != null)? tform1.bold : false;
			_popupBox.btnBold2.selected = (tform2.bold != null)? tform2.bold : false;
			// Get text size.
			prevTextSizeId1 = (tform1.size != null)? ts.getFontSizeIdFromSize(tform1.size as Number) : 1;
			prevTextSizeId2 = (tform2.size != null)? ts.getFontSizeIdFromSize(tform2.size as Number) : 1;
			// Get font color.
			ColorPicker(_popupBox.colorPicker1).selectedColor = uint(tform1.color);
			ColorPicker(_popupBox.colorPicker2).selectedColor = uint(tform2.color);
		}
		
		private function onCancel(e:MouseEvent):void {
			resetListeners();
			_popupBox.txtContent.text = "";
			_ref._mainContainer.removeChild(_popupBox);
		}
	
		private function onSave(e:MouseEvent):void {
			resetListeners();
			_ref._mainContainer.removeChild(_popupBox);
			// Update Custom Text.
			MCTextCustom(_texts_panel.customText).setTextContent(_popupBox.txtContent, _popupBox.txtContent2);
		}
		
		private function resetListeners():void {
			stopListeners();
			_texts_panel.btn_edit.addEventListener(MouseEvent.CLICK, onShowEditOptions);
		}
		
		private function onColorChange(e:ColorPickerEvent):void {
			var cp:Object = e.target;
			var selectedColor:uint = cp.selectedColor;
			var selectedColorHex:String = "0x" + cp.hexValue;
			if (cp.name == "colorPicker1") tform1.color = selectedColor;
			if (cp.name == "colorPicker2") tform2.color = selectedColor;
			applyFormats();
		}
		
		private function onBoldChange(e:MouseEvent):void {
			var btn:Button = e.target as Button;
			if (btn.selected) {
				
				if (btn.name == "btnBold1") tform1.bold = true;
				if (btn.name == "btnBold2") tform2.bold = true;
			} else {
				if (btn.name == "btnBold1") tform1.bold = false;
				if (btn.name == "btnBold2") tform2.bold = false;
			}
			applyFormats();
		}
		
		private function onTextChange(e:MouseEvent):void {
			var btn:Button = e.target as Button;
			var newFontSize:Number = 16;
			updateControls();
			if (btn.name == "btnTextSize1") {
				var newTextSizeId1:int = prevTextSizeId1+1;
				if (newTextSizeId1 > textSizes) newTextSizeId1 = 0;
				newFontSize = ts.getFontSizeFromId(newTextSizeId1);
				tform1.size = newFontSize;
				prevTextSizeId1 = newTextSizeId1;
			}
			if (btn.name == "btnTextSize2") {
				var newTextSizeId2:int = prevTextSizeId2+1;
				if (newTextSizeId2 > textSizes) newTextSizeId2 = 0;
				newFontSize = ts.getFontSizeFromId(newTextSizeId2);
				tform2.size = newFontSize;
				prevTextSizeId2 = newTextSizeId2;
			}
			applyFormats();
		}
		
		private function onTextFieldUpdate(e:Event):void {
			if (tf1.textHeight > tf1.height || tf1.textWidth > tf1.width) {
				if (prevText1 != "") {
					tf1.text = prevText1;
				} else {
					// Crop pasted text.
					fitTextInTextField(tf1);
				}
			}else {
				prevText1 = tf1.text;
			}
			if (tf2.textHeight > tf2.height || tf2.textWidth > tf2.width) {
				if (prevText2 != "") {
					tf2.text = prevText2;
				} else {
					// Crop pasted text.
					fitTextInTextField(tf2);
				}
			}else {
				prevText2 = tf2.text;
			}
		}
		
		private function fitTextInTextField(tf:TextField):void {
			// Crop pasted text.
			while ( tf.textWidth > tf.width || tf.textHeight > tf.height ) 
			{
				tf.text = tf.text.substring(0, tf.length-1);
			}
		}
		
		private function applyFormats():void {
			tf1.defaultTextFormat = tform1;
			tf2.defaultTextFormat = tform2;
			tf1.setTextFormat(tform1);
			tf2.setTextFormat(tform2);
		}
	}
}