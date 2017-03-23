package src3d.lines
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaskMaterial;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import src3d.SSPEvent;
	
	public class ElevatedLineHandle extends ObjectContainer3D
	{
		public var handleIndex:int = -1;
		private var aCp:Vector.<Sprite3D>;
		
		public function ElevatedLineHandle(idx:int) {
			
			handleIndex = idx;
			// Get the screenshot.
			var mc:MovieClip = new btn_handle_arrows_v();
			var bmd:BitmapData = new BitmapData(mc.width, mc.height, true, 0x000000);
			bmd.draw(mc);
			var bmm:BitmapMaterial = new BitmapMaterial(bmd, {smooth:true});
			bmm.alpha = .8;
			//btn_handle.gotoAndStop(1);
			// Set Handle.
			aCp = new Vector.<Sprite3D>();
			var cP:Sprite3D = new Sprite3D(bmm);
			cP.distanceScaling = false;
			
			// Set selection Area.
			var cm:ColorMaterial = new ColorMaterial(0xFF0000);
			cm.alpha = 0;
			var cPm:Sprite3D = new Sprite3D(cm, cP.width+2, cP.height+2);
			cPm.distanceScaling = false;
			
			this.ownCanvas = true;
			this.mouseEnabled = true;
			this.useHandCursor = true;
			//this.debugbb = true;
			
			this.addSprite(cPm);
			this.addSprite(cP);
			
			aCp.push(cP);
			aCp.push(cPm);
			this.alpha = .5;
			listenersEnabled(true);
		}
		
		private function listenersEnabled(lEnabled:Boolean):void {
			//trace("listenersEnabled(): "+lEnabled);
			if (lEnabled) {
				listenersEnabled(false);
				this.addOnMouseOver(onMouseOverHandler);
				this.addOnMouseOut(onMouseOutHandler);
			} else {
				//trace("hideHandles");
				/*repeater				this.removeEventListener(Object3DEvent.POSITION_CHANGED, onHPMouseMove);*/
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
		
		public function dispose():void {
			for each(var cP:Sprite3D in aCp) {
				this.removeSprite(cP);
				cP = null;
			}
			this.parent.removeChild(this);
		}
	}
}