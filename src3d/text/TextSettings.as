package src3d.text
{
	import flash.display.Bitmap;
	
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.equipment.EquipmentSettings;
	import src3d.utils.MiscUtils;
	
	public class TextSettings extends EquipmentSettings
	{
		public var _textContent:String = "";
		//public var _bmd
		// v2 vars.
		public var _textContent2:String = "";
		private var __textStyle:String = "0,0x000000,1,0,0x000000,1";
		
		public var line1_style:uint = 0;
		public var line1_color:uint = 0x000000;
		public var line1_textsize:uint = 1;
		public var line2_style:uint = 0;
		public var line2_color:uint = 0x000000;
		public var line2_textsize:uint = 1;
		
		public var _textBmp:Bitmap; // Used on drag and drop.
		
		public function TextSettings() {}
		
		public override function clone(cloneIn:SSPObjectBaseSettings = null):SSPObjectBaseSettings
		{
			var newObjSettings:TextSettings = (cloneIn)? cloneIn as TextSettings: new TextSettings();
			super.clone(newObjSettings); // Get base settings.
			newObjSettings._textContent = _textContent;
			newObjSettings._textContent2 = _textContent2;
			newObjSettings._textStyle = _textStyle;
			
			return newObjSettings;
		}
		
		public function get _textStyle():String {
			__textStyle = String (
				line1_style + "," +
				MiscUtils.getNumberAsHexString(line1_color) + "," +
				line1_textsize + "," +
				line2_style + "," +
				MiscUtils.getNumberAsHexString(line2_color) + "," +
				line2_textsize
				);
			return __textStyle;
		}
		
		public function set _textStyle(ts:String):void {
			// Parse the style string.
			var formatArray:Array = ts.split(",");
			line1_style = formatArray[0];
			line1_color = formatArray[1];
			line1_textsize = formatArray[2];
			line2_style = formatArray[3];
			line2_color = formatArray[4];
			line2_textsize = formatArray[5];
			__textStyle = ts;
		}
		
		public function getFontSizeIdFromSize(size:int):uint {
			return TextLibrary.getFontSizeIdFromSize(size);
		}
		
		public function getFontSizeFromId(fontSizeId:int):uint {
			return TextLibrary.getFontSizeFromId(fontSizeId);
		}
	}
}