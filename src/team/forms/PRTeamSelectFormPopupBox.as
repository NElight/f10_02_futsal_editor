package src.team.forms
{
	import flash.display.Stage;
	
	import src.popup.PopupBox;
	
	import src3d.SessionGlobals;
	
	public class PRTeamSelectFormPopupBox extends PopupBox
	{
		public var formContent:PRTeamSelectForm;
		
		public function PRTeamSelectFormPopupBox(st:Stage)
		{
			formContent = new PRTeamSelectForm();
			var title:String = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titleTeamSelectFromSquad.text();
			super(st, formContent, title, false, false);
		}
	}
}