package src3d.models.soccer.equipment
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * Collection of common textures. 
	 * It helps to reduce the file size by having a single embedded object. 
	 * 
	 */	
	public class EquipmentTextures
	{
		private static var _self:EquipmentTextures;
		private static var _allowInstance:Boolean = false;
		
		[Embed(source="images/net.png")]
		private var Net_Bitmap:Class;
		public var net_Bmd:BitmapData = new Net_Bitmap().bitmapData;
		
		[Embed(source="images/disc.jpg")]
		private var Disc_Bitmap:Class;
		public var disc_Bmd:BitmapData = new Disc_Bitmap().bitmapData;
		
		[Embed(source="images/pole.jpg")]
		private var Pole_Bitmap:Class;
		public var pole_Bmd:BitmapData = new Pole_Bitmap().bitmapData;
		
		[Embed(source="images/poles.jpg")]
		private var Poles_Bitmap:Class;
		public var poles_Bmd:BitmapData = new Poles_Bitmap().bitmapData;
		
		[Embed(source="images/poles2.png")]
		private var Poles2_Bitmap:Class;
		public var poles2_Bmd:BitmapData = new Poles2_Bitmap().bitmapData;
		
		[Embed(source="images/goalposts.png")]
		private var GoalPosts_Bitmap:Class;
		public var goalposts_Bmd:BitmapData = new GoalPosts_Bitmap().bitmapData;
		
		[Embed(source="images/mannequin.jpg")]
		private var Mannequin_Bitmap:Class;
		public var mannequin_Bmd:BitmapData = new Mannequin_Bitmap().bitmapData;
		
		[Embed(source="images/gradient1.jpg")]
		private var Gradient1_Bitmap:Class;
		public var gradient1_Bmd:BitmapData = new Gradient1_Bitmap().bitmapData;
		
		[Embed(source="images/square_gradient.jpg")]
		private var Square_Gradient_Bitmap:Class;
		public var square_gradient_Bmd:BitmapData = new Square_Gradient_Bitmap().bitmapData;
		
		[Embed(source="images/balance_ball.jpg")]
		private var Balance_Ball_Bitmap:Class;
		public var balance_ball_Bmd:BitmapData = new Balance_Ball_Bitmap().bitmapData;
		
		[Embed(source="images/rebound_board_1.jpg")]
		private var Rebound_Board_1_Bitmap:Class;
		public var rebound_board_1_Bmd:BitmapData = new Rebound_Board_1_Bitmap().bitmapData;
		
		/*[Embed(source="images/rebound_board_2.jpg")]
		private var Rebound_Board_2_Bitmap:Class;
		public var rebound_board_2_Bitmap:Bitmap = new Rebound_Board_2_Bitmap();*/
		
		[Embed(source="images/speed_chute.jpg")]
		private var Speed_Chute_Bitmap:Class;
		public var speed_chute_Bmd:BitmapData = new Speed_Chute_Bitmap().bitmapData;
		
		[Embed(source="images/football.jpg")]
		private var Football_Bitmap:Class;
		public var football_Bmd:BitmapData = new Football_Bitmap().bitmapData;
		
		[Embed(source="images/tyre.png")]
		private var Tyre_Bitmap:Class;
		public var tyre_Bmd:BitmapData = new Tyre_Bitmap().bitmapData;
		
		[Embed(source="images/flat_disc_marker.png")]
		private var Flat_Disc_Marker_Bitmap:Class;
		public var flat_disc_marker_Bmd:BitmapData = new Flat_Disc_Marker_Bitmap().bitmapData;
		
		[Embed(source="images/flat_shoes.png")]
		private var Flat_Shoes_Bitmap:Class;
		public var flat_shoes_Bmd:BitmapData = new Flat_Shoes_Bitmap().bitmapData;
		
		[Embed(source="images/head_tennis_net.png")]
		private var Head_Tennis_Net_Bitmap:Class;
		public var head_tennis_net_Bmd:BitmapData = new Head_Tennis_Net_Bitmap().bitmapData;
		
		// MASKS.
		
		[Embed(source="images/pole_mask.png")]
		private var Pole_Mask_Bitmap:Class;
		public var pole_mask_Bmd:BitmapData = new Pole_Mask_Bitmap().bitmapData;
		
		[Embed(source="images/balance_ball_mask.png")]
		private var Balance_Ball_Mask_Bitmap:Class;
		public var balance_ball_mask:BitmapData = new Balance_Ball_Mask_Bitmap().bitmapData;
		
		[Embed(source="images/rebound_board_1_mask.png")]
		private var Rebound_Board_1_Mask_Bitmap:Class;
		public var rebound_board_1_mask_Bmd:BitmapData = new Rebound_Board_1_Mask_Bitmap().bitmapData;
		
		[Embed(source="images/flat_shoes_mask.png")]
		private var Flat_Shoes_Mask_Bitmap:Class;
		public var flat_shoes_mask_Bmd:BitmapData = new Flat_Shoes_Mask_Bitmap().bitmapData;
		
		[Embed(source="images/head_tennis_net_mask.png")]
		private var Head_Tennis_Net_Mask_Bitmap:Class;
		public var head_tennis_net_mask_Bmd:BitmapData = new Head_Tennis_Net_Mask_Bitmap().bitmapData;
		
		/*[Embed(source="images/speed_chute_mask.png")]
		private var Speed_Chute_Bitmap_Mask:Class;
		public var speed_chute_mask_Bmd:BitmapData = new Speed_Chute_Bitmap_Mask().bitmapData;*/

		public function EquipmentTextures() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():EquipmentTextures {
			if(_self == null) {
				_allowInstance=true;
				_self = new EquipmentTextures();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
	}
}