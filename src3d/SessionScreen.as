package src3d
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.geom.Path;
	
	import flash.display.Stage;
	import flash.geom.Vector3D;
	
	import src.events.SSPScreenEvent;
	import src.minutes.MinutesManager;
	import src.minutes.PeriodMinutes;
	import src.team.SSPTeamEvent;
	import src.team.TeamGlobals;
	
	import src3d.lines.AreaBase;
	import src3d.lines.DynamicLine;
	import src3d.lines.LineBase;
	import src3d.lines.LineCreator;
	import src3d.lines.LineLibrary;
	import src3d.lines.LineSettings;
	import src3d.models.Equipment;
	import src3d.models.EquipmentCreator;
	import src3d.models.ObjectCloner;
	import src3d.models.PlayersManager;
	import src3d.models.SSPObjectBase;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.pitches.Pitch;
	import src3d.models.soccer.pitches.PitchController;
	import src3d.models.soccer.players.Player;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.text.Billboard;
	import src3d.text.TextCreator;
	import src3d.text.TextSettings;
	import src3d.utils.Dragger;
	import src3d.utils.EventHandler;
	import src3d.utils.LineUtils;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	public class SessionScreen extends ObjectContainer3D
	{
		
		// Start Globals Container.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mM:MinutesManager = MinutesManager.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		// Screen Vars.
		private var _sessionView:SessionView;
		private var view:View3D;
		private var camController:SSPCameraController;
		private var sPitch:Pitch; // Screen pitch.
		private var pitchController:PitchController;
		private var objectCloner:ObjectCloner;
		private var eCreator:EquipmentCreator;
		private var tCreator:TextCreator;
		private var lCreator:LineCreator;
		private var pManager:PlayersManager;
		private var sS:XML;
		private var _screenEnabled:Boolean;
		private var _screenLocked:Boolean; // Locks pitch and shaded areas only. Screen may be enabled.
		private var lastCamSettings:SSPCameraSettings = new SSPCameraSettings();
		private var lastScreenId:int = -1;
		private var _disposeFlag:Boolean;
		
		// Objects Lists.
		public var periodMinutes:PeriodMinutes;
		private var selectedObject:SSPObjectBase;
		public var aPlayers:Vector.<Player> = new Vector.<Player>();
		public var aEquipment:Vector.<Equipment> = new Vector.<Equipment>();
		public var aLines:Vector.<LineBase> = new Vector.<LineBase>();
		public var aTexts:Vector.<Billboard> = new Vector.<Billboard>();
		public var aDefaultEquipment:Vector.<Equipment> = new Vector.<Equipment>();
		
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		public function SessionScreen(sS:XML, sessionView:SessionView) {
			this.sS = sS;
			this._sessionView = sessionView;
			this.view = sessionView.view;
			this.camController = sessionView.camController;
			this.visible = false;
			
			periodMinutes = new PeriodMinutes(this);
			eCreator = new EquipmentCreator();
			tCreator = new TextCreator(this);
			lCreator = new LineCreator(this);
			pManager = new PlayersManager(this, eCreator);
			
			initPitch();
			
			objectCloner = new ObjectCloner(this);
			
			initPermanentListeners();
		}
		
		private function initPermanentListeners():void {
			// KITS
			sspEventHandler.addEventListener(SSPEvent.PLAYERS_UPDATE_DEFAULT_KITS, updateDefaultKits);
//			sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_DESELECT_OBJECTS, onDeselectObjects);
			sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, onNewObjectSelected);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_PITCH_MOUSE_DOWN, onPitchMouseDown);
			sspEventHandler.addEventListener(SSPEvent.CONTROL_DROP_OBJECT, onObjectDropped);
		}
		
		private function initPitch():void {
			// ---- Pitch ---- //
			sPitch = new Pitch();
			pitchController = new PitchController(sPitch, camController);
			pitchController.changeCamTarget(int( sS._cameraTarget.text() ));
			pitchController.changePitchFloor(int( sS._pitchFloorId.text() ));
			pitchController.changePitchMarks(int( sS._pitchMarksId.text() ));
			this.addChild(sPitch);
		}
		
		/**
		 * Shows the screen and enable listeners. 
		 */		
		public function enableScreen(applyCamera:Boolean):void {
			if (!_screenEnabled) {
				//trace("enableScreen("+Number(sS._screenId.text())+")");
				this.visible = true;
				this._screenEnabled = true;
				pitchController.pitchEnabled = true;
				toggleObjectsEnabled(true);
				if (applyCamera) applyCameraSettings();
				deselectObjects();
			}
		}
		
		/**
		 * Disable all Screen's listeners. Hide optional.
		 */
		public function disableScreen(hideScreen:Boolean, forceDisable:Boolean):void {
			if (forceDisable) _screenEnabled = true;
			if (_screenEnabled) {
				this._screenEnabled = false;
				pitchController.pitchEnabled = false;
				sessionView.camController.camStopMoves();
				deselectObjects();
				toggleObjectsEnabled(false);
				cloningFinished();
				drag3d.object3d = null;
				drag3d.removeOffsetCenter();
				
				storeCameraSettings();
				storePitchSettings();
				if (hideScreen) this.visible = false;
			}
		}
		
		/**
		 * Locks the screen. Disable pitch and shaded areas clicks to allow better object clicks. 
		 */		
		public function lockScreen(sLock:Boolean):void {
			_screenLocked = sLock;
			sG.camLocked = _screenLocked;
			pitchController.pitchEnabled = (_screenLocked)? false : true;
			lockShadedAreas(_screenLocked);
		}
		
		private function applyCameraSettings():void {
			deselectObjects();
			camController.moveCameraToXMLSettings(sS, true);
			pitchController.changeCamTarget(uint( sS._cameraTarget.text() ));
		}
		
		private function logMsg(strMsg:String, isError:Boolean, useSeparator:Boolean = false, useTimeStamp:Boolean = true):void {
			var strInfo:String = "S("+this.screenId+","+this.screenSortOrder+") - ";
			logger.addText(strInfo+strMsg, isError, useSeparator, useTimeStamp);
		}
		
		
		// ----------------------------- Object Creation ----------------------------- //
		/**
		 * Creates a new object that has been dragged from the 2D area.
		 */
		public function createDraggedObject(objSettings:SSPObjectBaseSettings):void {
			if (!objSettings) return;
			if (sG.editMode) return; // Abort if in pin or clone mode, to avoid unexpected drag and drop.
			if (objSettings._objectType == ObjectTypeLibrary.OBJECT_TYPE_PLAYER) {
				var pSettings:PlayerSettings = objSettings as PlayerSettings;
				// If it's a team player and it exist already, cancel creation and select the existing one.
				if (getTeamPlayer(pSettings._teamPlayerId, pSettings._teamSide)) {
					return;
				} else {
					/*if (pSettings._teamPlayer == true && pSettings._cKit._kitTypeId == PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS) {
						var gk:Player = pManager.getGoalkeeperFromTeam(pSettings._cKit._kitId);
						if (gk) {
							// Create standard player from settings.
							var pStandard:Player;
							var pSettingsStandard:PlayerSettings; // Standard Player Settings Container.
							pSettingsStandard = gk.settings.clone() as PlayerSettings; // Use current player settings.
							pSettingsStandard._libraryId = PlayerLibrary.defaultPlayerId; // Set default player pose.
							pSettingsStandard._cKit._kitTypeId = PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS; // Set player kit.
							pStandard = createObjectFrom2D(pSettingsStandard, true, false) as Player;
							if (pStandard) {
								pStandard.position = gk.position.clone();
								this.deletePlayer(gk);
							}
							//return;
						}
					}*/
				}
			}
			createObjectFrom2D(objSettings, true, true);
		}
		
		/**
		 * Creates a new object that has been dropped from the 2D area.
		 */
		public function createDroppedObject(objSettings:SSPObjectBaseSettings):void {
			if (!objSettings) return;
			if (sG.editMode) return; // Abort if in pin or clone mode, to avoid unexpected drag and drop.
			if (objSettings._objectType == ObjectTypeLibrary.OBJECT_TYPE_PLAYER) {
				// If it's a team player and it exist already, cancel creation and select the existing one.
				if (getTeamPlayer(PlayerSettings(objSettings)._teamPlayerId, PlayerSettings(objSettings)._teamSide)) return;
			}
			// Update settings with mouse position.
			var mPos:Vector3D = drag3d.getIntersect();
			objSettings._x = mPos.x;
			objSettings._y = mPos.y;
			objSettings._z = mPos.z;
			createObjectFrom2D(objSettings, true, false);
		}
		/**
		 * Creates a new object that has been dragged from the 2D area 
		 * @param objSettings SSPObjectBaseSettings. The object settings (equipment, text or player).
		 * @param addToScene. True to place the object on pitch. False to get a virutal object to clone.
		 * @returns The created object.
		 * @see Drag2DObject
		 * @see startCreatingMultypleObject
		 */	
		private function createObjectFrom2D(objSettings:SSPObjectBaseSettings, addToScene:Boolean, dragIt:Boolean):SSPObjectBase {
			var obj:SSPObjectBase;
			var newPos:Vector3D = _sessionView.drag3d.getIntersect();
			if (!isPosOnPitch(objSettings._objPos)) {
				logMsg("(A) - Can't create object (mouse not on pitch)", false);
				return null;
			}
			if (addToScene) logMsg("Creating "+objSettings._objectType+" from 2D (libraryId: "+objSettings._libraryId+")", false);
			objSettings._x = newPos.x;
			//objSettings._y = newPos.y;
			objSettings._z = newPos.z;
			objSettings._screenId = lastScreenId = this.screenId;
			objSettings._flipH = sG.globalFlipH;
			
			if (objSettings._objectType != ObjectTypeLibrary.OBJECT_TYPE_TEXT) {
				objSettings._rotationY = Number( sS._globalRotationY.text() );
				obj = eCreator.createNewObject3D(this, objSettings);
				if (addToScene) setupNewObject3D(obj, dragIt);
			} else {
				//createNewSprite3D(objData.objectId, objData.bmp, newPos, true);
				objSettings._rotationY = 0;
				obj = tCreator.createNewText(objSettings as TextSettings);
				if (addToScene) setupNewObject3D(obj, dragIt);
			}
			return obj;
		}
		
		public function createLineFrom2D(lineId:int, multiple:Boolean):void {
			if (!this._screenEnabled) return;
			logMsg("Creating line from 2D (libraryId: "+lineId+", multidrawing: "+multiple+")", false);
			this.creatingFinished();
			sG.createMode = true;
			sG.camLocked = true;
			togglePinButton(true, multiple);
			toggleObjectsEnabled(false);
			
			// Start line drawing.
			var newLine:LineBase = lCreator.drawLine(this.screenId, lineId, multiple);
			if (!newLine) {
				logMsg("(A) - Can't create line from 2D.", false);
				return;
			}
//			setupNewObject3D(newLine, false);
		}
		
		public function createNewLine3D(_lineSettings:LineSettings, objEnabled:Boolean = true):LineBase {
			var newLine:LineBase;
			newLine = lCreator.drawLoadedLine(_lineSettings);
			if (newLine) {
				if (!objEnabled) newLine.disableObject();
				setupNewObject3D(newLine, false, objEnabled);
			}
			return newLine;
		}
		
		public function createNewText(textSettings:TextSettings, dragged:Boolean, objEnabled:Boolean = true):void {
			// _screenId and _onlyDefaultPitches are included in lineSettings.
			if (screenId == textSettings._screenId) {
				var objText:Billboard = tCreator.createNewText(textSettings);
				if (objText) {
					setupNewObject3D(objText, dragged, objEnabled);
				} else {
					logMsg("Can't add new text.", true);
				}
			} else {
				trace("Error: Incorrect screenId when creating Text");
			}
		}
		
		public function createNewObject3D(objSettings:SSPObjectBaseSettings, dragged:Boolean = true, objEnabled:Boolean = true):void {
			if (!objSettings) return;
			// If the object position is out of the pitch, return.
			if (!dragged) {
				if (!isPosOnPitch(objSettings._objPos)) {
					logMsg("(A) - 3DObject creation skipped (not on pitch).", false);
					return;
				}
			}
			objSettings._screenId = lastScreenId = this.screenId;
			var obj:SSPObjectBase = eCreator.createNewObject3D(this, objSettings);
			if (!obj) {
				logMsg("Can't create 3DObject", true);
				return;
			}
			setupNewObject3D(obj, dragged, objEnabled);
		}
		
		/**
		 * Setup the created object.
		 *  
		 * @param obj SSPObjectBase. Can be a Player, Equipment, Line or Text.
		 * @param dragged Boolean. True if the object is created by drag and drop.
		 * @param objEnabled Boolean. True to enable or disable the object listeners.
		 * In the case of ObjectCloner, it needs to create disabled objects. See SSPObjectBase.enableObject().
		 */	
		public function setupNewObject3D(obj:SSPObjectBase, dragged:Boolean, objEnabled:Boolean = true):void {
			if (!obj) return;
			//trace("Adding "+obj.objectType+"'.");
			
			// Enable mouse (F11).
			obj.enableObject();
			
			// Add the object to the objects collection.
			switch(obj.objectType) {
				case ObjectTypeLibrary.OBJECT_TYPE_PLAYER:
					aPlayers.push(obj);
					sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_CREATED));
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT:
					if(obj.onlyDefaultPitches) {
						obj.visible = (sPitch.usingDefaultPitch)? true : false;
						obj.storePosition();
						aDefaultEquipment.push(obj);
					} else {
						aEquipment.push(obj);
					}
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_LINE:
					aLines.push(obj);
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_TEXT:
					aTexts.push(obj);
					break;
			}
			
			if (!objEnabled) { 
				obj.disableObject();
			} else {
				obj.enableObject();
			}
			
			if (dragged) {
				obj.startDrag();
				this.newObjectSelected(obj);
			} else {
				// TODO: Collision Detection here. If not dragged, check that no other object of the same type is on its position.
				deselectObjects();
			}
			// Needs removing listeners when removing object.
			this.addChild(obj);
		}
		
		private function onNewObjectSelected(e:SSPEvent):void {
			newObjectSelected(e.eventData as SSPObjectBase);
		}
		
		private function newObjectSelected(newObj:SSPObjectBase):void {
			if (!newObj) return;
			if (newObj.selectable) {
				// Set the new selected object.
				if (newObj.screenId == this.screenId){
					selectedObject = newObj;
					if (newObj.objectType == ObjectTypeLibrary.OBJECT_TYPE_PLAYER) {
						sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_SELECTED, newObj));
					}
				}
			}
		}
		
