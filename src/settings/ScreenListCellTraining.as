package src.settings
{
	public class ScreenListCellTraining extends ScreenListCellBase
	{
		public function ScreenListCellTraining()
		{
			super();
		}
		
		protected override function init():void {
			useCategory = true;
			useTimeSpent = true;
			
			// References.
			_txtTitle = this.txtScreenTitle;
			_cmbCategory = this.cmbScreenCategory;
			_sldTimeSpent = this.sldScreenTimeSpent;
			
			_lblTitle = this.lblScreenTitle;
			_lblCategory = this.lblScreenCategory;
			_lblTimeSpent = this.lblScreenTimeSpent;
			
			super.init();
			
			addListeners();
		}
	}
}