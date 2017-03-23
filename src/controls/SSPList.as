package src.controls
{
	import fl.controls.List;
	
	import flash.events.KeyboardEvent;
	
	public class SSPList extends List
	{
		private var _useKeyboard:Boolean = false;
		
		public function SSPList()
		{
			super();
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			if (_useKeyboard) {
				super.keyDownHandler(event);
			} else {
				// Do not use keyboard control and Avoids call to 'event.stopPropagation()', which prevents stage of receiving the keyboard event.
			}
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if (_useKeyboard) {
				super.keyUpHandler(event);
			} else {
				// Do not use keyboard control and Avoids call to 'event.stopPropatation()', which prevents stage of receiving the keyboard event.
			}
		}

		public function get useKeyboard():Boolean
		{
			return _useKeyboard;
		}

		public function set useKeyboard(value:Boolean):void
		{
			_useKeyboard = value;
		}

	}
}