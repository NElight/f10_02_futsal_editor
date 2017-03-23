package src.utils
{
	public class VideoValidatorSettings
	{
		public var source:String = "";
		public var base:String = "";
		public var params:String = "";
		public var baseAPI:String = "";
		public var paramsAPI:String = "";
		public var info:String = "";
		public var infoParams:String = "";
		public var playExternally:Boolean;
		
		public function VideoValidatorSettings(source:String, base:String, params:String, baseAPI:String, paramsAPI:String, info:String, infoParams:String, playExternally:Boolean)
		{
			this.source = source;
			this.base = base;
			this.params = params;
			this.baseAPI = baseAPI;
			this.paramsAPI = paramsAPI;
			this.info = info;
			this.infoParams = infoParams;
			this.playExternally = playExternally;
		}
		
		public function getLocation(strCode:String):String {
			return base + strCode + params;
		}
		
		public function getAPILocation(strCode:String):String {
			return baseAPI + strCode + paramsAPI;
		}
		
		public function getInfoLocation(strCode:String):String {
			if (info == "") return VideoValidator.NO_INFO;
			return info + strCode + infoParams;
		}
		
		public function clone():VideoValidatorSettings {
			return new VideoValidatorSettings(source, base, params, baseAPI, paramsAPI, info, infoParams, playExternally);
		}
	}
}