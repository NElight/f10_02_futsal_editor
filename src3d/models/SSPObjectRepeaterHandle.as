package src3d.models
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import src3d.SessionView;
	import src3d.utils.MiscUtils;

	public class SSPObjectRepeaterHandle extends ObjectContainer3D
	{
		private var aCp:Vector.<Sprite3D>;
		private var repeater:SSPObjectRepeater;
		private var repeaterHandleYPos:Number = 100;
		private var repeaterHandleYPosOffset:uint = 20;
		private var sessionView:SessionView;
		
		public function SSPObjectRepeaterHandle(repeater:SSPObjectRepeater, repeaterHandleYPos:Number):void
		{
			this.repeater = repeater;
			if (!isNaN(repeaterHandleYPos)) this.repeaterHandleYPos = repeaterHandleYPos;
			
			// Get the screenshot.
			var mc:MovieClip = new btn_handle_arrows();
			var bmd:BitmapData = MiscUtils.takeScreenshot(mc, true, 0x00000000, false).bitmapData;
			var bmm:BitmapMaterial = new BitmapMaterial(bmd, {smooth:true});
			
			// Set Handle.
			aCp = new Vector.<Sprite3D>();
			var cP:Sprite3D = new Sprite3D(bmm);
			cP.distanceScaling = false;
			
			// Set selection Area.
			var cm:ColorMaterial = new ColorMaterial(0xFF0000, {alpha:0});
			var cPm:Sprite3D = new Sprite3D(cm, int(bmm.width), int(bmm.height));
			cPm.distanceScaling = false;

			this.ownCanvas = true;
			this.mouseEnabled = true;
			this.useHandCursor = true;

			cPm.y += 10;
			cP.y += 10;
			this.addSprite(cPm);
			this.addSprite(cP);
			
			aCp.push(cP);
			aCp.push(cPm);
			
			this.updateYOffset();
			handleEnabled(false);
		}
		
		public function handleEnabled(enableHandle:Boolean):void {
			if (enableHandle) {
				this.pushfront = true;
				listenersEnabled(true);
				this.alpha = .5;
				this.visible = true;
			} else {
				listenersEnabled(false);
				this.visible = false;
			}
		}
		
		private function listenersEnabled(lEnabled:Boolean):void {
			//trace("listenersEnabled(): "+lEnabled);
			if (lEnabled) {
				listenersEnabled(false);
				if (!this.hasEventListener(MouseEvent3D.MOUSE_DOWN))
					this.addEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown);
				this.addOnMouseOver(onMouseOverHandler);
				this.addOnMouseOut(onMouseOutHandler);
			} else {
				main.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
				this.removeEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown);
				this.removeOnMouseOver(onMouseOverHandler);
				this.removeOnMouseOut(onMouseOutHandler);
			}
		}
		
		private function onMouseOverHandler(e:MouseEvent3D):void {
			this.alpha = 1;
		}
		
		private function onMouseOutHandler(e:MouseEvent3D):void {
			this.alpha = .5;
		}
		
		protected function onHPMouseDown(e:MouseEvent3D):void {
			trace("onHPMouseDown");
			listenersEnabled(false);
			this.visible = false;
			repeater.toggleEditMode(true);
			main.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
		}
		
		protected function onStageMouseMove(e:MouseEvent):void {
			//trace("onHPMouseMove");
			// update the path point.
			var useSteps:Boolean = (e.shiftKey)? true : false; 
			repeater.updateRepeater(true, useSteps);
		}
		
		protected function onStageMouseUp(e:MouseEvent):void {
			var useSteps:Boolean = (e.shiftKey)? true : false;
			repeater.updateRepeater(true, useSteps);
			//listenersEnabled(true);
			handleEnabled(true);
			repeater.toggleEditMode(false);
		}
		
		private function updateYOffset():void {
			this.y = repeaterHandleYPos + repeaterHandleYPosOffset;
		}
		
		public function canceEditMode():void {
			listenersEnabled(false);
		}
		
		public function dispose():void {
			handleEnabled(false); // Also disable listeners.
			for each(var cP:Sprite3D in aCp) {
				this.removeSprite(cP);
				cP = null;
			}
			aCp = null;
			this.ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}