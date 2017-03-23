package src.team
{
	import fl.motion.Color;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import src.lists.MCCellRenderer;
	import src.team.list.ColorBackgroundBox;
	
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.utils.ColorUtils;
	import src3d.utils.EventHandler;
	
	public class PRCellRendererBase extends MCCellRenderer
	{
		protected var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		private var stageEventHandler:EventHandler;
		
		// Cell Renderer vars.
		protected var _compactMode:Boolean;
		
		// Player Record vars.
		protected var _rF:PRCellRendererFormat = new PRCellRendererFormat();
		protected var _rFinit:PRCellRendererFormat = TeamGlobals.getInstance().initialExpandedCellSettings;
		protected var _playerId:String;
		protected var _blankRecord:Boolean; // Used to create a blank record to drop in the target list.
		protected var _txtName:TextField = new TextField();
		protected var _txtFamName:TextField = new TextField();
		protected var _btnRemove:MovieClip = new MovieClip();
		protected var _txtNumber:TextField = new TextField();
		protected var _mcNumberBg:ColorBackgroundBox = new ColorBackgroundBox();
		
		protected var isDragging:Boolean;
		
		protected var _prEnabled:Boolean = true;
		protected var _recordUsed:Boolean;
		protected var _recordRepeated:Boolean;
		
		protected var repeatedColor:uint = 0xFF0000;
		
		public function PRCellRendererBase()
		{
			super();
			this.stop();
			this.name = "PRCellRendererBase";
			
			// Controls.
			/*_txtName = this.txtName;
			_txtFamName = this.txtFamName;
			_txtNumber = this.txtNumber;
			_btnRemove = this.btnRemove;
			_btnRemove.buttonMode = true;
			_btnRemove.addEventListener(MouseEvent.CLICK, onBtnRemoveClick);
			_mcNumberBg = this.mcNumberBg;*/
			
			// Format.
			/*_rF.displayName = true;
			_rF.displayFamName = true;
			_rF.displayNumber = true;
			_rF.displayPicture = true;
			_rF.displayRemove = false;
			applyFormat();*/
			
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.buttonEnabled = true;
			stageEventHandler = new EventHandler(stage);
		}
		
		protected override function onMouseDown(e:MouseEvent):void {
			super.onMouseDown(e);
			stageEventHandler.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove, false, 0, true);
			stageEventHandler.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 0, true);
		}
		protected function onStageMouseMove(e:MouseEvent):void {
			stageEventHandler.RemoveEvent(MouseEvent.MOUSE_MOVE);
			if (!isDragging) {
				isDragging = true;
				sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_DRAG_ITEM, this));
			}
		}
		protected function onStageMouseUp(e:MouseEvent):void {
			stageEventHandler.RemoveEvent(MouseEvent.MOUSE_MOVE);
			stageEventHandler.RemoveEvent(MouseEvent.MOUSE_UP);
			if (!this.hasEventListener(MouseEvent.MOUSE_DOWN)) this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			isDragging = false;
		}
		
		protected override function onMouseOver(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			// No highlight if this is a blank item.
			if (!_prEnabled || _blankRecord) return;
			super.onMouseOver(e);
		}
		protected override function onMouseOut(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			// No highlight if this is a blank item.
			if (!_prEnabled || _blankRecord) return;
			super.onMouseOut(e);
		}
		
		protected function onBtnRemoveClick(e:MouseEvent):void {
			//sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TARGET_LIST_REMOVE_ITEM, this._data));
		}
		
		public function clone(cloneIn:PRCellRendererBase = null):PRCellRendererBase {
			var newPr:PRCellRendererBase = (cloneIn)? cloneIn : new PRCellRendererBase();
			newPr.width = this.width;
			newPr.height = this.height;
			newPr.scaleX = this.scaleX;
			newPr.scaleY = this.scaleY;
			newPr.scaleZ = this.scaleZ;
			
			var newPos:Point = this.localToGlobal(new Point(this.x, this.y));
			newPr.x = newPos.x - this.x;
			newPr.y = newPos.y - this.y;
			
			newPr.playerName = this.playerName;
			newPr.playerFamName = this.playerFamName;
			newPr.playerNumber = this.playerNumber;
			newPr.displayRemove = this.displayRemove;
			newPr.playerId = this.playerId;
			
			// Clone id, image, name, famName, number.
			//			newPr.id = this.id;
			newPr.label = this.label;
			newPr.icon = this.icon;
			//newPr.source = this.source;
			
			newPr.recordEnabled = this.recordEnabled;
			newPr.recordUsed = this.recordUsed;
			newPr._mcNumberBg.visible = this._mcNumberBg.visible;
			
			return newPr;
		}
		
		protected function blankRecord(bR:Boolean):void {
			_blankRecord = bR;
			if (_blankRecord) {
				_rF.displayName = false;
				_rF.displayFamName = false;
				_rF.displayNumber = false;
				_rF.displayPicture = false;
				_rF.displayRemove = false;
				_rF.displayEdit = false;
				_rF.displayInitials = false;
				_rF.displayPose = false;
				//_rF.displayPosition = false;
			} else {
				initPlayerRecordFormat();
			}
			applyFormat();
		}
		
		
		
		// ----------------------------------- Getters and Setters ----------------------------------- //
		public function set playerId(strPId:String):void {_playerId = strPId;}
		public function get playerId():String {return _playerId;}
		
		public function set playerName(str:String):void {_txtName.text = str;}
		public function get playerName():String {return _txtName.text;}
		
		public function set playerFamName(str:String):void {_txtFamName.text = str;}
		public function get playerFamName():String {return _txtFamName.text;}
		
		public function set playerNumber(str:String):void {_txtNumber.text = str;}
		public function get playerNumber():String {return _txtNumber.text;}
		
		public function set displayRemove(disp:Boolean):void {
			_rF.displayRemove = disp;
			applyFormat();
		}
		public function get displayRemove():Boolean {return _rF.displayRemove;}
		
		public function set displayEdit(disp:Boolean):void {
			_rF.displayEdit = disp;
			applyFormat();
		}
		public function get displayEdit():Boolean {return _rF.displayEdit;}
		
		public function set recordEnabled(prEnabled:Boolean):void {
			_prEnabled = prEnabled;
			if (!_prEnabled) {
				this.gotoAndStop(3);
			} else {
				this.gotoAndStop(1);
			}
			
		}
		public function get recordEnabled():Boolean { return _prEnabled; }
		
		public function set recordUsed(used:Boolean):void {
			if (_recordUsed == used) return;
			_recordUsed = used;
			if (_recordUsed) {
				addUsedEffect();
			} else {
				removeUsedEffect();
			}
		}
		public function get recordUsed():Boolean { return _recordUsed; }
		
		public function set recordRepeated(repeated:Boolean):void {
			if (_recordRepeated == repeated) return;
			_recordRepeated = repeated;
			if (_recordRepeated) {
				addRepeatedEffect();
			} else {
				removeRepeatedEffect();
			}
		}
		// -------------------------------- End of Getters and Setters ----------------------------------- //
		
		
		
		// ----------------------------------- Cell Renderer ----------------------------------- //
		public override function set data(d:Object):void { 
			super.data = d as PRItem; 
			if (!_data) return;
			/*if (_data.playerXML.children().length() == 0) {
				blankRecord(true);
			} else {
				blankRecord(false);
			}*/
			//label = d.label;
			blankRecord(_data.blankRecord);
			playerId = _data.playerId;
			_txtName.text = _data.playerName;
			_txtFamName.text = _data.playerFamName;
			_txtNumber.text = _data.playerNumber;
			this.recordEnabled = _data.recordEnabled;
			this.recordUsed = _data.recordUsed;
			this.recordRepeated = _data.recordRepeated;
		} 
		
		public function get compactMode():Boolean { return _compactMode; }
		
		protected override function invalidate():void
		{
			if (_data) recordEnabled = _data.recordEnabled;
			
			// There is an issue when using SimpleButton:
			// When clicking close, the cell renderer is removed from screen, but no 'mouse over' is fired.
			// When cell renderer is reused, the button is in 'mouse over' mode.
			// The easiest way to solve it is use a movie clip with buttonMode = true.
			_btnRemove.gotoAndStop("_up");
		}
		// -------------------------------- End of Cell Renderer ------------------------------- //
		
		
		
		// ----------------------------------- Style ----------------------------------- //
		protected function addUsedEffect():void {
			var col:Color = new Color();
			col.setTint(0xAAAAAA, .5);
			this.transform.colorTransform = col;
		}
		protected function removeUsedEffect():void {
			var col:Color = new Color();
			col.setTint(0, 0);
			this.transform.colorTransform = col;
		}
		
		protected function addRepeatedEffect():void {
			_mcNumberBg.boxSetLineColor(repeatedColor);
			_txtName.textColor = repeatedColor;
			_txtFamName.textColor = repeatedColor;
		}
		protected function removeRepeatedEffect():void {
			_mcNumberBg.boxResetLineColor();
			_txtName.textColor = 0;
			_txtFamName.textColor = 0;
		}
		
		protected function initPlayerRecordFormat():void {
			_rF.displayName = _rFinit.displayName;
			_rF.displayFamName = _rFinit.displayFamName;
			_rF.displayNumber = _rFinit.displayNumber;
			_rF.displayPicture = _rFinit.displayPicture;
			_rF.displayRemove = _rFinit.displayRemove;
			_rF.displayEdit = _rFinit.displayEdit;
			_rF.displayInitials = _rFinit.displayInitials;
			_rF.displayPose = _rFinit.displayPose;
			_rF.displayPosition = _rFinit.displayPosition;
			applyFormat();
		}
		/*public function setPlayerRecordFormat(rF:PRCellRendererFormat):void {
			_rFinit = rF;
			initPlayerRecordFormat();
		}*/
		public function getPlayerRecordFormat():PRCellRendererFormat {
			return _rF;
		}
		protected function applyFormat():void {
			//if (_blankRecord) return;
			if (_compactMode) _rF.displayFamName = false;
			if (_compactMode) _rF.displayNumber = true;
			if (_compactMode) _rF.displayNumber = true;
			if (_blankRecord) _rF.displayRemove = false;
			
			_txtName.visible = _rF.displayName;
			_txtFamName.visible = _rF.displayFamName;
			_txtNumber.visible = _rF.displayNumber;
			_mcNumberBg.visible = _rF.displayNumber;
			_btnRemove.visible = _rF.displayRemove;
			
			// Number style.
			var prItem:PRItem = this.data as PRItem;
			if (prItem) {
				var ps:PlayerSettings = prItem.getPlayerSettings();
				var bgCol:uint = int(PRTeamManager.getInstance().getTeamSideKitSettings(prItem.playerTeamSide, ps._cKit._kitTypeId)._topColor);
				//var lineCol:uint = int(PRTeamManager.getInstance().getTeamSideKitSettings(prItem.playerTeamSide, ps._cKit._kitTypeId)._bottomColor);
				_mcNumberBg.boxSetBgColor(bgCol);
				_txtNumber.textColor = ColorUtils.getColorContrast(_mcNumberBg.boxBgColor); // Number text field color contrast.
			}
		}
		// -------------------------------- End of Style ------------------------------- //
	}
}