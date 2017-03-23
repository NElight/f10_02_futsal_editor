package src3d.models.soccer.equipment
{
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.MiscUtils;
	
	public class EquipmentSettings extends SSPObjectBaseSettings
	{
		public var _equipColor:int = -1;
		public var _pathData:String = "0";
		
		public function EquipmentSettings()
		{
		}
		
		public override function clone(cloneIn:SSPObjectBaseSettings = null):SSPObjectBaseSettings
		{
			var newObjSettings:EquipmentSettings = (cloneIn)? cloneIn as EquipmentSettings: new EquipmentSettings();
			super.clone(newObjSettings); // Get base settings.
			newObjSettings._equipColor = this._equipColor;
			newObjSettings._pathData = this._pathData;
			
			return newObjSettings;
		}
		
		public function get _equipColorHex():String {
			var ec:String = "-1";
			if (_equipColor > -1) {
				//ec = "0x"+equipColor.toString(16);
				ec = MiscUtils.getNumberAsHexString(_equipColor);
			}
			return ec;
		}
		
		public function get _flip():int {
			return (_flipH)? 1 : 0;
		}
	}
}