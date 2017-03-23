package src3d.models {
	//import away3d.containers.LODObject;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.utils.Cast;
	import away3d.events.MouseEvent3D;
	import away3d.loaders.Max3DS;
	import away3d.materials.ColorMaterial;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.utils.Dragger;
	import src3d.utils.ModelUtils;
	

	public class Rotator extends ObjectContainer3D {
		[Embed(source="Rotator1a.3ds", mimeType="application/octet-stream")]
		private var Object1a:Class;

		private var _color1:uint = 0xFFFF00;
		private var objectSet:Array = [];
		private var objectA:ObjectContainer3D;
		private var _scale:Number;
		private var _isMouseDown:Boolean;
		
		private var target:Equipment;
		private var drag3d:Dragger;
		
		public function Rotator(target:Equipment, drag3d:Dragger) {
			this.target = target;
			this.drag3d = drag3d;
			this.name = "Rotator";
			_scale = 1;
			initObject();
			setMaterials();
			rotatorEnabled = false;
			//listenersEnabled(true); // Highlight Listeners.
		}
		
		private function initObject():void {
			objectA = Max3DS.parse(Cast.bytearray(Object1a),{autoLoadTextures:false}) as ObjectContainer3D;
			//objectA.rotationY = 180;
			//objectA.rotationX = 90;
			objectA.rotationY = 90;
			objectA.y = 4;
			objectA.scale(_scale);
			this.addChild(objectA);
			this.useHandCursor = true;
			
			// Create Objects Array.
			objectSet.push(objectA);
		}
		
		private function setMaterials():void {
			applyRotatorMaterial(.5, true);
			/*applyColorMaterial("arrow", _color1, objectSet, .5);
			applyColorMaterial("arc", _color1, objectSet, .0);
			applyColorMaterial("arrowccw", _color1, objectSet, .5);
			applyColorMaterial("arrowcw", _color1, objectSet, .5);*/
		}
		
		private function listenersEnabled(lEnabled:Boolean):void {
			if (lEnabled) {
				listenersEnabled(false);
				this.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverHandler);
				//this.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
				//this.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownHandler);
				//Main.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			} else {
				this.removeEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverHandler);
				this.removeEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
				this.removeEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownHandler);
				main.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
				main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
				
			}
		}
		
		private function onMouseDownHandler(e:MouseEvent3D):void {
			if (!target || !target.rotable) {
				rotatorEnabled = false;
				return;
			}
			this.removeEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownHandler);
			this.removeEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
			_isMouseDown = true;
			
			target.toggleEditMode(true);
			main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			
			main.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			
		}
		
		private function onMouseMoveHandler(e:MouseEvent):void {
			if (!e.shiftKey) {
				rotateObject(true, false);
			} else {
				// If Shift Key pressed, rotate in steps of 15 degrees.
				rotateObject(true, true);
			}
		}
		
		public function rotateObject(useMousePos:Boolean, useSteps:Boolean):void {
			if (!target) return;
			var _pos3D:Vector3D = drag3d.getIntersect();
			if (!useSteps) {
				target.objectRotationY = Math.atan2(target.x-_pos3D.x,target.z-_pos3D.z)*180/Math.PI;
			} else {
				var rotation:Number;
				var rotMargin:int = 15;
				rotation = Math.atan2(target.x-_pos3D.x,target.z-_pos3D.z)*180/Math.PI;
				for (var i:int = -180;i<=180;i+=rotMargin) {
					if (rotation <= i) {
						rotation = i;
						break;
					}
				}
				//trace("Rotation: "+rotation);
				target.objectRotationY = rotation;
			}
		}
		
		private function onStageMouseUpHandler(e:MouseEvent):void {
			main.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			_isMouseDown = false;
			this.highlight = false;
			listenersEnabled(true);
			target.toggleEditMode(false);
		}
		
		private function onMouseOverHandler(e:MouseEvent3D):void {
			this.removeEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverHandler);
			this.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownHandler);
			this.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
			this.highlight = true;
		}
		
		private function onMouseOutHandler(e:MouseEvent3D):void {
			this.removeEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDownHandler);
			this.removeEventListener(MouseEvent3D.MOUSE_OUT, onMouseOutHandler);
			this.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOverHandler);
			if (_isMouseDown) return;
			this.highlight = false;
		}
		
		public function set rotatorEnabled(rEnabled:Boolean):void {
			if (!target || !target.rotable) rEnabled = false;
			/*if (rEnabled) {
				trace("rotatorEnabled(): true");
			}*/
			listenersEnabled(rEnabled);
			this.visible = rEnabled;
		}
		
		/**
		 * Highlights the controller. 
		 * @param h True for highlighted, False for no highlighted.
		 * 
		 */		
		public function set highlight(h:Boolean):void {
			if (h) {
				applyRotatorMaterial(1, false);
			} else {
				applyRotatorMaterial(.5, false);
			}
		}
		
		protected function applyRotatorMaterial(t:Number, initTransparency:Boolean):void {
			var mat:ColorMaterial = new ColorMaterial(_color1, {alpha:t});
			for each(var obj3d:Object3D in objectA.children) {
				var mesh:Mesh = obj3d as Mesh;
				if (mesh != null) {
					if(mesh.name == "Arrow")
					{
						mesh.material = mat;
					} else if (initTransparency) {
						if (mesh.name == "Arc")	{
							mat = new ColorMaterial(_color1, {alpha:0});
							mesh.material = mat;
						}
					}
				}
			}
		}
		
		public function dispose():void {
			listenersEnabled(false);
			this.removeChild(objectA);
			ModelUtils.removeMaterials(objectA);
			objectA = null;
			target = null;
			drag3d = null;
			objectSet = [];
			ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}