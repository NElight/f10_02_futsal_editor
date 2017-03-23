package src.buttons
{
	import src.lists.MCCellRenderer;
	
	public class SSPButtonCellRenderer extends MCCellRenderer
	{
		public function SSPButtonCellRenderer()
		{
			super();
		}
		
		// ----------------------------------- Cell Renderer Interface ----------------------------------- //
		public override function set selected(value:Boolean):void
		{
			//this.buttonSelected = value;
			//this.invalidate();
		}
		// -------------------------------- End of Cell Renderer Interface ------------------------------- //
	}
}