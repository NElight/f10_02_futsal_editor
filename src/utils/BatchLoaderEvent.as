package src.utils
{
	import flash.events.Event;

	public class BatchLoaderEvent extends Event
	{
		public static const FILE_PROGRESS:String	= "FILE_PROGRESS";
		public static const FILE_COMPLETE:String	= "FILE_COMPLETE";
		public static const FILE_ERROR:String		= "FILE_ERROR";
		public static const ALL_COMPLETE:String		= "ALL_COMPLETE";
		
		public var eventData:*; // Extra data to include.
		
		public function BatchLoaderEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new BatchLoaderEvent(type, eventData);
		}
	}
}