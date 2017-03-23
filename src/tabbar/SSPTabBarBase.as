package src.tabbar
{
	import flash.display.MovieClip;
	
	public class SSPTabBarBase extends MovieClip
	{
		public function SSPTabBarBase()
		{
			super();
		}
		
		/**
		 * Returns a vector containing only SSPTab objects. Overriden in extending classes.
		 * @return Vector.<SSPTab>
		 */		
		public function get aTabs():Vector.<SSPTab> { return new Vector.<SSPTab>(); }
		
		public function tabUpdateGroup(sId:uint):void {}
	}
}