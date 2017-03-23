package src3d.lines
{
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.CurveLineSegment;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;
	
	import src3d.ButtonSettings;
	import src3d.SSPEvent;
	import src3d.SessionScreen;
	import src3d.models.SSPObjectBase;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.utils.LineUtils;
	import src3d.utils.Logger;
	
	public class LineBase extends SSPObjectBase
	{
		protected var objSettingsRef:LineSettings = new LineSettings(); // From <line> XML, if some value = -1, use <lines_library> to populate lineCurrentSettings.
		protected var lineCurrentSettings:LineSettings = new LineSettings(); // Current settings to work with.
		protected var linePathData:Path = new Path();
		
		// Lines.
		protected var mainLineMesh:Mesh;
		protected var refLineMesh:Mesh;
		
		protected var refLineMat:WireframeMaterial;
		protected var lineMat:ColorMaterial;
		protected var lineShadowMat:ColorMaterial;
		protected var selectedFX:GlowFilter;
		protected var aCurves:Vector.<CurveLineSegment> = new Vector.<CurveLineSegment>();
		
		protected var containerPos:Vector3D = new Vector3D(0,0,0);
		protected var lineThickness:int; // See LineSettings.getLineWidth();
		protected var lineAlpha:Number = 1;
		protected var useBorder:Boolean;
		protected var useArrowHead:Boolean = true;
		
		// Handles.
		protected var aHandles:Vector.<LineHandle> = new Vector.<LineHandle>; // Stores the line handles.
		protected var selectedHandle:LineHandle; // Selected Control Point.
		protected var newPos3D:Vector3D;
		
		protected var logger:Logger = Logger.getInstance();
		
		public function LineBase(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings)
		{
			objSettingsRef = objSettings as LineSettings;
			super(sessionScreen, objSettings);
			objSettingsRef.clone(lineCurrentSettings); // Clone of objSettings into objSettingsRef.
			lineCurrentSettings._objectType = ObjectTypeLibrary.OBJECT_TYPE_LINE; // The type of object, used for xml storing and array classification.
			this.name = LineLibrary.NAME_LINE;
			
			// Properties
			this._selectable = true;
			this._rotable = false; // Can't be rotated with line controls (at the moment).
			this._useShadow = false; // Use line shadow.
			this._scalable = false; // Can't be scaled with line controls (at the moment).
			this._repeatable = false; // Can't repeat itself in a path.
			this._clonable = true; // Object Clonner can place individual clones on pitch.
			this._colorable = false; // Color is applied from line settings.
			
			this.useBorder = false;
			
			// Init.
			//initMaterials(); // Started from extending classes
			//init2DButtons(); // Started from extending classes
			initLineCurrentSettings();
			initListeners();
			initMainLineMesh();
			initDragDropTarget();
			//this.debugbb = true;
		}
		
		
		
		// ------------------------------- Inits ------------------------------- //
		/**
		 * Initializes the main mesh (can be a line or a plane).
		 * Override in extending classes. 
		 */
		protected function initMainLineMesh():void {
			mainLineMesh = new Mesh();
		}
		
		protected override function initDragDropTarget():void {
			dragDropTarget = mainLineMesh;
			dragDropContainer = this;
		}
		
		/**
		 * Dispatches the event to enable/disable the custom button (eg: Player's Custom Kit button) in the 2D toolbar.
		 * This fuction is empty to be overwritten by the extending class. 
		 */		
		protected override function init2DButtons():void {
			if (this._clonable) {
				// Set Item Cloning.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ITEM_CLONE, true, 0, this, false));
			}
			if (this._colorable) {
				// Set Equipment Colors.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_EQUIP_COLOR, true, 0, this, false));
			}
			if (this.useArrowHead) {
				// Set Arrow Head Position.
				vBtnSettings.push(new ButtonSettings(ButtonSettings.CTRL_CUSTOM_ARROWHEAD_POS, true, objSettingsRef._useArrowHead, {arrowPos:lineCurrentSettings._useArrowHead}, false));
			}
		}
		
		private function initLineCurrentSettings():void {
			var strLibraryId:String = objSettingsRef._libraryId.toString();
			var lineLibrary:XMLList = src3d.SessionGlobals.getInstance().sessionDataXML.session.lines_library.(_linesLibraryId == strLibraryId);
			
			lineCurrentSettings._libraryId = objSettingsRef._libraryId;
			lineCurrentSettings._lineStyle = (objSettingsRef._lineStyle == -1)? int(lineLibrary._lineStyle.text()) : objSettingsRef._lineStyle;
			lineCurrentSettings._lineType = (objSettingsRef._lineType == -1)? int(lineLibrary._lineType.text()) : objSettingsRef._lineType;
			lineCurrentSettings._lineColor = (objSettingsRef._lineColor == -1)? int(lineLibrary._lineColor.text()) : objSettingsRef._lineColor;
			lineCurrentSettings._lineThickness = (objSettingsRef._lineThickness == -1)? int(lineLibrary._lineThickness.text()) : objSettingsRef._lineThickness;
			lineCurrentSettings._useArrowHead = (objSettingsRef._useArrowHead == -1)? int(lineLibrary._useArrowHead.text()) : objSettingsRef._useArrowHead;
			lineCurrentSettings._arrowThickness = (objSettingsRef._arrowThickness == -1)? int(lineLibrary._arrowThickness.text()) : objSettingsRef._arrowThickness;
			lineCurrentSettings._useHandles = (objSettingsRef._useHandles == "-1")? String(lineLibrary._useHandles.text()) : String(objSettingsRef._useHandles); // String.
			lineCurrentSettings._pathData = objSettingsRef._pathData; // String (see this.linePathData();).
			//lineCurrentSettings._pathCommands = "0"; // Not Used in this version.
			
			lineThickness = lineCurrentSettings.getLineWidth();
		}
		
		protected function initMaterials():void {
			refLineMat = new WireframeMaterial(lineCurrentSettings._lineColor, {thickness:lineThickness/2});
			lineMat = new ColorMaterial(lineCurrentSettings._lineColor, {alpha:lineAlpha});
			lineShadowMat = new ColorMaterial(0x000000);
			lineShadowMat.alpha = .3;
			selectedFX = new GlowFilter(0xFFFF99,1,5,5,4);
		}
		
		private function initListeners():void {
			// See lines.as
			sspEventHandler.addEventListener(SSPEvent.LINE_UPDATE_DEFAULT_SETTINGS, updateDefaultSettings);
		}
		// ----------------------------- End Inits ----------------------------- //
		
		
		
		// ----------------------------- Mouse ----------------------------- //
		protected override function onDragDropTargetMouseDown(e:MouseEvent3D):void {
			super.onDragDropTargetMouseDown(e);
			handlesVisible(false);
		}
		
		protected override function disableMouse():void {
			main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHPMouseMove);
			super.disableMouse();
		}
		protected override function onSSPObjectStageMouseUp(e:MouseEvent):void {
			if (this._selected) {
				updateLinePosition(); // Includes repositionHandles().
				handlesVisible(true);
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DROP_OBJECT, this));
			} else {
				super.onSSPObjectStageMouseUp(e);
			}
		}
		protected override function onSSPObjectStageMouseLeave(e:Event):void {
			if (this._selected) {
				updateLinePosition(); // Includes repositionHandles().
				handlesVisible(true);
			} else {
				super.onSSPObjectStageMouseLeave(e);
			}
		}
		
		protected override function stopDrag(callNotifyDrop:Boolean):void {
			super.stopDrag(callNotifyDrop);
			main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHPMouseMove);
		}
		// --------------------------- End Mouse --------------------------- //
		
		
		
		// ----------------------------- Drawing ----------------------------- //
		/**
		 * Draws a new Line or Area, depending on the extending class.
		 * * Override in extending classes.
		 * @param newPath
		 */
		public function drawLine(newPath:Path):void {}
		/**
		 * Override in extending classes.
		 */
		protected function updateLine():void {}
		/**
		 * Override in extending classes.
		 */
		public function drawRefLine(newPath:Path):void {drawLine(newPath);}
		/**
		 * Override in extending classes.
		 */
		protected function updateRefLine():void {updateLine();}
		// --------------------------- End Drawing --------------------------- //
		
		
		
		// ----------------------------- Selecting ----------------------------- //
		/**
		 * Change the 'selected' state of the object. 
		 * @param s (Selected) True to mark and display the object as selected. Otherwise set it to false.
		 */		
		public override function set selected(s:Boolean):void {
			if (linePathData.length <= 0) {
				trace("Error: Line not selected (path = 0)");
				//sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.LINE_EDITING, true));
				return;
			}
			if (!this._selectable) {
				trace(this.name+" is not selectable.");
				return;
			}
			if (s) {
				if (!sspObjEnabled) return;
				_selected = s;
				trace(this.name+" selected: "+s+". Pos: "+this.position);
				activate2DButtons(true);
				lineHighlight(true);
				handlesVisible(true);
				bringHandlesToFront();
			}else if (!s && _selected == true) {
				trace(this.name+" selected: "+s+". Pos: "+this.position);
				lineHighlight(false);
				handlesVisible(false);
				//activate2DButtons(false); // Do not dispatch. Conflicts if other line is selected.
				_selected = s;
			}
		}
		
		/**
		 * Override in extending classes. 
		 */
		protected function updateLinePosition(newPos:Vector3D = null):void {
			repositionHandles();
		}
		
		/**
		 * Override in extending classes. 
		 */
		public function moveLineTo(newPos:Vector3D):void {
			handlesVisible(false);
		}
		
		/**
		 * Override in extending classes. 
		 */
		public function get areaBounds():AreaBounds {
			var lb:AreaBounds = new AreaBounds();
			return lb;
		}
		// --------------------------- End Selecting --------------------------- //
		
		
		
		// ----------------------------- Handles ----------------------------- //
		protected function bringHandlesToFront():void {
			if (lineCurrentSettings._useHandles == "TRUE") {
				for each(var h:LineHandle in aHandles) {
					h.pushfront = true;
				}
			}
		}
		
		protected function updateHandles():void {
			if (lineCurrentSettings._useHandles == "TRUE") {
				if (aHandles.length == 0) {
					createHandles();
				} else {
					repositionHandles();
				}
			}
		}
		
		protected function createHandles():void {
			var cmd:Vector.<PathCommand> = linePathData.aSegments;
			var hP1:LineHandle;
			var hP2:LineHandle;
			var idx:int = 0;
			
			aHandles = new Vector.<LineHandle>;
			
			// Create the Start control point.
			hP1 = new LineHandle(idx, HandleLibrary.P_START);
			if (cmd.length != 0) {
				hP1.x = cmd[0].pStart.x;
				hP1.y = cmd[0].pStart.y+1;
				hP1.z = cmd[0].pStart.z;
			}
			//hP1.addEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown, false, 0, true);
			aHandles.push(hP1);
			this.addChild(hP1);
			hP1.pushfront = true;
			// Create middle control points if any (use pEnd position).
			// --
			// Create the End control point.
			idx++;
			hP2 = new LineHandle(idx, HandleLibrary.P_END);
			if (cmd.length != 0) {
				hP2.x = cmd[cmd.length-1].pEnd.x;
				hP2.y = cmd[cmd.length-1].pEnd.y+1;
				hP2.z = cmd[cmd.length-1].pEnd.z;
			}
			//hP2.addEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown, false, 0, true);
			aHandles.push(hP2);
			this.addChild(hP2);
			hP2.pushfront = true;
			
			handlesToggleListeners(true);
		}
		protected function repositionHandles():void {
			if (!aHandles || aHandles.length == 0) return;
			//trace("repositionHandles");
			var cmd:Vector.<PathCommand> = linePathData.aSegments;
			if (cmd != null && aHandles.length > 0) {
				// Reposition handles.
				aHandles[0].x = cmd[0].pStart.x;
				aHandles[0].y = cmd[0].pStart.y+1;
				aHandles[0].z = cmd[0].pStart.z;
				aHandles[0].pushfront = true;
				aHandles[1].x = cmd[cmd.length-1].pEnd.x;
				aHandles[1].y = cmd[cmd.length-1].pEnd.y+1;
				aHandles[1].z = cmd[cmd.length-1].pEnd.z;
				aHandles[1].pushfront = true;
			}
		}
		protected function removeHandles():void {
			selectedHandle = null;
			handlesToggleListeners(false);
			for each(var hP:LineHandle in aHandles) {
				hP.removeEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown);
				hP.dispose();
				hP = null;
			}
		}
		
		protected function handlesVisible(hVisible:Boolean):void {
			var h:LineHandle;
			if (hVisible) {
				if (lineCurrentSettings._useHandles == "TRUE") {
					updateHandles();
					for each(h in aHandles) {
						h.visible = true;
						h.pushfront = true;
					}
				}
			} else {
				for each(h in aHandles) {
					h.visible = false;
				}
			}
			handlesToggleListeners(hVisible);
		}
		
		protected function handlesToggleListeners(lEnabled:Boolean):void {
			if (lEnabled) handlesToggleListeners(false);
			for each(var h:LineHandle in aHandles) {
				if (lEnabled) {
					if (!h.hasEventListener(MouseEvent3D.MOUSE_DOWN))
						h.addEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown);
				} else {
					h.removeEventListener(MouseEvent3D.MOUSE_DOWN, onHPMouseDown);
				}
			}
			main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHPMouseMove);
			main.stage.removeEventListener(MouseEvent.MOUSE_UP, onHPStageMouseUp);
		}
		
		protected function onHPMouseDown(e:MouseEvent3D):void {
			// Get the selected Handle array index, it's the same than the aSegment index.
			selectedHandle = e.target as LineHandle;
			if (selectedHandle.handleIndex < 0) return;
			
			handlesVisible(false); // hides handles and remove listeners.
			main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onHPMouseMove);
			main.stage.addEventListener(MouseEvent.MOUSE_UP, onHPStageMouseUp);
			drag3d.object3d = null;
			drag3d.removeOffsetCenter();
			// Listen if SessionView orders to cancel all edits.
			sspEventHandler.addEventListener(SSPEvent.CONTROL_CANCEL, onCancelEditMode, false, 0, true);
			toggleEditMode(true);
		}
		
		/**
		 * Override in extending classes. 
		 */
		protected function onHPMouseMove(e:MouseEvent):void {
			
		}
		
		protected function onHPStageMouseUp(e:MouseEvent):void {
			cancelEdit();
		}
		// --------------------------- End Handles --------------------------- //
		
		
		
		protected function onCancelEditMode(e:SSPEvent):void {
			cancelEdit();
		}
		
		protected function cancelEdit():void {
			trace("DynamicLine.cancelEdit()");
			// Stop handles, redraw final line.
			//handlesVisible(false);
			toggleDragMode(false);
			toggleEditMode(false);
			//this.updateLine(true);
			if (main.stage.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onHPMouseMove);
			}
			this.updateLine();
			this.selected = this._selected;
		}
		
		
		
		
		private function updateDefaultSettings(e:SSPEvent):void {
			trace("updateDefaultSettings");
			var lineId:int = e.eventData;
			if (objSettingsRef._libraryId == lineId) {
				initLineCurrentSettings();
				initMaterials();
				updateLine();
			}
		}
		
		public function updateSingleLineSettings(e:SSPEvent):void {
			trace("updateSingleLineSettings");
			objSettingsRef._useArrowHead = e.eventData;
			initLineCurrentSettings();
			updateLine();
		}
		
		public function changeMainColor(newColor:uint):void {
			if (objSettingsRef._lineColor == newColor || !this._colorable) return;
			objSettingsRef._lineColor = newColor;
			initLineCurrentSettings();
			initMaterials();
			updateLine();
		}
		
		protected function lineHighlight(highlight:Boolean):void {
			trace("lineHighlight: "+highlight);
			// When the line drawing has started, there is no extrudedLine, so we check it also.
			mainLineMesh.filters = [];
			if (highlight) {
				mainLineMesh.y = 0;
				mainLineMesh.ownCanvas = true;
				mainLineMesh.filters = [selectedFX];
				//extrudedLineSelect.y = extrudedLine.y+.05;
			} else {
				//extrudedLineSelect.y = extrudedLine.y+.05;
				mainLineMesh.y = 0;
				mainLineMesh.ownCanvas = false;
				mainLineMesh.filters = [];
			}
		}
		
		protected override function get objSettings():SSPObjectBaseSettings {
			return lineCurrentSettings;
		}
		protected override function updateObjSettings():SSPObjectBaseSettings {
			super.updateObjSettings();
			lineCurrentSettings._pathData = LineUtils.pathDataToString(linePathData);
			objSettingsRef._pathData = lineCurrentSettings._pathData;
			return lineCurrentSettings;
		}
		
		public function get pathData():Path {
			return linePathData;
		}
		
		public override function dispose():void {
			this.selected = false;
			
			removeHandles();
			
			// Remove ref lines.
			if (refLineMesh) this.removeChild(refLineMesh);
			
			// Clear reference line.
			for(var i:int = 0;i<aCurves.length;++i) {
				aCurves[i] = null;
				this.removeChild(aCurves[i]);
			}
			
			super.dispose();
			
			objSettingsRef = null;
			lineCurrentSettings = null;
			linePathData = null;
			
			aHandles = null;
			selectedHandle = null;
			newPos3D = null;
			containerPos = null;
			
			refLineMesh = null;
			aCurves = null;
			refLineMat = null;
			lineMat = null;
			lineShadowMat = null;
			selectedFX = null;
		}
	}
}