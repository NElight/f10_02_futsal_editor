package src3d.models
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.RegularPolygon;
	
	import flash.geom.Vector3D;
	
	import src3d.ButtonSettings;
	import src3d.SessionScreen;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.equipment.EquipmentLibrary;
	import src3d.models.soccer.equipment.EquipmentSettings;
	import src3d.utils.ColorUtils;
	import src3d.utils.LineUtils;
	import src3d.utils.MiscUtils;
	import src3d.utils.ModelUtils;
	
	public class Equipment extends SSPObjectBase {
		
		public static const RESIZE_BLOCK_NONE:String	= "";
		public static const RESIZE_BLOCK_X:String		= "X";
		public static const RESIZE_BLOCK_Y:String		= "Y";
		public static const RESIZE_BLOCK_Z:String		= "Z";
		public static const RESIZE_BLOCK_XY:String		= "XY";
		public static const RESIZE_BLOCK_XZ:String		= "XZ";
		public static const RESIZE_BLOCK_YZ:String		= "YZ";
		
		private var objSettingsRef:EquipmentSettings;
		protected var accessories:Array = [];
		protected var enabledAccessories:Array = [];
		public var pathData:Path = new Path();
		protected var _color1:uint;
		protected var _color1default:uint;
		protected var _color2:uint;
		protected var _color2default:uint;

		protected var centralDisc:RegularPolygon; // Control Base container.
		protected var centralDiscInitialScale:Number = 1;
		protected var shadow:Shadow;
//		protected var aShadows:Vector.<Shadow> = new Vector.<Shadow>(); // Array of shadows.
		protected var _rotator:Rotator;
		private var _objRotateWithMouse:Boolean = false;
		protected var repeater:SSPObjectRepeater;
		
		protected var objectSet:Array = [];
		protected var _internalScale:Number; // Scale factor for the embeded 3d files.
		
		protected var minYPos:Number = 1;
		protected var maxYPos:Number = 70;
		protected var yPosOffset:Number = 0; // Corrects object adjustments like football radius.
		protected var _elevationDefault:Number = 0; // Some objects are elevated by default, like jumping players.
		protected var _elevationNumber:Number = 0;
		protected var _mainContainerHeight:Number; // To place objects on top like the repeater handle.
		
		public var aSizeRatios:Array;
		public var minSize = .5;
		public var maxSize = 2;
		protected var _sizeDefault:Number; // The initial object size (scale) of new objects.
		protected var _size:Number = 1;
		protected var resizeBlockAxis:String = RESIZE_BLOCK_NONE;
		
		public function Equipment(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings) {
			objSettingsRef = objSettings as EquipmentSettings;
			super(sessionScreen, objSettings);
			objSettingsRef._objectType = ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT; // The type of object, used for xml storing and array classification.
			
			// Properties.
			this._internalScale = 1; // Corrects the scale proportions of each child object.
			if (objSettingsRef._equipColor > -1) {
				_color1 = _color1default = objSettingsRef._equipColor;
			} else {
				objSettingsRef._equipColor = -1;
				_color1 = _color1default;
			}
			
			initcentralDisc();
			//init2DButtons(); // Use only in extending classes.
			//initRotator(); // Use only in extending classes.
			//initObjectRepeater(objSettingsRef._pathData); // Use only in extending classes.
			//initAccessories(enableAccessories); // Use only in extending classes.
			//initElevation(); // Use only in extending classes.
			//applyGlobalScale(); // Use only in extending classes.
			this.useShadow = true;
			this.ownCanvas = false; // Needs own canvas true before being deleted or it will throw an error when removing.
			_rotator = new Rotator(this, drag3d);
		}
		
		
		
		// ------------------------------- Inits ------------------------------- //
		protected override function initShadow():void {
			shadow = new Shadow();
		}
		
		/**
		 * Creates the control point (a circle in the base of the object).
		 */		
		private function initcentralDisc():void {
			// Create Control Base.
			centralDisc = new RegularPolygon({sides:16, radius:40, material:new ColorMaterial(0xffffff, {alpha:0.6}), visible:false, ownCanvas:true, name:"centralDisc"});
			this.mainContainer.addChild(centralDisc);
			//this.useHandCursor = true;
			//this.mouseEnabled = true;
		}
		
		public function initRotator():void {
			if (_rotable) {
				this.addChild(_rotator);
				_rotator.rotatorEnabled = false;
				if (_rotable) this.rotationY = objSettings._rotationY;
			}
		}
		
		/**
		 * Dispatches the event to enable/disable the custom button (eg: Player's Custom Kit button) in the 2D toolbar.
		 * This fuction is empty to be overwritten by the extending class. 
		 */		
		protected override function init2DButtons():void {
			if (this._colorable) {
				// Set Equipment Colors.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_EQUIP_COLOR, true, 0, this, false));
			}
			if (this._elevatable) {
				// Set Item Elevation.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_ELEVATION, true, 0, this, false));
			}
			if (this._resizable && maxSize-minSize>0) {
				// Set Item Resize.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_SIZE, true, 0, this, false));
			}
			if (this._clonable) {
				// Set Item Cloning.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_CLONE, true, 0, this, false));
			}
			if (this._transparentable) {
				// Set Item Transparency.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_TRANSPARENCY, true, 0, this, false));
			}
		}
		
		protected function initObjectRepeater(pdStr:String, maxSpace:Number = 100, maxFullDistance:Number = 1000, objAxis:String = SSPObjectRepeater.AXIS_Z):void {
			if (!this._repeatable) return;
			pathData = LineUtils.stringToPathDataNew(pdStr);
			fixPathData(); // Trim if needed.
			repeater = new SSPObjectRepeater(this, sScreen.drag3d, maxSpace, maxFullDistance, objAxis);
			repeater.startRepeater();
		}
		
		// Overriden by extending classes (eg: Player.as).
		protected function initAccessories():void {};
		
		protected function initElevation():void {
			if (this._elevatable) {
				getElevationDefault();
				if (!isNaN(objSettingsRef._elevationNumber)) {
					elevationNumber = objSettingsRef._elevationNumber;
				} else {
					resetElevation();
				}
				this.sspPosition = objSettings._objPos;
			}
		}
		
		protected function initSize():void {
			if (isNaN(objSettingsRef._size) || objSettingsRef._size < minSize || objSettingsRef._size > maxSize) {
				//Logger.getInstance().addAlert("Incorrect size for this "+this.name+" ("+String(objSettingsRef._size)+"). Using default.");
				objSettingsRef._size = this.sizeDefault;
			}
			if (this._resizable) {
				if (!isNaN(objSettingsRef._size)) {
					this.size = objSettingsRef._size;
				} else {
					resetSize();
				}
				//this.sspSize = objSettings._objSize;
			}
		}
		// ----------------------------- End Inits ----------------------------- //
		
		
		/**
		 * Change the 'selected' state of the object. 
		 * @param s (Selected) True to mark the object as selected. Otherwise set it to false.
		 */		
		public override function set selected(s:Boolean):void {
			if (this._selectable) {
				if (s) {
					if (!sspObjEnabled) return;
					_selected = s;
					//trace(this.name+" Selected");
					activate2DButtons(true);
					centralDisc.visible = true;
					shadowEnabled(false);
					if (_rotable) _rotator.rotatorEnabled = true;
					if (_repeatable && repeater) {repeater.repeaterEnabled(true);}
				}else {
					_selected = s;
					//trace(this.name+" DeSelected");
					//activate2DButtons(false); // Do not dispatch. Conflicts if other equipment is being selected at the same time.
					centralDisc.visible = false;
					_rotator.rotatorEnabled = false;
					shadowEnabled(true);
					if (_repeatable && repeater) {repeater.repeaterEnabled(false);}
				}
			} else {
				//trace(this.name+" is not selectable.");
				//trace(this.name+" DeSelected");
//				activate2DButtons(false);
				centralDisc.visible = false;
				shadowEnabled(true);
			}
		}
		
		public function getGlobalScale():Number {
			return mainContainer.scaleX;
		}
		
		protected function updateInternalScale(objContainer:ObjectContainer3D):void {
			ModelUtils.changeScaleInMesh(objContainer, _internalScale);
		}
		
		protected function set controllerScale(newScale:Number):void {
			_rotator.scale(newScale);
			this.centralDiscScale = newScale;
		}

		/**
		 * Changes the scale of the controller base. 
		 * @param _scl Number.
		 * 
		 */		
		protected function set centralDiscScale(newScale:Number):void {
			centralDisc.scale(newScale);
			centralDiscInitialScale = newScale;
		}
		
		/**
		 * Indicates if this object will have a shadow. 
		 * @param us Boolean.
		 * 
		 */		
		public override function set useShadow(us:Boolean):void {
			_useShadow = us;
			shadowEnabled(_useShadow);
		}
		private function shadowEnabled(en:Boolean):void {
			if (!_useShadow) return;
			/*for each (var s:Shadow in aShadows) {
				s.visible = _useShadow;
			}*/
		}
		private function resetShadowPos():void {
			if (!_useShadow) return;
			if (!shadow || !shadow.parent) return;
			// If objContainer is rotated, use Z axis.
			if (shadow.parent.rotationX == 90) {
				shadow.z = -shadow.parent.y;
			} else if (shadow.parent.rotationX == -90) {
				shadow.z = +shadow.parent.y;
			} else {
				shadow.y = -shadow.parent.y;
			}
		}
		
		public function toggleFlipH():void {
			if (!objSettingsRef._flipH) {
				flipH(true);
			} else {
				flipH(false);
			}
		}
		
		public function flipH(f:Boolean):void {
			if (!_flipable) return;
			var p:Object;
			var obj3d:Object3D;
			var mesh:Mesh
			objSettingsRef._flipH = f;
			if (objSettingsRef._flipH) {
				for each(p in objectSet) {
					p.scaleY *= -1;
					p.rotationY += 180;
					
					//var explode:Explode = new Explode();
					//explode.apply(p);
					//Mirror.apply(p, "x",false,false,true,true);
					
					// Enable both sides for the textured meshes.
					for each(obj3d in p.children) {
						mesh = obj3d as Mesh;
						if (mesh != null) mesh.bothsides = true;
					}
				}
			} else {
				// FlipH back only if it has been flipped already.
				if (objectSet[0].scaleY < 0) {
					for each(p in objectSet) {
						p.scaleY *= -1;
						p.rotationY -= 180;	
					}
					// If not flipH, disable bothsides to save resources.
					for each(obj3d in p.children) {
						mesh = obj3d as Mesh;
						if (mesh != null) mesh.bothsides = false;
					}
				}
			}
		}
		
		// Overriden by extending classes (eg: Player.as).
		protected function setAccessoriesTransparency():void {};
		
		/**
		 * Override in extending classes (eg. Players) to use custom library info (eg. PlayerLibrary). 
		 */		
		protected function getElevationDefault():void {
			var modelIdx:int = src3d.utils.MiscUtils.indexInArray(EquipmentLibrary._aEquipment, "EquipmentId", objSettingsRef._libraryId);
			_elevationDefault = EquipmentLibrary._aEquipment[modelIdx].ElevationDefault;
		}
		
		protected function getSizeDefault():void {
			var modelIdx:int = src3d.utils.MiscUtils.indexInArray(EquipmentLibrary._aEquipment, "EquipmentId", objSettingsRef._libraryId);
			_sizeDefault = EquipmentLibrary._aEquipment[modelIdx].SizeDefault;
		}
		
		protected function enableAccessory(acc:String):void {
			if (acc == "" || acc == ",") return;
			if (enabledAccessories.indexOf(acc) != -1) return;
			enabledAccessories.push(acc);
		}
		protected function disableAccessory(acc:String):void {
			if (acc == "" || acc == "," || !hasAccessory(acc)) return;
			var idx:int = enabledAccessories.indexOf(acc); 
			if (idx == -1) return;
			enabledAccessories.splice(idx,1);
		}
		
		/**
		 * Delete all accessories to dispose the object.
		 * This function is overriden when needed in extending classes.
		 */
		protected function deleteAccessories():void {}
		
		public function hasAccessory(acc:String):Boolean {
			if (!accessories || accessories.length == 0) return false;
			return (accessories.indexOf(acc) != -1)? true :false;
		}
		public function hasAnyAccessory():Boolean {
			return (!accessories || accessories.length == 0)? false : true; 
		}
		
		/**
		 * Color textures and apply materials.
		 * This function is overriden when needed in extending classes.
		 */		
		protected function setMaterials():void {}
		
		public function changeMainColor(newColor:uint):void {
			if (this._color1 == newColor || !this._colorable) return;
			objSettingsRef._equipColor = _color1 = newColor;
			setMaterials();
		}
		
		public function resetColor():void {
			if (this._color1 == _color1default || !this._colorable) return;
			objSettingsRef._equipColor = -1;
			_color1 = _color1default;
			setMaterials();
		}
		
		// ------------------------------- Clicks and Drags ------------------------------- //
		override protected function enableMouse():void {
			super.enableMouse(); // Note that super calls disableMouse.
			if (sspObjEnabled && _selectable && _rotable) {
				_rotator.rotatorEnabled = true;
				_rotator.visible = false; // Listeners enabled, but rotator invisible until selected.
			}
		}
		override protected function disableMouse():void {
			super.disableMouse();
			if (!sspObjEnabled) {
				_rotator.rotatorEnabled = false;
			}
		}
		// ----------------------------- End Clicks and Drags ----------------------------- //
		
		
		
		public function set transparency(t:Boolean):void {
			objSettingsRef._transparency = t;
			ColorUtils.changeMaterialTransparency(objectSet, transparencyValue);
			setAccessoriesTransparency();
		}
		public function get transparency():Boolean { return objSettingsRef._transparency; }
		public function get transparencyValue():Number {
			var t:Number = (objSettingsRef._transparency)? sspObjTransparencyValue : 1;
			return t;
		}
		
		public function get enabledAccessoriesString():String {
			if (!enabledAccessories || enabledAccessories.length == 0) return "";
			return enabledAccessories.join(",");
		}
		
		public function get _equipColorHex():String {
			var ec:String = "-1";
			if (objSettingsRef._equipColor > -1) {
				//ec = "0x"+_equipColor.toString(16);
				ec = MiscUtils.getNumberAsHexString(objSettingsRef._equipColor);
			}
			return ec;
		}
		
		/**
		 * Changes the scale of the object container while keeping the scale of the objects inside of it. 
		 * @param _scl Number.
		 */		
		public function applyGlobalScale():void {
			if (!_scalable && !_resizable) return;
			//var gScale:Number = (_scalable)? sScreen.globalScaleNum * this.size : this.size;
			var gScale:Number = (_scalable)? sScreen.globalScaleNum : 1;
			var scaleXValue:Number = (resizeBlockAxis != RESIZE_BLOCK_X && resizeBlockAxis != RESIZE_BLOCK_XY && resizeBlockAxis !=RESIZE_BLOCK_XZ)? this.size : 1;
			var scaleYValue:Number = (resizeBlockAxis != RESIZE_BLOCK_Y && resizeBlockAxis != RESIZE_BLOCK_XY && resizeBlockAxis !=RESIZE_BLOCK_YZ)? this.size : 1;
			var scaleZValue:Number = (resizeBlockAxis != RESIZE_BLOCK_Z && resizeBlockAxis != RESIZE_BLOCK_XZ && resizeBlockAxis !=RESIZE_BLOCK_YZ)? this.size : 1;
			
			if (isNaN(gScale) || isNaN(this.size)) return;
			
			// centralDisc needs to be inside mainContainer to be draggable, but keeping the scale.
			var newCDScale:Number = centralDiscInitialScale / (gScale * this.size);
			centralDisc.scale(newCDScale);
			
			mainContainer.scaleX = gScale * scaleXValue;
			mainContainer.scaleY = gScale * scaleYValue;
			mainContainer.scaleZ = gScale * scaleZValue;
			if (_repeatable && repeater) repeater.updateRepeater(0, false);
			shadowEnabled(true);
		
			//controllerScale = gScale;
		}
		
		public function get sizeDefault():Number {
			if (!_sizeDefault) getSizeDefault();
			return _sizeDefault;
		}
		
		public function resetSize():void {
			this.size = this.sizeDefault;
		}
		
		public function set size(value:Number):void {
			if (isNaN(value)) return;
			if (_size == value) return;
			if (value >= minSize && value <= maxSize) {
				_size = value;
				applyGlobalScale();
			}
		}
		
		public function get size():Number {
			return _size;
		}
		
		protected function resetElevation():void {
			this.elevationNumber = _elevationDefault;
		}
		
		public function set elevationNumber(value:Number):void {
			if (isNaN(value)) return;
			if (_elevationNumber == value) return;
			if (value >= minYPos && value <= maxYPos) {
				_elevationNumber = value;
				for each(var p:Object in objectSet) {
					p.y = _elevationNumber;
				}
			}
			resetShadowPos();
		}
		
		public function get elevationNumber():Number {
			return _elevationNumber;
		}
		
		public function set elevationRatio(value:Number):void {
			if (!_elevatable) return;
			if (isNaN(value)) return;
			if (value < 0 && value > 1) return;
			var newElev:Number = minYPos + ((maxYPos - minYPos) * value);
			if (isNaN(newElev)) return;
			_elevationNumber = newElev;
			for each(var p:Object in objectSet) {
				p.y = _elevationNumber + yPosOffset;
			}
			resetShadowPos();
		}
		public function get elevationRatio():Number {
			return (_elevationNumber - yPosOffset) / (maxYPos - minYPos);
		}
		
		public function repeatObjects(objSpace:Number, maxDistance:Number):void {
			var i:uint;
			var startPoint:uint;
			var newPoints:Array = [];
			var newObjSpace:Number = objSpace;
			var newObjAmount:uint = (maxDistance/this.getGlobalScale()) / newObjSpace;
			
			if (newObjAmount+1 == objectSet.length) return;
			
			// Prepare clones positions.
			for (i = 0;i<=newObjAmount;i++) {
				newPoints.push(-newObjSpace*i);
			}
			
			// Remove all previous clones.
			for (i = 1;i<objectSet.length;i++) {
				this.mainContainer.removeChild(objectSet[i]);
				objectSet[i] = null;
			}
			objectSet.splice(1,objectSet.length-1);
			
			// If points amount is bigger, add new clones.
			if (newPoints.length > objectSet.length && newPoints.length > 1) {
				//for (i = objectSet.length;i<newPoints.length;i++) {
				for (i = 1;i<newPoints.length;i++) {
					this.objectSet.push(objectSet[0].clone());
					objectSet[i].z = newPoints[i];
					this.mainContainer.addChild(objectSet[i]);
				}
			}
		}
		
		private function fixPathData():void {
			if (!pathData) pathData = new Path();
			if (pathData.length == 0) pathData.add(new PathCommand(PathCommand.LINE, new Vector3D(), new Vector3D(), new Vector3D()));
			// Equipment pathData should only have one path command.
			if (pathData.length > 1) {
				trace("Error: Equipment pathData too long. Trimmed.");
				//pathData.aSegments.splice(1,pathData.aSegments.length);
				try {
					pathData = new Path([
						pathData.aSegments[0].pStart,
						pathData.aSegments[0].pControl,
						pathData.aSegments[0].pEnd
					]);
				} catch (error:Error) {
					trace(error.message);
					trace("Using a blank path");
					// If there is an error with the existing data, create a new path.
					pathData = new Path();
					pathData.add(new PathCommand(PathCommand.LINE, new Vector3D(), new Vector3D(), new Vector3D()));
				}
			}
		}
		
		/**
		 * Session Data. 
		 * @return A <code>String</code> of <code>Path</code> commands.
		 */		
		public function get pathDataString():String {
			var lString:String = "";
			if (!pathData || pathData.length == 0) return "";
			// If path distance == 0, return an empty string to save database space.
			var pDistance:Number = Vector3D.distance(
				pathData.aSegments[0].pStart,
				pathData.aSegments[0].pEnd
				);
			if (pDistance != 0) {
				fixPathData();
				lString = LineUtils.pathDataToString(pathData, true);
			}
			return lString;
		}
		
		public function get mainContainerHeight():Number {
			if (isNaN(_mainContainerHeight)) _mainContainerHeight = 100;
			return _mainContainerHeight * mainContainer.scaleX;
		}
		
		public function get repeatable():Boolean {return _repeatable;}
		
		public function get rotator():Rotator {return _rotator;}
		
		public function get centralDiscRadius():Number {
			if (!centralDisc) return 0;
			return centralDisc.radius * centralDiscInitialScale * getGlobalScale();
		}
		
		protected override function get objSettings():SSPObjectBaseSettings {
			return objSettingsRef;
		}
		protected override function updateObjSettings():SSPObjectBaseSettings {
			super.updateObjSettings();
			if (!objSettingsRef) return null;
			objSettingsRef._elevationNumber = this.elevationNumber;
			objSettingsRef._size = this.size;
			objSettingsRef._pathData = this.pathDataString;
			return objSettingsRef;
		}
		
		public override function dispose():void {
			if (repeater) repeater.dispose();
			if (_rotator) _rotator.dispose();
			if (centralDisc) centralDisc.material = null;
			if (shadow) shadow.dispose();
			super.dispose();
			
			objSettingsRef = null
			repeater = null;
			_rotator = null;
			objectSet = [];
			accessories = [];
			enabledAccessories = [];
			pathData = null;
			centralDisc = null;
			shadow = null;
		}
	}
}