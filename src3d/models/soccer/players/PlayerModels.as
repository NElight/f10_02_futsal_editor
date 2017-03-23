package src3d.models.soccer.players
{
	import flash.display.Bitmap;

	/**
	 * Collection of common objects and textures. 
	 * It helps to reduce the file size by having a single embedded object. 
	 * 
	 */	
	public class PlayerModels
	{
		// Player Textures.
		[Embed(source="images/player.jpg")]
		private var PlayerM_Bitmap:Class;
		public var player:Bitmap = new PlayerM_Bitmap();
		
		// Goalkeeper Texture.
		[Embed(source="images/goalkeeper.jpg")]
		private var GoalkeeperM_Bitmap:Class;
		public var goalkeeper:Bitmap = new GoalkeeperM_Bitmap();
		
		// Official Texture.
		//[Embed(source="images/official.jpg")]
		//private var OfficialM_Bitmap:Class;
		//public var official:Bitmap = new OfficialM_Bitmap();
		public var official:Bitmap = player; // Same texture than player.
		
		// Player Masks.
		[Embed(source="images/player_mask_skin.png")]
		public var PlayerM_Mask_Skin_Bitmap:Class;
		[Embed(source="images/player_mask_hair.png")]
		public var PlayerM_Mask_Hair_Bitmap:Class;
		[Embed(source="images/player_mask_top.png")]
		public var PlayerM_Mask_Top_Bitmap:Class;
		[Embed(source="images/player_mask_bottom.png")]
		public var PlayerM_Mask_Bottom_Bitmap:Class;
		[Embed(source="images/player_mask_socks.png")]
		public var PlayerM_Mask_Socks_Bitmap:Class;
		[Embed(source="images/player_mask_shoes.png")]
		public var PlayerM_Mask_Shoes_Bitmap:Class;
		
		// Goalkeeper Masks.
		[Embed(source="images/goalkeeper_mask_skin.png")]
		public var GoalkeeperM_Mask_Skin_Bitmap:Class;
		[Embed(source="images/goalkeeper_mask_top.png")]
		public var GoalkeeperM_Mask_Top_Bitmap:Class;
		
		
		// Players.
		public var player_mask_skin:Bitmap = new PlayerM_Mask_Skin_Bitmap();
		public var player_mask_hair:Bitmap = new PlayerM_Mask_Hair_Bitmap();
		public var player_mask_top:Bitmap = new PlayerM_Mask_Top_Bitmap();
		public var player_mask_bottom:Bitmap = new PlayerM_Mask_Bottom_Bitmap();
		public var player_mask_socks:Bitmap = new PlayerM_Mask_Socks_Bitmap();
		public var player_mask_shoes:Bitmap = new PlayerM_Mask_Shoes_Bitmap();
		
		// Keepers.
		public var goalkeeper_mask_skin:Bitmap = new GoalkeeperM_Mask_Skin_Bitmap(); // Long Sleeves.
		public var goalkeeper_mask_hair:Bitmap = player_mask_hair;
		public var goalkeeper_mask_top:Bitmap = new GoalkeeperM_Mask_Top_Bitmap(); // Long Sleeves.
		public var goalkeeper_mask_bottom:Bitmap = player_mask_bottom;
		public var goalkeeper_mask_socks:Bitmap = player_mask_socks;
		public var goalkeeper_mask_shoes:Bitmap = player_mask_shoes;
		
		// Officials.
		public var official_mask_skin:Bitmap = player_mask_skin;
		public var official_mask_hair:Bitmap = player_mask_hair;
		public var official_mask_top:Bitmap = player_mask_top;
		public var official_mask_bottom:Bitmap = player_mask_bottom;
		public var official_mask_socks:Bitmap = player_mask_socks;
		public var official_mask_shoes:Bitmap = player_mask_shoes;
		
		
		// -- 3D Models --
		[Embed(source="Player001a.3ds", mimeType="application/octet-stream")]
		public var Player001a:Class;
		
		[Embed(source="Player002a.3ds", mimeType="application/octet-stream")]
		public var Player002a:Class;
		
		[Embed(source="Player003a.3ds", mimeType="application/octet-stream")]
		public var Player003a:Class;
		
		[Embed(source="Player004a.3ds", mimeType="application/octet-stream")]
		public var Player004a:Class;
		
		[Embed(source="Player005a.3ds", mimeType="application/octet-stream")]
		public var Player005a:Class;
		
		[Embed(source="Player006a.3ds", mimeType="application/octet-stream")]
		public var Player006a:Class;
		
		[Embed(source="Player007a.3ds", mimeType="application/octet-stream")]
		public var Player007a:Class;
		
		[Embed(source="Player008a.3ds", mimeType="application/octet-stream")]
		public var Player008a:Class;
		
		[Embed(source="Player009a.3ds", mimeType="application/octet-stream")]
		public var Player009a:Class;
		
		[Embed(source="Player010a.3ds", mimeType="application/octet-stream")]
		public var Player010a:Class;
		
		// Player 11 is used as player and keeper.
		[Embed(source="Player011a.3ds", mimeType="application/octet-stream")]
		public var Player011a:Class;
		
		[Embed(source="Player012a.3ds", mimeType="application/octet-stream")]
		public var Player012a:Class;
		
		[Embed(source="Player013a.3ds", mimeType="application/octet-stream")]
		public var Player013a:Class;
		
		// Player 14 is used as player and keeper.
		[Embed(source="Player014a.3ds", mimeType="application/octet-stream")]
		public var Player014a:Class;
		
		// Player 15 is used as player and keeper.
		[Embed(source="Player015a.3ds", mimeType="application/octet-stream")]
		public var Player015a:Class;
		
		[Embed(source="Player016a.3ds", mimeType="application/octet-stream")]
		public var Player016a:Class;
		
		[Embed(source="Player017a.3ds", mimeType="application/octet-stream")]
		public var Player017a:Class;
		
		[Embed(source="Player018a.3ds", mimeType="application/octet-stream")]
		public var Player018a:Class;
		
		[Embed(source="Player019a.3ds", mimeType="application/octet-stream")]
		public var Player019a:Class;
		
		[Embed(source="Player020a.3ds", mimeType="application/octet-stream")]
		public var Player020a:Class;
		
		[Embed(source="Player021a.3ds", mimeType="application/octet-stream")]
		public var Player021a:Class;
		
		[Embed(source="Player022a.3ds", mimeType="application/octet-stream")]
		public var Player022a:Class;
		
		[Embed(source="Player023a.3ds", mimeType="application/octet-stream")]
		public var Player023a:Class;
		
		[Embed(source="Player024a.3ds", mimeType="application/octet-stream")]
		public var Player024a:Class;
		
		private static var _self:PlayerModels;
		private static var _allowInstance:Boolean = false;
		
		public function PlayerModels()
		{
			if(!_allowInstance){
				throw new Error("You must use ModelsLibrary.getInstance()");   
			}else{
				//trace("ModelsLibrary initialized.");
				//init();
			}
		}
		
		public static function getInstance():PlayerModels
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new PlayerModels();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}

	}
}