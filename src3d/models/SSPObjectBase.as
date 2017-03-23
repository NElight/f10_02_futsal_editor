package src3d.models {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.events.MouseEvent3D;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.ButtonSettings;
	import src3d.ButtonsManager;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.utils.Dragger;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.ModelUtils;
	
	public class SSPObjectBase extends ObjectContainer3D {
		// SSP Object settings.
		protected var _objSettings:SSPObjectBaseSettings;
		
		protected var _useShadow:Boolean = true;
		protected var _selectable:Boolean = true;
		protected var _selected:Boolean = false;
		protected var _scalable:Boolean = true; // True if object is scaled with global scale options.
		protected var _resizable:Boolean = false; // True if user can change the size of the object.
		protected var _rotable:Boolean = false; // True if the object needs rotation controls.
		protected var _elevatable:Boolean = false;
		protected var _clonable:Boolean = true;
		protected var _repeatable:Boolean = false;
		protected var _flipable:Boolean = false; // True if the object can be flipped horizontally.
		protected var _colorable:Boolean = false;
		protected var _transparentable = false;
		
		protected var _objectLocked:Boolean = false;
		protected var sspObjEnabled:Boolean = true;
		protected var sspObjTransparencyValue:Number = .4;
		private var defaultPosition:Vector3D = new Vector3D(); // The default value to reset objects in viewer or default objects.
		private var defaultRotationY:Number = 0; // The default value to reset objects in viewer or default objects.
		
		// The object used to listen for mouse down events.
		protected var dragDropTarget:Object3D;
		// The object used to be dragged.
		protected var dragDropContainer:Object3D;
		
		// Object of Container. The main object like a Player or Equipment model.
		protected var objContainer:ObjectContainer3D;
		// Main Container, where the main object (player, equipment, etc.) is stored.
		protected var mainContainer:ObjectContainer3D;
		
		
		protected var vBtnSettings:Vector.<ButtonSettings> = new Vector.<ButtonSettings>();
		
		protected var _stage:Stage;
		protected var sScreen:SessionScreen;
		protected var drag3d:Dragger;
		
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		protected var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		protected var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		protected var stageEventHandler:EventHandler;
		
		
		public function SSPObjectBase(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			this.sScreen = sessionScreen;
			this._objSettings = objSettings;
			
			_stage = sScreen.stage;
			drag3d = sScreen.drag3d;
			
			initMainContainer();
			initShadow();
			initSetup();
			//init2DButtons(); // Use in extending classes to add their supported buttons.
			initDragDropTarget();
			
			stageEventHandler = new EventHandler(_stage);
			// Always listening to enable or disable this object on the screen it belongs to.
			sspEventHandler.addEventListener(SSPEvent.OBJECT_ENABLED, onObjectEnabled);
			//mouseCursor(true);
			this.ownCanvas = false;
			storePosition();
		}
		
		/**
		 * Setup some properties of the Object3D class.
		 * Override if a different setup is needed (eg: lines could have a different rotationY). 
		 */		
		protected function initSetup():void {
			if (this._rotable && !isNaN(this.objSettings._rotationY)) this.rotationY = this.objSettings._rotationY;
			this.sspPosition = objSettings._objPos;
		}
		
		private function initMainContainer():void {
			objContainer = new ObjectContainer3D();
			mainContainer = new ObjectContainer3D();
			mainContainer.name = "MainContainer";
			mainContainer.useHandCursor = true;
			mainContainer.mouseEnabled = true;
			this.addChild(mainContainer);
		}
		
		/**
		 * Set the object used to drag and drop.
		 * Override if a different setup is needed (eg: lines could have a different rotationY). 
		 */	
		protected function initDragDropTarget():void {
			dragDropTarget = mainContainer;
			dragDropContainer = this;
		}
		
		protected function initShadow():void { }
		/**
		 * Indicates if this object will have a shadow. 
		 * @param us Boolean.
		 * 
		 */		
		public function set useShadow(us:Boolean):void {
			_useShadow = us;
		}
		
		/**
		 * Stores the 2D buttons (elevation, color, etc.) to be enabled/disabled when the object is selected/deselected.
		 * To be overridden by the extending class if needed.
		 * @see ButtonSettings 
		 */		
		protected function init2DButtons():void {
			vBtnSettings = new Vector.<ButtonSettings>();
		}
		
		/**
		 * Change the 'selected' state of the object.
		 * To be overridden by the extending class. 
		 * @param s (Selected) True to mark the object as selected. Otherwise set it to false.
		 */		
		public function set selected(s:Boolean):void {
			if (this._selectable) {
				if (s) {
					if (!sspObjEnabled) return;
					_selected = s;
					(this.name+" Selected");
					activate2DButtons(true);
				}else {
					_selected = s;
					stopDrag(false);
					(this.name+" DeSelected");
					activate2DButtons(false);
				}
			} else {
				(this.name+" is not selectable.");
				_selected = false;
			}
		}
		
		/**
		 * Dispatches the event to enable/disable the custom button (eg: Player's Custom Kit button) in the 2D toolbar.
		 * This fuction is empty to be overridden by the extending class. 
		 */		
		protected function activate2DButtons(activate:Boolean):void {
			if (!vBtnSettings) return;
			if (activate) {
				// Dispatch.
				ButtonsManager.getInstance().showButtons(vBtnSettings);
			} else {
				if (!sG.createMode) {
					ButtonsManager.getInstance().hideButtons(vBtnSettings);
				}
			}
		}
		
		protected function addToMainContainer(obj:ObjectContainer3D):void {
			mainContainer.addChild(obj);
		}
		
		protected function removeFromMainContainer(obj:ObjectContainer3D):void {
			if (mainContainer.getChildByName(obj.name)) mainContainer.removeChild(obj);
		}
		
		protected function onObjectEnabled(e:SSPEvent):void {
			if (e.eventData.screenId != objSettings._screenId) return;
			this.selected = false;
			if (e.eventData.enabled) {
				enableMouse();
			} else {
				disableMouse();
			}
		}
		
		// ----------------------------- Mouse ----------------------------- //
		protected function enableMouse():void {
			disableMouse(); // Removes listeners if any and deselect object.
			if (this._selectable) {
				sspObjEnabled = true;
				this.mouseEnabled = true;
				dragDropTarget.useHandCursor = true;
				if (!dragDropTarget.hasEventListener(MouseEvent3D.MOUSE_DOWN)) dragDropTarget.addEventListener(MouseEvent3D.MOUSE_DOWN, onDragDropTargetMouseDown);
				if (!dragDropTarget.hasEventListener(SSPEvent.SESSION_SCREEN_SELECT_OBJECT)) sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, onSelectObject);
			}
		}
		protected function disableMouse():void {
			sspObjEnabled = false;
			this.mouseEnabled = false;
			dragDropTarget.useHandCursor = false;
			dragDropTarget.removeEventListener(MouseEvent3D.MOUSE_DOWN, onDragDropTargetMouseDown);
			sspEventHandler.RemoveEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT);
			stageEventHandler.RemoveEvent(Event.MOUSE_LEAVE);
			stageEventHandler.RemoveEvent(MouseEvent.MOUSE_UP);
		}
		protected function onDragDropTargetMouseDown(e:MouseEvent3D):void {
			//trace("SSPObjectBase.onDragDropTargetMouseDown()");
			if (!this._selectable || !sspObjEnabled) return;
			
			startDrag(false); // Includes toggleDragMode(true).
			
			// Disable all object selections except this and tell SessionScreen to register this as selectedObject.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, this));
		}
		
		public function startDrag(from2D:Boolean = true):void {
			//trace("startDrag()");
			
			if (!sspObjEnabled) return;
			
			if (from2D) this.selected = true;
			
			drag3d.object3d = null;
			drag3d.removeOffsetCenter();
			drag3d.object3d = dragDropContainer;
			if (!from2D) drag3d.setOffsetCenter(); // Keep object position offset when dragging an already existing object.			
			
			// Tell SessionScreen that an object is being dragged to disable pitch rotation and enable drag updating in SessionView.
			//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DRAG_OBJECT, {object:this, dragged:true}));
			toggleDragMode(true);
			
			// Check if mouse button is up or mouse is out of stage.
			stageEventHandler.addEventListener(Event.MOUSE_LEAVE, onSSPObjectStageMouseLeave, false, 0, true);
			stageEventHandler.addEventListener(MouseEvent.MOUSE_UP, onSSPObjectStageMouseUp, false, 0, true);
		}
		protected function stopDrag(callNotifyDrop:Boolean):void {
			if (!stageEventHandler || !drag3d) return;
			//trace("stopDrag() on "+this.name);
			stageEventHandler.RemoveEvent(Event.MOUSE_LEAVE);
			stageEventHandler.RemoveEvent(MouseEvent.MOUSE_UP);
			
			drag3d.object3d = null;
			drag3d.removeOffsetCenter();
			
			toggleDragMode(false);
			
			if (callNotifyDrop) notifyDrop();
		}
		protected function notifyDrop():void {
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DROP_OBJECT, this));
		}
		
		protected function onSSPObjectStageMouseUp(e:MouseEvent):void {
			//trace("onSSPObjectStageMouseUp()");
			stopDrag(true);
		}
		protected function onSSPObjectStageMouseLeave(e:Event):void {
			stopDrag(false);
			//sspEventDispatcher.dispatch(new SSPEvent(SSPEvent.CONTROL_DROP_OBJECT, this));
		}
		
		/**
		 * Normally used after create the object, to enable mouse listeners and others. 
		 */
		public function enableObject():void {
			if (_objectLocked) return;
			enableMouse();
		}
		
		/**
		 * Some creators like pining or cloning needs the object disable to avoid duplicated clicks. 
		 */
		public function disableObject():void {
			disableMouse();
		}
		
		// --------------------------- End Mouse --------------------------- //
		
		
		
		protected function onSelectObject(e:SSPEvent):void {
			// This event is received from another object or by itself.
			if (e.eventData != this) {
				// If the selected object is not this, deselect this.
				//trace("Deselecting "+this.name);
				if (this.selected) this.selected = false;
			} else {
				// If the selected object is this, select it.
				if (!this.selected) this.selected = true;
			}
		}
		
		public function toggleEditMode(toggle:Boolean):void {
			if (!sG) return;
			sG.editMode = toggle;
			if (!sScreen.screenLocked) sG.camLocked = toggle;
		}
		public function toggleDragMode(drag:Boolean):void {
			if (drag && !sScreen.drag3d.object3d) {
				//trace("Can't Drag.");
				return;
			}
			if (!sG) return;
			//sG.editMode = drag;
			sG.dragMode = drag;
			if (drag) {
				sG.camLocked = true;
			} else {
				if (!sScreen.screenLocked) sG.camLocked = false; // Unlock camera only if screen is not locked.
			}
		}
		
		/**
		 * Stores the current position and rotationY values. Used to reset default objects' position.
		 * @see resetPosition()
		 */		
		public function storePosition():void {
			defaultPosition = this.position.clone();
			defaultRotationY = this.rotationY;
		}
		public function resetPosition():void {
			this.position = defaultPosition.clone();
			this.rotationY = defaultRotationY;
		}
		public function set sspPosition(newPos:Vector3D):void {
			if (!newPos) {
				Logger.getInstance().addAlert("Null newPos on setup object.");
				return;
			}
			if (isNaN(newPos.x) || isNaN(newPos.y) || isNaN(newPos.z)) {
				Logger.getInstance().addAlert("Invalid newPos values on setup object.");
				return;
			}
			stopDrag(false);
			// newPos.x and newPos.z are applied to the container, newPos.y is applied to internal objects.
			this.x = newPos.x;
			this.z = newPos.z;
			if (this._elevatable) {
				this.y = 0; // Old sessions fix.
				this.objSettings._elevationNumber = newPos.y;
			} else {
				this.y = newPos.y;
			}
		}
		public function dropTo(newPos:Vector3D):void {
			sspPosition = newPos;
			notifyDrop();
		}
		
		public function set objectRotationY(newRotationY:Number):void {
			this.rotationY = newRotationY;
			sScreen.globalRotationY = this.rotationY;
		}
		public function get objectRotationY():Number {
			return this.rotationY;
		}
		
		public function set sspSize(newSize:Vector3D):void {
			if (!newSize) {
				Logger.getInstance().addAlert("Null newSize on setup object.");
				return;
			}
			if (isNaN(newSize.x) || isNaN(newSize.y) || isNaN(newSize.z)) {
				Logger.getInstance().addAlert("Invalid newSize values on setup object.");
				return;
			}
			if (this._scalable) {
				// In the future, it may store the x,y,z scales.
				//this.objSettings._size = newSize.x;
			}
		}
		
		/**
		 * Returns the selected state.
		 * @return True if the object is the selected one.
		 */
		public function get selected():Boolean {return _selected;}
		/**
		 * Change the globally scalable property of the object. 
		 * @param s True if the object will change scale when global scale changes.
		 */
		public function set scalable(s:Boolean):void {
			_scalable = s;
		}
		/**
		 * Returns true if this will change scale when global scale changes.
		 */
		public function get scalable():Boolean {return _scalable;}
		
		/**
		 * Change the 'resizable' property of the object. 
		 * @param s True if the object will allow custom size change.
		 */
		public function set resizable(s:Boolean):void {
			_resizable = s;
		}
		/**
		 * Returns true if the object will allow custom size change.
		 */
		public function get resizable():Boolean {return _resizable;}
		
		public function set objectLocked(locked:Boolean):void {
			if (locked) {
				if (this.selected) this.selected = false;
				if (sspObjEnabled) disableObject();
				this._selectable = false;
				this._objectLocked = true;
			} else {
				this._selectable = true;
				this._objectLocked = false;
				enableObject();
			}
		}
		
		public function get selectable():Boolean {return _selectable;}
		public function get rotable():Boolean {return _rotable;}
		public function get elevatable():Boolean {return _elevatable;}
		public function get transparentable():Boolean {return _transparentable;}
		
		// ---------------- SSP Object Settings ---------------- //
		/**
		 * Overrided in extending classes. 
		 * This getter is used to access to _objSettings internally from the extending classes.
		 * The difference with 'get settings()' is that this getter doesn't update _objSettings before return it.
		 * See Equipment.objSettings or Player.objSettings.
		 */		
		protected function get objSettings():SSPObjectBaseSettings {
			return _objSettings;
		}
		/**
		 * Updates and Returns _objSettings.
		 * This saves making two calls to the object when retrieving settings from other classes.
		 * @return SSPObjectBaseSettings
		 */		
		public function get settings():SSPObjectBaseSettings {
			// Update objSettings before return.
			updateObjSettings();
			return _objSettings;
		}
		/**
		 * Update _objSettings properties.
		 * Overrided in extending classes. 
		 */		
		protected function updateObjSettings():SSPObjectBaseSettings {
			if (!_objSettings) return null;
			_objSettings._rotationY = this.rotationY;
			_objSettings._x = this.x;
			_objSettings._y = this.y;
			_objSettings._z = this.z;
			return _objSettings;
		}
		
		public function get objectLocked():Boolean {return _objectLocked;}
		public function get libraryId():int {return objSettings._libraryId;}
		public function get screenId():int {return objSettings._screenId;}
		public function get objectType():String {return objSettings._objectType;}
		public function get onlyDefaultPitches():Boolean {return objSettings._onlyDefaultPitches;}
		public function get flippedH():Boolean {return objSettings._flipH;}
		
		protected function clear2DButtons():void {
			for (var i:int = 0; i < vBtnSettings.length; i++)
			{
				vBtnSettings[i].clearButtonSettings();
				vBtnSettings[i] = null;
			}
			vBtnSettings = new Vector.<ButtonSettings>();
		}
		
		protected function clearObjectContainer(objCont:ObjectContainer3D):void {
			ModelUtils.clearObjectContainer3D(objCont, true, true);
		}
		
		public function dispose():void {
			//trace("dispose()");
			//stopDrag(); // removed because it creates a loop when used in lines or other objects.
			stageEventHandler.RemoveEvents();
			dragDropTarget.removeEventListener(MouseEvent3D.MOUSE_DOWN, onDragDropTargetMouseDown);
			sspEventHandler.RemoveEvents();
			stopDrag(false);
			this.selected = false;
			disableMouse();
			clear2DButtons();
			
			sG.createMode = false;
			sG.editMode = false;
			sG.dragMode = false;
			if (!sScreen.screenLocked) sG.camLocked = false; // Unlock camera only if screen is not locked.
			
			drag3d.object3d = null;
			drag3d.removeOffsetCenter();
			
			// Empty the container.
			clearObjectContainer(mainContainer);
			if (objContainer) clearObjectContainer(objContainer);
			try {
				this.ownCanvas = true; // Away 3.6 needs ownCanvas = true to avoid render session error on deleting.
				if (this.parent) this.parent.removeChild(this);
			} catch (error:Error) {
				Logger.getInstance().addText("(A) - Can't delete child object3d: "+error, false);
			}
			
			dragDropTarget = null;
			dragDropContainer = null;
			drag3d = null;
			objContainer.geometry = null;
			objContainer.material = null;
			objContainer = null;
			this.removeChild(mainContainer);
			mainContainer.geometry = null;
			mainContainer.material = null;
			mainContainer = null;
			
			sspEventHandler = null;
			sspEventDispatcher = null;
			sScreen = null;
			vBtnSettings = null;
			_objSettings = null;
			
			defaultPosition = null;
			_stage = null;
			sG = null;
		}
	}
}