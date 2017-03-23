package src3d.models
{
	import away3d.materials.BitmapMaterial;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	import src3d.SessionGlobals;
	import src3d.models.soccer.players.PlayerKit;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerModels;
	import src3d.utils.ColorUtils;

	/**
	 * The kits library is a singleton library that will create and store the default kits bitmapdata.
	 * It will also store the last used Custom Kit bitmap data to reuse it if possible.
	 * This saves time and memory when creating a new player.
	 */	
	public class KitsLibrary {
		
		private static var _self:KitsLibrary;
		private static var _allowInstance:Boolean = false;
		
		public static const KIT_ID_OUR:int = 0; // Ours.
		public static const KIT_ID_OPP:int = 1; // Opposition.
		public static const KIT_ID_OFF:int = 2; // Officials.
		
		private static var libraryInitialized:Boolean = false;
		private static var kL:XMLList;
		private static var defaultKits:Array = new Array(5); // Stores the kit values and materials for every default kit, to reuse them later.
		private static var lastCustomKit:Object = {}; // Stores the last used custom kit values and bmd, to be reused if possible.
		
		private static var mL:PlayerModels = PlayerModels.getInstance();
		
		// Global variables.
		private var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		
		
		public function KitsLibrary()
		{
			if(!_allowInstance){
				throw new Error("You must use KitsLibrary.getInstance()");   
			}else{
				//trace("Kits Library initialized.");
				//init();
			}
		}
		
		public static function getInstance():KitsLibrary
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new KitsLibrary();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		/**
		 * Loads the default kits from xml and create the default TextureMaterial. 
		 */		
		public function initKitsLibrary():void {
			kL = sD.session.kit;
			var kit:XML;
			lastCustomKit._cKit = new PlayerKitSettings();
			
			for (var i:int;i<kL.length();i++) {
				kit = kL[i];
				defaultKits[i] = {};
				defaultKits[i]._kitId = kit._kitId;
				defaultKits[i]._kitTypeId = kit._kitTypeId;
				defaultKits[i]._material = new BitmapMaterial(createTextureFromXML(kit)); 
			}
		}
		
		
		public function getMaterialFromKit(kitColors:PlayerKitSettings, defaultKit:Boolean = false):BitmapMaterial {
			var newMaterial:BitmapMaterial = new BitmapMaterial(new BitmapData(8,8));
			newMaterial.blendMode
			if (defaultKit) {
				newMaterial = getDefaultKitMaterial(kitColors._kitId, kitColors._kitTypeId);
			} else {
				if (!kitColors.sameKitThan(lastCustomKit._cKit)) {
					lastCustomKit._cKit = kitColors;
					lastCustomKit._bmd = createTextureFromObj(kitColors);
				}
				newMaterial = new BitmapMaterial(lastCustomKit._bmd);
			}
			return newMaterial;
		}
		
		public function updateDefaultKit(dKit:PlayerKitSettings):void {
			for (var i:int;i>defaultKits.length;i++) {
				if (defaultKits[i]._dKit._kitId == dKit._kitId && defaultKits[i]._dKit._kitTypeId == dKit._kitTypeId) {
					if (!dKit.sameKitThan(defaultKits[i]._dKit)){
						defaultKits[i]._dKit = dKit;
						defaultKits[i]._material = new BitmapMaterial(createTextureFromObj(dKit));
					}
				} else {
					trace("Error: No defualt kit updated in KitsLibrary.");
				}
			}
		}
		
		/**
		 * Creates a texture with the specified kit values. 
		 * @param kit
		 * @return BitmapData. The final texture with all the kit colours applied.
		 * 
		 */		
		private function createTextureFromXML(oXML:XML):BitmapData {
			var _kit:PlayerKitSettings = new PlayerKitSettings();
			//_kit._kitId = uint( oXML._kitId.text() );
			//_kit._kitTypeId = uint( oXML._kitTypeId.text() );
			_kit._skinColor = uint( oXML._skinColor.text() );
			_kit._hairColor = uint( oXML._hairColor.text() );
			_kit._topColor = uint( oXML._topColor.text() );
			_kit._bottomColor = uint( oXML._bottomColor.text() );
			_kit._socksColor = uint( oXML._socksColor.text() );
			_kit._shoesColor = uint( oXML._shoesColor.text() );
			return createTextureFromObj(_kit);
		}
		
		private function createTextureFromObj(kitColors:PlayerKitSettings):BitmapData {
			var mask_skin_bmd:BitmapData;
			var mask_hair_bmd:BitmapData;
			var mask_socks_bmd:BitmapData;
			var mask_shoes_bmd:BitmapData;
			var mask_top_bmd:BitmapData;
			var mask_bottom_bmd:BitmapData;
			var newBmd:BitmapData;
			
			// Get masks.
			if (kitColors._kitId == PlayerKitSettings.KIT_ID_2_OFFICIALS) {
				mask_skin_bmd = mL.official_mask_skin.bitmapData;
				mask_hair_bmd = mL.official_mask_hair.bitmapData;
				mask_socks_bmd = mL.official_mask_socks.bitmapData;
				mask_shoes_bmd = mL.official_mask_shoes.bitmapData;
				mask_top_bmd = mL.official_mask_top.bitmapData;
				mask_bottom_bmd = mL.official_mask_bottom.bitmapData;
				newBmd = mL.official.bitmapData.clone(); // Create new BitmapData.
			} else if (kitColors._kitTypeId == PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS) {
				mask_skin_bmd = mL.goalkeeper_mask_skin.bitmapData;
				mask_hair_bmd = mL.goalkeeper_mask_hair.bitmapData;
				mask_socks_bmd = mL.goalkeeper_mask_socks.bitmapData;
				mask_shoes_bmd = mL.goalkeeper_mask_shoes.bitmapData;
				mask_top_bmd = mL.goalkeeper_mask_top.bitmapData;
				mask_bottom_bmd = mL.goalkeeper_mask_bottom.bitmapData;
				newBmd = mL.goalkeeper.bitmapData.clone(); // Create new BitmapData.
			} else {
				mask_skin_bmd = mL.player_mask_skin.bitmapData;
				mask_hair_bmd = mL.player_mask_hair.bitmapData;
				mask_socks_bmd = mL.player_mask_socks.bitmapData;
				mask_shoes_bmd = mL.player_mask_shoes.bitmapData;
				mask_top_bmd = mL.player_mask_top.bitmapData;
				mask_bottom_bmd = mL.player_mask_bottom.bitmapData;
				newBmd = mL.player.bitmapData.clone(); // Create new BitmapData.
			}
			
			// Apply Skin Color.
			newBmd.draw( ColorUtils.colorBmp(newBmd, uint(kitColors._skinColor), BlendMode.MULTIPLY, mask_skin_bmd) );
			newBmd.draw( ColorUtils.colorBmp(newBmd, uint(kitColors._hairColor), BlendMode.MULTIPLY, mask_hair_bmd) );
			newBmd.draw( ColorUtils.colorBmp(newBmd, uint(kitColors._topColor), BlendMode.MULTIPLY, mask_top_bmd) );
			newBmd.draw( ColorUtils.colorBmp(newBmd, uint(kitColors._bottomColor), BlendMode.MULTIPLY, mask_bottom_bmd) );
			newBmd.draw( ColorUtils.colorBmp(newBmd, uint(kitColors._socksColor), BlendMode.MULTIPLY, mask_socks_bmd) );
			newBmd.draw( ColorUtils.colorBmp(newBmd, uint(kitColors._shoesColor), BlendMode.MULTIPLY, mask_shoes_bmd) );
			
			mask_skin_bmd = null;
			mask_hair_bmd = null;
			mask_socks_bmd = null;
			mask_shoes_bmd = null;
			mask_top_bmd = null;
			mask_bottom_bmd = null;

			return newBmd;
		}
		
		private function getDefaultKitMaterial(kitId:int, kitTypeId:int):BitmapMaterial {
			for (var i:int;i>defaultKits.length;i++) {
				if (defaultKits[i]._dKit._kitId == kitId && defaultKits[i]._dKit._kitTypeId == kitTypeId) {
					return defaultKits[i]._material;
				} else {
					trace("Error: No defualt kit found in KitsLibrary.");
				}
			}
			return new BitmapMaterial(new BitmapData(8,8));
		}
		
		public function getDefaultPlayerKitSettings(kitId:int, kitTypeId:int):PlayerKitSettings {
			var pKit:PlayerKit = new PlayerKit(kitId, kitTypeId);
			return pKit.getKitColors();
		}
	}
}