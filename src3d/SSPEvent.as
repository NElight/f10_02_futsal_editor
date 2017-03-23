package src3d
{
	import flash.events.Event;
	
	public class SSPEvent extends Event
	{
		// Session Error and Success. See SSPError.as.
		public static const ERROR:String 										= "ERROR";
		public static const SUCCESS:String 										= "SUCCESS";
		public static const LATE_SUCCESS:String 								= "LATE_SUCCESS";
		public static const CANCEL:String 										= "CANCEL";
		public static const TIMEOUT:String 										= "TIMEOUT";
		public static const UPDATE:String										= "UPDATE";
		public static const COMPLETE:String 									= "COMPLETE";

		// Controls Events (triggered by keys down, mouse clicks, etc.)
		
		//MAIN
		public static const KEY_DOWN:String 									= "KEY_DOWN"; // eventData = key code.
		public static const KEY_UP:String 										= "KEY_UP"; // eventData = key code.
		public static const CONTROL_CLICK_SESSION_SAVE:String 					= "CONTROL_CLICK_SESSION_SAVE";
		public static const CONTROL_CLICK_SESSION_CLEAR_ALL:String 				= "CONTROL_CLICK_SESSION_CLEAR_ALL";
		public static const CONTROL_CLICK_SESSION_SAVE_TO_PC:String 			= "CONTROL_CLICK_SESSION_SAVE_TO_PC"; // Debug.
		
		// TABS
		public static const CONTROL_DOWN_SCREEN_CHANGE:String					= "CONTROL_DOWN_SCREEN_CHANGE";
		
		// KITS (eventData = An object with kitID, kitType, Array of Areas, color. Use kitID = -1 for customize player).
		public static const CONTROL_COLOR_CHANGE:String							= "CONTROL_COLOR_CHANGE";
		
		// LINES
		public static const CONTROL_CLICK_LINE:String							= "CONTROL_CLICK_LINE";
		public static const CONTROL_CLICK_LINE_MOVEMENT:String					= "CONTROL_CLICK_LINE_MOVEMENT";
		public static const CONTROL_CLICK_LINE_CUSTOM:String					= "CONTROL_CLICK_LINE_CUSTOM";
		public static const CONTROL_CLICK_LINE_PASS:String						= "CONTROL_CLICK_LINE_PASS";
		public static const CONTROL_CLICK_LINE_DRIBBLE:String					= "CONTROL_CLICK_LINE_DRIBBLE";
		public static const CONTROL_CLICK_LINE_LINE:String						= "CONTROL_CLICK_LINE_LINE";
		
		// TEXT
		
		// PITCH VIEWS
		public static const CONTROL_CLICK_PITCH_VIEW_CHANGE:String				= "CONTROL_CLICK_PITCH_VIEW_CHANGE";
		
		// CONTROLS TO 3D SCREEN
		public static const CONTROL_CANCEL:String								= "CONTROL_CANCEL"; // Eg: Cancel line drawing.
		public static const CONTROL_DOWN_ZOOM_IN:String							= "CONTROL_DOWN_ZOOM_IN";
		public static const CONTROL_UP_ZOOM_IN:String							= "CONTROL_UP_ZOOM_IN";
		public static const CONTROL_DOWN_ZOOM_OUT:String						= "CONTROL_DOWN_ZOOM_OUT";
		public static const CONTROL_UP_ZOOM_OUT:String							= "CONTROL_UP_ZOOM_OUT";
		public static const CONTROL_CLICK_PITCH_TEXTURE_CHANGE:String			= "CONTROL_CLICK_PITCH_TEXTURE_CHANGE";
		public static const CONTROL_CLICK_CAMERA_TARGET_CHANGE:String			= "CONTROL_CLICK_CAMERA_TARGET_CHANGE";
		public static const CONTROL_CLICK_SCREEN_LOCK:String					= "CONTROL_CLICK_SCREEN_LOCK";
		public static const CONTROL_CLICK_SCALE_CHANGE:String					= "CONTROL_CLICK_SCALE_CHANGE";
		public static const CONTROL_DOWN_LOCK:String							= "CONTROL_DOWN_LOCK";
		public static const CONTROL_UP_LOCK:String								= "CONTROL_UP_LOCK";
		public static const CONTROL_CLICK_PLAYER_CUSTOMIZE:String				= "CONTROL_CLICK_PLAYER_CUSTOMIZE";
		public static const CONTROL_CLICK_LINE_ANGLE_CHANGE:String				= "CONTROL_CLICK_LINE_ANGLE_CHANGE";
		public static const CONTROL_CLICK_FLIP_H:String							= "CONTROL_CLICK_FLIP_H";
		public static const CONTROL_DOWN_FLIP_H:String							= "CONTROL_DOWN_FLIP_H";
		public static const CONTROL_UP_FLIP_H:String							= "CONTROL_UP_FLIP_H";
		public static const CONTROL_DOWN_ROTATE:String							= "CONTROL_DOWN_ROTATE"; // True for CW, false for CCW.
		public static const CONTROL_UP_ROTATE:String							= "CONTROL_UP_ROTATE"; // True for CW, false for CCW.
		public static const CONTROL_CLICK_DELETE:String							= "CONTROL_CLICK_DELETE";
		public static const CONTROL_DOWN_CAMERA_RIGHT:String					= "CONTROL_DOWN_CAMERA_RIGHT";
		public static const CONTROL_UP_CAMERA_RIGHT:String						= "CONTROL_UP_CAMERA_RIGHT";
		public static const CONTROL_DOWN_CAMERA_LEFT:String						= "CONTROL_DOWN_CAMERA_LEFT";
		public static const CONTROL_UP_CAMERA_LEFT:String						= "CONTROL_UP_CAMERA_LEFT";
		public static const CONTROL_DOWN_CAMERA_UP:String						= "CONTROL_DOWN_CAMERA_UP";
		public static const CONTROL_UP_CAMERA_UP:String							= "CONTROL_UP_CAMERA_UP";
		public static const CONTROL_DOWN_CAMERA_DOWN:String						= "CONTROL_DOWN_CAMERA_DOWN";
		public static const CONTROL_UP_CAMERA_DOWN:String						= "CONTROL_UP_CAMERA_DOWN";
		
		// 3D SCREEN TO CONTROLS.
		public static const CONTROL_VISIBLE:String								= "CONTROL_VISIBLE";
		public static const CONTROL_POPUP_VISIBLE:String						= "CONTROL_POPUP_VISIBLE";
		public static const CONTROL_ARROW_POS:String							= "CONTROL_ARROW_POS";
		
		// Drag and Drop Events.
		public static const CONTROL_DRAG_OBJECT2D_OVER3D:String 				= "CONTROL_DRAG_OBJECT2D_OVER3D";
		public static const CONTROL_DROP_OBJECT2D_OVER3D:String 				= "CONTROL_DROP_OBJECT2D_OVER3D";
		//public static const CONTROL_DRAG_OBJECT:String 							= "CONTROL_DRAG_OBJECT";
		public static const CONTROL_DROP_OBJECT:String 							= "CONTROL_DROP_OBJECT";
		public static const CONTROL_PITCH_MOUSE_DOWN:String						= "CONTROL_PITCH_MOUSE_DOWN";
		
		// Camera Events.
		public static const CAMERA_MOVED										= "CAMERA_MOVED";
		public static const CAMERA_STOP_MOVING:String							= "CAMERA_STOP_MOVING";
		
		// Rotator Events.
		public static const ROTATOR_UPDATE:String								= "ROTATOR_UPDATE";
		
		// Kit Related Events.
		public static const PLAYER_SELECT_SINGLE_PLAYER:String 					= "PLAYER_SELECT_SINGLE_PLAYER"; // Sent to Kits.as
		public static const PLAYER_UPDATE_SINGLE_CUSTOM_SETTINGS:String			= "PLAYER_UPDATE_SINGLE_CUSTOM_SETTINGS"; // Sent from Kit.as
		public static const PLAYER_UPDATE_SINGLE_CUSTOM_KIT:String				= "PLAYER_UPDATE_SINGLE_CUSTOM_KIT"; // Sent from Kit.as
		public static const PLAYERS_UPDATE_DEFAULT_KITS:String					= "PLAYERS_UPDATE_DEFAULT_KITS"; // Sent from Kit.as
		
		// Equipment Events.
		public static const EQUIPMENT_TOGGLE_DEFAULT:String						= "EQUIPMENT_TOGGLE_DEFAULT"; // Changes defualt equipment visibility
		
		// Lines Events.
		//public static const LINE_EDITING:String									= "LINE_EDITING";
		public static const LINE_UPDATE_SINGLE_LINE:String						= "LINE_UPDATE_SINGLE_LINE"; // Sent from lines.as
		public static const LINE_UPDATE_DEFAULT_SETTINGS:String					= "LINE_UPDATE_DEFAULT_SETTINGS"; // Sent from lines.as
		public static const LINE_CREATE_BY_PINNING:String						= "LINE_CREATE_BY_PINNING"; // Allows multiple lines drawing.
		public static const LINE_CREATE_FINISHED:String							= "LINE_CREATE_FINISHED";
		
		// Load / Create Events.
		public static const CREATE_SCREEN:String								= "CREATE_SCREEN";
		public static const CREATE_OBJECT:String								= "CREATE_OBJECT";
		public static const CREATE_OBJECT_CANCEL:String							= "CREATE_OBJECT_CANCEL";
		public static const CREATE_OBJECT_BY_PINNING:String						= "CREATE_OBJECT_BY_PINNING";
		public static const CREATE_OBJECT_BY_CLONING:String						= "CREATE_OBJECT_BY_CLONING";
		public static const OBJECT_CREATED:String								= "OBJECT_CREATED";
		
		// Minutes Events.
		public static const MINUTES_ENABLED:String								= "MINUTES_ENABLED";
		public static const MINUTES_UPDATE_SCORE:String							= "MINUTES_UPDATE_SCORE";
		public static const MINUTES_SCORE_MODE:String							= "MINUTES_SCORE_MODE";
		public static const MINUTES_UPDATE_SCORE_MODE:String					= "MINUTES_UPDATE_SCORE_MODE";
		
		// Other Interface Events (for focus control, etc. eg: mouse up in any area of the stage.).
		public static const LOADING_DONE:String									= "LOADING_DONE";
		public static const LOADING_MODELS_DONE:String							= "LOADING_MODELS_DONE"; // From ModelsLoader.as
		public static const LOADING_MATERIALS_DONE:String						= "LOADING_MATERIALS_DONE"; // From MaterialsLoader.as)
		public static const STAGE_MOUSE_UP:String 								= "STAGE_MOUSE_UP";
		public static const STAGE_MOUSE_DOWN:String 							= "STAGE_MOUSE_DOWN";
		public static const SESSION_SCREEN_SELECT:String						= "SESSION_SCREEN_SELECT";
		public static const SESSION_SCREEN_ADD:String							= "SESSION_SCREEN_ADD";
		public static const SESSION_SCREEN_CREATED:String						= "SESSION_SCREEN_CREATED";
		public static const SESSION_SCREEN_REMOVE:String						= "SESSION_SCREEN_REMOVE";
		public static const SESSION_SCREEN_CLONE_FROM_TAB:String				= "SESSION_SCREEN_CLONE_FROM_TAB"; // Tab tells SessionView that we want to clone the screen.
		public static const SESSION_SCREEN_CLONE:String							= "SESSION_SCREEN_CLONE";
		public static const SESSION_SCREEN_CLONE_TOGGLE:String					= "SESSION_SCREEN_CLONE_TOGGLE";
		public static const SESSION_SCREEN_SELECT_OBJECT:String					= "SESSION_SCREEN_SELECT_OBJECT"; // Includes the object to be selected. Null to deselect all.
		public static const SESSION_SCREEN_SELECT_TEAM_PLAYER:String			= "SESSION_SCREEN_SELECT_TEAM_PLAYER"; // Includes the player Id.
		//public static const SESSION_SCREEN_DESELECT_OBJECTS:String			= "SESSION_SCREEN_DESELECT_OBJECTS";
		public static const SESSION_SCREEN_TITLE_CHANGE:String					= "SESSION_SCREEN_TITLE_CHANGE";
		public static const SESSION_SCREEN_TITLE_UPDATE:String					= "SESSION_SCREEN_TITLE_UPDATE";
		public static const SESSION_SCREEN_UPDATE_TEAM_SETTINGS:String			= "SESSION_SCREEN_UPDATE_TEAM_SETTINGS";
		public static const SESSION_SCREEN_REORDER:String						= "SESSION_SCREEN_REORDER";
		public static const SESSION_SCREEN_TABS_CHANGE:String					= "SESSION_SCREEN_TABS_CHANGE";
		public static const OBJECT_ENABLED:String								= "OBJECT_ENABLED"; // Sent from SessionScreen.as. Contains 'eventData.screenId(int)' and 'eventData.enabled(Boolean)'.
		/*public static const SESSION_VIEW_EDIT_MODE:String						= "SESSION_VIEW_EDIT_MODE";
		public static const SESSION_VIEW_DRAGG_MODE:String						= "SESSION_VIEW_DRAGG_MODE";
		public static const SESSION_VIEW_CREATE_MODE:String						= "SESSION_VIEW_CREATE_MODE";*/
		
		// Screen Tabs.
		public static const TAB_CLICK:String									= "TAB_CLICK";
		public static const TAB_CLOSE_CLICK:String								= "TAB_CLOSE_CLICK";
		public static const TAB_MOUSE_DOWN:String								= "TAB_MOUSE_DOWN";
		public static const TAB_MOUSE_UP:String									= "TAB_MOUSE_UP";
		
		// Controls.
		public static const CONTROL_UPDATE:String								= "CONTROL_UPDATE"; // Used in controls like volume or video seek bar.
		public static const CONTROL_CHANGE:String								= "CONTROL_CHANGE";
		public static const CONTROL_CLOSE:String								= "CONTROL_CLOSE";
		
		// Print.
		public static const PRINT_START:String									= "PRINT_START";
		public static const PRINT_DONE:String									= "PRINT_DONE";
		public static const PRINT_HIGH_RES:String								= "PRINT_HIGH_RES";
		
		// Settings.
		public static const SETTINGS_SCREEN_LIST_CHANGE:String					= "SETTINGS_SCREEN_LIST_CHANGE";
		
		// Stage.
		public static const STAGE_RESIZE:String									= "STAGE_RESIZE";
		
		// Main Menu.
		public static const MAIN_MENU_PANEL_TAB_CLICK							= "MAIN_MENU_PANEL_TAB_CLICK"; // Fired by panel button tabs.
		
		// GUI.
		public static const MOVIECLIP_PLAYED									= "MOVIECLIP_PLAYED"; // Fired when movie clip reaches the last frame.
		
		public var eventData:*; // Extra data to include (eg: ERROR_CODE's, loaded xml file name, button name, the loading error description, the '_sessionToken' string, etc.).
		
		public function SSPEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new SSPEvent(type, eventData);
		}
	}
}