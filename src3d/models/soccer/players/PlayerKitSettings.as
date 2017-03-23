package src3d.models.soccer.players
{
	import away3d.materials.BitmapMaterial;

	public class PlayerKitSettings
	{
		public static const KIT_ID_0_TEAM1:uint = 0; // Team 1.
		public static const KIT_ID_1_TEAM2:uint = 1; // Team 2.
		public static const KIT_ID_2_OFFICIALS:uint = 2; // Officials.
		
		public static const KIT_TYPE_ID_0_PLAYERS:uint = 0; // Players clothes.
		public static const KIT_TYPE_ID_1_GOALKEEPERS:uint = 1; // Goalkeepers clothes.
		
		// Note: Kit variables must match XML variable names.
		public var _kitId:int = 0;
		public var _kitTypeId:int = 0;
		
		public var _skinColor:int = -1;
		public var _hairColor:int = -1;
		public var _topColor:int = -1;
		public var _bottomColor:int = -1;
		public var _socksColor:int = -1;
		public var _shoesColor:int = -1;
		
		// Version 2 Kit variables. (Included for database/XML compatibility).
		public var _hairType:int = -1; // 0 short, 1 long.
		public var _skinTexture:int = -1; // The number indicates the texture (skin) file to be loaded.
		public var _stripesType:int = -1; // 0 no stripes, 1 vertical, 2 horizontal
		public var _stripesColor:int = -1;
		
		public function PlayerKitSettings()
		{
		}
		
		public function setKit(newKit:PlayerKitSettings):void {
			this._kitId = uint(newKit._kitId);
			this._kitTypeId = uint(newKit._kitTypeId);
			this._topColor = newKit._topColor;
			this._bottomColor = newKit._bottomColor;
			this._socksColor = newKit._socksColor;
			this._skinColor = newKit._skinColor;
			this._shoesColor = newKit._shoesColor;
			this._hairColor = newKit._hairColor;
			// v2.
			this._hairType = newKit._hairType;
			this._skinTexture = newKit._skinTexture;
			this._stripesType = newKit._stripesType;
			this._stripesColor = newKit._stripesColor;
		}
		
		public function clearKit():void {
			this._kitId = 0;
			this._kitTypeId = 0;
			this._topColor = -1;
			this._bottomColor = -1;
			this._socksColor = -1;
			this._skinColor = -1;
			this._shoesColor = -1;
			this._hairColor = -1;
			// v2.
			this._hairType = -1;
			this._skinTexture = -1;
			this._stripesType = -1;
			this._stripesColor = -1;
		}
		
		public function clone(_newKit:PlayerKitSettings = null):PlayerKitSettings
		{
			var newKit:PlayerKitSettings = (_newKit as PlayerKitSettings) || new PlayerKitSettings();

			newKit._kitId = this._kitId;
			newKit._kitTypeId = this._kitTypeId;
			newKit._skinColor = this._skinColor;
			newKit._hairColor = this._hairColor;
			newKit._topColor = this._topColor;
			newKit._bottomColor = this._bottomColor;
			newKit._socksColor = this._socksColor;
			newKit._shoesColor = this._shoesColor;
			newKit._hairType = this._hairType;
			newKit._skinTexture = this._skinTexture;
			newKit._stripesType = this._stripesType;
			newKit._stripesColor = this._stripesColor;
			
			return newKit;
		}
		
		/**
		 * Compares the current kit with another kit. 
		 * @param newKit New PlayerKitSettings object to be compared with.
		 * @param compareColorsOnly Boolean. Indicate if we want to compare colors only, not kit id's.
		 * @return True if both kits are identical, according to settings.
		 * 
		 */		
		public function sameKitThan(newKit:PlayerKitSettings):Boolean {
			var sameKit:Boolean = false;
			
			if (newKit._kitId == this._kitId &&
				newKit._kitTypeId == this._kitTypeId &&
				newKit._skinColor == this._skinColor &&
				newKit._hairColor == this._hairColor &&
				newKit._topColor == this._topColor &&
				newKit._bottomColor == this._bottomColor &&
				newKit._socksColor == this._socksColor &&
				newKit._shoesColor == this._shoesColor &&
				newKit._hairType == this._hairType &&
				newKit._skinTexture == this._skinTexture &&
				newKit._stripesType == this._stripesType &&
				newKit._stripesColor == this._stripesColor)
			{
				sameKit = true;	
			}
			
			return sameKit;
		}
	}
}