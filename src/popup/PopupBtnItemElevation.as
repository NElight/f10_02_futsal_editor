package src.popup
{
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.events.MouseEvent;
	import src3d.models.Equipment;
	
	public class PopupBtnItemElevation extends PopupBtnBase
	{
		private var aYPos:Array = [0, 25, 50];	
		private var slider:Slider;
		private var item:Equipment;
		
		public function PopupBtnItemElevation()
		{
			super();
		}
		
		protected override function init():void {
			super.init();
			popupMc = this.mcPopup;
			popupMc.visible = false;
			popupBtn = this.btn_custom_item_elevation.btnButton;
			slider = popupMc.mcSlider;
			slider.liveDragging = true;
			this.visible = false;
			
			slider.addEventListener(SliderEvent.CHANGE, onSliderChange, false, 0, true);
		}
		
		/*protected override function showPopup(e:MouseEvent = null):void {
			super.showPopup(e);
			popupMc.addEventListener(MouseEvent.CLICK, onPopupClick);
		}*/
		
		protected override function onPopupClick(e:MouseEvent):void {
			super.onPopupClick(e);
			
		}
		
		public function setItem(itm:Object):void {
			item = itm as Equipment;
			slider.value = item.elevationRatio;
			updateElevationButton(slider.value);
		}

		public function onSliderChange(e:SliderEvent):void {
			if (!item) return;
			//if (item.hasOwnProperty("elevatable")) {
				if (item.elevatable) {
					item.elevationRatio = slider.value;
					updateElevationButton(slider.value);
				}
			//}
		}
		
		private function updateElevationButton(elev:Number):void {
			var iconPos:uint;
			if (elev <= 0.333) {
				iconPos = 1;
			} else if (elev <= 0.666) {
				iconPos = 2;
			} else if (elev <= 1) {
				iconPos = 3;
			}
			
			trace("elev: "+elev+" iconPos: "+iconPos);
			this.btn_custom_item_elevation.iel_icon.gotoAndStop(iconPos);
		}
	}
}