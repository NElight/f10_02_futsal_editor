package src.minutes
{
	import fl.data.DataProvider;
	
	import src.events.SSPMinutesEvent;
	import src.header.ScoreData;
	import src.team.PRTeamManager;
	import src.team.TeamGlobals;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.models.soccer.players.Player;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	public class MinutesManager
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mG:MinutesGlobals = MinutesGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var popupPlayerList:MinutesPlayerListFormPopupBox;
		
		// Refs.
		private var minutesEditor:SSPMinutesEditor;
		private var minutesDG:MinutesDataGrid;
		private var minutesClock:MinutesClock;
		private var _minutesInitialized:Boolean;
		private var minutesConfirm:MinutesClockConfirmPopupBox;
		
		// Data.
		private var _minutesDP:DataProvider;
		
		private var confirmSettings:Object;
		private var confirmRed:String = "#CC0000";
		private var confirmGreen:String = "#009933";
		
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:MinutesManager;
		private static var _allowInstance:Boolean = false;
		public function MinutesManager()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				init();
			}
		}
		public static function getInstance():MinutesManager {
			if(_self == null) {
				_allowInstance=true;
				_self = new MinutesManager();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		// ----------------------------- Inits ----------------------------- //
		private function init():void {
			
		}
		
		public function initReferences(minutesEditor:SSPMinutesEditor, minutesDG:MinutesDataGrid, minutesClock:MinutesClock):void {
			this.minutesEditor = minutesEditor;
			this.minutesDG = minutesDG;
			this.minutesClock = minutesClock;
			if (this.minutesEditor && this.minutesDG && this.minutesClock) _minutesInitialized = true;
			updateMinutesDG();
			validateMinutesMode();
		}
		
		private function validateMinutesMode():void {
			// If minutes mode = auto and has minutes already and there is not match stop record, set minutes clock to manual.
			if (mG.autoMode && this.hasMinutes == true && this.getMatchStopTime() == "-1") {
				mG.autoMode = false;
				minutesClock.updateAutoMode();
				var mItem:MinutesItem = this.getMatchLastMinutesItem();
				if (mItem) {
					minutesClock.setTimeInSeconds(mItem.timeInSeconds);
				} else {
					minutesClock.setTimeInSeconds("0");
				}
			}
		}
		// -------------------------- End of Inits ----------------------------- //
		
		
		
		// ----------------------------- Players ----------------------------- //
		public function getPlayerNamesDataProvider():DataProvider {
			var aNewDP:Array = [];
			var minItem:MinutesItem;
			var strElementName:String;
			var strTeamPlayerId:String;
			
			var lineUpOursXMLList:XMLList = new XMLList();
			lineUpOursXMLList = PRTeamManager.getInstance().teamOursXML.children();
			for each(var pXML:XML in lineUpOursXMLList) {
				strTeamPlayerId = (sG.usePlayerRecords)? pXML._prPlayerId.text() : pXML._nonprPlayerId.text();
				aNewDP.push( new MinutesPlayerItem(strTeamPlayerId, TeamGlobals.TEAM_OUR) );
			}
			
			var lineUpOppXMLList:XMLList = new XMLList();
			lineUpOppXMLList = PRTeamManager.getInstance().teamOppXML.children();
			for each(var pXML:XML in lineUpOppXMLList) {
				strTeamPlayerId = pXML._nonprPlayerId.text();
				aNewDP.push( new MinutesPlayerItem(strTeamPlayerId, TeamGlobals.TEAM_OPP) );
			}
			
			return new DataProvider(aNewDP);
		}
		// -------------------------- End of Players ------------------------- //
		
		
		
		// ----------------------------- Activity ----------------------------- //
		public function getActivityDataProvider():DataProvider {
			var aNewDP:Array = [];
			for each(var ac:ActivityCode in MinutesGlobals.getInstance().activityCodes) {
				if (ac.activityCode != MinutesGlobals.ACTIVITY_START_PLAY &&
					ac.activityCode != MinutesGlobals.ACTIVITY_STOP_PLAY &&
					ac.activityCode != MinutesGlobals.ACTIVITY_LINE_UP) {
					aNewDP.push( {label:ac.activityName, data:ac.activityCode} );
				}
			}
			return new DataProvider(aNewDP);
		}
		
		public function getActivityNameFromCode(aCode:String):String {
			for each(var ac:ActivityCode in mG.activityCodes) {
				if (ac.activityCode == aCode) return ac.activityName;
			}
			return "";
		}
		// -------------------------- End of Activity ------------------------- //
		
		
		
		// ----------------------------- Minutes ----------------------------- //
		private function updateMinutesDG():void {
			updateMinutesDP();
			// TODO: Sort datagrid, select item, scroll to selected.
			minutesDG.dataProvider = _minutesDP;
			//minutesDG.sortItemsOn(MinutesGlobals.MINUTES_COLUMN_MINUTE, Array.NUMERIC);
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.MINUTES_UPDATE_SCORE));
		}
		
		private function updateMinutesDP():void {
			var periodsArray:Array = [];
			recalculateMinutesStartTime();
			for each(var sS:SessionScreen in this.sortedPeriods) {
				periodsArray = periodsArray.concat(sS.periodMinutes.aPeriod);
			}
			_minutesDP = new DataProvider(periodsArray);
			updateClockStatus();
		}
		
		private function updateClockStatus():void {
			if (this.playStarted) {
				minutesClock.displayStop();
			} else {
				minutesClock.displayStart();
			}
		}
		
		public function getMinutesFromTime(timeInSeconds:int):String {
			var min:int = Math.floor(timeInSeconds/60); // Get minutes.
			var strMin:String = MiscUtils.addLeadingZeros(min.toString(), MinutesGlobals.MAX_CHAR_MINUTES );
			return strMin;
		}
		
		public function getSecondsFromTime(timeInSeconds:int):String {
			var sec:int = Math.floor((timeInSeconds%60)%100); // Get seconds (rest of seconds).
			var strSec:String = MiscUtils.addLeadingZeros(sec.toString(), MinutesGlobals.MAX_CHAR_SECONDS );
			return strSec;
		}
		
		public function getMinutesSecondsFromTime(timeInSeconds:int):String {
			var strMin:String = getMinutesFromTime(timeInSeconds);
			var strSec:String = getSecondsFromTime(timeInSeconds);
			return strMin+":"+strSec;
		}
		
		public function getTimeInSecondsFromTime(strMinutes:String, strSeconds:String):void {
			minutesClock.getTimeInSeconds()
		}
		// -------------------------- End of Minutes ------------------------- //
		
		
		
		
		// ----------------------------- Utils ----------------------------- //
		private function getScreenIds():Array {
			var aScreenId:Array = [];
			var strScreenIdLocalName:String = "_screenId";
			var screenIdXMLList:XMLList = sG.sessionDataXML.session.screen.children().(localName() == strScreenIdLocalName);
			for each(var sIdXML:XML in screenIdXMLList) {
				if (aScreenId.indexOf(sIdXML.text()) == -1) {
					aScreenId.push(String(sIdXML.text()));
				}
			}
			aScreenId.sort(Array.NUMERIC);
			return aScreenId;
		}
		
		public function getTeamSideCodeFromXML(xml:XML):String {
			var teamSideCode:String;
			if (xml.name() == MinutesGlobals.SKELETON_PR.name()) {
				teamSideCode = TeamGlobals.TEAM_OUR; // All player records are our team.
			} else if (xml.name() == MinutesGlobals.SKELETON_SESSION.name()){
				// Check player team side.
				teamSideCode = PRTeamManager.getInstance().getTeamSideFromNonPRPlayerId(xml._nonprTeamPlayerId.text());
			} else {
				teamSideCode = "";
			}
			return teamSideCode;
		}
		
		private function getStartPlayTimeInSeconds(sScreen:SessionScreen):String {
			for each (var mi:MinutesItem in sScreen.periodMinutes) {
				if (mi.activityCode == MinutesGlobals.ACTIVITY_START_PLAY) return mi.activityCode;
			}
			return "-1";
		}
		
		public function getScreenOffsetDifference(sScreen:SessionScreen):String {
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			var difference:String = "0";
			var sS:SessionScreen;
			for (var i:int;i<aScreens.length;i++) {
				sS = aScreens[i];
				if (sS == sScreen) break;
				difference = sS.periodMinutes.periodStopTime;
			}
			return difference;
		}
		
		/**
		 * Sort by Offset, then _activityCode. Note that it doesn't sort full minutes.
		 * For full minutes, first sort is Period, then Offset, then _activityCode.
		 */		
		public static function sortMinutesItems(aMinutesItem:Vector.<MinutesItem>):void {
			aMinutesItem.sort(sortMinutesItemsCompare);
		}
		private static function sortMinutesItemsCompare(obj1:MinutesItem, obj2:MinutesItem):Number {
			var sortNumber:int;
			var subSortArray:Array;
			if (!obj1 || !obj2) return 0; // No sorting needed.
			var time1:Number = int(obj1.timeInSeconds);
			var time2:Number = int(obj2.timeInSeconds);
			if (isNaN(time1) || isNaN(time2)) return 0;
			// If Start Play, move to the top.
			if (obj1.activityCode == MinutesGlobals.ACTIVITY_START_PLAY) return -1;
			if (obj2.activityCode == MinutesGlobals.ACTIVITY_START_PLAY) return 1;
			// If Stop Play, move to the bottom.
			if (obj1.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) return 1;
			if (obj2.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) return -1;
			if (time1 > time2) {
				sortNumber = 1;
			} else if (time1 < time2) {
				sortNumber = -1;
			} else {
				// If both times are equal, sort by activityCode (alphabetically).
				sortNumber = (obj1.activityCode.localeCompare(obj2.activityCode) < 0)? 1 : -1;
			}
			return sortNumber;
		}
		
		public static function isPlayerRecordMinutes(minutesXML:XML):Boolean {
			var isPR:Boolean = (minutesXML.name() == MinutesGlobals.SKELETON_PR.name())? true : false;
			return isPR;
		}
		
		public static function secondsToMinutes(sec:String):String {
			var intSec:int = Math.abs(int(sec));
			return Math.ceil(intSec/60).toString();
		}
		
		/**
		 * Gets the corresponding Period from a given time. 
		 * @param timeInSeconds String.
		 * @return 
		 * 
		 */		
		public function getScreenFromTime(timeInSeconds:String):SessionScreen {
			if (!timeInSeconds || timeInSeconds == "" || timeInSeconds == "undefined") return null;
			var intTime:int = int(timeInSeconds);
			if (intTime < 0) return null;
			var sScreen:SessionScreen;
			var foundSessionScreen:SessionScreen;
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			// If match has finished and time is later than finished time, return null.
			if (aScreens[aScreens.length-1].periodMinutes.hasStopPlay &&
				intTime > int(aScreens[aScreens.length-1].periodMinutes.periodStopTime)) {
				return null;
			}
			
			for (var i:uint=0;i<aScreens.length;i++) {
				sScreen = aScreens[i];
				if (sScreen.periodMinutes.hasStopPlay) {
					if (intTime > int(sScreen.periodMinutes.periodStartTime) &&
						intTime < int(sScreen.periodMinutes.periodStopTime)) {					
						foundSessionScreen = sScreen;
					}
				} else {
					if (sScreen.periodMinutes.hasStartPlay && intTime > int(sScreen.periodMinutes.periodStartTime)) {
						foundSessionScreen = sScreen;
						break;
					}
				}
			}
			return foundSessionScreen;
		}
		
		/**
		 * Returns the first un-started screen found.
		 * @return SessionScreen
		 */		
		public function getUnstartedScreen():SessionScreen {
			var sScreen:SessionScreen;
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			for (var i:uint;i<aScreens.length;i++) {
				sScreen = aScreens[i];
				if (sScreen && !sScreen.disposeFlag && !sScreen.periodMinutes.hasStartPlay && !sScreen.periodMinutes.hasStopPlay) {
					return sScreen;
				}
			}
			return null;
		}
		
		/**
		 * Returns the first un-finished screen found.
		 * @return SessionScreen
		 */
		public function getUnfinishedScreen():SessionScreen {
			var sScreen:SessionScreen;
			var foundSessionScreen:SessionScreen;
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			for (var i:uint;i<aScreens.length;i++) {
				sScreen = aScreens[i];
				if (sScreen && !sScreen.disposeFlag && sScreen.periodMinutes.hasStartPlay && !sScreen.periodMinutes.hasStopPlay) {
					foundSessionScreen = sScreen;
				}
			}
			return foundSessionScreen;
		}
		
		/**
		 * Returns the match stop time or "-1" if no there is no stop time yet. 
		 * @return String
		 */		
		public function getMatchStopTime():String {
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			var sScreen:SessionScreen;
			var prevScreen:SessionScreen;
			var strStopTime:String = "-1";
			for (var i:uint;i<aScreens.length;i++) {
				sScreen = aScreens[i];
				if (sScreen && !sScreen.disposeFlag && sScreen.periodMinutes.hasStartPlay && sScreen.periodMinutes.hasStopPlay) {
					strStopTime = sScreen.periodMinutes.periodStopTime;
				}
			}
			return strStopTime;
		}
		
		/**
		 * Returns the last record time from the match. Not necessarily 'Stop Play'.
		 * @return String
		 */		
		public function getMatchLastMinutesItem():MinutesItem {
			var lastMinutesItem:MinutesItem;
			var lastMinutesItemTemp:MinutesItem;
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			for (var i:uint;i<aScreens.length;i++) {
				lastMinutesItemTemp = aScreens[i].periodMinutes.periodLastMinutesItem;
				if (lastMinutesItemTemp) lastMinutesItem = lastMinutesItemTemp;
			}
			
			return lastMinutesItem;
		}
		
		private function getsortedPeriods():Vector.<SessionScreen> {
			var aScreens:Vector.<SessionScreen> = new Vector.<SessionScreen>();
			for each(var sS:SessionScreen in main.sessionView.aScreens) {
				if (sS && !sS.disposeFlag && sS.screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					aScreens.push(sS);
				}
			}
			SessionScreenUtils.sortScreensBySortOrder(aScreens);
			return aScreens;
		}
		
		private function hasRedCard(teamPlayerId:String, teamSide:String):Boolean {
			var aScreens:Vector.<SessionScreen> = this.sortedPeriods;
			var sScreen:SessionScreen;
			for (var i:uint;i<aScreens.length;i++) {
				sScreen = aScreens[i];
				if (sScreen && !sScreen.disposeFlag && sScreen.periodMinutes.playerHasRedCard(teamPlayerId, teamSide)) return true;
			}
			return false;
		}
		// -------------------------- End of Utils ------------------------- //
		
		
		
		// ----------------------------- Minutes Log ----------------------------- //
		private function getScreenFromId(sId:String):SessionScreen {
			for each(var sS:SessionScreen in main.sessionView.aScreens) {
				if (sS && !sS.disposeFlag) {
					if (String(sS.screenId) == sId) return sS;
				}
			}
			return null;
		}
		
		public function addStartPlayRecord(sScreen:SessionScreen):Boolean {
			if (!sScreen || sScreen.periodMinutes.hasStartPlay) return false;
			var mItem:MinutesItem = this.getMatchLastMinutesItem();
			if (mItem && !mItem.isStopPlay) return false;
			var strTimeInSeconds:String = this.getMatchStopTime();
			if (!strTimeInSeconds || strTimeInSeconds == "" || strTimeInSeconds == "-1") strTimeInSeconds = "0";
			var mItem:MinutesItem = sScreen.periodMinutes.addStartPlayRecord(strTimeInSeconds);
			if (mItem) {
				updateMinutesDG();
				minutesDG.selectedItem = mItem;
				minutesDG.scrollToSelected();
				return true;
			}
			return false;
		}
		
		public function addStopPlayRecord(sScreen:SessionScreen, strTimeInSeconds:String):Boolean {
			if (!sScreen || sScreen.periodMinutes.hasStopPlay) return false;
			var mItem:MinutesItem = sScreen.periodMinutes.addStopPlayRecord(strTimeInSeconds);
			if (mItem) {
				updateMinutesDG();
				minutesDG.selectedItem = mItem;
				minutesDG.scrollToSelected();
				return true;
			}
			return false;
		}
		
		public function addMinutesRecord(sScreen:SessionScreen, strTimeInSeconds:String, activityCode:String, teamPlayerId:String = "", teamSideCode:String = "", strComment:String = ""):Boolean {
			if (activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_LINE_UP
			) {
				return false;
			}
			var intTimeInSeconds:int = int(strTimeInSeconds);
			var intStopTime:int = int(sScreen.periodMinutes.periodStopTime);
			var intStartTime:int = int(sScreen.periodMinutes.periodStartTime);
			if (intTimeInSeconds <= 0 || intTimeInSeconds <= intStartTime || (intStopTime > 0 && intTimeInSeconds > intStopTime)) {
				return false;
			}
			return addMinutesItem(sScreen, strTimeInSeconds, activityCode, teamPlayerId, teamSideCode, strComment);
		}
		
		private function addMinutesItem(sScreen:SessionScreen, strTimeInSeconds:String, activityCode:String, teamPlayerId:String = "", teamSideCode:String = "", strComment:String = ""):Boolean {
			var mItem:MinutesItem = sScreen.periodMinutes.addMinutesItem(strTimeInSeconds, activityCode, teamPlayerId, teamSideCode, strComment);
			if (mItem) {
				updateMinutesDG();
				minutesDG.selectedItem = mItem;
				minutesDG.scrollToSelected();
				return true;
			}
			return false;
		}
		
		public function removeMinutesItem(mItem:MinutesItem):void {
			var sScreen:SessionScreen = SessionScreenUtils.getScreenFromScreenId(int(mItem.screenId), main.sessionView.aScreens);
			if (!sScreen) return;
			// TODO: Validation (eg. not allowing to remove start play if previous period exists).
			
			sScreen.periodMinutes.removeMinutesItem(mItem);
			//minutesDG.removeItem(mItem);
			updateMinutesDG();
			
			if (mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY
				&& sScreen.periodMinutes.hasStartPlay) {
				minutesClock.displayStop();
				setClockToLastItemTime();
				minutesClock.updateAutoMode();
			}
		}
		
		private function setClockToLastItemTime():void {
			var mItem:MinutesItem = this.getMatchLastMinutesItem();
			if (mItem) {
				minutesClock.setTimeInSeconds(mItem.timeInSeconds);
			} else {
				minutesClock.setTimeInSeconds("0");
			}
		}
		
		public function editMinutesRecord(editMinutesItem:MinutesItem, teamPlayerId:String, teamSideCode:String, activityCode:String, comment:String):Boolean {
			// Rules:
			// - Can't move stop/play records from one period to another.
			// - Can't update stop time to a time lower than the previous record.
			// - If new record time belongs to another Period, move record to corresponding period.
			
			var intTime:int = int(minutesClock.getTimeInSeconds());
			var intPrevTime:int = 0;
			var intStartTime:int = 0;
			var previousMItem:MinutesItem;
			var sourceScreen:SessionScreen = SessionScreenUtils.getScreenFromScreenId(int(editMinutesItem.screenId), main.sessionView.aScreens);
			var targetScreen:SessionScreen = this.getScreenFromTime(intTime.toString());
			if (!sourceScreen) return false;
			if (editMinutesItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				if (!targetScreen) targetScreen = sourceScreen; // It is possible to update stop time to a time higher (in his own period).
			} else if (!targetScreen) return false;
			
			if (editMinutesItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY || editMinutesItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				// - Can't move stop/play records from one period to another.
				if (sourceScreen != targetScreen) return false;
				// If Stop/Start Play, keep record values.
				activityCode = editMinutesItem.activityCode;
				teamPlayerId = editMinutesItem.teamPlayerId;
				teamSideCode = editMinutesItem.teamSideCode;
			}
			
			if (editMinutesItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				if (sourceScreen && !sourceScreen.disposeFlag) {
					previousMItem = sourceScreen.periodMinutes.periodLastMinutesItemNoStopPlay;
					intStartTime = int(sourceScreen.periodMinutes.periodStartTime);
					if (previousMItem) intPrevTime = int(previousMItem.timeInSeconds);
					// - Can't update stop time to a time lower than the previous record.
					if (intTime < intPrevTime || intTime < intStartTime) {
						return false;
					}
				} else {
					return false;
				}
			}
			
			/*if (sScreen != sScreenFromTime && editMinutesItem.activityCode != MinutesGlobals.ACTIVITY_STOP_PLAY) {
				sScreenFromTime.periodMinutes.addMinutesItem(intTime.toString(), activityCode, teamPlayerId, teamSideCode, comment);
				sScreen.periodMinutes.removeMinutesItem(editMinutesItem);
			} else {
				// Update data to XML.
				editMinutesItem.updateXMLData(intTime.toString(), teamPlayerId, activityCode, comment);
			}*/
			
			// - Create record in corresponding period.
			sourceScreen.periodMinutes.removeMinutesItem(editMinutesItem);
			targetScreen.periodMinutes.addMinutesItem(intTime.toString(), activityCode, teamPlayerId, teamSideCode, comment);
			
			// If stop play is modified, adjust periods stop/start times.
			if (editMinutesItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				recalculateMinutesStartTime();
			}
			
			updateMinutesDG();
			return true;
		}
		
		public function displayPlayerList(sId:String):void {
			if (!popupPlayerList) popupPlayerList = MinutesPlayerListFormPopupBox.getInstance(main.stage);
			popupPlayerList.popupVisible = true;
			popupPlayerList.playerListOurTeam = getLineUpOurDPFromScreenId(sId);
			popupPlayerList.playerListOppTeam = getLineUpOppDPFromScreenId(sId);
		}
		
		public function getLineUpOurDPFromScreenId(sId:String):DataProvider {
			for each(var sS:SessionScreen in main.sessionView.aScreens) {
				if (String(sS.screenId) == sId) return new DataProvider(sS.periodMinutes.aLineUpOur);
			}
			return new DataProvider;
		}
		
		public function getLineUpOppDPFromScreenId(sId:String):DataProvider {
			for each(var sS:SessionScreen in main.sessionView.aScreens) {
				if (String(sS.screenId) == sId) return new DataProvider(sS.periodMinutes.aLineUpOpp);
			}
			return new DataProvider;
		}
		
		public function screenHasMinutes(sId:int):Boolean {
			if (SessionScreenUtils.getScreenFromScreenId(sId, main.sessionView.aScreens).periodMinutes.aPeriod.length > 0) return true;
			return false;
		}
		
		public function get hasMinutes():Boolean {
			if (!_minutesDP) return false;
			return (_minutesDP.length > 0)? true : false;
		}
		
		public function get playStarted():Boolean {
			if (!hasMinutes || !_minutesDP) return false;
			var _playStarted:Boolean;
			var periodsArray:Array = _minutesDP.toArray();
			for (var i:uint;i<periodsArray.length;i++) {
				if (periodsArray[i].activityCode == MinutesGlobals.ACTIVITY_START_PLAY) {
					_playStarted = true;
				} else if (periodsArray[i].activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
					_playStarted = false;
				}
			}
			return _playStarted;
		}
		
		/**
		 * If Stop Play time is modified, adjust all the periods start/stop times. 
		 */		
		private function recalculateMinutesStartTime():void {
			var startTime:int = 0;
			var sS:SessionScreen;
			var lastPeriod:SessionScreen = getLastStartedPeriod();
			var totalPeriods:int = main.sessionView.aPeriodsOnly.length;
			for (var i:uint = 0;i<totalPeriods;i++) {
				sS = main.sessionView.aPeriodsOnly[i];
				if (sS.periodMinutes) {
					if (startTime != int(sS.periodMinutes.periodStartTime)) {
						sS.periodMinutes.setPeriodStartTime(startTime, false);
					}
					if (sS == lastPeriod) break; // If no more started periods, exit loop.
					startTime = int(sS.periodMinutes.periodStopTime);
				}
			}
		}
		
		private function getLastStartedPeriod():SessionScreen {
			var aPeriods:Vector.<SessionScreen> = main.sessionView.aPeriodsOnly;
			for (var i:int = aPeriods.length-1; i>=0; i--) {
				if (aPeriods[i].periodMinutes.hasStartPlay) return aPeriods[i];
			}
			return null;
		}
		// -------------------------- End of Minutes Log ------------------------- //
		
		
		
		// ----------------------------- External Events ----------------------------- //
		public function screenReorder():void {
			// TODO:
			/*if (!mG.useMinutes || !this.hasMinutes) return;
			var sS:SessionScreen;
			var startTimeInSeconds:int = 0;
			SessionScreenUtils.sortScreensBySortOrder(main.sessionView.aScreens);
			for (var i:uint;i<main.sessionView.aScreens.length;i++) {
				sS = main.sessionView.aScreens[i];
				if (sS && !sS.disposeFlag) {
					startTimeInSeconds = sS.periodMinutes.setPeriodStartTime(startTimeInSeconds, true);
				}
			}
			updateMinutesDG();*/
		}
		
		public function screenSelected(sId:String):void {
			if (!mG.useMinutes) return;
			var sS:SessionScreen = getScreenFromId(sId);
			if (!sS) return;
			minutesEditor.updatePlayerNames();
		}
		
		public function screenDeleted(sId:String):void {
			if (!mG.useMinutes) return;
			updateMinutesDG();
		}
		
		public function teamListChanged(sScreen:SessionScreen):void {
			if (!mG.useMinutes || !sScreen ) return;
			minutesEditor.updatePlayerNames();
		}
		
		public function teamListPlayerNameChanged():void {
			if (!mG.useMinutes) return;
			// Update player name drop down box.
			minutesEditor.updatePlayerNames();
			// Update minutes data grid.
			MinutesGlobals.getInstance().playerNamesChanged = true;
			updateMinutesDG();
			MinutesGlobals.getInstance().playerNamesChanged = false;
		}
		
		public function playerSelected(p:Player):void {
			if (!mG.useMinutes || !p || !p.teamPlayer || !minutesEditor || !this.hasMinutes) return;
			var teamSide:String = PRTeamManager.getInstance().getTeamSideFromKitId(p.kitId);
			var teamPlayerId:String = p.teamPlayerId;
			minutesEditor.selectPlayerName(teamPlayerId, teamSide);
		}
		
		public function playerDeselected():void {
			if (!mG.useMinutes || !minutesEditor || !this.hasMinutes) return;
			minutesEditor.deselectPlayerName();
		}
		
		public function resetMinutes():void {
			if (!minutesInitialized || !minutesDG || !main.sessionView || !minutesClock) return;
			minutesDG.dataProvider.removeAll();
			for each(var sS:SessionScreen in main.sessionView.aScreens) {
				if (sS && !sS.disposeFlag && sS.periodMinutes) {
					sS.periodMinutes.clearMinutesList(true);
					sS.periodMinutes.resetTimeSpent();
				}
			}
			main.sessionView.aScreens
			minutesClock.clockStopAndReset();
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.MINUTES_UPDATE_SCORE));
		}
		
		public function updateScoreAndTimeSpent():void {
			//If minutes = on, reset score and timeSpent.
			//If minutes = off, keep score and round timeSpent.
			if (!main.sessionView || !main.sessionView.aScreens) return;
			for each(var sS:SessionScreen in main.sessionView.aScreens) {
				if (sS && !sS.disposeFlag && sS.periodMinutes) {
					if (mG.useMinutes) {
						sS.periodMinutes.resetTimeSpent();
					} else {
						sS.periodMinutes.roundUpTimeSpent();
					}
				}
			}
			if (mG.useMinutes) {
				mG.scoreOpp = 0;
				mG.scoreOur = 0;
			}
		}
		
		public function stopClock():void {
			minutesClock.clockStop();
		}
		
		public function get minutesInitialized():Boolean {
			return _minutesInitialized;
		}
		
		public function validateMinutes():void {
			// If Minutes != "Off", validate existing records.
			if (mG.useMinutes) {
				validateStopMatch();
				return;
			}
			var startTime:int = 0;
			var duration:int;
			var sS:SessionScreen;
			// Else, create auto-minutes.
			SessionScreenUtils.sortScreensBySortOrder(main.sessionView.aScreens);
			for (var i:uint = 0;i<main.sessionView.aScreens.length;i++) {
				sS = main.sessionView.aScreens[i];
				if (sS && !sS.disposeFlag && sS.periodMinutes) {
					duration = int(sS.getScreenXML(false, false)._timeSpent.text());
					if (duration > 0) {
						sS.periodMinutes.clearMinutesList(true);
						sS.periodMinutes.addStartPlayRecord(startTime.toString());
						sS.periodMinutes.addStopPlayRecord(String(duration + startTime));
						sS.periodMinutes.saveToXML();
						startTime = duration + startTime;
					} else {
						sS.periodMinutes.clearMinutesList(false);
						sS.periodMinutes.saveToXML();
					}
				}
			}
		}
		
		private function validateStopMatch():void {
			if (!this.hasMinutes) return;
			var s:SessionScreen = this.getUnfinishedScreen();
			if (!s || !s.periodMinutes.aPeriod || s.periodMinutes.aPeriod.length == 0) return; 
			logger.addText("(A) - No final 'Stop Play' in Minutes log. Adding from last record time + 1.", false);
			s.periodMinutes.forceStopPlay();
		}
		// -------------------------- End of External Events ------------------------- //
		
		
		
		
		// ----------------------------- 3D Screen Substitution ----------------------------- //
		public function playerSubstitution(sScreen:SessionScreen, playerOutSettings:PlayerSettings, playerInSettings:PlayerSettings) {
			// TODO. check if player already exists?
			if (!this.playStarted || !mG.useMinutes || !sScreen || !playerOutSettings || !playerInSettings) return;
			if (mG.autoMode) {
				addSubstitution(sScreen, playerOutSettings, playerInSettings);
			} else {
				confirmSettings = {s:sScreen, p1:playerOutSettings, p2:playerInSettings};
				confirmSubstitution();
			}
		}
		
		private function confirmSubstitution():void {
			if (!confirmSettings) return;
			minutesClock.clockEditLocked = true;
			removeConfirmListeners();
			if (!minutesConfirm) minutesConfirm = MinutesClockConfirmPopupBox.getInstance(main.stage);
			var strActivity1:String = getActivityNameFromCode(MinutesGlobals.ACTIVITY_SUBSTITUTED);
			var strActivity2:String = getActivityNameFromCode(MinutesGlobals.ACTIVITY_SUBSTITUTE);
			var strName1:String = confirmSettings.p1._playerName;
			var strName2:String = confirmSettings.p2._playerName;
			var strMsg:String = '<font color="'+confirmRed+'"><p align="center"><b>'+strActivity1+': '+strName1+'</b></font><br>'+
				'<font color="'+confirmGreen+'"><b>'+strActivity2+': '+strName2+'</b></p></font>';
			var intTimeInSeconds:int = int(minutesClock.getTimeInSeconds());
			var strMinutes:String = getMinutesFromTime(intTimeInSeconds);
			var strSeconds:String = getSecondsFromTime(intTimeInSeconds);
			minutesConfirm.addEventListener(SSPMinutesEvent.CONFIRM_SUBSTITUTION, onSubstitutionConfirmed, false, 0, true);
			minutesConfirm.addEventListener(SSPMinutesEvent.CONFIRM_CANCEL, onConfirmCanceled, false, 0, true);
			minutesConfirm.setData(confirmSettings.s, SSPMinutesEvent.CONFIRM_SUBSTITUTION, strMsg, strMinutes, strSeconds);
			if (!minutesConfirm.popupVisible) minutesConfirm.popupVisible = true;
		}
		
		private function onSubstitutionConfirmed(e:SSPMinutesEvent):void {
			removeConfirmListeners();
			minutesClock.clockEditLocked = false;
			if (confirmSettings) {
				minutesClock.setTimeInSeconds(e.eventData);
				addSubstitution(confirmSettings.s, confirmSettings.p1, confirmSettings.p2);
				confirmSettings = null;
			}
		}
		
		private function addSubstitution(sScreen:SessionScreen, playerOutSettings:PlayerSettings, playerInSettings:PlayerSettings) {
			// Create substitution records.
			var strTimeInSeconds:String = minutesClock.getTimeInSeconds();
			this.addMinutesRecord(sScreen, strTimeInSeconds, MinutesGlobals.ACTIVITY_SUBSTITUTED, playerOutSettings._teamPlayerId, playerOutSettings._teamSide);
			this.addMinutesRecord(sScreen, strTimeInSeconds, MinutesGlobals.ACTIVITY_SUBSTITUTE, playerInSettings._teamPlayerId, playerInSettings._teamSide);
		}
		
		private function onConfirmCanceled(e:SSPMinutesEvent):void {
			confirmSettings = null;
			removeConfirmListeners();
			minutesClock.clockEditLocked = false;
		}
		
		private function removeConfirmListeners():void {
			if (!minutesConfirm) return;
			minutesConfirm.removeEventListener(SSPMinutesEvent.CONFIRM_SUBSTITUTION, onSubstitutionConfirmed);
			minutesConfirm.removeEventListener(SSPMinutesEvent.CONFIRM_RED_CARD, onRedCardConfirmed);
			minutesConfirm.removeEventListener(SSPMinutesEvent.CONFIRM_CANCEL, onConfirmCanceled);
		}
		// -------------------------- End of 3D Screen Substitution ------------------------- //
		
		
		
		// ----------------------------- 3D Screen Removed ----------------------------- //
		public function playerRemoved(sScreen:SessionScreen, playerSettings:PlayerSettings):void {
			if (!this.playStarted || !mG.useMinutes || !sScreen || !playerSettings || hasRedCard(playerSettings._teamPlayerId, playerSettings._teamSide)) return;
			if (mG.autoMode) {
				addRedCard(sScreen, playerSettings);
			} else {
				confirmSettings = {s:sScreen, p1:playerSettings};
				confirmRedCard();
			}
		}
		
		private function confirmRedCard():void {
			if (!confirmSettings) return;
			removeConfirmListeners();
			if (!minutesConfirm) minutesConfirm = MinutesClockConfirmPopupBox.getInstance(main.stage);
			var strActivity1:String = getActivityNameFromCode(MinutesGlobals.ACTIVITY_RED_CARD);
			var strName1:String = confirmSettings.p1._playerName;
			var strMsg:String = '<p align="center"><font color="'+confirmRed+'"><b>'+strActivity1+': '+strName1+'</b></font></p>';
			var intTimeInSeconds:int = int(minutesClock.getTimeInSeconds());
			var strMinutes:String = getMinutesFromTime(intTimeInSeconds);
			var strSeconds:String = getSecondsFromTime(intTimeInSeconds);
			minutesConfirm.addEventListener(SSPMinutesEvent.CONFIRM_RED_CARD, onRedCardConfirmed, false, 0, true);
			minutesConfirm.addEventListener(SSPMinutesEvent.CONFIRM_CANCEL, onConfirmCanceled, false, 0, true);
			minutesConfirm.setData(confirmSettings.s, SSPMinutesEvent.CONFIRM_RED_CARD, strMsg, strMinutes, strSeconds);
			if (!minutesConfirm.popupVisible) minutesConfirm.popupVisible = true;
		}
		
		private function onRedCardConfirmed(e:SSPMinutesEvent):void {
			removeConfirmListeners();
			minutesClock.clockEditLocked = false;
			if (confirmSettings) {
				minutesClock.setTimeInSeconds(e.eventData);
				addRedCard(confirmSettings.s, confirmSettings.p1);
				confirmSettings = null;
			}
		}
		
		private function addRedCard(sScreen:SessionScreen, playerSettings:PlayerSettings):void {
			addMinutesRecord(sScreen, minutesClock.getTimeInSeconds(), MinutesGlobals.ACTIVITY_RED_CARD, playerSettings._teamPlayerId, playerSettings._teamSide, "");
		}
		// -------------------------- End of 3D Screen Removed ------------------------- //
	}
}