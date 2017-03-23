package src3d.utils
{
	import flash.events.Event;
	
	import src3d.SessionGlobals;
	import src3d.utils.MiscUtils;
	
	public class SSPError
	{
		// Session Data Error Handling Codes. These are not event types. They are sent in the 'eventId' of the 'ERROR' event type.
		public static const ERROR_CODE_ID_001_UNEXPECTED_ERROR:String 			= "001";
		public static const ERROR_CODE_ID_100_INVALID_TOKEN:String 				= "100";
		public static const ERROR_CODE_ID_101_VALIDATION_ERROR:String 			= "101";
		public static const ERROR_CODE_ID_101_SESSION_TRANSITION:String			= "101SessionTransition";
		public static const ERROR_CODE_ID_104_ACCOUNT_NO_LONGER_ACTIVE:String	= "104";
		public static const ERROR_CODE_ID_200_SERVER_TIME_OUT:String			= "200";
		public static const ERROR_CODE_ID_201_CONNECTION_ERROR:String			= "201";
		public static const ERROR_CODE_ID_300_LOADING_SESSION_DATA:String 		= "300";
		public static const ERROR_CODE_ID_301_LOADING_LANGUAGE_DATA:String		= "301";
		public static const ERROR_CODE_ID_302_LOADING_MENU_DATA:String			= "302";
		public static const ERROR_CODE_ID_303_LOADING_TEAM_DATA:String			= "303";
		
		public static const ERROR_CODE_ID_000_RETRY_TRIGGERED:String 			= "000"; // Custom error to retry saving.
		
		// Array of Loading Error Descriptions (you can use 'MiscUtils.indexInArray()' to get the corresponding description for an error code.).
		public static const aErrorDescriptions:Array = new Array(
			{Id:ERROR_CODE_ID_000_RETRY_TRIGGERED, Description:"Retry Triggered."},
			{Id:ERROR_CODE_ID_001_UNEXPECTED_ERROR, Description:"An unexpected error occurred.  Please send your session to the Support team who will investigate and try to upload it for you. Click the 'Save to PC' button,  then e-mail the saved file to support@SportSessionPlanner.com"},
			{Id:ERROR_CODE_ID_100_INVALID_TOKEN, Description:"Invalid token."},
			{Id:ERROR_CODE_ID_101_VALIDATION_ERROR, Description:"A validation error prevented your session from saving.  This may have been caused by a program or communications error.  If error persists, send details including this message to support@SportSessionPlanner.com."},
			{Id:ERROR_CODE_ID_101_SESSION_TRANSITION, Description:"Error trying to save a drill that was deleted on the server. (This can happen if coaches are sharing a single account.)"},
			{Id:ERROR_CODE_ID_104_ACCOUNT_NO_LONGER_ACTIVE, Description:"Account no longer active."},
			{Id:ERROR_CODE_ID_200_SERVER_TIME_OUT, Description:"A time-out occurred communicating with server.  Please check your network connection."},
			{Id:ERROR_CODE_ID_201_CONNECTION_ERROR, Description:"A problem occurred communicating with server.  Please check your network connection. If error persists, send details including this message to support@SportSessionPlanner.com."},
			{Id:ERROR_CODE_ID_300_LOADING_SESSION_DATA, Description:"Unable to load session data.  Your log-in session may have expired. Please try again."},
			{Id:ERROR_CODE_ID_301_LOADING_LANGUAGE_DATA, Description:"Unable to load language data file.  Please click to try again."},
			{Id:ERROR_CODE_ID_302_LOADING_MENU_DATA, Description:"Unable to load global data.  Please click to try again."},
			{Id:ERROR_CODE_ID_303_LOADING_TEAM_DATA, Description:"Unable to load team data.  Please click to try again."}
		);
		
		private var _errorCode:String = "";
		private var _errorDescription:String = "";
		private var _errorToken:String = "";
		private var _errorSourceError:Error;
		private var _errorExtraMessage:String = "";
		private var _errorExtraData:Object;
		private var _fullErrorMessage:String = "";
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		/**
		 * Creates an SSPServerError object from the specified error code and info.
		 *  
		 * @param errCode String. Eg: SSPError.ERROR_CODE_ID_100_INVALID_TOKEN.
		 * @param errDesc String. The error description. If no value, it will get the internal (english) description for the given code.
		 * @param errToken String. The token received from the server (eg: in the case of Error 300).
		 * @param sourceErr Error. You can store the source error if necesary (eg: a catched error in a try-catch).
		 * @param errExtraMsg String. Any extra text you want to add to the final error message.
		 * @param errExtraData Object. Any extra data you need to store.
		 * 
		 */		
		public function SSPError(errCode:String, errDesc:String = null, errToken:String = null, _errorSourceErr:Error = null, errExtraMsg:String = null, errExtraData:Object = null)
		{
			var strFormattedErrorToken:String = "";
			var strFormattedExtraMessage:String = "";
			var strAppInfo:String = "\n"+sG.sspApplicationInfo;
			var xmlLanguage:XMLList;
			var strErrorCode:String = "_"+errCode;
			var intErrorIdx:int;
			
			_errorCode = errCode;
			
			// Load hardcoded messages (in english).
			intErrorIdx = MiscUtils.indexInArray(aErrorDescriptions, "Id", errCode);
			_errorDescription = (intErrorIdx == -1)? "-" : aErrorDescriptions[intErrorIdx].Description;

			// If there is interface language, use it.
			if (sG.interfaceLanguageDataXML && sG.interfaceLanguageDataXML.length() > 0) {
				//var edXML:XML = XML(sG.interfaceLanguageDataXML.errors.children().(localName() == strErrorCode));
				xmlLanguage = sG.interfaceLanguageDataXML.errors.elements(strErrorCode);
				if (xmlLanguage && xmlLanguage.length() > 0) {
					_errorDescription = xmlLanguage.text();
				}
			}
			
			if (errDesc != null) {
				_errorDescription += "\n" + errDesc;
			}
			if (errToken != null) {
				_errorToken = errToken;
				strFormattedErrorToken = "\nToken: "+errToken;
			}
			_errorExtraData = errExtraData;
			_errorSourceError = _errorSourceErr;
			if (errExtraMsg != null) {
				_errorExtraMessage = errExtraMsg;
				strFormattedExtraMessage = "\n"+errExtraMsg;
			}
			// The error code and description is included at the end, so it can be readed in the msgBox area without having to scroll up.
			_fullErrorMessage = "Error "+errorCode+
				".\nDetails:"+
				strFormattedErrorToken+
				strFormattedExtraMessage+
				strAppInfo+
				"\n\n"+errorCode+" - "+errorDescription;
		}
		
		public function translateError(errCode:String, newText:String):void {
			aErrorDescriptions[MiscUtils.indexInArray(aErrorDescriptions, "Id", errCode)].Description = newText;
		}
		
		public function get errorCode():String { return _errorCode; }
		public function get errorDescription():String { return _errorDescription; }
		public function get errorToken():String { return _errorToken; }
		public function get errorSourceError():Error { return _errorSourceError; }
		public function get errorExtraMessage():String { return _errorExtraMessage; }
		public function get errorExtraData():Object { return _errorExtraData; }
		public function get fullErrorMessage():String { return _fullErrorMessage; }
	}
}