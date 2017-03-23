package src.mainmenu
{
	import fl.controls.Label;
	
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import src.buttons.SSPButtonBase;
	
	public class MainMenuTab extends SSPButtonBase
	{
		private var btnLabel:Label;
		
		public function MainMenuTab()
		{
			super();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.buttonEnabled = true;
			initLabel();
		}
		
		private function initLabel():void {
			this.visible = true;
			btnLabel = this.lblLabel;
			btnLabel.visible = true;
			
			var format:TextFormat		= new TextFormat();
			format.font					= "_sans";
			format.size					= 14;
			format.color				= 0xFFFFFF;
			format.bold					= false;
			format.italic				= false;
			format.align				= TextFormatAlign.CENTER;
			
			btnLabel.autoSize = TextFieldAutoSize.NONE;
			btnLabel.setStyle("textFormat", format);
		}
		
		public function set label(strLabel:String):void {
			btnLabel.text = strLabel;
		}
		public function get label():String {
			return btnLabel.text;
		}
	}
}