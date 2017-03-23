package src.popup  
{
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import src.StageManager;
	
	import src3d.utils.MiscUtils;
	
	public class PopupToolbarBase extends MovieClip
	{
		public static const DETECTION_METHOD_AREA_MOUSE_MOVE:String			= "DETECTION_METHOD_AREA_MOUSE_MOVE";
		public static const DETECTION_METHOD_STAGE_MOUSE_MOVE:String		= "DETECTION_METHOD_STAGE_MOUSE_MOVE";
		public static const DETECTION_METHOD_ENTER_FRAME:String				= "DETECTION_METHOD_ENTER_FRAME"; // Avoids HTTP to HTTPS security errors from some browsers like FireFox.
		
		protected var targetArea:DisplayObject;
		private var xPosVisible:Number = 0;
		private var xPosHidden:Number = 0;
		private var xPosMax:Number = 0;
		private var yPosVisible:Number = 0;
		private var yPosHidden:Number = 0;
		private var yPosMax:Number = 0;
		private var menuDelay:Number = 2;// Delay in seconds to keep the toolbar visible.
		private var toolbarTimer:Timer;
		private var isMouseOnToolbar:Boolean = false;
		private var isMouseDown:Boolean = false;
		private var toolbarVisible:Boolean;
		protected var _toolbarEnabled:Boolean;
		protected var _useSlide:Boolean;
		protected var _detectionMethod:String;
		
		
		/**
		 * @param targetArea DisplayObject. The area where the bar will be placed.
		 * @param useSlide Boolean. Default true. Set to false to not use a slide effect.
		 * @param initialXPos Number. Set it to other than -1 to override default intial X position.
		 * @param initialXPos Number. Set it to other than -1 to override default intial Y position.
		 * @param detectionMethod detectionMethod.
		 */
		public function PopupToolbarBase(targetArea:DisplayObject, initialXPos:Number = -1, initialYPos:Number = -1, useSlide:Boolean = true, detectionMethod:String = "DETECTION_METHOD_AREA_MOUSE_MOVE")
		{
			this.targetArea = targetArea;
			this._useSlide = useSlide;
			this._detectionMethod = detectionMethod;
			
			xPosMax = main.stage.stageWidth;
			yPosMax = main.stage.stageHeight;
			if (targetArea) {
				xPosVisible = (initialXPos != -1)? initialXPos : targetArea.width/2;
				yPosVisible = (initialYPos != -1)? initialYPos : targetArea.height;
				xPosHidden = xPosVisible;
			} else {
				xPosVisible = main.stage.stageWidth/2;
				yPosVisible = yPosMax;
				xPosHidden = xPosVisible;
			}
			if (_useSlide) {
				this.x = xPosVisible;
				this.y = yPosVisible;
				yPosHidden = yPosVisible+this.height;
			} else {
				this.x = xPosVisible;
				this.y = yPosVisible;
				yPosHidden = yPosVisible;
			}
			
			toolbarTimer = new Timer(menuDelay*1000, 1);
			
			this.name = "ControlBar";
			this.visible = false;
			this.alpha = 0;
			
			if(!this.stage)  {
				this.addEventListener(Event.ADDED_TO_STAGE, init); 
			} else { 
				init();
			}
		}
		
		protected function init(e:Event = null):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			//hideToolbar();
		}
		
		protected function startControlBar():void {
			if (_detectionMethod == DETECTION_METHOD_AREA_MOUSE_MOVE) {
				targetArea.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler, false, 0, true);
			} else if (_detectionMethod == DETECTION_METHOD_STAGE_MOUSE_MOVE) {
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler, false, 0, true);
			} else if (_detectionMethod == DETECTION_METHOD_ENTER_FRAME) {
				this.stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrameHandler, false, 0, true);
			}
			targetArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
			targetArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler, false, 0, true);
			this.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OVER, onToolbarMouseOver, false, 0, true);
		}
		
		protected function stopControlBar():void {
			toolbarTimer.stop();
			targetArea.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			targetArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			targetArea.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler);
			this.stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrameHandler);
			this.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeaveHandler);
			this.removeEventListener(MouseEvent.ROLL_OVER, onToolbarMouseOver);
		}
		
		private function onMouseMoveHandler(e:MouseEvent):void {
			updateState();
		}
		
		private function onStageMouseMoveHandler(e:MouseEvent):void {
			updateStateFromStage();
		}
		
		private function onStageEnterFrameHandler(e:Event):void {
			updateStateFromStage();
		}
		
		private function updateStateFromStage():void {
			if (!targetArea ||
				!this.stage ||
				!MiscUtils.objectContainsPoint(targetArea, new Point(this.stage.mouseX, this.stage.mouseY), this.stage)
			) return;
			updateState();
		}
		private function updateState():void {
			if (!isMouseDown) {
				isMouseOnToolbar = false;
				showToolbar();
			}
		}
		
		private function onMouseLeaveHandler(e:Event):void {
			//trace("onMouseLeaveHandler");
			hideToolbar()
		}
		
		private function showToolbar():void {
			if (isMouseOnToolbar) return;
			bringToFront();
			//trace("showToolbar");
			//if (!isMouseOnToolbar && !isMouseDown) {
			this.visible = true;
			//Tweener.removeAllTweens();
			Tweener.removeTweens(this);
			Tweener.addTween(this, {y:yPosVisible, time:1, onComplete:onShowComplete, delay:0, alpha:1});
			//}
		}
		
		private function onShowComplete():void {
			if (!isMouseOnToolbar && !isMouseDown && StageManager.getInstance().isFullScreen) {
				//trace("onShowComplete");
				toolbarTimer.addEventListener(TimerEvent.TIMER, hideToolbarTimer, false, 0, true);
				toolbarTimer.start();
			}
		}
		
		private function hideToolbarTimer(e:TimerEvent):void {
			toolbarTimer.removeEventListener(TimerEvent.TIMER, hideToolbarTimer);
			//trace("hideToolbar");
			toolbarTimer.stop();
			hideToolbar();
		}
		
		private function hideToolbar():void {
			//if (Tweener.isTweening(this)) {
			//Tweener.removeAllTweens();
			Tweener.removeTweens(this);
			//}
			Tweener.addTween(this, {y:yPosHidden, time:1, onComplete:onHideComplete, delay:0, alpha:0});
		}
		
		private function onHideComplete():void {
			this.visible = false;
		}
		
		private function bringToFront():void {
			if (!this.parent) return;
			this.parent.setChildIndex(this, this.parent.numChildren-1);
		}
		
		private function onToolbarMouseOver(e:MouseEvent):void {
			//trace("onToolbarMouseOver");
			isMouseOnToolbar = true;
		}
		
		private function onMouseDownHandler(e:MouseEvent):void {
			//trace("onMouseDownHandler");
			isMouseDown = true;
			isMouseOnToolbar = true;
			toolbarTimer.reset(); // Stops the timer in case user clicks again or still mouse down.
		}
		
		private function onMouseUpHandler(e:MouseEvent):void {
			//trace("onMouseUpHandler");
			isMouseDown = false;
			onShowComplete(); // Continue the timer if needed.
		}
		
		public function set toolbarEnabled(enabled:Boolean):void {
			//trace("toolbarEnabled(): "+enabled);
			if (enabled && !_toolbarEnabled) {
				_toolbarEnabled = true;
				startControlBar();
				this.visible = true;
				bringToFront();
			}
			
			if (!enabled && _toolbarEnabled) {
				_toolbarEnabled = false;
				stopControlBar();
				this.visible = false;
			}
		}
	}
}