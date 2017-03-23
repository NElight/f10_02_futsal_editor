package src3d.models.soccer.players
{
	import src3d.SessionGlobals;

	public class PlayerKit
	{
		// Global variables.
		private var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		
		// The _cKit (customized kit) is used to store the custom colors or -1 if use default is set. It is also the kit stored in the database.
		private var cKit:PlayerKitSettings = new PlayerKitSettings(); // kitId, kitTypeId, top, bottom, socks, skin.
		
		// The _dKit (defult kit) is the one coming from the XML. It is the default kit to apply. it will be compared to the _cKit before apply the colors.
		// If _cKit.[value] = -1, use _dKit.[value]. Else use _cKit.[value].
		private var dKit:PlayerKitSettings = new PlayerKitSettings(); // kitId, kitTypeId, top, bottom, socks, skin
		
		public var kitId:int;
		public var kitTypeId:int;
		
		public function PlayerKit(kitId:int, kitTypeId:int) {
			this.kitId = kitId;
			this.kitTypeId = kitTypeId;
			init();
		}
		
		private function init():void {
			dKit = this.getPlayerDefaultKit(kitId, kitTypeId);
			
			
/*Debug			if (newDefaultKit != null) {
				initDefaultKit(newDefaultKit);
			} else {
				// Don't create a player without kit colors.
				return;
			})
			
			if (newCustomKit != null) {
				// newCustomKit will be null when drag and drop.
				initCustomKit(newCustomKit);
			} else {
				// set default values if null.
				resetCustomKit();
			}*/
		}
		
		private function initDefaultKit(newKit:PlayerKitSettings):void {
			dKit.setKit(newKit);
		}
		
		protected function resetCustomKit():void {
			cKit.clearKit();
			cKit._kitId = dKit._kitId;
			cKit._kitTypeId = dKit._kitTypeId;
		}
		
		public function updateDefaultKit():void {
			initDefaultKit(getPlayerDefaultKit(kitId, kitTypeId));
			cKit._kitId = dKit._kitId;
			cKit._kitTypeId = dKit._kitTypeId;
		}
		
/*F11		public function setDefaultKit(newDKit:PlayerKitSettings):void {
			initDefaultKit(newDKit);
			cKit._kitId = dKit._kitId;
			cKit._kitTypeId = dKit._kitTypeId;
			//Debug			setMaterials();
		}*/
		
		public function setCustomKit(newCKit:PlayerKitSettings):void {
			if (newCKit != null) {
				if (newCKit._kitId > -1) cKit._kitId = newCKit._kitId;
				if (newCKit._kitTypeId > -1) cKit._kitTypeId = newCKit._kitTypeId;
				if (newCKit._topColor > -1) cKit._topColor = newCKit._topColor;
				if (newCKit._bottomColor > -1) cKit._bottomColor = newCKit._bottomColor;
				if (newCKit._socksColor > -1) cKit._socksColor = newCKit._socksColor;
				if (newCKit._skinColor > -1) cKit._skinColor = newCKit._skinColor;
				if (newCKit._shoesColor > -1) cKit._shoesColor = newCKit._shoesColor;
				if (newCKit._hairColor > -1) cKit._hairColor = newCKit._hairColor;
				//Debug			setMaterials();
			} else {
				resetCustomKit();
			}
		}
		
		/**
		 * Get's the specified player kit. 
		 * @param kId int. The _kitId used by that player.
		 * @param kTp int. The _kitType (player, keeper, referee).
		 * @return Object. The returned kit.
		 * 
		 */		
		private function getPlayerDefaultKit(kId:int, kTp:int):PlayerKitSettings {
			var kitObj:PlayerKitSettings = new PlayerKitSettings();
			var elementList:XMLList;
			var objXML:XML;
			// Get the specified kit list.
			elementList = sD.session.kit.(_kitId == kId && _kitTypeId == kTp).children();
			for each(objXML in elementList) {
				// Note that we are assuming that all kit values are numbers. Otherwise we need to define every object.
				kitObj[objXML.localName().toString()] = int( objXML );
			}
			return kitObj;
		}
		
		public function getKitColors():PlayerKitSettings {
			var kitColor:PlayerKitSettings = new PlayerKitSettings();
			
			kitColor._kitId = cKit._kitId;
			kitColor._kitTypeId = cKit._kitTypeId;
			kitColor._topColor = (cKit._topColor == -1)? dKit._topColor : cKit._topColor;
			kitColor._bottomColor = (cKit._bottomColor == -1)? dKit._bottomColor : cKit._bottomColor;
			kitColor._socksColor = (cKit._socksColor == -1)? dKit._socksColor : cKit._socksColor;
			kitColor._skinColor = (cKit._skinColor == -1)? dKit._skinColor : cKit._skinColor;
			kitColor._shoesColor = (cKit._shoesColor == -1)? dKit._shoesColor : cKit._shoesColor;
			kitColor._hairColor = (cKit._hairColor == -1)? dKit._hairColor : cKit._hairColor;
			
			/* Note: Future v2 settings:
			_stripesType = "0";
			_skinTexture = "0";
			_hairType = "0";
			_hairColor = "0x000000";
			_stripesType = "0";
			_stripesColor = "0x000000";
			*/
			
			return kitColor;
		}
		
		public function getCustomKit():PlayerKitSettings {
			return cKit;
		}
	}
}