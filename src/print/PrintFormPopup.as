package src.print
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.TextField;
	
	import src.controls.gallery.Thumbnail;
	import src.events.SSPMinutesEvent;
	import src.popup.PopupBox;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.utils.Logger;
	
	public class PrintFormPopup extends PopupBox
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:PrintFormPopup;
		private static var _allowInstance:Boolean = false;
		
		public function PrintFormPopup(st:Stage)
		{
			formContent = new MCPrintForm();
			formTitle = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titlePrintScreens.text();
			var useHeader:Boolean = (formTitle != "")? true : false;
			super(st, formContent, formTitle, false, false, -1, -1, true, useHeader);
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
				initListeners();
			}
		}
		
		public static function getInstance(st:Stage):PrintFormPopup
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new PrintFormPopup(st);
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		private var formContent:MCPrintForm;
		
		private function initListeners():void {
			SSPEventDispatcher.getInstance().addEventListener(SSPEvent.PRINT_HIGH_RES, onPrintHighRes);
		}
		
		private function onPrintHighRes(e:SSPEvent):void {
			Logger.getInstance().addText("Open Print Form", false);
			formContent.startPrint();
			this.popupVisible = true;
		}
		
		protected override function closeBox():void {
			Logger.getInstance().addText("Close Print Form", false);
			formContent.stopPrint();
			super.closeBox();
		}
	}
}