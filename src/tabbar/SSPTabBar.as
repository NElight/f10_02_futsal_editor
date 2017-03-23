package src.tabbar
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import src.buttons.SSPSimpleButton;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.ColorUtils;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.SessionScreenUtils;
	
	public class SSPTabBar extends SSPTabBarBase
	{
		private static const LEFT_SIDE:int = -1;
		private static const RIGHT_SIDE:int = 1;

		// Controls.
		private var tC:SSPTabBarContainer; // Tabs Container.
		private var tCMask:Shape; // Tabs Container Mask.
		private var btnScrollL:SimpleButton; // Scroll Left.
		private var btnScrollR:SimpleButton; // Scroll Right
		private var btnAddTab:SSPTabBase; // Add Tab.
		
		// Settings.
		private var tabsMin:uint = 1;
		private var tabsMax:uint = 10;
		private var tabsMinAbsolute:uint = 1;
		private var tabsMaxAbsolute:uint = 10;
		private var tabBarInitialWidth:Number; // Initial Width.
		private var tabBarInitialHeight:Number; // Initial Height.
		private var scrollLimitL:Number; // Scroll left distance limit.
		private var scrollLimitR:Number; // Scroll right distance limit.
		private var scrollWidth:Number; // Scroll full distance.
		
		public var tabCloneLastOnAdd:Boolean = true;
		private var tempNewScreenId:int = -1;
		
		//private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		public var useTweens:Boolean = true;
		public var tweenSpeed:Number = .2;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		public function SSPTabBar(tbPos:Point)
		{
			this.x = tbPos.x;
			this.y = tbPos.y;
			this.tabBarInitialWidth = this.width;
			this.tabBarInitialHeight = this.height;
			
			// Max Screens.
			var maxScreens:uint;
			var strMaxScreens:String = sG.sessionDataXML.session._maxScreens.text();
			maxScreens = (strMaxScreens == "")? tabsMax : uint(strMaxScreens);
			if (maxScreens == 0) maxScreens = tabsMax;
			this.tabsMax = (maxScreens > tabsMaxAbsolute)? tabsMaxAbsolute : maxScreens;
			
			// Flash References.
			tC = new SSPTabBarContainer();
			btnAddTab = new SSPTabAdd(0, false);
			btnAddTab.y = this.height;
			btnAddTab.setToolTipText(sG.interfaceLanguageDataXML.tags[0]._btnAddScreen.text());
			this.addChild(btnAddTab);
			btnScrollL = this.btn_scroll_l;
			btnScrollR = this.btn_scroll_r;
			
			// Config.
			scrollLimitL = 0;
			scrollLimitR = tabBarInitialWidth - btnAddTab.width;
			scrollWidth = scrollLimitR - scrollLimitL;
			
			tCMask = ColorUtils.createShape(scrollLimitL+tC.tabSpace,0,scrollLimitR-tC.tabSpace,tabBarInitialHeight);
			this.addChild(tCMask);
			tC.mainTabBarXPos = this.x; // Used for mouse scrolling when dragging.
			tC.tabBarInitialWidth = tabBarInitialWidth;
			tC.tabBarInitialHeight = tabBarInitialHeight;
			tC.scrollLimitL = scrollLimitL;
			tC.scrollLimitR = scrollLimitR;
			tC.tabsMin = this.tabsMin;
			tC.tabsMax = this.tabsMax;
			tC.tabsMaxAbsolute = this.tabsMaxAbsolute;
			tC.addEventListener(SSPEvent.SESSION_SCREEN_TABS_CHANGE, onTabContainerChangeHandler);
			tC.addEventListener(SSPEvent.SESSION_SCREEN_REMOVE, onSessionScreenRemoveHandler);
			tC.addEventListener(SSPEvent.SESSION_SCREEN_TITLE_CHANGE, onSessionScreenTitleChangeHandler);
			tC.addEventListener(SSPEvent.SESSION_SCREEN_UPDATE_TEAM_SETTINGS, onSessionScreenUpdateTeamSettings);
			tC.addEventListener(SSPEvent.SESSION_SCREEN_SELECT, onSessionScreenSelectHandler);
			tC.addEventListener(SSPEvent.SESSION_SCREEN_REORDER, onSessionScreenReorder);
			this.addChild(tC);
			tC.mask = tCMask;
			
			// Bring controls on top.
			this.setChildIndex(btnScrollR, this.numChildren-1);
			this.setChildIndex(btnScrollL, this.numChildren-1);
			this.setChildIndex(btnAddTab, this.numChildren-1);
			
			// Listen for 'clone screen' from SessionView and SSPTab context menus.
			sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_CLONE, onCloneTabHandler);
			
			// Listen for 'select screen' from SessionView (dispatched after session loaded).
			sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_SELECT, onSessionScreenSelectFrom3D);
			
			tC.initTabsXML(sG.sessionDataXML);
			// Enabled/Disable scroll bars.
			toggleScrollTabs();
		}
		
		private function toggleScrollTabs():Boolean {
			var tabsEnabled:Boolean;
			var visibleTabs:uint = Math.abs( scrollWidth / tC.tabWidth );
			var numTabs:uint = (tC.aTabs.length > tabsMax)? tC.aTabs.length : tabsMax;
			if (numTabs <= visibleTabs) {
				if (btnScrollL.visible == true || btnScrollR.visible == true) {
					this.toggleButton(btnScrollL, false);
					btnScrollL.visible = false;
					this.toggleButton(btnScrollR, false);
					btnScrollR.visible = false;
				}
				tabsEnabled = false;
			} else {
				if (btnScrollL.visible == false || btnScrollR.visible == false) {
					this.toggleButton(btnScrollL, true);
					btnScrollL.visible = true;
					this.toggleButton(btnScrollR, true);
					btnScrollR.visible = true;
				}
				tabsEnabled = true;
			}
			updateScrollLimits(); // Update limits and mask.
			return tabsEnabled;
		}
		private function updateScrollLimits():void {
			scrollLimitL = 0;
			scrollLimitR = tabBarInitialWidth - btnAddTab.width;
			if (btnScrollR.visible) scrollLimitR -= btnScrollR.width;
			if (btnScrollL.visible) scrollLimitR -= btnScrollL.width;
			scrollWidth = scrollLimitR - scrollLimitL;
			// Change Mask Width.
			tCMask.width = scrollWidth - tC.tabSpace;
			// Update the values in tC.
			tC.scrollLimitL = scrollLimitL;
			tC.scrollLimitR = scrollLimitR;
		}
		
		private function onSessionScreenRemoveHandler(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		private function onSessionScreenTitleChangeHandler(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		private function onSessionScreenUpdateTeamSettings(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		private function onSessionScreenSelectHandler(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		private function onSessionScreenReorder(e:SSPEvent):void {
			this.dispatchEvent(e);
		}
		private function onTabContainerChangeHandler(e:SSPEvent):void {
			notifyTabContainerChange();
		}
		private function notifyTabContainerChange():void {
			// TODO: Scroll tab container if necesary.
			updateTabsContainer(useTweens);
		}
		
		private function onSessionScreenSelectFrom3D(e:SSPEvent):void {
			var newSId:int = e.eventData as int;
			if (newSId == -1) return;
			tC.selectTabFromScreenId(newSId);
		}
		
		private function updateTabsContainer(userTweener:Boolean):void {
			var newTCXDistance:Number;
			var newTCXPos:Number;
			var lBound:Number;
			var rBound:Number;
			var extraOffset:Number = tC.tabHalfWidth; // To show hidden tab if any.
			var tCScrolled:Boolean = false; // Update if no scroll.
			
			if (tC.tabSelected) {
				// If selected tab is half visible, move container.
				lBound = tC.tabSelected.x + tC.x;
				rBound = tC.tabSelected.x + tC.x + tC.tabWidth;
			} else {
				// scroll container if needed (eg: after delete a tab);
				lBound = tC.x;
				rBound = tC.x + tC.width;
			}
			
			if (rBound >= scrollLimitR) {
				extraOffset = (rBound == scrollLimitR)? tC.tabHalfWidth : 0;
				newTCXDistance = Math.abs(rBound - scrollLimitR - extraOffset);
				
				// Fix position if needed.
				newTCXPos = tC.x - newTCXDistance;
				newTCXPos = getFixedTabBarContainerPos(LEFT_SIDE, newTCXPos);
				newTCXDistance = Math.abs(newTCXPos - tC.x);
				
				//scrollTabBarContainer(LEFT_SIDE, newTCXDistance);
				scrollTabBarContainer(LEFT_SIDE);
				tCScrolled = true;
				
				btnAddTab.visible = false; // Hide btnAddTab.
			}
			if (lBound <= scrollLimitL) {
				extraOffset = (lBound == scrollLimitL)? tC.tabHalfWidth : 0;
				newTCXDistance = Math.abs(lBound - scrollLimitL - extraOffset);
				
				// Fix position if needed.
				newTCXPos = tC.x + newTCXDistance;
				newTCXPos = getFixedTabBarContainerPos(RIGHT_SIDE, newTCXPos);
				newTCXDistance = Math.abs(newTCXPos - tC.x);
				
				//scrollTabBarContainer(RIGHT_SIDE, newTCXDistance);
				scrollTabBarContainer(RIGHT_SIDE);
				tCScrolled = true;
			}
			
			// Adjust Tabs Container (eg: in the case of a tab deletion).
			if (tC.width < scrollLimitR) {
				// Align to the left.
				newTCXDistance = Math.abs(tC.x - scrollLimitL);
				scrollTabBarContainer(RIGHT_SIDE, newTCXDistance);
				tCScrolled = true;
			}
			
			// Adjust Tabs Container (eg: in the case of a tab deletion).
			/*if (!tCScrolled) {
				if (tC.width < scrollLimitR) {
					// Align to the left.
					newTCXDistance = Math.abs(tC.x - scrollLimitL);
					scrollTabBarContainer(RIGHT_SIDE, newTCXDistance);
					tCScrolled = true;
				} else {
					// Align to the left.
					newTCXDistance = Math.abs(tC.width - scrollLimitR);
					//if (newTCXDistance > 0) newTCXDistance *= -1;
					scrollTabBarContainer(LEFT_SIDE, newTCXDistance);
					tCScrolled = true;
				}
			}*/
			
			if (!tCScrolled) updateControls();
		}
		
		private function scrollTabBarContainer(scrollDirection:int, scrollDistance:Number = NaN):void {
			// Get Distance needed to show specified tabs.
			var visibleTabs:uint = Math.abs( scrollWidth / tC.tabWidth );
			var newScrollDistance:Number = scrollWidth - (tC.tabWidth * visibleTabs);
			
			if (!isNaN(scrollDistance)) newScrollDistance = scrollDistance;
			
			var newTCXPos:Number; 
			if (scrollDirection == LEFT_SIDE) {
				// Scroll Left.
				newTCXPos = tC.x - newScrollDistance;
				// Use normal scroll distance if not the last tab and not distance specified.
				if (newTCXPos + tC.width > scrollLimitR && isNaN(scrollDistance)) {
					newTCXPos = tC.x - tC.tabWidth;
				}
				// Fix position if needed.
				newTCXPos = getFixedTabBarContainerPos(RIGHT_SIDE, newTCXPos);
			} else {
				// Scroll Right.
				newTCXPos = tC.x + newScrollDistance;
				// Use normal scroll distance + half if not the first tab and not distance specified.
				if (newTCXPos < scrollLimitL && isNaN(scrollDistance)) {
					newTCXPos = tC.x + tC.tabWidth;
				}
				// Fix position if needed.
				newTCXPos = getFixedTabBarContainerPos(LEFT_SIDE, newTCXPos);
			}
			moveXPos(tC, newTCXPos, useTweens, true, tweenSpeed);
		}
		
		private function getFixedTabBarContainerPos(adjustSide:int, newTCXPos:Number):Number {
			if (adjustSide == LEFT_SIDE) {
				// Adjust to the left side.
				if (newTCXPos > scrollLimitL) {
					newTCXPos = scrollLimitL;
				}
			} else if (adjustSide == RIGHT_SIDE) {
				// Adjust to the right side.
				if (newTCXPos + tC.width < scrollLimitR) {
					newTCXPos = scrollLimitR - tC.width;
				}
			}
			return newTCXPos;
		}
		
		private function updateControls():void {
			updateScrollTabs();
			updateAddTab();
		}
		
		private function updateScrollTabs():void {
			//if (!toggleScrollTabs()) return; // If scroll tabs are disabled, return.
			
			var tCBorderLeft:Number = tC.x;
			var tCBorderRight:Number = tC.width + tC.x;
			
			// Scroll Right.
			if (tCBorderLeft >= scrollLimitL) {
				toggleButton(btnScrollL, false);
				btnScrollL.removeEventListener(MouseEvent.CLICK, onScrollLClickHandler);
			} else {
				toggleButton(btnScrollL, true);
				if (!btnScrollL.hasEventListener(MouseEvent.CLICK)) {
					btnScrollL.addEventListener(MouseEvent.CLICK, onScrollLClickHandler);
				}
			}
			
			// Scroll Right.
			if (tCBorderRight <= scrollLimitR) {
				toggleButton(btnScrollR, false);
				btnScrollR.removeEventListener(MouseEvent.CLICK, onScrollRClickHandler);
			} else {
				toggleButton(btnScrollR, true);
				if (!btnScrollR.hasEventListener(MouseEvent.CLICK)) {
					btnScrollR.addEventListener(MouseEvent.CLICK, onScrollRClickHandler);
				}
			}
		}
		
		private function updateAddTab():void {
			var atXPos:Number = 0;
			atXPos = tC.width + tC.x;
			if (atXPos > scrollLimitR) atXPos = scrollLimitR;
			//var useT:Boolean = (atXPos < scrollLimitR)? true : false;
			var useT:Boolean = true;
			btnAddTab.visible = useT;
			moveXPos(btnAddTab, atXPos, useT, false, tweenSpeed/2);
			
			// If no more tabs available, disable btnAddTab.
			if (tC.tabsMax != 0 && tC.tabsNumber >= tC.tabsMax) {
				toggleAddTab(false);
				btnAddTab.removeEventListener(MouseEvent.CLICK, onAddTabClickHandler);
			} else {
				toggleAddTab(true);
				if (!btnAddTab.hasEventListener(MouseEvent.CLICK)) {
					btnAddTab.addEventListener(MouseEvent.CLICK, onAddTabClickHandler);
				}
			}
			btnAddTab.visible = true; // Show btnAddTab.
		}
		public function moveXPos(targetObj:DisplayObject, newXPos:Number, useTweener:Boolean, callUpdateControls:Boolean, newTweenSpeed:Number):void {
			if (!useTweener) {
				targetObj.x = newXPos;
				if (callUpdateControls) updateControls();
			} else {
				var tOptions:Object = {};
				tOptions.x = newXPos;
				if (callUpdateControls) {
					tOptions.onComplete = updateControls;
				} else {
					tOptions.onComplete = onMoveXPosFinished;
				}
				TweenLite.to(targetObj, newTweenSpeed, tOptions);
			}
		}
		private function onMoveXPosFinished():void {
			this.setChildIndex(btnAddTab, this.numChildren-1); // Bring btnAddTab on top.
		}
		
		private function onAddTabClickHandler(e:MouseEvent):void {
			btnAddTab.removeEventListener(MouseEvent.CLICK, onAddTabClickHandler);
			if (!btnAddTab.buttonEnabled) return;
			toggleAddTab(false);
			
			//this.setChildIndex(btnAddTab, 0);
			this.swapChildren(btnAddTab, tC); // Send btnAddTab behind tC.
			var tCCI:int = this.getChildIndex(tC);
			var aTCI:int = this.getChildIndex(btnAddTab);
			
			// Check Limit.
			if (tC.tabsLimitReached) {
				logger.addText("(A) - Can't add more tabs (max: "+tabsMax+")", false);
				return;
			}
			var newTabXMLList:XMLList;
			var includeObjects:Boolean = false;
			var resetComments:Boolean = true;
			var resetScreenSettings:Boolean = true;
			if (tabCloneLastOnAdd) {
				// Note that tabs can change screenSortOrder, but screenId never changes, otherwise the objects would be messed up.
				newTabXMLList = SessionScreenUtils.cloneScreen(SessionScreenUtils.getMaxScreenId(), TabUtils.getInstance().defaultLabelScreen, includeObjects, resetComments, resetScreenSettings);
			} else {
				// Clone First.
				newTabXMLList = SessionScreenUtils.cloneScreen(SessionScreenUtils.getMinScreenId(), TabUtils.getInstance().defaultLabelScreen, includeObjects, resetComments, resetScreenSettings);
			}
			var tempNewSId:uint = uint( newTabXMLList._screenId.text() );
			sessionScreenAddStart(tempNewSId);
		}
		
		private function onCloneTabHandler(e:SSPEvent):void {
			// Check Limit.
			if (tC.tabsLimitReached) {
				logger.addText("(A) - Can't clone more tabs (max: "+tabsMax+")", false);
				return;
			}
			logger.addText("Cloning Screen From Tab (Id:"+e.eventData+").", false);
			var newSId:uint = e.eventData as uint;
			var includeObjects:Boolean = true;
			var resetComments:Boolean = true;
			var resetScreenSettings:Boolean = false;
			var newTabXMLList:XMLList = SessionScreenUtils.cloneScreen(newSId, TabUtils.getInstance().defaultLabelScreen, includeObjects, resetComments, resetScreenSettings);
			var tempNewSId:uint = uint( newTabXMLList._screenId.text() );
			sessionScreenAddStart(tempNewSId);
		}
		
		/**
		 * Tells Session View to create a 3d screen. 
		 * @param newScreenId
		 */		
		private function sessionScreenAddStart(newScreenId:uint):void {
			tempNewScreenId = newScreenId;
			sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_CREATED, onSessionScreenCreated); // Listen for SessionView response.
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_ADD,tempNewScreenId)); // Send order to session view.
		}
		
		private function onSessionScreenCreated(e:SSPEvent):void {
			sspEventHandler.RemoveEvent(SSPEvent.SESSION_SCREEN_CREATED);
			var newTabXML:XML = e.eventData as XML;
			if (!newTabXML) {
				logger.addText("Can't create 3D Screen. Add tab aborted.", true);
				cancelScreenCreation(tempNewScreenId);
			}
			
			var newScreenId:int = int(newTabXML._screenId.text()); 
			if (newScreenId != tempNewScreenId || newScreenId < 0) {
				logger.addText("Unexpected screenId '"+newTabXML._screenId.text()+" created. Should be '"+tempNewScreenId+".", true);
				return;
			}
			
			tC.createNewTab(newTabXML);
			
			updateTabsContainer((btnAddTab.x >= tC.width + tC.x)? true : false);
			
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_CREATED, newScreenId)); // Redispatch to ScreensController but including screenId instead of XML.
			
			sG.createMode = false;
			toggleAddTab(true);
			
			logger.addText("End of new screen load (Id: "+newTabXML._screenId.text()+", sortOrder: "+newTabXML._screenSortOrder.text()+").", false);
		}
		
		private function cancelScreenCreation(sId:int) {
			SessionScreenUtils.deleteScreen(sId);
			sG.createMode = false;
			toggleAddTab(true);
			return;
		}
		
		private function onScrollLClickHandler(e:MouseEvent):void {
			scrollTabBarContainer(RIGHT_SIDE);
		}
		
		private function onScrollRClickHandler(e:MouseEvent):void {
			scrollTabBarContainer(LEFT_SIDE);
		}
		
		private function toggleButton(btn:SimpleButton, btnEnabled:Boolean):void {
			if (!btnEnabled) {
				trace(btn.name + " disabled");
				btn.alpha = .4;
				btn.enabled = false;
				//this.setChildIndex(btn, 0); // Send btn to bottom.
			} else {
				trace(btn.name + " enabled");
				btn.alpha = 1;
				btn.enabled = true;
				//this.setChildIndex(btn, this.numChildren-1); // Bring btn to top.
			}
		}
		
		private function toggleAddTab(toggle:Boolean):void {
			//btnAddTab.buttonSelected = toggle;
			btnAddTab.buttonEnabled = toggle;
		}
		
		public function updateTabTitle(sId:uint):void {
			tC.updateTabsTitle(sId);
		}
			
		public override function get aTabs():Vector.<SSPTab> {
			var aT:Vector.<SSPTab> = new Vector.<SSPTab>();
			for (var i:uint;i<tC.aTabs.length;i++) {
				if (tC.aTabs[i].isTab) aT.push(tC.aTabs[i] as SSPTab);
			}
			return aT;
		}
	}
}