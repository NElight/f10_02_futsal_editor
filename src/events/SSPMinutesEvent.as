package src.events
{
	import flash.events.Event;
	
	public class SSPMinutesEvent extends Event
	{
		public static const CLICK_START_PLAY:String							= "CLICK_START_PLAY";
		public static const CLICK_STOP_PLAY:String							= "CLICK_STOP_PLAY";
		
		public static const TEAM_PLAYER_RED_CARD:String						= "TEAM_PLAYER_RED_CARD";
		
		public static const CONFIRM_CANCEL:String							= "CONFIRM_CANCEL";
		public static const CONFIRM_RED_CARD:String							= "CONFIRM_RED_CARD";
		public static const CONFIRM_SUBSTITUTION:String						= "CONFIRM_SUBSTITUTION";
		
		public var eventData:*; // Extra data to include.
		
		public function SSPMinutesEvent(type:String, eventData:* = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.eventData = eventData;
		}
		
		override public function clone():Event {
			return new SSPScreenEvent(type, eventData);
		}
	}
}