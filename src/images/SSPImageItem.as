package src.images
{
	import flash.display.Bitmap;

	public class SSPImageItem
	{
		public var screenId:int;
		public var data:Bitmap;
		public var imageLocation:String;
		
		public function SSPImageItem(screenId:int, data:Bitmap = null, imageLocation:String = "")
		{
			this.screenId = screenId;
			this.data = data;
			this.imageLocation = imageLocation;
		}
		
		public function get imageExists():Boolean {
			return (data || (imageLocation && imageLocation != ""))? true : false;
		}
		
		public function get fromServer():Boolean {
			return (!imageLocation || imageLocation == "")? false : true;
		}
	}
}