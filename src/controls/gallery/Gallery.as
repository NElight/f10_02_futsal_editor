package src.controls.gallery
{
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import src.print.PrintThumb;
	
	import src3d.ScreenshotItem;
	import src3d.utils.ColorUtils;
	
	public class Gallery extends MovieClip
	{
		protected var galleryW:Number = 642;
		protected var galleryH:Number = 101;
		protected var thumbW:Number = 100;
		protected var thumbH:Number = 90;
		protected var thumbSpace:Number = 5;
		protected var padding:Number = 5;
		protected var cols:uint = 5;
		protected var rows:uint = 0; // Unlimited.
		
		protected var content:MovieClip = new MovieClip();
		protected var scrollPane:ScrollPane = new ScrollPane();
		protected var shpClear:Shape;
		
		protected var vThumbs:Vector.<Thumbnail>;
		
		protected var _galleryEnabled:Boolean = true;
		
		public function Gallery(xPos:Number, yPos:Number, w:Number, h:Number, cols:uint, rows:uint) {
			this.x = xPos;
			this.y = yPos;
			this.galleryW = w;
			this.galleryH = h;
			this.cols = cols;
			this.rows = rows;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			initScrollPane();
		}
		
		protected function initScrollPane():void {
			scrollPane.enabled = true;
			scrollPane.horizontalScrollPolicy = ScrollPolicy.OFF;
			scrollPane.horizontalLineScrollSize = 4;
			scrollPane.horizontalPageScrollSize = 0;
			scrollPane.scrollDrag = false; // Set to false to avoid Error #1009: Cannot access a property or method of a null object reference. at fl.containers::ScrollPane/endDrag().
			scrollPane.verticalScrollPolicy = ScrollPolicy.ON;
			scrollPane.verticalLineScrollSize = 4;
			scrollPane.verticalPageScrollSize = 0;
			scrollPane.visible = true;
			scrollPane.width = galleryW;
			scrollPane.height = galleryH;
			
			var spBg:Shape = new Shape();
			spBg.graphics.lineStyle(1,0xCCCCCC);
			spBg.graphics.beginFill(0xFFFFFF, 1);
			spBg.graphics.drawRect(0,0,galleryW,galleryH);
			spBg.graphics.endFill();
			
			//scrollPane.setStyle("contentPadding", 5);
			scrollPane.setStyle("skin", spBg);
			scrollPane.setStyle("upSkin", spBg); // ScrollPane_upSkin
			this.addChild(scrollPane);
			scrollPane.drawNow();
			scrollPane.source = content;
		}
		
		public function setData(newThumbs:Vector.<Thumbnail>):void {
			if (vThumbs) {
				for each(var thumb:Thumbnail in vThumbs) {
					thumb.dispose();
					thumb = null;
				}
			}
			if (shpClear && shpClear.parent) shpClear.parent.removeChild(shpClear);
			
			if (!newThumbs) return;
			vThumbs = newThumbs;
			
			var xPos:Number = 0+padding;
			var yPos:Number = 0+padding;
			var colCounter:int = 1;
			// Get thumbnail width and height.
			getThumbSize();
			// Add thumbnails.
			for each(var thumb:Thumbnail in vThumbs) {
				thumb.x = xPos;
				thumb.y = yPos;
				content.addChild(thumb);
				xPos += thumbW + thumbSpace;
				colCounter++;
				if (colCounter > cols) {
					colCounter = 1;
					xPos = 0 + padding;
					yPos += thumbH + thumbSpace;
				}
			}
			// Add extra space for scrollPane content.
			if (!shpClear) shpClear = ColorUtils.createShape(0,0,2,2,0xF5F5F5,1);
			shpClear.y = yPos + thumbH + padding;
			content.addChild(shpClear);
			scrollPane.source = content;
		}
		
		public function getThumbSize():Rectangle {
			var totalSpace:Number = thumbSpace*(cols-1);
			var realW:Number = galleryW - (padding*2) - totalSpace - scrollPane.verticalScrollBar.width;
			thumbW = realW / cols;
			var realH:Number = galleryH - (padding*2);
			thumbH = (thumbW > realH)? realH : thumbW;
			return new Rectangle(0,0,thumbW,thumbH);
		}
		
		public function galleryReset():void {
			this.setData(new Vector.<Thumbnail>());
		}
		
		public function gallerySelectAll():void {
			for each(var thumb:Thumbnail in vThumbs) {
				thumb.selected = true;
			}
		}
		
		public function gallerySelectNone():void {
			for each(var thumb:Thumbnail in vThumbs) {
				thumb.selected = false;
			}
		}
		
		public function gallerySelectThumb(t:Thumbnail):void {
			if (!t) return;
			t.selected = true;
		}
		
		public function get galleryEnabled():Boolean {
			return _galleryEnabled;
		}
		public function set galleryEnabled(value:Boolean):void {
			_galleryEnabled = value;
			scrollPane.enabled = _galleryEnabled;
			scrollPane.tabEnabled = _galleryEnabled;
			if (_galleryEnabled) {
				
			}
		}
		
		public function get galleryThumbnails():Vector.<Thumbnail> {
			return vThumbs;
		}
	}
}