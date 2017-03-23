package src.minutes
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.TextField;
	
	import src.events.SSPMinutesEvent;
	import src.popup.PopupBox;
	
	import src3d.SessionScreen;
	
	public class MinutesClockConfirmPopupBox extends PopupBox
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:MinutesClockConfirmPopupBox;
		private static var _allowInstance:Boolean = false;
		
		public function MinutesClockConfirmPopupBox(st:Stage)
		{
			formContent = new MinutesClockConfirm(st);
			formTitle = "SSP";
			var useHeader:Boolean = (formTitle != "")? true : false;
			super(st, formContent, formTitle, false, false, -1, -1, true, useHeader);
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance(st:Stage):MinutesClockConfirmPopupBox
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new MinutesClockConfirmPopupBox(st);
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		private var formContent:MinutesClockConfirm;
		
		public function setData(sScreen:SessionScreen, strEvent:String, strActionHTML:String, strMinutes:String, strSeconds:String):void {
			formContent.setData(sScreen, strEvent, strActionHTML, strMinutes, strSeconds);
		}
		
		protected override function closeBox():void {
			this.dispatchEvent(new SSPMinutesEvent(SSPMinutesEvent.CONFIRM_CANCEL));
			super.closeBox();
		}
	}
}