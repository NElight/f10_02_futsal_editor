package src.minutes
{
	import fl.controls.Button;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import src.events.SSPMinutesEvent;
	import src.popup.MessageBox;
	import src.popup.PopupBox;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class MinutesClockConfirm extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		private var _stage:Stage;
		private var sScreen:SessionScreen;
		private var btnOK:Button;
		private var btnCancel:Button;
		private var txtAction:TextField;
		private var txtEditMinutes:TextField;
		private var txtEditSeconds:TextField;
		private var validMinutes:Boolean;
		private var validSeconds:Boolean;
		private var strMinutesEvent:String = "";
		private var strOldMinutes:String = "000";
		private var strOldSeconds:String = "00";
		
		private var intTimeInSeconds:int = -1;
		
		public function MinutesClockConfirm(st:Stage)
		{
			super();
			this._stage = st;
			initControls();
			initListeners();
		}
		
		public function setData(sScreen:SessionScreen, strMinutesEvent:String, strActionHTML:String, strMinutes:String, strSeconds:String):void {
			this.sScreen = sScreen;
			this.strMinutesEvent = strMinutesEvent;
			//var tf:TextFormat = new TextFormat();
			//tf.align = "center";
			//txtAction.setTextFormat(tf);
			//txtAction.text = "Hola";
			txtAction.htmlText = strActionHTML;
			txtEditMinutes.text = strMinutes;
			txtEditSeconds.text = strSeconds;
			startEditTime();
		}
		
		private function onOK(e:MouseEvent):void {
			sendData();
		}
		
		private function onCancel(e:MouseEvent):void {
			closePopup();
		}
		
		private function sendData():void {
			var validated:Boolean = validateTime();
			if (!validated) {
				main.msgBox.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesGeneralTimeError.text());
				return;
			}
			var popupForm:MinutesClockConfirmPopupBox = this.parent.parent as MinutesClockConfirmPopupBox;
			if (!popupForm) return;
			popupForm.dispatchEvent(new SSPMinutesEvent(strMinutesEvent, intTimeInSeconds.toString()));
			closePopup();
		}
		
		private function removeListeners():void {
			
		}
		
		private function closePopup():void {
			stopEditTime();
			removeListeners();
			var popupForm:PopupBox = this.parent.parent as PopupBox;
			if (!popupForm) return;
			popupForm.popupVisible = false;
		}
		
		
		
		// ----------------------------- Inits ----------------------------- //
		private function initControls():void {
			btnOK = this.buttonOK;
			btnOK.useHandCursor = true;
			btnOK.label = sG.interfaceLanguageDataXML.buttons._btnInterfaceOk.text();
			btnOK.drawNow();
			btnOK.addEventListener(MouseEvent.CLICK, onOK);
			
			btnCancel = this.buttonCancel;
			btnCancel.useHandCursor = true;
			btnCancel.label = sG.interfaceLanguageDataXML.buttons._btnInterfaceCancel.text();
			btnCancel.drawNow();
			btnCancel.addEventListener(MouseEvent.CLICK, onCancel);
			
			txtAction = this.textAction;
			txtEditMinutes = this.textEditMinutes;
			txtEditSeconds = this.textEditSeconds;
			
			txtEditMinutes.maxChars = MinutesGlobals.MAX_CHAR_MINUTES;
			txtEditSeconds.maxChars = MinutesGlobals.MAX_CHAR_SECONDS;
			
			txtEditMinutes.restrict = "0-9";
			txtEditSeconds.restrict = "0-9";
			
			txtEditMinutes.tabIndex = 0;
			txtEditSeconds.tabIndex = 1;
			btnOK.tabIndex = 2;
			btnCancel.tabIndex = 3;
		}
		
		private function initListeners():void {}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Clock Edit ----------------------------- //
		private function startEditTime():void {
			_stage.focus = this;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, false, 0, true);
			sspEventHandler.addEventListener(SSPEvent.KEY_DOWN, onKeyDownHandler);
			sspEventHandler.addEventListener(SSPEvent.KEY_UP, onKeyUpHandler);
			_stage.focus = txtEditMinutes;
			txtEditMinutes.setSelection(0, txtEditMinutes.length);
			txtEditMinutes.addEventListener(Event.CHANGE, onTextFieldChange, false, 0, true);
			txtEditSeconds.addEventListener(Event.CHANGE, onTextFieldChange, false, 0, true);
			txtEditMinutes.addEventListener(FocusEvent.FOCUS_IN, onMinutesFocusIn, false, 0, true);
			txtEditSeconds.addEventListener(FocusEvent.FOCUS_IN, onSecondsFocusIn, false, 0, true);
			txtEditMinutes.addEventListener(MouseEvent.MOUSE_UP, onMinutesMouseUp, false, 0, true);
			txtEditSeconds.addEventListener(MouseEvent.MOUSE_UP, onSecondsMouseUp, false, 0, true);
			txtEditMinutes.addEventListener(FocusEvent.FOCUS_OUT, onMinutesFocusOut, false, 0, true);
			txtEditSeconds.addEventListener(FocusEvent.FOCUS_OUT, onSecondsFocusOut, false, 0, true);
		}
		
		private function stopEditTime():void {
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			sspEventHandler.RemoveEvent(SSPEvent.KEY_DOWN);
			sspEventHandler.RemoveEvent(SSPEvent.KEY_UP);
			txtEditMinutes.removeEventListener(Event.CHANGE, onTextFieldChange);
			txtEditSeconds.removeEventListener(Event.CHANGE, onTextFieldChange);
			txtEditMinutes.removeEventListener(FocusEvent.FOCUS_IN, onMinutesFocusIn);
			txtEditSeconds.removeEventListener(FocusEvent.FOCUS_IN, onSecondsFocusIn);
			txtEditMinutes.addEventListener(MouseEvent.MOUSE_UP, onMinutesMouseUp);
			txtEditSeconds.addEventListener(MouseEvent.MOUSE_UP, onSecondsMouseUp);
			txtEditMinutes.removeEventListener(FocusEvent.FOCUS_OUT, onMinutesFocusOut);
			txtEditSeconds.removeEventListener(FocusEvent.FOCUS_OUT, onSecondsFocusOut);
		}
		
		private function onMinutesMouseUp(e:MouseEvent):void {
			if (txtEditMinutes.selectedText == "") txtEditMinutes.setSelection(0, txtEditMinutes.length);
		}
		
		private function onSecondsMouseUp(e:MouseEvent):void {
			if (txtEditSeconds.selectedText == "") txtEditSeconds.setSelection(0, txtEditSeconds.length);
		}
		
		private function onMinutesFocusIn(e:FocusEvent):void {
			trace("confirm.onMinutesFocusIn()");
			txtEditMinutes.setSelection(0, txtEditMinutes.length);
		}
		
		private function onSecondsFocusIn(e:FocusEvent):void {
			trace("confirm.onSecondsFocusIn()");
			txtEditSeconds.setSelection(0, txtEditSeconds.length);
		}
		
		private function onMinutesFocusOut(e:FocusEvent):void {
			trace("confirm.onMinutesFocusOut()");
			txtEditMinutes.text = MiscUtils.addLeadingZeros(txtEditMinutes.text, MinutesGlobals.MAX_CHAR_MINUTES);
		}
		
		private function onSecondsFocusOut(e:FocusEvent):void {
			trace("confirm.onSecondsFocusOut()");
			txtEditSeconds.text = MiscUtils.addLeadingZeros(txtEditSeconds.text, MinutesGlobals.MAX_CHAR_SECONDS);
		}
		
		private function onTextFieldChange(e:Event):void {
			trace("confirm.onTextFieldChange()");
			if (_stage.focus == txtEditMinutes && txtEditMinutes.selectedText.length == 0 &&
				txtEditMinutes.length >= MinutesGlobals.MAX_CHAR_MINUTES) {
				_stage.focus = txtEditSeconds;
				//txtEditSeconds.setSelection(0, txtEditSeconds.length);
			}
		}
		
		private function onKeyDownHandler(e:SSPEvent):void {
			var _lastKey:KeyboardEvent = e.eventData; // Get KeyCode.
			/*if (_lastKey.keyCode == Keyboard.ESCAPE) {
			stopEditTime();
			}*/
			
			if (_lastKey.keyCode == Keyboard.ENTER || _lastKey.keyCode == Keyboard.NUMPAD_ENTER) {
				if (_stage.focus == txtEditMinutes) {
					_stage.focus = txtEditSeconds;
					//txtEditSeconds.setSelection(0, txtEditSeconds.length);
				} else if (_stage.focus == txtEditSeconds || _stage.focus == btnOK) {
					sendData();
				}
				return;
			}
		}
		
		private function onKeyUpHandler(e:SSPEvent):void {
			var _lastKey:KeyboardEvent = e.eventData; // Get KeyCode.
			if (_stage.focus == txtEditSeconds && _lastKey.keyCode == Keyboard.BACKSPACE && txtEditSeconds.length == 0) {
				_stage.focus = txtEditMinutes;
				//txtEditMinutes.setSelection(txtEditMinutes.length, txtEditMinutes.length);
			}
			
			if (_stage.focus == txtEditSeconds && _lastKey.keyCode == Keyboard.LEFT && txtEditSeconds.caretIndex == 0) {
				_stage.focus = txtEditMinutes;
				//txtEditMinutes.setSelection(txtEditMinutes.length, txtEditMinutes.length);
			}
			
			if (_stage.focus == txtEditMinutes && _lastKey.keyCode == Keyboard.RIGHT && txtEditMinutes.caretIndex == txtEditMinutes.length) {
				_stage.focus = txtEditSeconds;
				//txtEditSeconds.setSelection(0, 0);
			}
		}
		
		private function onStageMouseDown(e:MouseEvent):void {
//			if (e.target == txtEditMinutes || e.target == txtEditSeconds) return;
//			validateTime();
		}

		private function validateTime():Boolean {
			validMinutes = validateMinutes();
			validSeconds = validateSeconds();
			if (validMinutes && validSeconds) {
				//_stage.focus = null;
				var minToSec:int = int(txtEditMinutes.text) * 60;
				intTimeInSeconds = minToSec + int(txtEditSeconds.text);
				var intStopTime:int = int(sScreen.periodMinutes.periodStopTime);
				var intStartTime:int = int(sScreen.periodMinutes.periodStartTime);
				if (intTimeInSeconds <= 0 || intTimeInSeconds <= intStartTime || (intStopTime > 0 && intTimeInSeconds > intStopTime)) {
					intTimeInSeconds = -1;
					return false;
				}
				return true;
			} else {
				_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				showInvalidTimeMessage();
			}
			return false;
		}
		
		private function validateMinutes():Boolean {
			var strText:String = MiscUtils.addLeadingZeros(txtEditMinutes.text, MinutesGlobals.MAX_CHAR_MINUTES);
			var strPat:String = "[0-9][0-9][0-9]"; // Valid values: 9 or 99 or 999.
			var regEx:RegExp = new RegExp(strPat);
			var result:Object = regEx.exec(strText);
			return (result)? true : false;
		}
		
		private function validateSeconds():Boolean {
			var strText:String = MiscUtils.addLeadingZeros(txtEditSeconds.text, MinutesGlobals.MAX_CHAR_SECONDS);
			var strPat:String = "[0-5][0-9]"; // Valid values: 59 or 9.
			var regEx:RegExp = new RegExp(strPat);
			var result:Object = regEx.exec(strText);
			return (result)? true : false;
		}
		// -------------------------- End of Clock Edit ------------------------- //
		
		
		
		// ----------------------------- Error Message Box ----------------------------- //
		private function showInvalidTimeMessage():void {
			var strMsg:String = sG.interfaceLanguageDataXML.messages._msgErrorTimeFormat.text();
			main.msgBox.popupEnabled = true;
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onErrorMsgBoxOk, false, 0, true);
			main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK);
		}
		
		private function removeErrorMsgBox():void {
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onErrorMsgBoxOk);
			main.msgBox.popupVisible = false;
		}
		
		private function onErrorMsgBoxOk(e:Event):void {
			removeErrorMsgBox();
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, false, 0, true);
			if (!validMinutes) {
				_stage.focus = txtEditMinutes;
				//txtEditMinutes.setSelection(0, txtEditMinutes.length);
			} else if (!validSeconds) {
				_stage.focus = txtEditSeconds;
				//txtEditSeconds.setSelection(0, txtEditSeconds.length);
			}
			// Do nothing.
		}
		// -------------------------- End of Error Message Box ------------------------- //
	}
}