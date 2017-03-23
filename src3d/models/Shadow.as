package src3d.models {
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.RegularPolygon;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	import src3d.utils.ColorUtils;
	
	public class Shadow extends ObjectContainer3D {
		[Embed(source="shadow.png")]
		private var Obj_Bitmap:Class;
		private var obj:RegularPolygon;
		private var _scale:Number;
		private var _shadowBmd:BitmapData;
		private var _shadowColor:uint;
		
		public function Shadow(sclX:Number = NaN, sclZ:Number = NaN, ...initarray:Array) {
			super(initarray);
			_scale = 1;
			this.name = "SSPShadow";
			initObject();
			if (!isNaN(sclX)) obj.scaleX = sclX;
			if (!isNaN(sclZ)) obj.scaleZ = sclZ;
		}
		
		private function initObject():void {
			_shadowBmd = Bitmap(new Obj_Bitmap()).bitmapData;
			obj = new RegularPolygon({sides:16, radius:40, material:new BitmapMaterial(_shadowBmd), visible:true, name:"Shadow"});
			obj.scale(_scale);
			obj.bothsides = true;
			this.ownCanvas = false; // If true, there can give a this.parent.session = null when added to a sub-container. 
			this.addChild(obj);
		}
		
		public function shadowRotateX(rX:Number):void {
			if (!obj) return;
			obj.rotationX = rX;
		}
		
		public function shadowScale(sclX:Number, sclZ:Number) {
			if (!obj) return;
			obj.scaleX = sclX;
			obj.scaleZ = sclZ;
		}
		
		public function shadowAlpha(al:Number):void {
			if (!obj) return;
			BitmapMaterial(obj.material).alpha = al;
		}
		
		public function shadowColor(newColor:uint):void {
			if (newColor == _shadowColor) return;
			_shadowColor = newColor;
			//_shadowBmd = ColorUtils.colorBmp(_shadowBmd, 0xFFFFFF, BlendMode.NORMAL);
			_shadowBmd = ColorUtils.colorBmp(_shadowBmd, _shadowColor, BlendMode.MULTIPLY);
			ColorUtils.applyMaterialToMesh([this],_shadowBmd);
		}
		
		public function dispose():void {
			obj.material = null;
			this.removeChild(obj);
			obj = null;
			_shadowBmd = null;
			Obj_Bitmap = null;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}