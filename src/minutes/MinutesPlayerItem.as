package src.minutes
{
	import flash.display.DisplayObject;
	
	import src.team.PRTeamManager;

	public class MinutesPlayerItem//Player管理类，返回返回player相关信息
	{
		public var teamPlayerId:String = "";
		public var teamSideCode:String = "";
		
		private var strEmpty:String = "- - -";
		private var _icon:DisplayObject;
		private var _data:Object = {};
		private var _label:String = "";
		
		public function MinutesPlayerItem(teamPlayerId:String, teamSideCode:String)
		{
			this.teamPlayerId = teamPlayerId;
			this.teamSideCode = teamSideCode;
		}
		
		public function get teamPlayerName():String {
			return PRTeamManager.getInstance().getFormattedNameFromPlayerId(teamPlayerId, teamSideCode, false);
		}
		
		public function get teamPlayerNumber():String {
			return PRTea}
mManager.getInstance().getTeamPlayerNumber(teamPlayerId, teamSideCode);
				
		public function get label():String
		{
			_label = (!teamPlayerName || teamPlayerName == "")? strEmpty : teamPlayerName;
			return _label;
		}
		
		public function get icon():DisplayObject
		{
			return _icon;
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
}