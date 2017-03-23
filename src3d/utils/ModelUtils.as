package src3d.utils
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	
	import flash.geom.Vector3D;

	public class ModelUtils
	{
		public function ModelUtils()
		{
		}
		
		public static function changeScaleInMesh(obj:ObjectContainer3D, scl:Number, meshNameId:String = ""):void {
			for each(var obj3d:Object3D in obj.children) {
				var mesh:Mesh = obj3d as Mesh;
				if (mesh != null) {
					if(mesh.name == meshNameId){
						mesh.scale(scl);
						return;
					} else {
						mesh.scale(scl);
					}
				}
			}
		}
		
		public static function clearObjectContainer3D(obj3d:ObjectContainer3D, clearMaterial:Boolean, clearGeometry:Boolean):void {
			removeMaterials(obj3d);
			var cont3d:ObjectContainer3D;
			var obj:Object3D;
			var mesh:Mesh;
			while (obj3d.children.length > 0) {
				obj = obj3d.children[0];
				cont3d = obj as ObjectContainer3D;
				if (cont3d) clearObjectContainer3D(cont3d, clearMaterial, clearGeometry);
				obj3d.removeChild(obj);
				
				mesh = obj as Mesh;
				if (mesh) {
					if (clearMaterial) mesh.material = null;
					if (clearGeometry) mesh.geometry = null;
				}
			}
			if (clearMaterial) obj3d.material = null;
			//if (clearGeometry) obj3d.geometry = null; // Can't remove geometry until removeChild.
		}
		
		public static function removeMaterials(obj:ObjectContainer3D, meshNameId:String = ""):void {
			var mesh:Mesh;
			var objCont3d:ObjectContainer3D;
			for each(var obj3d:Object3D in obj.children) {
				objCont3d = obj3d as ObjectContainer3D;
				if (objCont3d) {
					removeMaterials(objCont3d, meshNameId);
				}
				mesh = obj3d as Mesh;
				if (mesh) {
					if(mesh.name == meshNameId){
						mesh.material = null;
						return;
					} else {
						mesh.material = null;
					}
				}
			}
		}
		
		public static function collisionTestAABS(objA:ObjectContainer3D, objB:ObjectContainer3D):Boolean{
			///first approach/////////////
			var dist:Number=Vector3D.distance(objA.position,objB.position);
			if(dist<=(objA.boundingRadius+objB.boundingRadius)){
				return true;
			}
			return false;
			//second optional (more math oriented) aproach///
			//var centerDiff:Vector3D=_objA.position.subtract(_objB.position);
			//var radSum:Number=_objA.radius+_objB.radius;
			//trace(centerDiff.dotProduct(centerDiff)<=radSum*radSum);
		}
		public static function collisionTestAABSDistance(objA:ObjectContainer3D, objB:ObjectContainer3D):Number{
			var dist:Number=Vector3D.distance(objA.position,objB.position);
			if(dist<=(objA.boundingRadius+objB.boundingRadius)){
				return dist;
			}
			return -1;
		}
		
		public static function applyFilterToContainer3D(aFilters:Array, obj:ObjectContainer3D, meshNameId:String = ""):void {
			var mesh:Mesh;
			for each(var obj3d:Object3D in obj.children) {
				mesh = obj3d as Mesh;
				if (mesh){
					if (meshNameId == "") {
						mesh.filters = aFilters;
					} else if (mesh.name == meshNameId) {
						mesh.filters = aFilters;
						return;
					}
				}
			}
		}
	}
}