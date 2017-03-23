package src.team.forms
{
	import flash.events.Event;
	
	import src.team.PRItem;
	import src.team.SSPTeamEvent;
	
	public class PRPopupListSource extends PRPopupListBase
	{
		
		public function PRPopupListSource()
		{
			this.name = LIST_NAME_SOURCE;
		}
		protected override function init(e:Event):void {
			super.init(e);
			var pr:PRCellRendererPopupList = new PRCellRendererPopupList();
			this.setStyle("cellRenderer",PRCellRendererPopupList);
			this.rowHeight = pr.height;
			//this.width = pr.width + this._verticalScrollBar.width;
			this.width = pr.width;
			
			// Listen for remove items.
			sspEventDispatcher.addEventListener(SSPTeamEvent.TARGET_LIST_REMOVE_ITEM, onTargetListItemRemove, false, 0, true);
		}
		
		private function onTargetListItemRemove(e:SSPTeamEvent):void {
			var targetItem:PRItem = e.eventData;
			if (!targetItem) return;
			// Enable the item in the source list.
			togglePlayerRecord(targetItem.playerId, true);
		}
		
		// ----------------------------------- Drag and Drop ----------------------------------- //
		//public override function startDragging(pr:PRCellRenderer, sourceName:String):void {
		//	trace("PlayerRecordsSource.startDragging()");
		//	this.sourceName = sourceName;
		//	if (sourceName == LIST_NAME_TARGET) this.acceptDrag = true;
		//}
		// -------------------------------- End of Drag and Drop ------------------------------- //
	}
}