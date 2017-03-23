package src3d.models.soccer.pitches
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.Material;
	import away3d.primitives.Plane;
	
	import flash.geom.Vector3D;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionScreen;
	import src3d.models.Equipment;
	import src3d.utils.ColorUtils;
	import src3d.utils.MiscUtils;

	public class Pitch extends ObjectContainer3D {
		private var pWidth:Number;
		private var pHeight:Number;
		private var _pitchLimits:Vector3D;
		private var aCamTargets:Vector.<PitchTarget>;
		
		private var pLib:PitchLibrary = PitchLibrary.getInstance();
		private var pB:Plane; // Pitch Base
		private var pM:ObjectContainer3D = new ObjectContainer3D();// pM = Main marks container.
		private var _pitchEnabled:Boolean;
				
		// SESSION DATA VARS.
		private var _currentCamTargetId:int = -1; // Current Camera Target Id.
		private var _currentMarksId:int = -1; // Current Pitch Marks Id.
		private var _currentFloorId:int = -1; // Current Pitch Texture Id.
		//private var _currentMarksColor:uint;
		
		//private var _aDE:Vector.<Equipment> = new Vector.<Equipment>; // Array of Default Equipment.

		public function Pitch() {
			this.name = "Pitch";
			this.ownCanvas = true;
			this.pushback = true;
			initPitchMarks();
			init();
		}

		private function init():void {
			pWidth = 2809;
			pHeight = 1521;
			_pitchLimits = new Vector3D(pWidth/2,0,pHeight/2);
			
			// Set materials.
			_currentFloorId = PitchLibrary.FLOOR_ID_1;
			// Set Pitch Base.
			var mat:Material = pLib.aPF[_currentFloorId].floor as Material; 
			
			//var pMat:TransformBitmapMaterial = new TransformBitmapMaterial(Cast.bitmap(PitchTexture1),{repeat:true, smooth:false});
			// Set the pB.y to a number <0 to avoid dragging errors when clicking plane objects with y=0.
			pB = new Plane({y:-.1, width:pWidth, height:pHeight, segmentsW:20, segmentsH:20, material:mat, ownCanvas:true});
			this.addChild(pB);
			
			// Set Pitch Marks container.
			//pM = new ObjectContainer3D();
			setPitchMarks(PitchLibrary.MARKS_ID_STANDARD); // Default Marks.
			//setPitchMarksColor(m.marks); // Default Marks color.
			this.addChild(pM);
			
			// Create Camera Targets.
			aCamTargets = new PitchTargets().createCameraTargets(pWidth, pHeight);
			//for each (var t:PitchTarget in aCamTargets) {
			//	this.addChild(t);
			//}
			
			this.addEventListener(MouseEvent3D.MOUSE_DOWN, onPitchMouseDown, false, 0, true);
		}
		
		private function initPitchMarks():void {
			// Color all Marks.
			for (var i:int = 0;i<pLib.aPM.length;i++) {
				ColorUtils.applyWireColorMaterialToMeshes(new Array(pLib.aPM[i].marks),0xFFFFFF,0xFFFFFF,1,"");
			}
		}
		
		private function clearMarks():void {
			if (pM.children.length > 0){
				for each(var o:ObjectContainer3D in pM.children) {
					if (o.name == "marks") {
						pM.removeChild(o);
						o = null;
						//pM.removeChildByName("marks");	
					}
				}
			}
		}
		
		/*public function setPitchMarksColor(marks:ObjectContainer3D, newCol:uint = PitchLibrary.MARKS_COLOR_DEFAULT, al:Number = 1):void {
		// Not used yet.
		}*/
		
		public function setPitchMarks(marksId:int):int {
			if (_currentMarksId == marksId) return marksId;
			if (marksId >= pLib.aPM.length) marksId = 0;
			if (MiscUtils.indexInArray(pLib.aPM, "pitchMarksId", marksId) == -1) marksId = 0;
			_currentMarksId = marksId;
			clearMarks();
			pM.addChild(ObjectContainer3D(pLib.aPM[_currentMarksId].marks).clone());
			//this.addChild(pM);
			return marksId;
		}
		public function get pitchMarksId():int {
			return _currentMarksId;
		}
		
		public function setPitchFloor(pitchFloorId:int):int {
			if (_currentFloorId == pitchFloorId) return pitchFloorId;
			if (pitchFloorId >= pLib.aPF.length) pitchFloorId = 0;
			if (MiscUtils.indexInArray(pLib.aPF, "pitchFloorId", pitchFloorId) == -1) pitchFloorId = 0;
			
			_currentFloorId = pitchFloorId;
			pB.material = pLib.aPF[_currentFloorId].floor;
			return _currentFloorId;
		}
		public function get pitchFloorId():int {
			return _currentFloorId;
		}
		
		public function get pitchWidth():Number {
			return pWidth;
		}
		public function get pitchHeight():Number {
			return pHeight;
		}
		public function getPitchLimits():Vector3D {
			return _pitchLimits;
		}
		
		public function get usingDefaultPitch():Boolean {
			if (pLib.aPM[_currentMarksId].defaultPitch) {
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * Returns the specified Camera Target Position.
		 * If no camera target is specified, returns the Selected Camera Target Position.
		 *  
		 * @param targetId int. Camera target id.
		 * @return Vector3D with the camera target position.
		 * 
		 */		
		public function getCamTargetPos(targetId:int = -1):Vector3D {
			if (targetId == -1) targetId = _currentCamTargetId;
			return aCamTargets[targetId].position;
		}
		
		/**
		 * Returns the specified Camera Target.
		 * If no camera target is specified, returns the Selected Camera Target.
		 *  
		 * @param targetId int. Camera target id.
		 * @return PitchTarget.
		 * 
		 */		
		public function getCamTarget(targetId:int = -1):PitchTarget {
			if (targetId == -1) targetId = _currentCamTargetId;
			return aCamTargets[targetId];
		}
		
		public function get camTargets():Vector.<PitchTarget> {
			return aCamTargets;
		}
		
		public function set cameraTargetId(newCamTargetId:int):void {
			_currentCamTargetId = newCamTargetId;
		}
		public function get cameraTargetId():int {
			return _currentCamTargetId;
		}
		
		public function set pitchEnabled(pEnabled:Boolean):void {
			_pitchEnabled = pEnabled;
			if (!_pitchEnabled) {
				this.removeEventListener(MouseEvent3D.MOUSE_DOWN, onPitchMouseDown);
			}else {
				if (!this.hasEventListener(MouseEvent3D.MOUSE_DOWN)) this.addEventListener(MouseEvent3D.MOUSE_DOWN, onPitchMouseDown, false, 0, true);
			}
		}
		public function get pitchEnabled():Boolean {
			return _pitchEnabled;
		}
		
		private function onPitchMouseDown(e:MouseEvent3D):void {
			trace("Pitch.onPitchMouseDown()");
			if (!_pitchEnabled) return;
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CONTROL_PITCH_MOUSE_DOWN));
		}
		
		public function dispose():void {
			this.removeEventListener(MouseEvent3D.MOUSE_DOWN, onPitchMouseDown);
			clearMarks();
			// Remove Pitch Marks.
			this.removeChild(pM);
			// Remove Pitch Base.
			pB.material = null;
			this.removeChild(pB);
			pM = null;
			pB = null;
			pLib = null;
			_pitchLimits = null;
			aCamTargets = null;
			if (this.parent) this.parent.removeChild(this);
		}
	}
}