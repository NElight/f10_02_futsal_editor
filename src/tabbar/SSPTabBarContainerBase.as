package src.tabbar
{
	import flash.display.MovieClip;
	
	public class SSPTabBarContainerBase extends MovieClip
	{
		// Note: Tags used from XML: _screenId, _screenSortOrder, _screenTitle, _screenChangedFlag.
		
		// Tabs.
		public var tabsMax:uint = 10; // Number of tabs that can be created (0 = no limit).
		public var tabsMin:uint = 1; // Number of minimum permanent tabs (cannot be deleted).
		public var tabsMaxAbsolute:uint = 10;
		public var ignoreTabsMax:Boolean = true; // Allow any amount of tabs < tabsMaxAbsolute to be created at start.
		public var tabWidth:Number = 106;
		public var tabHalfWidth:Number = tabWidth / 2;
		public var tabSpace:Number = 5; // Tabs space (added in mc already, but needed for mask).
		private var _selectedTab:SSPTab;
		private var tabLastXPos:Number;
		private var lastMouseX:Number;
		
		public function SSPTabBarContainerBase()
		{
			super();
		}
		
		protected function swapItems(array:Vector.<SSPTabBase>, item1:SSPTabBase, item2:SSPTabBase) {
			var item1pos:int = array.indexOf(item1);
			var item2pos:int = array.indexOf(item2);
			
			if ((item1pos != -1) && (item2pos != -1))
			{
				var tempItem:SSPTabBase = array[item2pos];
				array[item2pos] = array[item1pos];
				array[item1pos] = tempItem;
			}
			
			// If both items are tabs, swap sortOrder.
			if (item1.isTab && item2.isTab) {
				var tab1:SSPTab = item1 as SSPTab;
				var tab2:SSPTab = item2 as SSPTab;
				var tmpSortOrder:uint = tab1.tabSortOrder;
				tab1.tabSortOrder = tab2.tabSortOrder;
				tab2.tabSortOrder = tmpSortOrder;
			}
		}
	}
}