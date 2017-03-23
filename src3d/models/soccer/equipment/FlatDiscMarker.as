package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class FlatDiscMarker extends Equipment {
		[Embed(source="FlatDiscMarker.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_031;
		
		public function FlatDiscMarker(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_FLAT_DISC_MARKER;
			
			// Properties.
			this._scalable = true;
			this._rotable = true;
			this._colorable = true;
			this._elevatable = false;
			this._repeatable = true;
			this._internalScale = 1;
			this.controllerScale = 1;
			this.useShadow = true;
			this.shadow.shadowScale(.7, .7);
			this.shadow.shadowAlpha(.8);
			//this.shadow.shadowRotateX(-90);
			
			// Init.
			initColors(objSettingsRef._equipColor);
			initObject();
			setMaterials();
			initElevation();
			applyGlobalScale();
			initObjectRepeater(objSettingsRef._pathData, 90);
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
			//_color2 = 0xFAF803;
		}
		
		private function initObject():void {
			objContainer = new ObjectContainer3D();
			objContainer = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.name = EquipmentLibrary.NAME_FLAT_DISC_MARKER;
			objContainer.rotationX = -90;
			
			shadow.shadowRotateX(-90);
			objContainer.addChild(shadow);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
			this._mainContainerHeight = 10; // To place objects on top like the repeater handle.
		}
		
		protected override function setMaterials():void {
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().flat_disc_marker_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1);
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData);
		}
	}
}