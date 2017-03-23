package src.tabbar
{
	public class McTabAddLarge extends McTabBase
	{
		public function McTabAddLarge(newLabel:String, asHTML:Boolean, useSep:Boolean)
		{
			this.name = "McTabAddLarge";
			super(newLabel, asHTML, false, useSep);
			
			this.tabBtnArea = this.tabArea;
			this.tabColor = this.mcTabBgColor;
		}
	}
}