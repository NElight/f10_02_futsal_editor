package src3d.models.soccer.equipment {
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TransformBitmapMaterial;
	import away3d.primitives.Sphere;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	
	public class Football extends Equipment {
		[Embed(source="images/football.jpg")]
		private var Obj_Bitmap:Class;

		private var objectA:Sphere;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_002;
		
		public function Football(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_FOOTBALL;
			
			// Properties.
			//this._rotable = true;
			this._colorable = true;
			this._elevatable = true;
			this._repeatable = false;
			this._transparentable = true;
			this._internalScale = 1;
			//this.controllerScale = 4;
			//this.shadow.scaleZ = .6;
			this.shadow.scale(.2);
			//this.useShadow = false;
			minYPos = 1;
			maxYPos = 200; // Football can be higher than other objects.
			yPosOffset = 0;
			
			this._resizable = true;
			this.minSize = 1;
			this.maxSize = 3;
			
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
			_color1default = 0xFFFFFF;
			if (this._colorable) {
				_color1 = (newCol > -1)? newCol : _color1default;
			} else {
				_color1 = _color1default;
			}
			//_color2 = 0xCCCCCC;
		}
		
		private function initObject():void {
			objContainer = new ObjectContainer3D();
			objContainer.addChild(shadow);
			objectA = new Sphere({radius:11, segmentsW:10, segmentsH:10, y:11, name:"Football"});
			objContainer.name = "Football";
			objContainer.addChild(objectA);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
		}
		
		protected override function setMaterials():void {
			/*var bm:Bitmap = new Obj_Bitmap();
			var mat:TransformBitmapMaterial = new TransformBitmapMaterial(bm.bitmapData);*/
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().football_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1, BlendMode.MULTIPLY);
			//ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "");
			//objectA.material = new TransformBitmapMaterial(obj1_BitmapData);
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "", false, this.transparencyValue); // Includes transparency.
		}
	}
}