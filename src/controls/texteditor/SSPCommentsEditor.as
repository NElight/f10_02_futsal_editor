package src.controls.texteditor
{
	import flash.text.TextFormat;
	
	import src3d.SessionGlobals;
	import src3d.utils.Logger;

	public class SSPCommentsEditor extends SSPTextEditor
	{
		private var currentScreenXML:XML;
		
		public function SSPCommentsEditor(xPos:Number, yPos:Number, txtWidth:Number, txtHeight:Number, txtFontSize:Number,
										  txtHTMLText:String, txtMaxChars:Number, useLabel:Boolean, lblText:String = "Text", lblWidth:Number = 100,
										  lblFontSize:Number = 11, lblHeight:Number = 22
		) {
			super(xPos, yPos, txtWidth, txtHeight, txtFontSize, txtHTMLText, txtMaxChars, false, lblText, lblWidth, lblFontSize, lblHeight);
			this.txtField.borderColor = 0xB2B2B2;
		}
		
		public function displayScreenComments(newScreenId:int):void {
			if (newScreenId < 0) {
				currentScreenXML = null;
				updateCommentsTextField();
				return;
			}
			// Update XML before change.
			saveToXML();
			// Set the new xml.
			var strScreenId:String = newScreenId.toString();
			currentScreenXML = sG.sessionDataXML.session.screen.(_screenId == strScreenId)[0];
			Logger.getInstance().addText("(A) - Can't load _screenComments. _screenId "+strScreenId+" XML data not found.", false);
			targetXML = (currentScreenXML)? currentScreenXML._screenComments[0] : null;
			// Update the comments text field.
			updateCommentsTextField();
		}
		
		public function updateCommentsTextField():void {
			if (this.targetXML) {
				txtField.htmlText = this.targetXML.text();
			} else {
				txtField.htmlText = "";
			}
			var globalFormat:TextFormat = new TextFormat(SSPSettings.DEFAULT_FONT, txtFontSize, 0);
			txtField.defaultTextFormat = globalFormat;
			txtField.setTextFormat(globalFormat); 
		}
		
		public function updateCommentsXML():void {
			saveToXML();
		}
		
		protected override function saveToXML():void {
			if (currentScreenXML && currentScreenXML.length() > 0 && txtField) {
				//currentScreenXML._screenComments = new XML( "<_screenComments><![CDATA[" + _comments.commentsField.htmlText + "]]></_screenComments>" );
				currentScreenXML._screenComments = txtField.htmlText;
			}
		}
	}
}