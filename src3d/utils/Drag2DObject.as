package src3d.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionView;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.equipment.EquipmentSettings;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;
	
	public class Drag2DObject extends MovieClip {
		protected var clone2D:MovieClip;
		protected var cloneBmp:Bitmap;
		private var objSettings:SSPObjectBaseSettings;
		public var _objectType:String;
		public var _objectId:int;
		public var _kitTypeId:int;
		private var startPos:Point = new Point();
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var _dragEnabled:Boolean;
		
		public function Drag2DObject(objType:String, objId:int, kitTypeId:int = -1, dragEnabled = true){
			_objectType = objType;
			_objectId = objId;
			_kitTypeId = kitTypeId;
			_dragEnabled = dragEnabled;
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			updateDragStatus();
		}
		
		private function updateDragStatus():void {
			if (_dragEnabled) {
				this.useHandCursor = true;
				this.buttonMode = true;
				if (!this.hasEventListener(MouseEvent.MOUSE_DOWN)) {
					this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
				}
				addContextMenuItems();
			} else {
				this.useHandCursor = false;
				this.buttonMode = false;
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				removeDrag2DListeners()
			}
		}
		
		private function removeDrag2DListeners():void {
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
				this.stage.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onReleaseOutside);
			}
			if (main.sessionView) main.sessionView.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		}
		
		private function onMouseDown(e:Event):void{
			stopDragging2D();
			// Send the event to deselect the object in the 3d screen.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_BY_CLONING, false)); // This cancels pinning mode if it is running.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, null));
			
			// Update the settings object to be sent with the event.
			objSettings = getSettings();
			if (!objSettings) {
				trace("Error: No Drag and Drop object settings");
				return; // If not valid settings, return.
			}
			
			takeScreenshot();
			//var bounds:Rectangle = this.getBounds(this);
			var newMc:MovieClip = new MovieClip();
			newMc.addChild(cloneBmp);
			//newMc.x = bounds.x;
			//newMc.y = bounds.y;
			newMc.x = -newMc.width/2;
			newMc.y = -newMc.height;
			
			clone2D = new MovieClip();
			clone2D.addChild(newMc);
			clone2D.x = stage.mouseX;
			clone2D.y = stage.mouseY;
			stage.addChild(clone2D);
			clone2D.startDrag();
			
			// Listens when the mouse is over the 3D MovieClip Container.
			if (this.stage && main.sessionView) {
				this.stage.addEventListener(MouseEvent.MOUSE_UP, onDrop, false, 0, true);
				this.stage.addEventListener(MouseEvent.RELEASE_OUTSIDE, onReleaseOutside, false, 0, true);
				main.sessionView.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			}
		}
		
		// This function is overriden in extending classes like MCTextChar.as.
		protected function getSettings():SSPObjectBaseSettings {
			var newSettings:SSPObjectBaseSettings;
			// Add object specific settings.
			switch (_objectType) {
				case ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT:
					var newES:EquipmentSettings = new EquipmentSettings();
					newES._objectType = _objectType;
					newES._libraryId = objectId;
					newSettings = newES;
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_PLAYER:
					var newPS:PlayerSettings = new PlayerSettings();
					newPS._objectType = _objectType;
					newPS._libraryId = objectId;
					newPS._cKit._kitTypeId = _kitTypeId;
					newPS._cKit._kitId = SessionGlobals.getInstance().currentKitId;
					newSettings = newPS;
					break;
				/*case ObjectTypeLibrary.OBJECT_TYPE_TEXT:
					// Overriden in MCTextChar.as
					break;*/
				default:
					newSettings = null;
					break;
			}
			return newSettings;
		}
		
		private function takeScreenshot():void {
			var mcObj:MovieClip = this;
			//var bgTransparent:Boolean = false;
			
			// Taking a screenshot instead of only duplicate the object. This keeps the color changes on kits.
			//var bounds:Rectangle = mcObj.getBounds(mcObj);
			//bgTransparent = true;
			//cloneBmp = new Bitmap();
			//cloneBmp.bitmapData = new BitmapData( int( bounds.width + 0.5 ), int( bounds.height + 0.5 ), bgTransparent, 0x00FFFFFF);
			//cloneBmp.bitmapData.draw(mcObj, new Matrix(1,0,0,1,-bounds.x,-bounds.y) );
			cloneBmp = MiscUtils.takeScreenshot(mcObj,true,0x00FFFFFF,true);
			cloneBmp.name = mcObj.name;
			if (sG.globalFlipH) {
				cloneBmp.scaleX *= -1;
				cloneBmp.x += cloneBmp.width;
			}
		}
		
		private function onDrop(e:MouseEvent):void {
			//trace("onDrop()");
			stopDragging2D();
		}
		
		private function onReleaseOutside(e:MouseEvent):void {
			//trace("onReleaseOutside()");
			onDrop(e);
		}
		
		private function stopDragging2D():void {
			removeDrag2DListeners();
			if (clone2D) {
				clone2D.stopDrag();
				// Removes the clon movieclip from his parent.
				if (clone2D.parent) {
					clone2D.parent.removeChild(clone2D);
				}
				clone2D = null;
			}
		}
		
		private function onMouseOver(e:MouseEvent):void{
			stopDragging2D();
			// Dispatches the event for the 3D scene.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DRAG_OBJECT2D_OVER3D, objSettings));
		}
		
		private function addContextMenuItems():void {
			var pinToCursorLabelStr:String = sG.interfaceLanguageDataXML.menu[0]._rclickPinToCursor.text();
			if (pinToCursorLabelStr == "") pinToCursorLabelStr = "Pin to Cursor";
			var cMenu:ContextMenu = new ContextMenu();
			var pinToCursor:ContextMenuItem = new ContextMenuItem(pinToCursorLabelStr);
			//cloneScreenOptions = new ContextMenuItem("Clone Screen with Options");
			
			pinToCursor.separatorBefore = true;
			pinToCursor.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onAddMultipleObjects, false, 0, true);
			
			cMenu.hideBuiltInItems();
			cMenu.customItems = [pinToCursor];
			
			this.contextMenu = cMenu;
		}
		
		private function onAddMultipleObjects(e:ContextMenuEvent):void {
			stopDragging2D();
			objSettings = getSettings();
			if (!objSettings) {
				trace("Error: No Drag and Drop object settings");
				return; // If not valid settings, return.
			}
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_BY_PINNING, objSettings));
		}
		
		public function getScreenshot():Bitmap {
			//if (!cloneBmp) takeScreenshot();
			takeScreenshot();
			return cloneBmp;
		}
		
		public function get objectType():String {
			return _objectType;
		}
		public function get objectId():int {
			return _objectId;
		}
		public function get kitTypeId():int {
			return _kitTypeId;
		}

		public function get dragEnabled():Boolean {
			return _dragEnabled;
		}

		public function set dragEnabled(value:Boolean):void {
			if (_dragEnabled == value) return;
			_dragEnabled = value;
			updateDragStatus();
		}
	}
}