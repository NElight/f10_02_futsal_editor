package src.team.list
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	import src.popup.SelectPoseFormPopupBox;
	import src.team.PRCellRendererBase;
	import src.team.PRItem;
	import src.team.PlayerIcons;
	import src.team.SSPTeamEvent;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;
	
	public class PRCCellRendererBase extends PRCellRendererBase
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		// Player Record vars.
		protected var _txtPosition:TextField = new TextField();
		protected var _btnEdit:MovieClip = new MovieClip();
		protected var _btnPose:MovieClip = new MovieClip();
		protected var _btnNumber:SimpleButton = new SimpleButton();
		protected var _poseContainer:MovieClip = new MovieClip(); // We need a container inside _btnPose to keep x,y positions.
		
		// Select Pose Form.
		private var popupSelectPose:SelectPoseFormPopupBox;
		private var bmpIcon:Bitmap = new Bitmap();
		
		// Tooltip Settings.
		private var vSettings:Vector.<SSPToolTipSettings>;
		
		public function PRCCellRendererBase()
		{
			super();
		}
		
		// ----------------------------------- PR Controls ----------------------------------- //
		protected function initListeners():void {
			this.invalidate();
			sspEventDispatcher.addEventListener(SSPTeamEvent.TEAM_SETTINGS_CHANGE_NUMBER_FORMAT, onPlayerNumberChangeFormat);
			sspEventDispatcher.addEventListener(SSPTeamEvent.TEAM_SETTINGS_CHANGE_NAME_FORMAT, onPlayerNameChangeFormat);
			applyFormat();
			initToolTips();
		}
		
		private function initToolTips():void {
			// Tooltips.
			vSettings = new Vector.<SSPToolTipSettings>();
			vSettings.push(new SSPToolTipSettings(_btnNumber, sG.interfaceLanguageDataXML.tags._menuBtnEditPlayer.text()));
			vSettings.push(new SSPToolTipSettings(_btnPose, sG.interfaceLanguageDataXML.tags._tagsBtnTeamPlayerPose.text()));
			vSettings.push(new SSPToolTipSettings(_btnEdit, sG.interfaceLanguageDataXML.tags._menuBtnEditPlayer.text()));
			vSettings.push(new SSPToolTipSettings(_btnRemove, sG.interfaceLanguageDataXML.tags._menuBtnRemovePlayer.text()));
			SSPToolTip.getInstance().addToolTips(vSettings);
		}
		
		protected function onPlayerNumberChangeFormat(e:SSPTeamEvent):void {
			if (_compactMode) return;
			updatePlayerNumberFormat();
		}
		protected function updatePlayerNumberFormat():void {
			var idx:int = uint(sG.sessionDataXML.session._teamPlayerNumberFormat.text());
			if (idx == 0) {
				// Display Player Number.
				_rF.displayNumber = _rFinit.displayNumber = true;
				_rF.displayPose = _rFinit.displayPose = false;
			} else {
				// Display Player Pose.
				_rF.displayNumber = _rFinit.displayNumber = false;
				_rF.displayPose = _rFinit.displayPose = true;
			}
			applyFormat();
		}
		
		protected function onPlayerNameChangeFormat(e:SSPTeamEvent):void {
			if (!_data) return;
			_txtName.text = teamMgr.getFormattedName(_data.playerName, _data.playerFamName);
			this.invalidate();
		}
		
		protected override function onMouseDown(e:MouseEvent):void {
			super.onMouseDown(e);
			// Select 3D player if exist.
			var prItem:PRItem = this.data as PRItem;
			if (prItem) sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_TEAM_PLAYER, {teamPlayerId:prItem.playerId, teamSide:prItem.playerTeamSide}));
		}
		
		protected override function onBtnRemoveClick(e:MouseEvent):void {
			this.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_REMOVE_ITEM, this._data, true));
		}
		protected function onBtnEditClick(e:MouseEvent):void {
			this.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_EDIT_ITEM, this._data, true));
		}
		
		private function onBtnPoseClick(e:MouseEvent):void {
			if (!_data) return;
			var ps:PlayerSettings = _data.getPlayerSettings();
			// Select Pose Popup Form.
			if (!popupSelectPose) popupSelectPose = SelectPoseFormPopupBox.getInstance(this.stage);
			popupSelectPose.loadPoseIconsDP(ps._cKit._kitId, ps._cKit._kitTypeId); // Tells Player Icons form to load the specified kit icons.
			popupSelectPose.addEventListener(SSPTeamEvent.PLAYER_POSE_SELECT, onPoseSelected, false, 0, true); // Player Pose Listener.
			popupSelectPose.popupVisible = true;
		}
		protected function onPoseSelected(e:SSPTeamEvent):void {
			// TODO.
			popupSelectPose.removeEventListener(SSPTeamEvent.PLAYER_POSE_SELECT, onPoseSelected);
			var pId:String = e.eventData; // Event contains playerPoseId.
			setPlayerPose(pId);
			this.invalidate();
		}
		protected function checkPoseIcon():void {
			// Check new sortOrder and see if pose is the correct one.
			var prItem:PRItem = _data as PRItem;
			if (!prItem) return;
			
			var ps:PlayerSettings = prItem.getPlayerSettings();
			// If it's a keeper and doesn't have keeper Id.
			if (prItem.playerSortOrder == "0"
				&& ps._cKit._kitTypeId != PlayerLibrary.TYPE_KEEPER) {
				prItem.playerPoseId = ps._libraryId.toString();
			}
		}
		
		private function setPlayerPose(pId:String):void {
			_data.playerPoseId = pId;
			if (bmpIcon && _poseContainer.contains(bmpIcon)) _poseContainer.removeChild(bmpIcon);
			var ps:PlayerSettings = _data.getPlayerSettings();
			bmpIcon = PlayerIcons.getInstance().getPlayerIcon(int(_data.playerPoseId), ps._cKit._kitId, ps._cKit._kitTypeId, _btnPose, 2);
			if (bmpIcon) _poseContainer.addChild(bmpIcon);
			//var test:Object = _btnPose.getchildByName(bmpIcon.name);
		}
		// -------------------------------- End of PR Controls ------------------------------- //
		
		
		
		// ----------------------------------- Cell Renderer ----------------------------------- //
		public override function set data(d:Object):void {
			super.data = d;
			checkPoseIcon();
			
			_txtPosition.text = this.teamMgr.getPlayerPositionName(_data.playerPositionId);
			_txtName.text = teamMgr.getFormattedName(_data.playerName, _data.playerFamName);
			
			setPlayerPose(_data.playerPoseId);
		}
		
		public function set playerPosition(str:String):void {_txtPosition.text = str;}
		public function get playerPosition():String {return _txtPosition.text;}
		// -------------------------------- End of Cell Renderer ------------------------------- //
		
		
		
		// ----------------------------------- Styles ----------------------------------- //
		protected override function addRepeatedEffect():void {
			super.addRepeatedEffect();
			_txtPosition.textColor = repeatedColor;
		}
		protected override function removeRepeatedEffect():void {
			super.removeRepeatedEffect();
			_txtPosition.textColor = 0;
		}
		
		protected override function applyFormat():void {
			super.applyFormat();
			if (_blankRecord) _rF.displayPosition = false;
			_txtPosition.visible = _rF.displayPosition;
			if (_rF.displayRemove) {
				_btnRemove.buttonMode = true;
				if (!_btnRemove.hasEventListener(MouseEvent.CLICK)) _btnRemove.addEventListener(MouseEvent.CLICK, onBtnRemoveClick, false, 0, true);
			}
			if (_blankRecord) _rF.displayEdit = false;
			if (_rF.displayEdit) {
				_btnEdit.visible = _rF.displayEdit;
				_btnEdit.buttonMode = true;
				if (!_btnEdit.hasEventListener(MouseEvent.CLICK)) _btnEdit.addEventListener(MouseEvent.CLICK, onBtnEditClick, false, 0, true);
			}
			if (_blankRecord) _rF.displayPose = false;
			_btnPose.visible = _rF.displayPose;
			if (_rF.displayPose) {
				_btnNumber.visible = false;
				_btnNumber.removeEventListener(MouseEvent.CLICK, onBtnEditClick);
				_btnPose.visible = true;
				_btnPose.buttonMode = true;
				if (!_btnPose.hasEventListener(MouseEvent.CLICK)) _btnPose.addEventListener(MouseEvent.CLICK, onBtnPoseClick, false, 0, true);
			} else if (_rF.displayEdit) {
				_btnPose.visible = false;
				_btnPose.removeEventListener(MouseEvent.CLICK, onBtnPoseClick);
				_btnNumber.visible = true;
				if (!_btnNumber.hasEventListener(MouseEvent.CLICK)) _btnNumber.addEventListener(MouseEvent.CLICK, onBtnEditClick, false, 0, true);
				
			}
			this.invalidate();
		}
		// -------------------------------- End of Styles ------------------------------- //
		
		/*protected function dispose():void {
			SSPToolTip.getInstance().deleteToolTips(vSettings, true);
		}*/
	}
}