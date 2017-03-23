package src3d.text
{
	import fl.managers.style_manager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class MCChar2Custom extends MCTextChar
	{
		private const HEIGHT_SINGLE:Number = 22;
		private const WIDTH_SINGLE:Number = 15.50;
		private const WIDTH_DOUBLE:Number = 25;
		
		private var txtContent:String;
		private var txtField:TextField;
		private var txtBg:Sprite;
		
		public function MCChar2Custom(txtContent:String)
		{
			super();
			this.txtContent = txtContent;
			initBackground();
			initTextField();
		}
		
		public function updateText(textStr:String):void {
			txtField.text = textStr.substr(0,2);
			updateBg(txtField.text.length);
		}
		
		private function initTextField():void {
			// Text Format.
			var tf:TextFormat = new TextFormat();
			tf.font = "_sans";
			tf.size = 16;
			tf.color = 0;
			tf.bold = false;
			tf.italic = false;
			tf.align = TextFormatAlign.CENTER;
			tf.letterSpacing = 0;
			
			// Text Field. 
			txtField.setTextFormat(tf);
			txtField.multiline = false;
			txtField.border = false;
			txtField.selectable = false;
			this.addChild(txtField);
		}
		
		private function initBackground():void {
			txtBg = new Sprite();
			txtBg.graphics.beginFill(0xFFFFFF, 1);
			txtBg.graphics.drawRect(0, 0, WIDTH_SINGLE, HEIGHT_SINGLE);
			txtBg.graphics.endFill();
			txtBg.y = -txtBg.height;
			txtBg.x = txtBg.width/2;
			this.addChild(txtBg);
		}
		
		private function updateBg(txtLength:int):void {
			if (txtLength <= 1) {
				txtBg.width = WIDTH_SINGLE;
			} else {
				txtBg.width = WIDTH_SINGLE+(WIDTH_SINGLE*(0.5*txtLength-1));
			}
		}
	}
}