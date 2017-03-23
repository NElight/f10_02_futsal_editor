package src3d.text
{
	public class TextLibrary
	{
		// Line Types.
		public static const TYPE_TEXT_CHAR:uint = 0;
		public static const TYPE_TEXT_CUSTOM:uint = 1;
		
		public static const FONT_SIZE_ID_SMALL:int = 0;
		public static const FONT_SIZE_ID_MEDIUM:int = 1;
		public static const FONT_SIZE_ID_BIG:int = 2;
		
		private static const FONT_SIZE_SMALL:uint = 10;
		private static const FONT_SIZE_MEDIUM:uint = 14;
		private static const FONT_SIZE_BIG:uint = 18;
		
		//private static const FONT_SIZE_ARRAY:Array = new Array(FONT_SIZE_SMALL, FONT_SIZE_MEDIUM, FONT_SIZE_BIG);
		
		public function TextLibrary()
		{
			/*Format note: 
			_textStyle[line1_style, line1_colour, line1_textsize, line2_style, line2_colour, line2_textsize]
			Eg: 
			_textStyle="1,0xFF0000,2,0,0x000000,1"
			_textLine1="Player1name &amp; Player2name"
			_textLine2="Defense"*/ 
		}
		
		public static function getFontSizeIdFromSize(size:int):uint {
			var fontSizeId:uint;
			switch (size) {
				case FONT_SIZE_SMALL:
					fontSizeId = FONT_SIZE_ID_SMALL;
					break;
				case FONT_SIZE_MEDIUM:
					fontSizeId = FONT_SIZE_ID_MEDIUM;
					break;
				case FONT_SIZE_BIG:
					fontSizeId = FONT_SIZE_ID_BIG;
					break;
				default:
					fontSizeId = FONT_SIZE_ID_MEDIUM;
					break;
			}
			return fontSizeId;
		}
		
		public static function getFontSizeFromId(fontSizeId:int):uint {
			var newSize:uint;
			switch (fontSizeId) {
				case FONT_SIZE_ID_SMALL:
					newSize = FONT_SIZE_SMALL;
					break;
				case FONT_SIZE_ID_MEDIUM:
					newSize = FONT_SIZE_MEDIUM;
					break;
				case FONT_SIZE_ID_BIG:
					newSize = FONT_SIZE_BIG;
					break;
				default:
					newSize = FONT_SIZE_MEDIUM;
					break;
			}
			return newSize;
		}
	}
}