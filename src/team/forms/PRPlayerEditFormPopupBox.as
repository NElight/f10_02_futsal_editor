package src.team.forms
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import src.popup.PopupBox;
	import src.team.PRItem;
	import src.team.SSPTeamEvent;
	
	import src3d.SessionGlobals;
	
	public class PRPlayerEditFormPopupBox extends PopupBox
	{
		// Singleton.
		private static var _self:PRPlayerEditFormPopupBox;
		private static var _allowInstance:Boolean = false;
		
		public var formContent:PRPlayerEditForm;
		
		public function PRPlayerEditFormPopupBox(st:Stage)
		{
			formContent = new PRPlayerEditForm();
			var title:String = "SSP";
			super(st, formContent, title, false, false);
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance(st:Stage):PRPlayerEditFormPopupBox {
			if(_self == null) {
				_allowInstance=true;
				_self = new PRPlayerEditFormPopupBox(st);
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		protected override function init(e:Event):void {
			formContent.addEventListener(SSPTeamEvent.PLAYER_POSE_SELECT, onPoseSelect, false, 0, true); // Player Pose Listener.
		}
		
		private function onPoseSelect(e:SSPTeamEvent):void {
			this.dispatchEvent(e);
		}
		
		public function setPlayerData(pData:PRItem, teamSide:String, addMode:Boolean):void {
			formContent.setPlayerData(pData, teamSide, addMode);
			if (formContent.addMode) {
				this.formTitle = sG.interfaceLanguageDataXML.titles._titleTeamAdd.text();
			} else {
				this.formTitle = sG.interfaceLanguageDataXML.titles._titleTeamEdit.text();
			}
		}
	}
}