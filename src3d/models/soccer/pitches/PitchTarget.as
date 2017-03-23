package src3d.models.soccer.pitches
{
	import away3d.containers.ObjectContainer3D;
	
	import flash.geom.Vector3D;
	
	public class PitchTarget extends ObjectContainer3D
	{
		public var panAngle:Number;
		public var tiltAngle:Number;
		public var zoom:Number;
		
		public function PitchTarget(targetPos:Vector3D, panAngle:Number, tiltAngle:Number, zoom:Number)
		{
			this.position = targetPos;
			this.panAngle = panAngle;
			this.tiltAngle = tiltAngle;
			this.zoom = zoom;
		}
	}
}