package src3d.lines
{
	import away3d.core.base.Segment;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	
	import flash.geom.Vector3D;

	public class AreaHandle extends LineHandle
	{
		private var _pCommand1:PathCommand;
		private var _pCommand2:PathCommand;
		private var _isCornerHandle:Boolean;
		
		public function AreaHandle(idx:int, _pCommand1:PathCommand, _pCommand2:PathCommand = null) {
			super(idx);
			this._pCommand1 = pCommand1;
			this._pCommand2 = pCommand2;
			_isCornerHandle = (_pCommand2)? true : false;
		}
		
		public function get pCommand1():Vector3D {return _pCommand1;}
		public function get pCommand2():Vector3D {return _pCommand2;}
		public function get isCornerHandle():Boolean {return _isCornerHandle;}
		
		/*public override function set x(value:Number) {
			super.x = value;
			super.x = this.scenePosition.x;
		}*/
	}
}