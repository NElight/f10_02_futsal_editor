package src.popup {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
    public class ScribblePad extends MovieClip {
		private var _ref:main;
		private var padContainer:MovieClip;
		// flag for drawing
        private var isDrawing:Boolean;
		private var padOffsetY:Number;
		private var padOffsetX:Number;
		
		public function ScribblePad(ref:main,padContainer:MovieClip,padYOffset:Number) {
			_ref = ref;
			this.padContainer = padContainer;
			this.name = "ssp_pad";
			padOffsetX = padContainer.x = 0;
			padOffsetY = padContainer.y = padYOffset;
		}
		
        public function initPad() {
			this.graphics.clear();
			// set line style - line width and line color
			this.graphics.lineStyle(3,0xFFF000);
			padContainer.addChild(this);
			_ref.bringPadContainerToFront();
            // set drawing flag to false
            isDrawing = false;
            // When mouse down start drawing
            this.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
            // When mouse move continue drawing
            this.addEventListener(MouseEvent.MOUSE_MOVE, draw);
            // When mouse up stop drawing
            this.addEventListener(MouseEvent.MOUSE_UP, onStopDrawing);
			_ref.stage.addEventListener(MouseEvent.MOUSE_UP, onStopDrawing);
			_ref.stage.addEventListener(KeyboardEvent.KEY_UP, key_up);
        }
		
        public function startDrawing(event:MouseEvent):void {
            //starting point is where mouse pressed
            this.graphics.moveTo( mouseX-padContainer.x, mouseY-padContainer.y);
            isDrawing = true;
        }
		
        public function draw(event:MouseEvent) {
            if (isDrawing) {
                this.graphics.lineTo(mouseX-padContainer.x,mouseY-padContainer.y);
            }
        }
		
        public function onStopDrawing(event:MouseEvent) {
			stopDrawing();
        }
		
		public function stopDrawing() {
			isDrawing = false;
		}
		
		public function clearDrawing():void {
			removeEvents();
			padContainer.removeChild(this);
			this.graphics.clear();
		}
		
		private function removeEvents():void {
			_ref.stage.removeEventListener(MouseEvent.MOUSE_DOWN, clearDrawing);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, draw);
			this.removeEventListener(MouseEvent.MOUSE_UP, onStopDrawing);
			_ref.stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrawing);
			_ref.stage.removeEventListener(KeyboardEvent.KEY_UP, key_up);
		}
		
		private function key_up(e:KeyboardEvent):void {
			switch(e.keyCode){
				case Keyboard.ESCAPE:
					// Tells header to stop this and reset buttons.
//e					_ref._header.padEnabled(false);
			}
		}
    }
}