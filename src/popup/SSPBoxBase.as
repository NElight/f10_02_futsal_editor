package src.popup
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class SSPBoxBase extends MovieClip
	{
		protected var _stage:Stage;
		
		// Stage Handler.
		protected var stageHandler:EventHandler;
		
		// Box Design.
		private static const boxHeaderHeightDefault:Number = 47.25;
		protected var box:MovieClip;
		private var _boxHeaderHeight:Number = 47.25;
		private var boxTitleMargin:int = 10;
		private var boxTitleTextSize:int = 22;
		private var boxInnerBgMarginL:Number = 10;
		private var boxInnerBgMarginR:Number = 10;
		private var boxInnerBgMarginT:Number = 10;
		private var boxInnerBgMarginB:Number = 10;
		private var _darkBGAlpha:Number = .5;
		private var boxMinW:Number = 150;
		private var boxMinH:Number = 150;
		private var useDarkBG:Boolean = true;
		private var boxW:Number = 400;
		private var boxH:Number = 200;
		private var dbgIdx:int = 0; // Dark Background layer index.
		private var boxIdx:int = 1; // Box layer index.
		private var _boxPadding:Number = 10;
		private var headerScale:Number = 1;
		private var _buttonCloseHeight:Number = 28.8; // 28.8 is the real size in flash library.
		
		// Box Colors.
		private var boxBorderThickness1:uint = 1;
		private var boxBorderThickness2:uint = 1;
		private var boxBorderColor1:uint = 0;
		private var boxBorderColor2:uint = 0xCCCCCC;
		private var boxInnerColor1:uint = 0xF5F5F5;
		private var boxInnerColor2:uint = 0xFFFFFF;
		private var boxHeaderColor1:uint = 0x009FD5; // Light SSP blue.
		private var boxHeaderColor2:uint = 0x0064A0; // Dark SSP blue.
		private var boxHeaderColor3:uint = 0x7ac7e2; // Extra light blue.
		private var boxTitleColor:uint = 0xFFFFFF;
		private var boxDropShadowColor:uint = 0x333333;
		private var darkBGColor:uint = 0;
		
		// Box Objects.
		protected var txtFormTitle:TextField;
		protected var btnFormClose:SSPButtonCloseForm;
		private var darkBG:Sprite;
		private var dropShadow:DropShadowFilter;
		
		// Contructor vars.
		private var content:DisplayObject;
		private var strFormTitle:String;
		private var initialBoxW:Number;
		private var initialBoxH:Number;
		private var autoCenter:Boolean;
		protected var centerContent:Boolean;
		private var _useInnerBg:Boolean;
		private var _usePadding:Boolean;
		private var _useHeader:Boolean;
		private var _useCloseBtn:Boolean;
		private var _useDarkerClose:Boolean;
		private var _useEscClose:Boolean;
		private var _useDropShadow:Boolean;
		
		public function SSPBoxBase(st:Stage, content:DisplayObject, formTitle:String = "", useInnerBg:Boolean = true, usePadding:Boolean = false, boxW:int = -1, boxH:int = -1,
								autoCenter:Boolean = true, useHeader:Boolean = true, useCloseBtn:Boolean = true, useDarkerClose:Boolean = true, useEscClose:Boolean = true, boxPadding:Number = 10,
								headerHeight:Number = boxHeaderHeightDefault, darkerAlpha:Number = .6
		) {
			this._stage = st;
			this.content = content;
			this.strFormTitle = formTitle;
			this._useInnerBg = useInnerBg;
			this._usePadding = usePadding;
			this.initialBoxW = boxW;
			this.initialBoxH = boxH;
			this.autoCenter = autoCenter;
			this._useHeader = useHeader;
			this._useCloseBtn = useCloseBtn;
			this._useDarkerClose = useDarkerClose;
			this._useEscClose = useEscClose;
			this._boxPadding = (usePadding)? boxPadding : boxBorderThickness1/2;
			this.headerScale = headerHeight / boxHeaderHeightDefault;
			this._boxHeaderHeight = headerHeight * headerScale;
			this._darkBGAlpha = darkerAlpha;
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			stageHandler = new EventHandler(_stage);
		}
		
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			updateBox();
			listenersEnabled = true;
		}
		
		public function updateBox():void {
			var shpBox:Shape = new Shape();
			var tmpX:Number;
			var tmpY:Number;
			var tmpW:Number;
			var tmpH:Number;
			var tmpHeaderH:Number = (_useHeader)? _boxHeaderHeight : 0;
			var tmpBoxTitleTextSize:Number = (headerScale < .6)? boxTitleTextSize * headerScale + 2 : boxTitleTextSize * headerScale; // Compensate small header title.
			var tmpPaddingL:Number = 0;
			var tmpPaddingR:Number = 0;
			var tmpPaddingT:Number = 0;
			var tmpPaddingB:Number = 0;
			
			if (_usePadding) {
				tmpPaddingL += boxPadding;
				tmpPaddingR += boxPadding;
				tmpPaddingT += boxPadding;
				tmpPaddingB += boxPadding;
			}
			if (_useInnerBg) {
				tmpPaddingL += boxInnerBgMarginL;
				tmpPaddingR += boxInnerBgMarginR;
				tmpPaddingT += boxInnerBgMarginT;
				tmpPaddingB += boxInnerBgMarginB;
			}
			
			// Box Size.
			if (content && (initialBoxW < 0)) {
				boxW = content.width;
			} else {
				boxW = initialBoxW;
			}
			if (content && (initialBoxH < 0)) {
				boxH = content.height;
			} else {
				boxH = initialBoxH;
			}
			if (boxW < boxMinW) boxW = boxMinW;
			if (boxH < boxMinH) boxH = boxMinH;
			if (_stage && boxW > _stage.stageWidth) boxW = _stage.stageWidth;
			if (_stage && boxH > _stage.stageHeight) boxH = _stage.stageHeight;
			
			boxW += boxBorderThickness1 + tmpPaddingL + tmpPaddingR;
			boxH += boxBorderThickness1 + tmpHeaderH + tmpPaddingT + tmpPaddingB;
			
			// Box Container.
			if (box && this.contains(box)) this.removeChild(box);
			box = new MovieClip();
			
			// Dark Background.
			updateDarkBG();
			
			// Main Box Shape.
			box.addChild(shpBox);
			
			// Outer Box.
			tmpX = boxBorderThickness1/2;
			tmpY = boxBorderThickness1/2;
			tmpW = boxW - (boxBorderThickness1/2);
			tmpH = boxH - (boxBorderThickness1/2);
			shpBox.graphics.lineStyle(boxBorderThickness1,boxBorderColor1);
			shpBox.graphics.beginFill(boxInnerColor1);
			shpBox.graphics.drawRect(tmpX,tmpY,tmpW,tmpH);
			shpBox.graphics.endFill();
			
			// Inner Bg.
			if (_useInnerBg) {
				tmpX = boxInnerBgMarginL;
				tmpY = boxInnerBgMarginT + tmpHeaderH;
				tmpW = boxW - (boxInnerBgMarginL+boxInnerBgMarginR);
				tmpH = boxH - (boxInnerBgMarginT+boxInnerBgMarginB+tmpHeaderH);
				shpBox.graphics.lineStyle(boxBorderThickness2,boxBorderColor2);
				shpBox.graphics.beginFill(boxInnerColor2);
				shpBox.graphics.drawRect(tmpX,tmpY,tmpW,tmpH);
				shpBox.graphics.endFill();
			}
			
			// Header.
			if (_useHeader) {
				tmpX = boxBorderThickness1;
				tmpY = boxBorderThickness1;
				tmpW = boxW - boxBorderThickness1;
				tmpH = tmpHeaderH;
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(tmpW, tmpH, Math.PI/2, 0, 0);
				shpBox.graphics.lineStyle();
				shpBox.graphics.beginGradientFill(GradientType.LINEAR,[boxHeaderColor1,boxHeaderColor2],[1,1],[0x00, 0xFF],matrix);
				shpBox.graphics.drawRect(tmpX,tmpY,tmpW,tmpH);
				shpBox.graphics.endFill();
				shpBox.graphics.lineStyle();
				shpBox.graphics.beginFill(boxHeaderColor3);
				shpBox.graphics.drawRect(tmpX,tmpY,tmpW,1);
				shpBox.graphics.endFill();
				
				// Form Title.
				if (!txtFormTitle) {
					txtFormTitle = new TextField();
					txtFormTitle.type = TextFieldType.DYNAMIC;
					var tf:TextFormat = new TextFormat("_sans", tmpBoxTitleTextSize, boxTitleColor);
					tf.align = TextFormatAlign.LEFT;
					txtFormTitle.defaultTextFormat = tf;
					txtFormTitle.name = "lblFormTitle";
					txtFormTitle.border = false;
					txtFormTitle.selectable = false;
					txtFormTitle.multiline = false;
					txtFormTitle.width = boxW - boxTitleMargin*2;
					txtFormTitle.height = tmpBoxTitleTextSize + boxTitleMargin;
					txtFormTitle.x = boxTitleMargin;
					txtFormTitle.y = (tmpHeaderH - txtFormTitle.height)/2;
					//txtFormTitle.maxChars = 100;
					//txtFormTitle.setTextFormat(tf); // Apply TextFormat settings to current format.
				}
				txtFormTitle.text = strFormTitle;
				box.addChild(txtFormTitle);
			}
			
			// Content.
			if (content) {
				var contentPos:Point;
				if (centerContent) {
					contentPos = MiscUtils.getPosToCenterInContainer(content, boxW, boxH);
					content.x = contentPos.x;
					content.y = (_useHeader)? contentPos.y + tmpHeaderH/2 : contentPos.y;
				} else {
					contentPos = (usePadding)? new Point(_boxPadding, _boxPadding) : new Point();
					content.x = contentPos.x;
					content.y = (_useHeader)? contentPos.y + tmpHeaderH : contentPos.y;
				}
				box.addChild(content);
				box.removeChild(content);
				box.addChild(content);
			}
			
			// Close Button.
			if (_useCloseBtn) {
				if (!btnFormClose) btnFormClose = new SSPButtonCloseForm();
				btnFormClose.x = boxW - (btnFormClose.width) - 7;
				btnFormClose.y = (tmpHeaderH - btnFormClose.height) / 2;
				btnFormClose.height = _buttonCloseHeight;
				btnFormClose.scaleX = btnFormClose.scaleY;
				if (btnFormClose.height > tmpHeaderH) {
					//btnFormClose.height = _buttonCloseHeight;
					//btnFormClose.scaleX = btnFormClose.scaleY;
					btnFormClose.y = 0;
				} else {
					//btnFormClose.scaleX = headerScale;
					//btnFormClose.scaleY = headerScale;
				}
				box.addChild(btnFormClose);
				if (_useHeader) txtFormTitle.width = btnFormClose.x - btnFormClose.width - boxTitleMargin;
			}
			
			// Drop Shadow.
			if (_useDropShadow) {
				if (!dropShadow) {
					dropShadow = new DropShadowFilter();
					dropShadow.distance = 5;
					dropShadow.angle = 45;
					dropShadow.color = boxDropShadowColor;
					dropShadow.alpha = 1;
					dropShadow.blurX = 10;
					dropShadow.blurY = 10;
					dropShadow.strength = .5; // Values from 0 to 255.
					dropShadow.quality = BitmapFilterQuality.LOW;
					dropShadow.inner = false;
					dropShadow.knockout = false;
					dropShadow.hideObject = false;
				}
				box.filters = new Array(dropShadow);
			} else {
				box.filters = [];
			}
			
			// Box Position.
			if (autoCenter) {
				var bcPos:Point = MiscUtils.getPosToCenterInContainer(box, _stage.stageWidth, _stage.stageHeight);
				box.x = bcPos.x;
				box.y = bcPos.y;
				
				// If box width is specified and content is bigger than specified box, fix offset in width.
				var offsetW:Number = box.width - initialBoxW;
				if (initialBoxW > -1 && offsetW > 0) box.x += offsetW / 2;
				
				// If box is bigger than stage, place it at 0,0.
				if (box.width > _stage.stageWidth) box.x = 0;
				if (box.height > _stage.stageHeight) box.y = 0;
			}
			
			this.addChildAt(box, boxIdx);
		}
		
		private function updateDarkBG():void {
			if (darkBG && this.contains(darkBG)) this.removeChild(darkBG);
			if (useDarkBG) {
				darkBG = new Sprite();
				darkBG.graphics.beginFill(darkBGColor, _darkBGAlpha);
				darkBG.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
				this.addChildAt(darkBG, dbgIdx);
			}
		}
		
		private function bringToFront():void {
			if (parent) parent.setChildIndex(this, parent.numChildren-1);
			this.visible = true;
		}
		
		
		
		// ----------------------------------- Events ----------------------------------- //
		protected function set listenersEnabled(lEnabled:Boolean):void {
			if (lEnabled) {
				if (_useCloseBtn && btnFormClose && !btnFormClose.hasEventListener(MouseEvent.CLICK)) btnFormClose.addEventListener(MouseEvent.CLICK, onBoxCloseClick, false, 0, true);
				if (_useDarkerClose && darkBG && !darkBG.hasEventListener(MouseEvent.CLICK)) {
					darkBG.addEventListener(MouseEvent.CLICK, onBoxDarkBGClick, false, 0, true);
				}
				if (_stage) {
					if (_useEscClose) stageHandler.addEventListener(KeyboardEvent.KEY_DOWN, onBoxKeyDown, false, 0, true);
				}
			} else {
				if (btnFormClose) btnFormClose.removeEventListener(MouseEvent.CLICK, onBoxCloseClick);
				if (darkBG) darkBG.removeEventListener(MouseEvent.CLICK, onBoxDarkBGClick);
				if (_stage) stageHandler.RemoveEvents();
			}
		}
		protected function onBoxCloseClick(e:MouseEvent):void {
			closeBox();
		}
		protected function onBoxDarkBGClick(e:MouseEvent):void {
			if (e.target == this.box || e.currentTarget == this.box) return;
			if (_stage) {
				var mousePos:Point = new Point(_stage.mouseX, _stage.mouseY);
				//if (MiscUtils.isObjectUnder2DPos(box, mousePos, _stage)) return;
				if (MiscUtils.objectContainsPoint(box, mousePos, _stage)) return;
			}
			closeBox();
		}
		protected function onBoxKeyDown(e:KeyboardEvent):void {
			var _lastKey:KeyboardEvent = e;
			if (!_lastKey) return;
			switch(_lastKey.keyCode){
				case Keyboard.ESCAPE:
					closeBox();
					break;
			}
		}
		// -------------------------------- End of Events ------------------------------- //
		
		
		
		protected function showBox():void {
			updateBox();
			bringToFront();
			listenersEnabled = true;
		}
		
		/**
		 * Override this class to set a default action before closing.
		 * For example if class is a message box, it can be used to dispatch an Event like OK, Cancel, etc. 
		 */		
		protected function closeBox():void {
			removeBox();
		}
		private function removeBox():void {
			this.visible = false;
			listenersEnabled = false;
			if (_stage) _stage.focus = _stage;
			if (this.parent) parent.removeChild(this);
		}
		
		public function set formTitle(value:String):void {
			strFormTitle = value;
			if (txtFormTitle) txtFormTitle.text = strFormTitle;
		}
		public function get formTitle():String { return strFormTitle; }
		
		public function get boxInnerBounds():Rectangle {
			var tmpPaddingL:Number = boxBorderThickness1 / 2;
			var tmpPaddingR:Number = boxBorderThickness1 / 2;
			var tmpPaddingT:Number = boxBorderThickness1 / 2;
			var tmpPaddingB:Number = boxBorderThickness1 / 2;
			if (_usePadding) {
				tmpPaddingL += boxPadding;
				tmpPaddingR += boxPadding;
				tmpPaddingT += boxPadding;
				tmpPaddingB += boxPadding;
			}
			if (_useInnerBg) {
				tmpPaddingL += boxInnerBgMarginL;
				tmpPaddingR += boxInnerBgMarginR;
				tmpPaddingT += boxInnerBgMarginT;
				tmpPaddingB += boxInnerBgMarginB;
			}
			if (_useHeader) tmpPaddingT += _boxHeaderHeight;
			return new Rectangle(tmpPaddingL, tmpPaddingT, boxW-tmpPaddingR, boxH-tmpPaddingB);
		}
		
		public function get boxWidth():Number { return box.width; }
		
		public function get boxHeight():Number { return box.height; }
		
		public function get useInnerBg():Boolean { return _useInnerBg; }
		
		public function get usePadding():Boolean { return _usePadding; }
		
		public function get useHeader():Boolean { return _useHeader; }
		public function set useHeader(value:Boolean):void {
			_useHeader = value;
		}
		
		public function get useCloseBtn():Boolean { return _useCloseBtn; }
		
		public function get useDarkerClose():Boolean { return _useDarkerClose; }
		
		public function get useEscClose():Boolean { return _useEscClose; }
		
		public function get useDropShadow():Boolean { return _useDropShadow; }
		public function set useDropShadow(value:Boolean):void {
			_useDropShadow = value;
		}
		
		public function get boxPadding():Number { return _boxPadding; }
		
		public function set boxHeaderHeight(value:Number):void {
			headerScale = value / boxHeaderHeightDefault;
			_boxHeaderHeight = value * headerScale;
		}
		
		public function set boxDarkerAlpha(value:Number):void {
			_darkBGAlpha = value;
		}
		
		public function set buttonCloseHeight(value:Number):void {
			_buttonCloseHeight = value;
		}
	}
}