package src.tabbar
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	
	import src.buttons.SSPLabelButton;
	
	public class McTabBase extends SSPLabelButton
	{
		public var tabBtnArea:SimpleButton;
		public var tabClose:SimpleButton;
		public var tabColor:MovieClip;
		
		private var tabMargin:uint = 5;
		private var tabSep:MovieClip;
		private var _useSep:Boolean;
		
		public function McTabBase(newLabel:String, asHTML:Boolean, isToggleButton:Boolean, useSep:Boolean)
		{
			super(newLabel, asHTML, isToggleButton);
			this.useSep = useSep;
		}
		
		
		public function get useSep():Boolean
		{
			return _useSep;
		}

		public function set useSep(value:Boolean):void {
			if (_useSep == value) return;
			_useSep = value;
			// If use separator.
			if (_useSep) {
				if (!tabSep) tabSep = new mcTabSep();
				tabSep.x = this.width + tabMargin;
				this.addChild(tabSep);
			} else {
				if (tabSep && this.contains(tabSep)) this.removeChild(tabSep);
			}
		}

	}
}