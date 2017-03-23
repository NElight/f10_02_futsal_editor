package src3d.utils
{
	public class TimeUtils
	{
		public function TimeUtils()
		{
		}
		
		/**
		 * Returns the time zone, without the DST (Daylight Saving Time). 
		 * @return difference with GMT-0 in milliseconds.
		 * @see getDTS
		 */		
		public static function getTimezone():Number
		{
			// Create two dates: one summer and one winter
			var d1:Date = new Date( 0, 0, 1 );
			var d2:Date = new Date( 0, 6, 1 );
			
			// largest value has no DST modifier
			var tzd:Number = Math.max( d1.timezoneOffset, d2.timezoneOffset );
			
			// convert to milliseconds
			return tzd * 60000;
		}
		
		/**
		 * Returns the DST (Daylight Saving Time). 
		 * @return The amount of Daylight Saving Time in milliseconds.
		 * 
		 * see getTimezone
		 */
		public static function getDST( d:Date ):Number
		{
			var tzd:Number = getTimezone();
			var dst:Number = (d.timezoneOffset * 60000) - tzd;
			return dst;
		}
		
		/**
		 * Determines if local computer is observing daylight savings time for US and London.
		 * 
		 * @see buildTimeZoneDesignation
		 */
		public static function isObservingDTS():Boolean
		{
			var winter:Date = new Date(2011, 01, 01); // after daylight savings time ends
			var summer:Date = new Date(2011, 07, 01); // during daylight savings time
			var now:Date = new Date();
			
			var winterOffset:Number = winter.getTimezoneOffset();
			var summerOffset:Number = summer.getTimezoneOffset();
			var nowOffset:Number = now.getTimezoneOffset();
			
			if((nowOffset == summerOffset) && (nowOffset != winterOffset)) {
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * Method to build GMT from date and timezone offset and accounting for daylight savings.
		 *
		 * Originally code befor modifications:
		 * http://flexoop.com/2008/12/flex-date-utils-date-and-time-format-part-i/
		 * 
		 * @see isObservingDTS
		 */
		public static function buildTimeZoneDesignation( date:Date, dts:Boolean, useGMTString:Boolean ):String
		{
			if ( !date ) {
				return "";
			}
			
			var timeZoneAsString:String = "";
			var timeZoneOffset:Number;
			
			if (useGMTString) timeZoneAsString = "GMT";
			
			// timezoneoffset is the number that needs to be added to the local time to get to GMT, so
			// a positive number would actually be GMT -X hours
			if ( date.getTimezoneOffset() / 60 > 0 && date.getTimezoneOffset() / 60 < 10 ) {
				timeZoneOffset = (dts)? ( date.getTimezoneOffset() / 60 ):( date.getTimezoneOffset() / 60 - 1 );
				timeZoneAsString += "-0" + timeZoneOffset.toString();
			} else if ( date.getTimezoneOffset() < 0 && date.timezoneOffset / 60 > -10 ) {
				timeZoneOffset = (dts)? ( date.getTimezoneOffset() / 60 ):( date.getTimezoneOffset() / 60 + 1 );
				timeZoneAsString += "+0" + ( -1 * timeZoneOffset ).toString();
			} else {
				timeZoneAsString += "+00";
			}
			
			// add zeros to match standard format
			//timeZoneAsString += "00";
			return timeZoneAsString;
		}
		
		public static function getDateAsYYYYMMDD(includeTime:Boolean, separator:String = "_", customDate:Date = null):String {
			var currentDate:Date = (customDate)? customDate : new Date();
			var strYear:String = MiscUtils.addLeadingZeros(currentDate.fullYear.toString(), 4);
			var strMonth:String = MiscUtils.addLeadingZeros(Number(currentDate.month+1).toString(), 2); // Flash Month + 1.
			var strDay:String = MiscUtils.addLeadingZeros(currentDate.date.toString(), 2);
			var strDate:String = strYear+strMonth+strDay;
			if (includeTime) {
				var strHour:String = MiscUtils.addLeadingZeros(currentDate.hours.toString(), 2);
				var strMin:String = MiscUtils.addLeadingZeros(currentDate.minutes.toString(), 2);
				strDate += separator+strHour+strMin;
			}
			return strDate;
		}
	}
}