package src3d.utils
{
	import flash.text.StyleSheet;
	import flash.text.TextField;

	public class TextUtils
	{
		public function TextUtils()
		{
		}
		
		public static function sanitizeHTMLToNonHTML(strHTMLText:String):String {
			// Some fields like session title, screen title and screen comments have to be read as HTML and escaped as nonHTML.
			var tmpTxtField:TextField = new TextField();
			tmpTxtField.htmlText = strHTMLText;
			return sanitize(tmpTxtField.text);
		}
		
		public static function sanitize(myString:String):String {
			if (!myString) return "";
			//htmlChars["<"] = "&#60;";
			//htmlChars[">"] = "&#62;";
			//htmlChars["/"] = "&#47;";*/
			
			// XML require these characters to be escaped:
			// "   &quot;
			// '   &apos;
			// <   &lt;
			// >   &gt;
			// &   &amp; (and this doesn't require double escaping as &#38;amp;)
			
			var aChars:Array = new Array(
				{src:"\\", esc:""},
				{src:"\"", esc:""},
				{src:"<img>", esc:""},
				{src:"</img>", esc:""}
			);
			
			var aCharsEsc:Array = new Array(
				{src:"\\", esc:""},
				{src:"\"", esc:""},
				{src:"<img>", esc:""},
				{src:"</img>", esc:""},
				//{src:"\&", esc:"&amp;"},
				//{src:"\"", esc:"&quot;"},
				//{src:"\'", esc:"&apos;"},
				//{src:"\<", esc:"&lt;"},
				//{src:"\>", esc:"&gt;"}
				{src:"\<", esc:"&#60;"},
				{src:"\>", esc:"&#62;"}
			);
			
			var srcChars:Array = aCharsEsc;
			var tmpChars:Array;
			var counter:int = srcChars.length;
			for (var i:int = 0; i<counter; i++) {
				tmpChars = myString.split(srcChars[i].src);
				myString = tmpChars.join(srcChars[i].esc);
				if (i == counter-1) {}
			}
			
			myString = stripHTML(myString);
			return myString;
		}
		
		public static function stripHTML(str:String):String {
			var safeStr:String = stripASCII(str);
			var regEx:RegExp = new RegExp("[<>]", "gi");
			safeStr = safeStr.replace(regEx, "");
			return safeStr;
		}
		
		public static function stripASCII(str:String):String {
			// Remove < ASCII(32);
			var regEx:RegExp = new RegExp("[\\x0-\\x1F]", "gi");
			var newString:String = str.replace(regEx, "");
			return newString;
		}
		
		/**
		 * Note: Do not use this function to escape html characters. 
		 * @param str String.
		 * @return String.
		 * @see <code>sanitize</code>
		 * @see <code>stripHTML</code>
		 * @see <code>stripASCII</code>
		 */		
		public static function stripASCIIPlus(str:String):String {
			// Remove < ASCII(48): \\x0-\\x2F (includes ", ', & and /).
			// Remove ASCII(92): \\x5C (\).
			// Remove ASCII(60): \\x40 (<).
			// Remove ASCII(62): \\x3C (>).
			// Remove ASCII(64): \\x3E (@).
			
			var regEx:RegExp = new RegExp("[\\x0-\\x2F\\\<\>\@]", "gi");
			var newString:String = str.replace(regEx, "");
			return newString;
		}
		
		public static function htmlToText(txt:String):String {
			var tf:TextField = new TextField();
			tf.htmlText = txt;
			return tf.text;
		}
		
		public static function applyLinkStyle(txtField:TextField,
											  linkColor:String = "#0000FF", hoverColor:String = "#FFFFFF", activeColor:String = "#FFFFFF", visitedColor:String = "#0000FF",
											  linkUnderline:Boolean = true, hoverUnderline:Boolean = false, activeUnderline:Boolean = true, visitedUnderline:Boolean = true,
											  linkBold:Boolean = true, hoverBold:Boolean = true, activeBold:Boolean = true, visitedBold:Boolean = true):void 
		{
			var link:Object = new Object();
			link.color = linkColor;
			link.textDecoration = (linkUnderline)? "underline" : "none";
			link.fontWeight = (linkBold)? "bold" : "normal";
			
			var hover:Object = new Object();
			hover.color = hoverColor;
			hover.textDecoration = (hoverUnderline)? "underline" : "none";
			hover.fontWeight = (hoverBold)? "bold" : "normal";
			
			var active:Object = new Object();
			active.color = activeColor;
			active.textDecoration = (activeUnderline)? "underline" : "none";
			active.fontWeight = (activeBold)? "bold" : "normal";
			
			var visited:Object = new Object();
			visited.color = visitedColor;
			visited.textDecoration= (visitedUnderline)? "underline" : "none";
			visited.fontWeight = (visitedBold)? "bold" : "normal";
			
			var style:StyleSheet = new StyleSheet();
			style.setStyle("a:link", link);
			style.setStyle("a:hover", hover);
			style.setStyle("a:active", active);
			style.setStyle(".visited", visited);
			
			txtField.styleSheet = style;
		}
	}
}