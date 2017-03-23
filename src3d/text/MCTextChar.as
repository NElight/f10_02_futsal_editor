package src3d.text {
		
	import flash.text.TextField;
	
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.utils.Drag2DObject;
	
	public class MCTextChar extends Drag2DObject {
		
		protected var _internalScale:Number; // Scale factor for the embeded sprite.
		
		public function MCTextChar() {
			super(ObjectTypeLibrary.OBJECT_TYPE_TEXT, 0);
			_objectId = TextLibrary.TYPE_TEXT_CHAR;
			_internalScale = 0.61;
		}
		
		// This function can be overriden in extending classes.
		protected override function getSettings():SSPObjectBaseSettings {
			var newSettings:TextSettings = new TextSettings();
			// Base Settings.
			newSettings._objectType = _objectType;
			newSettings._libraryId = _objectId;
			
			// Text Settings.
			newSettings._textBmp = cloneBmp;
			newSettings._textContent = textContent;
			newSettings._textContent2 = textContent2;
			newSettings._textStyle = textStyle;
			return newSettings;
		}
		
		// This function is overriden in extending classes;
		protected function get textContent():String {
			return this.name.substr(5, 2); // All characters movieclip are named Char_XX, where XX is/are the character/s.
		}
		
		// This function is overriden in extending classes;
		protected function get textContent2():String {
			return ""; // Empty string for single drag and drop characters.
		}
		
		protected function get textStyle():String {
			return ""; // Empty string for single drag and drop characters.
		}
	}
}