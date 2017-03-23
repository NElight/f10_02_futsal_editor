package  src.controls.datechooser {
	
	import fl.controls.ComboBox;
	import fl.events.SliderEvent;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	
	public class SSPCalendarControls extends SSPCalendarControlsBase {
		
		private var stageEventHandler:EventHandler;
		private var container:Stage;
		private var _calendarRunning:Boolean;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		private var _hasValidDateTime:Boolean;
		
        public function SSPCalendarControls(container:Stage) {
			super("_sans");
			this.container = container;
			stageEventHandler = new EventHandler(this.container);
			addListeners();
			updateLabels();
		}
		
		// ----------------------------- Labels ----------------------------- //
		private function updateLabels():void {
			this.lblTime.text = sG.interfaceLanguageDataXML.titles[0]._filingCalendarTime.text();
			this.lblHour.text = sG.interfaceLanguageDataXML.titles[0]._filingCalendarHour.text();
			this.lblMin.text = sG.interfaceLanguageDataXML.titles[0]._filingCalendarMinute.text();
			this.btnNow.label = sG.interfaceLanguageDataXML.buttons[0]._btnInterfaceNow.text();
			this.btnDone.label =  sG.interfaceLanguageDataXML.buttons[0]._btnInterfaceDone.text();
		}
		// -------------------------- End of Labels ------------------------- //
		
		
		
		// ----------------------------- Events ----------------------------- //
		private function addListeners():void {
			for each(var t:TextField in aDateCells) {
				t.addEventListener(MouseEvent.MOUSE_DOWN, onDateMouseDown, false, 0, true);
				t.addEventListener(MouseEvent.MOUSE_OVER, onDateMouseOver, false, 0, true);
				t.addEventListener(MouseEvent.MOUSE_OUT, onDateMouseOut, false, 0, true);
			}
			cbxMonth.addEventListener(Event.CHANGE, onMonthSelect, false, 0, true);
			nmsYear.addEventListener(Event.CHANGE, onYearSelect, false, 0, true);
			sldHour.addEventListener(SliderEvent.THUMB_DRAG, onSliderDrag, false, 0, true);
			sldHour.addEventListener(SliderEvent.CHANGE, onSliderChange, false, 0, true);
			sldMin.addEventListener(SliderEvent.THUMB_DRAG, onSliderDrag, false, 0, true);
			sldMin.addEventListener(SliderEvent.CHANGE, onSliderChange, false, 0, true);
			btnNow.addEventListener(MouseEvent.CLICK, onBtnNowClick, false, 0, true);
			btnDone.addEventListener(MouseEvent.CLICK, onBtnDoneClick, false, 0, true);
			stageEventHandler.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDownHandler, false, 0, true);
		}
		private function removeListeners():void {
			for each(var t:TextField in aDateCells) {
				t.removeEventListener(MouseEvent.MOUSE_DOWN, onDateMouseDown);
				t.removeEventListener(MouseEvent.MOUSE_OVER, onDateMouseOver);
				t.removeEventListener(MouseEvent.MOUSE_OUT, onDateMouseOut);
			}
			cbxMonth.removeEventListener(Event.CHANGE, onMonthSelect);
			nmsYear.removeEventListener(Event.CHANGE, onYearSelect);
			sldHour.removeEventListener(SliderEvent.THUMB_DRAG, onSliderDrag);
			sldHour.removeEventListener(SliderEvent.CHANGE, onSliderChange);
			sldMin.removeEventListener(SliderEvent.THUMB_DRAG, onSliderDrag);
			sldMin.removeEventListener(SliderEvent.CHANGE, onSliderChange);
			stageEventHandler.RemoveEvents();
		}
		
		private function onSliderDrag(e:SliderEvent):void {
			calSettings.calendarHours = sldHour.value;
			calSettings.calendarMinutes = sldMin.value;
			updateCalendarTime();
			calendarToUser();
			notifyChange();
		}
		
		private function onSliderChange(e:SliderEvent):void {
			calSettings.calendarHours = sldHour.value;
			calSettings.calendarMinutes = sldMin.value;
			updateCalendarTime();
			calendarToUser();
			notifyChange();
		}
		
		private function onMonthSelect(e:Event):void {
			calSettings.calendarMonth = ComboBox(e.target).selectedItem.data;
			updateMonth();
			calendarToUser();
			notifyChange();
		}
		
		private function onYearSelect(e:Event):void	{
			calSettings.calendarFullYear = e.target.value;
			updateMonth();
			calendarToUser();
			notifyChange();
		}
		
		private function onDateMouseOver(e:MouseEvent):void {
			var t:TextField = e.currentTarget as TextField;
			colorDateBgLast = t.backgroundColor;
			if (!t || t.alpha != 1 || t.border == false || t == txtSelected) return;
			t.backgroundColor = colorSelector;
		}
		
		private function onDateMouseOut(e:MouseEvent):void {
			var t:TextField = e.currentTarget as TextField;
			if (!t || t.alpha != 1 || t.border == false || t == txtSelected) return;
			t.backgroundColor = colorDateBgLast;
		}
		
		private function onDateMouseDown(e:MouseEvent):void {
			var dateCell:TextField = e.target as TextField;
			if (!dateCell || dateCell.name != dateCellName || dateCell.alpha == noMonthDayAlpha) return;
			calSettings.calendarDate = Number(dateCell.text);
			updateMonth();
			calendarToUser();
			notifyChange();
		}
		
		private function onBtnNowClick(e:MouseEvent):void {
			setTodaysDateTime();
			this.hideCalendar();
			notifyChange();
		}
		
		private function onBtnDoneClick(e:MouseEvent):void {
			this.hideCalendar();
			calendarToUser();
			notifyChange();
		}
		
		private function onStageMouseDownHandler(e:MouseEvent):void {
			if (!_calendarRunning) return;
			if (!isMouseOnThis(e.stageX, e.stageY)) {
				this.hideCalendar();
			}
		}
		private function isMouseOnThis(mXPos:Number, mYPos:Number):Boolean {
			var bnds:Rectangle = this.getBounds(container);
			if (mXPos > bnds.left &&
				mXPos < bnds.right &&
				mYPos > bnds.top &&
				mYPos < bnds.bottom
			)
			{
				return true;
			}
			return false;
		}
		// -------------------------- End of Events ------------------------- //
		
		
		
		// ----------------------------- Data ----------------------------- //
		private function calendarToUser():void {
			_hasValidDateTime = true;
			calSettings.setCalendarToUser();
		}
		
		private function updateCalendarSettings():void {
			if (calSettings.hasDefaultDate) {
				calSettings.setTodaysToCalendar();
			} else {
				calSettings.setUserToCalendar();
			}
			updateCalendar();
		}
		
		private function notifyChange():void {
			//calSettings.setCalendarToUser();
			this.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CHANGE, calSettings)); // Notify change.
		}
		
		private function setTodaysDateTime():void {
			calSettings.setTodaysDateTime();
			updateCalendarSettings();
		}
		
		public function showCalendar(xPos:Number, yPos:Number, alignR:Boolean):void {
			this.x = (alignR)? xPos-this.width : xPos;
			this.y = yPos;
			container.addChild(this);
			addListeners();
			_calendarRunning = true;
		}
		
		public function hideCalendar():void {
			_calendarRunning = false;
			removeListeners();
			cbxMonth.close();
			if (this.parent) this.parent.removeChild(this);
			//this.visible = false;
			notifyChange();
			this.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLOSE, calSettings)); // Notify close.
		}
		// -------------------------- End of Data ------------------------- //
		
		
		
		// ----------------------------- Public ----------------------------- //
		public function setMySQLDate(mysqlDate:String):Boolean {
			_hasValidDateTime = calSettings.setMySQLDate(mysqlDate);
			updateCalendarSettings();
			notifyChange();
			return _hasValidDateTime;
		}
		
		public function get hasDefaultDate():Boolean {
			return calSettings.hasDefaultDate;
		}
		
		public function get calendarDateTime():Date {
			return calSettings.getCalendarDateTime();
		}
		
		public function getDateTimeForServer():String {
			if (_hasValidDateTime && !calSettings.hasDefaultDate) {
				return calSettings.getDateTimeForServer();
			} else {
				return calSettings.defaultDateTime;
			}
		}
		
		public function getDateTimeForCalendar():String {
			return calSettings.getDateTimeForCalendar();
		}
		
		public function resetCalendar():void {
			setMySQLDate(calSettings.defaultDateTime);
		}
		// -------------------------- End of Public ------------------------- //
	}
}