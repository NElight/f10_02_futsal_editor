package src3d.text
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	public class MCChar2Control extends MovieClip
	{
		public function MCChar2Control()
		{
			init();
		}
		
		private function init():void {
			// Hide dragable mc.
			mcChar2Custom.visible = false;
			
			// Add buttons listeners.
			btnAddEnabled(true);
			btnClearEnabled(false);
			
			// Add text field listeners.
			txtFieldSource.addEventListener(KeyboardEvent.KEY_UP, onTextFieldKeyUp);
			txtFieldSource.addEventListener(Event.CHANGE, onTextFieldChange);
		}
		
		private function onAddText(e:MouseEvent = null):void {
			var txt:String = txtFieldSource.text.substr(0,2);
			if (txt == "" || txt == " " || txt == "  ") {
				txtFieldSource.text = "";
				return;
			}
			btnAddEnabled(false);
			btnClearEnabled(true);
			mcChar2Custom.updateText(txt);
			mcChar2Custom.visible = true;
			txtFieldSource.visible = false;
		}
		
		private function onClearText(e:MouseEvent):void {
			btnClearEnabled(false);
			btnAddEnabled(true);
			txtFieldSource.text = "";
			txtFieldSource.visible = true;
			mcChar2Custom.visible = false;
		}
		
		private function btnAddEnabled(enabled:Boolean):void {
			if (!enabled) {
				btnAdd.removeEventListener(MouseEvent.CLICK, onAddText);
				btnAdd.visible = false;
			} else {
				btnAdd.addEventListener(MouseEvent.CLICK, onAddText);
				btnAdd.visible = true;
			}
		}
		
		private function btnClearEnabled(enabled:Boolean):void {
			if (!enabled) {
				btnClear.removeEventListener(MouseEvent.CLICK, onClearText);
				btnClear.visible = false;
			} else {
				btnClear.addEventListener(MouseEvent.CLICK, onClearText);
				btnClear.visible = true;
			}
		}
		
		private function onTextFieldChange(event:Event):void {
			// If text has 2 chars already.
			if (txtFieldSource.length >= 2) {
				onAddText();
				return;
			}
		}
		
		private function onTextFieldKeyUp(event:KeyboardEvent):void {
			// If text has 2 chars already.
			if (txtFieldSource.length == 1 && event.charCode == Keyboard.ENTER) {
				onAddText();
				return;
			}
		}
	}
}