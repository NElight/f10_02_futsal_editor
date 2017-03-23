package src3d.enviroment
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	/**
	 * Collection of common textures. 
	 * It helps to reduce the file size by having a single embedded object. 
	 * 
	 */	
	public class EnviromentTextures
	{
		private static var _self:EnviromentTextures;
		private static var _allowInstance:Boolean = false;
		
		// Enviroment.
		[Embed(source="ssp_sky.png")]
		private var Ssp_Sky:Class;
		//private var ssp_sky_Bmd:BitmapData = new Ssp_Sky().bitmapData;
		//private var _sspBG:Sprite;
		//public var sspBGBitmap:Bitmap = new Ssp_Sky() as Bitmap;

		public function EnviromentTextures() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():EnviromentTextures {
			if(_self == null) {
				_allowInstance=true;
				_self = new EnviromentTextures();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		public function get sspBGBitmap():Bitmap {
			return new Ssp_Sky() as Bitmap;
		}

	}
}