package src3d.models.soccer.players {
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Cast;
	import away3d.loaders.Max3DS;
	import away3d.materials.BitmapMaterial;
	
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;
	
	import src.team.PRTeamManager;
	
	import src3d.ButtonSettings;
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.models.KitsLibrary;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.AccessoriesLibrary;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.equipment.SpeedChute;
	import src3d.utils.ColorUtils;
	import src3d.utils.MiscUtils;
	
	public class Player extends Equipment {
		
		protected var objSettingsRef:PlayerSettings;
		
		public var objMaterial:BitmapMaterial;
		protected var modelIdx:int // Index in PlayerLibrary._aPlayers.
		protected var bodyTexture:BitmapData // Stores the main texture (skin, hair, shoes).
		protected var playerKit:PlayerKit; // Kit colors.
		
		protected var _useSpeedChute:Boolean;
		protected var speedChute:SpeedChute;
		protected var _useGloves:Boolean;
		protected var _useBall:Boolean;
		
		// Team.
		protected var objDisc:PlayerDisc;
		protected var _highlightTeamPlayer:Boolean;
		protected var aTeamCollisionGlow:Array = [new GlowFilter(0x99FFFF,1,4,4,10)];
		
		protected var pCol:PlayerCollider;
		public var oldPos:Vector3D;
		
		public function Player(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as PlayerSettings;
			super(sessionScreen, objSettings);
			objSettingsRef._objectType = ObjectTypeLibrary.OBJECT_TYPE_PLAYER; // The type of object, used for xml storing and array classification.
			this.name = PlayerLibrary.NAME_PLAYER;
			
			// Properties.
			this._rotable = true;
			this._flipable = true;
			this._elevatable = true;
			this._repeatable = false;
			this._internalScale = 4;
			this.controllerScale = 1.4;
			this.shadow.shadowScale(.5, .3);
			//this.shadow.scaleX = 1.5;
			//this.shadow.scale(.5);
			//this.useShadow = false;
			
			// Init.
			initRotator();
			setCustomKit(objSettingsRef._cKit, false); // Player Kit.
			initPlayer();
			init2DButtons();
			initAccessories();
			initTeamObjects();
			initElevation();
			initCollider();
			
			// Setup.
			flipH(this.flippedH);
			applyGlobalScale();
			updateTeamSettings();
		}
		
		private function initPlayer():void {
			// Get class name of the 3d model objects.
			modelIdx = src3d.utils.MiscUtils.indexInArray(PlayerLibrary._aPlayers, "PlayerId", objSettingsRef._libraryId);
			var modelName:String = PlayerLibrary._aPlayers[modelIdx].ClassName;
			var modelClass:Class = PlayerModels.getInstance()[modelName+"a"];
			objContainer = Max3DS.parse(Cast.bytearray(modelClass),{autoLoadTextures:false}) as ObjectContainer3D;
			objContainer.rotationX = 90;
			objContainer.rotationY = 180;
			objContainer.name = "Player";
			applyMaterial();
			
			objContainer.addChild(shadow);
			shadow.shadowRotateX(-90);
			
			objectSet.push(objContainer);
			
			this.updateInternalScale(objContainer);
			
			this.addToMainContainer(objContainer);
		}
		
		private function initTeamObjects():void {
			if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				// Player Disc.
				var pKitSet:PlayerKitSettings = playerKit.getKitColors();
				objDisc = new PlayerDisc(pKitSet._topColor, pKitSet._bottomColor, objSettingsRef);
				updateDisc();
				this.addToMainContainer(objDisc);
				sspEventHandler.addEventListener(SSPEvent.CAMERA_MOVED, onCameraMoved);
			}
		}
		
		protected function initCollider():void {
			pCol = new PlayerCollider(sScreen, this);
		}
		
		protected override function setMaterials():void {
			applyMaterial();
		}
		
		public function get playerType():int {
			return PlayerLibrary._aPlayers[modelIdx].PlayerType;
		}
		
		protected override function init2DButtons():void {
			super.init2DButtons();
			// Set Custom Kit Button.
			vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_PLAYER_KIT, true, 0, {cKit:objSettingsRef._cKit, player:this}, false));
		}
		
		protected override function initAccessories():void {
			// Load Accessories.
			var aAccessories:Array = (objSettingsRef._accessories != null || objSettingsRef._accessories != "")? objSettingsRef._accessories.split(",") : null;
			var libIdx:int = MiscUtils.indexInArray(PlayerLibrary._aPlayers,"PlayerId",objSettingsRef._libraryId);
			if (libIdx < 0) return;
			accessories = PlayerLibrary._aPlayers[libIdx].OptionalAccessories;
			if (!accessories || accessories.length == 0 || !aAccessories || aAccessories.length == 0) return;
			if (aAccessories.indexOf(AccessoriesLibrary.ACCESSORY_CHUTE) != -1) useSpeedChute = true;
			if (aAccessories.indexOf(AccessoriesLibrary.ACCESSORY_GLOVES) != -1) useGloves = true;
			if (aAccessories.indexOf(AccessoriesLibrary.ACCESSORY_BALL) != -1) useBall = true;
		}
		
		protected override function deleteAccessories():void {
			useSpeedChute = false;
			if (speedChute) {
				speedChute.dispose();
				speedChute = null;
			}
		}
		
		public function set useSpeedChute(enabled:Boolean):void {
			if (enabled && !_useSpeedChute) {
				if (!speedChute) speedChute = new SpeedChute();
				_useSpeedChute = true;
				setAccessoriesTransparency();
				this.addToMainContainer(speedChute);
				enableAccessory(AccessoriesLibrary.ACCESSORY_CHUTE);
			} else {
				_useSpeedChute = false;
				if (speedChute)	removeFromMainContainer(speedChute);
				disableAccessory(AccessoriesLibrary.ACCESSORY_CHUTE);
			}
		}
		public function get useSpeedChute():Boolean {
			return _useSpeedChute;
		}
		
		public function set useGloves(enabled:Boolean):void {
			//TODO: Implement gloves.
			/*if (enabled && !_useGloves) {
				_useGloves = true;
				setAccessoriesTransparency();
			} else {
				_useGloves = false;
			}*/
			_useGloves = enabled;
		}
		public function get useGloves():Boolean {
			return _useGloves;
		}
		public function set useBall(enabled:Boolean):void {
			_useBall = enabled;
		}
		public function get useBall():Boolean {
			return _useBall;
		}
		
		protected override function setAccessoriesTransparency():void {
			if (!speedChute) return;
			ColorUtils.changeMaterialTransparency([speedChute], transparencyValue);
		}
		
		protected override function getElevationDefault():void {
			modelIdx = src3d.utils.MiscUtils.indexInArray(PlayerLibrary._aPlayers, "PlayerId", objSettingsRef._libraryId);
			_elevationDefault = PlayerLibrary._aPlayers[modelIdx].ElevationDefault;
		}
		
		public override function changeMainColor(newColor:uint):void {}
		public override function resetColor():void {}
		
		private function applyMaterial():void {
			objMaterial = KitsLibrary.getInstance().getMaterialFromKit(playerKit.getKitColors());
			//objMaterial.blendMode = BlendMode.LAYER;
			objMaterial.alpha = this.transparencyValue; // Apply current transparency.
			var bothSides:Boolean = (this.flippedH)? true : false;
			ColorUtils.applyBitmapMaterialToSingleObject(objContainer, objMaterial,"",bothSides,1);
		}

		public function setCustomKit(newCKit:PlayerKitSettings, applyKit:Boolean = true):void {
			// Init kit if needed.
			if (!playerKit) playerKit = new PlayerKit(objSettingsRef._cKit._kitId, objSettingsRef._cKit._kitTypeId);
			// Setup kit.
			playerKit.setCustomKit(newCKit);
			// Apply materials if requested.
			if (applyKit) applyMaterial();
			if (objDisc) {
				var pKitSet:PlayerKitSettings = playerKit.getKitColors();
				objDisc.updateDisc(pKitSet._topColor, pKitSet._bottomColor);
			}
		}
		
		public function updateDefaultKit():void {
			playerKit.updateDefaultKit();
			applyMaterial();
		}
		
		public function get kitId():int {
			return cKit._kitId;
		}
		
		public function get kitTypeId():int {
			return cKit._kitTypeId;
		}
		
		public function get cKit():PlayerKitSettings {
			return playerKit.getCustomKit();
		}
		
		
		
		// ----------------------------- Team Settings ----------------------------- //
		private function onCameraMoved(e:SSPEvent):void {
			if (!main.sessionView) return;
			updateDisc();
		}
		private function updateDisc():void {
			if (!objDisc) return;
			objDisc.lookAt(main.sessionView.camController.cameraPos);
			objDisc.rotationY -= this.rotationY; // Compensate main container rotationY.
			objDisc.rotationX = 0;
		}
		public function get teamPlayerId():String {
			return objSettingsRef._teamPlayerId;
		}
		public function set teamPlayerId(value:String):void {
			if (!value) value = "";
			objSettingsRef._teamPlayerId = value;
		}
		public function get teamPlayer():Boolean {
			return objSettingsRef._teamPlayer;
		}
		public function get teamPlayerEmpty():Boolean {
			return objSettingsRef._teamPlayerEmpty;
		}
		public function get teamSide():String {
			return objSettingsRef._teamSide;
		}
		
		public function updateTeamSettings():void {
			if (!objDisc) {
				objContainer.visible = true;
				return;
			}
			objSettingsRef._playerNameFormat = sScreen.playerNameFormat.toString();
			objSettingsRef._playerModelFormat = sScreen.playerModelFormat.toString();
			if (sScreen.playerDisplayModel) {
				objContainer.visible = true;
				objDisc.displayDisc = false;
			} else {
				objContainer.visible = false;
				objDisc.displayDisc = true;
			}
			objDisc.displayName = sScreen.playerDisplayName;
			objDisc.displayNumber = sScreen.playerDisplayNumber;
			objDisc.displayPosition = sScreen.playerDisplayPosition;
			objDisc.updateDisc();
			updateDisc();
		}
		
		public function clearTeamData():void {
			objSettingsRef.clearTeamData();
			objDisc.displayName = false;
			objDisc.displayNumber = false;
			objDisc.displayPosition = false;
			objDisc.updateDisc();
		}
		
		public function getTeamPlayerData():Object {
			var newTeamData:Object = {
				playerGivenName:objSettingsRef._playerGivenName,
				playerFamilyName:objSettingsRef._playerFamilyName,
				playerNumber:objSettingsRef._playerNumber,
				playerPositionId:objSettingsRef._playerPositionId,
				teamPlayerId:objSettingsRef._teamPlayerId,
				teamPlayer:objSettingsRef._teamPlayer
			};
			return newTeamData;
		}
		public function setTeamPlayerData(newTeamData:Object):void {
			if (!newTeamData) {
				clearTeamData();
				updateTeamSettings();
				return;
			}
			objSettingsRef._playerGivenName = newTeamData.playerGivenName;
			objSettingsRef._playerFamilyName = newTeamData.playerFamilyName;
			objSettingsRef._playerNumber = newTeamData.playerNumber;
			objSettingsRef._playerPositionId = newTeamData.playerPositionId;
			objSettingsRef._teamPlayerId = newTeamData.teamPlayerId;
			objSettingsRef._teamPlayer = newTeamData.teamPlayer;
			updateTeamSettings();
		}
		
		public function get highlightTeamPlayer():Boolean {
			return _highlightTeamPlayer;
		}
		public function set highlightTeamPlayer(h:Boolean):void {
			if (h && _highlightTeamPlayer) return;
			if (!objContainer) return;
			_highlightTeamPlayer= h;
			objContainer.ownCanvas = _highlightTeamPlayer;
			objContainer.filters = (_highlightTeamPlayer)? aTeamCollisionGlow : new Array();
			if (objDisc) objDisc.highlightDisc = _highlightTeamPlayer;
		}
		// -------------------------- End of Team Settings ------------------------- //
		
		
		
		// ----------------------------- Player Collision ----------------------------- //
		public override function startDrag(from2D:Boolean = true):void {
			oldPos = (from2D)? null : this.position;
			pCol.startTeamCollisionDetection();
			super.startDrag(from2D);
		}
		
		protected override function stopDrag(callNotifyDrop:Boolean):void {
			//pCol.stopTeamCollisionDetection();
			super.stopDrag(callNotifyDrop);
		}
		// -------------------------- End of Player Collision ------------------------- //
		
		
		
		protected override function get objSettings():SSPObjectBaseSettings {
			return objSettingsRef;
		}
		protected override function updateObjSettings():SSPObjectBaseSettings {
			super.updateObjSettings();
			if (!objSettingsRef) return null;
			//objSettingsRef._elevationNumber = this.elevationNumber; // Done in base class Equipment.
			objSettingsRef._accessories = enabledAccessoriesString;
			return objSettingsRef;
		}
		
		public override function dispose():void {
			teamPlayerId = "";
			pCol.dispose();
			deleteAccessories();
			if (objDisc) objDisc.dispose();
			super.dispose();
			
			objDisc = null;
			objSettingsRef = null;
			objMaterial = null;
			bodyTexture = null // Stores the main texture (skin, hair, shoes).
			playerKit = null;
			speedChute = null;
		}
	}
}