package src3d
{
	import src3d.models.soccer.pitches.PitchTargets;
	import src3d.utils.Logger;

	public class SSPCameraSettings
	{
		public static const CAM_TYPE_HOVER:uint					= 0;
		
		public static const DEFAULT_CAM_DISTANCE:uint			= 1997.04; // 1997.04 avoids View.render() issues with certain camera settings.
		public static const DEFAULT_CAM_FOCUS:uint				= 100;
		public static const DEFAULT_CAM_MIN_ZOOM:uint			= 6; // Flash 10 version
		public static const DEFAULT_CAM_MAX_ZOOM:uint			= 66; // Flash 10 version
		public static const DEFAULT_CAM_MIN_TILT_ANGLE:uint		= 3;
		public static const DEFAULT_CAM_MAX_TILT_ANGLE:uint		= 89;
		public static const DEFAULT_CAM_STEPS:uint				= 1;
		
		public static const DEFAULT_CAM_PAN_ANGLE:int			= -42;
		public static const DEFAULT_CAM_TILT_ANGLE:int			= 16;
		public static const DEFAULT_CAM_ZOOM:uint				= 8;
		public static const DEFAULT_CAM_TARGET:uint				= PitchTargets.TARGET_CENTER;
		
		// Default values for F11 (v2) settings.
		public static const DEFAULT_CAM_FOV:String				= ""; // v2.
		public static const DEFAULT_CAM_TYPE:uint				= CAM_TYPE_HOVER; // v2.
		
		public var _cameraPanAngle:Number;
		public var _cameraTiltAngle:Number;
		public var _cameraZoom:Number;
		public var _cameraTarget:uint;
		public var _cameraFOV:String; // v2.
		public var _cameraType:uint; // v2.
		
		public function SSPCameraSettings()
		{
		}
		
		/*public function resetCameraSettings():void {
			_cameraPanAngle = DEFAULT_CAM_PAN_ANGLE;
			_cameraTiltAngle = DEFAULT_CAM_TILT_ANGLE;
			_cameraZoom = DEFAULT_CAM_ZOOM;
			_cameraTarget = DEFAULT_CAM_TARGET;
			_cameraFOV = DEFAULT_CAM_FOV;
			_cameraType = DEFAULT_CAM_TYPE;
		}*/
	}
}