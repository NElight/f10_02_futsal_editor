package src3d.lines
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.events.MouseEvent3D;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.SSPCursors;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.SessionView;
	import src3d.utils.Dragger;
	import src3d.utils.LineUtils;
	import src3d.utils.Logger;
	
	public class LineCreator
	{
		private var sLine:LineBase; // Selected Line.
		private var path:Path;
		private var sScreen:SessionScreen;
		private var sessionView:SessionView;
		private var drag3d:Dragger;
		private var pitchContainer:ObjectContainer3D;
		
		private var drawing:Boolean = false;
		private var customDrawing:Boolean = false; // Predefined or Hand made.
		private var multiple:Boolean = false;
		
		// Drawing vars.
		private var lCount:int = 0; // Line Counter used for rename the lines.
		private var newPos3D:Vector3D;
		private var oldPos3D:Vector3D;
		
		// Start Global Vars.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sD:XML = sG.sessionDataXML;
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		public function LineCreator(sessionScreen:SessionScreen)
		{
			this.sScreen = sessionScreen;
			this.sessionView = sessionScreen.sessionView;
			this.drag3d = sessionScreen.drag3d;
		}
		
		public function drawLoadedLine(_lineSettings:LineSettings):LineBase {
			multiple = false;
			//trace("drawLoadedLine()");
			
			_lineSettings._pathData = LineSmoother.getInstance().trimPathDataString(_lineSettings._pathData); // Trim if necessary.
			
			if (_lineSettings._pathData == "") {
				logger.addAlert("Error Loading Line: empty _pathData. (ScreenId: "+_lineSettings._screenId+", LibraryId: "+_lineSettings._libraryId+"). Ignoring line");
				return null;
			}
			var p:Path = LineUtils.stringToPathData(_lineSettings._pathData);
			if (p == null) {
				logger.addAlert("Error Loading Line: invalid Path. (ScreenId: "+_lineSettings._screenId+", LibraryId: "+_lineSettings._libraryId+"). Ignoring line");
				return null;
			}
			if (p.length == 0) {
				logger.addAlert("Error Loading Line: invalid _pathData. (ScreenId: "+_lineSettings._screenId+", LibraryId: "+_lineSettings._libraryId+"). Ignoring line");
				return null;
			}
			if (LineUtils.getPathLength(p) == 0) {
				logger.addAlert("Error Loading Line: zero length line (ScreenId: "+_lineSettings._screenId+", LibraryId: "+_lineSettings._libraryId+"). Ignoring line");
				return null;
			}
			if (!sScreen.isPathOnPitch(p)) {
				logger.addAlert("Error Loading Line: _pathData not on pitch. (ScreenId: "+_lineSettings._screenId+", LibraryId: "+_lineSettings._libraryId+"). Ignoring line");
				return null;
			}
			
			if (!initLineContainer(_lineSettings._screenId, _lineSettings._libraryId, _lineSettings)) {
				logger.addAlert("Can't create line container. (ScreenId: "+_lineSettings._screenId+", LibraryId: "+_lineSettings._libraryId+"). Ignoring line");
				return null;
			}
			
			// LineSmoother.getInstance().smoothCustomLine(p); // Debug
			sLine.drawLine(p);
			sLine.name = "line"+lCount++;
			sLine.selected = false;
			return sLine;
		}
		
		public function drawLine(screenId:uint, lineId:int, multiple:Boolean = false):LineBase {
			//trace("drawLine()");
			this.multiple = multiple;
			
			if (!initLineContainer(screenId, lineId)) {
				logger.addAlert("Can't create line container.");
				return null;
			}
			if (!sLine) {
				logger.addAlert("Cannot create line.");
				return null;
			}
			
			// Change cursor.
			if (multiple) {
				SSPCursors.getInstance().setPin();
			} else {
				SSPCursors.getInstance().setCross();
			}
			sG.createMode = true;
			sG.camLocked = true;
			// Adds the listener for the reference line creation.
			sessionView.view.scene.addEventListener(MouseEvent3D.MOUSE_DOWN, startLineMouseDown, false, 0, false);
			sspEventDispatcher.addEventListener(SSPEvent.CONTROL_CANCEL, onDrawLineCancel, false, 0, true);
			drawing = true;
			
			sScreen.setupNewObject3D(sLine, false);
			
			return sLine;
		}
		
		private function initLineContainer(_screenId:uint, _lineId:int, _lineSettings:LineSettings = null):Boolean {
			//trace("Init container");
			var intLineType:uint;
			
			// If there is no _lineSettings, it means it's a new line, not loaded from server.
			if (_lineSettings == null) {
				_lineSettings = new LineSettings();
				_lineSettings._libraryId = _lineId;
				// Add _screenId and _onlyDefaultPitches.
				_lineSettings._screenId = _screenId;
				_lineSettings._onlyDefaultPitches = false;
			}
			
			if (_lineSettings._lineType == -1) {
				// Check <lines_default> to get line type.
				var lineIdStr:String = String(_lineId);
				var linesLibraryXML:XMLList = sD.session.lines_library.(_linesLibraryId == lineIdStr);
				if (linesLibraryXML.length() == 0) {
					logger.addAlert("Line with LineId "+_lineId+" not found in lines_library");
					return false;
				}
				intLineType = int(linesLibraryXML._lineType);
			} else {
				intLineType = _lineSettings._lineType;
			}
			
			// Create the specified line.
			drag3d.removeOffsetCenter();
			switch(intLineType) {
				/*case LineLibrary.TYPE_ELEVATED:
				sLine = new ElevatedLine(sScreen, _lineSettings);
				customDrawing = false;
				break;*/
				case LineLibrary.TYPE_GRID:
					sLine = new AreaBase(sScreen, _lineSettings);
					customDrawing = false;
					break;
				case LineLibrary.TYPE_CUSTOM:
					sLine = new CustomLine(sScreen, _lineSettings);
					customDrawing = true;
					break;
				default:
					sLine = new DynamicLine(sScreen, _lineSettings);
					customDrawing = false;
					break;
			}
			if (!sLine) return false;
			return true;
		}
		
		private function startLineMouseDown(e:MouseEvent3D):void
		{
			trace("startLineMouseDown");
			sessionView.view.scene.removeEventListener(MouseEvent3D.MOUSE_DOWN, startLineMouseDown);
			
			sG.createMode = true;
			sG.camLocked = true;
			oldPos3D = drag3d.getIntersect().clone();
			newPos3D = oldPos3D.clone();
			path = new Path();
			path.add(new PathCommand(PathCommand.MOVE, oldPos3D.clone(), oldPos3D.clone(), oldPos3D.clone()));
			
			sessionView.view.scene.addEventListener(MouseEvent3D.MOUSE_MOVE, lineMouseMove, false, 0, true);
			sessionView.stage.addEventListener(MouseEvent.MOUSE_UP, onLineMouseUp, false, 0, true);
			sessionView.stage.addEventListener(MouseEvent.CLICK, onStageMouseClick, false, 0, true);
		}
		
		private function lineMouseMove(e:MouseEvent3D):void	{
			//trace("areaMouseMove");
//			if (!sScreen.isPosOnPitch(newPos3D)) return;
			var valid:Boolean;
			var mPos:Vector3D = drag3d.getIntersect().clone();
			if (!customDrawing) {
				// Clear last command and add the new one.
				if (path.array.length > 1) {
					path.array.pop();
				}
				valid = true;
			} else {
				// Validate the segment length.
				if (Vector3D.distance(oldPos3D, mPos)>20) {
					valid = true;
					// If line is custom, update the last position.
					oldPos3D = newPos3D.clone();
				}
			}
			if (valid) {
				newPos3D = mPos.clone();
				path.add(new PathCommand(PathCommand.LINE, oldPos3D.clone(), oldPos3D.clone(), newPos3D.clone()));
				if (path && sLine) {
					sLine.drawRefLine(path);
				}
			}
		}
		
		private function onLineMouseUp(e:MouseEvent):void {
			sessionView.view.scene.removeEventListener(MouseEvent3D.MOUSE_MOVE, lineMouseMove);
			sessionView.stage.removeEventListener(MouseEvent.MOUSE_UP, onLineMouseUp);
			
			if (!path) return;
			
			var newPos3DTmp:Vector3D = drag3d.getIntersect();
			var isOnPitch:Boolean = sScreen.isPosOnPitch(newPos3DTmp);
			
			if (!customDrawing) {
				// Clear last command and add the new one.
				if (path.array.length > 1) {
					path.array.pop();
				}
			} else {
				// If line is custom, update the last position.
				if (isOnPitch) oldPos3D = newPos3D.clone();
			}
			
			if (isOnPitch) {
				newPos3D = drag3d.getIntersect().clone();
			}
			
			// Reduce the last point to make space for the arrow head.
			//newPos3D = new Vector3D(newPos3D.x-15, newPos3D.y, newPos3D.z-15);
			
			path.add(new PathCommand(PathCommand.LINE, oldPos3D.clone(), oldPos3D.clone(), newPos3D.clone()));
			//path.debugPath(sessionView.view.scene);
			
			
			
			if (!multiple) {
				stopDrawingLine();
				//if (sLine) sLine.selected = true;
			}else {
				drawFinalLine();
				// Request another line draw.
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_LINE, {lineId:sLine.settings._libraryId, multiple:true}));
			}
			//drawing = false;
		}
		
		private function drawFinalLine():void {
			if (customDrawing) {
				LineSmoother.getInstance().smoothCustomLine(path);
			}
			sLine.drawLine(path);
			sLine.name = "line"+lCount++;
		}
		
		private function onStageMouseClick(e:MouseEvent):void {
			//trace("LineCreator.onStageMouseClick()");
			if (!sessionView.isMouseOn3DView() || !sG.createMode) {
				stopDrawingLine();
			}
		}
		
		private function onDrawLineCancel(e:SSPEvent):void {
			stopDrawingLine();
		}
		
		private function stopDrawingLine():void {
			removeAllListeners();
			multiple = false;
			sG.createMode = false;
			if (!sScreen.screenLocked) sG.camLocked = false; // Unlock camera only if screen is not locked.
			SSPCursors.getInstance().reset(); // Reset cursor.
			
			// Do not dispose line container. Only finish drawing if possible.
			if (drawing && sLine && path) drawFinalLine();
			drawing = false;
			
			sScreen.drawingLineFinished();
		}
		
		/**
		 * Add an extra control point in the specified line. 
		 * @param line DynamicLine.
		 * 
		 */		
		public function addControlPoint(line:DynamicLine):void {
			// Get line length.
			/*			var pAM:PathAlignModifier = new PathAlignModifier(line, line.path);
			var lineLength:Number = pAM.pathLength;
			
			// Get current control points.
			var cCP:int =  line.countOfHandlerPoints;
			var newCCP:int = cCP+1;
			var newSLength:Number = lineLength / newCCP;
			var lU:LineUtils = new Lie
			var newPath:Path = new Path();
			var cs:PathCommand= path.aSegments[i];
			var pStart:Vertex = new Vertex(cs.pStart.x, cs.pStart.y, cs.pStart.z);
			var pControl:Vertex = new Vertex(cs.pControl.x, cs.pControl.y, cs.pControl.z);
			var pEnd:Vertex = new Vertex(cs.pEnd.x, cs.pEnd.y, cs.pEnd.z);
			
			newPath.add(new PathCommand(PathCommand.MOVE, 
			for (var i:int = 0;i<newSLength;i++;) {
			lU.getVector(newSLength, line.path.array);
			
			
			}*/
			
			// 1 sumar trozos
			// 2 dividir largo en x
			// 3 obtener punto en i
			// agregar punto i
			
			/*var _newLine.lineSourcePath
			var t:Number = .33;
			data = _lU.insertPointInVector(t, data);
			t = .66;
			data = _lU.insertPointInVector(t, data);*/
		}
		
		private function removeAllListeners():void {
			sessionView.view.scene.removeEventListener(MouseEvent3D.MOUSE_DOWN, startLineMouseDown);
			sessionView.view.scene.removeEventListener(MouseEvent3D.MOUSE_MOVE, lineMouseMove);
			sessionView.stage.removeEventListener(MouseEvent.MOUSE_UP, onLineMouseUp);
			sessionView.stage.removeEventListener(MouseEvent.CLICK, onStageMouseClick);
			sspEventDispatcher.removeEventListener(SSPEvent.CONTROL_CANCEL, onDrawLineCancel);
		}
		
		public function dispose():void {
			removeAllListeners();
		}
	}
}