package src3d.lines
{
	import away3d.core.base.Geometry;
	import away3d.core.base.Mesh;
	import away3d.core.geom.Path;
	import away3d.extrusions.PathExtrusion;
	import away3d.materials.Material;
	import away3d.tools.Merge;
	
	import flash.geom.Vector3D;

	public class SimpleLine extends PathExtrusion
	{
		protected var _sourcePath:Path = new Path(); // Contains the data from and for the XML.
		protected var _lineThickness:int; // See LineSettings.getLineWidth();
		protected var _arrowThickness:int;
		//protected var _lineProfile:Array;
		protected var _useBorder:Boolean;
		
		protected var _useArrowHead:int;
		protected var _aH:Vector.<ArrowHead> = new Vector.<ArrowHead>(); // Array of Arrow Heads
		protected var merge:Merge = new Merge(false,false,true);
		
		public function SimpleLine(useBorder:Boolean)
		{
			// Super valid data to avoid invalid extruded line error.
			super(new Path([new Vector3D, new Vector3D, new Vector3D]), [new Vector3D(), new Vector3D()]);
			this._useBorder = useBorder;
			this.mouseEnabled = true;
			this.useHandCursor = true;
			//this.showBounds = true;
			//this.debugbb = true;
			
			initArrowHeads();
		}
		
		public function drawLine(path:Path, lineThickness:int, useArrowHead:int, arrowThickness:Number, lineMat:Material):void {
			if(path == null || path.length == 0) {
				trace("Smooth path data is too short. Line ignored.");
				return;
			}
			_lineThickness = lineThickness;
			_useArrowHead = useArrowHead;
			_arrowThickness = arrowThickness;
			this.geometry = new Geometry();
			//this.profile = _lineProfile = [new Vector3D(-_lineThickness, 0, 0), new Vector3D(_lineThickness, 0, 0)];
			if (_useBorder) {
				this.profile = [
					new Vector3D(-_lineThickness, 0, 0),
					new Vector3D(-_lineThickness, -2, 0),
					new Vector3D(_lineThickness, -2, 0),
					new Vector3D(_lineThickness, 0, 0)
				];
			} else {
				this.profile = [
					new Vector3D(-_lineThickness, 0, 0),
					new Vector3D(_lineThickness, 0, 0)
				];
			}
			
			this.subdivision = (path.length <= 2)? 0 : 4;
			//this.showBounds = true;
			getMainLine(path);
			this.bothsides = true;
			if (_useArrowHead != LineLibrary.ARROW_HEAD_NONE) {
				updateArrowHeads();
				//var merge:Merge = new Merge(false,false,false);
				if (_useArrowHead == LineLibrary.ARROW_HEAD_END){
					_aH[1].rotateArrowHead(path,false);
					// Merge the arrow head with the extruded line to have a single mesh.
					merge.apply(this, _aH[1]);
				} else if (_useArrowHead == LineLibrary.ARROW_HEAD_START){
					_aH[0].rotateArrowHead(path,true);
					// Merge the arrow head with the extruded line to have a single mesh.
					merge.apply(this, _aH[0]);
				} else if (_useArrowHead == LineLibrary.ARROW_HEAD_BOTH) {
					_aH[0].rotateArrowHead(path,true);
					_aH[1].rotateArrowHead(path,false);
					merge.apply(this, _aH[0]);
					merge.apply(this, _aH[1]);
				}
			} else {
				merge.apply(this, new Mesh()); // Forces updating mesh to detect correct position when stop dragging.
			}
			if (this.material != lineMat) this.material = lineMat; 
			//this.material.bothSides = true;
			//this.showBounds = true;
		}
		
		public function eraseLine():void {
			//this.path = new Path(new Vector.<Vector3D>);
			trace("eraseLine()");
			this.geometry = null;
		}
		
		/**
		 * To be overriden by DashedLine, DottedLine, etc. 
		 */		
		protected function getMainLine(path:Path):void {
			this.path = path;
		}

		protected function initArrowHeads():void {
			_aH = new Vector.<ArrowHead>();
			var aHa:ArrowHead = new ArrowHead(_arrowThickness);
			var aHb:ArrowHead = new ArrowHead(_arrowThickness);
			_aH.push(aHa, aHb);
		}
		
		protected function updateArrowHeads():void {
			for each(var aH:ArrowHead in _aH) {
				aH.arrowSize = _arrowThickness;
			}
		}

		public function dispose():void {
			for each(var aH:ArrowHead in _aH) {
				aH.dispose();
			}
			aH = null;
			_sourcePath = null;
			merge = null;
			//this.geometry = null;
			
			this.ownCanvas = true;
			if (this.parent) this.parent.removeChild(this);
		}
		
		public function get sourcePath():Path { return _sourcePath };
		public function get useArrowHead():uint { return _useArrowHead;};
	}
}