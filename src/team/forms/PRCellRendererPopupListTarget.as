package src.team.forms
{
	import src.team.TeamGlobals;

	public class PRCellRendererPopupListTarget extends PRCellRendererPopupList
	{
		public function PRCellRendererPopupListTarget()
		{
			super();
			this.name = "PRCellRendererPopupListTarget";
			
			// Format.
			_rFinit = TeamGlobals.getInstance().initialSelectTeamTargetCellSettings;
			
			initPlayerRecordFormat();
		}
	}
}