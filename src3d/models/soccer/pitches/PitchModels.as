package src3d.models.soccer.pitches
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.WireColorMaterial;

	public class PitchModels {
		[Embed(source="PitchMarks.3ds", mimeType="application/octet-stream")]
		public var PitchMarks:Class;
		[Embed(source="PitchMarksBorder.3ds", mimeType="application/octet-stream")]
		public var PitchMarksBorder:Class;
		[Embed(source="PitchMarksCircle.3ds", mimeType="application/octet-stream")]
		public var PitchMarksCircle:Class;
		//[Embed(source="PitchMarksSquare.3ds", mimeType="application/octet-stream")]
		//public var PitchMarksSquare:Class;
		[Embed(source="PitchMarksTriangle.3ds", mimeType="application/octet-stream")]
		public var PitchMarksTriangle:Class; 
		[Embed(source="PitchMarksRectangle.3ds", mimeType="application/octet-stream")]
		public var PitchMarksRectangle:Class;
		[Embed(source="PitchMarksRectangleIn2.3ds", mimeType="application/octet-stream")]
		public var PitchMarksRectangleIn2:Class;
		[Embed(source="PitchMarksRectangleIn4.3ds", mimeType="application/octet-stream")]
		public var PitchMarksRectangleIn4:Class;
		[Embed(source="PitchMarksRectangleIn6.3ds", mimeType="application/octet-stream")]
		public var PitchMarksRectangleIn6:Class;
		[Embed(source="PitchMarksThirds.3ds", mimeType="application/octet-stream")]
		public var PitchMarksThirds:Class;
		
		[Embed(source="images/pitch_texture_1.jpg")]
		public var PitchTexture1:Class;
		[Embed(source="images/pitch_texture_2.jpg")]
		public var PitchTexture2:Class;
		[Embed(source="images/pitch_texture_3.jpg")]
		public var PitchTexture3:Class;
		[Embed(source="images/pitch_texture_4.jpg")]
		public var PitchTexture4:Class;
		
		// For Future Use.
		/*public var PitchTexture5:ColorMaterial = new ColorMaterial(0x53ad0f);
		public var PitchTextureBW:ColorMaterial = new ColorMaterial(0xFFFFFF);
		public var PitchMarksBW:WireColorMaterial = new ColorMaterial(0x000000);
		public var PitchMarksMat:WireColorMaterial;*/
		
		// Singleton.
		private static var _self:PitchModels;
		private static var _allowInstance:Boolean = false;
		
		public function PitchModels()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("Library initialized.");
				//init();
			}
		}
		
		public static function getInstance():PitchModels
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new PitchModels();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
	}
}