package src3d.models
{
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.equipment.AgilityCones;
	import src3d.models.soccer.equipment.BalanceBall;
	import src3d.models.soccer.equipment.Disc;
	import src3d.models.soccer.equipment.EquipmentLibrary;
	import src3d.models.soccer.equipment.Flag;
	import src3d.models.soccer.equipment.FlatDiscMarker;
	import src3d.models.soccer.equipment.FlatShoeLeft;
	import src3d.models.soccer.equipment.FlatShoeRight;
	import src3d.models.soccer.equipment.Football;
	import src3d.models.soccer.equipment.Goal;
	import src3d.models.soccer.equipment.GoalToScale;
	import src3d.models.soccer.equipment.HeadTennisNet;
	import src3d.models.soccer.equipment.Hurdle;
	import src3d.models.soccer.equipment.Ladder;
	import src3d.models.soccer.equipment.LargeHurdle;
	import src3d.models.soccer.equipment.Mannequin;
	import src3d.models.soccer.equipment.MiniGoal;
	import src3d.models.soccer.equipment.PassingArc;
	import src3d.models.soccer.equipment.Pole;
	import src3d.models.soccer.equipment.ReboundBoard1;
	import src3d.models.soccer.equipment.ReboundBoard2;
	import src3d.models.soccer.equipment.SoccerCone;
	import src3d.models.soccer.equipment.Tyre;
	import src3d.models.soccer.players.Player;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	
	public class EquipmentCreator
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		private var logger:Logger = Logger.getInstance();
		
		public function EquipmentCreator()
		{
		}
		
		/**
		 * Creates a new object with the specified settings.
		 * @param sessionScreen To be passed to created objects.
		 * @param objSettings SSPObjectBaseSettings. The settings to create the object.
		 * @param dragged Boolean. True if the object is created by drag and drop.
		 * 
		 * @see <code>SSPObjectBaseSettings</code>
		 */
		public function createNewObject3D(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings):SSPObjectBase {
			if (!sessionScreen || !objSettings) return null;
			var objOK:Boolean = false;
			var objIdx:int;
			var strClassName:String;
			var strClassPath:String;
			var newSSPObj:SSPObjectBase;
			
			switch(objSettings._objectType) {
				case ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT:
					objIdx = MiscUtils.indexInArray(EquipmentLibrary._aEquipment, "EquipmentId", objSettings._libraryId);
					if (objIdx != -1) {
						//strClassPath = EquipmentLibrary.NAME_CLASS_BASE_PATH;
						strClassName = EquipmentLibrary._aEquipment[objIdx].ClassName;
						objOK = true;
					}
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_PLAYER:
					objIdx = MiscUtils.indexInArray(PlayerLibrary._aPlayers, "PlayerId", objSettings._libraryId);
					if (objIdx != -1) {
						if (PlayerSettings(objSettings)._cKit._kitTypeId == -1) {
							// get the player kit type (player/official or goalkeeper).
							PlayerSettings(objSettings)._cKit._kitTypeId = (PlayerLibrary._aPlayers[objIdx].PlayerType == PlayerLibrary.TYPE_KEEPER)? 
								PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS :
								PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
						}
						//strClassPath = PlayerLibrary.NAME_CLASS_BASE_PATH;
						strClassName = PlayerLibrary.NAME_PLAYER; // "Player"
						objOK = true;
					}
					break;
			}
			if (!objOK) {
				logger.addText("Can't create new object on pitch. Object Id "+objSettings._libraryId+" not in library.", true);
				return null;
			}
			
			//newSSPObj = getSSPObjectFromClassName(strClassPath+strClassName, sessionScreen, objSettings);
			if (strClassName != "") {
				switch(strClassName) {
					case EquipmentLibrary.NAME_FLAG:
						newSSPObj = new Flag(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_FOOTBALL:
						newSSPObj = new Football(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_CONE:
						newSSPObj = new SoccerCone(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_LADDER:
						newSSPObj = new Ladder(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_HURDLE:
						newSSPObj = new Hurdle(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_DISC:
						newSSPObj = new Disc(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_POLE:
						newSSPObj = new Pole(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_MANNEQUIN:
						newSSPObj = new Mannequin(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_GOAL:
						newSSPObj = new Goal(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_MINIGOAL:
						newSSPObj = new MiniGoal(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_GOAL_TO_SCALE:
						newSSPObj = new GoalToScale(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_PASSING_ARC:
						newSSPObj = new PassingArc(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_BALANCE_BALL:
						newSSPObj = new BalanceBall(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_LARGE_HURDLE:
						newSSPObj = new LargeHurdle(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_REBOUND_BOARD_1:
						newSSPObj = new ReboundBoard1(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_REBOUND_BOARD_2:
						newSSPObj = new ReboundBoard2(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_AGILITY_CONES:
						newSSPObj = new AgilityCones(sessionScreen, objSettings);
						break;
					/*case "SpeedRings":
					newSSPObj = new SpeedRings(sessionScreen, objSettings);
					break;*/
					case EquipmentLibrary.NAME_CAR_TYRE:
						newSSPObj = new Tyre(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_FLAT_DISC_MARKER:
						newSSPObj = new FlatDiscMarker(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_FLAT_SHOE_LEFT:
						newSSPObj = new FlatShoeLeft(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_FLAT_SHOE_RIGHT:
						newSSPObj = new FlatShoeRight(sessionScreen, objSettings);
						break;
					case EquipmentLibrary.NAME_HEAD_TENNIS_NET:
						newSSPObj = new HeadTennisNet(sessionScreen, objSettings);
						break;
					case PlayerLibrary.NAME_PLAYER:
						newSSPObj = new Player(sessionScreen, objSettings);
						break;
				}
			}
			return newSSPObj;
		}
		
		/*private function getSSPObjectFromClassName(strClassFullPath:String, sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings):SSPObjectBase {
			var classReference:Class = MiscUtils.getClassDefinitionByName(strClassFullPath) as Class;
			var newSSPObj:SSPObjectBase;
			if (!classReference) {
				logger.addText("Can't get 3D object from class name ("+strClassFullPath+").", true);
				return null;
			}
			try {
				newSSPObj = new classReference(sessionScreen, objSettings) as SSPObjectBase;
			} catch (error:Error) {
				logger.addText("Can't create 3D object instance from class name ("+strClassFullPath+"): "+error, true);
				return null;
			}
			return newSSPObj;
		}*/
		
		public function dispose():void {
			sG = null;
			sD = null;
			logger = null;
		}
	}
}