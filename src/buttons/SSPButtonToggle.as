package src.buttons
{
	import flash.events.Event;

	public class SSPButtonToggle extends SSPButtonBase
	{
		public function SSPButtonToggle()
		{
			super();
			_isToggleButton = true;
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.visible = true;
			this.useHandCursor = true;
		}
	}
}