package src3d.models.soccer.pitches
{
	import flash.geom.Vector3D;
	
	public class PitchTargets
	{
		public static const TARGET_CENTER:int				= 0;
		
		public static const TARGET_CENTER_LEFT_TOP:int 		= 12;
		public static const TARGET_CENTER_LEFT:int			= 1;
		public static const TARGET_CENTER_LEFT_BOTTOM:int 	= 11;
		
		public static const TARGET_CENTER_RIGHT_TOP:int 	= 14;
		public static const TARGET_CENTER_RIGHT:int			= 2;
		public static const TARGET_CENTER_RIGHT_BOTTOM:int 	= 13;
		
		public static const TARGET_BOTTOM_LEFT:int			= 3;
		public static const TARGET_SIDE_LEFT:int			= 9;
		public static const TARGET_TOP_LEFT:int				= 4;
		
		public static const TARGET_BOTTOM_CENTER:int		= 5;
		public static const TARGET_SIDE_RIGHT:int			= 10;
		public static const TARGET_TOP_CENTER:int			= 6;
		
		public static const TARGET_BOTTOM_RIGHT:int			= 7;
		public static const TARGET_TOP_RIGHT:int			= 8;
		
		private static var aCamTargets:Vector.<PitchTarget>;
		private var pWidth:Number;
		private var pHeight:Number;
		
		public function PitchTargets()
		{
			super();
		}
		
		public function createCameraTargets(pitchWidth:Number, pitchHeight:Number):Vector.<PitchTarget> {
			pWidth = pitchWidth;
			pHeight = pitchHeight;
			
			if (!aCamTargets) {
				initCameraTargets();
			}
			return aCamTargets;
		}
		
		public static function get cameraTargets():Vector.<PitchTarget> {
			return aCamTargets;
		}
		
		private function initCameraTargets():void {
			
			// Values to positionate corners and side cameras.
			var pitchLongSideTarget:uint = 920;
			var pitchShortSideTarget:uint = 320;
			
			// -------- CamTarget Positions. --------
			//
			//  (4.tL) (12.cLT) (6.tC) (14.cRT) (8.tR)
			//  (9.sL)  (1.cL)  (0.cC)  (2.cR)  (10.sR)
			//  (3.bL) (11.cLB) (5.bC) (13.cRB) (7.bR)
			//
			// --------------------------------------
			
			aCamTargets = new Vector.<PitchTarget>(15);
			var tL:Vector3D = new Vector3D(pitchLongSideTarget,50,-pitchShortSideTarget); // Top Left
			var tC:Vector3D = new Vector3D(0,50,-pitchShortSideTarget); // Top Center
			var tR:Vector3D = new Vector3D(-pitchLongSideTarget,50,-pitchShortSideTarget); // Top Right
			
			var cLT:Vector3D = new Vector3D(int(pWidth/6),0,int(-pHeight/4)); // Center Left Top
			var cL:Vector3D = new Vector3D(int(pWidth/6),0,0); // Center Left
			var cLB:Vector3D = new Vector3D(int(pWidth/6),0,int(pHeight/4)); // Center Left Bottom
			
			var cC:Vector3D = new Vector3D(0,0,0); // Center
			
			var cRT:Vector3D = new Vector3D(int(-pWidth/6),0,int(-pHeight/4)); // Center Right Top
			var cR:Vector3D = new Vector3D(int(-pWidth/6),0,0); // Center Right
			var cRB:Vector3D = new Vector3D(int(-pWidth/6),0,int(pHeight/4)); // Center Right Bottom
			
			var bL:Vector3D = new Vector3D(pitchLongSideTarget,50,pitchShortSideTarget); // Bottom Left
			var bC:Vector3D = new Vector3D(0,50,pitchShortSideTarget); // Bottom Center
			var bR:Vector3D = new Vector3D(-pitchLongSideTarget,50,pitchShortSideTarget); // Bottom Right
			
			var sL:Vector3D = new Vector3D(pitchLongSideTarget,0,0); // Side Left
			var sR:Vector3D = new Vector3D(-pitchLongSideTarget,0,0); // Side Right
			
			// For the corners and sides, I've elevated the camera a little bit to use the whole space of the screen.
			
			aCamTargets[TARGET_CENTER] = new PitchTarget(cC, 0, 10, 14); // Center.
			
			aCamTargets[TARGET_CENTER_LEFT_TOP] = new PitchTarget(cLT, -45, 10, 14); // Center Left Top.
			aCamTargets[TARGET_CENTER_LEFT] = new PitchTarget(cL, -45, 10, 14); // Center Left.
			aCamTargets[TARGET_CENTER_LEFT_BOTTOM] = new PitchTarget(cLB, -45, 10, 14); // Center Left Bottom.
			
			aCamTargets[TARGET_CENTER_RIGHT_TOP] = new PitchTarget(cRT, 45, 10, 14); // Center Right Top.
			aCamTargets[TARGET_CENTER_RIGHT] = new PitchTarget(cR, 45, 10, 14); // Center Right.
			aCamTargets[TARGET_CENTER_RIGHT_BOTTOM] = new PitchTarget(cRB, 45, 10, 14); // Center Right Bottom.
			
			aCamTargets[TARGET_BOTTOM_LEFT] = new PitchTarget(bL, 0, 9.4, 18.5); // Bottom Left.
			aCamTargets[TARGET_SIDE_LEFT] = new PitchTarget(sL, -45, 10, 14); // Side Left.
			aCamTargets[TARGET_TOP_LEFT] = new PitchTarget(tL, 180, 9.4, 18.5); // Top Left.
			
			aCamTargets[TARGET_BOTTOM_CENTER] = new PitchTarget(bC, 25, 9.4, 18.5); // Bottom Center.
			aCamTargets[TARGET_TOP_CENTER] = new PitchTarget(tC, 155, 9.4, 18.5); // Top Center.
			
			aCamTargets[TARGET_BOTTOM_RIGHT] = new PitchTarget(bR, -25, 9.4, 18.5); // Bottom Right.
			aCamTargets[TARGET_SIDE_RIGHT] = new PitchTarget(sR, 45, 10, 14); // Side Left.
			aCamTargets[TARGET_TOP_RIGHT] = new PitchTarget(tR, -155, 9.4, 18.5); // Top Right.
		}
	}
}