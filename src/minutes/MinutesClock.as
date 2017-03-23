package src.minutes
{
	import fl.controls.DataGrid;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import src.buttons.SSPLabelButton;
	import src.events.SSPMinutesEvent;
	import src.popup.MessageBox;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class MinutesClock extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mG:MinutesGlobals = MinutesGlobals.getInstance();
		private var mM:MinutesManager = MinutesManager.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		// Controls.
		private var txtEditMinutes:TextField;
		private var txtEditSeconds:TextField;
		private var mcEditBg:MovieClip;
		private var btnClock:SSPButtonClock;
		private var btnStartPlay:SSPLabelButton;
		private var btnStopPlay:SSPLabelButton;
		private var btnManualAuto:SSPLabelButton;
		private var _clockEditLocked:Boolean = true;
		
		private var mainDG:DataGrid;
		
		// Time.
		private var strLabelManual:String = "Switch to Manual";
		private var strLabelAuto:String = "Switch to Auto";
		private var validMinutes:Boolean;
		private var validSeconds:Boolean;
		private var timeCounter:int;
		private var timeCounterMax:int;
		private var timer:Timer;
		
		public function MinutesClock()
		{
			super();
			initControls();
			initListeners();
		}
		
		
		
		// ----------------------------- Inits ----------------------------- //
		private function initControls():void {
			var sL:XML = sG.interfaceLanguageDataXML;
			
			txtEditMinutes = this.textEditMinutes;
			txtEditSeconds = this.textEditSeconds;
			mcEditBg = this.mcEditClockBg;
			btnClock = this.buttonClock;
			btnStartPlay = this.buttonStartPlay;
			btnStopPlay = this.buttonStopPlay;
			btnManualAuto = this.buttonManualAuto;
			
			txtEditMinutes.maxChars = MinutesGlobals.MAX_CHAR_MINUTES;
			txtEditSeconds.maxChars = MinutesGlobals.MAX_CHAR_SECONDS;
			txtEditMinutes.visible = false;
			txtEditSeconds.visible = false;
			txtEditMinutes.restrict = "0-9";
			txtEditSeconds.restrict = "0-9";
			mcEditBg.visible = false;
			
			btnClock.labelMinutes = "000";
			btnClock.labelSeconds = "00";
			
			timeCounterMax = 59999; // 999m * 60s = 59940s + 59s = 59999s.
			
			btnStartPlay.label = sL.buttons._btnMinutesClockStart.text();
			btnStopPlay.label = sL.buttons._btnMinutesClockStop.text();
			strLabelManual = sL.buttons._btnMinutesClockManual.text();
			strLabelAuto = sL.buttons._btnMinutesClockAuto.text();
			btnManualAuto.label = strLabelManual;
			
			// Tooltips.
			/*btnClock.setToolTipText("Tooltip");
			btnStartPlay.setToolTipText("Tooltip");
			btnStopPlay.setToolTipText("Tooltip");
			btnManualAuto.setToolTipText("Tooltip");*/
			
			timer = new Timer(1000, 0);
		}
		
		private function initListeners():void {
			btnStartPlay.addEventListener(MouseEvent.CLICK, onStartClick, false, 0, true);
			btnStopPlay.addEventListener(MouseEvent.CLICK, onStopClick, false, 0, true);
			btnManualAuto.addEventListener(MouseEvent.CLICK, onManualAutoClick, false, 0, true);
			btnClock.addEventListener(MouseEvent.CLICK, onManualAutoClick, false, 0, true);
			timer.addEventListener(TimerEvent.TIMER, refreshTimeHandler, false, 0, true);
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Clock Edit ----------------------------- //
		private function startEditTime():void {
			mcEditBg.visible = true;
			txtEditMinutes.visible = true;
			txtEditSeconds.visible = true;
			refreshEditMinutesFromClock();
			stage.focus = txtEditMinutes;
			txtEditMinutes.setSelection(0, txtEditMinutes.length);
			clockEditLocked = false;
		}
		
		private function stopEditTime():void {
			txtEditMinutes.visible = false;
			txtEditSeconds.visible = false;
			mcEditBg.visible = false;
			clockEditLocked = true;
		}
		
		public function get clockEditLocked():Boolean { return _clockEditLocked; }
		public function set clockEditLocked(locked:Boolean):void {
			if (!locked) {
				if (!_clockEditLocked) return;
				_clockEditLocked = false;
				//txtEditMinutes.type = TextFieldType.INPUT;
				//txtEditSeconds.type = TextFieldType.INPUT;
				txtEditMinutes.selectable = true;
				txtEditSeconds.selectable = true;
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, false, 0, true);
				sspEventHandler.addEventListener(SSPEvent.KEY_DOWN, onKeyDownHandler);
				sspEventHandler.addEventListener(SSPEvent.KEY_UP, onKeyUpHandler);
				txtEditMinutes.addEventListener(Event.CHANGE, onTextFieldChange, false, 0, true);
				txtEditSeconds.addEventListener(Event.CHANGE, onTextFieldChange, false, 0, true);
				txtEditMinutes.addEventListener(FocusEvent.FOCUS_IN, onMinutesFocusIn, false, 0, true);
				txtEditSeconds.addEventListener(FocusEvent.FOCUS_IN, onSecondsFocusIn, false, 0, true);
				txtEditMinutes.addEventListener(MouseEvent.MOUSE_UP, onMinutesMouseUp, false, 0, true);
				txtEditSeconds.addEventListener(MouseEvent.MOUSE_UP, onSecondsMouseUp, false, 0, true);
				txtEditMinutes.addEventListener(FocusEvent.FOCUS_OUT, onMinutesFocusOut, false, 0, true);
				txtEditSeconds.addEventListener(FocusEvent.FOCUS_OUT, onSecondsFocusOut, false, 0, true);
			} else {
				_clockEditLocked = true;
				//txtEditMinutes.type = TextFieldType.DYNAMIC;
				//txtEditSeconds.type = TextFieldType.DYNAMIC;
				txtEditMinutes.selectable = false;
				txtEditSeconds.selectable = false;
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
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
		}
		
		private function onMinutesMouseUp(e:MouseEvent):void {
			if (txtEditMinutes.selectedText == "") txtEditMinutes.setSelection(0, txtEditMinutes.length);
		}
		
		private function onSecondsMouseUp(e:MouseEvent):void {
			if (txtEditSeconds.selectedText == "") txtEditSeconds.setSelection(0, txtEditSeconds.length);
		}
		
		private function onMinutesFocusIn(e:FocusEvent):void {
			trace("minutes.onMinutesFocusIn()");
			txtEditMinutes.setSelection(0, txtEditMinutes.length);
		}
		
		private function onSecondsFocusIn(e:FocusEvent):void {
			trace("minutes.onSecondsFocusIn()");
			txtEditSeconds.setSelection(0, txtEditSeconds.length);
		}
		
		private function onMinutesFocusOut(e:FocusEvent):void {
			trace("minutes.onMinutesFocusOut()");
			txtEditMinutes.text = MiscUtils.addLeadingZeros(txtEditMinutes.text, MinutesGlobals.MAX_CHAR_MINUTES);
		}
		
		private function onSecondsFocusOut(e:FocusEvent):void {
			trace("minutes.onSecondsFocusOut()");
			txtEditSeconds.text = MiscUtils.addLeadingZeros(txtEditSeconds.text, MinutesGlobals.MAX_CHAR_SECONDS);
		}
		
		private function onTextFieldChange(e:Event):void {
			trace("minutes.onTextFieldChange()");
			if (stage.focus == txtEditMinutes && txtEditMinutes.selectedText.length == 0 &&
				txtEditMinutes.length >= MinutesGlobals.MAX_CHAR_MINUTES) {
				stage.focus = txtEditSeconds;
				//txtEditSeconds.setSelection(0, txtEditSeconds.length);
			}
		}
		
		private function onKeyDownHandler(e:SSPEvent):void {
			var _lastKey:KeyboardEvent = e.eventData; // Get KeyCode.
			/*if (_lastKey.keyCode == Keyboard.ESCAPE) {
				stopEditTime();
			}*/
			
			if (_lastKey.keyCode == Keyboard.ENTER || _lastKey.keyCode == Keyboard.NUMPAD_ENTER) {
				if (stage.focus == txtEditMinutes) {
					stage.focus = txtEditSeconds;
					//txtEditSeconds.setSelection(0, txtEditSeconds.length);
				} else if (stage.focus == txtEditSeconds) {
					updateTime();
				}
				return;
			}
		}
		
		private function onKeyUpHandler(e:SSPEvent):void {
			var _lastKey:KeyboardEvent = e.eventData; // Get KeyCode.
			if (stage.focus == txtEditSeconds && _lastKey.keyCode == Keyboard.BACKSPACE && txtEditSeconds.length == 0) {
				stage.focus = txtEditMinutes;
				//txtEditMinutes.setSelection(txtEditMinutes.length, txtEditMinutes.length);
			}
			
			if (stage.focus == txtEditSeconds && _lastKey.keyCode == Keyboard.LEFT && txtEditSeconds.caretIndex == 0) {
				stage.focus = txtEditMinutes;
				//txtEditMinutes.setSelection(txtEditMinutes.length, txtEditMinutes.length);
			}
			
			if (stage.focus == txtEditMinutes && _lastKey.keyCode == Keyboard.RIGHT && txtEditMinutes.caretIndex == txtEditMinutes.length) {
				stage.focus = txtEditSeconds;
				//txtEditSeconds.setSelection(0, 0);
			}
		}
		
		private function onStageMouseDown(e:MouseEvent):void {
			if (e.target == txtEditMinutes || e.target == txtEditSeconds) return;
			updateTime();
		}
		
		private function updateTime():void {
			validMinutes = validateMinutes();
			validSeconds = validateSeconds();
			if (validMinutes && validSeconds) {
				//stage.focus = null;
				var minToSec:int = int(txtEditMinutes.text) * 60;
				timeCounter = minToSec + int(txtEditSeconds.text);
				refreshClockButton();
			} else {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				showInvalidTimeMessage();
			}
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
		
		
		
		// ----------------------------- Message Box ----------------------------- //
		private function showInvalidTimeMessage():void {
			var strMsg:String = sG.interfaceLanguageDataXML.messages._msgErrorTimeFormat.text();
			main.msgBox.popupEnabled = true;
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, onMsgBoxRetry, false, 0, true);
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onMsgBoxCancel, false, 0, true);
			main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_RETRY_CANCEL);
		}
		
		private function removeMsgBox():void {
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, onMsgBoxRetry);
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onMsgBoxCancel);
			main.msgBox.popupVisible = false;
		}
		
		private function onMsgBoxCancel(e:Event):void {
			removeMsgBox();
			txtEditMinutes.text = btnClock.labelMinutes;
			txtEditSeconds.text = btnClock.labelSeconds;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, false, 0, true);
		}
		
		private function onMsgBoxRetry(e:Event):void {
			removeMsgBox();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown, false, 0, true);
			if (!validMinutes) {
				stage.focus = txtEditMinutes;
				//txtEditMinutes.setSelection(0, txtEditMinutes.length);
			} else if (!validSeconds) {
				stage.focus = txtEditSeconds;
				//txtEditSeconds.setSelection(0, txtEditSeconds.length);
			}
			// Do nothing.
		}
		// -------------------------- End of Message Box ------------------------- //
		
		
		
		// ----------------------------- Controls ----------------------------- //
		private function onStartClick(e:MouseEvent):void {
			this.dispatchEvent(new SSPMinutesEvent(SSPMinutesEvent.CLICK_START_PLAY));
		}
		
		private function onStopClick(e:MouseEvent):void {
			this.dispatchEvent(new SSPMinutesEvent(SSPMinutesEvent.CLICK_STOP_PLAY));
		}
		
		private function onManualAutoClick(e:MouseEvent):void {
			if (mG.autoMode) {
				switchToManual();
			} else {
				switchToAuto();
			}
		}
		
		public function switchToManual():void {
			mG.autoMode = false;
			updateAutoMode();
		}
		
		public function switchToAuto():void {
			mG.autoMode = true;
			updateAutoMode();
		}
		
		public function clockStart():void {
			btnStartPlay.visible = false;
			btnStopPlay.visible = true;
			if (mG.autoMode) timer.start();
			
		}
		
		public function clockStop():void {
			btnStartPlay.visible = true;
			btnStopPlay.visible = false;
			timer.stop();
		}
		
		private function clockReset():void {
			resetCurrentTime();
			refreshClockButton();
			refreshEditMinutesFromClock();
		}
		
		public function displayStart():void {
			btnStartPlay.visible = true;
			btnStopPlay.visible = false;
		}
		
		public function displayStop():void {
			btnStartPlay.visible = false;
			btnStopPlay.visible = true;
		}
		// -------------------------- End of Controls ------------------------- //
		
		
		// ----------------------------- Timer ----------------------------- //
		private function refreshTimeHandler(event:TimerEvent):void {
			timeCounter++;
			refreshClockButton();
		}
		
		private function refreshClockButton():void {
			if (timeCounter > timeCounterMax) timeCounter = 0;
			btnClock.labelMinutes = mM.getMinutesFromTime(timeCounter);
			btnClock.labelSeconds = mM.getSecondsFromTime(timeCounter);
		}
		
		private function refreshEditMinutesFromClock():void {
			txtEditMinutes.text = btnClock.labelMinutes;
			txtEditSeconds.text = btnClock.labelSeconds;
		}
		
		private function resetCurrentTime():void {
			timeCounter = 0;
		}
		// -------------------------- End of Timer ------------------------- //
		
		
		
		// ----------------------------- Public ----------------------------- //
		public function updateAutoMode():void {
			if (mG.autoMode) {
				btnManualAuto.label = strLabelManual;
				if (mM.playStarted) timer.start();
				stopEditTime();
				btnClock.addEventListener(MouseEvent.CLICK, onManualAutoClick, false, 0, true);
			} else {
				btnManualAuto.label = strLabelAuto;
				btnClock.removeEventListener(MouseEvent.CLICK, onManualAutoClick);
				timer.stop();
				startEditTime();
			}
		}
		
		public function getTimeInSeconds():String {
			return timeCounter.toString();
		}
		
		public function setTimeInSeconds(ts:String):void {
			var newTS:Number = Number(ts);
			if (isNaN(newTS) || newTS < 0) return;
			timeCounter = newTS;
			refreshClockButton();
			refreshEditMinutesFromClock();
		}
		
		public function clockStopAndReset():void {
			clockStop();
			clockReset();
		}
		// -------------------------- End of Public ------------------------- //
		
	}
}