package src.minutes
{
	import flash.events.Event;
	import flash.text.TextField;
	
	import src.buttons.SSPButtonBase;
	
	public class SSPButtonClock extends SSPButtonBase//显示时间控件
	{
		private var txtMinutes:TextField;
		private var txtSeconds:TextField;
		
		private var maxCharsMinutes:int = 3;
		private var maxCharsSeconds:int = 2;
		private var initMinutes:String = "000";
		private var initSeconds:String = "00";
		
		public function SSPButtonClock()
		{
			super();
			this.buttonEnabled = true;
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			initLabel();
		}
		
		protected function initLabel():void {
			txtMinutes = getChildByName("textMinutes") as TextField;
			txtSeconds = getChildByName("textSeconds") as TextField;
			txtMinutes.maxChars = maxCharsMinutes;
			txtSeconds.maxChars = maxCharsSeconds;
			this.labelMinutes = initMinutes;
			this.labelSeconds = initSeconds;
		}
		
		public function get labelMinutes():String {
			return txtMinutes.text;
		}
		public function set labelMinutes(value:String):void {
			if (txtMinutes) {
				txtMinutes.text = value;
			} else {
				initMinutes = value;
			}
		}
		
		public function get labelSeconds():String {
			return txtSeconds.text;
		}
		public function set labelSeconds(value:String):void {
			if (txtSeconds) {
				txtSeconds.text = value;
			} else {
				initSeconds = value;
			}
		}
	}
}