package src.popup
{
	import fl.controls.CheckBox;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.models.Equipment;
	
	public class PopupBtnItemColor extends PopupBtnBase
	{
		// aColors array order must match flash buttons names.
		private var aColors:Array = [0xE6E6E6, 0x00FFFF, 0x2F2FFB, 0x9A30FC, 0x00FF00, 0xFFFF00, 0xFC9630, 0xFF0000, 0xFFCCEE, 0x990000, 0x009900, 0x333333];
		private var _selectedColor:uint;
		private var cbxSemiTransparent:CheckBox;
		private var item:Equipment;
		public function PopupBtnItemColor()
		{
			super();
		}
		
		protected override function init():void {
			super.init();
			popupMc = this.mcPopup;
			popupMc.visible = false;
			popupBtn = this.btnButton;
			cbxSemiTransparent = popupMc.cbSemiTransparent;
			cbxSemiTransparent.addEventListener(Event.CHANGE, onSemiTransparentChange, false, 0, true);
			
			var myTf:TextFormat = new TextFormat(); 
			myTf.size = 9; 
			myTf.color = 0xDDDDDD; 
			cbxSemiTransparent.setStyle("textFormat", myTf);
			cbxSemiTransparent.label = SessionGlobals.getInstance().interfaceLanguageDataXML.menu[0]._optionSemiTransparent.text();
		}
		
		protected override function onPopupClick(e:MouseEvent):void {
			super.onPopupClick(e);
			
			// Get the index from the button name (btn_00, btn_01, etc).
			var btnName:String = String(e.target.name).substr(0, 4);
			if (btnName != "btn_") return;
			var btnIdx:int = int(String(e.target.name).slice(4));
			_selectedColor = aColors[btnIdx];
			trace("Equipment Color: "+_selectedColor);
			// Dispatch Equipment Color Event.
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CONTROL_COLOR_CHANGE,_selectedColor));
		}
		
		private function onSemiTransparentChange(e:Event):void {
			// Fire semi transparent event.
			item.transparency = cbxSemiTransparent.selected;
		}
		
		public function setItem(itm:Object):void {
			if (!itm) return;
			item = itm as Equipment;
			if (item.transparentable) {
				cbxSemiTransparent.enabled = true;
				cbxSemiTransparent.visible = true;
				cbxSemiTransparent.selected = item.transparency;
			} else {
				cbxSemiTransparent.enabled = false;
				cbxSemiTransparent.visible = false;
			}
			
		}
		
		public function set selectedColor(col:uint):void {
			_selectedColor = col;
		}
	}
}