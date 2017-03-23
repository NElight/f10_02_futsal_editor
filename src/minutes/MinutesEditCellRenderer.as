package src.minutes
{
	import src.buttons.SSPButtonCellRenderer;
	
	public class MinutesEditCellRenderer extends SSPButtonCellRenderer
	{
		public function MinutesEditCellRenderer()
		{
			super();
		}
		
		public override function set data(value:Object):void
		{
			super.data = value;
			var mItem:MinutesItem = value as MinutesItem;
			if (mItem && mItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY) {
				this.buttonEnabled = false;
			} else {
				this.buttonEnabled = true;
			}
		}
	}
}