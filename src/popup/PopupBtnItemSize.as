package src.popup
{
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import src3d.models.Equipment;
	import src3d.utils.MiscUtils;
	
	public class PopupBtnItemSize extends PopupBtnBase
	{
		private var aYPos:Array = [0, 25, 50];	
		private var slider:Slider;
		private var resetBtn:SimpleButton
		private var item:Equipment;
		
		public function PopupBtnItemSize()
		{
			super();
		}
		
		protected override function init():void {
			super.init();
			popupMc = this.mcPopup;
			popupMc.visible = false;
			popupBtn = this.btn_custom_item_size.btnButton;
			slider = popupMc.mcSlider;
			slider.liveDragging = true;
			resetBtn = popupMc.btnReset;
			this.visible = false;
			
			resetBtn.addEventListener(MouseEvent.CLICK, onResetClick, false, 0, true);
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
			updateSlider();
		}
		
		private function onResetClick(e:MouseEvent):void {
			if (!item || !item.resizable) return;
			item.resetSize();
			updateSlider();
		}
		
		private function updateSlider():void {
			//return item.size / (item.maxSize - item.minSize); // Item's current ratio.
			updateItemRatios();
			for (var i:int = 0;i<item.aSizeRatios.length;i++) {
				if (item.aSizeRatios[i] == item.size) {
					slider.value = (i + 1) * slider.snapInterval;
					break;
				}
			}
			updateButtonIcon();
			updateReset();
		}
		
		private function updateReset():void {
			if (item.size == item.sizeDefault) {
				//resetBtn.enabled = false;
				resetBtn.mouseEnabled = false;
				resetBtn.alpha = .5;
			} else {
				//resetBtn.enabled = true;
				resetBtn.mouseEnabled = true;
				resetBtn.alpha = 1;
			}
		}

		public function onSliderChange(e:SliderEvent):void {
			if (!item) return;
			//if (item.hasOwnProperty("resizable")) {
				if (item.resizable) {
					updateItemSizeRatio();
					updateButtonIcon();
					updateReset();
				}
			//}
		}
		
		private function updateItemSizeRatio():void {
			updateItemRatios();
			var sliderPos:Number = Math.round(slider.value / slider.snapInterval);
			trace("SliderPos: "+String(sliderPos-1)+". Resize To: " + item.aSizeRatios[sliderPos-1]);
			item.size = item.aSizeRatios[sliderPos-1];
		}
		
		private function updateItemRatios():void {
			if (item.aSizeRatios || isNaN(slider.value)) return;
			var aSizeRatios:Array = [];
			var stepValue:Number;
			var stepCloserIdx:Number;
			var stepCloserRatio:Number;
			var stepCloserRatioTmp:Number;
			var sliderLength:Number = (slider.maximum - slider.minimum) / slider.snapInterval;
			var sliderIncrement:Number = (item.maxSize - item.minSize) / sliderLength;
			
			for (var i:int=0;i<=sliderLength;i++) {
				stepValue = item.minSize + (sliderIncrement * i);
				aSizeRatios.push(MiscUtils.trimNum2Dec(stepValue));
				// Get closer to 1.
				stepCloserRatioTmp = Math.abs(1 - stepValue);
				if (stepCloserRatioTmp < stepCloserRatio || isNaN(stepCloserRatio)) {
					stepCloserRatio = stepCloserRatioTmp;
					stepCloserIdx = i;
				}
			}
			if (stepCloserIdx) aSizeRatios[stepCloserIdx] = 1;
			item.aSizeRatios = aSizeRatios;
		}
		
		private function updateButtonIcon():void {
			var sliderInterval:Number = slider.snapInterval;
			var iconPos:uint;
			var sliderValue:Number = slider.value;
			var sliderPos:Number = Math.round(slider.value / slider.snapInterval);
			var sliderMin:Number = slider.minimum;
			
			
			var iconFrames:int = this.btn_custom_item_size.iel_icon.totalFrames;
			var sliderSize:Number = slider.maximum - slider.minimum;
			var sliderRatio:Number = sliderValue/sliderSize;
			var iconRatio:Number;
			
			for (var i:int=1;i<=iconFrames;i++) {
				iconRatio = i / iconFrames;
				iconPos = i;
				if (sliderRatio <= iconRatio) break;
			}
			
			trace("sliderValue: "+sliderValue+" iconPos: "+iconPos);
			this.btn_custom_item_size.iel_icon.gotoAndStop(iconPos);
		}
	}
}