package src3d.models.soccer.equipment
{
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.utils.Drag2DObject;
	
	public class MCEquipment extends Drag2DObject
	{
		// Array of 2D Player Names. 
		public static const NAME_EQUIPMENT:String = "equipment"; // Instance names format: equipment###.
		public static const namesDigits:uint = 2; // Number of digits used in 2D instance names.
		
		private var objId:int = -1;
		private var objType:String = ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT;
		
		public function MCEquipment()
		{
			objId = int( this.name.substr(this.name.length-namesDigits) ); // Get the Id from the instance name (last digits).
			super(objType, objId);
		}
	}
}