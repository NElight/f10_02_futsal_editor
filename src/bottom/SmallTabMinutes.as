package src.bottom
{
	import src.controls.SmallTab;
	
	public class SmallTabMinutes extends SmallTab
	{
		public function SmallTabMinutes(xPos:Number, yPos:Number)
		{
			this._big = new mcMinutesTab();
			this._small = new mcMinutesTabS();
			this._line = new mcMinutesLine();
			this.addChild(_big);
			this.addChild(_small);
			this.addChild(_line);
			super(xPos, yPos);
		}
	}
}