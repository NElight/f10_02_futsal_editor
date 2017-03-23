package src.team
{
	import flash.events.Event;
	
	public class SSPTeamEvent extends Event
	{
		// ----------------------------------- Form: Select Team ----------------------------------- //
		public static const SOURCE_LIST_DRAG_ITEM:String			= "SOURCE_LIST_DRAG_ITEM";
		public static const TARGET_LIST_MOUSE_UP:String				= "TARGET_LIST_MOUSE_UP";
		public static const TARGET_LIST_REMOVE_ITEM:String			= "TARGET_LIST_REMOVE_ITEM";
		
		public static const OUR_TEAM_UPDATE:String					= "OUR_TEAM_UPDATE";
		public static const OPP_TEAM_UPDATE:String					= "OPP_TEAM_UPDATE";
		public static const PLAYER_POSE_SELECT:String				= "PLAYER_POSE_SELECT";
		public static const PLAYER_POSE_UPDATE:String				= "PLAYER_POSE_UPDATE";
		
		
		// ----------------------------------- Menu: Team Lists ----------------------------------- //
		public static const TEAM_LIST_CHANGE:String					= "TEAM_LIST_CHANGE";
		public static const TEAM_LIST_REMOVE_ALL:String				= "TEAM_LIST_REMOVE_ALL";
		public static const TEAM_LIST_REMOVE_ITEM:String			= "TEAM_LIST_REMOVE_ITEM";
		public static const TEAM_LIST_EDIT_ITEM:String				= "TEAM_LIST_EDIT_ITEM";
		public static const TEAM_LIST_DRAG_ITEM:String				= "TEAM_LIST_DRAG_ITEM";
		
		
		// ----------------------------------- Menu: Team Settings ----------------------------------- //
		public static const TEAM_SETTINGS_CHANGE_NAME_FORMAT		= "TEAM_SETTINGS_CHANGE_NAME_FORMAT";
		public static const TEAM_SETTINGS_CHANGE_NUMBER_FORMAT		= "TEAM_SETTINGS_CHANGE_NUMBER_FORMAT";
		
		
		// ----------------------------------- Menu: Screen Settings ----------------------------------- //
		public static const SCREEN_SETTINGS_CHANGE_NAME_FORMAT		= "SCREEN_SETTINGS_CHANGE_NAME_FORMAT";
		public static const SCREEN_SETTINGS_CHANGE_MODEL_FORMAT		= "SCREEN_SETTINGS_CHANGE_MODEL_FORMAT";
		public static const SCREEN_SETTINGS_PLAYER_UPDATE			= "SCREEN_SETTINGS_PLAYER_UPDATE";
		public static const SCREEN_SETTINGS_AUTO_LAYOUT_PITCH		= "SCREEN_SETTINGS_AUTO_LAYOUT_PITCH";
		
		
		public var eventData:*; // Extra data to include.
		
		public function SSPTeamEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new SSPTeamEvent(type, eventData);
		}
	}
}