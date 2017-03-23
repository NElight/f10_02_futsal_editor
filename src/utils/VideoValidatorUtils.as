package src.utils
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.XMLUtil;
	
	import src3d.SessionGlobals;
	import src3d.utils.Logger;

	public class VideoValidatorUtils
	{
		public static const SOURCE_YOUTUBE:String		= "YouTube";
		public static const SOURCE_QQ:String			= "QQ";
		/* Videos    
		*  YouTube parameters:
		*  -------------------
		*    &cc_load_policy=1 (force subs enabled)
		*    &hl=en (specify language)
		*    &theme=light (use a light theme)
		*  During Playback:
		*    To increase text size: press "+" key
		*    To decrease text size: press "-" key
		*    To change background: press "B" or "b" key
		*    You can also drag and drop the subtitles
		*    if they don't use positioning.
		*
		*  QQ Video parameters:
		*  --------------------
		*    ?vid = [video code]
		*    &tiny = 1 (uses small buttons)
		*    &auto = 1 (autoplay on)
		*  More info:
		*    http://wiki.open.qq.com/wiki/t/get_video_info.
		*    http://www.apihome.cn/api/tencent/81
		*    http://open.t.qq.com/api/t/getvideoinfo
		*    http://bbs.open.t.qq.com/forum.php?mod=forumdisplay&fid=51
		*  
		*    
		*/
		private static const aVideoSources:Vector.<VideoValidatorSettings> = Vector.<VideoValidatorSettings>([
			// new VideoValidatorSettings(SOURCE_YOUTUBE, "http://www.youtube.com/v/", "?version=3&rel=0&modestbranding=1", "http://gdata.youtube.com/feeds/api/videos/", "?v=2") // Old API v2 info URL. Deprecated.
			//new VideoValidatorSettings(SOURCE_YOUTUBE, "http://www.youtube.com/v/", "?version=3&rel=0&modestbranding=1", "http://www.youtube.com/oembed?url=http://www.youtube.com/watch?v=", "&format=xml") // It only works locally, it gives a SandBox error when running from server due to YouTube crossdomain policy file.
			//new VideoValidatorSettings(SOURCE_YOUTUBE, "http://www.youtube.com/v/", "?version=3&rel=0&modestbranding=1", "http://www.youtube.com/get_video_info?&video_id=", "&asv=3&el=detailpage&hl=en_US") // It only works locally, it gives a SandBox error when running from server due to YouTube crossdomain policy file.
			//new VideoValidatorSettings(SOURCE_YOUTUBE, "http://www.youtube.com/v/", "?version=3&rel=0&modestbranding=1", "https://www.googleapis.com/youtube/v3/videos?id=", "&key="+SSPSettings.DK_YOUTUBE+"&part=snippet", false), // API v3. No HTTPS.
			//"https://www.youtube.com/apiplayer?version=3&video_id=" // Chromeless API Player URL.
			new VideoValidatorSettings(
				SOURCE_YOUTUBE,
				"https://www.youtube.com/v/",
				"?version=3&rel=0&modestbranding=1&show_deprecation_notice=0",
				"https://www.youtube.com/apiplayer?version=3&video_id=",
				"&rel=0&modestbranding=1&show_deprecation_notice=0",
				"https://www.googleapis.com/youtube/v3/videos?id=",
				"&key="+SSPSettings.DK_YOUTUBE+"&part=snippet",
				false), // API v3. HTTPS.
			
			//new VideoValidatorSettings(SOURCE_QQ, "http://static.video.qq.com/TPout.swf?vid=", "&tiny=0&auto=1", "", "")
			new VideoValidatorSettings(
				SOURCE_QQ,
				"http://v.qq.com/iframe/player.html?vid=",
				"&tiny=1&auto=1",
				"",
				"",
				"",
				"",
				true)
		]);
		
		public function VideoValidatorUtils()
		{
		}
		
		public static function getVideoLocationSettings(strSource:String):VideoValidatorSettings {
			var url:String = "";
			var base:String = "";
			var params:String = "";
			var language:String = "";
			var newVs:VideoValidatorSettings;
			for each (var vs:VideoValidatorSettings in aVideoSources) {
				if (vs.source == strSource) {
					newVs = vs.clone();
					// Add the language parameter for player interface and subtitles.
					language = SessionGlobals.getInstance().sessionDataXML.session._interfaceLanguageCode.text();
					if (strSource == SOURCE_YOUTUBE && language != "undefined" && language != null && language != "") {
						newVs.params += "&hl="+language;
					}
					return newVs;
				}
			}
			return null;
		}
		
		public static function getVideoSourceFromLocation(strLocation:String):String {
			var strSource:String = "";
			var strYouTube1:String = "youtube.com";
			var strYouTube2:String = "youtu.be";
			var strQQ:String = "qq.com";
			// If string contains youtube.com or youtu.be, it's a YouTube video, else it's a QQ video.
			if (strLocation.indexOf(strYouTube1) > -1 || strLocation.indexOf(strYouTube2) > -1) {
				strSource = SOURCE_YOUTUBE;
			} else {
				strSource = SOURCE_QQ;
			}
			return strSource;
		}
		
		public static function getVideoCodeFromLocation(strLocation:String, strSource:String):String {
			var strCode:String = "";
			// If string contains youtube.com or youtu.be, it's a YouTube video, else it's a QQ video.
			if (strSource == SOURCE_YOUTUBE) {
				strCode = getYouTubeCode(strLocation);
			} else {
				strCode = getQQCode(strLocation);
			}
			return strCode;
		}
		
		private static function getYouTubeCode(strLocation:String):String {
			var strCode:String = "";
			var foundIdx:int;
			var strDomainURL:String = "youtube.com";
			var regExp1:RegExp = /v=([\w\-]+)/;
			var regExp2:RegExp = /youtu.be\/([\w\-]+)/;
			
			// Check youtube.com/
			foundIdx = strLocation.indexOf(strDomainURL);
			if (foundIdx > -1) {
				//var test:String = strLocation.replace(regExp, "FOUND");
				var aRegExp:Array = regExp1.exec(strLocation);
				if (aRegExp && aRegExp[0]) {
					strCode = aRegExp[0];
					strCode = strCode.split("v=").join("");
					strCode.replace(/[v=]/, "");
					return strCode;
				}
			}
			
			// Check youtu.be/
			var aRegExp:Array = regExp2.exec(strLocation);
			if (aRegExp && aRegExp[0]) {
				strCode = aRegExp[0];
				strCode = strCode.split("youtu.be/").join("");
				strCode.replace(/[youtu.be\/]/, "");
				return strCode;
			}
			
			return strCode;
		}
		
		private static function getQQCode(strLocation:String):String {
			var strCode:String = "";
			var foundIdx:int;
			var strDomainURL:String = "qq.com";
			var regExp1:RegExp = /vid=([\w\-]+)/;
			
			// Check youtube.com/
			foundIdx = strLocation.indexOf(strDomainURL);
			if (foundIdx > -1) {
				//var test:String = strLocation.replace(regExp, "FOUND");
				var aRegExp:Array = regExp1.exec(strLocation);
				if (aRegExp && aRegExp[0]) {
					strCode = aRegExp[0];
					strCode = strCode.split("vid=").join("");
					strCode.replace(/[vid=]/, "");
					return strCode;
				}
			}
			
			return strCode;
		}
		
		public static function getVideoLocation(strSource:String, strCode:String, usePlayerAPI:Boolean = false):String {
			var vLocation:String = "";
			var vSettings:VideoValidatorSettings = getVideoLocationSettings(strSource);
			if (vSettings) {
				if (usePlayerAPI) {
					vLocation = vSettings.getAPILocation(strCode);
				} else {
					vLocation = vSettings.getLocation(strCode);
				}
			}
			return vLocation;
		}
		
		public static function getVideoInfoLocation(strSource:String, strCode:String):String {
			var vInfoLocation:String = "";
			var vSettings:VideoValidatorSettings = getVideoLocationSettings(strSource);
			if (vSettings) vInfoLocation = vSettings.getInfoLocation(strCode);
			return vInfoLocation;
		}
		
		public static function parseVideoInfo(strSource:String, strInfoData:String, strVideoCode:String):VideoValidatorInfo {
			var vi:VideoValidatorInfo;
			if (!strInfoData) return null;
			if (strSource == SOURCE_YOUTUBE) {
				// strInfoData = validateXML(SOURCE_YOUTUBE, strInfoData); // Used with the old API v2.
				if (strInfoData) vi = parseYouTubeInfo(strInfoData, strVideoCode);
			} else {
				if (strInfoData) vi = parseQQInfo(strInfoData, strVideoCode);
			}
			return vi;
		}
		
		public static function getPlayExternally(strSrouce:String):Boolean {
			var playExternally:Boolean;
			var vSettings:VideoValidatorSettings = getVideoLocationSettings(strSrouce);
			if (vSettings) playExternally = vSettings.playExternally;
			return playExternally;
		}
		
		// ----------------------------- Parsers ----------------------------- //
		private static function parseQQInfo(strInfoData:String, strVideoCode:String):VideoValidatorInfo {
			// No Video Info available for QQ videos.
			var vi:VideoValidatorInfo = new VideoValidatorInfo();
			vi.videoSource = SOURCE_QQ;
			vi.videoDuration = "0"; // No duration provided.
			vi.videoCode = strVideoCode;
			
			vi.videoStatusOK = true; // Forced validation.
			vi.videoTitle = "QQ Video"; // No title available.
			
			return vi;
		}
		
		
		
		private static function parseYouTubeInfo(strInfoData:String, strVideoCode:String):VideoValidatorInfo {
			var vi:VideoValidatorInfo = new VideoValidatorInfo();
			var sJSON:Object;
			var strAppState:String;
			vi.videoSource = SOURCE_YOUTUBE;
			vi.videoDuration = "0"; // No duration provided.
			vi.videoCode = strVideoCode;
			try {
				sJSON = com.adobe.serialization.json.JSON.decode(strInfoData, false);
				if (sJSON && sJSON.items) {
					vi.videoStatusOK = true;
					if (sJSON.items.length > 0) {
						vi.videoTitle = sJSON.items[0].snippet.title;
					} else {
						vi.videoRestricted = true;
						vi.videoRestrictedInfo = "";
						// If JSON data includes the reason, display it.
						if (sJSON.error && sJSON.error.errors && sJSON.error.errors.length > 0) {
							vi.videoRestrictedInfo = sJSON.error.errors[0].reason +". "+ sJSON.error.errors[0].message +".";
						}
						Logger.getInstance().addAlert("No details in JSON data from YouTube video id '"+vi.videoCode+"'. Could be a private video.");
					}
					//Logger.getInstance().addError(SOURCE_YOUTUBE+" data parsed OK:\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----");
					Logger.getInstance().addInfo(SOURCE_YOUTUBE+" info data of '"+vi.videoCode+"' parsed OK.");
				} else {
					Logger.getInstance().addError("Can't decode "+SOURCE_YOUTUBE+" JSON data from video id '"+vi.videoCode+"'.");
				}
			} catch(error:Error) {
				//Logger.getInstance().addError("Can't parse "+SOURCE_YOUTUBE+" data: "+error.message+"\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----");
				Logger.getInstance().addError("Can't parse "+SOURCE_YOUTUBE+" data: "+error.message);
			}
			return vi;
		}
		
		
		// Alternative method oEmbed or video_info.
		/*private static function parseYouTubeInfo(strInfoData:String):VideoValidatorInfo {
			var vi:VideoValidatorInfo = new VideoValidatorInfo();
			var sXML:XML;
			var strAppState:String;
			try {
				sXML = new XML(strInfoData);
				
				vi.videoSource = SOURCE_YOUTUBE;
				vi.videoTitle = sXML.title.text();
				vi.videoDuration = "0"; // No duration provided.
				vi.videoCode = "";
				vi.videoStatusOK = (sXML)? true : false;
				
				if (strAppState && strAppState == "restricted") {
					vi.videoRestricted = true;
					vi.videoRestrictedInfo = "";
				}
				
				//Logger.getInstance().addError(SOURCE_YOUTUBE+" data parsed OK:\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----");
				Logger.getInstance().addInfo(SOURCE_YOUTUBE+" info data of '"+vi.videoCode+"' parsed OK.");
			} catch(error:Error) {
				//Logger.getInstance().addError("Can't parse "+SOURCE_YOUTUBE+" data: "+error.message+"\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----");
				Logger.getInstance().addError("Can't parse "+SOURCE_YOUTUBE+" data: "+error.message,);
			}
			return vi;
		}*/
		
		
		// Deprecated YouTube API v2:
		/*private static function parseYouTubeInfo(strInfoData:String):VideoValidatorInfo {
			var vi:VideoValidatorInfo = new VideoValidatorInfo();
			var sXML:XML;
			var mediaNS:Namespace;
			var ytNS:Namespace;
			var appNS:Namespace;
			var strAppState:String;
			try {
				sXML = new XML(strInfoData);
				mediaNS = sXML.namespace("media");
				ytNS = sXML.namespace("yt");
				appNS = sXML.namespace("app");
				
				vi.videoSource = SOURCE_YOUTUBE;
				vi.videoTitle = sXML.mediaNS::group.mediaNS::title.text();
				vi.videoDuration = String(sXML.mediaNS::group.ytNS::duration.@seconds);
				vi.videoCode = sXML.mediaNS::group.ytNS::videoid.text();
				vi.videoStatusOK = (sXML)? true : false;
				
				if (appNS) strAppState = sXML.appNS::control.ytNS::state.@name;
				if (strAppState && strAppState == "restricted") {
					vi.videoRestricted = true;
					vi.videoStateCode = sXML.appNS::control.ytNS::state.@reasonCode;
					vi.videoStateInfo = sXML.appNS::control.ytNS::state.text();
					vi.videoMediaRestrictionType = sXML.mediaNS::group.mediaNS::restriction.@type;
					vi.videoMediaRestrictionRelationship = sXML.mediaNS::group.mediaNS::restriction.@relationship;
					vi.videoMediaRestrictionValue = sXML.mediaNS::group.mediaNS::restriction.text();
				}
				
				//Logger.getInstance().addError(SOURCE_YOUTUBE+" data parsed OK:\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----");
				Logger.getInstance().addEntry(SOURCE_YOUTUBE+" info data of '"+vi.videoCode+"' parsed OK.");
			} catch(error:Error) {
				//Logger.getInstance().addError("Can't parse "+SOURCE_YOUTUBE+" data: "+error.message+"\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----");
				Logger.getInstance().addError("Can't parse "+SOURCE_YOUTUBE+" data: "+error.message);
			}
			return vi;
		}*/
		// -------------------------- End of Parsers ------------------------- //
		
		
		// -------------------------- Data Validators ------------------------ //
		private static function validateXML(strSource:String, strInfoData:String):String {
			var strResultData:String;
			var startChar:String = "<?xml";
			var startCharIdx:int;
			var endChar:String = "</entry>";
			var endCharIdx:int;
			var strSourceInfoData:String;
			var strCleanInfoData:String;
			
			if (!XMLUtil.isValidXML(strInfoData)) {
				strSourceInfoData = "\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----\n";
				Logger.getInstance().addAlert("Invalid "+strSource+" Info Data found: "+strSourceInfoData+"Removing extra code before and after xml data...");
				startCharIdx = strInfoData.indexOf(startChar);
				endCharIdx = strInfoData.lastIndexOf(endChar) + endChar.length;
				if (endCharIdx == -1) endCharIdx = strInfoData.length - 1;
				if (startCharIdx != -1) {
					strInfoData = strInfoData.substring(startCharIdx, endCharIdx);
					strCleanInfoData = "\n----- Start of Data -----\n"+strInfoData+"\n----- End of Data -----\n";
					Logger.getInstance().addEntry(strSource+"Removing extra code done:"+strCleanInfoData);
				}
			}
			if (!XMLUtil.isValidXML(strInfoData)) {
				Logger.getInstance().addError("Invalid "+strSource+" Info Data");
			} else {
				strResultData = strInfoData;
			}
			return strInfoData;
		}
		// ----------------------- End of Data Validators -------------------- //
	}
}