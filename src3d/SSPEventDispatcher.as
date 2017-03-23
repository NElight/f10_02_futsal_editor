package src3d
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class SSPEventDispatcher extends EventDispatcher
	{
		private static var _self:SSPEventDispatcher;
		private static var _allowInstance:Boolean = false;
		
		public function SSPEventDispatcher()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("ModelsLibrary initialized.");
				//init();
			}
		}
		
		public static function getInstance():SSPEventDispatcher
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new SSPEventDispatcher();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		/*public function dispatch(e:Event):void {
			this.dispatchEvent(e);
		}*/
	}
}