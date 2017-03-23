package src.team.list
{
	import flash.events.Event;
	
	import src.team.TeamGlobals;
	
	public class PRCContainerOpposition extends PRCContainerBase
	{
		public function PRCContainerOpposition()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.teamSide = TeamGlobals.TEAM_OPP;
			this._lblTeamName = this.lblTeamName;
			this._txtTeamName = this.txtTeamName;
			this._btnRemoveAll = this.btnRemoveAll;
			this._btnAddPlayer = this.btnAddPlayer;
			this._txtGenerateDummyTeam = this.txtGenerateDummyTeam; // Opposition Team List Only.
			this._btnGenerateDummyTeam = this.btnGenerateDummyTeam; // Opposition Team List Only.
			
			initControls();
		}
	}
}