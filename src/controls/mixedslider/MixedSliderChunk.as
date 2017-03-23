package src.controls.mixedslider
{
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import src3d.utils.ColorUtils;
	
	public class MixedSliderChunk extends MovieClip
	{
		private var barW:int = 500;
		private var barH:int = 30;
		private var barS:int = 20;
		
		private var txtTitle:TextField;
		
		private var shpColorBar:Shape;
		private var shpBWBar:Shape;
		private var shpHandle:Shape;
		
		private var useHandle:Boolean;
		
		public function MixedSliderChunk(barColor:uint, barText:String, barWidth:Number, barHeight:Number, barSelect:Number, useHandle:Boolean)
		{
			super();
			this.barW = barWidth;
			this.barH = barHeight;
			this.barS = barSelect;
			this.useHandle = useHandle;
			initBar(barColor);
			initText(barText);
			//this.buttonMode = true;
		}
		
		private function initBar(col:uint, handleCol:uint = 0x000000, handleWidth:uint = 30):void {
			shpColorBar = new Shape();
			//shpColorBar.graphics.lineStyle(2);
			shpColorBar.graphics.beginFill(col, 1);
			shpColorBar.graphics.drawRect(0, 0, barW, barH);
			shpColorBar.graphics.endFill();
			shpColorBar.blendMode = BlendMode.LAYER;
			this.addChild(shpColorBar);
			
			// Convert to bw.
			shpBWBar = new Shape();
			//shpColorBar.graphics.lineStyle(2);
			shpBWBar.graphics.beginFill(ColorUtils.hexColorToBW(col), 1);
			shpBWBar.graphics.drawRect(0, 0, barW, barH);
			shpBWBar.graphics.endFill();
			shpBWBar.blendMode = BlendMode.LAYER;
			shpBWBar.alpha = .3;
			shpBWBar.visible = false;
			this.addChild(shpBWBar);
			
			if (useHandle) {
				shpHandle = new Shape();
				//sprite.graphics.lineStyle(2);
				shpHandle.graphics.beginFill(handleCol, .15);
				shpHandle.graphics.drawRect(0, 0, handleWidth, barH);
				shpHandle.graphics.endFill();
				shpHandle.blendMode = BlendMode.MULTIPLY;
				this.addChild(shpHandle);
			}
		}
		
		protected function initText(strText:String):void {
			var txtW = 150;
			var txtH = 20;
			txtTitle = getTextField(txtW, txtH);
			txtTitle.x = 3;
			txtTitle.y = 5;
			txtTitle.text = strText;
			this.addChild(txtTitle);
		}
		
		private function getTextField(txtW:Number, txtH:Number):TextField {
			var newTxt:TextField;
			var format:TextFormat		= new TextFormat();
			//format.font				= FONT;
			format.font					= "_sans";
			format.size					= 12;
			format.color				= "0x000000";
			
			newTxt 						= new TextField();
			newTxt.defaultTextFormat	= format;
			newTxt.type					= TextFieldType.DYNAMIC;
			newTxt.selectable			= false;
			newTxt.text					= "";
			newTxt.border				= false;
			//newTxt.x					= 0;
			//newTxt.y					= barH;
			newTxt.multiline			= false;
			newTxt.wordWrap				= false;
			newTxt.background			= false;
			//newTxt.backgroundColor	= 0xFFFF99;
			newTxt.width				= txtW;
			newTxt.height				= txtH;
			//newTxt.maxChars			= 100;
			newTxt.textColor			= 0;
			
			return newTxt;
		}
		
		public function get barWidth():Number {
			return shpColorBar.width;
		}
		public function set barWidth(value:Number):void {
			if (isNaN(value)) return;
			if (value < 0) return;
			var absValue:Number = Math.abs(value);
			shpColorBar.width = absValue;
			shpBWBar.width = absValue;
			txtTitle.width = absValue;
			this.x = barW-absValue;
		}
		
		public function get barTitle():String {
			return txtTitle.text;
		}
		public function set barTitle(value:String):void {
			if (!value) return;
			txtTitle.text = value;
		}
		
		public function set barEnabled(value:Boolean):void {
			if (value) {
				shpColorBar.visible = true;
				shpBWBar.visible = false;
			} else {
				shpColorBar.visible = false;
				shpBWBar.visible = true;
			}
		}
	}
}