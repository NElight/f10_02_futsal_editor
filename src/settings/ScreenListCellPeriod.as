package src.settings
{
	public class ScreenListCellPeriod extends ScreenListCellBase
	{
		public function ScreenListCellPeriod()
		{
			super();
		}
		
		protected override function init():void {
			useCategory = false;
			useTimeSpent = true;
			
			// References.
			_txtTitle = this.txtScreenTitle;
			_sldTimeSpent = this.sldScreenTimeSpent;
			
			_lblTitle = this.lblScreenTitle;
			_lblTimeSpent = this.lblScreenTimeSpent;
			
			super.init();
			
			addListeners();
		}
	}
}