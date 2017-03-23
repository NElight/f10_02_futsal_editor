package src.events
{
	import flash.events.Event;
	
	public class SSPScreenEvent extends Event
	{
		public static const SCREEN_PLAYER_CREATED:String							= "SCREEN_PLAYER_CREATED";
		public static const SCREEN_PLAYER_REMOVED:String							= "SCREEN_PLAYER_REMOVED";
		
		public static const SCREEN_PLAYER_SUBSTITUTION:String						= "SCREEN_PLAYER_SUBSTITUTION";
		public static const SCREEN_PLAYER_SELECTED:String							= "SCREEN_PLAYER_SELECTED";
		public static const SCREEN_PLAYER_DESELECTED:String							= "SCREEN_PLAYER_DESELECTED";
		
		
		public var eventData:*; // Extra data to include.
		
		public function SSPScreenEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new SSPScreenEvent(type, eventData);
		}
	}
}