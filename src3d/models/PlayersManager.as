package src3d.models
{
	import flash.geom.Vector3D;
	
	import src.team.PRItem;
	import src.team.PRTeamManager;
	import src.team.SSPFormation;
	import src.team.SSPTeamEvent;
	import src.team.TeamGlobals;
	
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.players.Player;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;

	public class PlayersManager
	{
		// Global Vars.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var stageEventHandler:EventHandler;
		
		private var sScreen:SessionScreen;
		private var eCreator:EquipmentCreator;
		private var ourTeamFormation:SSPFormation;
		private var oppTeamFormation:SSPFormation;
		
		public function PlayersManager(sScreen:SessionScreen, eCreator:EquipmentCreator)
		{
			this.sScreen = sScreen;
			this.eCreator = eCreator;
			stageEventHandler = new EventHandler(sScreen.stage);
		}
		
		public function autoLayoutPitch(e:SSPTeamEvent):void {
			if (!e || !e.eventData) return;
			var ourTeamFormation:SSPFormation = e.eventData.ourFormation as SSPFormation;
			var oppTeamFormation:SSPFormation = e.eventData.oppFormation as SSPFormation;
			if (!ourTeamFormation || !oppTeamFormation) return;
//			removeTeamPlayers();
			sScreen.deleteAllTeamPlayers();
			createPlayers(ourTeamFormation, oppTeamFormation);
		}
		
		public function clearPlayerTeamData(e:SSPTeamEvent):void {
			// Data pased can be a single player, an array of players to exclude or just the team side.
			var pItem:PRItem = e.eventData as PRItem;
			var pTeamSide:String = e.eventData as String;
			var objExclude:Object = e.eventData;
			
			if (pItem) {
				// If receives a single player, delete it.
				clearSinglePlayerTeamData(pItem);
			} else if (pTeamSide) {
				// If receive teamSide, delete all players of that team side.
				clearAllPlayersFromTeamSide(pTeamSide);
			} else if (objExclude && objExclude.excludeList) {
				// If receive an array, delete all but the ones in array.
				clearAllPlayersButExcluded(objExclude.excludeList, objExclude.teamSide);
			}
		}
		
		private function clearSinglePlayerTeamData(prItem:PRItem):void {
			var pSettings:PlayerSettings;
			var intTeamSide:int = (prItem.playerTeamSide == TeamGlobals.TEAM_OPP)? 1 : 0;
			for each (var p:Player in sScreen.aPlayers) {
				pSettings = p.settings as PlayerSettings;
				if (pSettings._teamPlayerId == prItem.playerId &&
					pSettings._cKit._kitId == intTeamSide) {
					p.clearTeamData();
				}
			}
		}
			
		private function clearAllPlayersFromTeamSide(teamSide:String):void {
			for each (var p:Player in sScreen.aPlayers) {
				if (p.teamSide == teamSide && p.teamPlayer) {
					p.clearTeamData();
				}
			}
		}
		
		private function clearAllPlayersButExcluded(aExclude:Array, teamSide:String):void {
			if (!aExclude || !teamSide || teamSide == "") return;
			var exclude:Boolean;
			var pItem:PRItem;
			var p:Player;
			for each (p in sScreen.aPlayers) {
				exclude = false;
				if (p.teamSide == teamSide) {
					for each (pItem in aExclude) {
						if (p.teamPlayerId == pItem.playerId) exclude = true;
					}
					if (!exclude) p.clearTeamData();
				}
			}
		}
		
		private function createPlayers(ourTeamFormation:SSPFormation, oppTeamFormation:SSPFormation):void {
			var teamOursXMLList:XMLList = MiscUtils.sortXMLList(teamMgr.teamOursXML.children(), "_sortOrder");
			var teamOppXMLList:XMLList = MiscUtils.sortXMLList(teamMgr.teamOppXML.children(), "_sortOrder");
			var vFormationOur:Vector.<Vector3D> = (teamMgr.teamWePlayHome)? ourTeamFormation.vFormation : ourTeamFormation.vFormationReversed;
			var vFormationOpp:Vector.<Vector3D> = (teamMgr.teamWePlayHome)? oppTeamFormation.vFormationReversed : oppTeamFormation.vFormation;
			var pRotation:Number = (teamMgr.teamWePlayHome)? 90 : -90;
			var kitTypeId:int;
			var isGoalkeeper:Boolean;
			var i:uint;
			// The number of players must match number of formation positions.
			//var ourListLength:uint = teamOursXMLList.length();
			var ourListLength:uint = vFormationOur.length;
			//var oppListLength:uint = teamOppXMLList.length();
			var oppListLength:uint = vFormationOpp.length;
			
			// Our Team.
			//if (teamOursXMLList.length() != vFormationOur.length) {
			//	ourListLength = (teamOursXMLList.length() < vFormationOur.length)? teamOursXMLList.length() : vFormationOur.length;
			//}
			for (i=0;i<ourListLength;i++) {
				if (teamOursXMLList.length() > i) {
					// If enough team players.
					//kitTypeId = (teamOursXMLList[i]._sortOrder == "0")? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS; // Allow one goalkeeper only.
					isGoalkeeper = teamMgr.isPlayerPositionGoalkeeper(teamOursXMLList[i]._playerPositionId.text());
					kitTypeId = (isGoalkeeper)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
					createPlayer(teamOursXMLList[i], true, false, PlayerKitSettings.KIT_ID_0_TEAM1, kitTypeId, vFormationOur[i], pRotation);
				} else {
					// Else, use empty players.
					kitTypeId = (i==0)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
					createPlayer(null, true, true, PlayerKitSettings.KIT_ID_0_TEAM1, kitTypeId, vFormationOur[i], pRotation);
				}
			}
			
			//if (sScreen.screenFormat != TeamGlobals.SCREEN_FORMATION_P1) {
				// Opposition Team.
				//if (teamOppXMLList.length() != vFormationOpp.length) {
				//	oppListLength = (teamOppXMLList.length() < vFormationOpp.length)? teamOppXMLList.length() : vFormationOpp.length;
				//}
				for (i=0;i<oppListLength;i++) {
					if (teamOppXMLList.length() > i) {
						// If enough team players.
						//kitTypeId = (teamOppXMLList[i]._sortOrder == "0")? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS; // Allow one goalkeeper only.
						isGoalkeeper = teamMgr.isPlayerPositionGoalkeeper(teamOppXMLList[i]._playerPositionId.text());
						kitTypeId = (isGoalkeeper)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
						createPlayer(teamOppXMLList[i], true, false, PlayerKitSettings.KIT_ID_1_TEAM2, kitTypeId, vFormationOpp[i], -pRotation);
					} else {
						// Else, use empty players.
						kitTypeId = (i==0)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
						createPlayer(null, true, true, PlayerKitSettings.KIT_ID_1_TEAM2, kitTypeId, vFormationOpp[i], -pRotation);
					}
				}
			//}
		}
		
		private function createPlayer(pXML:XML, teamPlayer:Boolean, teamPlayerEmpty:Boolean, kitId:int, kitTypeId:int, pPos:Vector3D, rot:Number):void {
			// Get settings from Team XML's.
			var newPS:PlayerSettings = new PlayerSettings();
			newPS._screenId = sScreen.screenId;
			newPS._teamPlayer = teamPlayer;
			if (teamPlayerEmpty) {
				// As _teamPlayerEmpty is not saved to server, we set _teamPlayerId = 0.
				// This way Flash can identify this player as depersonalized Team Player on next load.
				newPS._teamPlayerId = "0";
			}
			newPS._objectType = ObjectTypeLibrary.OBJECT_TYPE_PLAYER;
			newPS._cKit._kitId = kitId;
			newPS._cKit._kitTypeId = kitTypeId;
			if (teamPlayer) {
				if (pXML) {
					newPS._libraryId = Number(pXML._poseId.text());
				} else {
					newPS._libraryId = (newPS._cKit._kitTypeId == PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS)? PlayerLibrary.defaultGoalKeeperId : PlayerLibrary.defaultPlayerId;
				}
			} else {
				newPS._libraryId = (newPS._cKit._kitTypeId == PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS)? PlayerLibrary.defaultGoalKeeperId : PlayerLibrary.defaultPlayerId;
			}
			// Team Settings.
			if (teamPlayer && pXML && !sG.omitTeamPlayerId) {
				newPS._teamPlayerId = (pXML._prPlayerId.length() > 0)? pXML._prPlayerId.text() : pXML._nonprPlayerId.text();
				newPS._playerPositionId = pXML._playerPositionId.text();
				newPS._playerGivenName = pXML._givenName.text();
				newPS._playerFamilyName = pXML._familyName.text();
				newPS._playerNumber = pXML._playerNumber;
			}
			if (sG.omitTeamPlayerId) newPS._teamPlayerId = "0"; // Overrides teamPlayerEmpty.
			// Formation Settings.
			newPS._x = pPos.x;
			newPS._y = pPos.y;
			newPS._z = pPos.z;
			newPS._rotationY = rot;
			// Create new player.
			sScreen.createNewObject3D(newPS, false, true);
		}
		
/*		private function removeTeamPlayers():void {
			var aPlayersDispose:Vector.<Player> = new Vector.<Player>();
			var p:Player;
			
			for each(p in sScreen.aPlayers) {
				if (p.teamPlayer) {
					aPlayersDispose.push(p);
				}
			}
			
			for each(var p:Player in aPlayersDispose) {
				sScreen.deletePlayer(p);
			}
		}*/
		
		/*private function updateTeamsList():void {
			vTeamsListOld = vTeamsList;
			vTeamsList = new Vector.<Player>();
			
			// Check if players has been removed from the list.
			for each(var p:Player in sScreen.aPlayers) {
				if (!isPlayerOnTeam(p)) {
					sScreen.deletePlayer(p);
				} else {
					if (p) vTeamsList.push(p);
				}
			}
		}*/
		
		private function isPlayerOnTeam(p:Player):Boolean {
				var found:Boolean = false;
				var pXML:XML;
				var strPlayerId:String = p.teamPlayerId;
				var xmlList:XMLList;
				
				/*for each(pXML in teamMgr.teamOursXML) {
					if (p.teamPlayerId == pXML._teamPlayerId) {
						found = true;
						break;
					}
					if (found) return found;
				}
				for each(pXML in teamMgr.teamOppXML) {
					if (p.teamPlayerId == pXML._teamPlayerId) {
						found = true;
						break;
					}
					if (found) return found;
				}*/
				
				if (sG.usePlayerRecords) {
					xmlList = teamMgr.teamOursXML.(_prPlayerId == strPlayerId);
				} else {
					xmlList = teamMgr.teamOursXML.(_nonprPlayerId == strPlayerId);
				}
				if (xmlList && xmlList.length() > 0) return true;
				xmlList = teamMgr.teamOppXML.(_nonprPlayerId == strPlayerId);
				if (xmlList && xmlList.length() > 0) return true;
				return false;
		}
		
		/*public function getGoalkeeperFromTeam(pTeam:uint):Player {
			var pSettings:PlayerSettings;
			for each (var p:Player in sScreen.aPlayers) {
				pSettings = p.settings as PlayerSettings;
				if (pSettings &&
					pSettings._teamPlayer &&
					pSettings._cKit._kitTypeId == PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS &&
					pSettings._cKit._kitId == pTeam
				) {
					return p;
				}
			}
			return null;
		}*/
	}
}