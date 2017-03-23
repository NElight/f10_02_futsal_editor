package src3d.text
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src3d.utils.MiscUtils;

	public class MCTextCustom extends MCTextChar
	{
		public var txtField1:TextField = new TextField();
		public var txtField2:TextField = new TextField();
		
		public function MCTextCustom()
		{
			super();
			_objectId = TextLibrary.TYPE_TEXT_CUSTOM;
			_internalScale = 1;
			initTextFields();
		}
		
		protected function initTextFields():void {
			// Apply Flash TextField format.
			txtField1.defaultTextFormat = TextField(this.textField).defaultTextFormat;
			txtField2.defaultTextFormat = TextField(this.textField).defaultTextFormat;
		}
		
		protected override function get textContent():String {
			//_textContent = MiscUtils.escapeHTML(this.textField.htmlText);
			return this.txtField1.text;
		}
		
		protected override function get textContent2():String {
			return this.txtField2.text;
		}
		
		protected override function get textStyle():String {
			// Use TextSettings class to obtain the textStyle String.
			var textSettings:TextSettings = new TextSettings();
			textSettings.line1_style = (txtField1.defaultTextFormat.bold)? 1 : 0;
			textSettings.line1_color = uint(txtField1.defaultTextFormat.color);
			textSettings.line1_textsize = TextLibrary.getFontSizeIdFromSize(Number(txtField1.defaultTextFormat.size));
			textSettings.line2_style = (txtField2.defaultTextFormat.bold)? 1 : 0;
			textSettings.line2_color = uint(txtField2.defaultTextFormat.color);
			textSettings.line2_textsize = TextLibrary.getFontSizeIdFromSize(Number(txtField2.defaultTextFormat.size));

			return textSettings._textStyle;
		}
		
		public function setTextContent(txtContent:TextField, txtContent2:TextField):void {
			txtField1.defaultTextFormat = txtContent.getTextFormat();
			txtField2.defaultTextFormat = txtContent2.getTextFormat();
			txtField1.text = txtContent.text;
			txtField2.text = txtContent2.text;
			updateHTMLText();
		}
		
		public function setLoadedTextContent(textSettings:TextSettings):void {
			applySSPTextStyleToCustomText(textSettings, txtField1, txtField2, false);
			txtField1.text = textSettings._textContent;
			txtField2.text = textSettings._textContent2;
			updateHTMLText();
		}
		
		protected function applySSPTextStyleToCustomText(textSettings:TextSettings, txtF1:TextField, txtF2:TextField, apply:Boolean):void {
			/*Format note: 
			_textStyle[line1_style, line1_colour, line1_textsize, line2_style, line2_colour, line2_textsize]
			Eg: 
			_textStyle="1,0xFF0000,2,0,0x000000,1"
			_textLine1="Player1name &amp; Player2name"
			_textLine2="Defense"*/ 
			
			var txtFormat1:TextFormat = new TextFormat();
			txtFormat1.bold = (textSettings.line1_style == 1)? true : false;
			txtFormat1.color = textSettings.line1_color;
			txtFormat1.size = TextLibrary.getFontSizeFromId(int(textSettings.line1_textsize));
			
			var txtFormat2:TextFormat = new TextFormat();
			txtFormat2.bold = (textSettings.line2_style == 1)? true : false;
			txtFormat2.color = textSettings.line2_color;
			txtFormat2.size = TextLibrary.getFontSizeFromId(int(textSettings.line2_textsize));
			
			if (apply) {
				txtF1.setTextFormat(txtFormat1);
				txtF2.setTextFormat(txtFormat2);
			} else {
				txtF1.defaultTextFormat = txtFormat1;
				txtF2.defaultTextFormat = txtFormat2;
			}
		}
		
		public function updateHTMLText():void {
			var htmlStr:String = txtField1.htmlText + txtField2.htmlText;
			this.textField.htmlText = htmlStr; // 2D Text embedded in flash.
		}
	}
}