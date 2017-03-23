package src.popup
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	import src3d.SessionGlobals;
	
	public class PopupBox extends SSPBoxBase
	{
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		
		protected var _popupEnabled:Boolean = true; // Used to disable the popup box in ssp viewer.
		protected var _popupVisible:Boolean;
		
		public function PopupBox(st:Stage, content:DisplayObject, formTitle:String="", useInnerBg:Boolean=true, usePadding:Boolean=false, boxW:int=-1, boxH:int=-1,
								 autoCenter:Boolean=true, useHeader:Boolean=true, useCloseBtn:Boolean=true, useDarkerClose:Boolean=true, useEscClose:Boolean=true, boxPadding:Number = 10) {
			super(st, content, formTitle, useInnerBg, usePadding, boxW, boxH, autoCenter, useHeader, useCloseBtn, useDarkerClose, useEscClose, boxPadding);
		}
		
		public function set popupVisible(v:Boolean):void {
			if (v) {
				showBox();
			} else {
				closeBox();
			}
		}
		public function get popupVisible():Boolean {
			return _popupVisible;
		}
		
		protected override function showBox():void {
			if (!_stage || !_popupEnabled) return;
			if (!_stage.contains(this)) _stage.addChild(this);
			sG.sScreenKeysEnabled = false; // Disable 3D Keys.
			super.showBox();
			_popupVisible = true;
		}
		
		protected override function closeBox():void {
			super.closeBox();
			sG.sScreenKeysEnabled = true; // Enable 3D Keys.
			_popupVisible = false;
		}
		
		/**
		 * Override to enable/disable the popup events and custom buttons. See MessageBox.as.
		 * This is used where no msg box has to be displayed (like the ssp viewer app). 
		 */
		public function set popupEnabled(en:Boolean):void {
			_popupEnabled = en;
		}
		public function get popupEnabled():Boolean {
			return _popupEnabled;
		}
	}
}