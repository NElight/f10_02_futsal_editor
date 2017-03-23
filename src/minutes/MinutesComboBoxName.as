package src.minutes
{
	import fl.controls.ComboBox;
	import fl.core.InvalidationType;
	
	import flash.text.TextFormat;
	
	import src.team.PRTeamManager;
	
	import src3d.utils.ColorUtils;
	
	public class MinutesComboBoxName extends ComboBox
	{
		public function MinutesComboBoxName()
		{
			super();
		}
		
		/*protected override function draw():void {
			super.draw();
		}
		
		public override function set selectedIndex(value:int):void {
			super.selectedIndex = value;
			updateStyle();
		}*/
		
		public override function invalidate(property:String=InvalidationType.ALL,callLater:Boolean=true):void {
			super.invalidate(property, callLater);
			updateStyle();
		}
		
		
		private function updateStyle():void {
			if (!list) return;
			var tsCol:int = -1; 
			var mPItem:MinutesPlayerItem = this.selectedItem as MinutesPlayerItem;
			var tf:TextFormat = this.textField.textField.defaultTextFormat;
			if (mPItem) tsCol = int(PRTeamManager.getInstance().getTeamSideKitSettings(mPItem.teamSideCode)._topColor);
			if (tf) {
				if (tsCol > -1) {
					this.textField.textField.background = true;
					this.textField.textField.backgroundColor = tsCol;
					tf.color = ColorUtils.getColorContrast(tsCol);
				} else {
					this.textField.textField.background = false;
					this.textField.textField.backgroundColor = 0;
					tf.color = 0;
				}
				this.textField.setStyle("textFormat", tf);
			}
		}
	}
}