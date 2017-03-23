package src.bottom
{
	import src.controls.SmallTab;
	
	public class SmallTabVideos extends SmallTab
	{
		public function SmallTabVideos(xPos:Number, yPos:Number)
		{
			this._big = new mcVideosTab();
			this._small = new mcVideosTabS();
			this._line = new mcVideosLine();
			this.addChild(_big);
			this.addChild(_small);
			this.addChild(_line);
			super(xPos, yPos);
		}
	}
}