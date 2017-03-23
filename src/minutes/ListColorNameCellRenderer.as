package src.minutes
{
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import src.team.PRTeamManager;
	
	import src3d.utils.ColorUtils;
	
	public class ListColorNameCellRenderer extends ListNameCellRenderer
	{
		public function ListColorNameCellRenderer()
		{
			super();
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			var tf:TextFormat;
			var numTF:TextFormat;
			var tsCol:int = -1;
			var mPItem:MinutesPlayerItem = data as MinutesPlayerItem;
			if (mPItem) {
				numTextField.text = mPItem.teamPlayerNumber;
				tsCol = int(PRTeamManager.getInstance().getTeamSideKitSettings(mPItem.teamSideCode)._topColor);
				tf = this.textField.defaultTextFormat;
				numTF = this.numTextField.defaultTextFormat;
				if (tf) {
					if (tsCol > -1) {
						numTextField.background = true;
						numTextField.backgroundColor = tsCol;
						this.textField.background = true;
						this.textField.backgroundColor = tsCol;
						tf.color = ColorUtils.getColorContrast(tsCol);
						numTF.color = tf.color;
					} else {
						this.textField.background = false;
						this.textField.backgroundColor = 0xFFFFFF;
						numTextField.background = false;
						numTextField.backgroundColor = 0xFFFFFF;
						tf.color = 0;
						numTF.color = tf.color;
					}
					numTextField.setTextFormat(numTF);
					this.setStyle("textFormat", tf);
				}
			}
		}
		
		protected function getNewColorBg(col:uint):Sprite {
			var newSpr = new Sprite();
			newSpr.graphics.beginFill(col, 1);
			newSpr.graphics.drawRect(0, 0, 100, 20);
			newSpr.graphics.endFill();
			return newSpr;
		}
	}
}