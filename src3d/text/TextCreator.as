package src3d.text
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	
	import src3d.SessionScreen;
	import src3d.utils.MiscUtils;

	public class TextCreator
	{
		private var panelText:MovieClip;
		private var sessionScreen:SessionScreen;
		
		public function TextCreator(sessionScreen:SessionScreen)
		{
			this.sessionScreen = sessionScreen;
			panelText = new mc_texts_panel(); // Load Text MovieClip from the .fla file.
		}
		
		public function createNewText(textSettings:TextSettings):Billboard {
			var bmp:Bitmap;
			if (textSettings._libraryId == TextLibrary.TYPE_TEXT_CHAR) {
				if (textSettings._textContent == "") return null;
				bmp = getSingleCharBmp(textSettings._textContent);
				if (!bmpOK(bmp)) return null;
				textSettings._textBmp = bmp;
				return new Billboard(sessionScreen, textSettings);
			} else {
				bmp = getCustomTextBmp(textSettings);
				if (!bmpOK(bmp)) return null;
				textSettings._textBmp = bmp;
				return new CustomBillboard(sessionScreen, textSettings);
			}
		}
		
		private function bmpOK(bmp:Bitmap):Boolean {
			if (!bmp) return false;
			if (!bmp.bitmapData) return false;
			if (bmp.bitmapData.height <= 0 && bmp.bitmapData.width <= 0) return false;
			return true;
		}
		
		/*public function createLoadedText(textSettings:TextSettings):Billboard {
			var bmp:Bitmap;
			if (textSettings._textLibraryId == TextLibrary.TYPE_TEXT_CHAR) {
				bmp = getSingleCharBmp(textSettings._textContent); 
				return new Billboard(textSettings, bmp);
			} else {
				bmp = getCustomTextBmp(textSettings);
				return new CustomBillboard(textSettings, bmp);
			}
		}*/
		
		public function getSingleCharBmp(char:String):Bitmap {
			if (char.length < 1 || char.length > 2) return null;
			var mcName:String = "text_"+char;
			var mcObj:MovieClip;
			var newBmp:Bitmap = null;
			if (panelText.getChildByName(mcName) != null) {
				mcObj = MovieClip(panelText.getChildByName(mcName));
			} else {
				mcObj = new MCChar2Custom(char);
			}
			if (mcObj) {
				newBmp = MiscUtils.takeScreenshot(mcObj);
				newBmp.name = mcName;
			}
			return newBmp;
		}
		
		public function getCustomTextBmp(textSettings:TextSettings):Bitmap {
			var mcName:String = "customText";
			var mcObj:MCTextCustom;
			var newBmp:Bitmap;
			if (panelText.getChildByName(mcName) != null) {
				mcObj = MCTextCustom(panelText.getChildByName(mcName));
				if (mcObj) {
					// Update Custom Text.
					mcObj.setLoadedTextContent(textSettings);
					newBmp = MiscUtils.takeScreenshot(mcObj, true, 0x00000000, true);
					newBmp.name = mcName;
				}
			}
			return newBmp;
		}
		
		public function dispose():void {
			panelText = null;
		}
	}
}