package src.minutes
{
	import fl.controls.DataGrid;
	import fl.controls.ScrollPolicy;
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.events.ListEvent;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	
	public class MinutesDataGrid extends DataGrid//切换screen
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mM:MinutesManager = MinutesManager.getInstance();
		private var minutesEditor:SSPMinutesEditor;
		
		private var strMinute:String = "Minute";
		private var strObject:String = "Object";
		private var strTeam:String = "Team";
		private var strActivity:String = "Activity";
		private var strRemove:String = "Remove";
		private var strEdit:String = "Edit";
		
		private var strCellRendererRemove:String = "buttonMinutesRemove";
		private var strCellRendererEdit:String = "buttonMinutesEdit";
		
		public function MinutesDataGrid(minutesEditor:SSPMinutesEditor)
		{
			super();
			this.minutesEditor = minutesEditor;
			init();
		}
		
		private function init():void {
			this.setStyle("border", false);
			this.allowMultipleSelection = false;
			this.editable = false;
			this.headerHeight = 20;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.resizableColumns = false;
			this.rowHeight = 20;
			this.showHeaders = false;
			this.sortableColumns = false;
			this.verticalScrollPolicy = ScrollPolicy.ON;
			this.selectable = true;
			
			strMinute = MinutesGlobals.MINUTES_COLUMN_MINUTE;
			strObject = MinutesGlobals.MINUTES_COLUMN_OBJECT;
			strTeam = MinutesGlobals.MINUTES_COLUMN_TEAM;
			strActivity = MinutesGlobals.MINUTES_COLUMN_ACTIVITY;
			strRemove = MinutesGlobals.MINUTES_COLUMN_REMOVE;
			strEdit = MinutesGlobals.MINUTES_COLUMN_EDIT;
			
			this.columns = new Array(strMinute, strObject, strTeam, strActivity, strRemove, strEdit);
			this.columns[0].width = 43; // Minute.
			this.columns[1].width = 115; // Object.
			this.columns[2].width = 45; // Team.
			this.columns[3].width = 80; // Action.
			
			var controlsDGC:DataGridColumn;
			controlsDGC = this.columns[1];
			controlsDGC.cellRenderer = ListNameCellRenderer;
			controlsDGC = this.columns[3];
			controlsDGC.cellRenderer = MinutesDataGridCellRenderer;
			controlsDGC = this.columns[4];
			controlsDGC.cellRenderer = strCellRendererRemove;
			controlsDGC = this.columns[5];
			controlsDGC.cellRenderer = strCellRendererEdit;
			
			this.addEventListener(ListEvent.ITEM_CLICK, onMouseClickHandler, false, 0, true);
		}
		
		private function onMouseClickHandler(e:ListEvent):void {
			if (e.columnIndex == -1 || !e.item) return;
			var mItem:MinutesItem = e.item as MinutesItem;
			if (!mItem) return;
			
			// Select Corresponding 3D Screen.
			var uintScreenId:uint = uint(mItem.screenId);
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT, uintScreenId));
			
			// Remove Button.
			if (this.columns[e.columnIndex].headerText == strRemove) {
				minutesEditor.removeRecord(e.item as MinutesItem);
			}
			
			// Edit Button.
			if (this.columns[e.columnIndex].headerText == strEdit) {
				minutesEditor.setEditRecord(e.item as MinutesItem);
			}
			
			// Player List Button.
			if (mItem.isButton
				&& mItem.Activity == sG.interfaceLanguageDataXML.buttons._btnMinutesPlayerList.text()
				&& this.columns[e.columnIndex].headerText == strActivity
			) {
				var sId:String = mItem.screenId;
				mM.displayPlayerList(sId);
			}
		}
		
		public function sortDataGrid():void {
			this.sortItemsOn(strMinute); // Sort by Minute.
		}
		
		
		
		// ----------------------------- Public ----------------------------- //
		/*public function addMinuteItem(newItem:MinutesItem):void {
			if (!newItem) return;
			this.addItem(newItem);
			//this.sortByColumn(0); // This method toggles between ascending and descending each time is used.
			sortDataGrid();
			this.selectedItem = newItem;
			this.scrollToSelected();
		}*/
		// -------------------------- End of Public ------------------------- //
	}
}