package src
{
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import src3d.utils.MiscUtils;
	
	public class SSPLogo extends MovieClip
	{
		private var centered:Boolean;
		private var containerWidth:Number;
		private var containerHeight:Number;
		
		public function SSPLogo(centered:Boolean, containerWidth:Number = NaN, containerHeight:Number = NaN, logoWidth:Number = NaN, logoHeight:Number = NaN)
		{
			this.centered = centered;
			this.containerWidth = containerWidth;
			this.containerHeight = containerHeight;
			this.alpha = .8;
			if (!isNaN(logoWidth) && !isNaN(logoHeight)) {
				this.width = logoWidth;
				this.height = logoHeight;
			}
			//this.blendMode = BlendMode.MULTIPLY;
			logoEnabled = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			if (centered) {
				if (!containerWidth) containerWidth = this.stage.stageWidth;
				if (!containerHeight) containerHeight = this.stage.stageHeight;
				reCenter( new Rectangle(0,0,containerWidth,containerHeight) );
			}
			
		} 
		
		public function reCenter(containerRectangle:Rectangle):void {
			var thisPos:Point = MiscUtils.getPosToCenterInContainer(this, containerRectangle.width, containerRectangle.height);
			this.x = thisPos.x;
			this.y = thisPos.y;
		}
		
		public function set logoEnabled(en:Boolean):void {
			if (en) {
				this.gotoAndPlay(1);
				this.visible = true;
				if (this.parent) this.parent.setChildIndex(this,this.parent.numChildren-1);
			} else {
				this.visible = false;
				this.gotoAndStop(0);
			}
		}
	}
}