package src
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.utils.Logger;

	public class StageManager
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:StageManager;
		private static var _allowInstance:Boolean = false;
		
		public function StageManager()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():StageManager
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new StageManager();
				_allowInstance=false;
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var m:main;
		private var st:Stage;
		private var lastDisplayState:String = "";
		
		public function initialize(m:main):void {
			this.m = m;
			this.st = m.stage;
			st.scaleMode = StageScaleMode.SHOW_ALL;
			//st.align = StageAlign.TOP;
			//st.addEventListener(Event.RESIZE, onStageResizeHandler, true);
			st.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
		}
		
		private function onStageResizeHandler(e:Event):void {
			notifyStageSizeChange(st.displayState);
		}
		
		private function onStageKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ESCAPE) notifyStageSizeChange(st.displayState);
		}
		
		private function notifyStageSizeChange(newDisplayState:String):void {
			if (lastDisplayState == newDisplayState) return;
			lastDisplayState = newDisplayState;
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.STAGE_RESIZE, newDisplayState));
		}
		
		private function onFullScreenInteractiveAccepted(e:FullScreenEvent):void {
			if (e.fullScreen && e.interactive) {
				Logger.getInstance().addUser("User accepted Full Screen Interactive.");
			}
		}
		
		/**
		 * Toggles the Stage size (Stage.displayState) and returns the <code>StageDisplayState</code> value.
		 * @return String.
		 * @see <code>StageDisplayState</code>
		 */		
		public function toggleStageSize():String {
			//st.scaleMode = StageScaleMode.SHOW_ALL;
			//st.scaleMode = StageScaleMode.NO_SCALE; // Needed to detect stage display changes.
			if (st.displayState == StageDisplayState.NORMAL) {
				m._comments.editorEnabled = false;
				try {
					if (!st.hasEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED)) {
						st.addEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, this.onFullScreenInteractiveAccepted);
					}
					st.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					Logger.getInstance().addInfo("Screen changed to Full Screen Interactive.");
				} catch(error:Error) {
					st.displayState = StageDisplayState.FULL_SCREEN;
					Logger.getInstance().addAlert("Screen changed to Full Screen. Interactive not supported.");
				}
			} else {
				m._comments.editorEnabled = true;
				st.displayState = StageDisplayState.NORMAL;
				Logger.getInstance().addInfo("Screen changed to Normal Screen.");
			}
			notifyStageSizeChange(st.displayState);
			return st.displayState;
		}
		
		public function get isFullScreen():Boolean {
			return (st.displayState == StageDisplayState.FULL_SCREEN || st.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)? true : false;
		}
		
		public function get isFullScreenInteractive():Boolean {
			return (st.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)? true : false;
		}
	}
}