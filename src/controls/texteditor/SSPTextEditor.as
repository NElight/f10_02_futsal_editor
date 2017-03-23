package src.controls.texteditor
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import src3d.SessionGlobals;
	
	public class SSPTextEditor extends SSPTextEditorBase
	{
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		
		protected var sBeginIdx:Number; // Selection Begin Index.
		protected var sEndIdx:Number; // Selection End Index.
		
		protected var _editorEnabled:Boolean;
		
		public var targetXML:XML;
		public var strXMLObjectName:String;
		
		public function SSPTextEditor(xPos:Number, yPos:Number, txtWidth:Number, txtHeight:Number, txtFontSize:Number,
									  txtHTMLText:String, txtMaxChars:Number, useLabel:Boolean, lblText:String = "Text", lblWidth:Number = 100,
									  lblFontSize:Number = 11, lblHeight:Number = 22
		) {
			// TODO: Tooltips.
			super(xPos, yPos, txtWidth, txtHeight, txtFontSize, txtHTMLText,
				txtMaxChars, useLabel, lblText, lblWidth, lblFontSize, lblHeight
			);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// ----------------------------- Inits ----------------------------- //
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			initTooltips();
			addEvents();
		}
		
		private function initTooltips():void {
			var lD:XML = sG.interfaceLanguageDataXML.tags[0];
			if (!lD || lD.length() == 0) return;
			btnB.setToolTipText(lD._btnBold.text());
			btnI.setToolTipText(lD._btnItalic.text());
			btnU.setToolTipText(lD._btnUnderline.text());
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		// ----------------------------- Events ----------------------------- //
		private function addEvents():void {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDownHandler);
			txtField.addEventListener(Event.CHANGE, onTextFieldChange);
			btnB.addEventListener(MouseEvent.CLICK, onBtnBoldClick);
			btnI.addEventListener(MouseEvent.CLICK, onBtnItalicClick);
			btnU.addEventListener(MouseEvent.CLICK, onBtnUnderlineClick);
		}
		
		private function removeEvents():void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDownHandler);
			txtField.removeEventListener(Event.CHANGE, onTextFieldChange);
			//txtField.removeEventListener(TextEvent.TEXT_INPUT, onTextFieldChange);
			btnB.removeEventListener(MouseEvent.CLICK, onBtnBoldClick);
			btnI.removeEventListener(MouseEvent.CLICK, onBtnItalicClick);
			btnU.removeEventListener(MouseEvent.CLICK, onBtnUnderlineClick);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		private function onBtnBoldClick(e:MouseEvent):void {
			toggleBold();
		}
		
		private function onBtnItalicClick(e:MouseEvent):void {
			toggleItalic();
		}
		
		private function onBtnUnderlineClick(e:MouseEvent):void {
			toggleUnderline();
		}
		
		private function onStageMouseDown(e:MouseEvent):void {
			var avoidObj:Object = e.target;
			
			if(avoidObj != txtField && avoidObj != btnB && avoidObj != btnI && avoidObj != btnU) {
				saveToXML();
			}
			
		}
		
		private function onStageMouseUp(e:MouseEvent):void {
			getSelection();
		}
		
		private function onTextFieldChange(event:Event):void {
			if (isNaN(sBeginIdx) || sBeginIdx < 0) sBeginIdx = txtField.selectionBeginIndex;
			sEndIdx = txtField.selectionEndIndex;
			
			if (sBeginIdx == sEndIdx) {
				sBeginIdx = txtField.caretIndex;
				sEndIdx = txtField.caretIndex;
			} else {
				//sEndIdx = txtField.text.length;
				sEndIdx = txtField.caretIndex;
			}
			
			if(sBeginIdx < sEndIdx && sEndIdx != 0) {
				setFormat();
			}
			
			getFormat();
		}
		
		private function onStageKeyUp(event:KeyboardEvent):void {
			// KeyboardEvent includes the keycode, keylocation, shiftkey and altkey.
			
			// If keys are Home, PgUp, PgDn, End, Up, Down, Left, Right.
			if (event.keyCode >= 33 && event.keyCode <= 40) {
				getSelection();
			}
			// If Backspace.
			if (event.keyCode == 8) getSelection();
			
			getFormat();
		}
		
		private function onStageMouseDownHandler(e:MouseEvent):void {
			// Enable the editor if mouse is down on 'this'.
			if (isMouseOnThis(e.stageX, e.stageY)) {
				editorEnabled = true;
			} else {
				editorEnabled = false;
			}
			// Save data if editor has been disabled.
			if (!_editorEnabled) saveToXML();
		}
		// -------------------------- End of Events ------------------------- //
		
		
		
		
		// ----------------------------- Data ----------------------------- //
		private function updateButtonsState(fstart, fend) {
			if (fend > txtField.text.length) fend = txtField.text.length;
			if (fstart == fend) return;
			
			txtFormat = txtField.getTextFormat(fstart, fend);
			btnB.buttonSelected = (txtFormat.bold)? true : false;
			btnI.buttonSelected = (txtFormat.italic)? true : false;
			btnU.buttonSelected = (txtFormat.underline)? true : false;
		}
		
		protected function saveToXML():void {
			if (targetXML) {
				// Override to save the text to an xml object.
			}
		}
		
		private function notifyChange():void {
			
		}
		
		private function isMouseOnThis(mXPos:Number, mYPos:Number):Boolean {
			var bnds:Rectangle = this.getBounds(stage);
			if (mXPos > bnds.left &&
				mXPos < bnds.right &&
				mYPos > bnds.top &&
				mYPos < bnds.bottom
			)
			{
				return true;
			}
			return false;
		}
		// -------------------------- End of Data ------------------------- //
		
		
		
		// ----------------------------- Text Format ----------------------------- //
		private function toggleBold():void {
			txtFormat.bold = (txtFormat.bold)? false : true;
			setFormat();
		}
		
		private function toggleItalic():void {
			txtFormat.italic = (txtFormat.italic)? false : true;
			setFormat();
		}
		
		private function toggleUnderline():void {
			txtFormat.underline = (txtFormat.underline)? false : true;
			setFormat();
		}
		
		private function setFormat():void {
			if (isNaN(sBeginIdx) || isNaN(sEndIdx)) return;
			
			if (txtField.length == 0) {
				TextField(txtField).setTextFormat(txtFormat);
				return;
			}
			
			if (sBeginIdx == sEndIdx) {
				sBeginIdx = TextField(txtField).caretIndex;
				return;
			}
			
			TextField(txtField).setTextFormat(txtFormat,sBeginIdx,sEndIdx);
			
		}
		
		private function getFormat():void {
			if (_editorEnabled) {
				sBeginIdx = txtField.selectionBeginIndex;
				sEndIdx = txtField.selectionEndIndex;
			}
		}
		
		private function getSelection():void {
			var oldBeginIdx:int = sBeginIdx;
			var oldEndIdx:int = sEndIdx;
			
			sBeginIdx = txtField.selectionBeginIndex;
			sEndIdx = txtField.selectionEndIndex;
			
			if (sBeginIdx > txtField.text.length) sBeginIdx = txtField.text.length;
			if (sEndIdx > txtField.text.length) sEndIdx = txtField.text.length;
			
			if(sBeginIdx == sEndIdx) {
				
				if(sBeginIdx == 0) {
					oldBeginIdx = 0;
					oldEndIdx = 1;
				} else {
					oldBeginIdx = sBeginIdx-1;
					oldEndIdx	= sEndIdx;
				}
				
				updateButtonsState(oldBeginIdx,oldEndIdx);
			} else if(sBeginIdx != sEndIdx) {
				updateButtonsState(sBeginIdx,sEndIdx);	
			}
		}
		// -------------------------- End of Text Format ------------------------- //
		
		
		
		// ----------------------------- Public ----------------------------- //
		public function get editorEnabled():Boolean
		{
			return _editorEnabled;
		}
		
		public function set editorEnabled(value:Boolean):void
		{
			_editorEnabled = value;
			if (_editorEnabled) {
				txtField.selectable = true;
				txtField.type = TextFieldType.INPUT;
				if (stage) {
					stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				}
			} else {
				txtField.selectable = false;
				txtField.type = TextFieldType.DYNAMIC;
				if (stage) {
					stage.removeEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
					stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				}
				this.saveToXML();
			}

		}
		// -------------------------- End of Public ------------------------- //
	}
}