package src3d.utils
{
	public class Logger
	{
		private static var _self:Logger;
		private static var _allowInstance:Boolean = false;
		
		public static const TYPE_ERROR:String = "E";
		public static const TYPE_ALERT:String = "A";
		public static const TYPE_INFO:String = "I";
		public static const TYPE_USER:String = "U";
		public static const TYPE_TEXT:String = "T";
		
		private var _hasErrors:Boolean = false; // Stores if some error has occurred.
		
		private var strSeparator:String = "------------------------------------";
		private var newLine:String = "\r\n";
		private var strE:String = "(E) - "; // Error.
		private var strA:String = "(A) - "; // Alert.
		private var strI:String = "(I) - "; // Info.
		private var strU:String = "(U) - "; // User.
		private var strT:String = ""; // Text.
		
		private var _mainHeader:String = "SSP Error Log"+newLine+strSeparator+newLine;
		private var _mainLog:String = newLine+"Main Log:"+newLine+strSeparator+newLine;
		private var _errorLog:String = newLine+"Errors Found:"+newLine+strSeparator+newLine;
		private var _sysInfoLog:String = newLine+"System Info:"+newLine+strSeparator+newLine;
		private var _lastText:String = ""; // Stores the last text to be reused for msg box.
		
		
		public function Logger() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():Logger {
			if(_self == null) {
				_allowInstance=true;
				_self = new Logger();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		private function getFormattedLog():String {
			var log:String = "";
			if (_hasErrors) log += _errorLog;
			log += _sysInfoLog;
			log += _mainLog;
			return log;
		}
		
		private function addToErrorLog(t:String):void {
			var aLogs:Array = _errorLog.split(newLine);
			if (aLogs.indexOf(t) == -1) {
				_errorLog += (t + newLine);
			}
		}
		
		public function addError(t:String) {
			addText(t, true, false, true, false, TYPE_ERROR);
		}
		
		public function addAlert(t:String) {
			addText(t, false, false, true, false, TYPE_ALERT);
		}
		
		public function addInfo(t:String) {
			addText(t, false, false, true, false, TYPE_INFO);
		}
		
		public function addUser(t:String) {
			addText(t, false, false, true, false, TYPE_USER);
		}
		
		public function addEntry(t:String, sameLine:Boolean = false) {
			addText(t, false, false, (sameLine)? false : true, sameLine, TYPE_TEXT);
		}
		
		public function addText(t:String, isError:Boolean, useSeparator:Boolean = false, useTimeStamp:Boolean = true, sameLine:Boolean = false, entryType:String = TYPE_TEXT):void {
			trace("Logged: "+t);
			if (isError) _hasErrors = true;
			_lastText = t;
			if (useSeparator) {
				_mainLog += strSeparator+newLine;
			}
			if (useTimeStamp) {
				_mainLog += getTimeStamp() + " - ";
			}
			if (isError || entryType == TYPE_ERROR) {
				_mainLog += strE;
				addToErrorLog(strE + t);
			} else if (entryType == TYPE_ALERT) {
				_mainLog += strA;
			} else if (entryType == TYPE_INFO) {
				_mainLog += strI;
			} else if (entryType == TYPE_USER) {
				_mainLog += strU;
			//} else if entryType == TYPE_TEXT {
			//	_mainLog += strT;
			}
			_mainLog += t;
			if (!sameLine) _mainLog += newLine;
		}
		
		public function addSysInfo(t:String):void {
			_sysInfoLog += t+newLine;
		}
		
		public function setError():void {
			_hasErrors = true;
		}
		
		public function addSeparator():void {
			_mainLog += strSeparator+newLine;
		}
		
		public function addBlankSpace():void {
			_mainLog += newLine;
		}
		
		public function getTimeStamp():String {
			var ts:String = "";
			var now:Date = new Date();
			var strYear:String = now.fullYear.toString();
			var strMonth:String = (now.month < 10)? "0"+now.month.toString() : now.month.toString();
			var strDate:String = (now.date < 10)? "0"+now.date.toString() : now.date.toString();
			var strHours:String = (now.hours < 10)? "0"+now.hours.toString() : now.hours.toString();
			var strMin:String = (now.minutes < 10)? "0"+now.minutes.toString() : now.minutes.toString();
			var strSec:String = (now.seconds < 10)? "0"+now.seconds.toString() : now.seconds.toString();
			
			// Format to yyyy-mm-dd - hh:mm:ss [gmt].
			ts = strYear + "-" + strMonth + "-" + strDate 
				+ " - " + strHours + ":" + strMin + ":" + strSec 
				+ " [" + TimeUtils.buildTimeZoneDesignation(now, false, false) + "]" ;
			
			return ts;
		}
		
		public function get hasErrors():Boolean { return _hasErrors; }
		public function get lastText():String { return _lastText; }
		public function get mainLog():String { return getFormattedLog(); }
	}
}