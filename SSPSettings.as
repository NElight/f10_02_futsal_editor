package
{
	public class SSPSettings
	{
		// Tool Settings.
		public static const sspToolVersion:Number = 1; // Application version.
		public static const sspToolMinorVersion:Number = 1; // Application minor version.
		public static const xmlDeclaration:String = '<?xml version="1.1" encoding="utf-8"?>';
		
		// Debug Settings.
		public static const noRedirectOnSave:Boolean = false; // Set to true for debugging.
		public static const resendSameDataFile:Boolean = false; // Set to true for debugging.
		
		// Data Settings.
		public static const _sessionSport:uint = 2;
		public static const _tagSportName:String = "soccer"; // Used in lines tags.
		public static const _maxPlayersPerTeam:uint = 11;
		public static const namesDigits:uint = 2; // Number of digits used in 2D instance names.
		public static const saveToServerAutoRetryAlways:Boolean = true; // Keep using auto-retry after user retries.
		public static const saveToServerAutoRetryMax:uint = 2; // Number of times to auto-retry saving on error.
		public static const reUseSessionDataOnRetry:Boolean = true; // Do not prepare data again if retrying save. Creates a new zip and includes error.txt if exists.
		public static const errorPreparingDataMax:int = 3; // Max num of internal errors allowed while preparing data to be saved.
		
		// Screen Settings.
		public static const DEFAULT_TAB_LABEL_WILDCARD:String	= "@~~@"; // To be replaced with tab number.
		//public static const DEFAULT_TAB_LABEL_SCREEN:String		= "Screen @~~@";
		//public static const DEFAULT_TAB_LABEL_PERIOD:String		= "Period @~~@";
		//public static const DEFAULT_TAB_LABEL_SET_PIECE:String	= "Set-piece @~~@";
		public static const aScales:Array = new Array(0.5, 0.75, 1, 1.5); // Available object scales.
		
		// Team Settings.
		public static const pitchView1Team:String = "btnPitch02";
		public static const pitchView2Teams:String = "btnPitch03";
		public static const scoreLimit:uint = 1000;
		
		// Format Settings.
		public static const mandatoryCharacterStr:String = "<b><font color='#FF0000'>*</font></b>";
		public static const mandatoryColonStr:String = mandatoryCharacterStr+":";
		public static const nonMandatoryColonStr:String = ":";
		public static const defaultDefaultMaxChars:uint = 100;
		public static const defaultScreenTitleMaxChars:uint = 100;
		public static const defaultSessionDescriptionMaxChars:uint = 4096;
		public static const defaultSkillsCommentsMaxChars:uint = 1024;
		public static const defaultMaxTimeSpent:uint = 120;
		public static const defaultStartTime:String = "0000-00-00 00:00:00";
		public static const defaultLinePathDataMaxChars:uint = 4096;
		
		// Styles.
		public static const DEFAULT_FONT:String = "_sans"; // Default font.
		public static const DEFAULT_ROW_COUNT = 11; // Default max rows in lists.
		public static const DEFAULT_V_SCROLL_SIZE = 100; // Default vertical scroll in lists.
		
		// User Images.
		public static const userImageMaxWidth:uint = 1024;
		public static const userImageMaxHeight:uint = 768;
		public static const userImageJPGQuality:uint = 80;
		
		// Server Images.
		public static const screenImageJPGQuality:uint = 60;
		
		// Domains.
		//public static const aAllowedDomains:Vector.<String> = Vector.<String>(["*.youtube.com", "www.youtube.com", "ytimg.com", "*.ytimg.com", "s.ytimg.com", "i.ytimg.com", "kyosei-systems.com", "dev.kyosei-systems.com", "ssp.dev.kyosei-systems.com"]);
		public static const aAllowedDomains:Vector.<String> = Vector.<String>([
			
			"www.youtube.com",
			"youtube.com",
			"*.youtube.com",
			"ytimg.com",
			"s.ytimg.com",
			"i.ytimg.com",
			"*.ytimg.com",
			"youtube.google.com",
			"*.youtube.google.com",
			"kyosei-systems.com",
			"dev.kyosei-systems.com",
			"ssp.dev.kyosei-systems.com",
			"https://www.youtube.com",
			"https://youtube.com",
			"https://*.youtube.com",
			"https://s.ytimg.com",
			"https://i.ytimg.com",
			"https://*.ytimg.com",
			"https://youtube.google.com",
			"https://*.youtube.google.com",
		]);
		
		
		// Dev Keys.
		public static const DK_YOUTUBE:String = "AIzaSyBMxgex5dL2F7HzWSOuGd79ydy3BjQAHgY";
		
		public function SSPSettings()
		{
		}
	}
}