package src.tabbar
{
	import flash.display.SimpleButton;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	
	public class SSPTab extends SSPTabBase
	{
		// Note: Tags used from XML: _screenId, _screenSortOrder, _screenTitle, _screenChangedFlag.
		
		private var stageEventHandler:EventHandler;
		
		private var _tabNumber:int = 0;
		private var _tabLabel:String = "";
		private var _tabFullLabel:String = "";
		private var _tabContentChanged:Boolean;
		private var _tabScreenXML:XML;
		private var tabChangedMark:String = ""; // Display asterik if screen changes.
		//private var tabChangedMark:String = ""; // No display asterik if screen changes.
		
		private var labelEditMode:Boolean;
		private var txtTabLabelEdit:TextField;
		private var txtTabLabelOldText:String = "";
		private var uintTabLabelFontColor:uint = 0x404040;
		//private var uintTabLabelFontEditColor:uint = 0;
		private var strTabLabelMaxChars:uint = 100;
		private var uintTabLabelEditBackgroudColor:uint = 0xFFFF99;
		
		private var tabContextMenu:ContextMenu;
		private var tabContextMenuCloneScreen:ContextMenuItem;
		
		public function SSPTab(xPos:Number, yPos:Number, tabScreenXML:XML, tabNumber:int)
		{
			var tbA:McTab = new McTab("", true);
			super(SSPTabTypeLibrary.OBJECT_TYPE_SCREEN_TAB, tbA, null, true);
			
			txtTabLabelEdit = tbA.txtLabelEdit;
			this._tabScreenXML = tabScreenXML;
			this._tabNumber = tabNumber;
			//this._tabLabel = _tabScreenXML._screenTitle.text();
			this.x = xPos;
			this.y = yPos;
			
			initTabGroup();
			initTabLabel();
			
			// Add Context Menu.
			addContextMenuItems();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			stageEventHandler = new EventHandler(this.stage);
			initTabLabelEdit();
		}
		
		private function initTabGroup():void {
			if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				this.tabGroup = (_tabScreenXML._screenType.text() == SessionGlobals.SCREEN_TYPE_SET_PIECE)? 1 : 0;
			}else {
				this.tabGroup = 0;
			}
		}
		
		private function initTabLabelEdit():void {
			txtTabLabelEdit.visible = false;
			txtTabLabelEdit.background			= true;
			txtTabLabelEdit.backgroundColor		= uintTabLabelEditBackgroudColor;
			txtTabLabelEdit.maxChars			= strTabLabelMaxChars;
		}
		
		
		
		// ----------------------------- Controls ----------------------------- //
		protected override function set listenersEnabled(lEnabled:Boolean):void {
			super.listenersEnabled = lEnabled;
			if (lEnabled) {
				// Edit Label Listener.
				if (_labelEditable) {
					tabAArea.doubleClickEnabled = true;
					tabAArea.addEventListener(MouseEvent.DOUBLE_CLICK, onButtonMouseDoubleClickHandler, false, 0, true);
					if (btnB) {
						tabBArea.doubleClickEnabled = true;
						tabBArea.addEventListener(MouseEvent.DOUBLE_CLICK, onButtonMouseDoubleClickHandler, false, 0, true);
					}
				}
			} else {
				if (stageEventHandler) stageEventHandler.RemoveEvents();
				btnA.removeEventListener(MouseEvent.DOUBLE_CLICK, onButtonMouseDoubleClickHandler);
				if (btnB) btnB.removeEventListener(MouseEvent.DOUBLE_CLICK, onButtonMouseDoubleClickHandler);
			}
		}
		// -------------------------- End of Controls ------------------------- //
		
		
		
		// ----------------------------- Label ----------------------------- //
		private function initTabLabel():void {
			var newLabel:String = TabUtils.getInstance().updateTabLabel(_tabScreenXML._screenTitle.text(), _tabScreenXML._screenType.text(), _tabNumber);
			_tabContentChanged = false;
			applyTabLabel(newLabel);
		}
		
		/**
		 * Sets the Tab Label including the Tab Number if necessary (eg: "Screen 1", "My Period", "Training", etc.). 
		 * @param tLabel String.
		 * @see <code>setTabLabel</code>
		 */		
		public function set tabLabel(tLabel:String):void {
			//if (tLabel == this.tabLabel) return;
			// Validate
			if (!tLabel || tLabel == "") tLabel = TabUtils.getInstance().updateTabLabel("", this.tabScreenType, _tabNumber);
			
			_tabContentChanged = true;
			
			applyTabLabel(tLabel);
			
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_TITLE_CHANGE, this.tabScreenId));
		}
		private function applyTabLabel(tLabel:String):void {
			_tabLabel = tLabel;
			_tabFullLabel = (_tabContentChanged)? tabChangedMark+_tabLabel : _tabLabel;
			this.buttonLabelHTML = _tabFullLabel;
			_tabScreenXML._screenTitle = this.buttonLabel;
			_tabScreenXML._screenChangedFlag = (_tabContentChanged)? "TRUE" : "FALSE";
		}
		
		public function get tabLabel():String {
			return this.buttonLabel;
		}
		public function get tabLabelHtml():String {
			return this.buttonLabelHTML;
		}
		
		public function updateTabLabel():void {
			tabLabel = _tabScreenXML._screenTitle.text();
		}
		// -------------------------- End of Label ------------------------- //
		
		
		
		// ----------------------------- Label Edit ----------------------------- //
		public override function set buttonSelected(value:Boolean):void {
			stopTabLabelEdit();
			super.buttonSelected = value;
		}
		
		private function onButtonMouseDoubleClickHandler(e:MouseEvent):void {
			if (e.target != tabBClose && e.target != tabBClose) {
				startTabLabelEdit();
			}
		}
		
		private function onStageMouseDownTabLabelHandler(e:MouseEvent){
			if(e.target != txtTabLabelEdit) {
				stopTabLabelEdit();
			}
		}
		protected override function onButtonMouseMouseDown(e:MouseEvent):void {
			if (e.target == txtTabLabelEdit) return;
			super.onButtonMouseMouseDown(e);
		}
		
		private function onStageKeyDownTabLabelHandler(e:KeyboardEvent) {
			if(e.charCode == Keyboard.ENTER) stopTabLabelEdit();
			if(e.charCode == Keyboard.ESCAPE) cancelTabLabelEdit();
		}
		
		private function startTabLabelEdit():void {
			tabLabelEditMode = true;
		}
		
		protected function stopTabLabelEdit():void {
			if (!labelEditMode || !txtTabLabelEdit) return;
			tabLabel = txtTabLabelEdit.htmlText;
			tabLabelEditMode = false;
		}
		
		protected function cancelTabLabelEdit():void {
			tabLabel = _tabLabel; // Reset the old text.
			tabLabelEditMode = false;
		}
		
		protected function set tabLabelEditMode(value:Boolean):void {
			if (!buttonLabelTextFieldA || !txtTabLabelEdit) return;
			if (value) {
				sG.editMode = labelEditMode = true;
				txtTabLabelEdit.visible = true; // Make text edit visible.
				txtTabLabelEdit.htmlText = _tabLabel; // Get label text.
				
				// Listeners.
				stageEventHandler.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDownTabLabelHandler, false, 0, true);
				stageEventHandler.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDownTabLabelHandler, false, 0, true);
				
				// Select the text.
				if (txtTabLabelEdit.length > 0) txtTabLabelEdit.setSelection(0, txtTabLabelEdit.length);
				stage.focus = txtTabLabelEdit;
				
				// Set focus.
				if (this.visible && txtTabLabelEdit.visible && stage) stage.focus = txtTabLabelEdit;
			} else {
				stageEventHandler.RemoveEvents();
				txtTabLabelEdit.visible = false;
				//if (stage) stage.focus = stage;
				sG.editMode = labelEditMode = false;
			}
		}
		// -------------------------- End of Label Edit ------------------------- //
		
		
		
		private function addContextMenuItems():void {
			if (!tabContextMenu) {
				tabContextMenu = new ContextMenu();
			}
			if (!tabContextMenuCloneScreen) {
				var cloneScreenLabelStr:String = sG.interfaceLanguageDataXML.menu[0]._rclickCloneScreen.text();
				if (cloneScreenLabelStr == "") cloneScreenLabelStr = "CloneScreen"; // Set the default english text if no language tag.
				tabContextMenuCloneScreen = new ContextMenuItem(cloneScreenLabelStr);
			}
			
			//cloneScreenOptions = new ContextMenuItem("Clone Screen with Options"); Future implementation.
			
			tabContextMenuCloneScreen.separatorBefore = true;
			tabContextMenuCloneScreen.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTabClone, false, 0, true);
			
			tabContextMenu.hideBuiltInItems();
			tabContextMenu.customItems = [tabContextMenuCloneScreen];
			
			this.contextMenu = tabContextMenu;
		}
		private function onTabClone(e:ContextMenuEvent):void {
			Logger.getInstance().addText("Cloning Screen From Tab (Id:"+this.tabScreenId+", SO: "+this.tabSortOrder+").", false);
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_CLONE_FROM_TAB, this.tabScreenId, true));
		}
		
		
		
		// ----------------------------- Gettters/Setters ----------------------------- //
		public function set contextMenuEnabled(ctxEnabled:Boolean):void {
			tabContextMenuCloneScreen.enabled = ctxEnabled;
			this.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_CLONE_TOGGLE, ctxEnabled, true));
		}
		
		public override function set tabSelected(s:Boolean):void {
			super.tabSelected = s;
			if (!this.tabSelected) tabLabelEditMode = false;
		}
		
		public function set tabNumber(tNumber:int):void {
			_tabNumber = tNumber;
			this.tabLabel = TabUtils.getInstance().updateTabLabel(_tabLabel, this.tabScreenType, _tabNumber);
		}
		
		public function set tabContentChanged(c:Boolean):void {
			_tabContentChanged = c;
			tabLabel = _tabLabel; // Update label.
		}
		
		public function get tabScreenXML():XML { return _tabScreenXML; }
		public function set tabSortOrder(newSO:int):void {
			if (newSO < 0) {
				trace ("_tabSortOrder can't be negative");
				return;
			}
			_tabScreenXML._screenSortOrder = newSO.toString(); }
		public function get tabSortOrder():int {
			var strSO:String = _tabScreenXML._screenSortOrder.text();
			if (strSO == "" || strSO == null) return -1;
			return int( _tabScreenXML._screenSortOrder.text() );
		}
		public function get tabScreenId():int {
			var strId:String = _tabScreenXML._screenId.text();
			if (strId == "" || strId == null) return -1;
			return int( _tabScreenXML._screenId.text() );
		}
		
		public function get tabScreenType():String {
			var strType:String = _tabScreenXML._screenType.text();
			if (strType == "" || strType == null) {
				if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
					strType = SessionGlobals.SCREEN_TYPE_SET_PIECE;
				} else {
					strType = SessionGlobals.SCREEN_TYPE_SCREEN;
				}
			}
			return strType;
		}
		
		public override function set tabGroup(g:int):void {
			this._tabGroup = g;
			var sType:String = this.getScreenTypeFromGroup(g);
			_tabScreenXML._screenType = sType;
			this.tabBackgroundType = sType;
		}
		// -------------------------- End of Gettters/Setters ------------------------- //
		
		public override function dispose():void {
			if (stageEventHandler) stageEventHandler.RemoveEvents();
			_tabScreenXML = null;
			if (tabContextMenuCloneScreen) {
				tabContextMenuCloneScreen.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onTabClone);
			}
			tabContextMenuCloneScreen = null;
			tabContextMenu = null;
			super.dispose();
		}
	}
}