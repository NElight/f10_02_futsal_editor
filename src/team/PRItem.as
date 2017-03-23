package src.team
{
	import flash.display.DisplayObject;
	
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;

	public class PRItem extends Object
	{
		private var _playerXML:XML = new XML();
		
		/*public var playerId:String = ""; // Server store it as a string with leading zeros, eg: 7 --> "00000007".
		public var playerName:String = "";
		public var playerFamName:String = "";
		public var playerNumber:String = "";
		public var playerPositionId:uint = 0;
		public var playerPoseId:uint = 0;
		public var playerSortOrder:uint = 0;
		public var playerSquadId:uint = 0;
		public var playerTeamSide:String = "";*/ // Use PRGlobals.TEAM_OUR or PRGlobals.TEAM_OPP.
		
		// Cell Renderer Controls.
		//public var useRemove:Boolean;
		//public var useEdit:Boolean;
		
		public var label:String;
		public var icon:DisplayObject;
		
		public var recordEnabled:Boolean = true; // Tells the cell renderer to change to enabled or disabled status.
		public var blankRecord:Boolean = false; // Tells the cell renderer to hide this item info, for drag and drop purposes.
		public var recordUsed:Boolean = false; // Tells the cell renderer to mark this record as used.
		public var recordRepeated:Boolean = false; // Tells the cell renderer to mark this record as repeated.
		
		// Controls positions.
		public var fullSizeNameYPos:Number = 0;
		public var fullSizeFamNameYPos:Number = 0;
		public var fullSizeNumberYPos:Number = 0;
		public var fullSizeRemoveYPos:Number = 0;
		public var fullSizeMcNumberBgYPos:Number = 0;
		
		public function PRItem() {
			super();
		}
		
		public function set playerXML(value:XML):void {
			_playerXML = value;
			// Validate poseId.
			if (!playerPoseId || playerPoseId == "" || playerPoseId == "0") {
				var isGoalKeeper:Boolean = (playerSortOrder == "0")? true : false;
				playerPoseId = (isGoalKeeper)? PlayerLibrary.defaultGoalKeeperId.toString() : PlayerLibrary.defaultPlayerId.toString();
			}
		}
		
		public function get playerXML():XML {
			return _playerXML;
		}
		
		public function get playerRecord():Boolean {
			var pr:Boolean = (playerXML._prPlayerId.length() > 0)? true : false;
			return pr;
		}
		
		public function set playerId(val:String):void {
			// Server store it as a string with leading zeros, eg: 7 --> "00000007".
			if (playerRecord) {
				playerXML._prPlayerId = val;
			} else {
				playerXML._nonprPlayerId = val;
			}
		}
		public function get playerId():String {
			var val:String;
			if (playerRecord) {
				val = playerXML._prPlayerId.text();
			} else {
				val = playerXML._nonprPlayerId.text();
			}
			return val;
		}
		
		public function set playerName(val:String):void { playerXML._givenName = val; }
		public function get playerName():String { return playerXML._givenName.text(); }
		
		public function set playerFamName(val:String):void { playerXML._familyName = val; }
		public function get playerFamName():String { return playerXML._familyName.text(); }
		
		public function set playerNumber(val:String):void { playerXML._playerNumber = val; }
		public function get playerNumber():String { return playerXML._playerNumber.text(); }
		
		public function set playerPositionId(val:String):void { playerXML._playerPositionId = val; }
		public function get playerPositionId():String { return playerXML._playerPositionId.text(); }
		
		public function set playerPoseId(val:String):void { playerXML._poseId = val; }
		public function get playerPoseId():String { return playerXML._poseId.text(); }
		
		public function set playerSortOrder(val:String):void { playerXML._sortOrder = val; }
		public function get playerSortOrder():String { return playerXML._sortOrder.text(); }
		
		public function set playerSquadId(val:String):void { if (playerRecord) playerXML._squadId = val; } // PR Only.
		public function get playerSquadId():String { return playerXML._squadId.text(); } // PR Only.
		
		public function set playerLastTeam(val:String):void { if (playerRecord) playerXML._lastTeam = val; } // PR Only.
		public function get playerLastTeam():String { return playerXML._lastTeam.text(); } // PR Only.
		
		public function set playerTeamSide(val:String):void { if (!playerRecord) playerXML._teamSide = val; } // Use TeamGlobals.TEAM_OUR or TeamGlobals.TEAM_OPP.
		public function get playerTeamSide():String { return (playerRecord)? TeamGlobals.TEAM_OUR : playerXML._teamSide.text(); }
		
		public function set playerIsGoalkeeper(val:Boolean):void {
			if (val) {
				if (!this.playerIsGoalkeeper) {
					this.playerPoseId = PlayerLibrary.defaultGoalKeeperId.toString();
					this.playerPositionId = PRTeamManager.getInstance().getGoalkeeperPositionId();
				}
			} else {
				if (this.playerIsGoalkeeper) {
					this.playerPoseId = PlayerLibrary.defaultPlayerId.toString();
					this.playerPositionId = "";
				}
			}
		}
		public function get playerIsGoalkeeper():Boolean {
			return PRTeamManager.getInstance().isPlayerPositionGoalkeeper(this.playerPositionId);
		}
		
		/*public function set playerRemoveFlag(val:String):void { playerXML._removeFlag = val; }
		public function get playerRemoveFlag():String { 
			var rf:String = playerXML._removeFlag.text();
			if (rf != "TRUE") rf = "FALSE";
			return rf;
		}*/
		
		/*public function setSettingsFromXML(xml:XML, itemsEnabled:Boolean):void {
			if (!xml || xml.length() == 0) return;
			this.playerXML = xml;
			this.playerId = xml._prPlayerId.text();
			this.playerName = xml._givenName.text();
			this.playerFamName = xml._familyName.text();
			this.playerNumber = xml._playerNumber.text();
			this.playerPositionId = uint(xml._playerPositionId.text());
			this.playerPoseId = uint(xml._poseId.text());
			this.playerSortOrder = uint(xml._sortOrder.text());
			this.playerSquadId = uint(xml._squadId.text());
			
			//this.recordEnabled:Boolean = itemsEnabled; // Tells the cell renderer to change to enabled or disabled status.
		}*/
		
		public function clone(cloneIn:PRItem = null):PRItem
		{
			var newPRItem:PRItem = (cloneIn)? cloneIn : new PRItem();
			/*newPRItem.playerXML = this.playerXML;
			newPRItem.playerId = this.playerId;
			newPRItem.playerName = this.playerName;
			newPRItem.playerFamName = this.playerFamName;
			newPRItem.playerNumber = this.playerNumber;
			newPRItem.playerPositionId = this.playerPositionId;
			newPRItem.playerPoseId = this.playerPoseId;
			newPRItem.playerSortOrder = this.playerSortOrder;
			newPRItem.playerSquadId = this.playerSquadId;*/
			
			newPRItem.playerXML = this.playerXML;
			
			newPRItem.recordEnabled = this.recordEnabled;
			
			newPRItem.label = this.label;
			newPRItem.icon = this.icon;
			
			// Controls positions.
			newPRItem.fullSizeNameYPos = this.fullSizeNameYPos;
			newPRItem.fullSizeFamNameYPos = this.fullSizeFamNameYPos;
			newPRItem.fullSizeNumberYPos = this.fullSizeNumberYPos;
			newPRItem.fullSizeRemoveYPos this.fullSizeRemoveYPos;
			newPRItem.fullSizeMcNumberBgYPos = this.fullSizeMcNumberBgYPos;
			
			return newPRItem;
		}
		
		// ----------------------------------- 3D Player Settings ----------------------------------- //
		public function getPlayerSettings():PlayerSettings {
			var newPS:PlayerSettings = new PlayerSettings();
			var isGoalkeeper:Boolean = this.playerIsGoalkeeper;
/*			var defPosId:String = (hasGoalKeeperPos)? PlayerLibrary.defaultGoalKeeperId.toString() : PlayerLibrary.defaultPlayerId.toString();
			var pLibSettings:Object = PlayerLibrary.getPlayerPropertiesFromId(uint(this.playerPoseId));
			if (!pLibSettings) {
				this.playerPoseId = defPosId;
			} else {
				if (hasGoalKeeperPos && pLibSettings.PlayerType != PlayerLibrary.TYPE_KEEPER) {
					this.playerPoseId = defPosId;
				} else if (!hasGoalKeeperPos && pLibSettings.PlayerType == PlayerLibrary.TYPE_KEEPER) {
					this.playerPoseId = defPosId;
				}
			}*/
			newPS._objectType = ObjectTypeLibrary.OBJECT_TYPE_PLAYER;
			newPS._teamPlayer = true;
			newPS._libraryId = uint(this.playerPoseId);;
			newPS._cKit._kitId = (this.playerTeamSide == TeamGlobals.TEAM_OPP)? PlayerKitSettings.KIT_ID_1_TEAM2 : PlayerKitSettings.KIT_ID_0_TEAM1; // Note that playerTeamSide = "", will use kitId = 0 ("Ours");
			newPS._cKit._kitTypeId = (isGoalkeeper)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
			
			// Team Settings.
			newPS._teamPlayerId = this.playerId;
			newPS._playerPositionId = this.playerPositionId;
			newPS._playerGivenName = this.playerName;
			newPS._playerFamilyName = this.playerFamName;
			newPS._playerNumber = this.playerNumber;
			
			return newPS;
		}
		// -------------------------------- End of 3D Player Settings ------------------------------- //
	}
}