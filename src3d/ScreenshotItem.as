package src3d
{
	import flash.display.Bitmap;

	public class ScreenshotItem
	{
		public var bitmap:Bitmap;
		public var text:String;
		public var screenId:int;
		public var screenSO:int;
		
		public function ScreenshotItem(bitmap:Bitmap, text:String, screenId:int, screenSO:int)
		{
			this.bitmap = bitmap;
			this.text = text;
			this.screenId = screenId;
			this.screenSO = screenSO;
		}
	}
}