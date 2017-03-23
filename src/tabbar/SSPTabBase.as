package src.tabbar
{
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import src.buttons.SSPDualButton;
	import src.controls.tooltip.SSPToolTip;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	
	public class SSPTabBase extends SSPDualButton
	{
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		
		protected var _objectType = SSPTabTypeLibrary.OBJECT_TYPE_SCREEN_TAB_BASE; // See SSPTabTypeLibrary.
		protected var _tabGroup:int = -1; // -1: addTab's, 0 or 1 for Tabs.
		protected var _labelEditable:Boolean;
		
		protected var tabAArea:SimpleButton;
		protected var tabBArea:SimpleButton;
		protected var tabAClose:SimpleButton;
		protected var tabBClose:SimpleButton;
		private var tabAColor:MovieClip;
		private var tabBColor:MovieClip;
		
		private var tabScreenColor:uint = 0xffffff;
		//private var tabGroup0Color:uint = 0x3399FF;
		private var tabGroup0Color:uint = 0x7ebfff;
		//private var tabGroup1Color:uint = 0xFF9900;
		private var tabGroup1Color:uint = 0xffcc33;
		
		public function SSPTabBase(objType:String, tabButtonA:McTabBase, tabButtonB:McTabBase, labelEditable:Boolean)
		{
			super(tabButtonA, tabButtonB, "");
			this._objectType = objType;
			this.name = objType;
			this._labelEditable = labelEditable;
			
			if (tabButtonA.tabClose) tabAClose = tabButtonA.tabClose;
			tabAArea = tabButtonA.tabBtnArea;
			tabAColor = tabButtonA.tabColor;
			tabAColor.visible = false;
			tabAColor.blendMode = BlendMode.OVERLAY;
			
			if (btnB) {
				if (tabButtonB.tabClose) tabBClose = tabButtonB.tabClose;
				tabBArea = tabButtonB.tabBtnArea;
				tabBColor = tabButtonB.tabColor;
				tabBColor.visible = false;
				tabBColor.blendMode = BlendMode.OVERLAY;
			}
		}
		
		
		
		// ----------------------------- Controls ----------------------------- //
		protected override function set listenersEnabled(lEnabled:Boolean):void {
			super.listenersEnabled = lEnabled;
			if (lEnabled) {
				btnA.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseMouseDown, false, 0, true);
				btnA.addEventListener(MouseEvent.MOUSE_UP, onButtonMouseMouseUp, false, 0, true);
				btnA.addEventListener(MouseEvent.CLICK, onButtonMouseClick, false, 0, true);
				if (btnB) {
					btnB.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseMouseDown, false, 0, true);
					btnB.addEventListener(MouseEvent.MOUSE_UP, onButtonMouseMouseUp, false, 0, true);
					btnB.addEventListener(MouseEvent.CLICK, onButtonMouseClick, false, 0, true);
				}
			} else {
				btnA.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseMouseDown);
				btnA.removeEventListener(MouseEvent.MOUSE_UP, onButtonMouseMouseUp);
				btnA.removeEventListener(MouseEvent.CLICK, onButtonMouseClick);
				if (btnB) {
					btnB.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseMouseDown);
					btnB.removeEventListener(MouseEvent.MOUSE_UP, onButtonMouseMouseUp);
					btnB.removeEventListener(MouseEvent.CLICK, onButtonMouseClick);
				}
			}
		}
		
		protected function onButtonMouseMouseDown(e:MouseEvent):void {
			if (!buttonEnabled) return;
			SSPToolTip.getInstance().removeToolTip();
			// If !buttonClose.
			if (e.target != tabAClose && e.target != tabBClose) {
				this.dispatchEvent(new SSPEvent(SSPEvent.TAB_MOUSE_DOWN));
			}
		}
		
		protected function onButtonMouseMouseUp(e:MouseEvent):void {
			if (!buttonEnabled) return;
			this.dispatchEvent(new SSPEvent(SSPEvent.TAB_MOUSE_UP));
		}
		
		protected function onButtonMouseClick(e:MouseEvent):void {
			if (!buttonEnabled) return;
			SSPToolTip.getInstance().removeToolTip();
			// If buttonClose.
			if (e.target == tabAClose || e.target == tabBClose) {
				this.dispatchEvent(new SSPEvent(SSPEvent.TAB_CLOSE_CLICK, this));
			} else {
				this.dispatchEvent(new SSPEvent(SSPEvent.TAB_CLICK));
			}
		}
		// -------------------------- End of Controls ------------------------- //
		
		
		
		// ----------------------------- Background Color ----------------------------- //
		public function set tabBackgroundType(tabType:String):void {
			// Change tab colour.
			var colT:ColorTransform = tabAColor.transform.colorTransform;
			switch (tabType) {
				case SessionGlobals.SCREEN_TYPE_PERIOD:
					colT.color = this.tabGroup0Color;
					break;
				case SessionGlobals.SCREEN_TYPE_SET_PIECE:
					colT.color = this.tabGroup1Color;
					break;
				default:
					colT.color = this.tabScreenColor;
					break;
			}
			
//			if (tabType != SessionGlobals.SCREEN_TYPE_SCREEN) {
				tabAColor.transform.colorTransform = colT;
				tabAColor.visible = true;
				if (tabBColor) {
					tabBColor.transform.colorTransform = colT;
					tabBColor.visible = true;
				}
//			}
		}
		// -------------------------- End of Background Color ------------------------- //
		
		
		// ----------------------------- Gettters/Setters ----------------------------- //
		public function get objectType():String { return _objectType; }
		public function set tabSelected(s:Boolean):void { this.buttonSelected = s; }
		public function get tabSelected():Boolean { return this.buttonSelected; }
		public function get isTab():Boolean {
			return (_objectType == SSPTabTypeLibrary.OBJECT_TYPE_SCREEN_TAB)? true : false;
		}
		public function get tabGroup():int { return _tabGroup; }
		public function set tabGroup(g:int):void {
			this._tabGroup = g;
			var sType:String = this.getScreenTypeFromGroup(g);
			this.tabBackgroundType = sType;
		}
		public function get tabCloseVisible():Boolean {
			if (!tabAClose) return false;
			return tabAClose.visible;
		}
		public function set tabCloseVisible(value:Boolean):void {
			if (tabAClose) tabAClose.visible = value;
			if (tabBClose) tabBClose.visible = value;
		}
		// -------------------------- End of Gettters/Setters ------------------------- //
		
		
		
		protected function getScreenTypeFromGroup(g:int):String {
			var sType:String;
			switch (g) {
				case 0:
					if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
						sType = SessionGlobals.SCREEN_TYPE_PERIOD;
					} else {
						sType = SessionGlobals.SCREEN_TYPE_SCREEN;
					}
					break;
				case 1:
					sType = SessionGlobals.SCREEN_TYPE_SET_PIECE;
					break;
				default:
					sType = SessionGlobals.SCREEN_TYPE_SCREEN;
			}
			return sType;
		}
		
		public override function dispose():void {
			listenersEnabled = false;
			tabAClose = null;
			tabBClose = null;
			tabAColor = null;
			tabBColor = null;
			super.dispose();
		}
	}
}