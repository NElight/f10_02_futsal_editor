package src.team.forms
{
	import fl.controls.ComboBox;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	import src.popup.PopupBox;
	import src.popup.SelectPoseFormPopupBox;
	import src.team.PRItem;
	import src.team.PRTeamManager;
	import src.team.PlayerIcons;
	import src.team.SSPTeamEvent;
	import src.team.TeamGlobals;
	import src.team.list.ColorBackgroundBox;
	
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.models.soccer.players.PlayerKitSettings;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.utils.ColorUtils;
	import src3d.utils.TextUtils;
	
	public class PRPlayerEditForm extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		
		private var _btnOK:MovieClip;
		
		private var _txtNumber:TextField;
		private var _txtName:TextField;
		private var _txtFamName:TextField;
		private var _cmbPosition:ComboBox;
		private var _btnPose:MovieClip;
		private var _poseContainer:MovieClip = new MovieClip(); // We need a container inside _btnPose to keep x,y positions.
		private var _mcNumberBg:ColorBackgroundBox = new ColorBackgroundBox();
		
		// Select Pose Form.
		private var popupSelectPose:SelectPoseFormPopupBox;
		private var bmpIcon:Bitmap = new Bitmap();
		
		private var _playerData:PRItem;
		private var isGoalkeeper:Boolean;
		
		private var _teamSide:String;
		private var _addMode:Boolean;
		
		public function PRPlayerEditForm()
		{
			this._btnOK = this.btnOK;
			this._btnOK.buttonMode = true;
			
			TextField(this.lblNumber).text = sG.interfaceLanguageDataXML.titles._teamEditNumber.text();
			TextField(this.lblPose).text = sG.interfaceLanguageDataXML.titles._teamEditModel.text();
			TextField(this.lblName).text = sG.interfaceLanguageDataXML.titles._teamEditGivenName.text();
			TextField(this.lblFamName).text = sG.interfaceLanguageDataXML.titles._teamEditFamilyName.text();
			TextField(this.lblPosition).text = sG.interfaceLanguageDataXML.titles._teamEditPosition.text();
			
			_txtNumber = this.txtNumber;
			_txtNumber.maxChars = TeamGlobals.PLAYER_NUMBER_MAX_CHARS;
			_txtName = this.txtName;
			_txtFamName = this.txtFamName;
			_cmbPosition = this.cmbPosition;
			_mcNumberBg = this.mcNumberBg;
			_cmbPosition.addEventListener(Event.CHANGE, onPositionChange);
			
			_btnPose = this.btnPose;
			_btnPose.addChild(_poseContainer);
			_btnPose.buttonMode = true;
			_btnPose.addEventListener(MouseEvent.CLICK, onSelectPose);
			
			var pleaseSelectStr:String = sG.interfaceLanguageDataXML.menu._menuPleaseSelect.text();
			_cmbPosition.prompt = pleaseSelectStr;
			_cmbPosition.dataProvider = teamMgr.getTeamPositionsDataProvider(); // Populate position.
			_cmbPosition.addItemAt( {data: 0, label:pleaseSelectStr }, 0 );
			
			_btnOK.addEventListener(MouseEvent.CLICK, onOK);
			
			initToolTips();
		}
		
		private function initToolTips():void {
			// Tooltips.
			var vSettings:Vector.<SSPToolTipSettings> = new Vector.<SSPToolTipSettings>();
			vSettings.push(new SSPToolTipSettings(_btnPose, sG.interfaceLanguageDataXML.tags._tagsBtnTeamPlayerPose.text()));
			SSPToolTip.getInstance().addToolTips(vSettings);
		}
		
		public function setPlayerData(pData:PRItem, teamSide:String, addMode:Boolean):void {
			if (!pData) return;
			_teamSide = teamSide;
			_addMode = addMode;
			_playerData = pData;
			isGoalkeeper = _playerData.playerIsGoalkeeper;
			_txtNumber.text = _playerData.playerNumber;
			_txtName.text = _playerData.playerName;
			_txtFamName.text = _playerData.playerFamName;
			var idx:int = teamMgr.getPlayerPositionIndex(_playerData.playerPositionId);
			_cmbPosition.selectedIndex = idx + 1;
			setPlayerPose(_playerData.playerPoseId);
			updateFormDesign();
			updateNumberDesign();
			if (this.stage) stage.focus = _txtNumber;
			if (_txtNumber.length > 0) _txtNumber.setSelection(_txtNumber.length, _txtNumber.length);
		}
		
		private function setPlayerPose(pId:String):void {
			if (pId == "0" || pId == "") {
				if (isGoalkeeper) {
					pId = PlayerLibrary.defaultGoalKeeperId.toString();
				} else {
					pId = PlayerLibrary.defaultPlayerId.toString();
				}
			}
			_playerData.playerPoseId = pId;
			if (bmpIcon && _btnPose.contains(bmpIcon)) _btnPose.removeChild(bmpIcon);
			var ps:PlayerSettings = _playerData.getPlayerSettings();
			var kitId:int = ps._cKit._kitId;
			var kitTypeId:int = (isGoalkeeper)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
			bmpIcon = PlayerIcons.getInstance().getPlayerIcon(int(_playerData.playerPoseId), kitId, kitTypeId, _btnPose, 2);
			if (bmpIcon) _btnPose.addChild(bmpIcon);
		}
		
		private function updateFormDesign():void {
			if (_playerData.playerRecord) {
				// Disable given name and family name edit.
				//_txtName.type = TextFieldType.INPUT;
				_txtName.selectable = false;
				_txtName.border = false;
				//_txtName.borderColor = 0x666666;
				_txtName.textColor = 0x666666;
				_txtFamName.selectable = false;
				_txtFamName.border = false;
				//_txtFamName.borderColor = 0x666666;
				_txtFamName.textColor = 0x666666;
				TextField(this.lblName).textColor = 0x666666;
				TextField(this.lblFamName).textColor = 0x666666;
			} else {
				_txtName.selectable = true;
				_txtName.border = true;
				//_txtName.borderColor = 0;
				_txtName.textColor = 0;
				_txtFamName.selectable = true;
				_txtFamName.border = true;
				//_txtFamName.borderColor = 0;
				_txtFamName.textColor = 0;
				TextField(this.lblName).textColor = 0;
				TextField(this.lblFamName).textColor = 0;
			}
		}
		
		private function onPositionChange(e:Event):void {
			//var strPlayerPositionId:String = teamMgr.getPlayerPositionId(_cmbPosition.selectedIndex);
			var strPlayerPositionId:String = (_cmbPosition.selectedItem)? _cmbPosition.selectedItem.data : "0";
			var newPositionIsGoalkeeper = teamMgr.isPlayerPositionGoalkeeper(strPlayerPositionId);
			if (newPositionIsGoalkeeper != isGoalkeeper) {
				isGoalkeeper = newPositionIsGoalkeeper;
				if (isGoalkeeper) {
					setPlayerPose(PlayerLibrary.defaultGoalKeeperId.toString());
				} else {
					setPlayerPose(PlayerLibrary.defaultPlayerId.toString());
				}
			}
			isGoalkeeper = newPositionIsGoalkeeper;
			updateNumberDesign();
		}
		
		private function updateNumberDesign():void {
			// Number style.
			if (_playerData) {
				var bgCol:uint = (isGoalkeeper)?
					uint(teamMgr.getTeamSideKitSettings(_playerData.playerTeamSide, PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS)._topColor):
					uint(teamMgr.getTeamSideKitSettings(_playerData.playerTeamSide, PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS)._topColor);
				var liCol:uint = (isGoalkeeper)?
					uint(teamMgr.getTeamSideKitSettings(_playerData.playerTeamSide, PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS)._bottomColor):
					uint(teamMgr.getTeamSideKitSettings(_playerData.playerTeamSide, PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS)._bottomColor);
				_mcNumberBg.boxSetColor(bgCol, liCol);
				_txtNumber.textColor = ColorUtils.getColorContrast(_mcNumberBg.boxBgColor); // Number text field color contrast.
			}
		}
		
		
		
		// ----------------------------------- Select Pose ----------------------------------- //
		private function onSelectPose(e:MouseEvent):void {
			if (!_playerData) return;
			var ps:PlayerSettings = _playerData.getPlayerSettings();
			var kitId:int = ps._cKit._kitId;
			var kitTypeId:int = (isGoalkeeper)? PlayerKitSettings.KIT_TYPE_ID_1_GOALKEEPERS : PlayerKitSettings.KIT_TYPE_ID_0_PLAYERS;
			// Select Pose Popup Form.
			if (!popupSelectPose) popupSelectPose = SelectPoseFormPopupBox.getInstance(this.stage);
			popupSelectPose.loadPoseIconsDP(kitId, kitTypeId); // Tells Player Icons form to load the specified kit icons.
			popupSelectPose.addEventListener(SSPTeamEvent.PLAYER_POSE_SELECT, onPoseSelected, false, 0, true); // Player Pose Listener.
			popupSelectPose.popupVisible = true;
		}
		private function onPoseSelected(e:SSPTeamEvent):void {
			removeListeners();
			var pId:String = e.eventData; // Event contains playerPoseId.
			setPlayerPose(pId);
		}
		// -------------------------------- End of Select Pose ------------------------------- //
		
		private function onOK(e:MouseEvent):void {
			updatePlayerData();
			/*var strEventName:String = "";
			if (_teamSide == PRGlobals.TEAM_OUR) {
				strEventName = (_addMode)? SSPTeamEvent.OUR_TEAM_PLAYER_ADD : SSPTeamEvent.OUR_TEAM_PLAYER_UPDATE;
			} else {
				strEventName = (_addMode)? SSPTeamEvent.OPP_TEAM_PLAYER_ADD : SSPTeamEvent.OPP_TEAM_PLAYER_UPDATE;
			}
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(strEventName, _playerData));*/
			
			if (_teamSide == TeamGlobals.TEAM_OUR) {
				sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.OUR_TEAM_UPDATE, {prItem:_playerData, addMode:_addMode}));
			} else {
				sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.OPP_TEAM_UPDATE, {prItem:_playerData, addMode:_addMode}));
			}
			
			closePopup();
		}
		
		private function updatePlayerData():void {
			// Validate fields.
			_playerData.playerNumber = TextUtils.stripASCIIPlus(_txtNumber.text);
			_playerData.playerName = TextUtils.stripHTML(_txtName.text);
			_playerData.playerFamName = TextUtils.stripHTML(_txtFamName.text);
			var strPlayerPositionId:String = (_cmbPosition.selectedItem)? _cmbPosition.selectedItem.data : "0";
			_playerData.playerPositionId = strPlayerPositionId;
		}
		
		private function removeListeners():void {
			if (popupSelectPose) popupSelectPose.removeEventListener(SSPTeamEvent.PLAYER_POSE_SELECT, onPoseSelected);
		}
		
		private function closePopup():void {
			removeListeners();
			var popupForm:PopupBox = this.parent.parent as PopupBox;
			if (!popupForm) return;
			popupForm.popupVisible = false;
		}
		
		public function get addMode():Boolean {
			return _addMode;
		}
	}
}