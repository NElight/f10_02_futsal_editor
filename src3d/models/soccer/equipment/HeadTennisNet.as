package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class HeadTennisNet extends Equipment {
		[Embed(source="HeadTennisNet.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_034;
		
		public function HeadTennisNet(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_HEAD_TENNIS_NET;
			
			// Properties.
			//this._scalable = false;
			this._rotable = true;
			this._colorable = true;
			//this._elevatable = true;
			this._repeatable = false;
			this._internalScale = 1;
			this.controllerScale = 1.4;
			this.shadow.shadowScale(6, 1);
			//this.shadow.scale(1);
			//this.useShadow = false;
			
			this._resizable = true;
			this.minSize = .7;
			this.maxSize = 1.25;
			this.resizeBlockAxis = RESIZE_BLOCK_Y;
			
			// Init.
			initColors(objSettingsRef._equipColor);
			initObject();
			setMaterials();
			initElevation();
			initSize();
			applyGlobalScale();
			initObjectRepeater(objSettingsRef._pathData);
			initRotator();
			init2DButtons();
		}
		
		private function initColors(newCol:int):void {
			_color1default = 0xFC9630;
			if (this._colorable) {
				_color1 = (newCol > -1)? newCol : _color1default;
			} else {
				_color1 = _color1default;
			}
			//_color2 = 0xCCCCCC;
		}
		
		private function initObject():void {
			objContainer = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.name = EquipmentLibrary.NAME_HEAD_TENNIS_NET;
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
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().head_tennis_net_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1, BlendMode.MULTIPLY, EquipmentTextures.getInstance().head_tennis_net_mask_Bmd);
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "mesh", true);
		}
	}
}