package src.team.list
{
	import src.team.TeamGlobals;
	
	public class PRCCellRendererExpanded extends PRCCellRendererBase
	{
		public function PRCCellRendererExpanded()
		{
			super();
			this.name = "PRCCellRendererExpanded";
			
			// Settings.
			_compactMode = false;
			
			// Controls.
			_txtName = this.txtName;
			_txtFamName = this.txtFamName;
			_txtNumber = this.txtNumber;
			_btnRemove = this.btnRemove;
			_mcNumberBg = this.mcNumberBg;
			
			// Controls Extended.
			_txtPosition = this.txtPosition;
			_btnEdit = this.btnEdit;
			_btnPose = this.btnPose;
			_btnNumber = this.btnNumber;
			_btnPose.addChild(_poseContainer);
			
			initFormat();
			initPlayerRecordFormat();
			initListeners();
		}
		
		protected function initFormat():void {
			// Initial Cell Renderer Settings.
			_rFinit = TeamGlobals.getInstance().initialExpandedCellSettings;
			updatePlayerNumberFormat(); // Update initial settings with session settings.
		}
	}
}