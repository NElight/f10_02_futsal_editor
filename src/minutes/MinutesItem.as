package src.minutes
{
	import flash.display.DisplayObject;
	
	import src.team.PRTeamManager;
	import src.team.TeamGlobals;
	
	import src3d.SessionGlobals;
	import src3d.utils.SessionScreenUtils;

	public class MinutesItem extends Object//minutes事件更新
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mM:MinutesManager = MinutesManager.getInstance();
		
		public var label:String;
		public var icon:DisplayObject;
		
		public var minutesXML:XML = new XML();
		
		private var _screenId:String;
		private var _minute:String = "";
		private var _name:String = "";
		private var _activity:String = "";
		private var _team:String = "";
		private var _comment:String = "";
		
		private var strGivenName:String = "";
		private var strFamilyName:String = "";
		private var strEmpty:String = "- - -";
		private var strButtonLabel:String = "";
		public var isButton:Boolean;
		
		
		private var _timeInSeconds:String = "0";
		private var _offsetInSeconds:String = "0";
		private var _activityCode:String = "";
		private var _teamSideCode:String = "";
		private var _teamPlayerId:String = "0";
		private var _teamPlayerNumber:String = "";
		
		public function MinutesItem(minutesXML:XML)
		{
			this.minutesXML = minutesXML;
			this._screenId = this.minutesXML._screenId.text();
			updateDataFromXML();
		}
		
		private function updateDataFromXML():void {
			if (!minutesXML) return;
			
			// Minutes.
			_timeInSeconds = minutesXML._time.text();
			_minute = mM.getMinutesSecondsFromTime(int(_timeInSeconds));
			
			_offsetInSeconds = minutesXML._offset.text();
			
			// Activity Name.
			_activityCode = minutesXML._activityCode.text();
			if (_activityCode == MinutesGlobals.ACTIVITY_START_PLAY) {
				isButton = true;
				strButtonLabel = sG.interfaceLanguageDataXML.buttons._btnMinutesPlayerList.text();
			} else {
				isButton = false;
			}
			_activity = mM.getActivityNameFromCode(_activityCode);
			
			// Team Side.
			_teamSideCode = mM.getTeamSideCodeFromXML(minutesXML);
			if (_teamSideCode == TeamGlobals.TEAM_OUR) {
				_team = sG.interfaceLanguageDataXML.titles._titleTeamUs.text();
			} else if (_teamSideCode == TeamGlobals.TEAM_OPP) {
				_team = sG.interfaceLanguageDataXML.titles._titleTeamOpp.text();
			} else {
				_team = strEmpty;
			}
			
			_teamPlayerId = (MinutesManager.isPlayerRecordMinutes(minutesXML))? minutesXML._teamPlayerId.text() : minutesXML._nonprTeamPlayerId.text();
			
			// Object Name.
			//strGivenName = PRTeamManager.getInstance().getTeamPlayerGivenName(_teamPlayerId, _teamSideCode);
			//strFamilyName = PRTeamManager.getInstance().getTeamPlayerFamilyName(_teamPlayerId, _teamSideCode);
			updateName();
			
			// Comment.
			_comment = minutesXML._comment.text();
			
			// Player Number.
			_teamPlayerNumber = PRTeamManager.getInstance().getTeamPlayerNumber(_teamPlayerId, _teamSideCode);
		}
		
		public function updateXMLData(timeInSec:String, tPlayerId:String, actCode:String, strComment:String):void {
			minutesXML._time = timeInSec;
			if (MinutesManager.isPlayerRecordMinutes(minutesXML)) {
				minutesXML._teamPlayerId = tPlayerId;
			} else {
				minutesXML._nonprTeamPlayerId = tPlayerId;
			}
			minutesXML._activityCode = actCode;
			minutesXML._comment = strComment;
			updateDataFromXML();
		}
		
		public function setScreenId(strScreenId:String):void {
			if (!strScreenId) return;
			minutesXML._screenId = strScreenId;
			_screenId = strScreenId;
		}
		
		public function updateName():void {
			//_name = (_team == strEmpty)? strEmpty : PRTeamManager.getInstance().getTeamPlayerFamilyName(_teamPlayerId, _teamSideCode);
			//_name = (_team == strEmpty)? strEmpty : PRTeamManager.getInstance().getFormattedName(strGivenName, strFamilyName);
			_name = (_teamSideCode == strEmpty)? strEmpty : PRTeamManager.getInstance().getFormattedNameFromPlayerId(_teamPlayerId, _teamSideCode, false);
			if (_name == "") _name = strEmpty;
		}
		
		// ----------------------------- Data for Editor ----------------------------- //
		public function get screenId():String {
			return _screenId;
		}
		
		public function set timeInSeconds(value:String):void {
			_timeInSeconds = value;
			_minute = mM.getMinutesSecondsFromTime(int(_timeInSeconds));
		}
		public function get timeInSeconds():String {
			return _timeInSeconds;
		}
		
		public function set offsetInSeconds(value:String):void {
			_offsetInSeconds = value;
		}
		public function get offsetInSeconds():String {
			return _offsetInSeconds;
		}
		
		public function get activityCode():String {
			return _activityCode;
		}
		
		public function get teamSideCode():String {
			return _teamSideCode;
		}
		
		public function get teamPlayerId():String {
			return _teamPlayerId;
		}
		
		public function get teamPlayerNumber():String {
			var strPNumber:String = _teamPlayerNumber;
			var intsortOrder:int;
			var strSortOrder:String;
			if (activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				// Use Period Number.
				intsortOrder = int(SessionScreenUtils.getScreenSortOrderFromScreenId(this.screenId))+1;
				strSortOrder = (intsortOrder <= 0)? "" : intsortOrder.toString();
				strPNumber = "P"+strSortOrder;
			}
			return strPNumber;
		}
		
		public function get isStopPlay():Boolean {
			return (activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY)? true : false; 
		}
		
		public function get isStartPlay():Boolean {
			return (activityCode == MinutesGlobals.ACTIVITY_START_PLAY)? true : false; 
		}
		
		public function clone():MinutesItem {
			return new MinutesItem(this.minutesXML.copy());
		}
		// ----------------------------- Data for Editor ----------------------------- //
		
		
		
		// ----------------------------- Cell Renderer Data ----------------------------- //
		public function get Minute():String {
			return _minute;
		}
		
		public function get Object():String {
			var strObj:String = _name;
			if (activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				strObj = _activity;
			} else {
				strObj = _name;
			}
			//if (strObj == strEmpty) strObj = _activity;
			return strObj;
		}
		
		public function get Team():String {
			return _team;
		}
		
		public function get Activity():String {
			var strActivity:String = _activity;
			if (isButton) {
				// Show button label as activity name.
				strActivity = strButtonLabel;
			} else if (activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				// No activity name shown.
				strActivity = strEmpty;
			}
			return strActivity;
		}
		
		public function get Comment():String {
			return _comment;
		}
		// -------------------------- End of Cell Renderer Data ------------------------- //
	}
}