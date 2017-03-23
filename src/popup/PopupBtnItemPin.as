package src.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.buttons.SSPButtonBase;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	
	public class PopupBtnItemPin extends SSPButtonBase
	{
		public function PopupBtnItemPin()
		{
			super();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.visible = false;
			this.isToggleButton = true;
		}
		
		protected override function onMouseUp(e:MouseEvent):void {
			super.onMouseUp(e);
			if (!this.isToggled) {
				SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.LINE_CREATE_BY_PINNING, true));
			}
			// Note that cancel is dispatched by SessionView.
		}
	}
}