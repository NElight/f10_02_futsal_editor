package src.videos
{
	import src.utils.VideoValidatorUtils;

	public class SSPVideoItem
	{
		public var screenId:int;
		public var videoSource:String = "";
		public var videoCode:String = "";
		public var videoTitle:String = "";
		public var videoDuration:String = "";
		public var videoSortOrder:int;
		public var videoThumbLocation:String = "";
		public var preValidateLocation:String = ""; // User location not yet validated.
		public var videoValidated:Boolean = true; // Validated = true does not implies valid.
		
		public function SSPVideoItem(screenId:int, videoSource:String = "", videoCode:String = "", videoTitle:String = "", videoDuration:String = "", videoSortOrder:int = 0, videoThumbLocation:String = "", videoValidated:Boolean = true, preValidateLocation:String = "")
		{
			this.screenId = screenId;
			this.videoSource = videoSource;
			this.videoCode = videoCode;
			this.videoTitle = videoTitle;			
			this.videoDuration = videoDuration;
			this.videoSortOrder = videoSortOrder;
			this.videoThumbLocation = videoThumbLocation;
			this.videoValidated = videoValidated;
			this.preValidateLocation = preValidateLocation;
		}
		
		public function get playExternally():Boolean {
			return VideoValidatorUtils.getPlayExternally(this.videoSource);
		}
	}
}