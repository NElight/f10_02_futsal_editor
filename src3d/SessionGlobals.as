package src3d
{
	import flash.utils.ByteArray;
	
	import src3d.utils.MiscUtils;

	public class SessionGlobals
	{
		private static var _self:SessionGlobals;
		private static var _allowInstance:Boolean = false;
		
		// Session Settings.
		public static const SESSION_TYPE_TRAINING:String	= "Training";
		public static const SESSION_TYPE_MATCH:String		= "Match";
		
		public static const SCREEN_TYPE_SCREEN:String		= "Screen";
		public static const SCREEN_TYPE_PERIOD:String		= "Period";
		public static const SCREEN_TYPE_SET_PIECE:String	= "Set-piece"; // Note the small p, not capital.
		
		// Category settings.
		public static const CATEGORY_TYPE_TRAINING:String	= "Training";
		public static const CATEGORY_TYPE_MATCH:String		= "Match";
		public static const CATEGORY_TYPE_SET_PIECE:String	= "Set-piece";
		
		public var sessionDataXML:XML = new XML();
		public var interfaceLanguageDataXML:XML = new XML();
		public var menuDataXML:XML = new XML();
		private var _teamDataXML:XML;
		public var zipData:ByteArray;
		
		public var errorSavingOverallDescription:Boolean;
		public var errorSavingScreenComments:Boolean;
		
		public var sspToolVersion:Number = SSPSettings.sspToolVersion; // Application version.
		public var sspToolMinorVersion:Number = SSPSettings.sspToolMinorVersion;
		public var sspXMLVersion:Number; // Loaded XML Data Version.
		public var sspRevision:String = ""; // Application revision.
		public var sspFlashVersion:String = "";
		public var sspApplicationInfo = "SSP v"+sspToolVersion.toString()+"."+sspToolMinorVersion.toString(); // Displayed in settings form.
		
		public var currentKitId:int;
		public var initialLinesLibrary:Object = {}; // Initial lines style (<intial_lines_library>).
		public var defaultLinesLibrary:Object = {}; // User default lines style (<lines_library>).
		
		// System Info.
		public var clientPlatform:String = "";
		public var clientFlashFullVersion:String = ""; // eg: WIN 11,3,31,222
		public var clientFlashVersion:String = ""; // eg: 11,3,31,222
		public var clientFlashVersionMayor:int;
		public var clientFlashVersionMinor:int;
		public var clientFlashVersionBuid:int;
		public var clientPlayerType:String = "";
		public var clientOS:String = "";
		public var clientProcessorType:String = "";
		public var clientCPUArchitecture:String = "";
		public var clientLanguage:String = "";
		public var clientBrowserLanguage:String = "";
		public var clientRAM:String = "";
		public var clientScreen:String = "";
		
		public var sessionType:String = SESSION_TYPE_TRAINING; // Default session type.
		public var sessionDataURL = "xml_content.xml"; // This is the default value for local debug.
		public var interfaceLanguageURL = "language_data.xml"; // This is the default value for local debug.
		public var menuDataURL = "global_data.xml"; // This is the default value for local debug.
		public var teamDataURL = "team_data.xml"; // 
		
		public var strScreenSortOrder:String = "0"; // Viewer Flashvar. Screen to load.
		public var isLocal = false; // Tells flash if the player is local or in server.
		public var isDev = false; // Tells flash if the player is running in Dev server.
		
		private var _sScreenKeysEnabled:Boolean; // Tells if 3D keys are enabled. Used by settings form.
		private var _textEditing:Boolean; // Mike's code for settings control.
		private var _createMode:Boolean; // Used by Line Creators, ObjectCloner.as, PopupBtnItemClone.as, PopupBtnItemPin.as.
		private var _editMode:Boolean;
		private var _dragMode:Boolean;
		private var _camLocked:Boolean;
		private var _globalFlipH:Boolean;
		private var _showErrorOnSave:Boolean;
		
		// Match Day.
		public var omitTeamPlayerId:Boolean; // Place unpersonalized 3D team players.
		
		public function SessionGlobals() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				// trace("SessionGlobals initialized.");
			}
		}
		
		public static function getInstance():SessionGlobals {
			if(_self == null) {
				_allowInstance=true;
				_self = new SessionGlobals();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		public function set createMode(val:Boolean):void {
			//trace("sG.createMode(): "+val);
			_createMode = val;
		}
		public function get createMode():Boolean {
			return _createMode;
		}
		
		public function set editMode(val:Boolean):void {
			//trace("sG.editMode(): "+val);
			_editMode = val;
		}
		public function get editMode():Boolean {
			return _editMode;
		}
		
		public function set dragMode(val:Boolean):void {
			//trace("sG.dragMode(): "+val);
			_dragMode = val;
		}
		public function get dragMode():Boolean {
			return _dragMode;
		}
		
		public function set camLocked(val:Boolean):void {
			//trace("sG.camLocked(): "+val);
			_camLocked = val;
		}
		public function get camLocked():Boolean {
			return _camLocked;
		}

		public function get sScreenKeysEnabled():Boolean
		{
			return _sScreenKeysEnabled;
		}

		public function set sScreenKeysEnabled(value:Boolean):void
		{
			_sScreenKeysEnabled = value;
		}

		public function get textEditing():Boolean
		{
			return _textEditing;
		}

		public function set textEditing(value:Boolean):void
		{
			_textEditing = value;
		}

		public function get globalFlipH():Boolean
		{
			return _globalFlipH;
		}

		public function set globalFlipH(value:Boolean):void
		{
			_globalFlipH = value;
		}

		public function get showErrorOnSave():Boolean
		{
			return _showErrorOnSave;
		}

		public function set showErrorOnSave(value:Boolean):void
		{
			_showErrorOnSave = value;
		}
		
		public function get sessionTypeIsMatch():Boolean {
			return (sessionType == SESSION_TYPE_MATCH)? true : false;
		}

		public function get usePlayerRecords():Boolean
		{
			return MiscUtils.stringToBoolean(this.sessionDataXML._usePlayerRecords.text());
		}
	}
}