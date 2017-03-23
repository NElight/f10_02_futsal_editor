package src.minutes
{
	import src.header.ScoreData;
	
	import src3d.SessionGlobals;
	import src3d.utils.MiscUtils;

	public class MinutesGlobals//创建事件 <pr_minutes> <session_minutes>
	{
		// Internal Activity Codes (Matches server Activity Codes).
		public static const ACTIVITY_START_PLAY:String		= "start_play";
		public static const ACTIVITY_STOP_PLAY:String		= "stop_play";
		public static const ACTIVITY_LINE_UP:String			= "line_up";
		public static const ACTIVITY_SUBSTITUTE:String		= "substitute";
		public static const ACTIVITY_SUBSTITUTED:String		= "substituted";
		public static const ACTIVITY_RED_CARD:String		= "red_card";
		public static const ACTIVITY_GOAL:String			= "goal";
		public static const ACTIVITY_OWN_GOAL:String		= "own_goal";
		
		// Minutes Mode.
		public static const MINUTES_MODE_AUTO:String		= "Auto";
		public static const MINUTES_MODE_MANUAL:String		= "Manual";
		public static const MINUTES_MODE_OFF:String			= "Off";
		
		// Minutes Format.
		public static const MAX_CHAR_MINUTES:int			= 3;
		public static const MAX_CHAR_SECONDS:int			= 2;
		
		// Minutes Data Grid Columns.
		public static const MINUTES_COLUMN_MINUTE:String	= "Minute";
		public static const MINUTES_COLUMN_OBJECT:String	= "Object";
		public static const MINUTES_COLUMN_TEAM:String		= "Team";
		public static const MINUTES_COLUMN_ACTIVITY:String	= "Activity";
		public static const MINUTES_COLUMN_REMOVE:String	= "Remove";
		public static const MINUTES_COLUMN_EDIT:String		= "Edit";
		
		// Minutes skeletons.
		public static const SKELETON_PR:XML = new XML(
			<pr_minutes>
				<_screenId></_screenId>
				<_time></_time>
				<_offset></_offset>
				<_activityCode></_activityCode>
				<_teamPlayerId>0</_teamPlayerId>
				<_comment></_comment>
			</pr_minutes>);
		public static const SKELETON_SESSION:XML = new XML(
			<session_minutes>
				<_screenId></_screenId>
				<_time></_time>
				<_offset></_offset>
				<_activityCode></_activityCode>
				<_nonprTeamPlayerId>0</_nonprTeamPlayerId>
				<_comment></_comment>
			</session_minutes>);
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var _activityCodes:Vector.<ActivityCode> = new Vector.<ActivityCode>();
		private var _lastMatchMinutes:String = "";
		public var playerNamesChanged:Boolean; // Flag to recalculate player names.
		private var _scoreData:ScoreData;
		
		
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:MinutesGlobals;
		private static var _allowInstance:Boolean = false;
		public function MinutesGlobals()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		public static function getInstance():MinutesGlobals {
			if(_self == null) {
				_allowInstance=true;
				_self = new MinutesGlobals();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// ----------------------------- Singleton ----------------------------- //
		
		
		
		public function get activityCodes():Vector.<ActivityCode> {
			if (_activityCodes.length > 0) return _activityCodes;
			_activityCodes = new Vector.<ActivityCode>();
			var acXMLList:XMLList = sG.menuDataXML.meta_data.activity;
			var ac:ActivityCode;
			for each (var acXML:XML in acXMLList) {
				ac = new ActivityCode();
				ac.activityCode = acXML.@_activityCode;
				ac.activityName = acXML.@_activityName;
				_activityCodes.push(ac);
			}
			_activityCodes = Vector.<ActivityCode>(MiscUtils.vectorSortToArray(_activityCodes, "activityName"));
			return _activityCodes;
		}
		
		public function get useMinutes():Boolean
		{
			return (this.matchMinutes == MINUTES_MODE_AUTO || this.matchMinutes == MINUTES_MODE_MANUAL)? true : false;
		}
		
		public function set useMinutes(value:Boolean):void
		{
			this.matchMinutes = (value)? _lastMatchMinutes : MINUTES_MODE_OFF;
		}
		
		public function get matchMinutes():String
		{
			if (sG.sessionDataXML.session._matchMinutes.text() == "") this.matchMinutes = MINUTES_MODE_AUTO; // If no tag exist, create it.
			return sG.sessionDataXML.session._matchMinutes.text();
		}
		
		public function set matchMinutes(value:String):void
		{
			sG.sessionDataXML.session._matchMinutes = (value == "")? sG.sessionDataXML.session._matchMinutes = MINUTES_MODE_AUTO : value; // Default is auto.
			if (sG.sessionDataXML.session._matchMinutes.text() != MINUTES_MODE_OFF) _lastMatchMinutes = sG.sessionDataXML.session._matchMinutes.text(); // Store last ON mode.
		}
		
		public function get autoMode():Boolean {
			var aMode:Boolean = (this.matchMinutes == MINUTES_MODE_AUTO)? true : false;
			return aMode;
		}
		
		public function set autoMode(value:Boolean):void {
			this.matchMinutes = (value)? MINUTES_MODE_AUTO : MINUTES_MODE_MANUAL;
		}
		
		private function updateScoreData():void {
			_scoreData = new ScoreData();
			if (!useMinutes) {
				_scoreData.scoreOpp = int(sG.sessionDataXML.session._matchScoreOpposition.text());
				if (_scoreData.scoreOpp < 0) scoreOpp = 0;
			}
			if (!useMinutes) {
				_scoreData.scoreOur = int(sG.sessionDataXML.session._matchScoreUs.text());
				if (_scoreData.scoreOur < 0) scoreOur = 0;
			}
		}
		
		private function get scoreData():ScoreData {
			if (!_scoreData) updateScoreData();
			return _scoreData;
		}
		
		public function set scoreOur(value:int):void {
			if (value < 0) value = 0;
			scoreData.scoreOur = value;
			sG.sessionDataXML.session._matchScoreUs = value.toString();
		}
		
		public function get scoreOur():int {
			return scoreData.scoreOur;
		}
		
		public function set scoreOpp(value:int):void {
			if (value < 0) value = 0;
			scoreData.scoreOpp = value;
			sG.sessionDataXML.session._matchScoreOpposition = value.toString();
		}
		
		public function get scoreOpp():int {
			return scoreData.scoreOpp;
		}
	}
}