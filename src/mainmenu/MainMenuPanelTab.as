package src.mainmenu
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src.buttons.SSPButtonBase;
	
	import src3d.SSPEvent;
	
	public class MainMenuPanelTab extends SSPButtonBase
	{
		protected var btnLabel:TextField;
		
		public function MainMenuPanelTab()
		{
			super();
			this.isToggleButton = true;
			btnLabel = this.txtLabel;
			this.initLabel();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.buttonEnabled = true;
			//initLabel();
		}
		
		protected function initLabel():void {
			//btnLabel = this.txtLabel;
			this.visible = true;
			btnLabel.visible = true;
		}
		
		protected override function onClick(e:MouseEvent):void {
			super.onClick(e);
			this.dispatchEvent(new SSPEvent(SSPEvent.MAIN_MENU_PANEL_TAB_CLICK));
		}
		
		public function set label(strLabel:String):void {
			btnLabel.text = strLabel;
		}
		public function get label():String {
			return btnLabel.text;
		}
	}
}