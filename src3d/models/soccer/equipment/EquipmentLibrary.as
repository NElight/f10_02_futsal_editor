package src3d.models.soccer.equipment
{
	public class EquipmentLibrary
	{
		public static const NAME_EQUIPMENT:String	= "Equipment"; // Identify Object Name. See Equipment Creator.
		
		// Database Id's.
		public static const ID_001:int				= 001;
		public static const ID_002:int				= 002;
		public static const ID_003:int				= 003;
		public static const ID_004:int				= 004;
		public static const ID_005:int				= 005;
		public static const ID_006:int				= 006;
		public static const ID_007:int				= 007;
		public static const ID_008:int				= 008;
		public static const ID_009:int				= 009;
		public static const ID_010:int				= 010;
		public static const ID_011:int				= 011;
		public static const ID_012:int				= 012;
		public static const ID_013:int				= 013;
		public static const ID_014:int				= 014;
		public static const ID_015:int				= 015;
		public static const ID_016:int				= 016;
		public static const ID_017:int				= 017;
		public static const ID_018:int				= 018;
		public static const ID_024:int				= 024;
		public static const ID_031:int				= 031;
		public static const ID_032:int				= 032;
		public static const ID_033:int				= 033;
		public static const ID_034:int				= 034;
		
		
		// Class Names.
		public static const NAME_CLASS_BASE_PATH:String = "src3d.models.soccer.equipment::"; // Class path to use 'getDefinitionByName' in EquipmentCreator.as.
		public static const NAME_FLAG:String = "Flag";
		public static const NAME_FOOTBALL:String = "Football";
		public static const NAME_CONE:String = "SoccerCone"; // Added 'Soccer' to avoid problems with away3d primitive 'Cone'.
		public static const NAME_LADDER:String = "Ladder";
		public static const NAME_HURDLE:String = "Hurdle";
		public static const NAME_DISC:String = "Disc";
		public static const NAME_POLE:String = "Pole";
		public static const NAME_MANNEQUIN:String = "Mannequin";
		public static const NAME_GOAL:String = "Goal";
		public static const NAME_MINIGOAL:String = "MiniGoal";
		public static const NAME_PASSING_ARC:String = "PassingArc";
		public static const NAME_BALANCE_BALL:String = "BalanceBall";
		public static const NAME_LARGE_HURDLE:String = "LargeHurdle";
		public static const NAME_REBOUND_BOARD_1:String = "ReboundBoard1";
		public static const NAME_REBOUND_BOARD_2:String = "ReboundBoard2";
		public static const NAME_AGILITY_CONES:String = "AgilityCones";
		public static const NAME_SPEED_RINGS:String = "SpeedRings";
		public static const NAME_GOAL_TO_SCALE:String = "GoalToScale";
		public static const NAME_CAR_TYRE:String = "CarTyre";
		public static const NAME_FLAT_DISC_MARKER:String = "FlatDiscMarker";
		public static const NAME_FLAT_SHOE_LEFT:String = "FlatShoeLeft";
		public static const NAME_FLAT_SHOE_RIGHT:String = "FlatShoeRight";
		public static const NAME_HEAD_TENNIS_NET:String = "HeadTennisNet";
		
		// Array of Equipment Settings.
		public static const _aEquipment:Array = new Array(
			{EquipmentId:ID_001, ClassName:NAME_FLAG, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_002, ClassName:NAME_FOOTBALL, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_003, ClassName:NAME_CONE, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_004, ClassName:NAME_LADDER, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_005, ClassName:NAME_HURDLE, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_006, ClassName:NAME_DISC, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_007, ClassName:NAME_POLE, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_008, ClassName:NAME_MANNEQUIN, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_009, ClassName:NAME_GOAL, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_010, ClassName:NAME_MINIGOAL, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_011, ClassName:NAME_PASSING_ARC, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_012, ClassName:NAME_BALANCE_BALL, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_013, ClassName:NAME_LARGE_HURDLE, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_014, ClassName:NAME_REBOUND_BOARD_1, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_015, ClassName:NAME_REBOUND_BOARD_2, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_016, ClassName:NAME_AGILITY_CONES, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_017, ClassName:NAME_SPEED_RINGS, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_018, ClassName:NAME_GOAL_TO_SCALE, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_024, ClassName:NAME_CAR_TYRE, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_031, ClassName:NAME_FLAT_DISC_MARKER, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_032, ClassName:NAME_FLAT_SHOE_LEFT, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_033, ClassName:NAME_FLAT_SHOE_RIGHT, ElevationDefault: 0, SizeDefault: 1},
			{EquipmentId:ID_034, ClassName:NAME_HEAD_TENNIS_NET, ElevationDefault: 0, SizeDefault: 1}
		);
		
		public function EquipmentLibrary()
		{
		}
	}
}