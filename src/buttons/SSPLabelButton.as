package src.buttons
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	public class SSPLabelButton extends SSPButtonBase
	{
		private var initNewLabel:String = "";
		private var initNewLabelHTML:String = "";
		private var initAsHTML:Boolean;
		
		protected var _txtLabel:TextField;
		//protected var tFormat:TextFormat;
		protected var tSize:TextFormat;
		
		public function SSPLabelButton(newLabel:String = "", asHTML:Boolean = false, isToggleButton:Boolean = false)
		{
			super();
			this.buttonEnabled = true;
			initNewLabel = initNewLabelHTML = newLabel;
			initAsHTML = asHTML;
			this.isToggleButton = isToggleButton;
			initLabel();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
		}
		
		protected function initLabel():void {
			_txtLabel = getChildByName("txtLabel") as TextField;
			// Next line allows to be extended by using "tabLabel" as instance name for text field.
			// See McTab, McTabBase, and their objects in FLA file.
			// Avoids compiling error 1152 if use txtLabel for extenting classes.
			// Note that also "btnArea" name has to be changed to "tabArea".
			if (!_txtLabel) _txtLabel = getChildByName("tabLabel") as TextField;
			if (!_txtLabel) return;
			//tFormat = _txtLabel.getTextFormat();
			tSize = new TextFormat(_txtLabel.getTextFormat().font, _txtLabel.getTextFormat().size);
			if (!initAsHTML) {
				this.label = initNewLabel;
			} else {
				this.labelHTML = initNewLabel;
			}
		}
		
		/*protected function initLabel():void {
			var txtW = this.width;
			var txtH = this.height;
			
			var format:TextFormat		= new TextFormat();
			//format.font				= FONT;
			format.font					= "_sans";
			format.size					= 10;
			format.color				= "0x000000";
			
			_txtLabel = new TextField();
			_txtLabel.defaultTextFormat=format;
			_txtLabel.type				= TextFieldType.DYNAMIC;
			_txtLabel.selectable		= false;
			_txtLabel.text				= "";
			_txtLabel.border			= false;
			_txtLabel.x					= 0;
			_txtLabel.y					= 0;
			_txtLabel.multiline			= false;
			_txtLabel.wordWrap			= false;
			_txtLabel.background		= false;
			//_txtLabel.backgroundColor	= 0xFFFF99;
			_txtLabel.width				= txtW;
			_txtLabel.height			= txtH;
			//_txtLabel.maxChars		= 100;
			_txtLabel.textColor			= 0;
			
			this.addChild(_txtLabel);
			var btn:DisplayObject = getChildByName("btnSelect");
			if (btn) this.swapChildren(_txtLabel, btn);
		}*/
		
		public function set label(l:String):void { 
			if (!_txtLabel) {
				initNewLabel = l;
			} else {
				_txtLabel.text = l;
			}
		}
		public function get label():String {
			if (!_txtLabel) return "";
			return _txtLabel.text;
		}
		
		public function set labelHTML(l:String):void {
			if (!_txtLabel) {
				initNewLabelHTML = l;
			} else {
				tSize = new TextFormat(_txtLabel.getTextFormat().font, _txtLabel.getTextFormat().size);
				_txtLabel.htmlText = l;
				//_txtLabel.setTextFormat(tFormat); // Keep basic format.
				_txtLabel.setTextFormat(tSize); // Keep font type and size.
			}
		}
		public function get labelHTML():String {
			if (!_txtLabel) return "";
			return _txtLabel.htmlText;
		}
		
		public function get labelTextField():TextField { return _txtLabel; }
	}
}