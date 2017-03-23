package src3d.models.soccer.players
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import src3d.text.Text2D;
	import src3d.utils.ColorUtils;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.ModelUtils;
	
	public class PlayerDisc extends ObjectContainer3D
	{
		private var objectA:Sprite3D;
		private var objectAMouse:Sprite3D;
		private var objectMat:BitmapMaterial;
		private var discShape:Shape;
		private var discHighlightShape:Shape;
		private var spriteDistance:uint = 40;
		
		private var _color1:uint;
		private var _color2:uint;
		private var _colorH:uint = 0x99FFFF;
		private var _objSettingsRef:PlayerSettings;
		
		private var _nameSize:uint = 14;
		private var _numberSize:uint = 15;
		private var _discRadius:uint = 12;
		private var _highlightDisc:Boolean;
		private var _highlightWidth:uint = 4;
		
		// Settings.
		public var displayDisc:Boolean;
		public var displayNumber:Boolean;
		public var displayName:Boolean;
		public var displayPosition:Boolean;
		
		public function PlayerDisc(color1:uint, color2:uint, objSettingsRef:PlayerSettings)
		{
			if (color1 == 0) color1 = 0x222222;
			if (color2 == 0) color2 = 0x222222;
			this._color1 = color1;
			this._color2 = color2;
			this._objSettingsRef = objSettingsRef;
			initObject();
			initMouseArea();
			updateDisc();
			this.mouseEnabled = true;
		}
		
		private function initObject():void {
			objectA = new Sprite3D();
			objectA.distanceScaling = false;
			if (!displayDisc) objectA.z = spriteDistance;
		}
		
		private function initMouseArea():void {
			var mouseMat:ColorMaterial = new ColorMaterial(0xFFFFFF, {alpha:0});
			if (!discShape) initDiscShape();
			objectAMouse = new Sprite3D(mouseMat, discShape.width, discShape.height);
			objectAMouse.distanceScaling = false;
			if (!displayDisc) objectAMouse.z = spriteDistance;
		}
		
		private function initDiscShape():void {
			discShape = ColorUtils.createShapeCircle(0, 0, _discRadius, _color1, 1, 1.5, _color2);
			discHighlightShape = ColorUtils.createShapeCircle(0, 0, _discRadius+_highlightWidth, _colorH, 1, 0, 0);
		}
		
		public function updateDisc(col1:Number = NaN, col2:Number = NaN):void {
			if (!isNaN(col1)) {
				_color1 = col1;
				if (_color1 == 0) _color1 = 0x222222;
			}
			if (!isNaN(col2)) {
				_color2 = col2;
				if (_color2 == 0) _color2 = 0x222222;
			}
			initDiscShape();
			if (objectA) {
				objectA.material = null;
				this.removeSprite(objectA);
				this.removeSprite(objectAMouse);
			}
			objectMat = null;
			var sprDisc:Sprite = new Sprite();
			var strText:String = "";
			if (displayDisc) {
				displayNumber = true;
				if (_highlightDisc) {
					sprDisc.addChild(discHighlightShape);
				}
				//discShape.y = -discShape.height/2;
				sprDisc.addChild(discShape);
			}
			if (displayDisc && displayNumber) {
				var strNumber:String = (_objSettingsRef._playerNumber == "")? "<b>"+_objSettingsRef._playerInitials+"</b>" : "<b>"+_objSettingsRef._playerNumber+"</b>";
				var textColor:uint = ColorUtils.getColorContrast(_color1);
				var numberBmp:Bitmap = Text2D.getInstance().getCustomTextBmp(strNumber, true, _numberSize, TextFormatAlign.CENTER, textColor, false, 0);
				numberBmp.x = -numberBmp.width/2;
				numberBmp.y = -numberBmp.height/2;
				sprDisc.addChild(numberBmp);
			}
			if (displayName) {
				strText = "<p><b>";
				if (!displayDisc && displayNumber) strText += _objSettingsRef._playerNumber+" ";
				strText += _objSettingsRef._playerName+"</b><br />";
			} else {
				if (!displayDisc && displayNumber) strText = "<p><b>"+_objSettingsRef._playerNumber+"</b><br />";
			}
			if (displayPosition) {
				strText += _objSettingsRef._playerPositionName+"</p>";
			}
			
			var txtBmp:Bitmap = Text2D.getInstance().getCustomTextBmp(strText, true, _nameSize, TextFormatAlign.CENTER);
			txtBmp.x = -txtBmp.width/2;
			txtBmp.y = discShape.height/2;
			sprDisc.addChild(txtBmp);
			
			if (sprDisc.width == 0 || sprDisc.height == 0) {
				this.removeSprite(objectA);
				this.removeSprite(objectAMouse);
				return;
			} else {
				this.addSprite(objectA);
				this.addSprite(objectAMouse);
				//objectAMouse.y = sprDisc.y;
				objectAMouse.height = sprDisc.height;
			}
			var matBmd:BitmapData = MiscUtils.takeScreenshot(sprDisc, true,0x00CCCCCC,true).bitmapData;
			if (!matBmd) {
				Logger.getInstance().addText("(A) - Can't get Payer Disc material. Using default colors", false);
				discShape = ColorUtils.createShapeCircle(0, 0, _discRadius, 0x111111, 1, 1.5, 0x666666);
				sprDisc.addChildAt(discShape,0);
				matBmd = MiscUtils.takeScreenshot(sprDisc, true,0x00CCCCCC,true).bitmapData;
			}
			if (!matBmd) {
				Logger.getInstance().addText("Error getting Payer Disc material", true);
				this.removeSprite(objectA);
				this.removeSprite(objectAMouse);
				return;
			}
			objectMat = new BitmapMaterial(matBmd, {smooth: true});
			objectA.material = null;
			objectA.material = objectMat;
			objectA.z = (!displayDisc)? spriteDistance : 0;
			objectA.y = (!_highlightDisc)? objectA.height/2 : objectA.height/2 + _highlightWidth*2;
			
			objectAMouse.y = objectA.y;
			objectAMouse.z = objectA.z;
		}
		
		public function get highlightDisc():Boolean {
			return _highlightDisc;
		}
		
		public function set highlightDisc(value:Boolean):void {
			_highlightDisc = value;
			updateDisc();
		}
		
		public function dispose():void {
			objectA.material = null;
			objectAMouse.material = null;
			ModelUtils.clearObjectContainer3D(this, true, true);
			
			objectA = null;
			objectAMouse = null;
			objectMat = null
			this.ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}