package src.tabbar
{
	public class McTab extends McTabBase
	{
		public function McTab(newLabel:String, asHTML:Boolean)
		{
			this.name = "McTab";
			super(newLabel, asHTML, false, false);
			
			this.tabBtnArea = this.tabArea;
			this.tabColor = this.mcTabBgColor;
			this.tabClose = this.btnClose;
		}
	}
}