package src3d.lines
{
	import flash.geom.Vector3D;

	public class AreaBounds
	{
		public var _maxX:Number = 0;
		public var _minX:Number = 0;
		public var _maxZ:Number = 0;
		public var _minZ:Number = 0;
		
		private var _centerOffsetX:Number = 0;
		private var _centerOffsetZ:Number = 0;
		
		//private var areaPosition:Vector3D = new Vector3D();
		
		public function AreaBounds()
		{
			// TODO: Add offset support. Add offset to center, get offset from position.
		}
		
		public function set maxX(newVal:Number):void {
			if (isNaN(newVal)) return;
			_maxX = newVal;
		}
		public function set minX(newVal:Number):void {
			if (isNaN(newVal)) return;
			_minX = newVal;
		}
		public function set maxZ(newVal:Number):void {
			if (isNaN(newVal)) return;
			_maxZ = newVal;
		}
		public function set minZ(newVal:Number):void {
			if (isNaN(newVal)) return;
			_minZ = newVal;
		}
		public function get maxX():Number {return _maxX;}
		public function get minX():Number {return _minX;}
		public function get maxZ():Number {return _maxZ;}
		public function get minZ():Number {return _minZ;}
		
		
		
		public function get areaWidth():Number {
			return _maxX - _minX;
		}
		
		public function get areaDepth():Number {
			return _maxZ - _minZ;
		}
		
		public function get areaCenterX():Number {
			return _maxX - (areaWidth / 2);
		}
		
		public function get areaCenterZ():Number {
			return _maxZ - (areaDepth / 2);
		}
		
		public function get areaPosition():Vector3D {
			return new Vector3D(areaCenterX, 0, areaCenterZ);
		}
	}
}