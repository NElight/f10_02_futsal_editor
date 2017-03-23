package src.videos
{
	import flash.events.Event;
	
	public class SSPVideoEvent extends Event
	{
		// LINES
		public static const CONTROL_PLAY:String			= "CONTROL_PLAY";
		public static const CONTROL_PAUSE:String		= "CONTROL_PAUSE";
		public static const CONTROL_STOP:String			= "CONTROL_STOP";
		public static const CONTROL_VOLUME:String		= "CONTROL_VOLUME";
		public static const CONTROL_SEEK:String			= "CONTROL_SEEK";
		
		public var eventData:*; // Extra data to include (eg: ERROR_CODE's, loaded xml file name, button name, the loading error description, the '_sessionToken' string, etc.).
		
		public function SSPVideoEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new SSPVideoEvent(type, eventData);
		}
	}
}