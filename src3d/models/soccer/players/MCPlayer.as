package src3d.models.soccer.players
{
	import flash.display.BlendMode;
	import flash.geom.ColorTransform;
	
	import src3d.models.KitColorSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.utils.Drag2DObject;
	
	public class MCPlayer extends Drag2DObject
	{
		// Array of 2D Player Names. 
		// They can have this format: "player###", "keeper###", "referee###" (males)
		// and "fplayer###", "fkeeper###", "freferee###" (females).
		public static const NAME_PLAYER:String = "player";
		public static const NAME_KEEPER:String = "keeper";
		public static const NAME_OFFICIAL:String = "official";
		public static const NAME_F_PLAYER:String = "fplayer";
		public static const NAME_F_KEEPER:String = "fkeeper";
		public static const NAME_F_OFFICIAL:String = "official";
		public static const NAME_LIST_HEADER:String = "header";
		public static const playerNames:Array = new Array(NAME_PLAYER, NAME_KEEPER, NAME_OFFICIAL, NAME_F_PLAYER, NAME_F_KEEPER, NAME_F_OFFICIAL);
		
		// Kit parts (values corresponds to Players MovieClip's names).
		public static const KIT_HAIR:String		= "hair"; // Hair/Helmets.
		public static const KIT_SKIN:String		= "skin";
		public static const KIT_TOP:String		= "shirt"; // Shirts, labels, jackets...
		public static const KIT_BOTTOM:String	= "bottoms"; // Shorts, Trousers, Skirts...
		public static const KIT_SOCKS:String	= "socks"; // Socks or any other legs accessory.
		public static const KIT_SHOES:String	= "shoes"; // Shoes, boots...
		
		private var objId:int = -1;
		private var objType:String = ObjectTypeLibrary.OBJECT_TYPE_PLAYER;
		
		public function MCPlayer(dragEnabled:Boolean = true)
		{
			objId = int( this.name.substr(this.name.length-SSPSettings.namesDigits) ); // Get the Id from the instance name (last digits).
			super(objType, objId, -1, dragEnabled); // Use dragEnabled = false to use players as non-draggable images (eg. in team lists).
			init();
		}
		
		public function init():void {
			// Apply multiply effect on players to give realistic look and add tool tip listeners.
			this[KIT_HAIR].blendMode = BlendMode.MULTIPLY;
			this[KIT_SKIN].blendMode = BlendMode.MULTIPLY;
			this[KIT_TOP].blendMode = BlendMode.MULTIPLY;
			this[KIT_BOTTOM].blendMode = BlendMode.MULTIPLY;
			this[KIT_SOCKS].blendMode = BlendMode.MULTIPLY;
			this[KIT_SHOES].blendMode = BlendMode.MULTIPLY;
		}
		
		public function setKitColor(kc:KitColorSettings):void {
			var ct:ColorTransform = new ColorTransform();
			try {
				ct.color = kc.hair;
				this[KIT_HAIR].transform.colorTransform = ct;
				ct.color = kc.skin;
				this[KIT_SKIN].transform.colorTransform = ct;
				ct.color = kc.top;
				this[KIT_TOP].transform.colorTransform = ct;
				ct.color = kc.bottom;
				this[KIT_BOTTOM].transform.colorTransform = ct;
				ct.color = kc.socks;
				this[KIT_SOCKS].transform.colorTransform = ct;
				ct.color = kc.shoes;
				this[KIT_SHOES].transform.colorTransform = ct;
			} catch (error:Error) {
				trace("(A) MCPlayer.as: Can't apply kit color to "+this.name+".");
			}
		}
		
		public function setKitColorFromXML(kitXML:XML) {
			var kc:KitColorSettings = new KitColorSettings(
				kitXML._hairColor,
				kitXML._skinColor,
				kitXML._topColor,
				kitXML._bottomColor,
				kitXML._socksColor,
				kitXML._shoesColor
			);
			setKitColor(kc);
		}
	}
}