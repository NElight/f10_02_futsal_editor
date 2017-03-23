package src3d.lines
{
	import away3d.core.base.Mesh;
	import away3d.core.base.Segment;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.events.MouseEvent3D;
	import away3d.primitives.CurveLineSegment;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.SSPEvent;
	import src3d.SessionScreen;
	import src3d.models.SSPObjectBaseSettings;
	import src3d.utils.LineUtils;
	
	public class DynamicLine extends LineBase
	{
		// Lines.
		protected var extrudedLine:SimpleLine;
		protected var extrudedLineSelect:SimpleLine; // Line selection area.
		protected var extrudedLineShadow:SimpleLine; // Shadow.
		
		// Handles.
		protected var pCommand1:PathCommand; // Stores the path command of the selected handle.
		protected var pCommand2:PathCommand; // Stores the path command next to the selected handle.
		
		/**
		 * Creates a new standard dynamic line. Used by <code>LineMaker</code>.
		 * 
		 * @see LineLibrary
		 * @see LineMaker
		 * 
		 */		
		public function DynamicLine(sessionScreen:SessionScreen, objSettings:SSPObjectBaseSettings)
		{
			// Place Internal Properties (_selectable, _rotable, etc.) before super.
			super(sessionScreen, objSettings);
			//this.debugbb = true;
			
			initMaterials();
			init2DButtons();
		}
		
		
		// ------------------------------- Inits ------------------------------- //
		protected override function initMainLineMesh():void {
			// Use this line to Debug:
			//lineCurrentSettings._lineStyle = LineLibrary.STYLE_DOTTED;
			
			// Add a small border to the elevated line profile to make it visible when viewed from one side.
			if (lineCurrentSettings._lineType == LineLibrary.TYPE_ELEVATED) {
				_useShadow = true;
				useBorder = true;
			} else {
				_useShadow = false;
				useBorder = false;
			}
			
			if (lineCurrentSettings._lineStyle == LineLibrary.STYLE_DASHED) {
				extrudedLine = new DashedLine(useBorder);
				if (_useShadow) extrudedLineShadow = new DashedLine(false);
			}
			if (lineCurrentSettings._lineStyle == LineLibrary.STYLE_CONTINUOUS) {
				extrudedLine = new SimpleLine(useBorder);
				if (_useShadow) extrudedLineShadow = new SimpleLine(false);
			}
			if (lineCurrentSettings._lineStyle == LineLibrary.STYLE_DOTTED) {
				extrudedLine = new DottedLine(useBorder);
				if (_useShadow) extrudedLineShadow = new DottedLine(false);
			}
			if (extrudedLineShadow) extrudedLineShadow.name = "extrudedLineShadow";
			
			extrudedLine.name = "extrudedLine";
			
			refLineMesh = new Mesh({name:"refLineMesh"});
			
			mainLineMesh = extrudedLine;
			
			// Selection Mesh.
			extrudedLineSelect = new SimpleLine(false);
			extrudedLineSelect.ownCanvas = true;
			extrudedLineSelect.alpha = 0;
			extrudedLineSelect.name = "extrudedLineSelect";
		}
		
		protected override function initDragDropTarget():void {
			dragDropTarget = extrudedLineSelect; // The transparent extruded line will trigger the mouse down event.
			dragDropContainer = this;  // 'this' will be dragged, then the internal objects' positions will be updated.
		}
		// ----------------------------- End Inits ----------------------------- //
		
		
		
		// ----------------------------- Drawing ----------------------------- //
		/**
		 * Draws a new Reference line. Uses a faster line than drawLine().
		 * Used in F10 to speed up onEnterFrame process.
		 * @param newPath
		 * 
		 */		
		public override function drawRefLine(newPath:Path):void {
			if (!newPath) {
				trace("newPath is null");
				return;
			}
			linePathData = newPath;
			updateRefLine();
		}
		
		protected override function updateRefLine():void {
			/*if (newPath != null && _refLinePathOld == newPath) {
				trace("recycling ref line");
				return;
			}*/
			//trace("drawRefLine()...");

			if (linePathData == null || linePathData.length == 0 || linePathData.aSegments.length <= 0) {
				trace("Can't create line.");
				return;
			}

			var _vec0:Vector3D = linePathData.aSegments[0].pStart;
			var _vec1:Vector3D;
			var _v0:Vertex = new Vertex(_vec0.x, _vec0.y, _vec0.z);
			var _v1:Vertex;
			var _segment:Segment;
			var _loop:int = linePathData.aSegments.length;
			
			// Custom Line Variables.
			var pStart:Vertex;
			var pControl:Vertex;
			var pEnd:Vertex;
			var pc:PathCommand;
			var pT:Vector3D;
			
			clearLines();
			
			if (lineCurrentSettings._lineType != LineLibrary.TYPE_CUSTOM) {
				_vec1 = linePathData.aSegments[_loop-1].pEnd;
				_v1 = new Vertex(_vec1.x, _vec1.y, _vec1.z);
//				refLineMesh = new Mesh();
//				_segment = new Segment(_v0, _v1, refLineMat);
//				refLineMesh.addSegment(_segment);
//				this.addChild(refLineMesh);

				if (refLineMesh.segments.length == 0) {
					_segment = new Segment(_v0, _v1, refLineMat);
					refLineMesh.addSegment(_segment);
				}
				//refLineMesh.vertices[0] = _v0;
				//refLineMesh.vertices[1] = _v1;
				refLineMesh.updateVertex(refLineMesh.vertices[0], _v0.x, _v0.y, _v0.z);
				refLineMesh.updateVertex(refLineMesh.vertices[1], _v1.x, _v1.y, _v1.z);
				this.addChild(refLineMesh);
			} else {
				aCurves = new Vector.<CurveLineSegment>();
				_segment = new Segment();
				for(var i:int = 0; i<_loop; i++){
					/*pc = linePathData.aSegments[i];
					pStart = new Vertex(pc.pStart.x, pc.pStart.y, pc.pStart.z);
					//pControl = new Vertex(pc.pControl.x, pc.pControl.y, pc.pControl.z);
					pControl = pStart;
					pEnd = new Vertex(pc.pEnd.x, pc.pEnd.y, pc.pEnd.z);
					_cls = 	new CurveLineSegment(pStart, pControl, pEnd, refLineMat);
					aCurves.push(_cls);
					this.addChild(_cls);*/
					
					pc = linePathData.aSegments[i];
					pT = LineUtils.getPointOnCurve(pc.pStart, pc.pControl, pc.pEnd, 0.5); // Get the point from the control.
					_segment.moveTo(pc.pStart.x, pc.pStart.y, pc.pStart.z);
					_segment.lineTo(pT.x, pT.y, pT.z);
					_segment.moveTo(pT.x, pT.y, pT.z);
					_segment.lineTo(pc.pEnd.x, pc.pEnd.y, pc.pEnd.z);
				}
				refLineMesh.addSegment(_segment);
				this.addChild(refLineMesh);
			}
		}
		
		public override function drawLine(newPath:Path):void {
			if (!newPath) {
				trace("newPath is null");
				return;
			}
			linePathData = newPath;
			updateLine();
		}

		protected override function updateLine():void {
			//trace("drawLine()...");
			/*if (this._mainContainer.contains(refLineMesh)) {
				trace("removing refLine");
				this._mainContainer.removeChild(refLineMesh);
			}
			if (this._mainContainer.contains(_cls)) {
				trace("removing refLine");
				this._mainContainer.removeChild(_cls);
			}*/
			clearLines();
			if (linePathData == null) {
				//trace("linePathData is null");
				// If there is nothing to draw, return.
				linePathData = new Path();
				return;
			}
			if (linePathData.aSegments.length <= 0) {
				//trace("No path data yet.");
				return;
			}
			// The database has a limit of 4096 characters for _pathData
			// Each segment will be about 64 characters.
			// 64*64 = 4096.
			// So max segments to draw a line would be 64. Using 62 to be safe.
			//var maxSeg:uint = 62;
			//if (linePathData.aSegments.length > maxSeg) {
			//	trace ("Line is too long ("+linePathData.aSegments.length+" segments), trimming to "+maxSeg+".");
			//	var sToDel:uint = linePathData.aSegments.length - maxSeg;
			//	linePathData.aSegments.splice(maxSeg, sToDel);
			//}
			// The avobe code is commented out since now we trim the line properly when finished drawing. See LineCreator.drawFinalLine().
			if(linePathData == null || linePathData.length == 0) {
				trace("Invalid path data. drawing line ignored.");
				return;
			}
			
			if (_useShadow) {
				extrudedLineShadow.drawLine(LineUtils.makePlainPath(linePathData), lineThickness, lineCurrentSettings._useArrowHead, lineCurrentSettings._arrowThickness, lineShadowMat);
				if (!this.getChildByName("extrudedLineShadow")) this.addChild(extrudedLineShadow);
			} else {
				if (extrudedLineShadow) {
					if (extrudedLineShadow.parent == this) {
						this.removeChild(extrudedLineShadow);
					}
				}
			}
			extrudedLine.drawLine(linePathData, lineThickness, lineCurrentSettings._useArrowHead, lineCurrentSettings._arrowThickness, lineMat);
			if (!this.getChildByName("extrudedLine")) this.addChild(extrudedLine);
			
			extrudedLineSelect.drawLine(linePathData, lineThickness*3, lineCurrentSettings._useArrowHead, lineCurrentSettings._arrowThickness*3, lineMat);
			if (!this.getChildByName("extrudedLineSelect")) this.addChild(extrudedLineSelect);
			extrudedLineSelect.y = .1; // Move on top of other lines.
			
			bringHandlesToFront();
			//trace("line drawing done. Path Length: "+linePathData.length);
		}
		
		/**
		 * Removes and destroys the lines inside the ObjectContainer3D.
		 */
		public function clearLines():void
		{
			//trace("clearLines");
			var i:int;
			
			if (extrudedLine) removeChild(extrudedLine);
			if (extrudedLineSelect) removeChild(extrudedLineSelect);
			if (extrudedLineShadow) removeChild(extrudedLineShadow);
			
			if (refLineMesh) {
				//trace("removing mesh");
				this.removeChild(refLineMesh);
				refLineMesh = new Mesh({name:"refLineMesh"});
				refLineMesh.material = refLineMat;
			}
			//trace("removing curves");
			for(i = 0;i<aCurves.length;++i) {
				this.removeChild(aCurves[i]);
				aCurves[i] = null;
			}
			aCurves = new Vector.<CurveLineSegment>();
		}
		// --------------------------- End Drawing --------------------------- //

		
		
		// ----------------------------- Selecting ----------------------------- //
		public override function set selected(s:Boolean):void {
			super.selected = s;
			if (!s) {
				updateLinePosition();
			}
		}
		
		protected override function updateLinePosition(newPos:Vector3D = null):void {
			if (!newPos) {
				repositionLine(this.position);
			} else {
				repositionLine(newPos);
			}
			this.position = containerPos;
			updateLine();
			repositionHandles();
		}
		protected function repositionLine(newPos:Vector3D):void {
			//trace("repositionLine");
			if (isNaN(newPos.x) || isNaN(newPos.y) || isNaN(newPos.z)) return;
			for (var i:int = 0;i<linePathData.aSegments.length;i++) {
				linePathData.aSegments[i].pStart = newPos.add(linePathData.aSegments[i].pStart);
				linePathData.aSegments[i].pControl = newPos.add(linePathData.aSegments[i].pControl);
				linePathData.aSegments[i].pEnd = newPos.add(linePathData.aSegments[i].pEnd);
			}
		}
		
		public override function moveLineTo(newPos:Vector3D):void {
			// Get the center offset.
			//var pBounds:Object = LineUtils.getPathBounds(linePathData);
			var currentAreaBounds:AreaBounds = this.areaBounds;
			if (!currentAreaBounds) return;
			var pCenter:Vector3D = currentAreaBounds.areaPosition.clone();
			// Change the pos to: -centerPos + newPos.
			pCenter.negate();
			updateLinePosition(pCenter.add(newPos));
			handlesVisible(false);
		}
		
		public override function get areaBounds():AreaBounds {
			updateLinePosition();
			var lb:AreaBounds = new AreaBounds();
			lb.maxX = extrudedLine.maxX;
			lb.minX = extrudedLine.minX;
			lb.maxZ = extrudedLine.maxZ;
			lb.minZ = extrudedLine.minZ;
			//lb.centerOffsetX = lb.maxX - pCenterX; 
			//lb.centerOffsetZ = lb.maxZ - pCenterZ;
			//lb.centerOffsetX = this.position.x;
			//lb.centerOffsetZ = this.position.z;
			return lb;
		}
		// --------------------------- End Selecting --------------------------- //
		
		
		
		// ----------------------------- Handles ----------------------------- //
		protected override function onHPMouseDown(e:MouseEvent3D):void {
			super.onHPMouseDown(e);
			var hIdx = selectedHandle.handleIndex;
			pCommand2 = null;
			pCommand1 = null;
			
			if (hIdx > 0) {
				pCommand1 = linePathData.aSegments[linePathData.aSegments.length-1];
			} else {
				pCommand1 = linePathData.aSegments[0];
				if (LineUtils.pathCommandZeroLength(pCommand1)) {
					// Store the next path only if it exists.
					if (hIdx < linePathData.aSegments.length-1) {
						pCommand2 = linePathData.aSegments[hIdx+1];
					}
				}
			}
		}
		
		protected override function onHPMouseMove(e:MouseEvent):void {
			trace("onHPMouseMove");
			if (!selectedHandle) return;
			/*if (lineCurrentSettings._lineType == LineLibrary.TYPE_CUSTOM ||
			lineCurrentSettings._lineType == LineLibrary.TYPE_GRID
			) return;*/
			
			newPos3D = drag3d.getIntersect().clone();
			
			if (selectedHandle.handleControlPoint == HandleLibrary.P_START) {
				trace("pStart");
				pCommand1.pStart = newPos3D;
				pCommand1.pControl = newPos3D;
				pCommand1.pEnd = newPos3D;
				
			} else {
				trace("pEnd");                                                                                                                                          
				pCommand1.pEnd = newPos3D;
			}
			if (pCommand2) {
				pCommand2.pStart = newPos3D;
				pCommand2.pControl = newPos3D;
			}
			
			// Update the main line, wihout the shadow.
			this.updateRefLine();
		}
		
		protected override function onHPStageMouseUp(e:MouseEvent):void {
			linePathData.aSegments = LineSmoother.getInstance().trimCustomLine(linePathData.aSegments);
			super.onHPStageMouseUp(e);
		}
		// --------------------------- End Handles --------------------------- //
		
		
		
		public override function dispose():void {
			clearLines();
			
			super.dispose();
			
			if (extrudedLine) extrudedLine.dispose();
			if (extrudedLineSelect) extrudedLineSelect.dispose();
			if (extrudedLineShadow) extrudedLineShadow.dispose();
			extrudedLine = null;
			extrudedLineSelect = null;
			extrudedLineShadow = null;
			pCommand1 = null;
			pCommand2 = null;
		}
	}
}
