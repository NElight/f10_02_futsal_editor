package src.tabbar
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import src.minutes.MinutesGlobals;
	import src.minutes.MinutesManager;
	import src.team.TeamGlobals;
	
	import src3d.SSPCursors;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.models.soccer.pitches.PitchViewLibrary;
	import src3d.models.soccer.pitches.PitchViewSettings;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	public class SSPTabBarDualContainer extends MovieClip
	{
		// Note: Tags used from XML: _screenId, _screenSortOrder, _screenTitle, _screenChangedFlag.
		
		// Tabs.
		private var numAddTabs:uint = 2;
		public var tabsMax:uint = 10+numAddTabs; // Number of tabs that can be created (0 = no limit).
		public var tabsMin:uint = 1; // Number of minimum permanent tabs (cannot be deleted).
		public var tabsMaxAbsolute:uint = 10+numAddTabs;
		public var ignoreTabsMax:Boolean = true; // Allow any amount of tabs < tabsMaxAbsolute to be created at start.
		public var tabWidth:Number = 106;
		public var tabHalfWidth:Number = tabWidth / 2;
		public var tabSpace:Number = 5; // Tabs space (added in mc already, but needed for mask).
		private var _selectedTab:SSPTab;
		private var tabLastXPos:Number;
		private var lastMouseX:Number;
		
		// Tab Bar.
		private var tB:SSPTabBarDual;
//		private var btnMcAddTabSep:SSPTabAdd; // First Add Tab with Separator.
//		private var btnMcAddTab:SSPTabAdd; // Second Add Tab.
		private var sepIdx:int; // Separator index in _aTabs, same than btnMcAddTabSep index.
		public var mainTabBarXPos:Number = 0; // Used for mouse scrolling when dragging.
		public var tabBarInitialWidth:Number = 0; // Used to positionate new tabs.
		public var tabBarInitialHeight:Number = 0; // Used to positionate new tabs.
		public var tabCloneLastOnAdd:Boolean = true;
		
		// General Settings.
		private var _aTabs:Vector.<SSPTabBase> = new Vector.<SSPTabBase>();
		private var _aAddTabs:Vector.<SSPTabBase> = new Vector.<SSPTabBase>();
		private var tabsXML:XML;
		
		private var useTweens:Boolean = true;
		private var tweenSpeed:Number = .2;
		
		private var scrollXSpeedMax:Number = 5; // Max scroll speed.
		private var scrollXMouseRange:Number = 20; // Range where the mouse speed will be checked.
		public var scrollLimitL:Number = 0; // Left limit for tab drag and drop.
		public var scrollLimitR:Number = 0; // Right limit for tab drag and drop.
		
		private var isDragging:Boolean;
		private var initialTabGroup:int;
		private var tabGroupChanged:Boolean;
		private var allowTabGroupChange:Boolean;
		private var newTabGroup:int;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sC:SSPCursors = SSPCursors.getInstance();
		private var tU:TabUtils = TabUtils.getInstance();
		
		public function SSPTabBarDualContainer(tB:SSPTabBarDual)
		{
			super();
			this.tB = tB;
			init();
		}
		
		private function init():void {
			var t:SSPTabBase;
			t = new SSPTabAdd(0, true);
			t.y = tB.height;
			this.addChild(t);
			_aTabs.push(t);
			_aAddTabs.push(t);
			
			// If Match, add second group's tab.
			if (sG.sessionTypeIsMatch) {
				t = new SSPTabAdd(1, false);
				t.y = tB.height;
				this.addChild(t);
				_aTabs.push(t);
				_aAddTabs.push(t);
			}
			
			updateTabsPos();
			
			allowTabGroupChange = (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH)? false : true;
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
			
			updateTabsPos();
		}
		
		public function createNewTab(newTabXML:XML):XML {
			if (tabsLimitReached) return null; // Check Limit.
			selectTab(createNewTabFromXML(newTabXML), true);
			updateAddTab();
			return newTabXML;
		}
		
		private function createNewTabFromXML(tXML:XML):SSPTab {
			var sspTab:SSPTab = new SSPTab(0, tabBarInitialHeight, tXML, _aTabs.length-1);
			sspTab.x = (_aTabs.length == 0) ? 0 : this.width;
			setTabListeners(sspTab, true);
			_aTabs.push(sspTab);
			this.addChild(sspTab);
			notifyTabContainerChange();
			return sspTab;
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
			var strMsg:String;
			if (!tab || _aTabs.length <= tabsMin) return;
			// Display confirmation if minutes attached and useMinutes != "Off".
			if (MinutesGlobals.getInstance().useMinutes &&
				MinutesManager.getInstance().screenHasMinutes(tab.tabScreenId)) {
				strMsg = sG.interfaceLanguageDataXML.messages._minutesLostIfDeleteWarning.text();
				main.msgBox.displayMsgBox(strMsg, deleteScreenFromTab, tab);
			} else {
				strMsg = sG.interfaceLanguageDataXML.messages._interfaceAreYouSure.text();
				main.msgBox.displayMsgBox(strMsg, deleteScreenFromTab, tab); // Ask for user confirmation.
			}
		}
		
		private function deleteScreenFromTab(tab:SSPTab):void {
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
			
			return null;
		}
		
		private function selectTab(sTab:SSPTabBase, notifySelect:Boolean):void {
			if (!sTab) return;
			// Unselect all tabs.
			for each (var t:SSPTabBase in _aTabs) {
				t.tabSelected = false;
				t.tabCloseVisible = false;
			}
			
			if (sTab.isTab) {
				// Bring tab to front.
				this.setChildIndex(sTab, this.numChildren-1);
				// Select tab.
				sTab.tabSelected = true;
				sTab.tabCloseVisible = (_aTabs.length > tabsMin + numAddTabs)? true : false;
				_selectedTab = sTab as SSPTab;
				
				if (notifySelect) notifySelectTab();
			}
		}
		
		private function notifySelectTab():void {
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT,_selectedTab.tabScreenId));
		}
		
		public function selectTabFromScreenId(sId:uint):void {
			selectTab(getTabFromScreenId(sId), true);
		}
		
		private function getTabFromScreenId(sId:uint):SSPTab {
			var tab:SSPTab;
			for each(var tabBase:SSPTabBase in _aTabs) {
				tab = tabBase as SSPTab;
				if (tab && tab.tabScreenId == sId) return tab;
			}
			return null;
		}
		
		private function notifyTabContainerChange():void {
			updateTabsPos();
			updateTabsStatus();
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_TABS_CHANGE));
		}
		
		private function onSessionScreenTitleChange(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		
		public function tabUpdateGroup(sId:uint):void {
			var t:SSPTab = getTabFromScreenId(sId);
			if (!t) return;
			// Change tab group.
			var prevGroup:uint = t.tabGroup;
			t.tabGroup = (t.tabScreenXML._screenFormat.text() == TeamGlobals.SCREEN_FORMATION_S1)? 1 : 0;
			// Change tab sort order if group has changed.
			if (prevGroup != t.tabGroup) {
				var tSO:int = getTabMaxSortOrderFromGroup(t.tabGroup)+1;
				if (tSO > -1) {
					t.tabSortOrder = tSO;
					reorderTabsArray();
				}
			} else {
				notifyTabContainerChange();
			}
		}
		
		private function getTabMaxSortOrderFromGroup(g:uint):int {
			if (!_aTabs || _aTabs.length == 0) return -1;
			var sspTab:SSPTab;
			var maxTabSO:uint;
			for each(var tBase:SSPTabBase in _aTabs) {
				sspTab = tBase as SSPTab;
				if (sspTab && sspTab.tabGroup == g) {
					if (sspTab.tabSortOrder > maxTabSO) maxTabSO = sspTab.tabSortOrder;
				}
			}
			return maxTabSO;
		}
		
		private function getTabMaxSortOrder():int {
			if (!_aTabs || _aTabs.length == 0) return -1;
			var t:SSPTab = _aTabs[0] as SSPTab;
			if (!t) return -1;
			var maxTabSO:uint = t.tabSortOrder;
			for each(var tBase:SSPTabBase in _aTabs) {
				if (tBase.isTab) {
					t = tBase as SSPTab;
					if (t.tabSortOrder > maxTabSO) maxTabSO = t.tabSortOrder;
				}
			}
			return maxTabSO;
		}
		
		private function reorderTabsArray():void {
			_aTabs.sort(reorderTabsCompare);
			notifyTabContainerChange();
		}
		private function reorderTabsCompare(t1:SSPTabBase, t2:SSPTabBase):Number {
			var tab1:SSPTab = t1 as SSPTab;
			var tab2:SSPTab = t2 as SSPTab;
			var sortNumber:int;
			if (!tab1 || !tab2) return 0; // No sorting needed.
			sortNumber = (tab1.tabSortOrder > tab2.tabSortOrder)? 1 : -1;
			return sortNumber;
		}
		
/*		public function updateTabLabels():void {
			var intScreenCount:int = 1;
			var intPeriodCount:int = 1;
			var intSetPieceCount:int = 1;
			var tXML:XML;
			for (var i:uint = 0;i<_aTabs.length;i++) {
				tXML = _aTabs[i].
				
			}
			if (tXML._screenTitle == ""
				|| tXML._screenTitle == strTabDefaultLabelScreen
				|| tXML._screenTitle == strTabDefaultLabelPeriod
				|| tXML._screenTitle == strTabDefaultLabelSetPiece
			) {
				if (tXML._screenType.text() == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
					newLabel = strTabDefaultLabelSetPiece.replace(strTabDefaultWildcard, _aTabs.length - 1);
				} else if (tXML._screenType.text() == SessionGlobals.SCREEN_TYPE_PERIOD) {
					newLabel = strTabDefaultLabelPeriod.replace(strTabDefaultWildcard, _aTabs.length - 1);
				} else {
					newLabel = strTabDefaultLabelScreen.replace(strTabDefaultWildcard, _aTabs.length - 1);
				}
			} else {
				newLabel = tXML._screenTitle.text();
			}
		}*/
		
		// ------------------------- TAB DRAG AND DROP ------------------------- //
		private function tabStartDrag():void {
			if (isDragging) return;
			isDragging = true;
			
			// Remove Event Listener.
			//e.target.removeEventListener(MouseEvent.MOUSE_DOWN, onSelectTabMouseDownHandler);
			//stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler);
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame, false, 0, true);
			
			initialTabGroup = _selectedTab.tabGroup;
			hideAddTabsFromContainer();
			tabLastXPos = _selectedTab.x;
			lastMouseX = stage.mouseX;
			
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
		
		private function onStageEnterFrame(e:Event):void {
			dragContainerWithMouse() // Update container pos.
		}
		
		private function dragContainerWithMouse():void {
			var currentXSpeed:Number;
			var speedRatio:Number = 5;
			var mouseDistance:Number;
			
			// Get mouse distance.
			mouseDistance = mainTabBarXPos - stage.mouseX; // if <0 mouse is to the right else to the left
			
			// Scroll right.
			//if (stage.mouseX < mainTabBarXPos + (_selectedTab.width/2)) {
			if (stage.mouseX < mainTabBarXPos) {
				//mouseDistance = (mouseDistance > scrollXMouseRange) ? scrollXMouseRange : mouseDistance;
				//mouseDistance = (mouseDistance > scrollXMouseRange) ? scrollXMouseRange : mouseDistance;
				if (this.x < scrollLimitL) {
					if (this.x < scrollLimitL+speedRatio) {
						this.x += speedRatio;
					} else {
						this.x = scrollLimitL;
					}
				}
//				_selectedTab.stopDrag();
//				_selectedTab.x = Math.abs(this.x) + scrollLimitL;
//				isDragging = false;
/*				updateTabsPositionOnDrag();
				return;*/
			}
			
			
			//if (stage.mouseX > mainTabBarXPos + scrollLimitR - (_selectedTab.width/2)) {
			else if (stage.mouseX > mainTabBarXPos + scrollLimitR) {
				// Scroll left.
				if (this.x + this.width > scrollLimitR) {
					if (this.x + this.width > scrollLimitR-speedRatio) {
						this.x -= speedRatio;
					} else {
						this.x = scrollLimitR;
					}
				}
//				_selectedTab.stopDrag();
//				_selectedTab.x = Math.abs(this.x)+scrollLimitR-_selectedTab.width;
//				isDragging = false;
/*				updateTabsPositionOnDrag();
				return;*/
			}
			
			// If mouse inside bounds, start dragging again.
/*			if (stage.mouseX > mainTabBarXPos &&
				stage.mouseX < mainTabBarXPos + scrollLimitR) {
				tabStartDrag();
				isDragging = true;
			}*/
			
			updateTabsPositionOnDrag();
			
/*			if (!isDragging) {
				tabStartDrag();
				isDragging = true;
			}*/
		}
		
		private function tabStopDrag():void {
			stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler);
			_selectedTab.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTabMouseUpHandler);
			sC.reset();
			_selectedTab.stopDrag();
			isDragging = false;
			if (tabGroupChanged && allowTabGroupChange) _selectedTab.tabGroup = newTabGroup; // Update tab group.
			updateTabsStatus();
			showAddTabsInContainer();
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_UPDATE_TEAM_SETTINGS, {tabScreenId:_selectedTab.tabScreenId, tabGroupChanged:tabGroupChanged}));
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_REORDER));
			//notifyTabContainerChange();
		}
		
		private function hideAddTabsFromContainer():void {
			_aAddTabs[_aAddTabs.length-1].visible = false; // Hide last tab.
		}
		
		private function showAddTabsInContainer():void {
			_aAddTabs[_aAddTabs.length-1].visible = true; // Show last tab.
			updateTabsPos();
		}
		
		private function swapItems(array:Vector.<SSPTabBase>, item1:SSPTabBase, item2:SSPTabBase) {
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
		
		private function updateTabsPositionOnDrag():void {
			var i:uint;
			var tabCenterXPos:Number;
			var newTabXPos:Number;
			var multiplier:uint;
			var update:Boolean;
			
			if (lastMouseX > stage.mouseX) {
				// Moving Left.
				for (i = 0;i<_aTabs.length;i++) {
					tabCenterXPos = _aTabs[i].x + (_aTabs[i].width / 2);
					if (_selectedTab != _aTabs[i]
						&& _selectedTab.x < tabCenterXPos
						&& _aTabs[i].x < _selectedTab.x + (_selectedTab.width/2)
						//&& _selectedTab.x > _aTabs[i].x
					) {
						if (_selectedTab.tabGroup != _aTabs[i].tabGroup && !allowTabGroupChange) {
							sC.setNo();
							tabGroupChanged = false;
						} else {
							if (!_aTabs[i].isTab && !allowTabGroupChange) {
								sC.setNo();
								tabGroupChanged = false;
							} else if (_selectedTab.tabScreenType == SessionGlobals.SCREEN_TYPE_PERIOD && MinutesManager.getInstance().hasMinutes) {
								sC.setNo();
								tabGroupChanged = false;
							} else {
								sC.reset();
								swapItems(_aTabs, _selectedTab, _aTabs[i]); // Swap tabs in array.
								newTabGroup = (i > _aTabs.indexOf(_aAddTabs[0]))? 1 : 0; // Update tab group.
								tabGroupChanged = (newTabGroup != initialTabGroup)? true : false;
							}
						}
						break;
					} else if (_aTabs[i].x + _aTabs[i].width > _selectedTab.x + (_selectedTab.width/2) &&
						_selectedTab.tabGroup > _aTabs[i].tabGroup) {
							sC.setNo();
							tabGroupChanged = false;
					} else {
						sC.reset();
					}
				}
			} else if (lastMouseX < stage.mouseX) {
				// Moving Right.
				for (i = 0;i<_aTabs.length;i++) {
					tabCenterXPos = _aTabs[i].x + (_aTabs[i].width / 2);
					if (_selectedTab != _aTabs[i]
						&& _selectedTab.x + _selectedTab.width > tabCenterXPos
						&& _aTabs[i].x + _aTabs[i].width > _selectedTab.x + (_selectedTab.width/2)
						//&& _selectedTab.x + _selectedTab.width < _aTabs[i].x + _aTabs[i].width
					) {
						if (_selectedTab.tabGroup != _aTabs[i].tabGroup && !allowTabGroupChange) {
							sC.setNo();
							tabGroupChanged = false;
						} else {
							if (!_aTabs[i].isTab && !allowTabGroupChange) {
								sC.setNo();
								tabGroupChanged = false;
							} else if (_selectedTab.tabScreenType == SessionGlobals.SCREEN_TYPE_PERIOD && MinutesManager.getInstance().hasMinutes) {
								sC.setNo();
								tabGroupChanged = false;
							} else {
								sC.reset();
								swapItems(_aTabs, _selectedTab, _aTabs[i]); // Swap tabs in array.
								newTabGroup = (i > _aTabs.indexOf(_aAddTabs[0]))? 1 : 0; // Update tab group.
								tabGroupChanged = (newTabGroup != initialTabGroup)? true : false;
							}
						}
						break;
					} else if (_aTabs[i].x < _selectedTab.x + (_selectedTab.width/2) &&
						_selectedTab.tabGroup < _aTabs[i].tabGroup) {
							sC.setNo();
							tabGroupChanged = false;
					} else {
						sC.reset();
					}
				}
			}
			
			repositionTabs();
			
			lastMouseX = stage.mouseX;
		}
		
		private function repositionTabs():void {
			var lastXPos:Number = 0;
			var lastWidth:Number = 0;
			for (var i:uint = 0;i<_aTabs.length;i++) {
				if (_aTabs[i] != _selectedTab) {
					_aTabs[i].x = lastXPos + lastWidth;
				}
				lastXPos = lastXPos + lastWidth;
				lastWidth = _aTabs[i].width;
			}
		}
		
		private function updateTabsPos():void {
			var newATabs:Vector.<SSPTabBase> = new Vector.<SSPTabBase>();
			var sspTab:SSPTab;
			var tCounter:uint = 1;
			var sortOrder:uint = 0;
			// For each tab group.
			for (var h:uint = 0;h<_aAddTabs.length;h++) {
				for (var i:uint = 0; i<_aTabs.length;i++) {
					sspTab = _aTabs[i] as SSPTab;
					// Update tab label if needed.
					if (sspTab && sspTab.tabGroup == h) {
						// Add tabs to matching group.
						newATabs.push(sspTab);
/*						if (regExpTabLabelPatternPeriod.test(sspTab.tabLabel)
							|| regExpTabLabelPatternSetPiece.test(sspTab.tabLabel)
						) {
							if (sspTab.tabGroup == 0) {
								sspTab.tabLabel = strTabDefaultLabelPeriod.replace(SSPSettings.DEFAULT_TAB_LABEL_WILDCARD, tCounter);
							} else {
								sspTab.tabLabel = strTabDefaultLabelSetPiece.replace(SSPSettings.DEFAULT_TAB_LABEL_WILDCARD, tCounter);
							}
						}*/
						tCounter++;
					}
				}
				newATabs.push(_aAddTabs[h]); // Include Add Tab for corresponding group.
				tCounter = 1;
			}
			_aTabs = newATabs;
			for (i = 0; i<_aTabs.length;i++) {
				_aTabs[i].x = (i == 0)? 0 : _aTabs[i-1].x + _aTabs[i-1].width; // Move to the right of the previous tab.
				if (_aTabs[i].isTab) {
					SSPTab(_aTabs[i]).tabSortOrder = sortOrder;
					sortOrder++;
				}
			}
		}
		
		public function updateTabsStatus():void {
			var sspTab:SSPTab;
			var tCounter0:uint = 1;
			var tCounter1:uint = 1;
			var i:uint;
			for (i = 0; i<_aTabs.length;i++) {
//				_aTabs[i].x = (i == 0)? 0 : _aTabs[i-1].x + _aTabs[i-1].width; // Move to the right of the previous tab.
				// Update default labels number.
				if (_aTabs[i].isTab) {
					sspTab = _aTabs[i] as SSPTab;
					
					// Increase counter.
					if (sspTab.tabScreenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
						sspTab.tabNumber = tCounter1;
						tCounter1++;
					} else {
						sspTab.tabNumber = tCounter0;
						tCounter0++;
					}
					
					// Toggle close tab button.
					if (_aTabs.length == 1 + tabsMax) {
						sspTab.tabCloseVisible = false;
						sspTab.tabCloseVisible = false;
					} else {
						//sspTab.tabCloseVisible = true;
						//sspTab.tabCloseVisible = true;
					}
				}
			}
			// Expand Set-Piece button.
			var firstTab:SSPTab;
			var needUpdate:Boolean;
			if (sG.sessionTypeIsMatch) {
				if (!hasGroupTabs(0)) {
					_aAddTabs[0].buttonBDisplayed = true;
					needUpdate = true;
				} else if (!hasGroupTabs(1)) {
					_aAddTabs[1].buttonBDisplayed = true;
					needUpdate = true;
				} else {
					for (i = 0;i<_aAddTabs.length;i++) {
						if (_aAddTabs[i].buttonBDisplayed) needUpdate = true;
						_aAddTabs[i].buttonBDisplayed = false;
					}
				}
				if (needUpdate) updateTabsPos();
			}
		}
		
		private function hasGroupTabs(tGroup:uint):Boolean {
			for (var i:uint = 0;i<_aTabs.length;i++) {
				if (_aTabs[i].tabGroup == tGroup && _aTabs[i].isTab) return true;
			}
			return false;
		}
		
		private function updateTabLabel(tab:SSPTab, newNumber:uint):void {
			
		}
		
		/*private function sortTabsByXPos(): void
		{
			var n:int = _aTabs.length;
			var inc:int = int(n/2);
			while (inc)
			{
				for (var i:int = inc; i < n; i++)
				{
					var temp:SSPTabBase= _aTabs[i], j:int = i;
					while (j >= inc && _aTabs[int(j - inc)].x > temp.x)
					{
						_aTabs[j] = _aTabs[int(j - inc)];
						j = int(j - inc);
					}
					_aTabs[j] = temp
				}
				inc = int(inc / 2.2);
			}
		}*/
		// ----------------------- END TAB DRAG AND DROP ----------------------- //
		
		
		
		// ------------------------- ADD TAB BUTTONS ------------------------- //
		private function updateAddTab():void {
			// If no more tabs available, disable btnMcAddTab.
			if (tabsMax != 0 && tabsNumber >= tabsMax) {
				toggleAddTabs(false);
				addTabsListenerEnabled(false);
			} else {
				toggleAddTabs(true);
				addTabsListenerEnabled(true);
			}
		}
		
		private function onAddTabClickHandler(e:MouseEvent):void {
			addTabsListenerEnabled(false);
			Logger.getInstance().addText("(I) - User clicked 'Add Screen' tab button.", false);
			toggleAddTabs(false);
			sendAddTabsToBack();
			
			// Check Limit.
			if (this.tabsLimitReached) {
				Logger.getInstance().addText("(A) - Can't add more tabs (max: "+tabsMax+")", false);
				return;
			}
			
			var isBlankScreen:Boolean;
			var addTab:SSPTabAdd = e.currentTarget as SSPTabAdd;
			var strScreenType:String;
			var screenId:int;
			if (addTab.tabGroup == 0) {
				// Create a 'Period' or 'Screen' tab.
				strScreenType = (sG.sessionTypeIsMatch)? SessionGlobals.SCREEN_TYPE_PERIOD : SessionGlobals.SCREEN_TYPE_SCREEN;
			} else {
				// Create a 'Set-Piece' tab.
				strScreenType = SessionGlobals.SCREEN_TYPE_SET_PIECE;
			}
			
			if (tabCloneLastOnAdd) {
				// Clone Last Screen of its type.
				logger.addText("Using last "+strScreenType+" screen settings.", false);
				screenId = SessionScreenUtils.getScreenIdFromMaxSortOrder(strScreenType);
			} else {
				// Clone First Screen of its type.
				logger.addText("Using first "+strScreenType+" screen settings.", false);
				screenId = SessionScreenUtils.getScreenIdFromMinSortOrder(strScreenType);
			}
				
			if (screenId == -1) {
				// If no screens on that group, use the minimum Id and log the error.
				logger.addText("(A) - No previous "+strScreenType+" screen found. Using first screen settings available.", false);
				screenId = SessionScreenUtils.getMinScreenId();
				isBlankScreen = true;
			}
			if (screenId == -1) {
				logger.addText("Can't create new screen. No screens in the application to get as reference.", true);
				return;
			}
			
			// Note that tabs can change screenSortOrder, but screenId never changes, otherwise the objects would be messed up.
			var includeObjects:Boolean = false;
			var resetComments:Boolean = true;
			var resetScreenSettings:Boolean = true;
			var newTabXML:XML = SessionScreenUtils.cloneScreen(screenId, TabUtils.getInstance().defaultLabelScreen, includeObjects, resetComments, resetScreenSettings)[0];
			
			if (strScreenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
				newTabXML._screenType = SessionGlobals.SCREEN_TYPE_PERIOD;
				newTabXML._screenTitle = TabUtils.getInstance().defaultLabelPeriod;
			} else {
				newTabXML._screenType = SessionGlobals.SCREEN_TYPE_SET_PIECE;
				newTabXML._screenTitle = TabUtils.getInstance().defaultLabelSetPiece;
			}
			
			applyScreenDefaults(newTabXML[0], isBlankScreen);
			
			var tempNewSId:uint = uint( newTabXML._screenId.text() );
			tB.sessionScreenAddStart(tempNewSId);
		}
		
		private function addTabsListenerEnabled(value:Boolean):void {
			for (var i:uint = 0;i<_aAddTabs.length;i++) {
				if (value) {
					if (!_aAddTabs[i].hasEventListener(MouseEvent.CLICK)) {
						_aAddTabs[i].addEventListener(MouseEvent.CLICK, onAddTabClickHandler, false, 0, true);
					}
				} else {
					_aAddTabs[i].removeEventListener(MouseEvent.CLICK, onAddTabClickHandler);
				}
			}
		}
		
		private function toggleAddTabs(toggle:Boolean):void {
			for (var i:uint = 0;i<_aAddTabs.length;i++) {
				//_aAddTabs[i].buttonSelected = toggle;
				_aAddTabs[i].buttonEnabled = toggle;
			}
		}
		
		private function sendAddTabsToBack():void {
			for (var i:uint = 0;i<_aAddTabs.length;i++) {
				this.setChildIndex(_aAddTabs[i], i);
			}
		}
		// ---------------------- END OF ADD TAB BUTTONS --------------------- //
		
		
		
		private function applyScreenDefaults(selectedScreenXML:XML, isBlankScreen:Boolean):void {
			var pvSettings:PitchViewSettings;
			var strScreenType:String = selectedScreenXML._screenType.text();
			if (strScreenType == "") strScreenType = SessionGlobals.SCREEN_TYPE_SCREEN;
			// Apply Screen defaults (hardcoded).
			if (strScreenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
				selectedScreenXML._screenPlayerNameDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_S1_NAME_DISPLAY);
				selectedScreenXML._screenPlayerModelDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_S1_MODEL_DISPLAY);
				selectedScreenXML._screenPlayerPositionDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_S1_POSITION_DISPLAY);
			} else {
				selectedScreenXML._screenPlayerNameDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_P1_NAME_DISPLAY);
				selectedScreenXML._screenPlayerModelDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_P1_MODEL_DISPLAY);
				selectedScreenXML._screenPlayerPositionDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_P1_POSITION_DISPLAY);
			}
			
			// Apply Screen defaults (server).
			var dXML:XML = sG.sessionDataXML.session.screen_defaults.(_screenType == strScreenType)[0];
			if (dXML) {
				selectedScreenXML._screenPlayerNameFormat = dXML._screenPlayerNameFormat.text();
				selectedScreenXML._screenPlayerModelFormat = dXML._screenPlayerModelFormat.text();
			} else {
				// Use hardcoded values.
				logger.addText("No <screen_defaults> found in session data. Using internal default values. (_sessionType = "+sG.sessionType+").", true);
				selectedScreenXML._screenPlayerNameFormat = TeamGlobals.DEFAULTS_PLAYER_NAME_FORMAT;
				selectedScreenXML._screenPlayerModelFormat = TeamGlobals.DEFAULTS_PLAYER_MODEL_FORMAT;
			}
			
			// If no other screens of that type exist, apply camera default settings.
			if (isBlankScreen) {
				logger.addText("(I) - Applying default camera settings for new "+strScreenType+".", false);
				pvSettings = PitchViewLibrary.getInstance().aPV[3]; // Get Camera Settings for full pitch.
				selectedScreenXML._cameraFOV = "0";
				selectedScreenXML._cameraPanAngle = pvSettings.camPanAngle.toString();
				selectedScreenXML._cameraTarget = pvSettings.camTargetId.toString();
				selectedScreenXML._cameraTiltAngle = pvSettings.camTiltAngle.toString();
				selectedScreenXML._cameraZoom = pvSettings.camZoom.toString();
			}
		}
		
		/**
		 * Move container to XPos. 
		 */	
		public function moveToXPos(newXPos:Number, useTweener:Boolean, callUpdateControls:Boolean, fast:Boolean):void {
			moveXPos(this,newXPos,useTweener,callUpdateControls,fast);
		}
		
		/**
		 * Move object to XPos. 
		 */		
		private function moveXPos(targetObj:DisplayObject, newXPos:Number, useTweener:Boolean, callUpdateControls:Boolean, fast:Boolean):void {
			if (!useTweener) {
				targetObj.x = newXPos;
				if (callUpdateControls) updateAddTab();
			} else {
				var tOptions:Object = {};
				tOptions.x = newXPos;
				if (callUpdateControls) tOptions.onComplete = updateAddTab;
				TweenLite.to(targetObj, (fast)? tweenSpeed/2 : tweenSpeed, tOptions);
			}
		}
		
		public function cancelScreenCreation():void {
			toggleAddTabs(true);
		}
		
		internal function get tabsXMLList():XMLList {
			if (!tabsXML) {
				trace("No tabs XML ready");
				return new XMLList();
			}
			return tabsXML.session.children().(localName() == "screen");
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
		public function get aTabs():Vector.<SSPTabBase> {
			return _aTabs;
		}
		public function get tabsNumber():uint {
			return _aTabs.length - numAddTabs; // return Tabs - num of addTabs.
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