package src.controls.datechooser
{
	import fl.controls.Label;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	import src.popup.MessageBox;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.utils.MiscUtils;
	
	public class SSPDateChooser extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		private var _calendar:SSPCalendar;
		private var _lblLabel:TextField;
		private var _txtDateTime:TextField;
		private var _txtMessage:TextField;
		private var _btnCalendar:SimpleButton;
		private var _btnCalendarDelete:SimpleButton;
		
		private var labelWidth:uint = 178;
		private var txtWidth:uint = 150;
		private var txtHeight:uint = 22;
		private var msgColorWarning:uint = 0xFF9900;
		private var msgColorError:uint = 0xFF0000;
		
		private var lblTextFormat:TextFormat;
		
		public function SSPDateChooser()
		{
			super();
			initLabel();
			initTextField();
			initBtnCalendar();
			initBtnCalendarDelete();
			updateLayout();
			initCalendar();
			initToolTips();
		}
		
		// ----------------------------- Inits ----------------------------- //
		private function initLabel():void {
			_lblLabel = MiscUtils.createNewLabel(0,0,labelWidth,12);
			_lblLabel.text = "label";
			lblTextFormat = new TextFormat(SSPSettings.DEFAULT_FONT, 12);
			this.addChild(_lblLabel);
		}
		
		public function initTextField():void
		{
			// Message TextField.
			_txtMessage = MiscUtils.createNewTextField(0, 0, txtWidth, txtHeight, TextFieldType.DYNAMIC, false, false, false, 11 , msgColorWarning);
			_txtMessage.text = ""
			this.addChild(_txtMessage);
			
			// Main TextField.
			_txtDateTime = MiscUtils.createNewTextField(0, 0, txtWidth, txtHeight, TextFieldType.DYNAMIC, false, false, true, 12);
			_txtDateTime.name = "screenTitle";
			_txtDateTime.text = "";
			this.addChild(_txtDateTime);
			_txtDateTime.addEventListener(MouseEvent.CLICK, onTxtFieldClick, false, 0, true);
		}
		
		private function initBtnCalendar():void {
			//_btnCalendar = new SSPButtonBase();
			_btnCalendar = new btnSSPCalendar();
			_btnCalendar.addEventListener(MouseEvent.CLICK, onBtnCalendarClick, false, 0, true);
			this.addChild(_btnCalendar);
		}
		private function initBtnCalendarDelete():void {
			//_btnCalendar = new SSPButtonBase();
			_btnCalendarDelete = new btnSSPCalendarDelete();
			_btnCalendarDelete.width = txtHeight;
			_btnCalendarDelete.height = txtHeight;
			_btnCalendarDelete.addEventListener(MouseEvent.CLICK, onBtnCalendarDeleteClick, false, 0, true);
			this.addChild(_btnCalendarDelete);
		}
		
		private function updateLayout():void {
			_txtDateTime.x = _lblLabel.x + labelWidth;
			_btnCalendarDelete.x = labelWidth + txtWidth - _btnCalendarDelete.width; // Inside the text field.
			_btnCalendarDelete.y = _txtDateTime.y + 3; // Inside the text field.
			_btnCalendar.x = labelWidth + txtWidth + 3; // Next to the text field.
			_btnCalendar.y = _txtDateTime.y;
			_txtMessage.x = _txtDateTime.x;
			_txtMessage.y = _txtDateTime.y + _txtDateTime.height;
		}
		
		private function initCalendar():void {
			if (_calendar) return;
			_calendar = SSPCalendar.getInstance();
		}
		
		private function initToolTips():void {
			// Tooltips.
			var vSettings:Vector.<SSPToolTipSettings> = new Vector.<SSPToolTipSettings>();
			vSettings.push(new SSPToolTipSettings(_btnCalendarDelete, sG.interfaceLanguageDataXML.tags._btnFilingRemoveTime.text()));
			SSPToolTip.getInstance().addToolTips(vSettings);
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Confirmations ----------------------------- //
		protected function onBtnCalendarDeleteClick(e:MouseEvent):void {
			// Ask for user confirmation.
			var strMsg:String = sG.interfaceLanguageDataXML.messages._interfaceAreYouSure.text();
			main.msgBox.popupEnabled = true;
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onConfirmOK, false, 0, true);
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onConfirmCancel, false, 0, true);
			main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK_CANCEL);
		}
		
		private function onConfirmOK(e:Event):void {
			removeMsgBox();
			resetCalendar();
		}
		
		private function onConfirmCancel(e:Event):void {
			removeMsgBox();
		}
		
		private function removeMsgBox():void {
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onConfirmOK);
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onConfirmCancel);
			main.msgBox.popupVisible = false;
		}
		// -------------------------- End of Confirmations ------------------------- //
		
		
		
		private function updateControls(calDate:Date, notify:Boolean):Boolean {
			if (!calDate) {
				_txtMessage.text = "";
				return false;
			}
			var todayDate:Date = new Date();
			var validDate:Boolean = true;
			if (!_calendar.hasDefaultDate) {
				if (calDate.getTime() < todayDate.getTime()) {
					_txtMessage.textColor = msgColorWarning;
					_txtMessage.text = sG.interfaceLanguageDataXML.messages._filingWarningPastTime.text();
				} else if (calDate.hours == 0 && calDate.minutes == 0) {
					_txtMessage.textColor = msgColorWarning;
					_txtMessage.text = sG.interfaceLanguageDataXML.messages._filingWarningMidnight.text();
				} else {
					_txtMessage.text = "";
				}
			} else {
				if (sG.sessionTypeIsMatch && sG.usePlayerRecords) {
					validDate = false
					_txtMessage.textColor = msgColorError;
					_txtMessage.text = sG.interfaceLanguageDataXML.messages._filingErrorDateTimeMandatory.text();;
				} else {
					_txtMessage.textColor = msgColorWarning;
					_txtMessage.text = "";
				}
			}
			
			updateDeleteButton();
			if (notify) notifyCalendarChange();
			return validDate;
		}
		
		private function updateDeleteButton():void {
			if (!_calendar) initCalendar();
			if (!_calendar.hasDefaultDate) {
				_btnCalendarDelete.visible = true;
			} else {
				_btnCalendarDelete.visible = false;
			}
		}
		
		private function notifyCalendarChange():void {
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onTxtFieldClick(e:MouseEvent):void {
			showCalendar();
		}
		
		private function onBtnCalendarClick(e:MouseEvent):void {
			showCalendar();
		}
		
		private function showCalendar():void {
			if (!_calendar) initCalendar();
			if (!_calendar.hasEventListener(SSPEvent.CONTROL_CHANGE)) {
				_calendar.addEventListener(SSPEvent.CONTROL_CHANGE, onCalendarChange, false, 0, true);
			}
			if (!_calendar.hasEventListener(SSPEvent.CONTROL_CLOSE)) {
				_calendar.addEventListener(SSPEvent.CONTROL_CLOSE, onCalendarClose, false, 0, true);
			}
			var gPos:Point = this.localToGlobal(new Point(_btnCalendar.x+_btnCalendar.width, _txtDateTime.y+_txtDateTime.height));
			_calendar.showCalendar(gPos.x, gPos.y, true);
		}
		
		private function onCalendarChange(e:SSPEvent):void {
			var strDate:SSPCalendarSettings = e.eventData as SSPCalendarSettings;
			if (strDate) {
				_txtDateTime.text = strDate.getDateTimeForCalendar();
			}
			updateControls(strDate.getCalendarDateTime(), true);
		}
		
		private function onCalendarClose(e:SSPEvent):void {
			_calendar.removeEventListener(SSPEvent.CONTROL_CHANGE, onCalendarChange);
			_calendar.removeEventListener(SSPEvent.CONTROL_CLOSE, onCalendarClose);
		}
				
		public function setMySQLString(mysqlDate:String):void {
			if (!_calendar) initCalendar();
			_calendar.setMySQLDate(mysqlDate);
			if (!_calendar.hasDefaultDate) {
				_txtDateTime.text = _calendar.getDateTimeForCalendar();
			}
			updateControls(_calendar.calendarDateTime, true);
		}
		
		public function getMySQLDate():String {
			return _calendar.getDateTimeForServer();
		}
		
		public function hasValidDate():Boolean {
			return updateControls(_calendar.calendarDateTime, false);
		}
		
		private function resetCalendar():void {
			_calendar.resetCalendar();
			_txtDateTime.text = _calendar.getDateTimeForCalendar();
			updateControls(_calendar.calendarDateTime, true);
		}
		
		public function get label():String {
			return _lblLabel.text;
		}
		public function set label(value:String):void {
			_lblLabel.text = value;
		}
		public function get htmlLabel():String {
			return _lblLabel.htmlText;
		}
		public function set htmlLabel(value:String):void {
			_lblLabel.htmlText = value;
			_lblLabel.setTextFormat(lblTextFormat);
		}
	}
}