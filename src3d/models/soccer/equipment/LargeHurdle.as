package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class LargeHurdle extends Equipment {
		[Embed(source="LargeHurdle.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_013;
		
		public function LargeHurdle(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_LARGE_HURDLE;
			
			// Properties.
			this._rotable = true;
			this._colorable = true;
			//this._elevatable = true;
			this._repeatable = true;
			this._internalScale = 4;
			this.controllerScale = 1.4;
			this.shadow.shadowScale(.4, .2);
			//this.shadow.scale(1);
			//this.useShadow = false;
			
			// Init.
			initColors(objSettingsRef._equipColor);
			initObject();
			setMaterials();
			initElevation();
			applyGlobalScale();
			initObjectRepeater(objSettingsRef._pathData, 150);
			initRotator();
			init2DButtons();
		}
		
		private function initColors(newCol:int):void {
			_color1default = 0xFF0000;
			if (this._colorable) {
				_color1 = (newCol > -1)? newCol : _color1default;
			} else {
				_color1 = _color1default;
			}
			//_color2 = 0xCCCCCC;
		}
		
		private function initObject():void {
			objContainer = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.name = "LargeHurdle";
			objContainer.rotationX = 90;
			objContainer.rotationY = 180;
			objContainer.addChild(shadow);
			shadow.shadowRotateX(-90);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
			this._mainContainerHeight = 72;
		}
		
		protected override function setMaterials():void {
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().square_gradient_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1);
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "mesh");
		}
	}
}