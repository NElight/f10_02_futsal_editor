package src3d
{
	public class ButtonsManager
	{
		// Singleton.
		private static var _self:ButtonsManager;
		private static var _allowInstance:Boolean = false;
		
		protected var sG:SessionGlobals;
		protected var sspEventDispatcher:SSPEventDispatcher;
		
		private var vDefaultBtnSettings:Vector.<ButtonSettings> = new Vector.<ButtonSettings>();
		private var vBtnSettingsEnabled:Vector.<ButtonSettings> = new Vector.<ButtonSettings>();
		
		public function ButtonsManager()
		{
			sG = SessionGlobals.getInstance();
			sspEventDispatcher = SSPEventDispatcher.getInstance()
			initDefaultButtons();
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():ButtonsManager
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new ButtonsManager();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		private function initDefaultButtons():void {
			// Set Equipment Colors.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_EQUIP_COLOR, false, 0, null, false));
			// Set Item Elevation.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_ELEVATION, false, 0, null, false));
			// Set Item Resize.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_SIZE, false, 0, null, false));
			// Set Item Cloning.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_CLONE, false, 0, null, false));
			// Set Item Pinning.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_PIN, false, 0, null, false));
			// Set Arrow Head Position.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ARROWHEAD_POS, false, -1, null, false));
			// Set Custom Kit Button.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_PLAYER_KIT, false, 0, null, false));
			// Set Item Transparency.
			vDefaultBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_TRANSPARENCY, false, 0, null, false));
		}
		
		/**
		 * Shows specified buttons. 
		 * @param vShowBtnSettings Vector.<ButtonSettings>.
		 */
		public function showButtons(vShowBtnSettings:Vector.<ButtonSettings>):void {
			if (!vShowBtnSettings) return;
			//if (vShowBtnSettings.length == 0) return;  // Don't use this check. Some 3D objects like Texts needs 0 length to disable the other objects buttons when created.
			hideAllButtons();
			// Dispatch.
			for each(var btnSettings:ButtonSettings in vShowBtnSettings) { btnSettings.btnVisible = true; }
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, vShowBtnSettings));
		}
		
		/**
		 * Hides specified buttons. 
		 * @param vHideBtnSettings Vector.<ButtonSettings>.
		 */
		public function hideButtons(vHideBtnSettings:Vector.<ButtonSettings>):void {
			if (!vHideBtnSettings) return;
			if (vHideBtnSettings.length == 0) return;
			if (!sG.createMode) {
				for each(var btnSettings:ButtonSettings in vHideBtnSettings) { btnSettings.btnVisible = false; }
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, vHideBtnSettings));
			}
		}
		
		public function hideAllButtons():void {
			if (!vDefaultBtnSettings) return;
			if (vDefaultBtnSettings.length == 0) return;
			if (!sG.createMode) {
				for each(var btnSettings:ButtonSettings in vDefaultBtnSettings) { btnSettings.btnVisible = false; }
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, vDefaultBtnSettings));
			}
		}
	}
}