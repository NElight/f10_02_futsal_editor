package src.buttons
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	
	public class SSPButtonBase extends MovieClip
	{
		protected const UP:uint = 1;
		protected const OVER:uint = 2;
		protected const DOWN:uint = 3;
		protected const SELECTED:uint = 4;
	
		protected var _isToggleButton:Boolean = false;
		protected var isToggled:Boolean = false;
		protected var _buttonLocked:Boolean = false;
		
		protected var vTooltipSettings:Vector.<SSPToolTipSettings>;
		
		public function SSPButtonBase()
		{
			stop();
			this.visible = true;
			this.useHandCursor = true;
			//this.buttonMode = true;
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function set buttonEnabled(be:Boolean):void {
			if (_buttonLocked) return;
			if (be) {
				toggleListeners(true);
				this.visible = true;
			} else {
				toggleListeners(false);
				this.buttonSelected = false;
				this.visible = false;
				//this.gotoAndStop(UP);
			}
		}
		
		protected function toggleListeners(lEnabled:Boolean):void {
			if (lEnabled) {
				toggleListeners(false);
				this.addEventListener(MouseEvent.CLICK, onClick);
				this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			} else {
				this.removeEventListener(MouseEvent.CLICK, onClick);
				this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
		}
		
		protected function onMouseUp(e:MouseEvent):void {
			if (isToggled) return;
			//trace("SSPButton.onMouseUP()");
			this.gotoAndStop(UP);
		}
		
		protected function onClick(e:MouseEvent):void {
			//trace("SSPButton.onClick()");
			toggleButton();
		}
		
		protected function onMouseOver(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			if (_buttonLocked || isToggled) return;
			//trace("SSPButton.onMouseOver()");
			this.gotoAndStop(OVER);
		}
		
		protected function onMouseDown(e:MouseEvent):void {
			//trace("SSPButton.onMouseDown()");
			hidePopups();
			this.gotoAndStop(DOWN);
		}
		
		protected function onMouseOut(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			if (isToggled) return;
			//trace("SSPButton.onMouseOut()");
			if (this.currentFrame == SELECTED) return;
			this.gotoAndStop(UP);
		}
		
		protected function toggleButton():void {
			if (_buttonLocked) return;
			if (!isToggleButton) return;
			//trace("SSPButton.toggleButton()");
			if (isToggled) {
				this.buttonSelected = false;
			} else {
				this.buttonSelected = true;
			}
		}
		
		public function set buttonSelected(sel:Boolean):void {
			//if (!isToggleButton) return;
			//trace("SSPButton.buttonSelected(): "+sel);
			//if (_buttonLocked) return;
			//if (sG.createMode) return;
			if (!sel) {
				isToggled = false;
				this.gotoAndStop(UP);
			} else {
				isToggled = true;
				this.gotoAndStop(SELECTED);
			}
		}
		public function get buttonSelected():Boolean {return isToggled;}
		
		protected function hidePopups():void {
			// Hide the other popup buttons if any.
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CONTROL_POPUP_VISIBLE, false));
		}
		
		public function set buttonLocked(l:Boolean):void {
			if (l) {
				toggleListeners(false);
				_buttonLocked = true;
			} else {
				_buttonLocked = false;
				toggleListeners(true);
			}
		}
		public function get buttonLocked():Boolean {return _buttonLocked;}
		
		public function set isToggleButton(t:Boolean):void {
			if (!t) this.buttonSelected = false;
			_isToggleButton = t;
		}
		public function get isToggleButton():Boolean { return _isToggleButton; }
		
		public override function gotoAndStop(frame:Object, scene:String=null):void {
			//trace("SSPButton.gotoAndStop(): "+frame);
			super.gotoAndStop(frame, scene);
		}
		
		public function setToolTipText(tooltipText:String):void {
			if (vTooltipSettings || !tooltipText || tooltipText == "") return;
			vTooltipSettings = new Vector.<SSPToolTipSettings>();
			vTooltipSettings.push(new SSPToolTipSettings(this, tooltipText));
			SSPToolTip.getInstance().addToolTips(vTooltipSettings);
		}
		
		public function move(xPos:Number, yPos:Number):void {
			this.x = xPos;
			this.y = yPos;
		}
	}
}