package src.settings
{
	import fl.data.DataProvider;
	
	import flash.display.DisplayObject;
	
	import src.controls.mixedslider.MixedSliderValues;

	public class ScreenListData extends Object
	{
		public var label:String;
		public var icon:DisplayObject;
		
		public var screenId:String;
		public var screenSO:String;
		public var screenListNum:uint;
		public var screenType:String;
		
		public var screenTitle:String = "";
		public var screenCategoryIdx:int = -1;
		public var screenTimeSpent:uint = 0;
		public var screenCategoryDataProvider:DataProvider;
		
		public function ScreenListData()
		{
			super();
		}
	}
}