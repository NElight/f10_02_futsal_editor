package src.team
{
	import fl.data.DataProvider;
	
	import src3d.SessionGlobals;
	import src3d.models.KitsLibrary;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;

	public class PRTeamManager
	{
		// Singleton.
		private static var _self:PRTeamManager;
		private static var _allowInstance:Boolean = false;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var tG:TeamGlobals = TeamGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var _teamDataXML:XML;
		private var _teamSquadsXML:XML;
		private var _teamOursXML:XML;
		private var _teamOppXML:XML;
		private var _teamPositionsXML:XML;
		
		public function PRTeamManager()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():PRTeamManager {
			if(_self == null) {
				_allowInstance=true;
				_self = new PRTeamManager();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		private function getTeamData():void {
			if (_teamSquadsXML) return;
			//squadsList = this.teamDataXML.children().(localName() != "pr_squad").copy();
			_teamSquadsXML = new XML("<data></data>");
			_teamSquadsXML.appendChild(this.teamDataSourceXML.pr_squad);
			var tmpPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.pr_team_player;
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			var tmpPlayersXMLList:XMLList = this.teamDataSourceXML.pr_player;
			var tmpPlayerDetailsXMLList:XMLList;
			var tmpPlayerPositionsXMLList:XMLList = this.teamDataSourceXML.player_position;
			
			var strSquadId:String;
			var strPlayerId:String;
			var strTeamSide:String;
			
			// Squads.
			for each(var sqdXML:XML in _teamSquadsXML.children()) {
				strSquadId = sqdXML._squadId.text();
				sqdXML.appendChild(tmpPRTeamPlayersXMLList.(_squadId == strSquadId));
				for each(var playerXML:XML in sqdXML.pr_team_player) {
					strPlayerId = playerXML._prPlayerId.text();
					tmpPlayerDetailsXMLList = tmpPlayersXMLList.(_prPlayerId == strPlayerId).children().(localName() != "_prPlayerId");
					playerXML.appendChild(tmpPlayerDetailsXMLList);
				}
			}
			
			// Last Team Ours.
			_teamOursXML = new XML("<data></data>");
			if (sG.usePlayerRecords) {
				_teamOursXML.appendChild(tmpPRTeamPlayersXMLList.(_lastTeam == "TRUE"));
			} else {
				strTeamSide = TeamGlobals.TEAM_OUR;
				_teamOursXML.appendChild(tmpNonPRTeamPlayersXMLList.(_teamSide == strTeamSide));
			}
			
			// Last Team Opposition.
			strTeamSide = TeamGlobals.TEAM_OPP;
			_teamOppXML = new XML("<data></data>");
			_teamOppXML.appendChild(tmpNonPRTeamPlayersXMLList.(_teamSide == strTeamSide));
			
			// Player Positions.
			_teamPositionsXML = new XML("<data></data>");
			_teamPositionsXML.appendChild( MiscUtils.sortXMLList(tmpPlayerPositionsXMLList, "_playerPositionId") );
		}
		
		public function get teamSquadsXML():XML {
			if (!_teamSquadsXML) getTeamData();
			return _teamSquadsXML;
		}
		
		public function get teamOursXML():XML {
			if (!_teamOursXML) getTeamData();
			return _teamOursXML;
		}
		
		public function get teamOppXML():XML {
			if (!_teamOppXML) getTeamData();
			return _teamOppXML;
		}
		
		public function get teamPositionsXML():XML {
			if (!_teamPositionsXML) getTeamData();
			return _teamPositionsXML;
		}
		
		private function get teamDataSourceXML():XML {
			if (!_teamDataXML) {
				var tdXMLList:XMLList = sG.sessionDataXML.children().(localName() != "session").copy();
				_teamDataXML = new XML("<team_data>"+tdXMLList+"</team_data>");
			}
			return _teamDataXML;
		}
		
		public function get teamWePlayHome():Boolean {
			var wp:String = sG.sessionDataXML.session._teamWePlay.text();
			if (!wp || wp == "") wp = tG.aWePlay[0];
			return (wp == tG.aWePlay[0])? true : false;
		}
		
		public function getFirstCoachSquadId():int {
			getTeamData();
			var coachSquadId:int;
			var coachSquad:XMLList = this.teamSquadsXML.pr_squad.(_coachSquad == "TRUE");
			if (!coachSquad) coachSquad = new XMLList();
			if (coachSquad.length() < 1) {
				coachSquadId = -1;
			} else {
				coachSquadId = int(coachSquad[0]._squadId.text());
			}
			return coachSquadId;
		}
		
		public function getFixtureDataProvider():DataProvider {
			getTeamData();
			var coachSquadXMLList:XMLList = this.teamSquadsXML.pr_squad.(_coachSquad == "TRUE");
			if (!coachSquadXMLList) coachSquadXMLList = new XMLList();
			var aDP:Array = [];
			var strLbl:String;
			var strData:String;
			for each(var obj:XML in coachSquadXMLList) {
				strLbl = obj._squadName.text();
				strData = obj._squadId.text();
				aDP.push({label:strLbl, data:strData});
			}
			return new DataProvider(aDP);
		}
		
		public function getSquadSelectorDataProvider():DataProvider {
			getTeamData();
			var coachSquad:XMLList = this.teamSquadsXML.pr_squad;
			if (!coachSquad) coachSquad = new XMLList();
			var aDP:Array = [];
			var strLbl:String;
			var strData:String;
			for each(var obj:XML in this.teamSquadsXML.children()) {
				strLbl = obj._squadName.text();
				strData = obj._squadId.text();
				aDP.push({label:strLbl, data:strData});
			}
			return new DataProvider(aDP);
		}
		
		public function getFixtureId():String {
			if (sG.sessionDataXML.session._fixtureId.length() == 0) {
				var strId:String = sG.sessionDataXML._fixtureId.text();
				setFixtureId(strId);
			}
			strId = sG.sessionDataXML.session._fixtureId.text();
			return strId;
		}
		
		public function setFixtureId(strId:String):void {
			if (strId == null || strId == "" || strId == "null" || strId == "undefined") {
				strId = "0";
				logger.addText("(A) - Invalid _fixtureId value, using 0 as default", false);
			}
			sG.sessionDataXML.session._fixtureId = strId;
		}
		
		public function getTeamSquad(strSquadId:String):XML {
			getTeamData();
			var teamSquad:XMLList = this.teamSquadsXML.pr_squad.(_squadId == strSquadId);
			if (!teamSquad) teamSquad = new XMLList();
			return teamSquad[0];
		}
		
		public function getTeamSideFromNonPRPlayerId(strPlayerId:String):String {
			//var teamSide:String = _teamOppXML.children().(_nonprPlayerId == strPlayerId)._teamSide.text();
			var teamSide:String = this.teamDataSourceXML.nonpr_team_player.(_nonprPlayerId == strPlayerId)._teamSide.text();
			return teamSide;
		}
		
		public function getTeamSideFromKitId(kId:int):String {
			if (kId == KitsLibrary.KIT_ID_OUR) {
				return TeamGlobals.TEAM_OUR;
			} else if (kId == KitsLibrary.KIT_ID_OPP) {
				return TeamGlobals.TEAM_OPP;
			}
			return "";
		}
		
		public function getTeamPositionsDataProvider():DataProvider {
			if (!this.teamPositionsXML) getTeamData();
			var aDP:Array = [];
			var strLbl:String;
			var strData:String;
			for each(var obj:XML in this.teamPositionsXML.children()) {
				strLbl = obj._playerPositionName.text();
				strData = obj._playerPositionId.text();
				aDP.push({label:strLbl, data:strData});
			}
			return new DataProvider(aDP);
		}
		
		public function getPlayerPositionName(strPosId:String):String {
			if (!this.teamPositionsXML) getTeamData();
			var strPos:String = "";
			var tmpList:XMLList = this.teamPositionsXML.player_position.(_playerPositionId == strPosId);
			if (tmpList && tmpList.length() > 0) strPos = tmpList[0]._playerPositionName.text();
			return strPos;
		}
		
		public function getPlayerPositionIndex(strPosId:String):int {
			if (!this.teamPositionsXML) getTeamData();
			var tpXMLList:XMLList = this.teamPositionsXML.children();
			for (var i:uint = 0;i<tpXMLList.length();i++) {
				if (tpXMLList[i]._playerPositionId == strPosId) {
					return i;
				}
			}
			return -1;
		}
		
		public function getPlayerPositionId(listIdx:uint):String {
			if (!this.teamPositionsXML) getTeamData();
			var posId:uint = 0;
			if (this.teamPositionsXML.children().length() > listIdx) {
				posId = uint( this.teamPositionsXML.children()[listIdx]._playerPositionId.text() );
			}
			return posId.toString();
		}
		
		public function getTeamPlayerNumber(strPlayerId:String, teamSide:String):String {
			var strNumber:String = "";
			var intNumPlayers:int;
			var tmpPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.pr_team_player;
			//var tmpPRPlayersXMLList:XMLList = this.teamDataXML.pr_player;
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			if (teamSide == TeamGlobals.TEAM_OUR) {
				if (sG.usePlayerRecords) {
					intNumPlayers = tmpPRTeamPlayersXMLList.(_prPlayerId == strPlayerId).length();
					if (intNumPlayers >= 1) {
						strNumber = tmpPRTeamPlayersXMLList.(_prPlayerId == strPlayerId)[0]._playerNumber.text();
					}
				} else {
					intNumPlayers = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId).length();
					if (intNumPlayers >= 1) {
						strNumber = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._playerNumber.text();
					}
				}
			} else {
				//strNumber = _teamOppXML.children().(_nonprPlayerId == strPlayerId)._playerNumber.text();
				intNumPlayers = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId).length();
				if (intNumPlayers >= 1) {
					strNumber = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._playerNumber.text();
				}
			}
			return strNumber;
		}
		
		public function getGivenName(strPlayerId:String, teamKitId:String):String {
			//var tmpPRTeamPlayersXMLList:XMLList = this.teamDataXML.pr_team_player;
			var tmpPRPlayersXMLList:XMLList = this.teamDataSourceXML.pr_player;
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			var strName:String;
			if (sG.usePlayerRecords && teamKitId == PlayerKitSettings.KIT_ID_0_TEAM1.toString()) {
				strName = tmpPRPlayersXMLList.(_prPlayerId == strPlayerId)._givenName.text();
			} else {
				strName = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)._givenName.text();
			}
			return strName;
		}
		
		public function getFamilyName(strPlayerId:String, teamKitId:String):String {
			var tmpPRPlayersXMLList:XMLList = this.teamDataSourceXML.pr_player;
			//var tmpPRTeamPlayersXMLList:XMLList = this.teamDataXML.pr_team_player;
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			var strName:String;
			if (sG.usePlayerRecords && teamKitId == PlayerKitSettings.KIT_ID_0_TEAM1.toString()) {
				strName = tmpPRPlayersXMLList.(_prPlayerId == strPlayerId)._familyName.text();
			} else {
				strName = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)._familyName.text();
			}
			return strName;
		}
		
		public function getTeamPlayerGivenName(strPlayerId:String, teamSide:String):String {
			var strName:String;
			if (teamSide == TeamGlobals.TEAM_OUR) {
				if (sG.usePlayerRecords) {
					strName = this.teamOursXML.children().(_prPlayerId == strPlayerId)._givenName.text();
				} else {
					strName = this.teamOursXML.children().(_nonprPlayerId == strPlayerId)._givenName.text();
				}
			} else {
				strName = this.teamOppXML.children().(_nonprPlayerId == strPlayerId)._givenName.text();
			}
			return strName;
		}
		
		public function getTeamPlayerFamilyName(strPlayerId:String, teamSide:String):String {
			var strName:String;
			if (teamSide == TeamGlobals.TEAM_OUR) {
				if (sG.usePlayerRecords) {
					strName = this.teamOursXML.children().(_prPlayerId == strPlayerId)._familyName.text();
				} else {
					strName = this.teamOursXML.children().(_nonprPlayerId == strPlayerId)._familyName.text();
				}
			} else {
				strName = this.teamOppXML.children().(_nonprPlayerId == strPlayerId)._familyName.text();
			}
			return strName;
		}
		
		public function getPlayerInitials(strPlayerName:String, strPlayerFamName:String):String {
			return strPlayerName.charAt(0) + strPlayerFamName.charAt(0);
		}
		
		public function getFormattedNameFromPlayerId(strPlayerId:String, teamSide:String, includeNumber:Boolean):String {
			var strGivName:String = "";
			var strFamName:String = "";
			var strNumber:String = "";
			var strFormattedName:String = "";
			var intNumPlayers:int = 0;
			var intNumPRPlayers:int = 0;
			var tmpPRPlayersXMLList:XMLList = this.teamDataSourceXML.pr_player;
			var tmpPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.pr_team_player;
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			if (teamSide == TeamGlobals.TEAM_OUR) {
				if (sG.usePlayerRecords) {
					intNumPRPlayers = tmpPRPlayersXMLList.(_prPlayerId == strPlayerId).length();
					intNumPlayers = tmpPRTeamPlayersXMLList.(_prPlayerId == strPlayerId).length();
					if (intNumPRPlayers >= 1) {
						strGivName = tmpPRPlayersXMLList.(_prPlayerId == strPlayerId)[0]._givenName.text();
						strFamName = tmpPRPlayersXMLList.(_prPlayerId == strPlayerId)[0]._familyName.text();
					}
					if (intNumPlayers >= 1) {
						strNumber = tmpPRTeamPlayersXMLList.(_prPlayerId == strPlayerId)[0]._playerNumber.text();
					}
				} else {
					intNumPlayers = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId).length();
					if (intNumPlayers >= 1) {
						if (intNumPlayers > 1) logger.addText("Duplicated _nonprPlayerId's found in our team list", true);
						strGivName = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._givenName.text();
						strFamName = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._familyName.text();
						strNumber = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._playerNumber.text();
					}
				}
			} else {
				intNumPlayers = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId).length();
				if (intNumPlayers >= 1) {
					if (intNumPlayers > 1) logger.addText("Duplicated _nonprPlayerId's found in opposition team list", true);
					strGivName = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._givenName.text();
					strFamName = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._familyName.text();
					strNumber = tmpNonPRTeamPlayersXMLList.(_nonprPlayerId == strPlayerId)[0]._playerNumber.text();
				}
			}
			
			if (includeNumber) {
				strFormattedName = "("+strNumber+") ";
			}
			strFormattedName += getFormattedName(strGivName, strFamName);
			
			return strFormattedName;
		}
		
		public function getFormattedName(strGivName:String, strFamName:String, screenPlayerNameFormat:Number = NaN):String {
			// ["Full Name", "Initial + Family Name", "Name + Initial", "Initials", "Family Name", "Name", "Family Name + Name"].
			var newName:String = "";
			var sp:String = (strGivName == "" || strFamName == "")? "" : " ";
			var dot:String = (strGivName == "" || strFamName == "")? "" : ".";;
			var gNameI:String = strGivName.substr(0,1) + dot;
			var fNameI:String = strFamName.substr(0,1) + dot;
			
			var nameFormat:uint = (!isNaN(screenPlayerNameFormat))? screenPlayerNameFormat : uint(sG.sessionDataXML.session._teamPlayerNameFormat.text());
			switch(nameFormat) {
				case 0:
					newName = strGivName + sp + strFamName;
					break;
				case 1:
					newName = gNameI + sp +strFamName;
					break;
				case 2:
					newName = strGivName + sp + fNameI;
					break;
				case 3:
					newName = gNameI + fNameI;
					break;
				case 4:
					newName = strFamName;
					break;
				case 5:
					newName = strGivName;
					break;
				case 6:
					newName = strFamName + sp + strGivName;
					break;
				default:
					newName = "";
					break;
			}
			return newName;
		}
		
		public function getTeamSideKitSettings(tSideCode:String, playerType:int = -1):PlayerKitSettings {
			if (playerType<0) playerType = PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
			var pkSettings:PlayerKitSettings = new PlayerKitSettings();
			if (tSideCode == TeamGlobals.TEAM_OUR) {
				pkSettings = KitsLibrary.getInstance().getDefaultPlayerKitSettings(PlayerKitSettings.KIT_ID_0_TEAM1, playerType);
			} else if (tSideCode == TeamGlobals.TEAM_OPP) {
				pkSettings = KitsLibrary.getInstance().getDefaultPlayerKitSettings(PlayerKitSettings.KIT_ID_1_TEAM2, playerType);
			} else {
				pkSettings = KitsLibrary.getInstance().getDefaultPlayerKitSettings(PlayerKitSettings.KIT_ID_2_OFFICIALS, PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS);
			}
			return pkSettings;
		}
			
			
		
		public function getMaxSortOrder(teamXML:XML):uint {
			var currentVal:uint;
			var maxVal:uint;
			for each(var sXML:XML in teamXML.children()) {
				currentVal = uint( sXML._sortOrder.text() );
				if ( currentVal > maxVal ) maxVal = currentVal;
			}
			return maxVal;
		}
		
		public function getNewNonPRPlayerId():String {
			var aNonPRTeamPlayerIds:Array = [];
			var newNonPRPId:uint;
			var strPId:String;
			var strPlayerId:String;
			//var tmpPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.pr_team_player;
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			// Get all non player records players (includes ours and opp).
			for each(var p:XML in tmpNonPRTeamPlayersXMLList) {
				strPId = p._nonprPlayerId.text();
				if (strPId && strPId != "") aNonPRTeamPlayerIds.push(int(strPId));
			}
			// Get new nonprPlayerId.
			newNonPRPId = 1; // Default value.
			if (aNonPRTeamPlayerIds.length > 0) {
				aNonPRTeamPlayerIds.sort(Array.NUMERIC);
				for (var i:uint;i<aNonPRTeamPlayerIds.length;i++) {
					if (newNonPRPId == aNonPRTeamPlayerIds[i]) {
						newNonPRPId++;
					} else {
						break;
					}
				}
			}
			
			if (newNonPRPId > TeamGlobals.NONPR_PLAYER_ID_MAX) {
				logger.addError("New _nonprPlayerId "+newNonPRPId+" is greater than "+TeamGlobals.NONPR_PLAYER_ID_MAX);
			}
			
			strPlayerId = String(newNonPRPId);
			
			//strPlayerId = MiscUtils.addLeadingZeros(strPlayerId, TeamGlobals.PLAYER_ID_DIGITS);
			return strPlayerId;
		}
		
		public function getPlayerXMLFromId(teamPlayerId:String):XML {
			var tmpNonPRTeamPlayersXMLList:XMLList = this.teamDataSourceXML.nonpr_team_player;
			for each(var p:XML in tmpNonPRTeamPlayersXMLList) {
				if (teamPlayerId == p._nonprPlayerId.text()) return p;
			}
			return null;
		}
		
		public function isPlayerPositionGoalkeeper(posId:String):Boolean {
			var isGoalkeeper:Boolean;
			var playerPosXML:XML = this.teamDataSourceXML.player_position.(_playerPositionId == posId)[0];
			if (playerPosXML) isGoalkeeper = MiscUtils.stringToBoolean(playerPosXML._isGoalkeeper.text());
			return isGoalkeeper;
		}
		
		public function getGoalkeeperPositionId():String {
			var posId:String = "";
			var posXMLList:XMLList;
			try {
				posXMLList = this.teamDataSourceXML.player_position.(_isGoalkeeper == "TRUE");
				if (posXMLList.length() > 0) {
					posId = posXMLList[0]._playerPositionId.text();
				} else {
					logger.addText("Can't get Goalkeeper's _playerPositionId from <player_position>.", true);
					posId = "";
				}
			} catch (error:Error) {
				logger.addText("Can't get Goalkeeper's _playerPositionId from <player_position>: "+error.message, true);
				posId = "";
			}
			return posId;
		}
		
		public function getCurrentFormations():Vector.<SSPFormation> {
			var ppTeam:int = int(sG.sessionDataXML.session._teamPlayersPerTeam.text());
			var currentFormations:Vector.<SSPFormation> = TeamGlobals.getInstance().getFormationList(ppTeam);
			return currentFormations;
		}
		
		public function getFormationIndex(formationName:String, vFormations:Vector.<SSPFormation>):int {
			if (!formationName) return -1;
			for (var i:uint = 0;i<vFormations.length;i++) {
				if (formationName == vFormations[i].name) return i;
			}
			return -1;
		}
		
		
		
		// ----------------------------- Screen Settings ----------------------------- //
		public function getScreenXML(sId:uint):XML {
			var strId:String = sId.toString();
			var sXML:XML = sG.sessionDataXML.session.screen.(_screenId == strId)[0];
			return sXML;
		}
		public function getScreenDefaultXML(screenType:String):XML {
			var sXML:XML = sG.sessionDataXML.session.screen_defaults.(_screenType == screenType)[0];
			return sXML;
		}
		public function setPlayerNameFormat(val:uint):void {
			
		}
		public function setWePlay(val:uint):void {
			if (val >= tG.aWePlay.length) return;
			sG.sessionDataXML.session._teamWePlay = tG.aWePlay[val];
		}
		// -------------------------- End of Screen Settings ------------------------- //
		
		
		
		// ----------------------------- Data Saving Utils ----------------------------- //
		
		/*
		* In Team Data:
		* <player_position> // No
		* <pr_activity> // No
		* <pr_player> // No
		* <pr_squad> // No
		* <pr_team_player> // Yes, contains updated players.
		* <nonpr_team_player> // Yes, can contain new or updated players.
		* <session_minutes> // Yes, if any.
		* <pr_minutes> // Yes, if any.
		* 
		* In Session Data:
		* <_teamPlayersPerTeam>
		* <_teamWePlay>
		* <_teamPlayerNameFormat>
		* <_teamPlayerNumberFormat>
		* <_teamPlayerPositionDisplay>
		* <_fixtureId>
		* 
		* In Session Data Screens:
		* <_screenFormationOurs>
		* <_screenFormationOpposition>
		* <_screenFormat>
		* <_screenPlayerNameFormat>
		* <_screenPlayerNameDisplay>
		* <_screenPlayerModelFormat>
		* <_screenPlayerModelDisplay>
		* <_screenPlayerPositionDisplay>
		*/
		
		public function getTeamDataXML():XML {
			var newTeamDataXML:XML = new XML("<team_data></team_data>");
			var usePlayerRecords:Boolean = MiscUtils.stringToBoolean( this.teamDataSourceXML._usePlayerRecords.text() );
			
			if (usePlayerRecords) {
				newTeamDataXML.appendChild(getPlayerRecords(this.teamOursXML.pr_team_player.(_lastTeam == "TRUE")));
			} else {
				newTeamDataXML.appendChild(this.teamOursXML.children().copy());
			}
			newTeamDataXML.appendChild(this.teamOppXML.children().copy());
			
			return newTeamDataXML;
		}
		
		private function getPlayerRecords(srcXMLList:XMLList):XMLList {
			var tmpXMLList:XMLList;
			// TODO: Update the '_lastTeam' value of all players. It can be done here or in the 'Select Team' form.
			tmpXMLList = srcXMLList.copy();
			// TODO: At the moment, remove _givenName and _familyName. Maybe used for debug in the future.
			for each (var xml:XML in tmpXMLList) {
				delete xml._givenName;
				delete xml._familyName;
				delete xml._removeFlag;
			}
			return tmpXMLList;
		}
		
		/*public function updatePRTeamXMLFromDataProvider(dp:DataProvider):XMLList {
			if (!dp) return null;
			var tdXMLList:XMLList = this.teamDataXML.pr_team_player;
			var strPId:String;
			var tmpXML:XML;
			
			// Reset all Player Records.
			for each(var xml:XML in tdXMLList) {
				xml._lastTeam = "FALSE";
				xml._sortOrder = "";
			}
			
			// Mark new selected Player Records.
			for each(var pr:PRItem in dp.toArray()) {
				strPId = pr.playerId;
				tmpXML = tdXMLList.(_prPlayerId == strPId)[0];
				if (tmpXML) {
					tmpXML._lastTeam = "TRUE"
					tmpXML._sortOrder = pr.playerSortOrder; // TODO: Use Player Sort Order or array index?
				}
			}
			
			// Return new list.
			return tdXMLList;
		}*/
		// -------------------------- End of Data Saving Utils ------------------------- //
		
		
		
		// ----------------------------- Team Edit ----------------------------- //
		public function addNonPRPlayerToTeamDataXML(pXML:XML):void {
			var newPlayerId:String = pXML._nonprPlayerId.text();
			var strTeamSide:String = pXML._teamSide.text();
			if (getPlayerXMLFromId(newPlayerId)) return;
			var targetXML:XML = (strTeamSide == TeamGlobals.TEAM_OPP)? this.teamOppXML : this.teamOursXML;
			var tmpXMLList:XMLList = targetXML.children();
			var lastElement:XML = (tmpXMLList.length() > 0)? tmpXMLList[tmpXMLList.length()-1] : null;
			targetXML.insertChildAfter(lastElement, pXML); // Using xml.insertChildAfter to avoid issues with xml.appendChild method.
			this.teamDataSourceXML.nonpr_team_player += pXML;
		}
		
		public function removeAllPlayerFromTeamXML(strTeamSide:String):void {
			// Source Team Data. Delete only if no player records user.
			if (!sG.usePlayerRecords) {
				// Delete the team side.
				for (var i:int = this.teamDataSourceXML.nonpr_team_player.length()-1; i>=0; i--) {
					if (this.teamDataSourceXML.nonpr_team_player[i]._teamSide.text() == strTeamSide) {
						if (this.teamDataSourceXML.nonpr_team_player[i]) {
							delete this.teamDataSourceXML.nonpr_team_player[i];
						}
					}
				}
			}
			
			// Selected Team Data.
			if (strTeamSide == TeamGlobals.TEAM_OUR) {
				if (sG.usePlayerRecords) {
					delete teamOursXML.pr_team_player;
				} else {
					delete teamOursXML.nonpr_team_player;
				}
			} else {
				delete teamOppXML.nonpr_team_player;
			}
		}
		// -------------------------- End of Team Edit ------------------------- //
		
		
		
		// ----------------------------- Dummy Team Creation ----------------------------- //
		public function createDummyTeamOpp():void {
			var newPlayerXMLList:XMLList = new XMLList();
			var newPlayer:XML;
			var pCount:uint = 1;
			var isGoalkeeper:Boolean;
			var defGoalkeeperPoseId:String = PlayerLibrary.defaultGoalKeeperId.toString();
			var defPlayerPoseId:String = PlayerLibrary.defaultPlayerId.toString();
			var strGivenName:String = sG.interfaceLanguageDataXML.titles._teamDummyOppositionGivenName.text();
			var strFamilyName:String = sG.interfaceLanguageDataXML.titles._teamDummyOppositionFamilyName.text();
			var strTeamSide:String = TeamGlobals.TEAM_OPP;
			var i:uint;
			
			for (i = 0;i<SSPSettings._maxPlayersPerTeam;i++) {
				isGoalkeeper = (pCount == 1)? true : false;
				newPlayer = TeamGlobals.NONPR_PLAYER_XML.copy();
				newPlayer._nonprPlayerId = uint(this.getNewNonPRPlayerId()) + i ;
				newPlayer._givenName = strGivenName;
				newPlayer._familyName = strFamilyName + " " + pCount;
				newPlayer._playerNumber = pCount;
				newPlayer._playerPositionId = (isGoalkeeper)? getGoalkeeperPositionId() : "";
				newPlayer._poseId = (isGoalkeeper)? defGoalkeeperPoseId : defPlayerPoseId;
				newPlayer._sortOrder = String(getMaxSortOrder(this.teamOppXML) + i);
				newPlayer._teamSide = strTeamSide;
				newPlayerXMLList += newPlayer;
				pCount++;
			}
			
			removeAllPlayerFromTeamXML(strTeamSide);
			
			this.teamDataSourceXML.appendChild(newPlayerXMLList);
			this.teamOppXML.appendChild(newPlayerXMLList);
			getTeamData();
		}
		
		// -------------------------- End of Dummy Team Creation ------------------------- //
	}
}