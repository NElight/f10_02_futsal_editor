package src.team.list
{
	import flash.events.MouseEvent;
	
	public class PRCCellRendererCompactNoEdit extends PRCCellRendererCompact
	{
		public function PRCCellRendererCompactNoEdit()
		{
			super();
			this.name = "PRCCellRendererCompactNoEdit";
		}
		
		protected override function initFormat():void {
			super.initFormat();
			_rFinit.displayEdit = false;
		}
	}
}