/*		private function onDeselectObjects(e:SSPEvent):void {
			deselectObjects();
		}*/
		
		private function deselectObjects():void {
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, null));
			selectedObject = null;
			sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_DESELECTED));
		}
		
		/**
		 * Enables or Disables all objects on pitch. 
		 * @param objEnabled Boolean. If false, makes all objects non selectable (eg: for clone or pin mode).
		 */		
		private function toggleObjectsEnabled(objEnabled:Boolean):void {
			var objSettings:Object = {screenId:this.screenId, enabled:objEnabled};
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.OBJECT_ENABLED, objSettings)); // Enabled objects in this screen.
		}
		
		/**
		 * Creates a virtual object and then send it to the cloner class.
		 * @param objData Object settings.
		 * 
		 */			
		public function startObjectPinning(objSettings:SSPObjectBaseSettings):void {
			if (!objSettings) return;
			if (!this._screenEnabled) return;
			var obj:Equipment = createObjectFrom2D(objSettings, false, false) as Equipment;
			if (!obj) return;
			obj.objectRotationY = Number(sS._globalRotationY);
			if (!obj) return;
			logMsg("Start "+objSettings._objectType+" pinning (libraryId: "+objSettings._libraryId+").", false);
			startObjectCloning(obj);
		}
		public function startObjectCloning(newItem:SSPObjectBase = null):void {
			if (!this._screenEnabled) return;
			trace("SessionScreen.cloningStart()");
			if (!newItem) {
				if (!selectedObject) {
					trace("No selected object to clone.");
					return;
				}
				sG.createMode = true;
				sG.camLocked = true;
				newItem = selectedObject;
				toggleCloneButton(true);
				SSPCursors.getInstance().setClone();
			} else {
				sG.createMode = true;
				sG.camLocked = true;
				togglePinButton(true, true);
				SSPCursors.getInstance().setPin();
			}
			toggleObjectsEnabled(false);
			//cloningFinished();
			logMsg("Cloning "+newItem.objectType+" (libraryId: "+newItem.libraryId+").", false);
			objectCloner.startCloning(newItem, true);
		}
		
		/**
		 * Received from ObjectClonner.stopCloning(). 
		 */		
		public function cloningFinished():void {
			if (!sG || !sG.createMode) return;
			logMsg("Cloning finished.", false);
			creatingFinished();
		}
		
		public function drawingLineFinished():void {
			//if (!sG.createMode) return;
			logMsg("Drawing line finished.", false);
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.LINE_CREATE_FINISHED)); // Disable menu line buttons.
			creatingFinished();
		}
		
		public function creatingFinished():void {
			logMsg("Creating object/s finished.", false);
			SSPCursors.getInstance().reset();
			sG.editMode = false;
			sG.createMode = false;
			if (!_screenLocked) sG.camLocked = false; // Unlock camera only if screen is not locked.
			toggleCloneButton(false);
			togglePinButton(false, false);
			hide2DButtons();
			deselectObjects();
			toggleObjectsEnabled(true);
		}
		
		/**
		 * Enables the clone 2D button. See 'controls.button_visible()'.
		 * @param bEnabled Boolean
		 */		
		private function toggleCloneButton(btnEnabled:Boolean):void {
			var btnSettingsVector:Vector.<ButtonSettings> = new Vector.<ButtonSettings>();
			btnSettingsVector.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_CLONE, btnEnabled, 0, null, btnEnabled));
			ButtonsManager.getInstance().showButtons(btnSettingsVector);
		}
		/**
		 * Enables the pin 2D button. See 'controls.button_visible()'.
		 * @param bEnabled Boolean
		 */		
		private function togglePinButton(btnEnabled:Boolean, btnSelected:Boolean):void {
			var btnSettingsVector:Vector.<ButtonSettings> = new Vector.<ButtonSettings>();
			btnSettingsVector.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_PIN, btnEnabled, 0, null, btnSelected));
			ButtonsManager.getInstance().showButtons(btnSettingsVector);
		}
		
		private function hide2DButtons():void {
			//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_VISIBLE, null));
			ButtonsManager.getInstance().hideAllButtons();
		}
		
		private function getTeamPlayer(teamPlayerId:String, teamSide:String):Player {
			// If it's a team player and it exist already, cancel creation and select the existing one.
			var playerFound:Player;
			if (teamPlayerId && teamPlayerId != "") {
				for each (var p:Player in aPlayers) {
					if (p.teamPlayer && p.teamPlayerId == teamPlayerId && p.teamSide == teamSide) {
						playerFound = p;
						break;
					}
				}
			}
			return playerFound;
		}
		// --------------------------- End Object Creation --------------------------- //
		
		
		// ----------------------------- Object Deletion ----------------------------- //
		private function onObjectDropped(e:SSPEvent):void {
			var obj:SSPObjectBase = e.eventData as SSPObjectBase;
			if (!obj) {
				//logMsg("(A) - Can't check dropped object (null)", false);
				return;
			}
			
			try {
				if (obj.screenId != this.screenId) return;
			} catch(error:Error) {
				// Can't access to object property. Object deleted already on its parent screen.
				return;
			}
			
			if (!isOnPitch(obj)) {
				selectedObject = obj;
				this.deleteSelected();
			}
		}
		public function deleteSelected():void {
			if (!selectedObject) return;
			deleteObjectFromArray(selectedObject);
			if (selectedObject.objectType == ObjectTypeLibrary.OBJECT_TYPE_PLAYER) {
				var pSettings:PlayerSettings = selectedObject.settings.clone() as PlayerSettings;
				sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_REMOVED, {screen:this, playerSettings:pSettings}));
			}
			deleteSSPObject(selectedObject);
			selectedObject = null;
		}
		public function deletePlayer(p:Player):void {
			this.deselectObjects();
			if (!p) logMsg("Deleting a null player.", true);
			var pSettings:PlayerSettings = p.settings.clone() as PlayerSettings;
			deleteObjectFromArray(p);
			deleteSSPObject(p);
			sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_REMOVED, {screen:this, playerSettings:pSettings}));
		}
		public function substitutePlayers(pOut:Player, pIn:Player):void {
			this.deselectObjects();
			if (!pOut) logMsg("Sending off a null player.", true);
			// Notify substitution
			var pOutSettings:PlayerSettings = pOut.settings.clone() as PlayerSettings;
			var pInSettings:PlayerSettings = pIn.settings.clone() as PlayerSettings;
			deleteObjectFromArray(pOut);
			deleteSSPObject(pOut);
			sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_SUBSTITUTION, {screen:this, playerOutSettings:pOutSettings, playerInSettings:pInSettings}));
		}
		public function deleteAllTeamPlayers():void {
			this.deselectObjects();
			logMsg("Deleting all team players on pitch.", false);
			selectedObject = null;
			var p:Player;
			for (var i:int = aPlayers.length-1; i >= 0; i--) {
				p = aPlayers[i];
				if (p) {
					if (p.teamPlayer || p.teamPlayerEmpty) {
						aPlayers[i].dispose();
						aPlayers[i] = null;
						delete aPlayers[i];
						aPlayers.splice(i,1);
					}
				}
			}
			sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_REMOVED, {screen:this}));
		}
		
		private function deleteSSPObject(sspObj:SSPObjectBase):void {
			try {
				logMsg("Deleting "+sspObj.objectType+"(Id: "+sspObj.libraryId+")", false);
				sspObj.dispose();
				sspObj = null;
			}catch(error:Error) {
				logMsg("(A) - Error deleting object: "+error.message, false);
			}
		}
		private function deleteObjectFromArray(sspObj:SSPObjectBase):void {
			var objIdx:int;
			if (!sspObj) {
				logMsg("Can't delete a null object.", true);
				return;
			}
			switch(sspObj.objectType) {
				case ObjectTypeLibrary.OBJECT_TYPE_PLAYER:
					objIdx = aPlayers.indexOf(sspObj);
					if (objIdx == -1) {
						logMsg("(A) - Error removing "+sspObj.objectType+", id "+sspObj.libraryId+" from array. Not in array.", false);
						break;
					}
					aPlayers.splice(objIdx,1);
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT:
					if (Equipment(sspObj).onlyDefaultPitches) {
						objIdx = aDefaultEquipment.indexOf(sspObj);
						if (objIdx == -1) {
							logMsg("(A) - Error removing "+sspObj.objectType+", id "+sspObj.libraryId+" from array. Not in array.", false);
							return;
						}
						aDefaultEquipment.splice(objIdx,1);
					} else {
						objIdx = aEquipment.indexOf(sspObj);
						if (objIdx == -1) {
							logMsg("(A) - Error removing "+sspObj.objectType+", id "+sspObj.libraryId+" from array. Not in array.", false);
							return;
						}
						aEquipment.splice(objIdx,1);
					}
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_LINE:
					objIdx = aLines.indexOf(sspObj);
					if (objIdx == -1) {
						logMsg("(A) - Error removing "+sspObj.objectType+", id "+sspObj.libraryId+". Not in array.", false);
						return;
					}
					aLines.splice(objIdx,1);
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_TEXT:
					objIdx = aTexts.indexOf(sspObj);
					if (objIdx == -1) {
						logMsg("(A) - Error removing "+sspObj.objectType+", id "+sspObj.libraryId+". Not in array.", false);
						return;
					}
					aTexts.splice(objIdx,1);
					break;
			}
		}
		
		public function clearAll(includeDefault:Boolean):void {
			logMsg("Deleting all objects on pitch.", false);
			periodMinutes.dispose();
			// TODO: clear all minutes?
			selectedObject = null;
			while(aPlayers.length>0) {
				aPlayers[0].dispose();
				aPlayers[0] = null;
				delete aPlayers[0];
				aPlayers.splice(0,1);
			}
			while(aLines.length>0) {
				aLines[0].dispose();
				aLines[0] = null;
				delete aLines[0];
				aLines.splice(0,1);
			}
			while(aEquipment.length>0) {
				aEquipment[0].dispose();
				aEquipment[0] = null;
				delete aEquipment[0];
				aEquipment.splice(0,1);
			}
			if (includeDefault) {
				while(aDefaultEquipment.length>0) {
					aDefaultEquipment[0].dispose();
					aDefaultEquipment[0] = null;
					delete aDefaultEquipment[0];
					aDefaultEquipment.splice(0,1);
				}
			}else {
				resetDefaultEquipment();
			}
			while(aTexts.length>0) {
				aTexts[0].dispose();
				aTexts[0] = null;
				delete aTexts[0];
				aTexts.splice(0,1);
			}
			sspEventDispatcher.dispatchEvent(new SSPScreenEvent(SSPScreenEvent.SCREEN_PLAYER_REMOVED, {screen:this}));
		}
		/*private function deleteAllFromArray(arr:Array) {
			selectedObject = null;
			while(arr.length>0) {
				arr[0].dispose();
				arr[0] = null;
				delete arr[0];
				arr.splice(0,1);
			}
			arr = [];
		}*/
		
		private function resetDefaultEquipment():void {
			for each (var de:Equipment in aDefaultEquipment) {
				if (de) de.resetPosition();
			}
		}
		// --------------------------- End Object Deletion --------------------------- //
		
		
		
		// ----------------------------------- View To Screen Controls ----------------------------------- //
		public function changePitchView(val:String, forceAltAngle:Boolean, allowSwitchAngle:Boolean):void {
			deselectObjects();
			sS._pitchMarksId = pitchController.changePitchView(val, forceAltAngle, allowSwitchAngle).toString();
		}
		
		public function changePitchCamTarget(val:int):void {
			sS._cameraTarget = pitchController.changeCamTarget(val, true).toString();
		}
		
		public function changePitchFloor(val:int):void {
			sS._pitchFloorId = pitchController.changePitchFloor(val).toString();
		}
		
		public function changePitchMarks(val:int):void {
			sS._pitchMarksId = pitchController.changePitchMarks(val).toString();
		}
		
		public function changeObjectScale(sclIdx:uint):void {
			var i:int;
			
			// If specified scale index is not in the array, change to the next current scale.
			if (sclIdx >= SSPSettings.aScales.length) {
				logMsg("Can't use object scale index: "+sclIdx, true);
				return;
			}
			
			sS._globalObjScale = sclIdx.toString();
			
			for (i=0; i<aEquipment.length;i++) {
				aEquipment[i].applyGlobalScale();
			}
			for (i=0; i<aDefaultEquipment.length;i++) {
				aDefaultEquipment[i].applyGlobalScale();
			}
			for (i=0; i<aPlayers.length;i++) {
				aPlayers[i].applyGlobalScale();
			}
			
			// Remove the focus from the test controls or keyboard events wont work.
//			_sessionView.stage.focus = view;
		}
		
		public function toggleFlipH():void {
			if (!selectedObject) return;
			if (selectedObject.objectType == ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT ||
				selectedObject.objectType == ObjectTypeLibrary.OBJECT_TYPE_PLAYER
			) {
				Equipment(selectedObject).toggleFlipH();
			}
		}
		
		public function setObjectMainColor(e:SSPEvent):void {
			if (!selectedObject) return;
			if ( isNaN(e.eventData) ) return;
			var newCol:uint = uint(e.eventData);
			if (selectedObject.objectType == ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT) {
				Equipment(selectedObject).changeMainColor(newCol);
			}
			// Shaded Areas are also colorable.
			if (selectedObject.objectType == ObjectTypeLibrary.OBJECT_TYPE_LINE) {
				if (selectedObject.settings._libraryId == LineLibrary.ID_14_GRID) {
					AreaBase(selectedObject).changeMainColor(newCol);
				}
			}
		}
		
		private function lockShadedAreas(areaLocked:Boolean):void {
			for each (var l:LineBase in aLines) {
				if (l.libraryId == LineLibrary.ID_14_GRID) {
					if (areaLocked) {
						l.selected = false;
						l.disableObject();
					} else {
						l.enableObject();
					}
				}
			}
		}
		
		public function updateSelectedLine(e:SSPEvent):void {
			if (!selectedObject.objectType == ObjectTypeLibrary.OBJECT_TYPE_LINE)return;
			if (selectedObject.settings._libraryId != LineLibrary.ID_14_GRID) {
				DynamicLine(selectedObject).updateSingleLineSettings(e);
			}
		}
		
		public function toggleDefaultEquipment(e:SSPEvent):void {
			var settings:Object = e.eventData;
			var eVisible:Boolean = settings.equipVisible;
			var pSelected:Pitch = settings.pitchSelected;
			var i:int;
			if (pSelected != sPitch) return;
			if (eVisible){
				for each (var de:Equipment in aDefaultEquipment) {
					de.visible = true;
				}
			} else {
				for each (var de:Equipment in aDefaultEquipment) {
					de.selected = false;
					de.visible = false;
				}
			}
		}
		// --------------------------------- End View To Screen Controls --------------------------------- //
		
		
		
		// ----------------------------- Team Settings ----------------------------- //
		public function autoLayoutPitch(e:SSPTeamEvent):void {
			var pvButtonName:String = (sS._screenFormat.text() == TeamGlobals.SCREEN_FORMATION_P1)? SSPSettings.pitchView1Team : SSPSettings.pitchView2Teams;
			// If we play 'Away' and we are displaying only one team, use the alternative pitch angle.
			var altAngle:Boolean = (sG.sessionDataXML.session._teamWePlay.text() == TeamGlobals.PLAY_AWAY &&
				pvButtonName == SSPSettings.pitchView1Team)? true : false;
			this.changePitchView(pvButtonName, altAngle, false);
			//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_PITCH_VIEW_CHANGE, pvButtonName));
			deselectObjects();
			// Note that eventData will be null if no players needs to be added. Eg. when changing tab group from Period to Set-Pieces.
			if (!e || !e.eventData) {
				updatePlayerTeamSettings();
			} else {
				pManager.autoLayoutPitch(e);
			}
		}
		public function updatePlayerTeamSettings():void {
			for each (var p:Player in aPlayers) {
				p.updateTeamSettings();
			}
		}
		public function get playerNameFormat():uint {
			return uint(sS._screenPlayerNameFormat.text());
		}
		public function get playerModelFormat():uint {
			return uint(sS._screenPlayerModelFormat.text());
		}
		public function get playerDisplayName():Boolean {
			return MiscUtils.stringToBoolean(sS._screenPlayerNameDisplay.text());
		}
		public function get playerDisplayNumber():Boolean {
			return (playerModelFormat == 1)? true : false;
		}
		public function get playerDisplayModel():Boolean {
			return MiscUtils.stringToBoolean(sS._screenPlayerModelDisplay.text());
		}
		public function get playerDisplayPosition():Boolean {
			return MiscUtils.stringToBoolean(sS._screenPlayerPositionDisplay.text());
		}
		public function get screenFormat():String {
			return sS._screenFormat.text();
		}
		public function clearPlayerTeamData(e:SSPTeamEvent):void {
			pManager.clearPlayerTeamData(e);
		}
		public function selectTeamPlayer(e:SSPEvent):void {
			if (!e.eventData || !e.eventData.teamPlayerId || !e.eventData.teamSide) return;
			var p:Player = getTeamPlayer(e.eventData.teamPlayerId, e.eventData.teamSide);
			if (!p) return;
			this.deselectObjects();
			p.selected = true;
			this.newObjectSelected(p);
		}
		public function deleteTeamPlayerFromId(teamPlayerId:String, teamSide:String):void {
			this.deletePlayer(getTeamPlayer(teamPlayerId, teamSide));
		}
		// -------------------------- End of Team Settings ------------------------- //
		
		
		
		private function onPitchMouseDown(e:SSPEvent):void {
			// reset screen excep in create mode (eg: pinning / drawing).
			if (!sG.createMode) {
				creatingFinished();
			}
		}
		
		private function updateDefaultKits(e:SSPEvent):void {
			("updateDefaultKits()");
			for each(var p:Player in aPlayers) {
				p.updateDefaultKit();
			}
		}
		
		public function setCustomKit(e:SSPEvent):void {
			("setCustomKit()");
			if (_screenEnabled) {
				for each(var p:Player in aPlayers) {
					if (p.selected) p.setCustomKit(e.eventData);
				}
			}
		}
		
		public function rotateObject(cw:Boolean):void {
			//trace("rotateObject("+cw+")");
			if (selectedObject && selectedObject.rotable) {
				if (cw) {
					//selectedObject.rotationY += 5;
					selectedObject.objectRotationY += 5;
				} else {
					//selectedObject.rotationY -= 5;
					selectedObject.objectRotationY -= 5;
				}
			}
		}
		
		public function isOnPitch(sspObj:SSPObjectBase):Boolean {
			//if (!sspObj) sspObj = selectedObject;
			if (!sspObj) {
				logMsg("(A) - Can't check if object is on pitch. Null or invalid object.", false);
				return false;
			}
			var onPitch:Boolean = true;
			if (sspObj.objectType == ObjectTypeLibrary.OBJECT_TYPE_LINE) {
				//onPitch = isPathOnPitch(LineBase(sspObj).pathData, LineBase(sspObj).areaBounds.areaPosition);
				onPitch = isLineOnPitch(sspObj as LineBase);
			} else {
				onPitch = isPosOnPitch(sspObj.position);
			}
			return onPitch;
		}
		
		public function isPosOnPitch(objPos:Vector3D):Boolean {
			if (!objPos) return false;
			if ( isNaN(objPos.x) || isNaN(objPos.y) || isNaN(objPos.z) ) return false;
			var limitX:Number = sPitch.pitchWidth/2;
			var limitZ:Number = sPitch.pitchHeight/2;
			var objX:int = objPos.x;
			var objZ:int = objPos.z;
			var onPitch:Boolean = true;
			
			if (objX>limitX || objX < -limitX || 
				objZ>limitZ || objZ < -limitZ) {
				onPitch = false;
				//trace("It's not on pitch. xPos: "+objX+", zPos: "+objZ+" limitX: +/-"+limitX+", limitZ: +/-"+limitZ);
			}else {
				//trace("It is on pitch. xPos: "+objX+", zPos: "+objZ+" limitX: +/-"+limitX+", limitZ: +/-"+limitZ);
			}
			return onPitch;
		}
		
		private function isLineOnPitch(sspLine:LineBase):Boolean {
			var onPitch:Boolean = true;
			var pitchLimitX:Number = sPitch.pitchWidth/2;
			var pitchLimitZ:Number = sPitch.pitchHeight/2;
			var objBoundX:int = LineBase(sspLine).areaBounds.areaWidth/2;
			var objBoundZ:int = LineBase(sspLine).areaBounds.areaDepth/2;
			var objX:Number = LineBase(sspLine).areaBounds.areaPosition.x;
			var objZ:Number = LineBase(sspLine).areaBounds.areaPosition.z;
			if (objX+objBoundX < -pitchLimitX || objX-objBoundX > pitchLimitX || 
				objZ+objBoundZ < -pitchLimitZ || objZ-objBoundZ > pitchLimitZ) {
				onPitch = false;
			}
			return onPitch;
		}
		
		public function isPathOnPitch(path:Path, newTargetPos:Vector3D = null, fullyOnPitch:Boolean = false):Boolean {
			if (newTargetPos) {
				if ( isNaN(newTargetPos.x) || isNaN(newTargetPos.y) || isNaN(newTargetPos.z) ) return false;
			}
			// Update line position.
			//DynamicLine(sspObj).updateLinePosition;
			var limitX:Number = sPitch.pitchWidth/2;
			var limitZ:Number = sPitch.pitchHeight/2;
			var objX:Number = (newTargetPos)? newTargetPos.x : 0;
			var objZ:Number = (newTargetPos)? newTargetPos.z : 0;
			var onPitch:Boolean = true;
			var pB:Object = LineUtils.getPathBounds(path);
			var objBoundX:int = pB.pWidth/2;
			var objBoundZ:int = pB.pDepth/2;
			
			if (!fullyOnPitch) {
				if (objX+objBoundX < -limitX || objX-objBoundX > limitX || 
					objZ+objBoundZ < -limitZ || objZ-objBoundZ > limitZ) {
					onPitch = false;
					//trace(this.name+" is not on pitch. maxX: "+maxX+", minX: "+minX+" maxZ: "+maxZ+", minZ: "+minZ+" limitX: +/-"+limitX+", limitZ: +/-"+limitZ);
					//trace(this.name+" is not on pitch.");
				}else {
					//trace(this.name+" is on pitch. maxX: "+maxX+", minX: "+minX+" maxZ: "+maxZ+", minZ: "+minZ+" limitX: +/-"+limitX+", limitZ: +/-"+limitZ);
					//trace(this.name+" is on pitch.");
				}
			} else {
				// Check if all bounds of the path are inside the pitch area.
				if (objX-objBoundX < -limitX || objX+objBoundX > limitX || 
					objZ-objBoundZ < -limitZ || objZ+objBoundZ > limitZ) {
					onPitch = false;	
				}
			}
			return onPitch;
		}
		
		public function getScreenXML(updateData:Boolean, clone:Boolean):XML {
			if (updateData) {
				updateXMLData();
			}
			if (clone) {
				return sS.copy();
			} else {
				return sS;
			}
		}
		
		private function updateXMLData():void {
			var errorStr:String;
			try {
				storeCameraSettings();
			} catch (error:Error) {
				errorStr = "Error ("+error.errorID+"): "+error.message;
				logMsg("(A) - Error updating Camera settings: "+errorStr, false);
			}
			try {
				storePitchSettings();
			} catch (error:Error) {
				errorStr = "Error ("+error.errorID+"): "+error.message;
				logMsg("(A) - Error updating Pitch settings: "+errorStr, false);
			}
			try {
				storeMinutes();
			} catch (error:Error) {
				errorStr = "Error ("+error.errorID+"): "+error.message;
				logMsg("(A) - Error updating Minutes: "+errorStr, false);
			}
			try {
				storeScreenObjects();
			} catch (error:Error) {
				errorStr = "Error ("+error.errorID+"): "+error.message;
				logMsg("(A) - Error updating Screen objects: "+errorStr, false);
			}
		}
		
		private function storeCameraSettings():void {
			/*sS._cameraTarget = sPitch.cameraTargetId.toFixed(2);
			sS._cameraTiltAngle = camController.tiltAngle.toFixed(2);
			sS._cameraPanAngle = MiscUtils.wrapAngle(camController.panAngle ).toFixed(2);
			sS._cameraZoom = camController.zoom.toFixed(2);
			sS._cameraFOV = ""; // F11 setting.
			sS._cameraType = camController.camType;*/
		}
		
		private function storePitchSettings():void {
			sS._globalObjScale = Number(sS._globalObjScale.text()).toFixed(2);
			sS._globalRotationY = MiscUtils.wrapAngle( Number(sS._globalRotationY.text()) ).toFixed(2);
			sS._pitchMarksId = sPitch.pitchMarksId.toString();
			sS._pitchFloorId = sPitch.pitchFloorId.toString();
		}
		
		private function storeMinutes():void {
			periodMinutes.saveToXML();
		}
		
		private function storeScreenObjects():void {
			// Update the XML with the current objects in the screen.
			SessionScreenUtils.updateScreenObjects(this, sS, true, true, true, true, true);
		}
		
		public function set globalRotationY(rot:Number):void {sS._globalRotationY = MiscUtils.wrapAngle(rot).toFixed(2);}
		public function get globalRotationY():Number { return Number(sS._globalRotationY.text());}
		public function get globalScaleNum():Number { return SSPSettings.aScales[uint(sS._globalObjScale.text())]; }
		//public function get screenPitch():Pitch {return sPitch;}
		//public function get screenPitchController():PitchController {return pitchController;}
		public function get screenId():int {
			// If screen has been deleted, return the last Id.
			if (!sS) return lastScreenId;
			lastScreenId = int(sS._screenId.text());
			return lastScreenId;
		}
		public function get screenSortOrder():int {
			if (!sS) return -1;
			return int(sS._screenSortOrder.text());
		}
		public function get screenType():String {
			return sS._screenType.text();
		}
		public function get screenEnabled():Boolean { return _screenEnabled; }
		public function get screenLocked():Boolean { return _screenLocked; }
		public function get pitchLimits():Vector3D { return sPitch.getPitchLimits(); }
		public function get stage():Stage { return _sessionView.stage; }
		public function get drag3d():Dragger { return _sessionView.drag3d; }
		public function get sessionView():SessionView { return _sessionView; }
		public function get disposeFlag():Boolean { return _disposeFlag; }
		
		public function dispose():void {
			_disposeFlag = true;
			// Remove screen listeners.
			sspEventHandler.RemoveEvents();
			// Disable Screen.
			disableScreen(false, true);
			// Remove all objects.
			clearAll(true);
			// Remove tools.
			objectCloner.dispose(); // Note that it calls 'SessionScreen.cloningFinished()'.
			objectCloner = null;
			// Remove creators.
			eCreator.dispose();
			eCreator = null;
			tCreator.dispose(); // Remove text MovieClips.
			tCreator = null;
			lCreator.dispose();
			lCreator = null;
			// Remove pitch.
			sPitch.dispose();
			sPitch = null;
			pitchController.dispose();
			pitchController = null;
			
			// Remove references.
			camController = null;
			sS = null;
			_sessionView = null;
			view = null;
			
			sG = null;
			logger = null;
			
			lastCamSettings = null;
			selectedObject = null;
			aPlayers = null;
			aEquipment = null;
			aLines = null;
			aTexts = null;
			aDefaultEquipment = null;
			lastCamSettings = null;
			sspEventDispatcher = null;
			sspEventHandler = null;
			periodMinutes.dispose();
			periodMinutes = null;
			
			this.ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}