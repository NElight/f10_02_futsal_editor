package src.utils
{
	import flash.events.Event;
	
	public class VideoValidatorEvent extends Event
	{
		public static const VALIDATION_COMPLETE:String			= "VALIDATION_COMPLETE";
		public static const VALIDATION_ERROR:String				= "VALIDATION_ERROR";
		public static const VALIDATION_ALL_COMPLETE:String		= "VALIDATION_ALL_COMPLETE";
		
		public var eventData:*; // Extra data to include.
		
		public function VideoValidatorEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new VideoValidatorEvent(type, eventData);
		}
	}
}