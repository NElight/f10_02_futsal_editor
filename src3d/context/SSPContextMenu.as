package src3d.context
{
	import flash.display.DisplayObjectContainer;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class SSPContextMenu
	{	
		protected var _ref:DisplayObjectContainer;
		protected var _refData:Object;
		
		// Context Menu Items.
		private var sspNotice:ContextMenuItem;
		private var sspAbout:ContextMenuItem;
		
		protected var _contextMenu:ContextMenu = new ContextMenu();
		protected var aCustomItems:Array = [];
		protected var aNonDefaultCustomItems:Array = [];
		
		public function SSPContextMenu()
		{
			init();
		}
		
		private function init():void {
			initDefaultMenuItems();
			initMenuItems();
			
			addTopMenuItems();
			addMenuItems();
			addBottomMenuItems();
			
			_contextMenu.customItems = aCustomItems;
		}
		
		private function initDefaultMenuItems():void {
			sspNotice = new ContextMenuItem("Sport Session Planner");
			sspAbout = new ContextMenuItem("About SSP");
			
			sspNotice.enabled = false;
			
			sspAbout.separatorBefore = true;
			sspAbout.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onOpenAbout, false, 0, true);
		}
		
		private function addTopMenuItems():void {
			//aCustomItems.push(sspNotice);
		}
		
		protected function initMenuItems():void {
			// Override in extending classes.
		}
		protected function addMenuItems():void {
			for each(var ci:ContextMenuItem in aNonDefaultCustomItems) {
				aCustomItems.push(ci);
			}
		}
		
		private function addBottomMenuItems():void {
			aCustomItems.push(sspAbout);
		}
		
		/**
		 * Apply the context menu to the specified target.
		 *  
		 * @param ref The target to apply the context menu to.
		 * @param refData An optional data to pass with the dispatched event (eg: a screen Id).
		 * @param hideBuiltInItems Hides default flash items.
		 * 
		 */		
		public function applyToTarget(ref:DisplayObjectContainer, refData:Object, hideBuiltInItems:Boolean):void {
			if (!ref) return;
			_ref = ref;
			_refData = refData;
			_ref.contextMenu = _contextMenu;
			if (hideBuiltInItems) _ref.contextMenu.hideBuiltInItems();
		}
		
		/*public function set contextMenu(newCMenu:ContextMenu):void {
			if (!_ref) return;
			_ref.contextMenu = newCMenu;
		}*/
		public function get contextMenu():ContextMenu {
			if (!_ref) return null;
			return _ref.contextMenu;
		}
		
		private function onOpenAbout(e:ContextMenuEvent):void{
			// To do.
		}
	}
}