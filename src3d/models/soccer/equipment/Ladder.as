package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class Ladder extends Equipment {
		[Embed(source="Ladder.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_004;
		
		public function Ladder(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_LADDER;
			
			// Properties.
			this._rotable = true;
			this._colorable = true;
			//this._elevatable = true;
			this._repeatable = false;
			this._internalScale = 1.2;
			this.controllerScale = 1.8;
			this.shadow.shadowScale(1, 6);
			this.shadow.shadowAlpha(0.7);
			//this.shadow.scale(.5);
			this.useShadow = true;
			
			// Init.
			initColors(objSettingsRef._equipColor);
			initObject();
			setMaterials();
			initElevation();
			applyGlobalScale();
			initObjectRepeater(objSettingsRef._pathData);
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
			_color2 = 0xFFCC00;
		}
		
		private function initObject():void {
			objContainer = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.name = "Ladder";
			objContainer.rotationX = -90;
			objContainer.y = 3;
			objContainer.addChild(shadow);
			shadow.shadowRotateX(90);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
		}
		
		protected override function setMaterials():void {
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().poles2_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1);
			var obj2_BitmapData:BitmapData = EquipmentTextures.getInstance().poles2_Bmd;
			obj2_BitmapData = ColorUtils.colorBmp(obj2_BitmapData, _color2);
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "ropes", true);
			ColorUtils.applyMaterialToMesh(objectSet, obj2_BitmapData, "steps");
		}
	}
}