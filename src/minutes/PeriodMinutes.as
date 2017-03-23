package src.minutes
{
	import src.header.ScoreData;
	import src.team.PRTeamManager;
	import src.team.TeamGlobals;
	
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.models.soccer.players.Player;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;

	public class PeriodMinutes
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mG:MinutesGlobals = MinutesGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var sScreen:SessionScreen;
		private var screenXML:XML;
		private var _screenId:String;
		private var _aPeriodMinutes:Vector.<MinutesItem> = new Vector.<MinutesItem>();
		private var _aPeriodLineUpOur:Vector.<MinutesItem> = new Vector.<MinutesItem>();
		private var _aPeriodLineUpOpp:Vector.<MinutesItem> = new Vector.<MinutesItem>();
		private var _alineUpOur:Array; // For Minutes' Player List.
		private var _alineUpOpp:Array; // For Minutes' Player List.
		
		/**
		 * This object is part of SessionScreen.as.
		 * It contains the minutes log for that screen.
		 *  
		 * @param screenId String. The screenId it belongs to.
		 * @param screenXML XML. SessionScreen's XML.
		 * 
		 */		
		public function PeriodMinutes(sScreen:SessionScreen)
		{
			this.sScreen = sScreen;
			var sXML:XML = sScreen.getScreenXML(false, false);
			this.screenXML = (sXML)? sXML : new XML(<meta_data/>);
			init();
		}
		
		// ----------------------------- Inits ----------------------------- //
		private function init():void {
			// Get both pr_minutes and session_minutes logs, but without _activityCode.
			var i:uint;
			var periodXMLList:XMLList = new XMLList();
			var mItem:MinutesItem;
			//strLineUpActivityCode = MinutesGlobals.ACTIVITY_LINE_UP;
			//minutesXML.appendChild(screenXML.pr_minutes.(element(_activityCode) != strLineUpActivityCode));
			//minutesXML.appendChild(screenXML.session_minutes.(element(_activityCode) != strLineUpActivityCode));
			//periodXMLList = minutesXML.children();
			
			for each (var xml:XML in screenXML.pr_minutes) {
				if (xml._activityCode.text() != MinutesGlobals.ACTIVITY_LINE_UP) {
					periodXMLList += xml;
				}
			}
			
			for each (var xml:XML in screenXML.session_minutes) {
				if (xml._activityCode.text() != MinutesGlobals.ACTIVITY_LINE_UP) {
					periodXMLList += xml;
				}
			}
			
			_aPeriodMinutes = new Vector.<MinutesItem>();
			for (i=0;i<periodXMLList.length();i++) {
				mItem = new MinutesItem(periodXMLList[i]);
				_aPeriodMinutes.push(mItem);
				addToScore(mItem.activityCode, mItem.teamSideCode);
			}
			
			// Set screenId.
			_screenId = String(sScreen.screenId);
			for each(var mItem:MinutesItem in _aPeriodMinutes) {
				mItem.setScreenId(_screenId);
			}
			
			MinutesManager.sortMinutesItems(_aPeriodMinutes);
		}
		// -------------------------- End of Inits ----------------------------- //
		
		
		
		// ----------------------------- Minutes ----------------------------- //
		public function addMinutesItem(strTimeInSeconds:String, activityCode:String, teamPlayerId:String = "", teamSideCode:String = "", strComment:String = ""):MinutesItem {
			//var screenId:String = String(sScreen.screenId);
			var intTimeInSeconds:int = int(strTimeInSeconds);
			var intPeriodStartTime:int = int(sScreen.periodMinutes.periodStartTime);
			var intMaxSeconds:int = (SSPSettings.defaultMaxTimeSpent * 60);
			var isStopPeriod:Boolean = (activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY)? true : false;
			var strOffsetInSeconds:String;
			var intOffsetInSeconds:int;
			
			if (activityCode != MinutesGlobals.ACTIVITY_START_PLAY) {
				if (!this.hasStartPlay) return null;
				intOffsetInSeconds = intTimeInSeconds - intPeriodStartTime;
			}
			
			// Validate max period time.
			if (intOffsetInSeconds > intMaxSeconds) {
				if (isStopPeriod) {
					intOffsetInSeconds = intMaxSeconds;
				} else {
					intOffsetInSeconds = intMaxSeconds - 1;
				}
				strTimeInSeconds = String(intPeriodStartTime + intOffsetInSeconds);
			}
			
			strOffsetInSeconds = intOffsetInSeconds.toString();
			
			// Create MinutesItem.
			var mItem:MinutesItem = getNewMinutesItem(teamPlayerId, teamSideCode, activityCode, strTimeInSeconds, strOffsetInSeconds, strComment);
			if (mItem) {
				if (mG.useMinutes && mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) screenXML._timeSpent = MinutesManager.secondsToMinutes(mItem.offsetInSeconds); // Update Time Spent in minutes.
				_aPeriodMinutes.push(mItem);
				MinutesManager.sortMinutesItems(_aPeriodMinutes);
				addToScore(mItem.activityCode, mItem.teamSideCode);
				return mItem;
			}
			return null;
		}
		
		public function addStartPlayRecord(strTimeInSeconds:String):MinutesItem {
			if (this.hasStartPlay) return null;
			return addMinutesItem(strTimeInSeconds, MinutesGlobals.ACTIVITY_START_PLAY, "0", "", "");
		}
		
		public function addStopPlayRecord(strTimeInSeconds:String):MinutesItem {
			if (this.hasStopPlay) return null;
			var mItem:MinutesItem = this.periodLastMinutesItem;
			if (int(strTimeInSeconds) <= int(mItem.timeInSeconds) ||
				mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				return null;
			}
			return addMinutesItem(strTimeInSeconds, MinutesGlobals.ACTIVITY_STOP_PLAY, "0", "", "");
		}
		
		public function removeMinutesItem(mi:MinutesItem):void {
			// TODO: validate item? (if start_play, stop_play, etc).
			this.removeMinutesItemFromArray(mi, _aPeriodMinutes);
			removeFromScore(mi.activityCode, mi.teamSideCode);
		}
		
		public function clearMinutesList(recalculateLineUp:Boolean):void {
			_aPeriodLineUpOur = new Vector.<MinutesItem>();
			_aPeriodLineUpOpp = new Vector.<MinutesItem>();
			_aPeriodMinutes = new Vector.<MinutesItem>();
			if (recalculateLineUp) updateTeamsLineUp();
		}
		
		public function resetTimeSpent():void {
			// Used only when useMinutes = true.
			if (mG.useMinutes) screenXML._timeSpent = "0";
		}
		
		public function roundUpTimeSpent():void {
			// Used only when useMinutes = false.
			var intTS:int = MiscUtils.roundUpToN(int(screenXML._timeSpent), 5, true);
			if (intTS < 0) intTS = 0; // 0 if negative number.
			if (!mG.useMinutes) screenXML._timeSpent = intTS.toString();
		}
		
		/**
		 * Sets a new Start Time for this period and recalculate all the records time. 
		 * @param newStartTimeInSeconds int. The new time this period will start at.
		 * @param forceStop Boolean. True to include a stop time (and start time if needed) if it doesn't exists.
		 * @return int. The Period's new stop time.
		 * @see <code>MinutesManager.screenReorder</code>
		 * @see <code>MinutesManager.validateMinutes</code>
		 */		
		public function setPeriodStartTime(newStartTimeInSeconds:int, forceStop:Boolean):int {
			MinutesManager.sortMinutesItems(_aPeriodMinutes);
			var intNewTime:int;
			var intOffset:int;
			if (_aPeriodMinutes.length == 0) {
				logger.addText("(A) - Unstarted Period found while updating Period Start Time. Adding zero length Start and Stop records.", false);
				addMinutesItem(newStartTimeInSeconds.toString(), MinutesGlobals.ACTIVITY_START_PLAY, "0", "", "");
				addMinutesItem(newStartTimeInSeconds.toString(), MinutesGlobals.ACTIVITY_STOP_PLAY, "0", "", "");
				return newStartTimeInSeconds;
			}
			for (var i:uint;i<_aPeriodMinutes.length;i++) {
				intOffset = int(_aPeriodMinutes[i].offsetInSeconds);
				intNewTime = newStartTimeInSeconds + intOffset;
				_aPeriodMinutes[i].timeInSeconds = intNewTime.toString();
			}
			if (this.hasStopPlay) {
				return int(this.periodStopTime);
			} else {
				// If no stop time, add it.
				if (forceStop) this.forceStopPlay();
			}
			return int(this.periodStopTime);
		}
		
		public function forceStopPlay():MinutesItem {
			/*if (this.hasStopPlay) {
			Logger.getInstance().addText("Can't force minutes stop play, period minutes already contains 'stop_play'.", true);
			return;
			}*/
			var mItem:MinutesItem = this.periodLastMinutesItem;
			if (!mItem) {
				logger.addText("(A) - Can't force minutes stop play, period does not contains minutes.", false);
				return null;
			}
			if (mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) return null;
			var stopTimeInSeconds:String = String(int(mItem.timeInSeconds) + 1);
			return addMinutesItem(stopTimeInSeconds, MinutesGlobals.ACTIVITY_STOP_PLAY, "0", "", "");
		}
		
		private function getNewMinutesItem(teamPlayerId:String, teamSideCode:String, activityCode:String, strTimeInSeconds:String, strOffsetInSeconds:String, strComment:String):MinutesItem {
			var newXML:XML;
			var mItem:MinutesItem;
			if (teamSideCode == TeamGlobals.TEAM_OUR) {
				newXML = (sG.usePlayerRecords)? MinutesGlobals.SKELETON_PR.copy() : MinutesGlobals.SKELETON_SESSION.copy();
			} else {
				newXML = MinutesGlobals.SKELETON_SESSION.copy();
			}
			newXML._screenId = screenId;
			newXML._time = strTimeInSeconds;
			newXML._offset = strOffsetInSeconds;
			if (MinutesManager.isPlayerRecordMinutes(newXML)) {
				newXML._teamPlayerId = teamPlayerId;
			} else {
				newXML._nonprTeamPlayerId = teamPlayerId;
			}
			newXML._activityCode = activityCode;
			newXML._comment = strComment;
			mItem = new MinutesItem(newXML);
			return mItem;
		}
		// -------------------------- End of Minutes ------------------------- //
		
		
		
		// ----------------------------- Line-Up ----------------------------- //
		/**
		 * The Line-up is calculated in two steps:
		 * 1) Get all current players on pitch.
		 * 2) Calculate who was not on pitch at the begining by iterating the minutes array in reverse order.
		 */		
		private function updateTeamsLineUp():void {
			var aPeriodLineUpTemp:Vector.<MinutesItem> = new Vector.<MinutesItem>();
			var aPlayersTemp:Vector.<MinutesItem> = new Vector.<MinutesItem>();
			var mItem:MinutesItem;
			var pItem:MinutesItem;
			var lineUpItem:MinutesItem;
			var isOnLineUp:Boolean;
			var i:int;
			
			_aPeriodLineUpOur = new Vector.<MinutesItem>();
			_aPeriodLineUpOpp = new Vector.<MinutesItem>();
			_alineUpOur = [];
			_alineUpOpp = [];
			
			// Get all players on pitch as MinutesItem's.
			for each(var p:Player in sScreen.aPlayers) {
				if (p.teamPlayer && !p.teamPlayerEmpty) aPeriodLineUpTemp.push(getMinutesItemFrom3DPlayer(p));
			}
			
			// Get Players Array.
			for(i=0;i<_aPeriodMinutes.length;i++) {
				mItem = _aPeriodMinutes[i];
				if (mItem) {
					if (mG.playerNamesChanged) mItem.updateName();
					if (mItem.activityCode == MinutesGlobals.ACTIVITY_SUBSTITUTE ||
						mItem.activityCode == MinutesGlobals.ACTIVITY_SUBSTITUTED ||
						mItem.activityCode == MinutesGlobals.ACTIVITY_RED_CARD
					) {
						if (!isPlayerMinutesInArray(mItem, aPlayersTemp)) aPlayersTemp.push(mItem);
					}
				}
			}
			
			// Check each player initial state.
			for each(pItem in aPlayersTemp) {
				isOnLineUp = false;
				// Loop Minutes backwards.
				for (i = _aPeriodMinutes.length-1; i>=0; i--) {
					mItem = _aPeriodMinutes[i];
					if (mItem.teamPlayerId == pItem.teamPlayerId
						&& mItem.teamSideCode == pItem.teamSideCode) {
						
						if (mItem.activityCode == MinutesGlobals.ACTIVITY_SUBSTITUTE
							|| mItem.activityCode == MinutesGlobals.ACTIVITY_SUBSTITUTED
							|| mItem.activityCode == MinutesGlobals.ACTIVITY_RED_CARD
						) {
							if (mItem.activityCode == MinutesGlobals.ACTIVITY_SUBSTITUTED
								|| mItem.activityCode == MinutesGlobals.ACTIVITY_RED_CARD
							) {
								isOnLineUp = true;
							} else if (mItem.activityCode == MinutesGlobals.ACTIVITY_SUBSTITUTE) {
								isOnLineUp = false;
							}
						}
					}
				}
				
				if (isOnLineUp) {
					if (!isPlayerMinutesInArray(pItem, aPeriodLineUpTemp)) aPeriodLineUpTemp.push(pItem);
				} else {
					removeMinutesItemFromLineUp(pItem, aPeriodLineUpTemp);
				}
			}
			
			// Split players in teams.
			for each(mItem in aPeriodLineUpTemp) {
				// Create lineUp if no lineup code (because it wasn't on 3D Pitch).
				if (mItem.activityCode != MinutesGlobals.ACTIVITY_LINE_UP) {
					lineUpItem = getNewMinutesItem(mItem.teamPlayerId, mItem.teamSideCode, MinutesGlobals.ACTIVITY_LINE_UP, this.periodStartTime, this.periodStartOffset, mItem.Comment);
				} else {
					lineUpItem = mItem.clone();
				}
				if (lineUpItem.teamSideCode == TeamGlobals.TEAM_OUR) {
					_aPeriodLineUpOur.push(lineUpItem);
					_alineUpOur.push({label:lineUpItem.Object, data:lineUpItem});
				} else {
					_aPeriodLineUpOpp.push(lineUpItem);
					_alineUpOpp.push({label:lineUpItem.Object, data:lineUpItem});
				}
			}
		}
		
		private function removeMinutesItemFromLineUp(pItem:MinutesItem, aMinutes:Vector.<MinutesItem>):void {
			for each (var mItem:MinutesItem in aMinutes) {
				if (mItem.teamPlayerId == pItem.teamPlayerId
					&& mItem.teamSideCode == pItem.teamSideCode
				) {
					aMinutes.splice(aMinutes.indexOf(mItem),1);
				}
			}
		}
		
		private function removeMinutesItemFromArray(pItem:MinutesItem, aMinutes:Vector.<MinutesItem>):void {
			for each (var mItem:MinutesItem in aMinutes) {
				if (mItem.offsetInSeconds == pItem.offsetInSeconds
					&& mItem.activityCode == pItem.activityCode
					&& mItem.teamPlayerId == pItem.teamPlayerId
					&& mItem.teamSideCode == pItem.teamSideCode
					&& mItem.Comment == pItem.Comment
				) {
					aMinutes.splice(aMinutes.indexOf(mItem),1);
				}
			}
		}
		
		/*private function removePlayerMinutesFromArray(pItem:MinutesItem, aMinutes:Vector.<MinutesItem>):void {
			for each (var mItem:MinutesItem in aMinutes) {
				if (mItem.teamPlayerId == pItem.teamPlayerId
					&& mItem.teamSideCode == pItem.teamSideCode) {
					aMinutes.splice(aMinutes.indexOf(mItem),1);
				}
			}
		}*/
		
		private function isPlayerMinutesInArray(pItem:MinutesItem, aMinutes:Vector.<MinutesItem>):Boolean {
			for each (var mItem:MinutesItem in aMinutes) {
				if (mItem.teamPlayerId == pItem.teamPlayerId
					&& mItem.teamSideCode == pItem.teamSideCode) {
					return true;
				}
			}
			return false;
		}
		
		private function getMinutesItemFrom3DPlayer(p:Player):MinutesItem {
			var newXML:XML;
			var newItem:MinutesItem;
			var teamSideCode:String = PRTeamManager.getInstance().getTeamSideFromKitId(p.kitId);
			if (teamSideCode == TeamGlobals.TEAM_OUR) {
				newXML = (sG.usePlayerRecords)? MinutesGlobals.SKELETON_PR.copy() : MinutesGlobals.SKELETON_SESSION.copy();
			} else {
				newXML = MinutesGlobals.SKELETON_SESSION.copy();
			}
			newXML._screenId = _screenId;
			newXML._time = this.periodStartTime;
			newXML._offset = this.periodStartOffset;
			if (MinutesManager.isPlayerRecordMinutes(newXML)) {
				newXML._teamPlayerId = p.teamPlayerId;
			} else {
				newXML._nonprTeamPlayerId = p.teamPlayerId;
			}
			newXML._activityCode = MinutesGlobals.ACTIVITY_LINE_UP;
			newXML._comment = "";
			newItem = new MinutesItem(newXML);
			return newItem;
		}
		// -------------------------- End of Line-Up ------------------------- //
		
		
		
		// ----------------------------- Score ----------------------------- //
		private function addToScore(activityCode:String, teamSideCode:String):void {
			if (activityCode == MinutesGlobals.ACTIVITY_GOAL) {
				if (teamSideCode == TeamGlobals.TEAM_OUR) {
					mG.scoreOur++;
				} else {
					mG.scoreOpp++;
				}
			} else if (activityCode == MinutesGlobals.ACTIVITY_OWN_GOAL) {
				if (teamSideCode == TeamGlobals.TEAM_OUR) {
					mG.scoreOpp++;
				} else {
					mG.scoreOur++;
				}
			}
		}
		
		private function removeFromScore(activityCode:String, teamSideCode:String):void {
			if (activityCode == MinutesGlobals.ACTIVITY_GOAL) {
				if (teamSideCode == TeamGlobals.TEAM_OUR) {
					mG.scoreOur--;
				} else {
					mG.scoreOpp--;
				}
			} else if (activityCode == MinutesGlobals.ACTIVITY_OWN_GOAL) {
				if (teamSideCode == TeamGlobals.TEAM_OUR) {
					mG.scoreOpp--;
				} else {
					mG.scoreOur--;
				}
			}
			//if (scoreData.scoreOur < 0) scoreData.scoreOur = 0;
			//if (scoreData.scoreOpp < 0) scoreData.scoreOpp = 0;
		}
		// -------------------------- End of Score -------------------------- //
		
		
		
		// ----------------------------- Properties ----------------------------- //
		public function get periodStartTime():String {
			for (var i:int;i<_aPeriodMinutes.length;i++) {
				if (_aPeriodMinutes[i].activityCode == MinutesGlobals.ACTIVITY_START_PLAY) return _aPeriodMinutes[i].timeInSeconds;
			}
			return "0";
		}
		
		public function get periodStopTime():String {
			for (var i:int;i<_aPeriodMinutes.length;i++) {
				if (_aPeriodMinutes[i].activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) return _aPeriodMinutes[i].timeInSeconds;
			}
			return "0";
		}
		
		public function get periodStartOffset():String {
			return "0"; // Play Start offset is always 0.
		}
		
		public function get periodLastMinutesItemNoStopPlay():MinutesItem {
			if (mG.playerNamesChanged) updateTeamsLineUp();
			if (_aPeriodMinutes.length == 0) return null;
			MinutesManager.sortMinutesItems(_aPeriodMinutes);
			var mItem:MinutesItem;
			for (var i:int = _aPeriodMinutes.length-1; i>=0; i--) {
				mItem = _aPeriodMinutes[i];
				if (mItem && mItem.activityCode != MinutesGlobals.ACTIVITY_STOP_PLAY) {
					return mItem;
				}
			}
			return null;
		}
		
		public function get periodLastMinutesItem():MinutesItem {
			if (mG.playerNamesChanged) updateTeamsLineUp();
			if (_aPeriodMinutes.length == 0) return null;
			MinutesManager.sortMinutesItems(_aPeriodMinutes);
			return _aPeriodMinutes[_aPeriodMinutes.length-1];
		}
		
		public function get aPeriod():Array {
			if (mG.playerNamesChanged) updateTeamsLineUp();
			MinutesManager.sortMinutesItems(_aPeriodMinutes);
			var dataArrayrray:Array = MiscUtils.vectorToArray(_aPeriodMinutes);
			if (!dataArrayrray) return [];
			return dataArrayrray;
		}
		
		public function get aLineUpOur():Array {
			updateTeamsLineUp();
			return _alineUpOur;
		}
		
		public function get aLineUpOpp():Array {
			updateTeamsLineUp();
			return _alineUpOpp;
		}
		
		public function get screenId():String {
			return _screenId;
		}
		
		public function get hasStartPlay():Boolean {
			for (var i:uint;i<_aPeriodMinutes.length;i++) {
				if (_aPeriodMinutes[i].activityCode == MinutesGlobals.ACTIVITY_START_PLAY) return true;
			}
			return false;
		}
		
		public function get hasStopPlay():Boolean {
			for (var i:uint;i<_aPeriodMinutes.length;i++) {
				if (_aPeriodMinutes[i].activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) return true;
			}
			return false;
		}
		
		public function playerHasRedCard(teamPlayerId:String, teamSide:String):Boolean {
			for (var i:uint;i<_aPeriodMinutes.length;i++) {
				if (_aPeriodMinutes[i].teamPlayerId == teamPlayerId &&
					_aPeriodMinutes[i].teamSideCode == teamSide &&
					_aPeriodMinutes[i].activityCode == MinutesGlobals.ACTIVITY_RED_CARD) {
					return true;
				}
			}
			return false;
		}
		// -------------------------- End of Properties ------------------------- //
		
		
		
		
		public function saveToXML():void {
			var mItem:MinutesItem;
			var strTimeSpent:String;
			
			// Clear old minutes in XML.
			delete screenXML.pr_minutes;
			delete screenXML.session_minutes;
			
			// Sort Minutes.
			MinutesManager.sortMinutesItems(_aPeriodMinutes);
			
			// Add current minutes.
			for each (mItem in _aPeriodMinutes) {
				screenXML.appendChild(mItem.minutesXML.copy());
			}
			
			if (this.hasStartPlay) {
				// Add current line-up.
				updateTeamsLineUp();
				for each (mItem in _aPeriodLineUpOur) {
					screenXML.appendChild(mItem.minutesXML.copy());
				}
				for each (mItem in _aPeriodLineUpOpp) {
					screenXML.appendChild(mItem.minutesXML.copy());
				}
			}
			
			// Update Time Spent.
			if (mG.useMinutes) {
				strTimeSpent = String(int(this.periodStopTime) - int(this.periodStartTime));
				screenXML._timeSpent = MinutesManager.secondsToMinutes(strTimeSpent);
			}
		}
		
		public function dispose():void {
			screenXML = new XML(<meta_data/>);
			_aPeriodMinutes = new Vector.<MinutesItem>();
			_aPeriodLineUpOur = new Vector.<MinutesItem>();
			_aPeriodLineUpOpp = new Vector.<MinutesItem>();
		}
	}
}