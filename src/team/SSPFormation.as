package src.team
{
	import flash.geom.Vector3D;

	public class SSPFormation
	{
		private var _formation:String = "";
		private var _name:String = "";
		private var _numPlayers:uint;
		private var _vFormation:Vector.<Vector3D>;
		private var _vFormationFullPitch:Vector.<Vector3D>;
		private var _vFormationReversed:Vector.<Vector3D>;
		private var _vFormationReversedFullPitch:Vector.<Vector3D>;
		
		public function SSPFormation(numPlayers:uint, name:String, formation:String)
		{
			this._numPlayers = numPlayers;
			this._name = name;
			this._formation = formation;
		}
		
		private function updateFormation():void {
			_vFormation = new Vector.<Vector3D>();
			var delimiter:String = TeamGlobals.delimiter;
			var aF:Array = _formation.split(delimiter);
			var aV3D:Array;
			for (var i:uint;i<aF.length;i++) {
				aV3D = aF[i].split(",");
				if (aV3D && aV3D.length == 3) _vFormation.push(new Vector3D(Number(aV3D[0]),Number(aV3D[1]),Number(aV3D[2])));
			}
			
			// Swap the positions to the other side of the pitch by making all x and z negative.
			// Note that 180 degrees rotation may be required in the object to face the oposite side.
			var pitchLength:Number;
			var pitchDepth:Number;
			
			// TODO.
			_vFormationFullPitch = new Vector.<Vector3D>();
			for each(var pos:Vector3D in vFormation) {
				_vFormationFullPitch.push(new Vector3D(-pos.x, pos.y, -pos.z));
			}
			
			_vFormationReversed = new Vector.<Vector3D>();
			for each(var pos:Vector3D in vFormation) {
				_vFormationReversed.push(new Vector3D(-pos.x, pos.y, -pos.z));
			}
			
			// TODO.
			_vFormationReversedFullPitch = new Vector.<Vector3D>();
			for each(var pos:Vector3D in _vFormationReversed) {
				_vFormationReversedFullPitch.push(new Vector3D(-pos.x, pos.y, -pos.z));
			}
		}
		
		public function get vFormation():Vector.<Vector3D> {
			if (!_vFormation) updateFormation();
			return _vFormation;
		}
		
		public function get vFormationFullPitch():Vector.<Vector3D> {
			if (!_vFormationFullPitch) updateFormation();
			return _vFormationFullPitch;
		}
		
		public function get vFormationReversed():Vector.<Vector3D> {
			if (!_vFormationReversed) updateFormation();
			return _vFormationReversed;
		}
		
		public function get vFormationReversedFullPitch():Vector.<Vector3D> {
			if (!_vFormationReversedFullPitch) updateFormation();
			return _vFormationReversedFullPitch;
		}

		public function get formation():String
		{
			return _formation;
		}

		public function get name():String
		{
			return _name;
		}

		public function get numPlayers():uint
		{
			return _numPlayers;
		}
	}
}