package src.buttons
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	
	public class SSPDualButton extends MovieClip
	{
		protected var btnA:SSPLabelButton;
		protected var btnB:SSPLabelButton;
		
		private var _buttonEnabled:Boolean;
		private var _buttonLocked:Boolean;
		private var _buttonToggle:Boolean;
		private var _buttonSelected:Boolean;
		private var _buttonDual:Boolean;
		private var _buttonBDisplayed:Boolean;
		
		private var vTooltipSettings:Vector.<SSPToolTipSettings>;
		
		public function SSPDualButton(btnA:SSPLabelButton, btnB:SSPLabelButton, newLabel:String = "", buttonEnabled:Boolean = true, isToggleButton:Boolean = false)
		{
			super();
			this.btnA = btnA;
			addBtn(this.btnA);
			this.btnB = btnB;
			if (!this.btnB) {
				buttonDual = false;
			} else {
				buttonDual = true;
				removeBtn(btnB);
			}
			_buttonEnabled = buttonEnabled;
			this.buttonToggle = isToggleButton;
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.buttonEnabled = _buttonEnabled;
		}
		
		protected function set listenersEnabled(lEnabled:Boolean):void {
			if (lEnabled) {
				listenersEnabled = false;
				//btnA.addEventListener(MouseEvent.CLICK, onSubButtonClick, false, 0, true);
				//if (btnB) btnB.addEventListener(MouseEvent.CLICK, onSubButtonClick, false, 0, true);
			} else {
				//btnA.removeEventListener(MouseEvent.CLICK, onSubButtonClick);
				//if (btnB) btnB.removeEventListener(MouseEvent.CLICK, onSubButtonClick);
			}
		}
		
		protected function onSubButtonClick(e:MouseEvent):void {
			//swapButtons();
			//if (_buttonToggle) {
			//	toggleButtons();
			//}
		}
		
		protected function hidePopups():void {
			// Hide popup buttons if any.
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CONTROL_POPUP_VISIBLE, false));
		}
		
		/*protected function toggleButton():void {
			if (_buttonLocked) return;
			if (!_buttonToggle) {
				this.buttonSelected = false;
				return;
			}
			//trace("SSPButton.toggleButton()");
			if (this.buttonSelected) {
				this.buttonSelected = false;
			} else {
				this.buttonSelected = true;
			}
		}*/
		
		/*protected function swapButtons():void {
			if (_buttonLocked || !buttonDual) return;
			if (btnA.visible) {
				removeBtn(btnA);
				if (btnB) addBtn(btnB);
			} else {
				addBtn(btnA);
				if (btnB) removeBtn(btnB);
			}
		}*/
		
		private function addBtn(btn:SSPLabelButton):void {
			if (!btn) return;
			btn.buttonEnabled = true;
			this.addChild(btn);
		}
		
		private function removeBtn(btn:SSPLabelButton):void {
			if (!btn) return;
			btn.buttonEnabled = false;
			if (this.contains(btn)) this.removeChild(btn);
		}
		
		
		
		// ----------------------------- Gettters/Setters ----------------------------- //
		public function get buttonBDisplayed():Boolean {
			return _buttonBDisplayed;
		}
		public function set buttonBDisplayed(value:Boolean):void {
			if (_buttonBDisplayed == value || _buttonLocked || !buttonDual ||!btnB) return;
			_buttonBDisplayed = value;
			if (_buttonBDisplayed) {
				removeBtn(btnA);
				addBtn(btnB);
			} else {
				addBtn(btnA);
				removeBtn(btnB);
			}
		}
		
		public function get buttonEnabled():Boolean {
			return _buttonEnabled;
		}
		public function set buttonEnabled(value:Boolean):void {
			if (_buttonLocked) return;
			_buttonEnabled = value;
			if (_buttonEnabled) {
				listenersEnabled = true;
				this.alpha = 1;
			} else {
				listenersEnabled = false;
				//this.buttonSelected = false;
				this.alpha = .4;
			}
		}
		
		public function set buttonLocked(l:Boolean):void {
			if (l) {
				listenersEnabled = false;
				_buttonLocked = true;
			} else {
				_buttonLocked = false;
				listenersEnabled = true;
			}
		}
		public function get buttonLocked():Boolean {return _buttonLocked;}
		
		public function get buttonToggle():Boolean {
			return _buttonToggle;
		}
		public function set buttonToggle(value:Boolean):void {
			_buttonToggle = value;
			if (!_buttonToggle) this.buttonSelected = false;
			if (btnA) btnA.isToggleButton = _buttonToggle;
			if (btnB) btnB.isToggleButton = _buttonToggle;
		}
		
		public function set buttonSelected(value:Boolean):void {
			//if (!_buttonToggle) return;
			_buttonSelected = value;
			if (_buttonSelected) {
				if (btnA) btnA.buttonSelected = true;
				if (btnB) btnB.buttonSelected = true;
			} else {
				if (btnA) btnA.buttonSelected = false;
				if (btnB) btnB.buttonSelected = false;
			}
		}
		public function get buttonSelected():Boolean {return _buttonSelected;}
		
		public function get buttonDual():Boolean {
			if (!btnA || !btnB) _buttonDual = false;
			return _buttonDual;
		}
		public function set buttonDual(value:Boolean):void {
			if (!btnA || !btnB) value = false;
			_buttonDual = value;
		}
		
		public function get buttonLabel():String { return btnA.label; }
		public function set buttonLabel(value:String):void {
			btnA.label = value;
			if (btnB) btnB.label = value;
		}
		
		public function get buttonLabelHTML():String { return btnA.labelHTML; }
		public function set buttonLabelHTML(value:String):void {
			btnA.labelHTML = value;
			if (btnB) btnB.labelHTML = value;
		}
		
		public function get buttonLabelTextFieldA():TextField {
			return btnA.labelTextField;
		}
		
		public function get buttonLabelTextFieldB():TextField {
			return (btnB)? btnB.labelTextField : null;
		}
		
		public function get buttonCurrentlyEnabled():SSPLabelButton {
			if (btnB && btnB.visible) return btnB;
			return btnA;
		}
		// -------------------------- End of Gettters/Setters ------------------------- //
		
		
		
		// ----------------------------- Public ----------------------------- //
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
		
		public function dispose():void {
			listenersEnabled = false;
			if (vTooltipSettings) SSPToolTip.getInstance().deleteToolTips(vTooltipSettings, true);
			vTooltipSettings = null;
			if (btnA && this.contains(btnA)) this.removeChild(btnA);
			if (btnB && this.contains(btnB)) this.removeChild(btnB);
			btnA = null;
			btnB = null;
			if (this.parent) this.parent.removeChild(this);
		}
		// -------------------------- End of Public ------------------------- //
	}
}