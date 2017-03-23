package src.settings
{
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	public class ScreenListScrollPane extends ScrollPane
	{
		
		public function ScreenListScrollPane()
		{
			super();
			this.addEventListener(Event.CHANGE, onContentChangeHandler);
			this.enabled = true;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalLineScrollSize = 4;
			this.horizontalPageScrollSize = 0;
			this.scrollDrag = false;
			this.verticalScrollPolicy = ScrollPolicy.ON;
			this.verticalLineScrollSize = 4;
			this.verticalPageScrollSize = 0;
			this.visible = true;
			this.x = 11;
			this.y = 170;
			this.width = 740;
			this.height = 310;
			
			var bgTransparent:Shape = new Shape();
			this.setStyle("skin", bgTransparent);
			this.setStyle("upSkin", bgTransparent); // ScrollPane_upSkin
		}
		
		private function onContentChangeHandler(e:Event):void {
			this.invalidate();
		}
	}
}