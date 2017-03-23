package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class ReboundBoard1 extends Equipment {
		[Embed(source="ReboundBoard1.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_014;
		
		public function ReboundBoard1(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_REBOUND_BOARD_1;
			
			// Properties.
			this._rotable = true;
			this._colorable = true;
			//this._elevatable = true;
			this._repeatable = false;
			this._internalScale = 4;
			this.controllerScale = 1.1;
			this.shadow.shadowScale(.5, .3);
			//this.shadow.scale(1);
			//this.useShadow = false;
			
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
			_color1default = 0xF6E616;
			if (this._colorable) {
				_color1 = (newCol > -1)? newCol : _color1default;
			} else {
				_color1 = _color1default;
			}
			//_color2 = 0xCCCCCC;
		}
		
		private function initObject():void {			objContainer = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.name = "ReboundBoard1";
			objContainer.rotationX = 90;
			objContainer.rotationY = 180;
			objContainer.addChild(shadow);
			shadow.shadowRotateX(-90);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
		}
		
		protected override function setMaterials():void {
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().rebound_board_1_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1, null, EquipmentTextures.getInstance().rebound_board_1_mask_Bmd);
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "mesh", true);
		}
	}
}