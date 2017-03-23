package src.images
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import src3d.utils.ColorUtils;
	import src3d.utils.EventHandler;
	import src3d.utils.ImageUtils;

	public class SSPImageViewer extends MovieClip
	{
		private var eventHandler:EventHandler;
		private var _main:main;
		private var _stage:Stage;
		private var container:DisplayObjectContainer;
		private var bg:Shape = new Shape();
		private var bgColor:uint = 0;
		
		private var img:Bitmap;
		
		public function SSPImageViewer(container:DisplayObjectContainer, ref:main, bgAlpha:Number = .5)
		{
			// The container will be 'stage' for editor, 'main' for viewer.
			// At the moment all user interface containers are stored in 'main', except popup boxes.
			// Settings it to 'stage' allows the image to be on top of the other popup boxes.
			this.container = container;
			this._main = ref;
			this._stage = _main.stage;
			bg = ColorUtils.createShape(0, 0, _stage.stageWidth, _stage.stageHeight, bgColor, bgAlpha);
			this.addChild(bg);
			eventHandler = new EventHandler(this);
			this.mouseEnabled = true;
		}
		
		public function openImage(newImg:Bitmap):void {
			closeImage();
			if (!newImg) return;
			img = ImageUtils.fitImageForContainer(newImg, this, true, 0, false);
			if (!img) return;
			this.addChild(img);
			container.addChild(this);
			container.setChildIndex(this, container.numChildren-1);
			_main.bringPadContainerToFront();
			_main.bringPopupToolbarContainerToFront();
			eventHandler.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		private function onMouseClickHandler(e:MouseEvent):void {
			closeImage();
		}
		
		public function closeImage():void {
			eventHandler.RemoveEvents();
			if (img && img.parent) img.parent.removeChild(img);
			img = null;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}