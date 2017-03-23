package src3d.models.soccer.equipment
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cone;
	import away3d.primitives.Cylinder;
	import away3d.primitives.Plane;
	
	import flash.display.BitmapData;
	
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.ColorUtils;
	
	public class AgilityCones extends Equipment {
		
		/*private var objectA:Plane;
		private var objectB:Cone;
		private var objectC:Plane;
		private var objectD:Cone;
		private var objectE:Cylinder;*/
		
		private var objSettingsRef:EquipmentSettings;
		public const _equipmentLibraryId:int = EquipmentLibrary.ID_016;
		
		public function AgilityCones(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			objSettingsRef._libraryId = _equipmentLibraryId;
			super(sessionScreen, objSettings);
			this.name = EquipmentLibrary.NAME_AGILITY_CONES;
			
			// Properties.
			this._rotable = true;
			this._colorable = true;
			//this._elevatable = true;
			this._repeatable = true;
			this._internalScale = 1;
			//this.controllerScale = 4;
			this.shadow.scaleX = 2;
			this.shadow.scaleZ = .5;
			//this.shadow.scale(.8);
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
			_color1default = 0x00EB00;
			if (this._colorable) {
				_color1 = (newCol > -1)? newCol : _color1default;
			} else {
				_color1 = _color1default;
			}
			_color2 = 0xF6F478;
		}
		
		private function initObject():void {
		objContainer = new ObjectContainer3D();
			objContainer.name = "AgilityConesContainer";
			objContainer.addChild(shadow);
			var objectA:Plane = new Plane({width:19, height:19, x:55, segmentsW:2, segmentsH:2, name:"conebase"});
			var objectB:Cone = new Cone({radius:7, height:32, x:55, y:15, segmentsW:8, openEnded:true, name:"conetop"});
			var objectC:Plane = new Plane({width:19, height:19, x:-55, segmentsW:2, segmentsH:2, name:"conebase2"});
			var objectD:Cone = new Cone({radius:7, height:32, x:-55, y:15, segmentsW:8, openEnded:true, name:"conetop2"});
			var objectE:Cylinder = new Cylinder({radius:2, height:110, y:24, rotationZ:90, segmentsW:3, name:"bar"});
			objContainer.addChild(objectA);
			objContainer.addChild(objectB);
			objContainer.addChild(objectC);
			objContainer.addChild(objectD);
			objContainer.addChild(objectE);
			
			// Create objectSet Array. Used for repeatable objects.
			objectSet.push(objContainer);
			
			//this.updateInternalScale(objContainer);
			this.addToMainContainer(objContainer);
			this._mainContainerHeight = 22;
		}
		
		protected override function setMaterials():void {
			var colMat:ColorMaterial = new ColorMaterial(_color1);
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().gradient1_Bmd;
			obj1_BitmapData = ColorUtils.colorBmp(obj1_BitmapData, _color1);
			var obj2_BitmapData:BitmapData = EquipmentTextures.getInstance().poles_Bmd;
			obj2_BitmapData = ColorUtils.colorBmp(obj2_BitmapData, _color2);
			
			ColorUtils.applyColorMaterialToMeshes(objectSet, _color1, 1, "conebase");
			ColorUtils.applyColorMaterialToMeshes(objectSet, _color1, 1, "conebase2");
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "conetop");
			ColorUtils.applyMaterialToMesh(objectSet, obj1_BitmapData, "conetop2");
			ColorUtils.applyMaterialToMesh(objectSet, obj2_BitmapData, "bar");
		}
	}
}