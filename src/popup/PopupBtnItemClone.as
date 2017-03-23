package src.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.buttons.SSPButtonBase;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	
	public class PopupBtnItemClone extends SSPButtonBase
	{
		public function PopupBtnItemClone()
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
				//trace("Clone.onMouseUp()");
				SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_BY_CLONING, true));
			}
			// Note that cancel is dispatched by SessionView.
		}
	}
}