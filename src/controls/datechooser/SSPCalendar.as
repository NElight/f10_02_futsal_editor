package src.controls.datechooser
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import src3d.SSPEvent;
	import src3d.utils.Logger;

	public class SSPCalendar extends EventDispatcher
	{
		private static var _self:SSPCalendar;
		private static var _allowInstance:Boolean = false;
		
		private var logger:Logger = Logger.getInstance();
		
		private var _stage:Stage;
		private var _calendar:SSPCalendarControls;
		
		private var _calendarRunning:Boolean;
		
		public function SSPCalendar() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():SSPCalendar {
			if(_self == null) {
				_allowInstance=true;
				_self = new SSPCalendar();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		public function initCalendar(container:Stage):void {
			// As this is a singletol class, if calendar will be used in several places, changes could affect to more than one listener.
			if (!_stage) {
				_stage = container;
				_calendar = new SSPCalendarControls(_stage);
			} else {
				trace("Calendar already initialized!");
			}
		}
		
		public function showCalendar(xPos:Number, yPos:Number, alignR:Boolean):void {
			if (!_stage || !_calendar) {
				trace("Calendar not initialized!");
				return;
			}
			_calendarRunning = true;
			_calendar.showCalendar(xPos, yPos, alignR);
			if (!_calendar.hasEventListener(SSPEvent.CONTROL_CHANGE)) {
				_calendar.addEventListener(SSPEvent.CONTROL_CHANGE, onCalendarChangeHandler, false, 0, true);
			}
			if (!_calendar.hasEventListener(SSPEvent.CONTROL_CLOSE)) {
				_calendar.addEventListener(SSPEvent.CONTROL_CLOSE, onCalendarCloseHandler, false, 0, true);
			}
		}
		
		private function onCalendarCloseHandler(e:SSPEvent):void {
			_calendarRunning = false;
			_calendar.removeEventListener(SSPEvent.CONTROL_CHANGE, onCalendarChangeHandler);
			_calendar.removeEventListener(SSPEvent.CONTROL_CLOSE, onCalendarCloseHandler);
		}
		
		private function onCalendarChangeHandler(e:SSPEvent):void {
			this.dispatchEvent(e);
		}

		public function get calendarRunning():Boolean {
			return _calendarRunning;
		}

		public function set calendarRunning(value:Boolean):void {
			_calendarRunning = value;
		}
		
		public function get calendarDateTime():Date {
			return _calendar.calendarDateTime;
		}
		
		public function getDateTimeForCalendar():String {
			return _calendar.getDateTimeForCalendar();
		}
		
		public function getDateTimeForServer():String {
			return _calendar.getDateTimeForServer();
		}
		
		public function setMySQLDate(mysqlDate:String):void {
			var dateOK:Boolean = _calendar.setMySQLDate(mysqlDate);
			if (!dateOK) {
				logger.addText("Invalid _sessionStartTime value found.", true);
			}
		}
		
		public function get hasDefaultDate():Boolean {
			return _calendar.hasDefaultDate;
		}
		
		public function resetCalendar():void {
			_calendar.resetCalendar();
		}
	}
}