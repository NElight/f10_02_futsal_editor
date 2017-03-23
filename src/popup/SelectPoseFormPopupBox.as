package src.popup
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Point;
	
	
	public class SelectPoseFormPopupBox extends PopupBox
	{
		// Singleton.
		private static var _self:SelectPoseFormPopupBox;
		private static var _allowInstance:Boolean = false;
		
		public var formContent:SelectPoseForm;
		
		public function SelectPoseFormPopupBox(st:Stage)
		{
			formContent = new SelectPoseForm();
			var title:String = "SSP"; // TODO: Select Pose language tag.
			super(st, formContent, title, false, false, formContent.formContentW, formContent.formContentH);
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance(st:Stage):SelectPoseFormPopupBox
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new SelectPoseFormPopupBox(st);
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		public function loadPoseIconsDP(kitId:int, kitTypeId:int):void {
			formContent.loadPoseIconsDP(kitId, kitTypeId);
		}
	}
}