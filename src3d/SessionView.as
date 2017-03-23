package src3d
{
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.clip.Clipping;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.render.QuadrantRenderer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import src.SSPLogo;
	import src.popup.MessageBox;
	import src.popup.SSPBrand;
	import src.team.SSPTeamEvent;
	
	import src3d.enviroment.EnviromentTextures;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.Dragger;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	[SWF(frameRate=100)]
	
	public class SessionView extends Sprite
	{
		// Global variables.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		private var logger:Logger = Logger.getInstance();

		//engine variables
		private var renderer:QuadrantRenderer;
		public var view:View3D;
		public var camController:SSPCameraController;
		private var sspLogoSmall:SSPLogo;
		
		// Container Variables.
		private var _pW:int; // Parent Width
		private var _pH:int; // Parent Height
		private var _xPos:int; // 3D Scene xPos
		private var _yPos:int; // 3D Scene yPos
		private var _ref:main;
		private var _aScreens:Vector.<SessionScreen> = new Vector.<SessionScreen>;
		private var _currentScreenId:uint;
		private var cloneScreenContextMenuItem:ContextMenuItem;
		
		// Events.
		private var stageEventHandler:EventHandler;
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler;
		
		// Scene Controls.
		public var drag3d:Dragger;
		private var sL:SessionLoader;
		private var keysController:KeysController;
		private var selectedScreen:SessionScreen;
		private var _rotateObjectCW:Boolean;
		private var _rotateObjectCCW:Boolean;
		//private var sVLocked:Boolean;
		
		// Resize Vars.
		private var _viewNormal:Rectangle = new Rectangle();
		private var _viewFullPitch:Rectangle = new Rectangle();
		private var _viewFullScreen:Rectangle = new Rectangle();
		private var _viewFirstResizeTime:Boolean = true;
		private var _scaleRatio:Number = 1;
		private var pv_status:int = 1; // Pitch View Status: 1 normal, 2 full. See header.as.
		
		public function SessionView(w:Number, h:Number, xPos:Number, yPos:Number, ref:main) {
			_pW = w;
			_pH = h;
			_xPos = xPos;
			_yPos = yPos;
			_ref = ref;
			
			this.name = "SessionView";
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			// Important: Don't change the order of the init's.
			
			stageEventHandler = new EventHandler(_ref.stage);
			sspEventHandler = new EventHandler(sspEventDispatcher);
			
			// F11 Settings.
			/*_viewFullPitch.width = _ref.stage.stageWidth;
			_viewFullPitch.height = _ref.stage.stageHeight;
			_viewFullPitch.x = 0;
			_viewFullPitch.y = 0;*/
			
			_viewFullPitch.width = 1000;
			_viewFullPitch.height = 585;
			_viewFullPitch.x = _viewFullPitch.width / 2;
			_viewFullPitch.y = (_viewFullPitch.height / 2);
			
			initEngine();
			
			// Debug.
			//initDebug();
		}
		
		/*protected function initDebug():void {
			addChild(new AwayStats(view));
			scene.addChild(new Trident(20));
		}*/
		
		private function initEngine():void {
			// ---  View  --- //
			view = new View3D({stats:false}); // stats:false disables a3d context menu.
			// ---  Camera  --- //
			camController = new SSPCameraController(view, this, this.stage);
			
			// ---  View Config --- //
			var viewBG:Bitmap = EnviromentTextures.getInstance().sspBGBitmap;
			viewBG.width = _pW+1;
			viewBG.height = _pH+1;
			view.background.addChild(viewBG);
			view.background.x = (-_pW/2)-1; // -1 corrects the bg offset.
			view.background.y = (-_pH/2)-1; // -1 corrects the bg offset.
			view.scene = new Scene3D();
			//view.camera = camera;
			view.x = _pW/2+_xPos;
			view.y = _pH/2+_yPos;
			//view.session = new BitmapSession(1);
			//view.session = new BitmapSession(.5);
			//view.renderer = renderer;
			//view.stats = false;
			addChild(view);
			
			// ---  Clipping  --- //
			var _minX:Number = -_pW/2;
			var _minY:Number = -_pH/2;
			var _maxX:Number = _pW/2-1;
			var _maxY:Number = _pH/2-1;
			view.clipping = new RectangleClipping({minX:_minX, maxX:_maxX, minY:_minY, maxY:_maxY});
			
			// Store View Initial Settings.
			_viewNormal.x = view.x;
			_viewNormal.y = view.y;
			_viewNormal.width = view.width;
			_viewNormal.height = view.height;
			
			var rect:Rectangle = view.getBounds(view);
			sspLogoSmall = new SSPLogo(false);
			sspLogoSmall.x = view.x;
			sspLogoSmall.y = view.y;
			this.addChild(sspLogoSmall);
			
			// Add Context Menu.
			addContextMenuItems(view);
			
			drag3d = new Dragger(view);
			//drag3d.debug = true;
			drag3d.object3d = null;
			drag3d.plane = "xz";
			//drag3d.planeObject3d = pitchContainer;
			
			initSessionLoad();
		}
		
		private function initSessionLoad():void {
			sL = new SessionLoader(this);
			sL.addEventListener(SSPEvent.LOADING_DONE, onSessionLoaded);
			sL.startSessionLoad();
		}
		
		private function onSessionLoaded(e:SSPEvent):void {
			sL.removeEventListener(SSPEvent.LOADING_DONE, onSessionLoaded);
			sspEventDispatcher.dispatchEvent(e); // Notify to minutes and other controls.
			initListeners();
			//selectScreenFromId(e.eventData as uint); // Selected from TabBar.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT, e.eventData as uint)); // Tells TabBar to select the screen.
		}
		
		private function initListeners():void {
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onSessionViewMouseDown);
			
			// KEYS.
			keysController = new KeysController();
			
			// -------  2D Interface Events to 3D Listeners.  ------- //
			stageEventHandler.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stageEventHandler.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_SESSION_CLEAR_ALL, onClearAll);
			sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, onSelectObject);
			
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DRAG_OBJECT2D_OVER3D, onCreateDraggedObject);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DROP_OBJECT2D_OVER3D, onCreateDroppedObject);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_LINE, onCreateLineFrom2D);
			sspEventDispatcher.addEventListener(SSPEvent.CREATE_OBJECT_BY_CLONING, onCreateObjectByCloning);
			sspEventDispatcher.addEventListener(SSPEvent.CREATE_OBJECT_BY_PINNING, onCreateObjectByPinning);
			sspEventDispatcher.addEventListener(SSPEvent.CREATE_OBJECT_CANCEL, onCancelObjectCreate);
			
			// 3D CONTROLS
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_PITCH_VIEW_CHANGE, onChangePitchView);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_CAMERA_TARGET_CHANGE, onChangeCamTarget);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_PITCH_TEXTURE_CHANGE, onChangePitchTexture);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_SCALE_CHANGE, onChangeObjectScale);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_FLIP_H, onFlipH);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_SCREEN_LOCK, onScreenLock);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DOWN_ROTATE, onRotateObject); // includes: true if cw, false if ccw.
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CLICK_DELETE, onDeleteObject);
			
			// EQUIPMENT
			sspEventHandler.addEventListener(SSPEvent.CONTROL_COLOR_CHANGE, onSetObjectMainColor);
			sspEventDispatcher.addEventListener(SSPEvent.EQUIPMENT_TOGGLE_DEFAULT, onToggleDefaultEquipment);
			
			// LINES
			sspEventHandler.addEventListener(SSPEvent.LINE_UPDATE_SINGLE_LINE, onUpdateSelectedLine);
		}
		
		private function onEnterFrameHandler(e:Event):void
		{
			if (sG.dragMode) {
				if (drag3d.object3d) drag3d.updateDrag();
			}
			if (_rotateObjectCW) selectedScreen.rotateObject(true);
			if (_rotateObjectCCW) selectedScreen.rotateObject(false);
			view.render();
		}
		
		private function onSessionViewMouseDown(e:MouseEvent):void {
			_ref.stage.focus = _ref.stage;
		}
		
		private function onStageMouseUp(e:MouseEvent):void {
			//trace("SessionView.onStageMouseUp()");
			// If clicked inside the 3D Scene, don't stop object edit.
			/*if (isMouseOn3DView()) {
				//trace("Mouse on 3D View");
				stopMovements(false);
			} else {
				//trace("Mouse NOT on 3D View");
				// Stop moves and object editions if not clicked on pin line button.
				if (e.target == _ref._controls._controls.ctrl_item_pin.btnButton ||
					e.target == _ref._controls._controls.ctrl_item_clone.btnButton) {
					stopMovements(false);
				} else {
					stopMovements(false);
				}
			}*/
			stopMovements(false);
		}

		private function onStageMouseLeave(event:Event):void
		{
			//trace("SessionView.onStageMouseLeave()");
			//stopMovements(false);
		}
		
		private function stopMovements(stopEdit:Boolean):void {
			//trace("Pan: "+_newPanAngle+", Tilt: "+_newTiltAngle+", Zoom: "+camera.zoom+", Dist: "+camera.distance);
			
			if (stopEdit == true) {
				//trace("stopMovements().stopEdit = true");
				// Stop Current Edit/Creation/Draw.
				//trace("Hide 3D Toolbar Buttons");
				//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, null));
				sG.editMode = false;
				sG.createMode = false;
				
				
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CANCEL));
				SSPCursors.getInstance().reset();
				if (selectedScreen) {
					if (!selectedScreen.screenLocked) sG.camLocked = false; // Unlock camera only if screen is not locked.
					selectedScreen.creatingFinished(); // Finish cloning and line drawing.
					//selectedScreen.enableScreen(false);
				} else {
					sG.camLocked = false;
				}
				
			}
			if (!sG.createMode) sG.dragMode = false;
			_rotateObjectCW = false;
			_rotateObjectCCW = false;
			
			drag3d.object3d = null;
			drag3d.removeOffsetCenter();
		}
		
		public function sessionScreenAdd(sId:uint):void {
			logger.addText("Adding Screen (Id:"+sId+").", false);
			if (selectedScreen) selectedScreen.disableScreen(true, false);
			sspLogoSmall.logoEnabled = true;
			selectedScreen = null;
			sL.addEventListener(SSPEvent.LOADING_DONE, onScreenAdded);
			sL.loadScreen(sId); // Create from XML and add to aScreens.
		}
		private function onScreenAdded(e:SSPEvent):void {
			sL.removeEventListener(SSPEvent.LOADING_DONE, onScreenAdded);
			sspLogoSmall.logoEnabled = false;
			this.selectScreenFromId(e.eventData as uint);
			if (selectedScreen) {
				var sS:XML = selectedScreen.getScreenXML(false, true);
				var tP:uint = sS.children().(localName() == "player").length();
				var tE:uint = sS.children().(localName() == "equipment").length();
				var tL:uint = sS.children().(localName() == "line").length();
				var tT:uint = sS.children().(localName() == "text").length();
				var tO:uint = tP + tE + tL + tT;
				logger.addText("Screen Added - Id("+sS._screenId+"), SO("+sS._screenSortOrder+") - Pl("+tP+") , Eq("+tE+"), Li("+tL+"), Te("+tT+"), Total("+tO+").", false);
				
				selectedScreen.enableScreen(true);
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_CREATED, selectedScreen.getScreenXML(false, false))); // Dispatch for SSPTabBar XMLList.
			} else {
				logger.addText("Error adding Screen (Id:"+e.eventData+").", false);
				// Remove the created screen.
				sessionScreenRemove(e.eventData as uint);
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_CREATED, null)); // Dispatch for SSPTabBar including null.
			}
			
		}
		
		public function sessionScreenRemove(sId:uint):void {
			var screenToRemove:SessionScreen = getScreenFromId(sId);
			if (!screenToRemove) {
				logger.addText("Can't remove screen. Id "+sId+" doesn't exist in aScreens", true);
				return;
			}
			var sIdx:int = aScreens.indexOf(screenToRemove);
			if (sIdx == -1) {
				logger.addText("Can't remove screen. Not in aScreens", true);
				screenToRemove.disableScreen(true, true);
				screenToRemove = null;
			} else {
				screenToRemove.dispose();
				screenToRemove = null;
				aScreens.splice(sIdx,1);
			}
		}
		
		public function sessionScreenSelect(sId:uint):void {
			selectScreenFromId(sId);
		}
		private function selectScreenFromId(sId:uint):void {
			for each (var s:SessionScreen in _aScreens) {
				if (s.screenId == sId) {
					if (!s.screenEnabled) {
						s.enableScreen(true);
						selectedScreen = s;
					}
				} else {
					s.disableScreen(true, false);
				}
			}
		}
		private function getScreenFromId(id:int):SessionScreen {
			for each(var s:SessionScreen in _aScreens) {
				if (s.screenId == id) return s;
			}
			return null;
		}
		
		private function onSelectObject(e:SSPEvent):void {
			// trace("SessionView.onDeselectObjects()");
			
			// Hide custom 2D toolbar buttons.
			//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, null));
			//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, {btnName:"", btnVisible:false, btnState:0, btnData:null}));
			
			// Mike's added code to return to previous panel after editing custom kit
			if(_ref._menu._kits.getCustomKitState()) {
				_ref._menu.slider(_ref._menu.previousTab);
				_ref._menu._kits.setCustomKitState(false);
				_ref._menu._kits.set_panel(_ref._menu._kits.getPreviousPanel());
			}
		}
		
		private function onToggleDefaultEquipment(e:SSPEvent):void {
			var settings:Object = e.eventData;
			selectedScreen.toggleDefaultEquipment(e);
		}
		
		
		
		// ----------------------------------- 2D Controls ----------------------------------- //
		private function onClearAll(e:SSPEvent):void {
			// Ask for user confirmation.
			var strMsg:String = sG.interfaceLanguageDataXML.messages[0]._interfaceAreYouSure.text();
			main.msgBox.popupEnabled = true;
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onClearAllOK, false, 0, true);
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onClearAllCancel, false, 0, true);
			main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK_CANCEL);
		}
		
		private function onClearAllOK(e:Event):void {
			removeMsgBox();
			selectedScreen.clearAll(false);
		}
		
		private function onClearAllCancel(e:Event):void {
			removeMsgBox();
		}
		
		private function onSetObjectMainColor(e:SSPEvent):void {
			selectedScreen.setObjectMainColor(e);
		}
		
		private function onUpdateSelectedLine(e:SSPEvent):void {
			selectedScreen.updateSelectedLine(e);
		}
		// --------------------------------- End 2D Controls --------------------------------- //
		
		
		
		// ----------------------------------- View To Screen Controls ----------------------------------- //
		private function onCreateLineFrom2D(e:SSPEvent):void {
			if (selectedScreen) selectedScreen.createLineFrom2D(e.eventData.lineId, e.eventData.multiple);
		}
		
		private function onChangePitchView(e:SSPEvent):void {
			if (selectedScreen) {
				selectedScreen.changePitchView(e.eventData, false, true);
				_ref.updateToolbars();
			}
		}
		
		private function onChangeCamTarget(e:SSPEvent):void {
			if (selectedScreen) selectedScreen.changePitchCamTarget(e.eventData as uint);
		}
		
		private function onChangePitchTexture(e:SSPEvent):void {
			if (selectedScreen) selectedScreen.changePitchFloor(e.eventData);
		}
		
		private function onChangeObjectScale(e:SSPEvent):void {
			if (selectedScreen) selectedScreen.changeObjectScale(e.eventData);
		}
		
		private function onFlipH(e:SSPEvent):void {
			if (selectedScreen) selectedScreen.toggleFlipH();
		}
		
		private function onScreenLock(e:SSPEvent):void {
			var sLock:Boolean = e.eventData as Boolean;
			if (selectedScreen) selectedScreen.lockScreen(sLock);
		}
		
		private function onRotateObject(e:SSPEvent):void {
			if (e.eventData) {
				_rotateObjectCCW = false;
				_rotateObjectCW = true;
			} else {
				_rotateObjectCW = false;
				_rotateObjectCCW = true;
			}
		}
		
		private function onDeleteObject(e:SSPEvent):void {
			if (sG.editMode) return;
			if (selectedScreen) selectedScreen.deleteSelected();
		}
		
		/*public function sessionViewLock(sVLock:Boolean):void {
			if (sVLock && !sVLocked) {
				if (keysController) keysController.disableKeys();
				if (selectedScreen) selectedScreen.disableScreen(false, false);
				sVLocked = true;
			} else if (!sVLock && sVLocked) {
				if (selectedScreen) selectedScreen.enableScreen(true);
				if (keysController) keysController.enableKeys();
				sVLocked = false;
			}
		}*/
		// --------------------------------- End View To Screen Controls --------------------------------- //
		
		
		
		// ----------------------------------- Object Creation ----------------------------------- //
		/**
		 * Creates a new screen from xml settings. 
		 * @param sS Session Screen XMLList.
		 * @return The created screen.
		 * @see SessionLoader.as
		 */		
		public function addScreen(sS:XML):SessionScreen {
			var sScreen:SessionScreen;
			try {
				sScreen = new SessionScreen(sS, this);
			} catch(error:Error) {
				logger.addText("Can't create new screen: "+error.message, true);
				return null;
			}
			if (!sScreen) {
				logger.addText("Can't create new screen.", true);
				return null;
			}
			_aScreens.push(sScreen);
			view.scene.addChild(sScreen);
			return sScreen;
		}
		
		public function removeScreen(screenId):Boolean {
			logger.addText("Deleting Screen (Id:"+screenId+").", false);
			var totScreens:int = _aScreens.length;
			for (var i:int = 0;i<_aScreens.length;i++) {
				if (_aScreens[i].screenId == screenId) {
					_aScreens[i].dispose();
					_aScreens[i] = null;
					_aScreens.splice(i,1);
				}
			}
			selectedScreen = null;
			if (_aScreens.length < totScreens) {
				return true;
			} else {
				return false;
			}
		}
		
		private function onCreateObjectByCloning(e:SSPEvent):void {
			if (e.eventData == true) {
				selectedScreen.startObjectCloning();
			} else {
				selectedScreen.cloningFinished();
			}
		}
		
		private function onCreateObjectByPinning(e:SSPEvent):void {
			if (!selectedScreen || !selectedScreen.screenEnabled) return;
			selectedScreen.startObjectPinning(e.eventData as SSPObjectBaseSettings);
		}
		
		private function onCreateDraggedObject(e:SSPEvent):void {
			selectedScreen.createDraggedObject(e.eventData as SSPObjectBaseSettings);
		}
		
		private function onCreateDroppedObject(e:SSPEvent):void {
			selectedScreen.createDroppedObject(e.eventData as SSPObjectBaseSettings);
		}
		
		private function onCancelObjectCreate(e:SSPEvent):void {
			stopMovements(true);
		}
		
		// --------------------------------- End Object Creation --------------------------------- //
		
		
		
		// ----------------------------- Team Settings ----------------------------- //
		public function autoLayoutPitch(e:SSPTeamEvent):void {
			if (selectedScreen) selectedScreen.autoLayoutPitch(e);
		}
		public function updatePlayerTeamSettings(e:SSPTeamEvent):void {
			if (selectedScreen) selectedScreen.updatePlayerTeamSettings();
		}
		public function clearPlayerTeamData(e:SSPTeamEvent):void {
			for each (var s:SessionScreen in _aScreens) {
				s.clearPlayerTeamData(e);
			}
		}
		public function selectTeamPlayer(e:SSPEvent):void {
			if (selectedScreen) selectedScreen.selectTeamPlayer(e);
		}
		// -------------------------- End of Team Settings ------------------------- //
		
		
		
		// ----------------------------------- Screen Clone ----------------------------------- //
		private function addContextMenuItems(target:InteractiveObject):void {
			var cMenu:ContextMenu = new ContextMenu();
			cloneScreenContextMenuItem = new ContextMenuItem("Clone Screen");
			//cloneScreenOptions = new ContextMenuItem("Clone Screen with Options");
			cloneScreenContextMenuItem.separatorBefore = true;
			cloneScreenContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onScreenClone, false, 0, true);
			cMenu.hideBuiltInItems();
			cMenu.customItems = [cloneScreenContextMenuItem];
			target.contextMenu = cMenu;
		}
		
		




		private function onScreenClone(e:ContextMenuEvent):void {
			//_refData = e.mouseTarget.name; // Uses the tab name or the screen3d name.
			logger.addText("Cloning From Current Screen (Id:"+selectedScreen.screenId+", SO:"+selectedScreen.screenSortOrder+").", false);
			screenClone(selectedScreen.screenId);
		}
		
		public function screenClone(sId:Number):void {
			if (isNaN(sId)) return;
			var tabScreenId:uint = sId;
			// We need to update the screen content before cloning.
			this.getScreenFromId(tabScreenId).getScreenXML(true, false);
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_CLONE, tabScreenId));
		}
		
		public function screenCloneToggle(value:Boolean):void {
			cloneScreenContextMenuItem.enabled = value;
		}
		// -------------------------------- End of Screen Clone ------------------------------- //
		
		
		
		// ----------------------------------- Session Resize ----------------------------------- //
		public function resizeView(pv_stat:int):void {
			pv_status = pv_stat;
			view3DUpdate();
			_ref.updateToolbars();
		}
		public function view3DUpdate():void {
			// Commented out until F11.
			/*if (isFullScreen()) {
				
				var ratioWidth:Number = stage.stageWidth / _viewFullPitch.width;
				var ratioHeight:Number = stage.stageHeight / _viewFullPitch.height;
				_scaleRatio = Math.min(ratioWidth, ratioHeight);
				
				_viewFullScreen.width = _viewFullPitch.width * _scaleRatio;
				_viewFullScreen.height = _viewFullPitch.height * _scaleRatio;
				_viewFullScreen.x = (stage.stageWidth-_viewFullScreen.width)/2;
				_viewFullScreen.y = _viewFullPitch.y;
				
				if (pv_status == 2) {
					// If full pitch.
					view.width = stage.stageWidth;
					view.height = stage.stageHeight
					view.x = 0;
					view.y = 0;
				} else {
					// If normal pitch.
					view.width = _viewNormal.width * _scaleRatio;
					view.height = _viewNormal.height * _scaleRatio;
					view.x = (_viewNormal.x*_scaleRatio) + _viewFullScreen.x;
					view.y = (_viewNormal.y*_scaleRatio) + _viewFullScreen.y;
				}
			} else {
				_scaleRatio = 1;
				if (pv_status == 2) {
					// If full pitch.
					view.width = stage.stageWidth;
					view.height = stage.stageHeight
					view.x = 0;
					view.y = 0;
				} else {
					// If normal pitch.
					view.width = _viewNormal.width * _scaleRatio;
					view.height = _viewNormal.height * _scaleRatio;
					view.x = _viewNormal.x*_scaleRatio;
					view.y = _viewNormal.y*_scaleRatio;
				}
			}*/
			
			_scaleRatio = 1;
			if (pv_status == 2) {
				viewToFullScreen(true);
			} else {
				viewToFullScreen(false);
			}
		}
		private function viewToFullScreen(value:Boolean):void {
			if (value) {
				var increaseRatio:Number = _viewFullPitch.width / _viewNormal.width;
				_viewFullPitch.height = _viewNormal.height*increaseRatio;
				view.width = _viewFullPitch.width;
				view.height = _viewFullPitch.height;
				view.x = _viewFullPitch.x;
				view.y = _viewFullPitch.y + 25; // +35px is the header height. But use 25 to compensate view height ratio.
			} else {
				// If normal pitch.
				view.width = _viewNormal.width;
				view.height = _viewNormal.height;
				view.x = _viewNormal.x;
				view.y = _viewNormal.y;
			}
		}
		private function isFullScreen():Boolean {
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				return true;
			} else {
				return false;
			}
		}
		// --------------------------------- End Session Resize --------------------------------- //
		
		
		
		public function isMouseOn3DView():Boolean {
			var isOnView:Boolean = false;
			var minX:Number = _xPos;
			var minY:Number = _yPos;
			var maxX:Number = _xPos + _pW;
			var maxY:Number = _yPos + _pH;
			if (stage.mouseX < maxX &&
				stage.mouseX > minX &&
				stage.mouseY < maxY &&
				stage.mouseY > minY) {
				isOnView = true;
			}
			//trace("SessionView.isMouseOn3DView(): "+isOnView);
			return isOnView
		}
		
		private function removeMsgBox():void {
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onClearAllOK);
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onClearAllCancel);
			main.msgBox.popupVisible = false;
		}
		
		private function camStopMoves(stopMoves:Boolean):void {
			if (stopMoves) {
				// Pause camera moving.
				camController.camStopMoves();
			}
		}
		
		public function takeHighResScreenshots(includeLogo:Boolean, sspLogoAlpha:Number = .2, sspLogoScale:Number = 1):Vector.<ScreenshotItem> {
			var aScreenshots:Vector.<ScreenshotItem> = new Vector.<ScreenshotItem>();
			var sItem:ScreenshotItem;
			var selectedId:int = (selectedScreen)? int(selectedScreen.screenId) : 0;
			var tmpBmp:Bitmap;
			var sspLogo:MovieClip;
			var sspLogoMargin:uint = 4;
			var sspLogoCont:MovieClip;
			
			logger.addText("Taking High Resolution screenshots...", false);
			
			if (selectedScreen) selectedScreen.disableScreen(true, false);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			viewToFullScreen(true);
			
			for each (var sS:SessionScreen in aScreens) {
				if (sS && !sS.disposeFlag) {
					// Make screen selected.
					this.selectScreenFromId(sS.screenId);
					view.clear(); // Clear view buffer.
					view.render(); // Render the frame to capture.
					//tmpBmp = new Bitmap(takeScreenshot(int(sS.screenId)));
					tmpBmp = MiscUtils.takeScreenshot(this,false);
					if (includeLogo) {
						sspLogo = new mcSSPUrlBW();
						sspLogo.scaleX = sspLogoScale;
						sspLogo.scaleY = sspLogoScale;
						sspLogo.alpha = sspLogoAlpha;
						sspLogo.x = tmpBmp.width - sspLogo.width - sspLogoMargin;
						sspLogo.y = tmpBmp.height - sspLogo.height - sspLogoMargin;
						sspLogoCont = new MovieClip();
						sspLogoCont.addChild(sspLogo);
						tmpBmp.bitmapData.draw(sspLogoCont, null, null, null, null, true);
					}
					if (tmpBmp) {
						sItem = new ScreenshotItem(tmpBmp, sS.getScreenXML(false, false)._screenTitle.text(), sS.screenId, sS.screenSortOrder);
						aScreenshots.push(sItem);
					} else {
						logger.addText("("+sS.screenId+","+sS.screenSortOrder+") - Can't take screenshot.", true);
					}
				}
			}
			
			aScreenshots = Vector.<ScreenshotItem>(MiscUtils.vectorSortToArray(aScreenshots, "screenSO"));
			
			if (pv_status == 1) viewToFullScreen(false);
			
			this.selectScreenFromId(selectedId);
			view.clear();
			view.render();
			
			if (!this.hasEventListener(Event.ENTER_FRAME)) this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			
			logger.addText("Done. "+aScreenshots.length+" screenshot/s of "+_aScreens.length+" screens.", false);
			
			return aScreenshots;
		}
		
		public function takeScreenshot(sId:uint):BitmapData {
			logger.addText("Taking screenshot of screenId"+sId.toString()+"...", false);
			
			// Make screen selected.
			this.selectScreenFromId(sId);
			
			// Render the frame to capture.
			view.clear();
			view.render();
			
			// Capture.
			var bmd:BitmapData = MiscUtils.takeScreenshot(view,false).bitmapData;
			
			// Add Branding.
			var sspBrand:MovieClip;
			var useSSPBrand:Boolean;
			var brandText:String = "";
			var uintBrandExist:Number = sG.sessionDataXML.session.children().(localName() == "_sessionBranding").length();
			
			if (uintBrandExist == 0) {
				useSSPBrand = true;
			} else {
				brandText = sG.sessionDataXML.session._sessionBranding.text();
			}
			
			if (useSSPBrand || brandText != "") {
				sspBrand = new SSPBrand(useSSPBrand, brandText, bmd.width, bmd.height);
				bmd.draw(sspBrand);
			}
			
			return bmd;
			logger.addText("Screenshot Done.", false);
		}
		
		public function get currentScreenId():uint {
			if (!selectedScreen) {
				_currentScreenId = 0;
			} else {
				_currentScreenId = selectedScreen.screenId;
			}
			return _currentScreenId;
		}
		
		public function get currentScreen():SessionScreen {
			return selectedScreen;
		}
		public function get aScreens():Vector.<SessionScreen> { return _aScreens; }
		public function get aPeriodsOnly():Vector.<SessionScreen> {
			var aP:Vector.<SessionScreen> = new Vector.<SessionScreen>();
			SessionScreenUtils.sortScreensBySortOrder(aScreens);
			for (var i:uint = 0;i<aScreens.length;i++) {
				if (aScreens[i] && !aScreens[i].disposeFlag && aScreens[i].screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					aP.push(aScreens[i]);
				}
			}
			return aP;
		}
		public function get aSetPiecesOnly():Vector.<SessionScreen> {
			var aSP:Vector.<SessionScreen> = new Vector.<SessionScreen>();
			SessionScreenUtils.sortScreensBySortOrder(aScreens);
			for (var i:uint = 0;i<aScreens.length;i++) {
				if (aScreens[i] && !aScreens[i].disposeFlag && aScreens[i].screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
					aSP.push(aScreens[i]);
				}
			}
			return aSP;
		}
		public static function get view():View3D { return view; }
	}
}