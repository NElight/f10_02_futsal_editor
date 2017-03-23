package src.images
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class SSPImage extends Bitmap
	{
		public function SSPImage(bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		public function loadImage(location):void {
			
		}
	}
}