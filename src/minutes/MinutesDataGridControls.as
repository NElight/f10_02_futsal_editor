package src.minutes
{
	import flash.events.MouseEvent;
	
	import src.lists.MCCellRenderer;
	
	public class MinutesDataGridControls extends MCCellRenderer
	{
		public function MinutesDataGridControls()
		{
			super();
			this.useHandCursor = true;
			this.buttonEnabled = true;
			this.isToggleButton = false;
		}
		
		protected override function onMouseDown(e:MouseEvent):void {
			hidePopups();
			this.gotoAndStop(DOWN);
		}
		
		protected override function onMouseUp(e:MouseEvent):void {
			if (isToggled) return;
			//trace("SSPButton.onMouseUP()");
			this.gotoAndStop(UP);
		}
	}
}