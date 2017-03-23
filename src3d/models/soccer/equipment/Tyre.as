package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class Tyre extends Equipment {
		[Embed(source="Tyre.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_024;
		
		public function Tyre(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_CAR_TYRE;
			
			// Properties.
			this._scalable = true;
			this._rotable = true;
			this._colorable = false;
			//this._elevatable = true;
			this._repeatable = true;
			this._internalScale = 1;
			this.controllerScale = 1;
			this.useShadow = true;
			this.shadow.shadowScale(1.2, 1.2);
			//this.shadow.shadowAlpha(.4);
			//this.shadow.shadowRotateX(-90);
			
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
			_color1default = 0x00FFFFFF;
			if (this._colorable) {
				_color1 = (newCol > -1)? newCol : _color1default;
			} else {
				_color1 = _color1default;
			}
			_color2 = 0xCCCCCC;
		}
		
		private function initObject():void {
			objContainer = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.name = EquipmentLibrary.NAME_CAR_TYRE;
			
			//shadow.shadowRotateX(-90);
			objContainer.addChild(shadow);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
			this._mainContainerHeight = 20; // To place objects on top like the repeater handle.
		}
		
		protected override function setMaterials():void {
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().tyre_Bmd;
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData);
		}
	}
}