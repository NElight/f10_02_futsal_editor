package src.controls.texteditor
{
	import fl.controls.ScrollBarDirection;
	import fl.controls.UIScrollBar;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import src.buttons.SSPButtonBase;
	
	import src3d.utils.MiscUtils;
	
	public class SSPTextEditorBase extends MovieClip
	{
		// Controls.
		protected var txtFormat:TextFormat;
		protected var labelFormat:TextFormat;
		protected var txtLabel:TextField;
		protected var txtField:TextField;
		protected var scrollBar:UIScrollBar;
		protected var btnB:SSPButtonBase; // Bold Button.
		protected var btnI:SSPButtonBase; // Italic Button.
		protected var btnU:SSPButtonBase; // Underline Button.
		
		// Controls Setup.
		protected var btnMargin:uint = 5;
		protected var xPos:Number;
		protected var yPos:Number;
		protected var txtWidth:Number;
		protected var txtHeight:Number;
		protected var txtFontSize:Number;
		protected var txtFontColor:Number = 0;
		protected var txtHTMLText:String;
		protected var txtMaxChars:Number;
		protected var lblText:String;
		protected var lblWidth:Number = 100;
		protected var lblFontSize:Number = 11;
		protected var lblHeight:Number = 22;
		
		private var _useLabel:Boolean;
		
		public function SSPTextEditorBase(xPos:Number, yPos:Number, txtWidth:Number, txtHeight:Number, txtFontSize:Number,
										  txtHTMLText:String, txtMaxChars:Number, useLabel:Boolean, lblText:String = "Text", lblWidth:Number = 100,
										  lblFontSize:Number = 11, lblHeight:Number = 22
		) {
			super();
			
			this.x = xPos;
			this.y = yPos;
			this.txtWidth = txtWidth;
			this.txtHeight = txtHeight;
			this.txtFontSize = txtFontSize;
			this.txtHTMLText = txtHTMLText;
			this.txtMaxChars = txtMaxChars;
			this._useLabel = useLabel;
			this.lblText = lblText;
			this.lblWidth = lblWidth;
			this.lblFontSize = lblFontSize;
			this.lblHeight = lblHeight;
			
			initControls();
		}
		
		// ----------------------------- Inits ----------------------------- //
		protected function initControls():void {
			var controlXPos:Number = 0;
			var controlYPos:Number = 0;
			
			// Label.
			if (_useLabel) {
				txtLabel = MiscUtils.createNewLabel(controlXPos, controlYPos, lblWidth, lblFontSize, lblHeight);
				txtLabel.text = lblText;
				this.addChild(txtLabel);
				controlXPos = txtLabel.x;
				controlYPos = txtLabel.y + txtLabel.height;
				labelFormat = txtLabel.defaultTextFormat;
			}
			
			// Buttons (From Flash text_editor folder).
			btnB = new mcBtnBold();
			btnI = new mcBtnItalic();
			btnU = new mcBtnUnderline();
			btnB.y = controlYPos;
			btnI.y = btnB.y + btnB.height + btnMargin;
			btnU.y = btnI.y + btnI.height + btnMargin;
			btnB.isToggleButton = true;
			btnI.isToggleButton = true;
			btnU.isToggleButton = true;
			btnB.buttonEnabled = true;
			btnI.buttonEnabled = true;
			btnU.buttonEnabled = true;
			this.addChild(btnB);
			this.addChild(btnI);
			this.addChild(btnU);
			
			// Scroll Bar.
			scrollBar = new UIScrollBar();
			scrollBar.direction = ScrollBarDirection.VERTICAL;
			scrollBar.visible = true;
			this.addChild(scrollBar);
			
			// Text Field.
			controlXPos = controlXPos + btnB.width + btnMargin;
			controlYPos = btnB.y;
			txtWidth = txtWidth - btnB.width - btnMargin - scrollBar.width; // Fit specified width with controls.
			txtField = MiscUtils.createNewTextField(controlXPos, controlYPos, txtWidth, txtHeight, TextFieldType.INPUT, true, true, true, txtFontSize, txtFontColor, txtMaxChars);
			txtField.htmlText = txtHTMLText;
			txtFormat = txtField.defaultTextFormat;
			this.addChild(txtField);
			
			// Update Scrollbar.
			scrollBar.scrollTarget = txtField;
			updateMinTextFieldHeight();
		}
		
		protected function updateMinTextFieldHeight():void {
			// Set minimum height for text field.
			txtField.y = btnB.y;
			if (txtField.height < btnU.y + btnU.height) {
				txtField.height = btnU.y + btnU.height - txtField.y;
			}
			updateScrollBar();
		}
		
		protected function updateScrollBar():void {
			scrollBar.direction = ScrollBarDirection.VERTICAL;
			scrollBar.setSize(txtField.width, txtField.height);
			scrollBar.move(txtField.x + txtField.width, txtField.y);
			scrollBar.scrollTarget = txtField;
			scrollBar.update();
			scrollBar.drawNow();
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Public ----------------------------- //
		public function setToolTips(b:String, i:String, u:String):void {
			btnB.setToolTipText(b);
			btnI.setToolTipText(i);
			btnU.setToolTipText(u);
		}
		public function get label():String {
			if (!_useLabel) return "";
			return txtLabel.text;
		}
		public function set label(value:String):void {
			if (!_useLabel) return;
			txtLabel.text = value;
		}
		public function get htmlLabel():String {
			if (!_useLabel) return "";
			return txtLabel.htmlText;
		}
		public function set htmlLabel(value:String):void {
			if (!_useLabel) return;
			txtLabel.htmlText = value;
			txtLabel.setTextFormat(labelFormat);
		}
		
		public function set editorText(value:String):void {
			txtField.text = value;
		}
		public function get editorText():String {
			return txtField.text;
		}
		
		public function set editorHTMLText(value:String):void {
			txtField.htmlText = value;
		}
		public function get editorHTMLText():String {
			return txtField.htmlText;
		}
		// -------------------------- End of Public ------------------------- //
	}
}