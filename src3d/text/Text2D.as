package src3d.text
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.BitmapMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import src3d.text.MCTextCustom;
	import src3d.text.TextSettings;
	import src3d.utils.MiscUtils;
	import src3d.utils.ModelUtils;
	
	public class Text2D
	{
		private static var _self:Text2D;
		private static var _allowInstance:Boolean = false;
		
		private var txt1:TextField;
		private var txt1Format:TextFormat;
		
		public function Text2D()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("Singleton initialized.");
			}
		}
		
		public static function getInstance():Text2D {
			if(_self == null) {
				_allowInstance=true;
				_self = new Text2D();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		protected function initTextFields():void {
			var textSize:uint = 12;
			txt1Format = new TextFormat("_sans", textSize, 0x000000);
			txt1Format.align = TextFormatAlign.LEFT;
			txt1 = new TextField();
			txt1.type = TextFieldType.DYNAMIC;
			txt1.defaultTextFormat = txt1Format;
			txt1.name = "txt1";
			txt1.border = false;
			txt1.selectable = false;
			txt1.multiline = true;
			//txt1.width = 140;
			//txt1.height = 70;
			txt1.maxChars = 30;
			txt1.y = 24;
			//txt1.setTextFormat(tf); // Apply TextFormat settings to current format.
		}
		
		public function getCustomTextBmp(strText:String, asHTML:Boolean, textSize:Number = 12, textAlign:String = TextFormatAlign.LEFT, textColor:uint = 0, useBorder:Boolean = true, borderColor:uint = 0xFFFFFF):Bitmap {
			var newBmp:Bitmap;
			if (!txt1) initTextFields();
			var spr:MovieClip = new MovieClip();
			spr.addChild(txt1);
			if (!asHTML) {
				txt1.text = (strText)? strText : "";
			} else {
				txt1.htmlText = (strText)? strText : "";
			}
			txt1Format.size = textSize;
			txt1Format.color = textColor;
			txt1Format.align = textAlign;
			txt1.setTextFormat(txt1Format);
			txt1.autoSize = TextFieldAutoSize.LEFT;
			txt1.filters = (useBorder)? [new GlowFilter(borderColor,1,4,4,10)] : [];
			newBmp = MiscUtils.takeScreenshot(txt1, true, 0xCCCCCC, true, 16);
			return newBmp;
		}
	}
}