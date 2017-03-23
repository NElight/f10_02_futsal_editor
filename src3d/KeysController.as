package src3d
{
	import fl.core.UIComponent;
	
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import src3d.utils.EventHandler;

	public class KeysController {
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		public function KeysController() {
			sspEventHandler = new EventHandler(SSPEventDispatcher.getInstance());
			initListeners();
			sG.sScreenKeysEnabled = true;
		}
		
		private function initListeners():void {
			stopListeners();
			sspEventHandler.addEventListener(SSPEvent.KEY_DOWN, onKeyDownHandler); // includes: key code.
			sspEventHandler.addEventListener(SSPEvent.KEY_UP, onKeyUpHandler); // includes: key code.
		}
		
		private function stopListeners():void {
			sspEventHandler.RemoveEvents();
		}
		
		private function onKeyDownHandler(e:SSPEvent):void {
			//trace("KeysController.onKeyDownHandler()");
			if (!sG.sScreenKeysEnabled) return;
			//if (e.eventData.target is TextField || e.eventData.target is UIComponent) return;
			if (e.eventData.target is TextField) return;
			if (main.stage.focus) {
				if (main.stage.focus is TextField) return;
				//trace("Focus on: "+main.stage.focus.name);
				if (main.stage.focus.name == "commentsField") return;
			}
			var _lastKey:KeyboardEvent = e.eventData;
			switch(_lastKey.keyCode){
				case Keyboard.DELETE:
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_DELETE,e.eventData));
					break;
				case Keyboard.BACKSPACE:
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_DELETE,e.eventData));
					break;
				case Keyboard.ESCAPE:
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, null));
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_BY_CLONING, false));
					break;
				case Keyboard.UP:
					if (_lastKey.ctrlKey) {
						sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_ZOOM_IN,true));
						break;
					}
					if (_lastKey.shiftKey) {
						sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_UP,true));
					}
					break;
				case Keyboard.DOWN:
					if (_lastKey.ctrlKey) {
						sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_ZOOM_OUT,true));
						break;
					}
					if (_lastKey.shiftKey) {
						sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_DOWN,true));
					}
					break;
				case Keyboard.LEFT:
					if (_lastKey.ctrlKey) {
						sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_LEFT,true));
					}
					break;
				case Keyboard.RIGHT:
					if (_lastKey.ctrlKey) {
						sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_RIGHT,true));
					}
					break;
			}
		}
		
		private function onKeyUpHandler(e:SSPEvent):void {sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CAMERA_STOP_MOVING, true));}
		
		/*public function enableKeys():void {
			sG.sScreenKeysEnabled = true;
			initListeners();
		}
		public function disableKeys():void {
			sG.sScreenKeysEnabled = false;
			stopListeners();
		}*/
	}
}