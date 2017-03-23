package src.controls.slider
{
	import fl.controls.Slider;
	import fl.controls.SliderDirection;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * This class extends Flash Slider component to change some of their settings.
	 * See also SSPSlider object in .fla file. 
	 * 
	 */	
	public class SSPSlider extends Slider
	{
		public function SSPSlider()
		{
			super();
			init();
		}
		
		private function init():void {
			this.setStyle("thumbDisabledSkin",SSPSliderThumb_disabledSkin);
			this.setStyle("thumbDownSkin",SSPSliderThumb_downSkin);
			this.setStyle("thumbOverSkin",SSPSliderThumb_overSkin);
			this.setStyle("thumbUpSkin",SSPSliderThumb_upSkin);
			this.setStyle("tickSkin",SSPSliderTick_skin);
			this.setStyle("sliderTrackDisabled",SSPSliderTrack_disabledSkin);
			this.setStyle("sliderTrackSkin",SSPSliderTrack_skin);
			this.direction = SliderDirection.HORIZONTAL;
			this.enabled = true;
			this.liveDragging = true;
			this.maximum = 120;
			this.minimum = 0;
			this.snapInterval = 5;
			this.tickInterval = 5;
			this.value = 0;
			this.visible = true;
		}
		
		override protected function configUI():void {
			super.configUI();
			track.setSize(track.width, 11); // Change track bar thickness.
			//track.useHandCursor = true;
			//_width += (thumb.width/2);
		}
		
		override protected function draw():void {
			super.draw();
/*			if (isInvalid(InvalidationType.SIZE)) {
				track.setSize(_width+(thumb.width/2), track.height);
				track.drawNow();
				//thumb.drawNow();
			}*/
		}
		
		override protected function drawTicks():void {
			//super.drawTicks();
			clearTicks();
			tickContainer = new Sprite();
			var divisor:Number = (maximum<1)?tickInterval/100:tickInterval;
			var l:Number = (maximum-minimum)/divisor;
			var dist:Number = _width/l;
			//for (var i:uint=0;i<=l;i++) {
			for (var i:uint=1;i<l;i++) { // Don't draw the first and last tick.
				var tick:DisplayObject = getDisplayObjectInstance(getStyleValue("tickSkin"));
				tick.x = dist * i;
				//tick.y = (track.y - tick.height) - 2;
				tick.y = track.y - (track.height/2); // Positionate ticks on top of track bar.
				tickContainer.addChild(tick);
			}
			addChild(tickContainer);
			// Move thumb on top.
			if (tickContainer) this.swapChildren(tickContainer, this.thumb);
		}
	}
}