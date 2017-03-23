package src3d.text
{
	import src3d.SessionScreen;
	import src3d.models.SSPObjectBaseSettings;
	
	public class CustomBillboard extends Billboard
	{
		public function CustomBillboard(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			//objectBmp.bitmapData = MiscUtils.scaleImage(objectBmp, 256, 128);
			this.textLibraryId = TextLibrary.TYPE_TEXT_CUSTOM;
			super(sessionScreen, objSettings);
		}
	}
}