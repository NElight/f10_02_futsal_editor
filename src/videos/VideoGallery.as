package src.videos
{
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	
	import src.controls.gallery.Gallery;
	import src.controls.gallery.Thumbnail;
	import src.utils.BatchLoader;
	import src.utils.BatchLoaderEvent;
	import src.utils.BatchLoaderItem;
	
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	
	public class VideoGallery extends Gallery
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var thumbLoader:BatchLoader = new BatchLoader();
		private var thumbLoaderEventHandler:EventHandler = new EventHandler(thumbLoader);
		
		private var vList:Vector.<Thumbnail>;
		private var videoCols:uint = 5;
		private var videoRows:uint = 0; // Unlimited.
		
		public function VideoGallery(w:Number, h:Number) {
			super(0, 0, w, h, videoCols, videoRows);
			this.setData(getVideoList());
		}
		
		private function getVideoList():Vector.<Thumbnail> {
			getThumbSize();
			vList = new Vector.<Thumbnail>();
			var videoXMLList:XMLList = sG.sessionDataXML.video;
			var videoThumb:VideoThumb
			videoXMLList = MiscUtils.sortXMLList(videoXMLList, "_sortOrder");
			for (var i:uint = 0;i<videoXMLList.length();i++) {
				videoThumb = new VideoThumb(videoXMLList[i], thumbW, thumbH);
				vList.push(videoThumb);
				thumbLoader.add(videoThumb.videoThumbLocation, i, true, false); // Create Loader Data.
			}
			loadThumbs();
			return vList;
		}
		
		// ----------------------------------- Thumbnails ----------------------------------- //
		private function loadThumbs():void {
			if (!vList || vList.length == 0) return;
			thumbLoaderEventHandler.RemoveEvents();
			thumbLoaderEventHandler.addEventListener(BatchLoaderEvent.FILE_COMPLETE, onThumbLoadOK);
			thumbLoaderEventHandler.addEventListener(BatchLoaderEvent.FILE_ERROR, onThumbLoadError);
			thumbLoaderEventHandler.addEventListener(BatchLoaderEvent.ALL_COMPLETE, onThumbLoadAllComplete);
			thumbLoader.start();
		}
		
		private function onThumbLoadOK(e:BatchLoaderEvent):void {
			var itemIdx:int = e.eventData.index;
			var item:BatchLoaderItem = e.eventData.item as BatchLoaderItem;
			var bmp:Bitmap = e.eventData.data as Bitmap;
			if (!bmp) logger.addText("Invalid image data loaded from '"+item.location+"'.", true);
			showThumb(bmp, itemIdx);
		}
		
		private function onThumbLoadError(e:BatchLoaderEvent):void {
			var item:BatchLoaderItem = e.eventData.item as BatchLoaderItem;
			var lInfo:String = " '"+item.location+"'";
			var message:String = String(e.eventData.message);
			logger.addAlert("Can't load video thumbnail"+lInfo+":\n "+message);
			showThumb(null, item.index);
		}
		
		private function onThumbLoadAllComplete(e:BatchLoaderEvent):void {
			thumbLoaderEventHandler.RemoveEvents();
		}
		
		private function showThumb(bmp:Bitmap, itemIdx:int):void {
			vList[itemIdx].showThumb(bmp);
		}
		// -------------------------------- End of Thumbnails ------------------------------- //
		
		public override function get galleryEnabled():Boolean {
			return _galleryEnabled;
		}
		public override function set galleryEnabled(value:Boolean):void {
			super.galleryEnabled = value;
			this.visible = value;
		}
	}
}