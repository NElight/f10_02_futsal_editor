package
{
	import flash.display.MovieClip;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	
	import src3d.SessionGlobals;
	import src3d.models.soccer.equipment.MCEquipment;
	
	public class equipment extends MovieClip
	{
		private var _ref:MovieClip;
		// Equipment array
		//private var aEquipment:Array = [];
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		public function equipment(ref:MovieClip)
		{
			_ref = ref.panel2; // Get panel2 from mc_accordion.

			// Create array of Equipment MC's.
			var i:int;
			var mc:MovieClip;
			var mcName:String;
			var vTooltipSettings:Vector.<SSPToolTipSettings> = new Vector.<SSPToolTipSettings>();
			for(i=0; i<_ref.numChildren; i++) {
				mc = _ref.getChildAt(i) as MovieClip;
				if (mc != null) {
					// Equipment names has this format: "equipment###" or this format "equipment##" in football and futsal.
					mcName = mc.name.substr(0,mc.name.length - MCEquipment.namesDigits); // Get all but # last digits.
					if (mcName == MCEquipment.NAME_EQUIPMENT) {
						//aEquipment.push(mc);
						vTooltipSettings.push(new SSPToolTipSettings(mc, getToolTipText(mc)));
					}
				}
			}
			
			SSPToolTip.getInstance().addToolTips(vTooltipSettings);
		}
		
		private function getToolTipText(mc:MovieClip):String {
			var objId:String = mc.name.substr(mc.name.length-MCEquipment.namesDigits); // Get the Id from the instance name (last digits).
			var tagName:String = "_tagEquipment"+objId;
			var ttText:String = sG.interfaceLanguageDataXML.tags[0][tagName].text();
			return ttText;
		}
	}
}