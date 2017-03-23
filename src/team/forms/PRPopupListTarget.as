package src.team.forms
{
	import flash.events.Event;
	
	import src.team.PRItem;
	import src.team.SSPTeamEvent;
	
	public class PRPopupListTarget extends PRPopupListBase
	{
		
		public function PRPopupListTarget()
		{
			this.name = LIST_NAME_TARGET;
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			var pr:PRCellRendererPopupList = new PRCellRendererPopupListTarget();
			this.setStyle("cellRenderer",PRCellRendererPopupListTarget);
			this.rowHeight = pr.height;
			this.width = pr.width;
			this.setStyle("border", false);
			this.setStyle("borderStyle", "solid");
			this.setStyle("borderColor", "red");
			
			// Listen for remove items.
			sspEventDispatcher.addEventListener(SSPTeamEvent.TARGET_LIST_REMOVE_ITEM, onTargetListItemRemove, false, 0, true);
		}
		
		// ----------------------------------- Item Remove ----------------------------------- //
		protected function onTargetListItemRemove(e:SSPTeamEvent):void {
			var targetItem:PRItem = e.eventData;
			if (!targetItem) return;
			// Removes the item from the target list.
			this.removeItem(targetItem);
		}
		// -------------------------------- End of Item Remove ------------------------------- //
	}
}