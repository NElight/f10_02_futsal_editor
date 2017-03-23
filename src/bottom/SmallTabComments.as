package src.bottom
{
	import src.controls.SmallTab;
	
	public class SmallTabComments extends SmallTab
	{
		public function SmallTabComments(xPos:Number, yPos:Number)
		{
			this._big = new mcCommentsTab();
			this._small = new mcCommentsTabS();
			this._line = new mcCommentsLine();
			this.addChild(_big);
			this.addChild(_small);
			this.addChild(_line);
			super(xPos, yPos);
		}
	}
}