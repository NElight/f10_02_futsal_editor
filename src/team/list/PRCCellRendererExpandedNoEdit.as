package src.team.list
{
	import flash.events.MouseEvent;
	
	public class PRCCellRendererExpandedNoEdit extends PRCCellRendererExpanded
	{
		public function PRCCellRendererExpandedNoEdit()
		{
			super();
			this.name = "PRCCellRendererExpandedNoEdit";
		}
		
		protected override function initFormat():void {
			super.initFormat();
			_rFinit.displayEdit = false;
		}
	}
}