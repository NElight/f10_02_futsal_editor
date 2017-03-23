package src.buttons
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src3d.SessionGlobals;

	public class SSPButtonOnOff extends SSPButtonBase
	{
		private var txtOn:TextField;
		private var txtOff:TextField;
		private var bgOn:MovieClip;
		private var bgOff:MovieClip;
		
		private var _buttonON:Boolean;
		
		public function SSPButtonOnOff()
		{
			super();
			this.isToggleButton = false;
			this.buttonEnabled = true;
			
			txtOn = this.textLabelOn;
			txtOff = this.textLabelOff;
			bgOn = this.mcButtonOn;
			bgOff = this.mcButtonOff;
			
			txtOn.text = SessionGlobals.getInstance().interfaceLanguageDataXML.options._interfaceOn.text();
			txtOff.text = SessionGlobals.getInstance().interfaceLanguageDataXML.options._interfaceOff.text();
			
			updateButtonState();
		}
		
		private function updateButtonState():void {
			if (_buttonON) {
				txtOn.visible = true;
				bgOn.visible = true;
				txtOff.visible = false;
				bgOff.visible = false;
			} else {
				txtOn.visible = false;
				bgOn.visible = false;
				txtOff.visible = true;
				bgOff.visible = true;
			}
		}
		
		protected override function onClick(e:MouseEvent):void {
			_buttonON = (_buttonON)? false : true;
			updateButtonState();
		}
		
		public function get buttonON():Boolean
		{
			return _buttonON;
		}

		public function set buttonON(value:Boolean):void
		{
			_buttonON = value;
			updateButtonState();
		}

	}
}