package src.controls.datechooser
{
	import com.adobe.utils.StringUtil;
	
	import flash.globalization.StringTools;
	
	import src3d.SessionGlobals;
	import src3d.utils.MiscUtils;

	public class SSPCalendarSettings
	{
		public var firstDay:Date; // Calendar's first day of the month reference.
		private var calendarDateTime:Date; // Calendar controls date.
		private var userDateTime:Date; // User selected date.
		private var _flashDefaultDate:Date;
		protected var sL:XML = SessionGlobals.getInstance().interfaceLanguageDataXML;
		
		public const defaultDateTime:String = "0000-00-00 00:00:00";
		
		public const aMonthDays:Array = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
		
		private const _aDayNames:Vector.<String> = Vector.<String>([
			sL.tags._daySun.text(),
			sL.tags._dayMon.text(),
			sL.tags._dayTue.text(),
			sL.tags._dayWed.text(),
			sL.tags._dayThu.text(),
			sL.tags._dayFri.text(),
			sL.tags._daySat.text()
		]);
		private const _aMonthNames:Array = [
			{label:sL.tags._monthJanuary.text(), data:0},
			{label:sL.tags._monthFebruary.text(), data:1},
			{label:sL.tags._monthMarch.text(), data:2},
			{label:sL.tags._monthApril.text(), data:3},
			{label:sL.tags._monthMay.text(), data:4},
			{label:sL.tags._monthJune.text(), data:5},
			{label:sL.tags._monthJuly.text(), data:6},
			{label:sL.tags._monthAugust.text(), data:7},
			{label:sL.tags._monthSeptember.text(), data:8},
			{label:sL.tags._monthOctober.text(), data:9},
			{label:sL.tags._monthNovember.text(), data:10},
			{label:sL.tags._monthDecember.text(), data:11}
		];
		
		private var roundTo5mins:Boolean;
		
		public function SSPCalendarSettings(roundTo5mins:Boolean)
		{
			this.roundTo5mins = roundTo5mins;
			setTodaysDateTime();
		}
		
		public function getMonthShortName(monthNum:uint):String {
			var strName:String = "Mmm";
			for each(var obj:Object in _aMonthNames) {
				if (obj.data == userDateTime.month) strName = obj.label;
			}
			strName = strName.substr(0,3);
			return strName;
		}
		
		public function getMonthNames():Array {
			return _aMonthNames;
		}
		
		public function getDayNames():Vector.<String> {
			return _aDayNames;
		}
		
		private function get flashDefaultDate():Date {
			if (!_flashDefaultDate) _flashDefaultDate = MiscUtils.getFlashDateFromMySQL(defaultDateTime);
			return _flashDefaultDate;
		}
		
		public function get flashTodaysDate():Date {
			var todaysDate:Date;
			todaysDate = (roundTo5mins)? todaysDate = MiscUtils.roundDateToNext5mins(new Date()) : new Date();
			return todaysDate;
		}
		
		private function setDefaultToUser():void {
			var defDateTime:Date = this.flashDefaultDate;
			userDateTime = new Date(defDateTime.fullYear,defDateTime.month,defDateTime.date,defDateTime.hours,defDateTime.minutes);
		}
		
		public function setCalendarToUser():void {
			//if (roundTo5mins) calendarDateTime = MiscUtils.roundDateToNext5mins(calendarDateTime);
			userDateTime = new Date(calendarDateTime.fullYear,calendarDateTime.month,calendarDateTime.date,calendarDateTime.hours,calendarDateTime.minutes);
		}
		
		public function setUserToCalendar():void {
			calendarDateTime = new Date(userDateTime.fullYear,userDateTime.month,userDateTime.date,userDateTime.hours,userDateTime.minutes);
		}
		
		public function setTodaysToCalendar():void {
			var todaysDate:Date = this.flashTodaysDate;
			calendarDateTime = new Date(todaysDate.fullYear,todaysDate.month,todaysDate.date,todaysDate.hours,todaysDate.minutes);
		}
		
		public function setTodaysDateTime():void {
			var todaysDate:Date = new Date();
			todaysDate.setTime(flashTodaysDate.getTime());
			if (!todaysDate) return;
			firstDay = new Date(todaysDate.fullYear,todaysDate.month,1);
			userDateTime = new Date(todaysDate.fullYear,todaysDate.month,todaysDate.date,todaysDate.hours,todaysDate.minutes);
			calendarDateTime = new Date(todaysDate.fullYear,todaysDate.month,todaysDate.date,todaysDate.hours,todaysDate.minutes);
		}
		
		private function setCalendarToNewDate(newDate:Date):void {
			calendarDateTime.fullYear = newDate.fullYear;
			calendarDateTime.month = newDate.month;
			calendarDateTime.date = newDate.date;
			calendarDateTime.hours = newDate.hours;
			calendarDateTime.minutes = newDate.minutes;
			calendarDateTime.seconds = 0;
		}
		
		public function get hasDefaultDate():Boolean {
			//if (flashDefaultDate == userDateTime) return true;
			if (
				userDateTime.fullYear == flashDefaultDate.fullYear &&
				userDateTime.month == flashDefaultDate.month &&
				userDateTime.date == flashDefaultDate.date &&
				userDateTime.hours == flashDefaultDate.hours &&
				userDateTime.minutes == flashDefaultDate.minutes
			) {
				return true;
			}
			return false;
		}
		
		public function setMySQLDate(mysqlDate:String):Boolean {
			var dateOK:Boolean = true;
			if (mysqlDate == "") mysqlDate = defaultDateTime;
			var newDate:Date = MiscUtils.getFlashDateFromMySQL(mysqlDate);
			if (!newDate) {
				dateOK = false;
				mysqlDate = defaultDateTime;
			}
			if (!newDate || mysqlDate == defaultDateTime) {
				setDefaultToUser();
				setTodaysToCalendar();
			} else {
				dateOK = true;
				// Use specified date settings.
				setCalendarToNewDate(newDate);
				setCalendarToUser();
			}
			var hasDef:Boolean = this.hasDefaultDate;
			return dateOK;
		}
		
		public function getDateTimeForServer():String {
			// Server format: 2013-12-30 00:00:00
			var strYear:String = MiscUtils.addLeadingZeros(userDateTime.fullYear.toString(), 4);
			var strMonth:String = MiscUtils.addLeadingZeros(Number(userDateTime.month+1).toString(), 2); // Flash Month + 1.
			var strDay:String = MiscUtils.addLeadingZeros(userDateTime.date.toString(), 2);
			var strHour:String = MiscUtils.addLeadingZeros(userDateTime.hours.toString(), 2);
			var strMin:String = MiscUtils.addLeadingZeros(userDateTime.minutes.toString(), 2);
			var strSec:String = "00";
			var strDateTime:String = (this.hasDefaultDate)? defaultDateTime : strYear+"-"+strMonth+"-"+strDay+" "+strHour+":"+strMin+":"+strSec;
			return strDateTime;
		}
		
		public function getDateTimeForCalendar():String {
			// Calendar format: dd-Mmm-yyyy 00:00
			var strYear:String = MiscUtils.addLeadingZeros(calendarDateTime.fullYear.toString(), 4);
			var strMonth:String = getMonthShortName(calendarDateTime.month);
			var strDay:String = MiscUtils.addLeadingZeros(calendarDateTime.date.toString(), 2);
			var strHour:String = MiscUtils.addLeadingZeros(calendarDateTime.hours.toString(), 2);
			var strMin:String = MiscUtils.addLeadingZeros(calendarDateTime.minutes.toString(), 2);
			var strDateTime:String = (this.hasDefaultDate)? "" : strDay+"-"+strMonth+"-"+strYear+" "+strHour+":"+strMin;
			return strDateTime;
		}
		
		public function getTimeForCalendar():String {
			var strHour:String = MiscUtils.addLeadingZeros(calendarDateTime.hours.toString(), 2);
			var strMin:String = MiscUtils.addLeadingZeros(calendarDateTime.minutes.toString(), 2);
			var strDateTime:String = strHour+":"+strMin;
			return strDateTime;
		}
		
		/**
		 * Use these getter/setters to use 'roundTo5min' property. 
		 */
		public function get calendarMinutes():Number { return calendarDateTime.minutes; }
		public function set calendarMinutes(value:Number):void {
			calendarDateTime.minutes = value;
			if (roundTo5mins) calendarDateTime = MiscUtils.roundDateToNext5mins(calendarDateTime);
		}
		
		public function get calendarHours():Number { return calendarDateTime.hours; }
		public function set calendarHours(value:Number):void { calendarDateTime.hours = value; }
		
		public function get calendarDate():Number { return calendarDateTime.date; }
		public function set calendarDate(value:Number):void { calendarDateTime.date = value; }
		
		public function get calendarMonth():Number { return calendarDateTime.month; }
		public function set calendarMonth(value:Number):void { calendarDateTime.month = value; }
		
		public function get calendarFullYear():Number { return calendarDateTime.fullYear; }
		public function set calendarFullYear(value:Number):void { calendarDateTime.fullYear = value; }
		
		public function getCalendarDateTime():Date {
			return calendarDateTime;
		}
	}
}