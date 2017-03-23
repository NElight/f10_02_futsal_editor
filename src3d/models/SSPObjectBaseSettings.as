package src3d.models
{
	import flash.geom.Vector3D;
	
	import src3d.utils.MiscUtils;
	
	public class SSPObjectBaseSettings
	{
		public var _screenId:int = -1;
		public var _objectType:String = "";
		public var _libraryId:Number = -1;
		
		public var _x:Number = 0;
		public var _y:Number = 0;
		public var _z:Number = 0;
		public var _rotationY:Number = 0;
		public var _onlyDefaultPitches:Boolean = false;
		public var _elevationNumber:Number = 0;
		public var _size:Number = 1;
		public var _transparency:Boolean = false;
		public var _flipH:Boolean = false;
		
		public function SSPObjectBaseSettings()
		{
		}
		
		// Use this function to allow a different object settings object to be cloned.
		/*public function clone(_newObjSettings:SSPObjectBaseSettings = null):SSPObjectBaseSettings
		{
			var newObjSettings:SSPObjectBaseSettings = (_newObjSettings as SSPObjectBaseSettings) || new SSPObjectBaseSettings();
			// Copy settings.
			return newObjSettings;
		}*/
		
		/**
		 * Returns a copy of this object settings.
		 * Note that the settings may need to be updated first.
		 * @param cloneIn SSPObjectBaseSettings. If another settings object is specified, it will clone the settings into that one.
		 * Use it to get the base settings into an extending settings object.
		 * Eg: super.clone(myLineSettings); will pass all the base settings into the extended class object myLineSettings.
		 * @return SSPObjectBaseSettings 
		 */		
		public function clone(cloneIn:SSPObjectBaseSettings = null):SSPObjectBaseSettings
		{
			var newObjSettings:SSPObjectBaseSettings = (cloneIn)? cloneIn : new SSPObjectBaseSettings();
			newObjSettings._screenId = this._screenId;
			newObjSettings._objectType = this._objectType;
			newObjSettings._libraryId = this._libraryId;
			newObjSettings._x = this._x;
			newObjSettings._y = this._y;
			newObjSettings._z = this._z;
			newObjSettings._rotationY = this._rotationY;
			newObjSettings._onlyDefaultPitches = this._onlyDefaultPitches;
			newObjSettings._elevationNumber = this._elevationNumber;
			newObjSettings._size = this._size;
			newObjSettings._transparency = this._transparency;
			newObjSettings._flipH = this._flipH;
			
			return newObjSettings;
		}
		
		/**
		 * Returns true or false as string 'TRUE' or 'FALSE'. 
		 * @return String 
		 */
		public function get _flipHString():String {
			return (this._flipH)? "TRUE" : "FALSE";
		}
		
		/**
		 * Returns true or false as string 'TRUE' or 'FALSE'. 
		 * @return String 
		 */
		public function get _onlyDefaultPitchesString():String {
			return (this._onlyDefaultPitches)? "TRUE" : "FALSE";
		}
		
		/**
		 * Returns true or false as string 'TRUE' or 'FALSE'. 
		 * @return String 
		 */
		public function get _transparencyString():String {
			return (this._transparency)? "TRUE" : "FALSE";
		}
		
		/**
		 * Some items like Equipments and Players uses <_y> from xml data for the internal meshes elevation and 0 for the container y pos. 
		 * @return Vector3D
		 */		
		public function get _objPos():Vector3D {
			return new Vector3D(_x, _elevationNumber, _z);
		}
		
		/*
		 * Some Equipment objects are scalable, like the goals or the tennis net. 
		 * @return Vector3D
		*/
		public function get _objSize():Vector3D {
			return new Vector3D(_size, _size, _size);
		}
	}
}