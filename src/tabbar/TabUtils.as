package src.tabbar
{
	import src3d.SessionGlobals;

	public class TabUtils
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:TabUtils;
		private static var _allowInstance:Boolean = false;
		public function TabUtils()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				init();
			}
		}
		public static function getInstance():TabUtils {
			if(_self == null) {
				_allowInstance=true;
				_self = new TabUtils();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		// ----------------------------- Inits ----------------------------- //
		private function init():void {
			initTabDefaultLabels();
		}
		// -------------------------- End of Inits ----------------------------- //
		
		
		
		private var _defaultLabelWildcard:String = SSPSettings.DEFAULT_TAB_LABEL_WILDCARD; // To be replaced with tab number.
		private var _defaultLabelScreen:String = "";
		private var _defaultLabelPeriod:String = "";
		private var _defaultLabelSetPiece:String = "";
		
		private var regExpTabLabelPatternScreen:RegExp;
		private var regExpTabLabelPatternPeriod:RegExp;
		private var regExpTabLabelPatternSetPiece:RegExp;
		
		
		
		// ----------------------------- Tab Labels ----------------------------- //
		private function initTabDefaultLabels() {
			_defaultLabelScreen = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titleScreen.text();
			var aTitleSplit:Array = _defaultLabelScreen.split(_defaultLabelWildcard);
			var strScreenPattern:String = "^(" + aTitleSplit['0'] + ")[0-9](" + aTitleSplit['1'] + ")*$";
			regExpTabLabelPatternScreen = new RegExp(strScreenPattern);
			
			_defaultLabelPeriod = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titlePeriodScreen.text();
			var aTitleSplit:Array = _defaultLabelPeriod.split(_defaultLabelWildcard);
			var strScreenPattern:String = "^(" + aTitleSplit['0'] + ")[0-9](" + aTitleSplit['1'] + ")*$";
			regExpTabLabelPatternPeriod = new RegExp(strScreenPattern);
			
			_defaultLabelSetPiece = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titleSetpieceScreen.text();
			var aTitleSplit:Array = _defaultLabelSetPiece.split(_defaultLabelWildcard);
			var strScreenPattern:String = "^(" + aTitleSplit['0'] + ")[0-9](" + aTitleSplit['1'] + ")*$";
			regExpTabLabelPatternSetPiece = new RegExp(strScreenPattern);
		}

		public function get defaultLabelScreen():String {
			if (_defaultLabelScreen == "") initTabDefaultLabels();
			return _defaultLabelScreen;
		}
		public function get defaultLabelPeriod():String {
			if (_defaultLabelPeriod == "") initTabDefaultLabels();
			return _defaultLabelPeriod;
		}
		public function get defaultLabelSetPiece():String {
			if (_defaultLabelSetPiece == "") initTabDefaultLabels();
			return _defaultLabelSetPiece;
		}
		
		/**
		 * If Tab Label matches tab naming pattern, a new default Tab Label is return.
		 * Else same Tab Label is returned. 
		 * @param tabLabel String. The current tab name.
		 * @param screenType String. Specify the screen type (Screen, Period, Set-piece).
		 * @param newTabNumber String. New tab number to use if current tab name matches the pattern. Use -1 for no tab number.
		 * @return String. The processed tab label.
		 */
		public function updateTabLabel(tabLabel:String, screenType:String, newTabNumber:int):String {
			var newTabLabel:String = tabLabel;
			var strTabNumber:String = (newTabNumber < 0)? "" : newTabNumber.toString();
			if (!regExpTabLabelPatternPeriod) initTabDefaultLabels();
			if(regExpTabLabelPatternPeriod.test(tabLabel)) {
				newTabLabel = defaultLabelPeriod.replace(SSPSettings.DEFAULT_TAB_LABEL_WILDCARD, strTabNumber);
			} else if(regExpTabLabelPatternSetPiece.test(tabLabel)) {
				newTabLabel = defaultLabelSetPiece.replace(SSPSettings.DEFAULT_TAB_LABEL_WILDCARD, strTabNumber);
			} else if (regExpTabLabelPatternScreen.test(tabLabel)) {
				newTabLabel = defaultLabelScreen.replace(SSPSettings.DEFAULT_TAB_LABEL_WILDCARD, strTabNumber);
			}
			
			// If no Tab Label or Tab Label is a tab label Pattern, set label by Screen Type.
			if (!tabLabel
				|| tabLabel == ""
				|| tabLabel == defaultLabelScreen
				|| tabLabel == defaultLabelPeriod
				|| tabLabel == defaultLabelSetPiece
			) {
				if (screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
					newTabLabel = defaultLabelSetPiece.replace(_defaultLabelWildcard, newTabNumber);
				} else if (screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					newTabLabel = defaultLabelPeriod.replace(_defaultLabelWildcard, newTabNumber);
				} else {
					newTabLabel = defaultLabelScreen.replace(_defaultLabelWildcard, newTabNumber);
				}
			}
			
			return newTabLabel;
		}
		// -------------------------- End of Tab Labels ------------------------- //
	}
}