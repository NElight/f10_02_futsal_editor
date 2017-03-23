package src3d
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class SSPCursors
	{
		private static var _self:SSPCursors;
		private static var _allowInstance:Boolean = false;
		
		public static const DEFAULT:uint	= 0;
		public static const CROSS:uint		= 1;
		public static const CLONE:uint		= 2;
		public static const PIN:uint		= 3;
		public static const NO:uint			= 4;
		public static const UNDO:uint		= 5;
		public static const REDO:uint		= 6;
		
		private var _ref:Stage;
		private var customCursor:MovieClip;
		private var aCursors:Array;
		
		public function SSPCursors() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():SSPCursors {
			if(_self == null) {
				_allowInstance=true;
				_self = new SSPCursors();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}

		public function initCustomCursors(ref:Stage):void {
			if (!aCursors) {
				aCursors = [new MovieClip(), new cursor_cross(), new cursor_clone(), new cursor_pin(), new cursor_no(), new cursor_undo(), new cursor_redo()];
				_ref = ref;
			}
		}
		
		public function setCursor(cursor:uint):void {
			if (!aCursors) {
				trace("You need to run 'initCustomCursors(stage);' the first time");
				return;
			}
			reset();
			if (cursor == DEFAULT) return;
			customCursor = aCursors[cursor];
			customCursor.mouseEnabled = false;
			customCursor.mouseChildren = false;
			_ref.addChild(customCursor);
			_ref.setChildIndex(customCursor,(_ref.numChildren-1));
			Mouse.hide();
			customCursor.x=_ref.mouseX;
			customCursor.y=_ref.mouseY;
			customCursor.visible = true;
			_ref.addEventListener(MouseEvent.MOUSE_MOVE, moveCursor, false, 0, true);
			_ref.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler, false, 0, true);
			_ref.addEventListener(Event.ADDED, updateStack, false, 0, true);
		}
		
		public function setCross():void {
			this.setCursor(CROSS);
		}
		
		public function setClone():void {
			this.setCursor(CLONE);
		}
		
		public function setPin():void {
			this.setCursor(PIN);
		}
		
		public function setNo():void {
			this.setCursor(NO);
		}
		
		public function setUndo():void {
			this.setCursor(UNDO);
		}
		
		public function setRedo():void {
			this.setCursor(REDO);
		}
		
		private function moveCursor(e:MouseEvent):void {
			customCursor.x=e.stageX;
			customCursor.y=e.stageY;
		}
		
		public function reset(e:SSPEvent = null):void {
			_ref.removeEventListener(MouseEvent.MOUSE_MOVE, mouseReturnHandler);
			_ref.removeEventListener(MouseEvent.MOUSE_MOVE, moveCursor);
			_ref.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			_ref.removeEventListener(Event.ADDED, updateStack);
			for each(var c:MovieClip in aCursors) {
				if (_ref.contains(c)) {
					_ref.removeChild(c);
				}
			}
			Mouse.show();
		}
		
		private function updateStack(e:Event) : void {
			// Place cursor on top of new added movieclips.
			_ref.addChild(customCursor);
		}
		
		private function mouseLeaveHandler(e:Event) : void {
			customCursor.visible = false;
			Mouse.show(); //in case of right click
			_ref.addEventListener(MouseEvent.MOUSE_MOVE, mouseReturnHandler, false, 0, true);
		}
		
		private function mouseReturnHandler(e:Event) : void {
			if (aCursors.indexOf(customCursor) < 1) {
				reset();
				return;
			}
			customCursor.visible = true;
			Mouse.hide(); //in case of right click
			_ref.removeEventListener(MouseEvent.MOUSE_MOVE, mouseReturnHandler);
		}
		
	}
}