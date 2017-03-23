package src3d.utils
{
	import flash.events.Event;

	public class EventHandler
	{
		private var eventList:Array;
		private var _dispatcher:*;
		public function EventHandler(dispatcher:*) 
		{
			eventList = new Array();
			_dispatcher = dispatcher;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void 
		{
			eventList.push( { TYPE:type, LISTENER:listener } );
			
			if (_dispatcher.hasEventListener(type))
			{
				_dispatcher.removeEventListener(type, listener);
			}
			
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function RemoveEvent(type:String):void
		{
			var total:int = eventList.length ;
			for (var i:int = 0; i < total; i++) 
			{
				if (eventList[i].TYPE == type)
				{
					_dispatcher.removeEventListener(eventList[i].TYPE, eventList[i].LISTENER);
					eventList.splice(i, 1);
					total = eventList.length;                   
				}               
			}
		}
		
		
		public function RemoveEvents():void 
		{
			var total:int = eventList.length ;
			for (var i:int = 0; i < total; i++) 
			{
				_dispatcher.removeEventListener(eventList[i].TYPE, eventList[i].LISTENER);
			}
			eventList = [];
		}
		
		public function dispatchEvent(e:Event):Boolean {
			return _dispatcher.dispatchEvent(e);
		}
		
	}
	
}