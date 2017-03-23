package src.settings
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import src.popup.PopupBox;
	
	import src3d.SessionGlobals;
	
	/**
	 * Popup Container for SSPSettingsForm. 
	 */
	public class SSPSettingsFormPopup extends PopupBox {
		
		public var formContent:SSPSettingsForm;
		
		public function SSPSettingsFormPopup(ref:main)
		{
			formContent = new SSPSettingsForm(ref);
			var title:String = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titleSettings.text();
			super(ref.stage, formContent, title, false, false, -1, -1, true, true, true, true, true);
		}
		
		protected override function showBox():void {
			super.showBox();
			formContent.formOpen();
		}
		
		protected override function closeBox():void {
			super.closeBox();
			formContent.formClose();
		}
		
		public function checkMetaInfo():Boolean {
			return formContent.checkMetaInfo();
		}
	}
}