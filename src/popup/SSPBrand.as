package src.popup
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class SSPBrand extends MovieClip
	{
		private var mcContainer:MovieClip;
		private var useSSPBrand:Boolean;
		private var brandText:String;
		private var areaW:Number = 663;
		private var areaH:Number = 388;
		private var marginW:uint = 10;
		private var marginH:uint = 5;
		
		public function SSPBrand(useSSPBrand:Boolean, brandText:String, areaW:Number, areaH:Number)
		{
			super();
			
			this.useSSPBrand = useSSPBrand;
			this.brandText = brandText;
			this.areaW = areaW;
			this.areaH = areaH;
			
			if (useSSPBrand) {
				initSSPGraphic();
			} else {
				initLabel();
			}
		}
		
		private function initSSPGraphic():void {
			var sspBrandingLogo:MovieClip = new mcSSPUrl();
			setupContainer(sspBrandingLogo);
		}
		
		private function initLabel():void {
			var txtLabel:TextField = new TextField();
			var format:TextFormat		= new TextFormat();
			var maxChars:uint = 50;
			var txtColor:uint = 0xFFFFFF;
			
			format.font					= "_sans";
			format.size					= 24;
			format.color				= txtColor;
			format.bold					= true;
			format.italic				= true;
			
			txtLabel.defaultTextFormat	= format;
			txtLabel.type				= TextFieldType.DYNAMIC;
			txtLabel.autoSize			= TextFieldAutoSize.LEFT;
			//txtLabel.visible			= false;
			txtLabel.selectable			= false;
			txtLabel.maxChars			= maxChars;
			txtLabel.border				= false;
			txtLabel.multiline			= false;
			txtLabel.wordWrap			= false;
			txtLabel.background			= false;
			txtLabel.textColor			= txtColor;
			//txtLabel.backgroundColor	= 0;
			//txtLabel.width			= txtW;
			//txtLabel.height			= txtH;
			//txtLabel.x				= 0;
			//txtLabel.y				= 0;
			txtLabel.text				= brandText;
			setupContainer(txtLabel);
		}
		
		private function setupContainer(obj:DisplayObject):void {
			mcContainer = new MovieClip();
			mcContainer.filters = getFilters();
			mcContainer.addChild(obj);
			mcContainer.x = areaW-mcContainer.width-marginW;
			mcContainer.y = areaH-mcContainer.height-marginH;
			this.addChild(mcContainer);
		}
		
		private function getFilters():Array {
			var dropShadow:DropShadowFilter = new DropShadowFilter();
			dropShadow.distance = 3;
			dropShadow.angle = 45;
			dropShadow.color = 0x000000;
			dropShadow.alpha = 1;
			dropShadow.blurX = 4;
			dropShadow.blurY = 4;
			dropShadow.strength = 1; // Values from 0 to 255.
			dropShadow.quality = BitmapFilterQuality.LOW;
			dropShadow.inner = false;
			dropShadow.knockout = false;
			dropShadow.hideObject = false;
			return [dropShadow];
		}
	}
}