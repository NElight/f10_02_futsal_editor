package src.print
{
	import src.controls.gallery.Thumbnail;
	
	import src3d.ScreenshotItem;
	
	public class PrintThumb extends Thumbnail
	{
		private var sItem:ScreenshotItem;
		
		public function PrintThumb(sItem:ScreenshotItem, thumbW:Number=90, thumbH:Number=90)
		{
			super(thumbW, thumbH, true);
			this.sItem = sItem;
			updateScreenshot();
		}
		
		private function updateScreenshot():void {
			updateThumbnailText(sItem.text);
			showThumb(sItem.bitmap);
		}
		
		public function get screenId():int {
			return sItem.screenId;
		}
	}
}