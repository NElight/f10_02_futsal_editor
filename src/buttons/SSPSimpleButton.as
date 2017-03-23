package src.buttons
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	
	import src3d.SessionGlobals;
	
	public class SSPSimpleButton extends SimpleButton
	{
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var vTooltipSettings:Vector.<SSPToolTipSettings>;
		
		public function SSPSimpleButton(upState:DisplayObject=null, overState:DisplayObject=null, downState:DisplayObject=null, hitTestState:DisplayObject=null)
		{
			super(upState, overState, downState, hitTestState);
			
		}
		
		public function setToolTipText(tooltipText:String):void {
			if (vTooltipSettings || !tooltipText || tooltipText == "") return;
			vTooltipSettings = new Vector.<SSPToolTipSettings>();
			vTooltipSettings.push(new SSPToolTipSettings(this, tooltipText));
			SSPToolTip.getInstance().addToolTips(vTooltipSettings);
		}
	}
}