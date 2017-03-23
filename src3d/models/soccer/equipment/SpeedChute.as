package src3d.models.soccer.equipment
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	
	import flash.display.BitmapData;
	
	import src3d.models.soccer.AccessoriesLibrary;
	import src3d.utils.ColorUtils;
	import src3d.utils.ModelUtils;
	
	/**
	 * This object is not added directly to the pitch, but to another object3D. So it doesn't extends Equipment. 
	 */	
	public class SpeedChute extends ObjectContainer3D
	{
		[Embed(source="SpeedChute.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;
		
		private var _internalScale = 4;
		
		public function SpeedChute(init:Object=null)
		{
			super(init);
			this.name = AccessoriesLibrary.ACCESSORY_CHUTE;
			initObject();
		}
		
		private function initObject():void {
			// Set temp object.
			var obj:ObjectContainer3D = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			
			// Set Material.
			var obj1_BitmapData:BitmapData = EquipmentTextures.getInstance().speed_chute_Bmd;
			ColorUtils.applyMaterialToMesh([obj], obj1_BitmapData, "", true);
			
			// Get meshes from temp object.
			this.addChild(obj.children[0]);
			this.rotationX = 90;
			this.rotationY = 180;
			this.scale(_internalScale);
			
			// Dispose temp object.
			obj = null;
		}
		
		public function dispose():void {
			ModelUtils.clearObjectContainer3D(this, true, true);
			this.ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}