package src.popup
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class PopupBtnBase extends MovieClip
	{
		protected var stageEventHandler:EventHandler;
		protected var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		protected var popupMc:MovieClip;
		protected var popupBtn:DisplayObject; // Accepts either Button or MovieClip.
		
		protected var popupBtnAlwaysVisible:Boolean = false; // Always shows the main button.
		protected var hideOnPopupClick:Boolean = false; // Hides the popup when clicking on it.

		public function PopupBtnBase() {
			init();
		}
		
		protected function init():void {
			stageEventHandler = new EventHandler(main.stage);
			this.visible = false;
		}
		
		public function set buttonEnabled(be:Boolean):void {
			if (be) {
				if (!popupBtn.hasEventListener(MouseEvent.CLICK)) popupBtn.addEventListener(MouseEvent.CLICK, onPopupBtnClick);
//				this.addEventListener(MouseEvent.MOUSE_UP, hidePopup);
				this.visible = true;
				sspEventHandler.addEventListener(SSPEvent.CONTROL_POPUP_VISIBLE, onPopupVisible, false, 0, true);
				stageEventHandler.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				
			} else {
				if (!popupBtnAlwaysVisible) {
					popupBtn.removeEventListener(MouseEvent.CLICK, onPopupBtnClick);
					sspEventHandler.RemoveEvent(SSPEvent.CONTROL_POPUP_VISIBLE);
//					this.removeEventListener(MouseEvent.MOUSE_UP, hidePopup);
					popupMc.removeEventListener(MouseEvent.CLICK, onPopupClick);
					popupMc.visible = false;
					this.visible = false;
					stageEventHandler.RemoveEvent(MouseEvent.MOUSE_DOWN);
				}
			}
		}
		
		protected function onPopupBtnClick(e:MouseEvent):void {
			if (popupMc.visible) {
				hidePopup(e);
			} else {
				showPopup(e);
			}
		}
		
		protected function showPopup(e:MouseEvent = null):void {
			//trace("showPopup()");
//			popupBtn.removeEventListener(MouseEvent.CLICK, onPopupBtnClick);
			
			if (!popupMc.visible) {
				sspEventHandler.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_POPUP_VISIBLE, false));
				popupMc.addEventListener(MouseEvent.CLICK, onPopupClick);
				popupMc.visible = true;
			}
		}
		
		protected function hidePopup(e:MouseEvent = null):void {
			//trace("hidePopup()");
			if (popupMc.visible) {
				popupMc.removeEventListener(MouseEvent.CLICK, onPopupClick);
				popupMc.visible = false;
			}
			this.removeEventListener(MouseEvent.MOUSE_UP, hidePopup);
//			popupBtn.addEventListener(MouseEvent.CLICK, onPopupBtnClick);
		}
		
		// Overriden in extending classes.
		protected function onPopupClick(e:MouseEvent):void {
			if (hideOnPopupClick) hidePopup();
		}
		
		protected function onPopupVisible(e:SSPEvent):void {
			if (!e.eventData) {
				hidePopup();
			}
		}
		
		protected function onStageMouseDown(e:MouseEvent):void {
			if (!popupMc.visible) return;
			var clickedOnPopup:Boolean;
			if ( MiscUtils.objectContainsPoint(popupMc, new Point(main.stage.mouseX, main.stage.mouseY), main.stage) || 
				e.target == popupMc ||
				e.target == popupBtn
			) {
				clickedOnPopup = true;
			}
			if (clickedOnPopup) {
				if (hideOnPopupClick) {
					hidePopup();
//					if (!popupBtnAlwaysVisible) buttonEnabled = false;
				}
			} else {
				hidePopup();
//				if (!popupBtnAlwaysVisible) buttonEnabled = false;
			}
		}
		
		public function get popupVisible():Boolean {
			return (popupMc && popupMc.visible)? true : false;
		}
		
		public function set popupVisible(value:Boolean):void {
			if (value) {
				showPopup();
			} else {
				hidePopup();
			}
		}
	}
}