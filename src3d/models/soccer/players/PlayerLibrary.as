package src3d.models.soccer.players
{
	import src3d.models.soccer.AccessoriesLibrary;
	
	public class PlayerLibrary
	{
		public static const NAME_CLASS_BASE_PATH:String = "src3d.models.soccer.players::"; // Class path to use 'getDefinitionByName' in EquipmentCreator.as.
		public static const NAME_PLAYER:String		= "Player"; // Identify Object Name. See Equipment Creator.
		
		public static const ID_001:int				= 1;
		public static const ID_002:int				= 2;
		public static const ID_003:int				= 3;
		public static const ID_004:int				= 4;
		public static const ID_005:int				= 5;
		public static const ID_006:int				= 6;
		public static const ID_007:int				= 7;
		public static const ID_008:int				= 8;
		public static const ID_009:int				= 9;
		public static const ID_010:int				= 10; // Keeper Diving
		public static const ID_011:int				= 11; // Keper Open Body
		public static const ID_012:int				= 12; // Keeper Catch From Across
		public static const ID_013:int				= 13; // Keeper Long Barrier
		public static const ID_014:int				= 14;
		public static const ID_015:int				= 15;
		public static const ID_016:int				= 16;
		public static const ID_017:int				= 17; // Keeper Feeding
		public static const ID_018:int				= 18; // Keeper Receiving
		public static const ID_019:int				= 19; // Keeper Set
		public static const ID_020:int				= 20; // Keeper Scoop Catch
		public static const ID_021:int				= 21; // Keeper Head Height Catch
		public static const ID_022:int				= 22; // Keeper Low Diving Save
		public static const ID_023:int				= 23; // Keeper Overarm Throw
		public static const ID_024:int				= 24; // Keeper Underarm Throw
		
		public static const TYPE_PLAYER:int 		= 0;
		public static const TYPE_KEEPER:int 		= 1;
		public static const TYPE_OFFICIAL:int 		= 2;
		
		// Array of Player Properties.
		public static const _aPlayers:Array = new Array(
			{PlayerId:ID_001, PlayerType:TYPE_PLAYER, ClassName:"Player001", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_CHUTE], Description:"Player-Running"},
			{PlayerId:ID_002, PlayerType:TYPE_PLAYER, ClassName:"Player002", DefaultPose:false, Accessories:2, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE, AccessoriesLibrary.ACCESSORY_BALL], Description:"Player-Throw-In"},
			{PlayerId:ID_003, PlayerType:TYPE_PLAYER, ClassName:"Player003", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Shooting"},
			{PlayerId:ID_004, PlayerType:TYPE_PLAYER, ClassName:"Player004", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Header"},
			{PlayerId:ID_005, PlayerType:TYPE_PLAYER, ClassName:"Player005", DefaultPose:false, Accessories:0, ElevationDefault: 20, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Jumping-Header"},
			{PlayerId:ID_006, PlayerType:TYPE_PLAYER, ClassName:"Player006", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Dribbling"},
			{PlayerId:ID_007, PlayerType:TYPE_PLAYER, ClassName:"Player007", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Side-Volley"},
			{PlayerId:ID_008, PlayerType:TYPE_PLAYER, ClassName:"Player008", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Pass"},
			{PlayerId:ID_009, PlayerType:TYPE_PLAYER, ClassName:"Player009", DefaultPose:true, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Waiting"},
			{PlayerId:ID_010, PlayerType:TYPE_KEEPER, ClassName:"Player010", DefaultPose:false, Accessories:0, ElevationDefault: 10, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES], Description:"Keeper-Diving"},
			{PlayerId:ID_011, PlayerType:TYPE_KEEPER, ClassName:"Player011", DefaultPose:true, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES], Description:"Keeper-Ready"},
			{PlayerId:ID_012, PlayerType:TYPE_KEEPER, ClassName:"Player012", DefaultPose:false, Accessories:2, ElevationDefault: 15, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES, AccessoriesLibrary.ACCESSORY_BALL], Description:"Keeper-High-Catch"},
			{PlayerId:ID_013, PlayerType:TYPE_KEEPER, ClassName:"Player013", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES], Description:"Keeper-Low-Receive"},
			{PlayerId:ID_014, PlayerType:TYPE_PLAYER, ClassName:"Player014", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Receiving"},
			{PlayerId:ID_015, PlayerType:TYPE_PLAYER, ClassName:"Player015", DefaultPose:false, Accessories:2, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE, AccessoriesLibrary.ACCESSORY_BALL], Description:"Player-Feeding-Ball"},
			{PlayerId:ID_016, PlayerType:TYPE_PLAYER, ClassName:"Player016", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_NONE], Description:"Player-Receiving=Ball"},
			{PlayerId:ID_017, PlayerType:TYPE_KEEPER, ClassName:"Player017", DefaultPose:false, Accessories:2, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES, AccessoriesLibrary.ACCESSORY_BALL], Description:"Keeper-Feeding-Ball"},
			{PlayerId:ID_018, PlayerType:TYPE_KEEPER, ClassName:"Player018", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES], Description:"Keeper-Receiving-Ball"},
			{PlayerId:ID_019, PlayerType:TYPE_KEEPER, ClassName:"Player019", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES], Description:"Keeper-Set"},
			{PlayerId:ID_020, PlayerType:TYPE_KEEPER, ClassName:"Player020", DefaultPose:false, Accessories:2, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES, AccessoriesLibrary.ACCESSORY_BALL], Description:"Keeper-Scoop-Catch"},
			{PlayerId:ID_021, PlayerType:TYPE_KEEPER, ClassName:"Player021", DefaultPose:false, Accessories:2, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES, AccessoriesLibrary.ACCESSORY_BALL], Description:"Keeper-Head-Height-Catch"},
			{PlayerId:ID_022, PlayerType:TYPE_KEEPER, ClassName:"Player022", DefaultPose:false, Accessories:0, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES], Description:"Keeper-Low-Diving-Save"},
			{PlayerId:ID_023, PlayerType:TYPE_KEEPER, ClassName:"Player023", DefaultPose:false, Accessories:1, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES, AccessoriesLibrary.ACCESSORY_BALL], Description:"Keeper-Overarm-Throw"},
			{PlayerId:ID_024, PlayerType:TYPE_KEEPER, ClassName:"Player024", DefaultPose:false, Accessories:2, ElevationDefault: 0, OptionalAccessories:[AccessoriesLibrary.ACCESSORY_GLOVES, AccessoriesLibrary.ACCESSORY_BALL], Description:"Keeper-Underarm-Throw"}
		);
		
		// Shared poses (same skeleton, different mesh): k11-p14, p15-k17, p16-k18.
		
		public static function get defaultPlayerId():int {
			var defId:int = -1;
			for each(var p:Object in _aPlayers) {
				if (p.PlayerType == TYPE_PLAYER && p.DefaultPose == true) defId = p.PlayerId;
			}
			return defId;
		}
		
		public static function get defaultGoalKeeperId():int {
			var defId:int = -1;
			for each(var p:Object in _aPlayers) {
				if (p.PlayerType == TYPE_KEEPER && p.DefaultPose == true) defId = p.PlayerId;
			}
			return defId;
		}
		
		public static function get defaultOfficialId():int {
			var defId:int = -1;
			for each(var p:Object in _aPlayers) {
				if (p.PlayerType == TYPE_OFFICIAL && p.DefaultPose == true) defId = p.PlayerId;
			}
			return defId;
		}
		
		public static function getPlayerPropertiesFromId(pId:int):Object {
			var pSettings:Object;
			for (var i:uint;i<_aPlayers.length;i++) {
				if (_aPlayers[i].PlayerId == pId) {
					pSettings = _aPlayers[i];
					break;
				}
			}
			return pSettings;
		}
		
		public function PlayerLibrary()
		{
		}
	}
}