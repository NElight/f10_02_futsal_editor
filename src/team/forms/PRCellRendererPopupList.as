package src.team.forms
{
	import flash.events.MouseEvent;
	
	import src.team.PRCellRendererBase;
	import src.team.SSPTeamEvent;
	import src.team.TeamGlobals;
	import src.team.list.ColorBackgroundBox;
	
	public class PRCellRendererPopupList extends PRCellRendererBase
	{
		
		public function PRCellRendererPopupList()
		{
			super();
			this.stop();
			this.name = "PRCellRendererPopupList";
			
			// Controls.
			_txtName = this.txtName;
			_txtFamName = this.txtFamName;
			_txtNumber = this.txtNumber;
			_btnRemove = this.btnRemove;
			_btnRemove.buttonMode = true;
			_btnRemove.addEventListener(MouseEvent.CLICK, onBtnRemoveClick);
			_mcNumberBg = this.mcNumberBg as ColorBackgroundBox;
			
			// Format.
			_rFinit = TeamGlobals.getInstance().initialSelectTeamSourceCellSettings;
			
			initPlayerRecordFormat();
		}
		
		protected override function onBtnRemoveClick(e:MouseEvent):void {
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TARGET_LIST_REMOVE_ITEM, this._data));
		}
		
		protected override function onStageMouseMove(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			if (!isDragging) {
				isDragging = true;
				sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.SOURCE_LIST_DRAG_ITEM, this)); // Tells 'Select Team' form that we are dragging an object.
			}
		}
		
		public override function clone(cloneIn:PRCellRendererBase=null):PRCellRendererBase {
			var newCR:PRCellRendererPopupList = (cloneIn)? cloneIn as PRCellRendererPopupList: new PRCellRendererPopupList();
			super.clone(newCR); // Get base settings.
			
			return newCR;
		}
	}
}