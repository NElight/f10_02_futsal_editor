package src3d.lines
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.sprites.Sprite3D;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	
	public class HandleBase extends ObjectContainer3D
	{
		protected var _handleControlPoint:int = -1; // Idicate if it is controlling pStart, pControl or pEnd.
		protected var _handleType:int = -1; // Basic, Elevation, Area, etc. See Handle Library.
		protected var _handleIndex:int = -1;
		
		protected var handleControlAxis:int = -1; // What axis to use when updating pos. See HandleLibrary.
		protected var handleOffsetY:Number = 40;
		protected var aCp:Vector.<Sprite3D>;
		protected var mcHandleIcon:MovieClip;
		
		private var bmm:BitmapMaterial;
		
		public function HandleBase(handleIndex:int, handleControlPoint:int, handleType:int, mcHandleIcon:MovieClip) {
			this._handleControlPoint = handleControlPoint;
			this._handleIndex = handleIndex;
			this._handleType = handleType; // Use it on extending classes. See HandleLibrary.
			this.mcHandleIcon = mcHandleIcon; // Use movie clip icon on extending classes.
			initHandle();
		}
		
		private function initHandle():void {
			if (!mcHandleIcon) {
				trace("Error: No Handle Icon specified.");
				return;
			}
			// Get scale to 32x32.
			/*var scale:Number = mcHandleIcon.width/32; // this is from your example of 600x600 => 100x100
			var scaledWidth:Number = mcHandleIcon.width * (1-scale);
			scale = mcHandleIcon.height/32;
			var scaledHeight:Number = mcHandleIcon.height * (1-scale);*/
			
			// Get the screenshot.
			var bmd:BitmapData = new BitmapData(mcHandleIcon.width, mcHandleIcon.height, true, 0x000000);
			bmd.draw(mcHandleIcon);
			
			var bmm:BitmapMaterial = new BitmapMaterial(bmd, {smooth:true});
			//bmm.alpha = .8;
			
			// Set Handle.
			aCp = new Vector.<Sprite3D>();
			var cP:Sprite3D = new Sprite3D(bmm);
			cP.distanceScaling = false;
			
			// Set selection Area.
			var cm:ColorMaterial = new ColorMaterial(0xFF0000);
			cm.alpha = 0;
			var cPm:Sprite3D = new Sprite3D(cm, cP.width+2, cP.height+2);
			cPm.distanceScaling = false;
			
			//cPm.y = bmd.height/2;
			//cP.y = bmd.height/2;
			
			this.addSprite(cPm);
			this.addSprite(cP);
			
			aCp.push(cPm);
			aCp.push(cP);
			
			//this.ownCanvas = true;
			this.mouseEnabled = true;
			this.useHandCursor = true;
			
			this.alpha = .6;
			this.pushfront = true;
			
			//this.debugbb = true;
			//listenersEnabled(true);
		}
		
		private function listenersEnabled(lEnabled:Boolean):void {
			if (lEnabled) {
				listenersEnabled(false);
				this.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverHandler);
				this.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
			} else {
				this.removeEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverHandler);
				this.removeEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
			}
		}
		
		private function onMouseOverHandler(e:MouseEvent3D):void {
			/*if (bmm) {
				bmm.alpha = 1;
				bmm.alphaBlending = true;
			}*/
			this.alpha = 1;
			this.pushfront = true;
		}
		
		private function onMouseOutHandler(e:MouseEvent3D):void {
			/*if (bmm) {
				bmm.alpha = .6;
				bmm.alphaBlending = true;
			}*/
			this.alpha = .6;
		}
		
		public function get handleControlPoint():int {return _handleControlPoint;}
		public function get handleType():int {return _handleType;}
		public function get handleIndex():int {return _handleIndex;}
		
		public function dispose():void {
			listenersEnabled(false);
			for each(var cP:Sprite3D in aCp) {
				cP.material = null;
				this.removeSprite(cP);
				cP = null;
			}
			if (this.parent) {
				this.ownCanvas = true;
				this.parent.removeChild(this);
			}
			
			aCp = null;
			mcHandleIcon = null;
			bmm = null;
		}
	}
}