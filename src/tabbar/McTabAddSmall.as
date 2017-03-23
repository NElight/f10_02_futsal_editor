package src.tabbar
{
	public class McTabAddSmall extends McTabBase
	{
		public function McTabAddSmall(newLabel:String, asHTML:Boolean, useSep:Boolean)
		{
			this.name = "McTabAddSmall";
			super(newLabel, asHTML, false, useSep);
			
			this.tabBtnArea = this.tabArea;
			this.tabColor = this.mcTabBgColor;
		}
	}
}