package src.team.forms
{
	import fl.controls.listClasses.CellRenderer;
	
	import flash.text.TextFormat;
	
	public class FixtureCellRenderer extends CellRenderer
	{
		private var fTF:TextFormat;
		
		public function FixtureCellRenderer()
		{
			super();
			updateStyle();
		}
		
		private function updateStyle():void {
			var col1:uint = 0x0064A0;
			var col2:uint = 0x0082BB;
			var col3:uint = 0x009FD5;
			if (!fTF) {
				fTF = this.textField.defaultTextFormat;
				fTF.font = SSPSettings.DEFAULT_FONT;
				fTF.size = 16;
				fTF.color = 0xFFFFFF;
				fTF.bold = true;
				this.setStyle("defaultTextFormat", fTF);
			}
			//this.textField.defaultTextFormat = fTF;
			//this.textField.setTextFormat(fTF);
			this.textField.background = true;
			this.textField.backgroundColor = col3;
			this.setStyle("textFormat", fTF);
		}
		
		public override function set data(value:Object):void {
			super.data = value;
		}
	}
}