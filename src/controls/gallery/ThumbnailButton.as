package src.controls.gallery
{
	import fl.controls.CheckBox;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	import src.SSPLogo;
	
	import src3d.utils.ColorUtils;
	import src3d.utils.MiscUtils;
	
	public class ThumbnailButton extends Sprite
	{
		protected var thumbW:Number;
		protected var thumbH:Number;
		protected var thumbWFull:Number;
		protected var thumbHFull:Number;
		protected var thumbPadding:Number = 2;
		protected var bgAlpha:uint = 0;
		//protected var bgColor:uint = 0xeaeaea;
		protected var bgColor:uint = 0xFFFFFF;
		protected var bgLineColor:uint = 0xF5F5F5;
		protected var selectColor:uint = 0x99D7FE;
		protected var selectLineColor:uint = 0x99D7FE;
		//protected var areaColor:uint = 0xFFFFFF;
		//protected var areaLineColor:uint = 0x666666;
		protected var areaColor:uint = 0x99D7FE;
		protected var areaLineColor:uint = 0x99D7FE;
		
		protected var alphaOut:Number = 0;
		protected var alphaOver:Number = 0.2;
		protected var alphaDown:Number = 0.7;
		protected var alphaSelected:Number = 0.3;
		
		protected var thumb:Bitmap;
		protected var bg:Sprite;
		protected var btnArea:Sprite;
		protected var bgSelect:Sprite;
		protected var cbxSelect:CheckBox;
		protected var logoScale:Number = 0.75;
		
		private var _selectable:Boolean;
		private var _selected:Boolean;
		
		public function ThumbnailButton(thumbW:Number = 50, thumbH:Number = 50, selectable:Boolean = false, thumbWFull:Number = NaN, thumbHFull:Number = NaN)
		{
			this.thumbW = thumbW;
			this.thumbH = thumbH;
			this.thumbWFull = (isNaN(thumbWFull))? thumbW : thumbWFull;
			this.thumbHFull = (isNaN(thumbHFull))? thumbH : thumbHFull;
			this._selectable = selectable;
			init();
			this.buttonMode = true;
			this.useHandCursor = true;
			initListeners();
		}
		
		protected function init():void {
			createControls();
			addControls();
		}
		
		protected function createControls():void {
			bgSelect = ColorUtils.createSprite(0,0,thumbW, thumbHFull, selectColor, alphaSelected, true, selectLineColor, 1);
			bgSelect.visible = false;
			
			bg = ColorUtils.createSprite(0,0,thumbW, thumbHFull, bgColor, bgAlpha, false, bgLineColor, 1);
			var logoSizeWH:Number = (thumbW > thumbH)? thumbH * logoScale : thumbW * logoScale
			var sspLogo:MovieClip = new SSPLogo(true, thumbW, thumbH, logoSizeWH, logoSizeWH);
			sspLogo.visible = true;
			bg.addChild(sspLogo);
			
			if (_selectable) {
				cbxSelect = new CheckBox();
				cbxSelect.label = "";
				cbxSelect.tabEnabled = false;
				cbxSelect.move(2,2);
				cbxSelect.opaqueBackground = 0xFFFFFF;
				this.addChild(cbxSelect);
			}
			btnArea = ColorUtils.createSprite(0,0,thumbW, thumbHFull, areaColor, 1, true, areaLineColor, 1);
			btnArea.alpha = 0;
			btnArea.buttonMode = true;
		}
		
		protected function addControls():void {
			this.addChild(bgSelect);
			this.addChild(bg);
			this.addChild(btnArea);
		}
		
		
		
		// ----------------------------- Events ----------------------------- //
		protected function initListeners():void {
			btnArea.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler, false, 0, true);
			btnArea.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler, false, 0, true);
			btnArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
			btnArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler, false, 0, true);
			btnArea.addEventListener(MouseEvent.CLICK, onMouseClickHandler, false, 0, true);
		}
		
		protected function removeListeners():void {
			btnArea.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			btnArea.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			btnArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			btnArea.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			btnArea.removeEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		protected function onMouseClickHandler(e:MouseEvent):void {
			if (_selectable) {
				if (_selected) {
					deselectThumb();
				} else {
					selectThumb();
				}
			}
		}
		
		protected function onMouseOverHandler(e:MouseEvent):void {
			btnArea.alpha = alphaOver;
		}
		protected function onMouseOutHandler(e:MouseEvent):void {
			btnArea.alpha = alphaOut;
		}
		protected function onMouseDownHandler(e:MouseEvent):void {
			btnArea.alpha = alphaDown;
		}
		protected function onMouseUpHandler(e:MouseEvent):void {
			btnArea.alpha = alphaOver;
		}
		// -------------------------- End of Events ------------------------- //
		
		
		
		public function showThumb(bmp:Bitmap = null):void {
			if (thumb && this.contains(thumb)) this.removeChild(thumb);
			if (!bmp) return;
			thumb = bmp;
			thumb.smoothing = true;
			thumb.width = thumbW - thumbPadding*2;
			thumb.height = thumbH - thumbPadding*2;
			thumb.x = thumbPadding;
			thumb.y = thumbPadding;
			this.addChild(thumb);
			if (_selectable && cbxSelect) this.setChildIndex(cbxSelect, this.numChildren-1);
			this.setChildIndex(btnArea, this.numChildren-1);
		}
		
		protected function selectThumb():void {
			if (!_selectable) return;
			_selected = true;
			cbxSelect.selected = true;
			bgSelect.visible = true;
		}
		
		protected function deselectThumb():void {
			_selected = false;
			cbxSelect.selected = false;
			bgSelect.visible = false;
		}
		
		public function get selectable():Boolean {
			return _selectable;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean):void {
			if (value) {
				selectThumb();
			} else {
				deselectThumb();
			}
		}
		
		public function get hasThumbnailImage():Boolean {
			return (thumb && this.contains(thumb))? true : false;
		}
		
		public function get thumbnailW():Number {
			return thumbW - thumbPadding*2;
		}
		
		public function get thumbnailH():Number {
			return thumbH - thumbPadding*2;
		}
		
		public function dispose():void {
			removeListeners();
			if (this.parent) this.parent.removeChild(this);
		}
	}
}