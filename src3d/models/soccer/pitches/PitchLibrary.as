package src3d.models.soccer.pitches
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;

	public class PitchLibrary
	{
		public static const FLOOR_ID_0:int						= 0;
		public static const FLOOR_ID_1:int						= 1;
		public static const FLOOR_ID_2:int						= 2;
		public static const FLOOR_ID_3:int						= 3;
		public static const FLOOR_ID_4:int						= 4;
		
		public static const FLOOR_NAME_0:String					= "NONE";
		public static const FLOOR_NAME_1:String					= "GRASS_STRIPES_W";
		public static const FLOOR_NAME_2:String					= "GRASS_CHECKER";
		public static const FLOOR_NAME_3:String					= "GRASS_CIRCLES";
		public static const FLOOR_NAME_4:String					= "GRASS_ONLY";
		
		public static const MARKS_ID_NONE:int 					= 0;
		public static const MARKS_ID_STANDARD:int 				= 1;
		public static const MARKS_ID_BORDER:int 				= 2;
		public static const MARKS_ID_CIRCLE:int 				= 3;
		public static const MARKS_ID_TRIANGLE:int 				= 4;
		public static const MARKS_ID_RECTANGLE:int 				= 5;
		public static const MARKS_ID_RECTANGLE_IN_2:int 		= 6;
		public static const MARKS_ID_RECTANGLE_IN_4:int 		= 7;
		public static const MARKS_ID_RECTANGLE_IN_6:int 		= 8;
		public static const MARKS_ID_THIRDS:int 				= 9;
		
		public static const MARKS_NAME_NONE:String 				= "MARKS_NAME_NONE";
		public static const MARKS_NAME_STANDARD:String 			= "MARKS_NAME_STANDARD";
		public static const MARKS_NAME_BORDER:String 			= "MARKS_NAME_BORDER";
		public static const MARKS_NAME_CIRCLE:String 			= "MARKS_NAME_CIRCLE";
		public static const MARKS_NAME_TRIANGLE:String 			= "MARKS_NAME_TRIANGLE";
		public static const MARKS_NAME_RECTANGLE:String 		= "MARKS_NAME_RECTANGLE";
		public static const MARKS_NAME_RECTANGLE_IN_2:String 	= "MARKS_NAME_RECTANGLE_IN_2";
		public static const MARKS_NAME_RECTANGLE_IN_4:String 	= "MARKS_NAME_RECTANGLE_IN_4";
		public static const MARKS_NAME_RECTANGLE_IN_6:String 	= "MARKS_NAME_RECTANGLE_IN_6";
		public static const MARKS_NAME_THIRDS:String 			= "MARKS_NAME_THIRDS";
		
		public static const MARKS_COLOR_DEFAULT:uint			= 0xFFFFFF;
		public static const MARKS_COLOR_BW:uint					= 0x000000; // For Black and White.
		
		public var aPF:Array = new Array(
			{pitchFloorId:FLOOR_ID_0, name:FLOOR_NAME_0, floor:new ColorMaterial(0x69A21D)},
			{pitchFloorId:FLOOR_ID_1, name:FLOOR_NAME_1, floor:new BitmapMaterial(Cast.bitmap(PitchModels.getInstance().PitchTexture2),{smooth:true})},
			{pitchFloorId:FLOOR_ID_2, name:FLOOR_NAME_2, floor:new BitmapMaterial(Cast.bitmap(PitchModels.getInstance().PitchTexture3),{smooth:true})},
			{pitchFloorId:FLOOR_ID_3, name:FLOOR_NAME_3, floor:new BitmapMaterial(Cast.bitmap(PitchModels.getInstance().PitchTexture4),{smooth:true})},
			{pitchFloorId:FLOOR_ID_4, name:FLOOR_NAME_4, floor:new BitmapMaterial(Cast.bitmap(PitchModels.getInstance().PitchTexture1),{smooth:true})}
		);
		
		// PMarks = // Main pitch marks.
		public var aPM:Array = new Array(
			{pitchMarksId:MARKS_ID_NONE, name:MARKS_NAME_NONE, defaultPitch:false, marks:new ObjectContainer3D({name:"marks"})},
			{pitchMarksId:MARKS_ID_STANDARD, name:MARKS_NAME_STANDARD, defaultPitch:true, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarks),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_BORDER, name:MARKS_NAME_BORDER, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksBorder),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_CIRCLE, name:MARKS_NAME_CIRCLE, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksCircle),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_TRIANGLE, name:MARKS_NAME_TRIANGLE, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksTriangle),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_RECTANGLE, name:MARKS_NAME_RECTANGLE, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksRectangle),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_RECTANGLE_IN_2, name:MARKS_NAME_RECTANGLE_IN_2, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksRectangleIn2),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_RECTANGLE_IN_4, name:MARKS_NAME_RECTANGLE_IN_4, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksRectangleIn4),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_RECTANGLE_IN_6, name:MARKS_NAME_RECTANGLE_IN_6, defaultPitch:false, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksRectangleIn6),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})},
			{pitchMarksId:MARKS_ID_THIRDS, name:MARKS_NAME_THIRDS, defaultPitch:true, marks:Max3DS.parse(Cast.bytearray(PitchModels.getInstance().PitchMarksThirds),{autoLoadTextures:false, rotationX:90, scale:4, ownCanvas:true, name:"marks"})}
		);
		
		// Singleton.
		private static var _self:PitchLibrary;
		private static var _allowInstance:Boolean = false;
		
		public function PitchLibrary()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("Library initialized.");
				//init();
			}
		}
		
		public static function getInstance():PitchLibrary
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new PitchLibrary();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
	}
}