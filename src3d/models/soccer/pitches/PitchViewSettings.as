package src3d.models.soccer.pitches
{
	public class PitchViewSettings
	{
		public var pitchMarksId:int;
		public var camTargetId:int;
		public var camTargetIdAlt:int;
		public var camPanAngle:Number;
		public var camPanAngleAlt:Number; // Oposite view when clicking again.
		public var camTiltAngle:Number;
		public var camZoom:Number; // No value assigned here for error checking.
		public var showDefaultEquipment:Boolean;
		
		// View Renderer Loop Fix. Store the old values that produced the issue. See SSPCameraUpdater.as.
		public var camOldPanAngle:Number;
		public var camOldPanAngleAlt:Number;
		public var camOldTiltAngle:Number;
		public var camOldZoom:Number;
		
		public function PitchViewSettings(pitchMarks:int, camTargetId:int, camTargetIdAlt:int, camPanAngle:Number, camPanAngleAlt:Number,
										  camTiltAngle:Number, camZoom:Number, showDefaultEquipment:Boolean, camOldPanAngle:Number = -1,
										  camOldPanAngleAlt:Number = -1, camOldTiltAngle:Number = -1, camOldZoom:Number = -1) {
			this.pitchMarksId = pitchMarks;
			this.camTargetId = camTargetId;
			this.camTargetIdAlt = camTargetIdAlt;
			this.camPanAngle = camPanAngle;
			this.camPanAngleAlt = camPanAngleAlt;
			this.camTiltAngle = camTiltAngle;
			this.camZoom = camZoom;
			this.showDefaultEquipment = showDefaultEquipment;
			
			this.camOldPanAngle = camOldPanAngle;
			this.camOldPanAngleAlt = camOldPanAngleAlt;
			this.camOldTiltAngle = camOldTiltAngle;
			this.camOldZoom = camOldZoom;
		
		}
	}
}