package src.controls
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import src3d.SSPEvent;
	
	public class SSPSeekerBase extends MovieClip
	{
		private var mcSeekPos:DisplayObject;
		private var currentMouseXPos:uint;
		private var isSeeking:Boolean;
		
		public function SSPSeekerBase()
		{
			super();
			this.buttonMode = true;
			
			if (!this.stage) {
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			} else {
				init();
			}
			
		}
		
		private function onAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}
		
		/**
		 * Some objects are not ready until added to stage.
		 * Override to run after added to stage.
		 */
		protected function init():void {}
		
		protected function setSeeker(sp:DisplayObject):void {
			mcSeekPos = sp;
			if (mcSeekPos) {
				addSeekerListeners();
			} else {
				removeSeekerListeners();
				removeStageListeners();
			}
		}
		
		private function addSeekerListeners():void {
			this.addEventListener(MouseEvent.MOUSE_DOWN, onThisMouseDownHandler, false, 0, true);
		}
		
		private function removeSeekerListeners():void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onThisMouseDownHandler);
		}
		
		private function addStageListeners():void {
			if (!stage) return;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageSeekerMouseMoveHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageSeekerMouseUpHandler, false, 0, true);
		}
		
		private function removeStageListeners():void {
			if (!stage) return;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageSeekerMouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageSeekerMouseUpHandler);
		}
		
		protected function onThisMouseDownHandler(e:MouseEvent):void {
			if (!mcSeekPos) return;
			isSeeking = true;
			removeSeekerListeners();
			currentMouseXPos = stage.mouseX;
			moveSeekerTo(currentMouseXPos);
			addStageListeners();
		}
		
		private function onStageSeekerMouseMoveHandler(e:MouseEvent):void {
			moveSeekerTo(stage.mouseX);
			notifyUpdate();
		}
		
		private function onStageSeekerMouseUpHandler(e:MouseEvent):void {
			removeStageListeners();
			addSeekerListeners();
			notifyChange();
			isSeeking = false;
		}
		
		private function notifyChange():void {
			var seekValue:Number = getSeekPos();
			if (seekValue < 0) return;
			this.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CHANGE, seekValue));
		}
		
		private function notifyUpdate():void {
			var seekValue:Number = getSeekPos();
			if (seekValue < 0) return;
			this.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_UPDATE, seekValue));
		}
		
		private function moveSeekerTo(mouseXPos:Number):void {
			if (!mcSeekPos) return;
			var newDistance:Number;
			var nearBarXPos:Number;
			
			var newXPos:Number = this.globalToLocal(new Point(mouseXPos, 0)).x;
			
			if (newXPos > this.width) newXPos = this.width;
			if (newXPos < 0) newXPos = 0;
			
			mcSeekPos.width = newXPos;
			
			currentMouseXPos = stage.mouseX;
		}
		
		public function getSeekPos():Number {
			var seekValue:Number = mcSeekPos.width / this.width;
			if (isNaN(seekValue)) return -1;
			if (seekValue < 0) seekValue = 0;
			if (seekValue > 1) seekValue = 1;
			return seekValue;
		}
		/** 
		 * @param value Number. Between 0 and 1.
		 */
		public function setSeekPos(value:Number):void {
			if (mcSeekPos && !isSeeking) mcSeekPos.scaleX = value;
		}
		
		public function resetSeekPos():void {
			if (mcSeekPos) mcSeekPos.scaleX = 0;
		}
	}
}