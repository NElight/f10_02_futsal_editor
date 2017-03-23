package src.minutes
{
	import flash.text.TextFormat;
	
	import src.team.PRTeamManager;
	
	import src3d.utils.ColorUtils;

	public class ListLineUpNameCellRenderer extends ListColorNameCellRenderer
	{
		public function ListLineUpNameCellRenderer()
		{
			super();
		}
		
		public override function set data(value:Object):void {
			super.data = value.data;
			var tf:TextFormat;
			var numTF:TextFormat;
			var tsCol:int = -1;
			var mPItem:MinutesItem = data as MinutesItem;
			if (mPItem) {
				numTextField.text = mPItem.teamPlayerNumber;
				this.label = mPItem.Object;
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
					//numTextField.defaultTextFormat = tf;
					numTextField.setTextFormat(numTF);
					this.setStyle("textFormat", tf);
				}
			}
		}
	}
}