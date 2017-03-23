package src.controls.tooltip
{
	import flash.display.DisplayObject;

	public class SSPToolTipSettings
	{
		public var target:DisplayObject;
		public var text:String;
		
		public function SSPToolTipSettings(target:DisplayObject, text:String)
		{
			this.target = target;
			this.text = text;
		}
	}
}