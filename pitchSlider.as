package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	import src3d.utils.MiscUtils;

	public class pitchSlider extends MovieClip {

		var scrollLimit:uint = 503;
		var scrollIncrement:Number = 62.95;
		var scrollOffset:Number = 0;
		var scrollMax:Number = 0;
		var scrollMin:Number = 0;
		var currentPos:Number = 0;
		var totalPitches:uint;
		var visiblePitches:uint = 8;
		var _pitchSlider:MovieClip;
		var speed:Number = 0.4;

		public function pitchSlider(ref) 
		{
			
			_pitchSlider = new mc_pitchSlider();
			//_pitchSlider.x 			= 888;
			_pitchSlider.x 			= 912;
			_pitchSlider.y 			= 35;
			
			ref._mainContainer.addChild(_pitchSlider);
			
			totalPitches = MiscUtils.movieClipsIn(_pitchSlider.pitch_container, "btnPitch", true).length;
			
			// If not enough buttons, do not activate scroll buttons.
			if (MiscUtils.movieClipsIn(_pitchSlider.pitch_container, "btnPitch", true).length <= visiblePitches) return;
			
			scrollMin = _pitchSlider.pitch_container.y;
			currentPos = scrollMin;
			//scrollOffset = scrollIncrement / 2;
			scrollMax = -(((totalPitches - visiblePitches) * scrollIncrement) - currentPos);

			//Button UP Event Listeners
			_pitchSlider.ps_button_up.pitch_button_up.addEventListener(MouseEvent.MOUSE_OUT,pu_out);
			_pitchSlider.ps_button_up.pitch_button_up.addEventListener(MouseEvent.MOUSE_OVER,pu_over);
			_pitchSlider.ps_button_up.pitch_button_up.addEventListener(MouseEvent.CLICK, scrollup);

			//Button DOWN Event Listeners
			_pitchSlider.ps_button_down.pitch_button_down.addEventListener(MouseEvent.MOUSE_OUT,pd_out);
			_pitchSlider.ps_button_down.pitch_button_down.addEventListener(MouseEvent.MOUSE_OVER,pd_over);
			_pitchSlider.ps_button_down.pitch_button_down.addEventListener(MouseEvent.CLICK, scrolldown);
		}

		protected function scrollup(event:MouseEvent):void 
		{
			if((totalPitches * scrollIncrement) > scrollLimit) {
				if(currentPos < scrollMin)  {
					currentPos = currentPos + scrollIncrement;
					if (currentPos > scrollMin) currentPos = scrollMin;
					TweenLite.to(_pitchSlider.pitch_container, speed, { y:(currentPos + scrollOffset) } );
				} else if(currentPos > scrollMin)  {
					currentPos = scrollMin;
					TweenLite.to(_pitchSlider.pitch_container, speed, { y:(currentPos) } );
				}
			}
		}

		protected function scrolldown(event:MouseEvent):void 
		{
			if((totalPitches * scrollIncrement) > scrollLimit) {
				if(currentPos > scrollMax)  {
					currentPos = currentPos - scrollIncrement;
					if (currentPos < scrollMax) currentPos = scrollMax;
					TweenLite.to(_pitchSlider.pitch_container, speed, { y:(currentPos + scrollOffset) } );
				} else if(currentPos < scrollMax)  {
					currentPos = scrollMax;
					TweenLite.to(_pitchSlider.pitch_container, speed, { y:(currentPos) } );
				}
			}
		}

		protected function pd_out(event:MouseEvent):void 
		{
			_pitchSlider.ps_button_down.gotoAndStop(1);
		}
		protected function pd_over(event:MouseEvent):void 
		{
			_pitchSlider.ps_button_down.gotoAndStop(2);
		}

		protected function pu_out(event:MouseEvent):void 
		{
			_pitchSlider.ps_button_up.gotoAndStop(1);
		}
		protected function pu_over(event:MouseEvent):void 
		{
			_pitchSlider.ps_button_up.gotoAndStop(2);
		}

	}
}