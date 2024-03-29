package src3d.utils {
	
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	/**
	 * Class Drag3D allows free dragging of an object3D locked to planes XY, XZ and YZ.
	 *
	 * locks on world planes
	 * locks on Object3D planes
	 * locks on Object3D planes with object rotations
	 */
	
	public class Dragger
	{
		//Targets
		private var _view:View3D;
		private var _object3d:Object3D;
		
		//Debug planes
		private var _planeXZ:Plane;
		private var _planeXY:Plane;
		private var _planeZY:Plane;
		private var _planesContainer:ObjectContainer3D;
		
		//Vectors
		private var _np:Vector3D = new Vector3D();
		private var _intersect:Vector3D = new Vector3D();
		private var _rotations:Vector3D;
		private var _baserotations:Vector3D;
		private var _offsetCenter:Vector3D;
		private var _bSetOffset:Boolean;
		
		private var _a:Number = 0;
		private var _b:Number = 0;
		private var _c:Number = 0;
		private var _d:Number = 1;
		
		//Planes
		private var _planeid:String = "xz";
		private var _useRotations:Boolean;
		
		public function Dragger(view:View3D)
		{
			_view = view;
			init();
		}
		
		private function init():void
		{
			if(!_view.camera.lens is PerspectiveLens)
				_view.camera.lens = new PerspectiveLens();
		}
		
		private function updateDebug():void
		{
			if(_a == 0 && _b == 0 && _c == 0){
				_planesContainer.x = _planesContainer.y = _planesContainer.z = 0;
				_planesContainer.rotationX = _planesContainer.rotationY = _planesContainer.rotationZ = 0;
				
			} else {
				_planesContainer.x = -_a;
				_planesContainer.y = -_b;
				_planesContainer.z = -_c;
				
				if(_useRotations && _rotations != null){
					_planesContainer.rotationX = _rotations.x;
					_planesContainer.rotationY = _rotations.y;
					_planesContainer.rotationZ = _rotations.z;
				}
			}
		}
		
		private function toggleDebug():void
		{
			if(_planesContainer != null){
				var rect:Rectangle = ((_planeXY as Mesh).material as BitmapMaterial).bitmap.rect;
				switch(_planeid){
					//XZ
					case"zx":
						_planeid = "xz";
					case"xz":
						((_planeXZ as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0x00FFFFFF);
						((_planeXZ as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0x12FF0000);
						((_planeXY as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0xFF00FF00);
						break;
					//XY
					case"yx":
						_planeid = "xy";
					case"xy":
						((_planeXY as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0x00FFFFFF);
						((_planeXY as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0x1200FF00);
						((_planeZY as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0xFF0000FF);
						break;
					//ZY
					case"yz":
						_planeid = "zy";
					case"zy":
						((_planeZY as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0x00FFFFFF);
						((_planeZY as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0x120000FF);
						((_planeXZ as Mesh).material as BitmapMaterial).bitmap.fillRect(rect, 0xFFFF0000);
						break;
					default:
						throw new Error("Unvalid plane description, use: xz, xy, or zy");
				}
			}
		}
		
		private function intersect():void
		{
			var pMouse:Vector3D = _view.camera.unproject(_view.mouseX, _view.mouseY);
			//pMouse = pMouse.add(_view.camera.position);
			pMouse.x += _view.camera.position.x;
			pMouse.y += _view.camera.position.y;
			pMouse.z += _view.camera.position.z;
			
			var cam:Vector3D = _view.camera.position;
			
			var d0: Number = _np.x * cam.x + _np.y * cam.y + _np.z * cam.z - _d;
			var d1: Number = _np.x * pMouse.x + _np.y * pMouse.y + _np.z * pMouse.z - _d;
			
			var m: Number = d1 / ( d1 - d0 );
			
			_intersect.x = pMouse.x + ( cam.x - pMouse.x ) * m;
			_intersect.y = pMouse.y + ( cam.y - pMouse.y ) * m;
			_intersect.z = pMouse.z + ( cam.z - pMouse.z ) * m;
			
			if(_bSetOffset){
				_bSetOffset = false;
				//_offsetCenter = _offsetCenter.subtract(_intersect);
				_offsetCenter.x = _offsetCenter.x - _intersect.x;
				_offsetCenter.y = _offsetCenter.y - _intersect.y;
				_offsetCenter.z = _offsetCenter.z - _intersect.z;
			}
			
		}
		
		//***************
		//  PUBLICS
		//***************
		
		/**
		 * Displays the planes for debug/visual aid purposes
		 *
		 * @param	b				Boolean. Display the planes of the dragged object3d. Default is false;
		 */
		public function set debug(b:Boolean):void
		{
			if(b && _planesContainer == null){
				
				var size:Number = 1000;
				var red:BitmapMaterial = new BitmapMaterial(new BitmapData(128,128,true, 0xFFFF0000), {debug:false});
				var green:BitmapMaterial = new BitmapMaterial(new BitmapData(128,128,true, 0x1200FF00), {debug:false});
				var blue:BitmapMaterial = new BitmapMaterial(new BitmapData(128,128,true, 0x120000FF), {debug:false});
				_planeXZ = new Plane({material:red, width:size, height:size, segmentsH:10, segmentsW:10, bothsides:true});
				_planeXY = new Plane({material:green, width:size, height:size, segmentsH:10, segmentsW:10, bothsides:true});
				_planeXY.rotationX = 90;
				_planeZY = new Plane({material:blue, width:size, height:size, segmentsH:10, segmentsW:10, bothsides:true});
				_planeZY.rotationY = 90;
				_planeZY.rotationX = 90;
				_planesContainer = new ObjectContainer3D(_planeXZ,_planeXY, _planeZY);
				_view.scene.addChild(_planesContainer);
				
				updateDebug();
				
			} else{
				
				if(_planesContainer != null){
					_planesContainer.removeChild(_planeXZ);
					_planesContainer.removeChild(_planeXY);
					_planesContainer.removeChild(_planeZY);
					((_planeXZ as Mesh).material as BitmapMaterial).bitmap.dispose();
					((_planeXY as Mesh).material as BitmapMaterial).bitmap.dispose();
					((_planeZY as Mesh).material as BitmapMaterial).bitmap.dispose();
					_view.scene.removeChild(_planesContainer);
					_planesContainer = null;
					_planeXZ = _planeXY = _planeZY = null;
				}
				
			}
			
		}
		
		public function get debug():Boolean
		{
			return (_planesContainer != null)? true : false;
		}
		
		/**
		 * Changes the plane the object will be considered on.
		 * If class debug is set to true. It display the selected plane for debug/visual aid purposes with a brighter color.
		 * @param	planeid				String. Plane id to drag the object3d on. Possible strings are 'xz', 'xy', or 'zy'. Default at init class is 'xz';
		 */
		public function set plane(planeid:String):void
		{
			_planeid = planeid.toLowerCase();
			
			if(_planeid != "xz" && _planeid != "xy" && _planeid != "zy")
				throw new Error("Unvalid plane description, use: xz, xy, or zy");
			
			planeObject3d = null;
			updateNormalPlanes();
			
			toggleDebug();
		}
		
		/**
		 * getIntersect method returns the 3d point in space (Vector3D) where mouse hits the given plane. 
		 *	@return Vector3D 	The intersection Vector3D
		 *  If both x and y params are NaN, the class will return the hit from mouse coordinates
		 *	@param	 x		[optional] Number. x coordinate.
		 *	@param	 y		[optional] Number. y coordinate.
		 */
		public function getIntersect():Vector3D
		{
			intersect();
			
			return _intersect;
		}
		
		/**
		 * if an object3D is set this handler will calculate the mouse intersection on given plane and will update position
		 * and rotations of the object3d set accordingly
		 */
		public function updateDrag():void
		{
			if(_object3d == null)
				throw new Error ("Drag3D error: no object3D or world planes specified");
			
			if(_planesContainer != null)
				updateDebug();
			
			intersect();
			
			if(_offsetCenter == null){
				
				if ( _intersect == null || isNaN(_intersect.x) || isNaN(_intersect.y) || isNaN(_intersect.y) ) return;
				
				_object3d.x = _intersect.x;
				_object3d.y = _intersect.y;
				_object3d.z = _intersect.z;
				
			} else{
				
				if ( !_intersect || isNaN(_intersect.x) || isNaN(_intersect.y) || isNaN(_intersect.y) ||
					!_offsetCenter || isNaN(_offsetCenter.x) || isNaN(_offsetCenter.y) || isNaN(_offsetCenter.y)
				) {
					return;
				}
				
				_object3d.x = _intersect.x + _offsetCenter.x;
				_object3d.y = _intersect.y + _offsetCenter.y;
				_object3d.z = _intersect.z + _offsetCenter.z;
				
			}
			
		}
		
		/**
		 * Sets the target object3d to the class. The object3d that will be dragged
		 *
		 * @param	obj		Object3D. The object3d that will be dragged. Default is null. When null planes will be considered at 0,0,0 world
		 */
		public function set object3d(obj:Object3D):void
		{
			_object3d = obj;
			
			if(_planesContainer != null)
				updateDebug();
		}
		/**
		 * Defines planes as the position of a given Object3D
		 *
		 * @param	obj		Object3D. The object3d that will be used to define the planes
		 */
		public function set planeObject3d(obj:Object3D):void
		{
			updateNormalPlanes(obj);
			
			if(_planesContainer != null)
				updateDebug();
		}
		/**
		 * Defines planes position by a postion Vector3D
		 *
		 * @param	pos		Vector3D. The Vector3D that will be used to define the planes position
		 */
		public function set planePosition(pos:Vector3D):void
		{
			switch(_planeid){
				//XZ
				case"xz":
					_np.x = 0;
					_np.y = 1;
					_np.z = 0;
					break;
				//XY
				case"xy":
					_np.x = 0;
					_np.y = 0;
					_np.z = 1;
					break;
				//ZY
				case"zy":
					_np.x = 1;
					_np.y = 0;
					_np.z = 0;
					break;
			}
			
			_a = - pos.x;
			_b = - pos.y;
			_c = - pos.z;
			
			_d = -(_a*_np.x + _b*_np.y + _c*_np.z);
			
			if(_planesContainer != null)
				updateDebug();
		}
		
		private function updateNormalPlanes(obj:Object3D = null):void
		{
			var world:Boolean = (obj == null)? true : false;
			
			if(_useRotations && !world){
				switch(_planeid){
					//XZ
					case"xz":
						_np.x = obj.transform.rawData[4];
						_np.y = obj.transform.rawData[5];
						_np.z = obj.transform.rawData[6];
						break;
					//XY
					case"xy":
						_np.x = obj.transform.rawData[8];
						_np.y = obj.transform.rawData[9];
						_np.z = obj.transform.rawData[10];
						break;
					//ZY
					case"zy":
						_np.x = obj.transform.rawData[0];
						_np.y = obj.transform.rawData[1];
						_np.z = obj.transform.rawData[2];
						break;
				}
				
				if(!_rotations){
					_rotations = new Vector3D();
					_baserotations = new Vector3D();
				}
				_rotations.x = obj.rotationX;
				_rotations.y = obj.rotationY;
				_rotations.z = obj.rotationZ;
				
				_baserotations.x = obj.rotationX;
				_baserotations.y = obj.rotationY;
				_baserotations.z = obj.rotationZ;
				
				_np.normalize();
				
			} else {
				
				if(_rotations != null && _baserotations != null){
					_baserotations.x = _baserotations.y = _baserotations.z = 0;
					_rotations.x = _rotations.y = _rotations.z = 0;
				}
				
				switch(_planeid){
					//XZ
					case"xz":
						_np.x = 0;
						_np.y = 1;
						_np.z = 0;
						break;
					//XY
					case"xy":
						_np.x = 0;
						_np.y = 0;
						_np.z = 1;
						break;
					//ZY
					case"zy":
						_np.x = 1;
						_np.y = 0;
						_np.z = 0;
						break;
				}
			}
			
			_a = (world)? 0 : - obj.scenePosition.x;
			_b = (world)? 0 : - obj.scenePosition.y;
			_c = (world)? 0 : - obj.scenePosition.z;
			
			_d = -(_a*_np.x + _b*_np.y + _c*_np.z);
		}
		
		public function get object3d():Object3D
		{
			return _object3d;
		}
		
		/**
		 * Defines if the target object3d plane will be aligned to object rotations or not
		 *
		 * @param	b		Boolean. Defines if the target object3d planes will be aligned to object rotations or not. Default is false.
		 */
		public function set useRotations(b:Boolean):void
		{
			_useRotations = b;
			
			if(!b && _rotations != null)
				_baserotations = null;
			_rotations = null;
			
			if(_planesContainer != null)
				updateDebug();
		}
		
		public function get useRotations():Boolean
		{
			return _useRotations;
		}
		
		/**
		 * Defines an offset for the drag from center mesh to mouse position.
		 * object3d must have been set previously for this setter. if not an error is triggered
		 * Since the offset is set from center to mouse projection, its usually a good practice to set it during firt mouse down
		 * prior to drag.
		 */
		public function setOffsetCenter():void
		{
			if(!_object3d)
				throw new Error("offsetcenter requires that an object3d as been assigned to the Drag3D class!");
			
			if(!_offsetCenter)
				_offsetCenter = new Vector3D();
			
			_offsetCenter = _object3d.scenePosition;
			
			_bSetOffset = true;
		}
		
		public function get offsetCenter():Vector3D
		{
			return _offsetCenter;
		}
		
		public function removeOffsetCenter():void {
			_offsetCenter = new Vector3D(0,1,0);
		}
		
	}
}
