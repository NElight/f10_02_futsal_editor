package src3d
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class SSP3DLogo extends MovieClip
	{
		public function SSP3DLogo()
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameEvent, false, 0, true);
		}
		
		private function onEnterFrameEvent(event : Event) : void
		{
			if (this.currentFrame == this.totalFrames) {
				SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.MOVIECLIP_PLAYED));
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrameEvent);
			}
		}
	}
}