package src.videos
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import src.controls.gallery.Thumbnail;
	import src.utils.FileLoader;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	
	public class VideoThumb extends Thumbnail
	{
		private var fileLoader:FileLoader = new FileLoader();
		private var eventHandler:EventHandler = new EventHandler(fileLoader);
		private var logger:Logger = Logger.getInstance();
		
		private var videoURL:String = "";
/*		private var videoCode:String = "";
		private var videoSource:String = "";
		private var videoTitle:String = "";
		private var _videoThumbLocation:String = "";
		private var videoDuration:String = "";
		private var videoSortOrder:int;*/
		
		private var _videoXML:XML;
		private var videoSettings:SSPVideoItem = new SSPVideoItem(-1);
		
		private var autoLoadThumb:Boolean;
		
		public function VideoThumb(videoXML:XML, thumbW:Number = 90, thumbH:Number = 90, autoLoadThumb:Boolean = false)
		{
			super(thumbW, thumbH, false);
			this.videoXML = videoXML;
			this.autoLoadThumb = autoLoadThumb;
		}
		
		protected override function init():void {
			bgAlpha = 1;
			bgColor = 0xF5F5F5;
			bgLineColor = 0x999999;
			alphaOut = 0;
			alphaOver = 0.5;
			alphaDown = 0.7;
			super.init();
		}
		
		protected override function onMouseClickHandler(e:MouseEvent):void {
			super.onMouseClickHandler(e);
			main.videoPlayer.openVideo(videoSettings);
		}
		
		private function loadThumb():void {
			if (!autoLoadThumb) return;
			eventHandler.addEventListener(SSPEvent.SUCCESS, onThumbLoadOK);
			eventHandler.addEventListener(SSPEvent.ERROR, onLoadError);
			fileLoader.loadFile(videoURL, true, false, true);
		}
		
		private function onThumbLoadOK(e:SSPEvent):void {
			eventHandler.RemoveEvents();
			var bmp:Bitmap = e.eventData as Bitmap;
			if (!bmp) logger.addText("Invalid data loading file '"+videoURL+"'.", true);
			showThumb(bmp);
		}
		
		private function onLoadError(e:SSPEvent):void {
			logger.addText("Error loading file '"+videoURL+"'.", true);
			eventHandler.RemoveEvents();
			showThumb();
		}
		
		public function set videoXML(vXML:XML):void {
			_videoXML = vXML;
			var _interfaceBaseURL:String = SessionGlobals.getInstance().sessionDataXML.session._interfaceBaseUrl.text();
			videoSettings = new SSPVideoItem(-1);
			videoSettings.videoTitle = _videoXML._videoTitle.text();
			videoSettings.videoDuration = _videoXML._videoDuration.text();
			videoSettings.videoCode = _videoXML._videoCode.text();
			videoSettings.videoSource = _videoXML._videoSource.text();
			videoSettings.videoSortOrder = int(_videoXML._sortOrder.text());
			videoSettings.videoThumbLocation = _interfaceBaseURL+_videoXML._thumbnailLocation.text();
			updateThumbnailText(videoSettings.videoTitle, videoSettings.videoDuration);
			loadThumb();
		}
		
		public override function dispose():void {
			eventHandler.RemoveEvents();
			eventHandler = null;
			fileLoader = null;
			logger = null;
			_videoXML = null;
			super.dispose();
		}
		
		public function get videoThumbLocation():String {
			return videoSettings.videoThumbLocation;
		}
	}
}