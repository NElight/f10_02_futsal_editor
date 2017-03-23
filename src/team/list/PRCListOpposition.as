package src.team.list
{
	import src.team.TeamGlobals;

	public class PRCListOpposition extends PRCListBase
	{
		public function PRCListOpposition(displayEdit:Boolean)
		{
			super(displayEdit);
			this.name = LIST_NAME_OPPOSITION;
			this.teamSide = TeamGlobals.TEAM_OPP;
		}
	}
}