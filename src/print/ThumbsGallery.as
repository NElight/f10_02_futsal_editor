package src.print
{
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	
	import src.controls.gallery.Gallery;
	import src.controls.gallery.Thumbnail;
	
	import src3d.SessionGlobals;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	
	public class ThumbsGallery extends Gallery
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		private var videoCols:uint = 5;
		private var videoRows:uint = 0; // Unlimited.
		
		public function ThumbsGallery(w:Number, h:Number) {
			super(0, 0, w, h, videoCols, videoRows);
			this.setContent(getVideoList());
		}
		
		private function getVideoList():Vector.<Thumbnail> {
			getThumbSize();
			var vList:Vector.<Thumbnail> = new Vector.<Thumbnail>();
			var videoXMLList:XMLList = sG.sessionDataXML.video;
			videoXMLList = MiscUtils.sortXMLList(videoXMLList, "_sortOrder");
			for each(var xml:XML in videoXMLList) {
				vList.push(new VideoItem(xml, thumbW, thumbH));
			}
			return vList;
		}
		
		public override function get galleryEnabled():Boolean {
			return _galleryEnabled;
		}
		public override function set galleryEnabled(value:Boolean):void {
			super.galleryEnabled = value;
			this.visible = value;
		}
	}
}