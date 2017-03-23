package src3d.models.soccer.players
{
	import src.team.PRTeamManager;
	
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.equipment.EquipmentSettings;
	
	public class PlayerSettings extends EquipmentSettings
	{
		public var _cKit:PlayerKitSettings = new PlayerKitSettings(); // See PlayerKit.as for more info.
		//public var _dKit:PlayerKitSettings = new PlayerKitSettings();
		public var _accessories:String = "";
		
		// Team Player vars.
		public var _teamPlayer:Boolean = false;
		public var _teamPlayerId:String = "";
		public var _playerGivenName:String = "";
		public var _playerFamilyName:String = "";
		public var _playerNumber:String = "";
		public var _playerPositionId:String = "";
		public var _playerNameFormat:String = "";
		public var _playerModelFormat:String = "";
		
		public function PlayerSettings()
		{
		}
		
		/**
		 * Unpersonalizes the player. 
		 */		
		public function clearTeamData():void {
			_playerGivenName = "";
			_playerFamilyName = "";
			_playerNumber = "";
			_playerPositionId = "";
			_teamPlayerId = (_teamPlayer)? "0" : ""; // 0 Means depersonalized Team Player.
		}
		
		public override function clone(cloneIn:SSPObjectBaseSettings = null):SSPObjectBaseSettings
		{
			var newObjSettings:PlayerSettings = (cloneIn)? cloneIn as PlayerSettings: new PlayerSettings();
			super.clone(newObjSettings); // Get base settings.
			newObjSettings._cKit = this._cKit.clone();
			newObjSettings._accessories = this._accessories;
			newObjSettings._teamPlayer = this._teamPlayer;
			newObjSettings._teamPlayerId = this._teamPlayerId;
			
			newObjSettings._playerGivenName = this._playerGivenName;
			newObjSettings._playerFamilyName = this._playerFamilyName;
			newObjSettings._playerNumber = this._playerNumber;
			newObjSettings._playerPositionId = this._playerPositionId;
			newObjSettings._playerNameFormat = this._playerNameFormat;
			newObjSettings._playerModelFormat = this._playerModelFormat;
			
			return newObjSettings;
		}
		
		public function get _playerName():String {
			return PRTeamManager.getInstance().getFormattedName(_playerGivenName, _playerFamilyName, uint(_playerNameFormat));
		}
		
		public function get _playerPositionName():String {
			return PRTeamManager.getInstance().getPlayerPositionName(_playerPositionId);
		}
		
		public function get _playerInitials():String {
			return PRTeamManager.getInstance().getPlayerInitials(_playerGivenName, _playerFamilyName);
		}
		
		public function get _teamSide():String {
			return PRTeamManager.getInstance().getTeamSideFromKitId(_cKit._kitId);
		}
		
		public function get _teamPlayerEmpty():Boolean
		{
			if (!_teamPlayer) _teamPlayerId = "";
			return (_teamPlayerId == "0")? true : false;
		}
	}
}