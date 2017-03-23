package src.tabbar
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import src.popup.MessageBox;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.Logger;
	import src3d.utils.SessionScreenUtils;
	
	
	public class SSPTabBarContainer extends MovieClip
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
		
		// Tab Bar.
		public var mainTabBarXPos:Number = 0; // Used for mouse scrolling when dragging.
		public var tabBarInitialWidth:Number = 0; // Used to positionate new tabs.
		public var tabBarInitialHeight:Number = 0; // Used to positionate new tabs.
		
		// General Settings.
		private var _aTabs:Vector.<SSPTab> = new Vector.<SSPTab>();
		private var tabsXML:XML;
		
		private var scrollXSpeedMax:Number = 5; // Max scroll speed.
		private var scrollXMouseRange:Number = 20; // Range where the mouse speed will be checked.
		public var scrollLimitL:Number = 0; // Left limit for tab drag and drop.
		public var scrollLimitR:Number = 0; // Right limit for tab drag and drop.
		
		private var isDragging:Boolean;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		public function SSPTabBarContainer()
		{
			super();
		}
		
		public function initTabsXML(tXML:XML):void {
			if (!tXML) return;
			if (tabsXML) {
				trace("Tabs already created. Use createNewTab() instead.");
				return;
			} else {
				tabsXML = tXML;
			}
			
			for (var i:uint = 0; i<this.tabsXMLList.length(); i++) {
				if (tabsLimitReached) break; // Check Limit.
				createNewTabFromXML(tabsXMLList[i]);
				//if (_aTabs[_aTabs.length].tabSortOrder == -1) _aTabs[_aTabs.length].tabSortOrder = i;
			}
			ignoreTabsMax = false; // Enable tabMax limit.
		}
		
		public function createNewTab(newTabXML:XML):XML {
			if (tabsLimitReached) return null; // Check Limit.
			createNewTabFromXML(newTabXML);
			selectTab(_aTabs[_aTabs.length-1], true);
			return newTabXML;
		}
		
		private function createNewTabFromXML(tXML:XML):void {
			var sspTab:SSPTab = new SSPTab(0, tabBarInitialHeight, tXML, _aTabs.length);
			/*if (isNaN(tabWidth)) {
				tabWidth = sspTab.width;
				tabHalfWidth = tabWidth / 2;
			}*/
			sspTab.x = (_aTabs.length == 0) ? 0 : this.width;
			setTabListeners(sspTab, true);
			_aTabs.push(sspTab);
			this.addChild(sspTab);
			notifyTabContainerChange();
		}
		
		private function setTabListeners(sspTab:SSPTab, lEnabled:Boolean):void {
			if (lEnabled) {
				sspTab.addEventListener(SSPEvent.TAB_MOUSE_DOWN, onTabMouseDownHandler, false, 0, true);
				sspTab.addEventListener(SSPEvent.TAB_CLOSE_CLICK, onTabCloseClickHanlder, false, 0, true);
				sspTab.addEventListener(SSPEvent.SESSION_SCREEN_TITLE_CHANGE, onSessionScreenTitleChange, false, 0, true);
			} else {
				sspTab.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
				sspTab.removeEventListener(SSPEvent.TAB_MOUSE_DOWN, onTabMouseDownHandler);
				sspTab.removeEventListener(SSPEvent.TAB_CLOSE_CLICK, onTabCloseClickHanlder);
				sspTab.removeEventListener(SSPEvent.SESSION_SCREEN_TITLE_CHANGE, onSessionScreenTitleChange);
			}
		}
		
		private function onTabMouseDownHandler(e:SSPEvent):void {
			selectTab( e.target as SSPTab, true);
			if (!_selectedTab) return;
			_selectedTab.addEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onTabMouseMoveHandler, false, 0, true);
		}
		
		private function onTabMouseUpHandler(e:MouseEvent):void {
			_selectedTab.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTabMouseMoveHandler);
			tabStopDrag();
		}
		
		private function onTabMouseMoveHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTabMouseMoveHandler);
			tabStartDrag();
		}
		
		private function onTabCloseClickHanlder(e:SSPEvent):void {
			var tab:SSPTab = e.eventData as SSPTab;
			var strMsg:String = sG.interfaceLanguageDataXML.messages._interfaceAreYouSure.text();
			main.msgBox.displayMsgBox(strMsg, deleteScreenFromTab, tab); // Ask for user confirmation.
		}
		
		private function deleteScreenFromTab(tab:SSPTab):void {
			if (!tab || _aTabs.length <= tabsMin) return;
			logger.addText("Deleting Screen ("+tab.tabScreenId+", "+tab.tabSortOrder+")...", false);
			
			var newTabToSelect:SSPTabBase = getNewTabToSelect(tab); // Select right tab if any, else left tab.
			selectTab(newTabToSelect, false); // Select without notify Tab Selected.
			
			var tabScreenId:uint = tab.tabScreenId; // Get the id before delete the tab.
			closeTab(tab);
			SessionScreenUtils.deleteScreen(tabScreenId); // Remove screen from XML.
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_REMOVE,tabScreenId)); // Dispatch after remove to update settings properly.
			
			notifySelectTab(); // Notify Tab Selected.
		}
		
		private function closeTab(t:SSPTab):void {
			if (!t || _aTabs.length <= tabsMin) return;
			this.setTabListeners(t, false); // Remove tab listeners.
			
			var tIdx:int = _aTabs.indexOf(t);
			if (tIdx > -1) _aTabs.splice(tIdx,1); // Remove from Tabs array.
			if (t.tabSelected) {
				t.tabSelected = false;
				_selectedTab = null;
			}
			t.dispose();
			t = null;
			//var newTIdx:uint = (tIdx < _aTabs.length)? tIdx : tIdx-1; // Select next tab on the right if any.
			//selectTab(_aTabs[newTIdx], false);
			notifyTabContainerChange();
		}
		
		private function getNewTabToSelect(oldTab:SSPTabBase):SSPTabBase {
			var tmpSTabs:Vector.<SSPTabBase> = new Vector.<SSPTabBase>(); // Array for Screen Tabs only.
			var tmpGroupSTabs:Vector.<SSPTabBase> = new Vector.<SSPTabBase>(); // Array for Screen Tabs of specified Tab Group.
			var i:uint;
			var tIdx:int;
			
			// Get screen tabs. Discard control tabs.
			for (i=0;i<_aTabs.length;i++) {
				if (_aTabs[i].isTab) tmpSTabs.push(_aTabs[i]);
			}
			
			// Get tabs of specified group.
			for (i=0;i<tmpSTabs.length;i++) {
				if (tmpSTabs[i].tabGroup == oldTab.tabGroup) tmpGroupSTabs.push(tmpSTabs[i]);
			}
			
			// If there are tabs of specified group.
			tIdx = tmpGroupSTabs.indexOf(oldTab);
			if (tmpGroupSTabs.length > 0) {
				if (tIdx+1 < tmpGroupSTabs.length) {
					// If there is a tab to the right, use it.
					return tmpGroupSTabs[tIdx+1];
				} else if (tIdx-1 >= 0) {
					// If there is a tab to the left, use it.
					return tmpGroupSTabs[tIdx-1];
				}
			}
			
			// If no tabs on specified group, check whoe list.
			tIdx = tmpSTabs.indexOf(oldTab);
			if (tmpSTabs.length > 1) {
				if (tIdx+1 < tmpSTabs.length) {
					// If there is a tab to the right, use it.
					return tmpSTabs[tIdx+1];
				} else if (tIdx-1 >= 0) {
					// If there is a tab to the left, use it.
					return tmpSTabs[tIdx-1];
				}
			} else {
				if (tmpSTabs.length > 0) return tmpSTabs[0];
			}
			
			logger.addError("Can't find another tab to select");
			return null;
		}
		
		private function selectTab(sTab:SSPTabBase, notifySelect:Boolean):void {
			if (!sTab) return;
			// Unselect all tabs.
			for each (var t:SSPTab in _aTabs) {
				t.tabSelected = false;
				t.tabCloseVisible = false;
			}
			// Bring tab to front.
			this.setChildIndex(sTab, this.numChildren-1);
			// Select tab.
			sTab.tabSelected = true;
			sTab.tabCloseVisible = (_aTabs.length > tabsMin)? true : false;
			_selectedTab = sTab as SSPTab;
			
			if (notifySelect) notifySelectTab();
		}
		
		private function notifySelectTab():void {
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT,_selectedTab.tabScreenId));
		}
		
		public function selectTabFromScreenId(sId:uint):void {
			selectTab(getTabFromScreenId(sId), true);
		}
		
		private function getTabFromScreenId(sId:uint):SSPTab {
			for each(var t:SSPTab in _aTabs) {
				if (t.tabScreenId == sId) return t;
			}
			return null;
		}
		
		private function notifyTabContainerChange():void {
			updateTabsStatus();
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_TABS_CHANGE));
		}
		
		private function updateTabsStatus():void {
			if (_aTabs.length == 0) return;
			for (var i:uint = 0; i<_aTabs.length;i++) {
				_aTabs[i].x = (i == 0)? 0 : _aTabs[i-1].x + _aTabs[i-1].width; // Move to the right of the previous tab.
				// Update default labels in case one has been deleted or moved.
				_aTabs[i].tabNumber = i + 1;

			}
			// Toggle close tab button.
			if (_aTabs.length == 1) {
				_aTabs[0].tabCloseVisible = false;
				_aTabs[0].tabCloseVisible = false;
			} else {
				//_aTabs[0].tabCloseVisible = true;
				//_aTabs[0].tabCloseVisible = true;
			}
		}
		
		private function onSessionScreenTitleChange(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		
		// ------------------------- TAB DRAG AND DROP -------------------------
		private function tabStartDrag():void {
			if (isDragging) return;
			isDragging = true;
			
			// Remove Event Listeners.
			//e.target.removeEventListener(MouseEvent.MOUSE_DOWN, onSelectTabMouseDownHandler);
			//stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler);
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame, false, 0, true);
			
			var leftBound:Number;
			var rightBound:Number;
			var visibleWidth:Number = scrollLimitR - _selectedTab.width;
			if (this.x < 0) {
				leftBound = this.x * -1;
				rightBound = visibleWidth;
			} else {
				leftBound = this.x;
				rightBound = visibleWidth;
			}
			var dragWidth:Number = tabWidth * (_aTabs.length-1);
			if (dragWidth < rightBound) rightBound = dragWidth;
			var dragBounds:Rectangle = new Rectangle(leftBound,_selectedTab.y,rightBound, 0); // Rectangle creation: from x,y make a rectangle of width,height.
			_selectedTab.startDrag(false, dragBounds);
		}
		
		private function onStageMouseMoveHandler(e:MouseEvent):void {
/*			e.updateAfterEvent();
			updateTabsPosition();*/
		}
		
		private function onStageEnterFrame(e:Event):void {
			dragContainerWithMouse() // Update container pos.
		}
		
		private function updateTabsPosition():void {
			var i:uint;
			var sTabXPos:Number;
			var tabCPos:Number;
			var newTabXPos:Number;
			var multiplier:uint;
			// Check left side.
			sTabXPos = _selectedTab.x;
			for (i = 0;i<_aTabs.length;i++) {
				tabCPos = _aTabs[i].x + tabHalfWidth;
				newTabXPos = tabWidth * (i+1);
				if (sTabXPos < tabCPos
					&& _selectedTab.tabSortOrder != _aTabs[i].tabSortOrder
					&& _selectedTab.x > _aTabs[i].x)
				{
					_aTabs[i].x = newTabXPos;
					// Swap tabs in array.
					swapItems(_aTabs, _selectedTab, _aTabs[i]);
					this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_REORDER));
				}
			}
			
			// Check right side.
			sTabXPos = _selectedTab.x + tabWidth;
			for (i = 0;i<_aTabs.length;i++) {
				tabCPos = _aTabs[i].x + tabHalfWidth;
				multiplier = (i-1 < 0) ? 0 : i-1;
				newTabXPos = tabWidth * multiplier;
				if (sTabXPos > tabCPos 
					&& _selectedTab.tabSortOrder != _aTabs[i].tabSortOrder
					&& _selectedTab.x + tabWidth < _aTabs[i].x + tabWidth)
				{
					_aTabs[i].x = newTabXPos;
					// Swap tabs in array.
					swapItems(_aTabs, _selectedTab, _aTabs[i]);
					this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_REORDER));
				}
			}
			
			// Reposition tabs.
			for (i = 0;i<_aTabs.length;i++) {
				if (_selectedTab.tabSortOrder != _aTabs[i].tabSortOrder) {
					_aTabs[i].x = (i == 0)? 0 : tabWidth*i;
				}
			}
		}
		
		private function dragContainerWithMouse():void {
			var currentXSpeed:Number;
			var speedRatio:Number = 5;
			var mouseDistance:Number;
			
			// Get mouse distance.
			mouseDistance = mainTabBarXPos - stage.mouseX; // if <0 mouse is to the right else to the left
			
			// Scroll right.
			if (stage.mouseX < mainTabBarXPos + (_selectedTab.width/2)) {
				//mouseDistance = (mouseDistance > scrollXMouseRange) ? scrollXMouseRange : mouseDistance;
				//mouseDistance = (mouseDistance > scrollXMouseRange) ? scrollXMouseRange : mouseDistance;
				if (this.x < scrollLimitL) {
					if (this.x < scrollLimitL+speedRatio) {
						this.x += speedRatio;
					} else {
						this.x = scrollLimitL;
					}
				}
				_selectedTab.stopDrag();
				_selectedTab.x = Math.abs(this.x) + scrollLimitL;
				isDragging = false;
				updateTabsPosition();
				return;
			}
			
			// Scroll left.
			if (stage.mouseX > mainTabBarXPos + scrollLimitR - (_selectedTab.width/2)) {
				// Scroll left.
				if (this.x + this.width > scrollLimitR) {
					if (this.x + this.width > scrollLimitR-speedRatio) {
						this.x -= speedRatio;
					} else {
						this.x = scrollLimitR;
					}
				}
				_selectedTab.stopDrag();
				_selectedTab.x = Math.abs(this.x)+scrollLimitR-_selectedTab.width;
				isDragging = false;
				updateTabsPosition();
				return;
			}
			
			// If mouse inside bounds, start dragging again.
			updateTabsPosition();
			if (!isDragging) {
				tabStartDrag();
				isDragging = true;
			}
		}
		
		private function tabStopDrag():void {
			stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler);
			_selectedTab.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
			_selectedTab.stopDrag();
			isDragging = false;
			for (var i:uint = 0;i<_aTabs.length;i++) {
				_aTabs[i].x = (i == 0)? 0 : tabWidth*i;
			}
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_UPDATE_TEAM_SETTINGS, {tabScreenId:_selectedTab.tabScreenId, tabGroupChanged:false}));
			notifyTabContainerChange();
		}
		
		/*private function checkMouseOutOnDrag():Boolean {
		// Stop dragging if mouse is out of stage.
		var isMouseOut:Boolean;
		var mX:Number = stage.mouseX;
		var mY:Number = stage.mouseY;
		if (mX < 0 ||
		mX > stage.stageWidth ||
		mY < 0 ||
		mY > stage.stageHeight)
		{
		isMouseOut = true;
		}
		return isMouseOut;
		}*/
		
		/*private function swapTabs(srcTab:SSPTab, targetTab:SSPTab):void {
			// Swap tabs in array.
			swapItems(_aTabs, srcTab, targetTab);
			
			// Reset tabs sort order.
			for (var i:uint; i<_aTabs.length; i++) {
				_aTabs[i].tabSortOrder = i;
			}
		}*/
		
		private function swapItems(array:Vector.<SSPTab>, item1:SSPTabBase, item2:SSPTabBase) {
			var item1pos:int = array.indexOf(item1);
			var item2pos:int = array.indexOf(item2);
			
			if ((item1pos != -1) && (item2pos != -1))
			{
				var tempItem:SSPTab = array[item2pos];
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
		
		// ----------------------- END TAB DRAG AND DROP -----------------------
		
		internal function get tabsXMLList():XMLList {
			if (!tabsXML) {
				trace("No tabs XML ready");
				return new XMLList();
			}
			return tabsXML.session[0].children().(localName() == "screen");
		}
		public function get tabsLimitReached():Boolean {
			if (_aTabs.length >= tabsMaxAbsolute) {
				logger.addText("(A) - Screens absolute max limit ("+tabsMaxAbsolute+") reached.", false);
				return true;
			}
			if (ignoreTabsMax) {
				if (_aTabs.length > tabsMax) {
					logger.addText("(A) - Screens loaded ("+_aTabs.length+") > '_maxScreens' ("+tabsMax+").", false);
				}
				return false;
			}
			// Check Limit.
			if (_aTabs.length >= tabsMax) {
				return true;
			} else {
				return false;
			}
		}
		public function get aTabs():Vector.<SSPTab> {
			return _aTabs;
		}
		public function get tabsNumber():uint {
			return _aTabs.length;
		}
		public function get tabSelected():SSPTab {
			return _selectedTab;
		}
		
		public function updateTabsTitle(sId:uint):void {
			for each(var t:SSPTab in _aTabs) {
				if (t.tabScreenId == sId) t.updateTabLabel();
			}
		}
		
	}
}