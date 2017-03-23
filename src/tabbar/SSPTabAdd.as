package src.tabbar
{
	import src.buttons.SSPSimpleButton;
	
	import src3d.SessionGlobals;
	
	public class SSPTabAdd extends SSPTabBase
	{
		public function SSPTabAdd(tabGroup:int, useSep:Boolean)
		{
			var sG:SessionGlobals = SessionGlobals.getInstance();
			var strTitle:String;
			var strTooltip:String;
			
			// Check if match mode.
			if (sG.sessionTypeIsMatch) {
				if (tabGroup == 1) {
					strTitle = sG.interfaceLanguageDataXML.buttons._addSetPiece.text();
					strTooltip = sG.interfaceLanguageDataXML.tags._btnAddSetPiece.text();
				} else {
					strTitle = sG.interfaceLanguageDataXML.buttons._addPeriod.text();
					strTooltip = sG.interfaceLanguageDataXML.tags._btnAddPeriod.text();
				}
				strTitle = "<b>"+strTitle+"</b>";
			}else {
				strTitle = ""; // No expanded tab in training mode.
				strTooltip = sG.interfaceLanguageDataXML.tags._btnAddScreen.text();
			}
			
			// Separator x 27, y -32.
			super(SSPTabTypeLibrary.OBJECT_TYPE_SCREEN_TAB_ADD, new McTabAddSmall(strTitle, true, useSep), new McTabAddLarge(strTitle, true, useSep), false);
			
			this.tabGroup = tabGroup;
			this.setToolTipText(strTooltip);
		}
	}
}