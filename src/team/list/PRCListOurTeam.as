package src.team.list
{
	import src.team.TeamGlobals;

	public class PRCListOurTeam extends PRCListBase
	{
		public function PRCListOurTeam(displayEdit:Boolean)
		{
			super(displayEdit);
			this.name = LIST_NAME_OUR_TEAM;
			this.teamSide = TeamGlobals.TEAM_OUR;
		}
	}
}