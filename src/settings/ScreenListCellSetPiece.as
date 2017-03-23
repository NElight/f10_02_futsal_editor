package src.settings
{
	public class ScreenListCellSetPiece extends ScreenListCellBase
	{
		public function ScreenListCellSetPiece()
		{
			super();
		}
		
		protected override function init():void {
			useCategory = true;
			useTimeSpent = false;
			
			// References.
			_txtTitle = this.txtScreenTitle;
			_cmbCategory = this.cmbScreenCategory;
			
			_lblTitle = this.lblScreenTitle;
			_lblCategory = this.lblScreenCategory;
			
			super.init();
			
			addListeners();
		}
	}
}