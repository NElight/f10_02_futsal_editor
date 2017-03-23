package src3d
{
	public class ButtonSettings extends Object
	{
		// See 'mc_controls' .FLA file for details about the buttons.
		public static const CTRL_CUSTOM_PLAYER_KIT:String = "ctrl_custom_player";
		public static const CTRL_CUSTOM_ARROWHEAD_POS:String = "ctrl_arrow_pos";
		public static const CTRL_CUSTOM_EQUIP_COLOR:String = "ctrl_custom_equipment_color";
		public static const CTRL_CUSTOM_ITEM_ELEVATION:String = "ctrl_custom_item_elevation";
		public static const CTRL_CUSTOM_ITEM_SIZE:String = "ctrl_custom_item_size";
		public static const CTRL_CUSTOM_ITEM_CLONE:String = "ctrl_custom_item_clone";
		public static const CTRL_CUSTOM_ITEM_PIN:String = "ctrl_custom_item_pin";
		public static const CTRL_CUSTOM_ITEM_TRANSPARENCY:String = "ctrl_custom_item_transparency";
		public static const CTRL_CAMERA_POSITION:String = "ctrl_camera_position";
		
		public var btnName:String;
		public var btnVisible:Boolean;
		public var btnState:int;
		public var btnData:Object = {};
		public var btnSelected:Boolean;
		
		public function ButtonSettings(name:String, visible:Boolean, state:int, data:Object, selected:Boolean)
		{
			btnName = name;
			btnVisible = visible;
			btnState = state;
			btnData = data;
			btnSelected = selected;
		}
		
		public function clearButtonSettings():void {
			btnName = "";
			btnVisible = false;
			btnState = 0;
			btnData = {};
			btnSelected = false;
		}
	}
}