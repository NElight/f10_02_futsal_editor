package src3d.models.soccer.players
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.BitmapMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import src3d.text.MCTextCustom;
	import src3d.text.TextSettings;
	import src3d.utils.MiscUtils;
	import src3d.utils.ModelUtils;
	
	public class PlayerText extends ObjectContainer3D
	{
		
		private var txtField1:TextField = new TextField();
		private var mcText:MovieClip = new MovieClip();
		private var sprite:Sprite3D = new Sprite3D();
		
		public function PlayerText(strText:String)
		{
			initTextFields();
			updateText(strText);
		}
		
		protected function initTextFields():void {
			var borderFX:GlowFilter = new GlowFilter(0xFFFFFF,1,3,3,10);
			var textSize:uint = 12;
			var tf:TextFormat = new TextFormat("_sans", textSize,0x000000);
			tf.align = TextFormatAlign.LEFT;
			txtField1.type = TextFieldType.DYNAMIC;
			txtField1.defaultTextFormat = tf;
			txtField1.name = "txtField1";
			txtField1.border = false;
			txtField1.selectable = false;
			txtField1.multiline = true;
			txtField1.width = 140;
			txtField1.height = 70;
			txtField1.maxChars = 30;
			txtField1.y = 24;
			//txtField1.setTextFormat(tf); // Apply TextFormat settings to current format.
			txtField1.filters = [borderFX];
			mcText.addChild(txtField1);
		}
		
		public function updateText(strText:String):void {
			updateSprite(strText);
		}
		
		private function updateSprite(strText:String):void {
			var textBmp:Bitmap = getCustomTextBmd(strText);
			sprite.material = new BitmapMaterial(textBmp.bitmapData, {smooth: true});
			sprite.width = textBmp.width;
			sprite.height = textBmp.height;
			sprite.distanceScaling = false;
			sprite.y = sprite.height/2;
			this.addSprite(sprite);
		}
		
		private function getCustomTextBmd(strText:String):Bitmap {
			var newBmp:Bitmap;
			txtField1.text = (strText)? strText : "";
			
			newBmp = MiscUtils.takeScreenshot(mcText, true, 0x00000000, true);
			return newBmp;
		}
		
		public function dispose():void {
			sprite.material = null;
			ModelUtils.clearObjectContainer3D(this, true, true);
			
			sprite = null;
			this.ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}