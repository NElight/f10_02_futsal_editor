package src.utils
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import src3d.utils.Logger;
	
	public class URLNavigator
	{
		public function URLNavigator()
		{
		}
		
		public static function openLocation(location:String, target:String = null):void {
			Logger.getInstance().addEntry("Open location '"+location+"'.");
			try {
				navigateToURL(new URLRequest(location), target);
			} catch(error:Error) {
				Logger.getInstance().addError("Error opening location '"+location+"': "+error.message);
			}
		}
	}
}