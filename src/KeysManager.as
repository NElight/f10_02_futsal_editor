package src
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;

	public class KeysManager
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:KeysManager;
		private static var _allowInstance:Boolean = false;
		
		public function KeysManager(st:Stage)
		{
			if (!this.st && st) {
				this.st = st;
				st.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDownHandler);
				st.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUpHandler);
			}
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance(st:Stage):KeysManager
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new KeysManager(st);
				_allowInstance=false;
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		private var st:Stage;
		private var aKeys:Array = new Array();
		
		private function onStageKeyDownHandler(e:KeyboardEvent):void {
			if (aKeys.indexOf(e.keyCode) == -1) {
				aKeys.push(e.keyCode);
			}
		}
		
		private function onStageKeyUpHandler(e:KeyboardEvent):void {
			var kIdx:int = aKeys.indexOf(e.keyCode);
			if (kIdx > -1) {
				aKeys.splice(kIdx, 1);
			}
		}
		
		public function isKeyDown(key:int):Boolean {
			return aKeys.indexOf(key) > -1;
		}
	}
}