package src3d.text
{
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.Bitmap;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	
	public class Billboard extends Equipment {
		
		private var objSettingsRef:TextSettings;
		
		private var _objectBmp:Bitmap;
		protected var textLibraryId:int = TextLibrary.TYPE_TEXT_CHAR;
		
		public function Billboard(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as TextSettings;
			super(sessionScreen, objSettings);
			objSettingsRef._objectType = ObjectTypeLibrary.OBJECT_TYPE_TEXT; // The type of object, used for xml storing and array classification.
			objSettingsRef._libraryId = textLibraryId; // Force Id in text 3d objects. In extending classes, it needs textLibraryId previously set.
			// Properties.
			this._rotable = false;
			this._scalable = false;
			this._internalScale = 1;
			this.controllerScale = .6;
			//this.shadow.scaleZ = .6;
			this.shadow.scale(.4);
			this.useShadow = true;
			this.name = objSettingsRef._textBmp.name;
			
			// Note: For single charcarters, movieclip are named Char_X, where X is the character.
			_objectBmp = objSettingsRef._textBmp;
			initObject();
			_rotator.rotatorEnabled = false;
		}
		
		private function initObject():void {
			var sprite:Sprite3D = new Sprite3D(new BitmapMaterial(_objectBmp.bitmapData, {smooth: true}),_objectBmp.width,_objectBmp.height);
			//sprite.scaling = _internalScale;
			sprite.distanceScaling = false;
			sprite.y = sprite.height/2;
			
			var cm:ColorMaterial = new ColorMaterial(0xFFFFFF);
			cm.alpha = 0;
			var mouseArea:Sprite3D = new Sprite3D(cm,sprite.width,sprite.height);
			//mouseArea.scaling = _internalScale;
			mouseArea.distanceScaling = false;
			mouseArea.y = sprite.y;
			
			//this.mouseEnabled = true;
			//this.useHandCursor = true;
			this.objContainer.addSprite(mouseArea);
			this.objContainer.addSprite(sprite);
			this.addToMainContainer(objContainer);
		}
		
		public function set textContent(newTxt:String):void { objSettingsRef._textContent = (newTxt != null)? newTxt : ""; }
		public function get textContent():String { return objSettingsRef._textContent; }
		
		public function set textContent2(newTxt:String):void { objSettingsRef._textContent2 = (newTxt != null)? newTxt : ""; }
		public function get textContent2():String { return objSettingsRef._textContent2; }
		
		public function set textStyle(newTxt:String):void { objSettingsRef._textStyle = (newTxt != null)? newTxt : ""; }
		public function get textStyle():String { return objSettingsRef._textStyle; }
		
		protected override function get objSettings():SSPObjectBaseSettings {
			return objSettingsRef;
		}
		protected override function updateObjSettings():SSPObjectBaseSettings {
			super.updateObjSettings();
			return objSettingsRef;
		}
		
		public override function dispose():void {
			super.dispose();
			objSettingsRef = null;
			_objectBmp = null;
		}
	}
}