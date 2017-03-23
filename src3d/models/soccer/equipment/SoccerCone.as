package src3d.models.soccer.equipment
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cone;
	import away3d.primitives.Plane;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;

	public class SoccerCone extends Equipment {

		private var objectA:Plane;
		private var objectB:Cone;
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_003;
		
		public function SoccerCone(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_CONE;
			
			// Properties.
			this._rotable = true;
			this._colorable = true;
			//this._elevatable = true;
			this._repeatable = true;
			this._internalScale = 1;
			//this.controllerScale = 4;
			//this.shadow.scaleZ = .6;
			this.shadow.scale(.8);
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
			_color1default = 0xF68C1F;
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
			objContainer.name = "Cone";
			objectA = new Plane({width:28, height:28, segmentsW:2, segmentsH:2, name:"conebase"});
			objectB = new Cone({radius:12, height:48, y:24, segmentsW:8, openEnded:true, name:"conetop"});
			objContainer.addChild(objectA);
			objContainer.addChild(objectB);
			
			// Create objectSet Array with a single object (to keep old F10 code compatibility).
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
			this._mainContainerHeight = 38;
		}
		
		protected override function setMaterials():void {
			var colMat:ColorMaterial = new ColorMaterial(_color1);
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().gradient1_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1);
			ColorUtils.applyColorMaterialToMeshes(objectSet, _color1, 1, "conebase");
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "conetop");
		}
	}
}