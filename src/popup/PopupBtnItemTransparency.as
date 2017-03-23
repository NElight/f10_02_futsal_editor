package src.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.buttons.SSPButtonBase;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.models.Equipment;
	
	public class PopupBtnItemTransparency extends SSPButtonBase
	{
		private var item:Equipment;
		
		public function PopupBtnItemTransparency()
		{
			super();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.visible = false;
			this.isToggleButton = true;
		}
		
		public function setItem(itm:Object):void {
			item = itm as Equipment;
			this.buttonSelected = item.transparency;
		}
		
		protected override function onMouseUp(e:MouseEvent):void {
			super.onMouseUp(e);
			if (!item || !item.transparentable) return;
			item.transparency = (!this.isToggled)? true : false;
			// Note that cancel is dispatched by SessionView.
		}
	}
}