package src3d.models.soccer.pitches
{
	public class PitchViewLibrary
	{
		
		// Array of pitch view settings.
		public var aPV:Vector.<PitchViewSettings> = new <PitchViewSettings>[
			new PitchViewSettings(PitchLibrary.MARKS_ID_STANDARD, PitchTargets.TARGET_CENTER_LEFT, PitchTargets.TARGET_CENTER_RIGHT, -60, 60, 16, 8, true),
			new PitchViewSettings(PitchLibrary.MARKS_ID_STANDARD, PitchTargets.TARGET_CENTER_RIGHT, PitchTargets.TARGET_CENTER_LEFT, -90, 90, 19, 6.5, true),
			new PitchViewSettings(PitchLibrary.MARKS_ID_STANDARD, PitchTargets.TARGET_CENTER_LEFT, PitchTargets.TARGET_CENTER_RIGHT, -90, 90, 16.5, 11, true),
			new PitchViewSettings(PitchLibrary.MARKS_ID_STANDARD, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 89, 10, true),
			new PitchViewSettings(PitchLibrary.MARKS_ID_CIRCLE, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_TRIANGLE, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_RECTANGLE_IN_6, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_RECTANGLE_IN_4, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_RECTANGLE_IN_2, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_RECTANGLE, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_NONE, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 30.02, 6, false, 0, 180, 30, 6),
			new PitchViewSettings(PitchLibrary.MARKS_ID_STANDARD, PitchTargets.TARGET_SIDE_LEFT, PitchTargets.TARGET_SIDE_RIGHT, -90, 90, 14.50, 16.5, true),
			new PitchViewSettings(PitchLibrary.MARKS_ID_NONE, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 89, 66, false),
			new PitchViewSettings(PitchLibrary.MARKS_ID_THIRDS, PitchTargets.TARGET_CENTER, PitchTargets.TARGET_CENTER, 0, 180, 89, 10, true)
		];
		
		// Singleton.
		private static var _self:PitchViewLibrary;
		private static var _allowInstance:Boolean = false;
		
		public function PitchViewLibrary()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("Library initialized.");
				//init();
			}
		}
		
		public static function getInstance():PitchViewLibrary
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new PitchViewLibrary();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}

	}
}