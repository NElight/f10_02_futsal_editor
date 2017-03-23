package src.team.list
{
	import flash.events.Event;
	
	import src.team.TeamGlobals;
	
	public class PRCContainerOurTeam extends PRCContainerBase
	{
		public function PRCContainerOurTeam()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.teamSide = TeamGlobals.TEAM_OUR;
			this._lblTeamName = this.lblTeamName;
			this._txtTeamName = this.txtTeamName;
			this._btnRemoveAll = this.btnRemoveAll;
			this._btnAddPlayer = this.btnAddPlayer;
			this._btnSelectTeam = this.btnSelectTeam; // Our Team List Only.
			
			initControls();
		}
	}
}