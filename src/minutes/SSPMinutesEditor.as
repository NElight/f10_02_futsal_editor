package src.minutes
{
	import fl.controls.ComboBox;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import src.buttons.SSPLabelButton;
	import src.events.SSPMinutesEvent;
	import src.popup.MessageBox;
	import src.team.SSPTeamEvent;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	public class SSPMinutesEditor extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mM:MinutesManager = MinutesManager.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var mB:MessageBox;
		
		// Controls.
		private var minutesDG:MinutesDataGrid;
		private var lblName:TextField;
		private var lblActivity:TextField;
		private var lblComment:TextField;
		private var cmbName:MinutesComboBoxName;
		private var cmbActivity:ComboBox;
		private var txtComment:TextField;
		private var btnAddUpdate:SSPLabelButton;
		private var btnCancelEdit:SSPLabelButton;
		private var txtMinutesHelp:TextField;
		private var minutesClock:MinutesClock;
		private var strAdd:String;
		private var strUpdate:String;
		
		private var _editorEnabled:Boolean;
		private var _controlsEnabled:Boolean;
		
		private var editRecord:MinutesItem;
		
		public function SSPMinutesEditor()
		{
			super();
			mB = main.msgBox;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// ----------------------------- Inits ----------------------------- //
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			initControls();
			initDataGrid();
			sspEventDispatcher.addEventListener(SSPEvent.LOADING_DONE, onSessionLoaded);
		}
		
		private function onSessionLoaded(e:SSPEvent):void {
			sspEventDispatcher.removeEventListener(SSPEvent.LOADING_DONE, onSessionLoaded);
			logger.addText(" - Loading minutes", false);
			initMinutesManager();
			initMinutesHelp();
			initListeners();
			refreshControlsState();
			minutesClock.updateAutoMode();
			logger.addText(" - Done", false);
		}
		
		private function initControls():void {
			var sL:XML = sG.interfaceLanguageDataXML;
			
			minutesClock = new MinutesClock();
			minutesClock.x = 0.5;
			minutesClock.y = 0.5;
			this.addChild(minutesClock);
			
			lblName = this.labelName;
			lblActivity = this.labelActivity;
			lblComment = this.labelComment;
			cmbName = this.comboName;
			cmbActivity = this.comboActivity;
			txtComment = this.textComment;
			btnAddUpdate = this.buttonAddUpdate;
			btnCancelEdit = this.buttonCancelEdit;
			
			strAdd = sL.buttons._btnMinutesAdd.text();
			strUpdate = sL.buttons._btnMinutesUpdate.text();
			btnAddUpdate.label = strAdd;
			btnCancelEdit.label = sL.buttons._btnMinutesCancelEdit.text();
			
			lblName.text = sL.titles._titleMinutesPlayerName.text();
			lblActivity.text = sL.titles._titleMinutesPlayerAction.text();
			lblComment.text = sL.titles._titleMinutesPlayerComment.text();
			
			cmbName.dropdown.setStyle("cellRenderer", ListColorNameCellRenderer);
			cmbName.prompt = sL.menu._menuPleaseSelect.text();
			var obj:Object = ComboBox.getStyleDefinition();
			cmbName.rowCount = 11;
			updatePlayerNames();
			
			cmbActivity.prompt = sL.menu._menuPleaseSelect.text();
			cmbActivity.rowCount = 11;
			cmbActivity.dataProvider = mM.getActivityDataProvider();
			
			txtComment.text = "";
		}
		
		private function initDataGrid():void {
			minutesDG = new MinutesDataGrid(this);
			minutesDG.x = minutesClock.x + minutesClock.width;
			minutesDG.y = 0.5;
			minutesDG.setSize(338.5, 98.5);
			this.addChild(minutesDG);
		}
		
		private function initMinutesManager():void {
			MinutesManager.getInstance().initReferences(this, minutesDG, minutesClock);
		}
		
		private function initMinutesHelp():void {
			txtMinutesHelp = MiscUtils.createNewTextField(minutesDG.x, minutesDG.y, minutesDG.width, minutesDG.height,
				TextFieldType.DYNAMIC, false, true, false, 11, 0, 0);
			txtMinutesHelp.htmlText = sG.interfaceLanguageDataXML.messages._helpMinutesIntro.text();
			this.addChild(txtMinutesHelp);
		}
		
		private function initTooltips():void {
			var lD:XML = sG.interfaceLanguageDataXML.tags[0];
			if (!lD || lD.length() == 0) return;
			//btnAddUpdate.setToolTipText("Tooltip");
		}
		
		private function initListeners():void {
			cmbName.addEventListener(Event.CHANGE, onNameChange, false, 0, true);
			cmbActivity.addEventListener(Event.CHANGE, onActivityChange, false, 0, true);
			btnAddUpdate.addEventListener(MouseEvent.CLICK, onAddUpdateClick, false, 0, true);
			btnCancelEdit.addEventListener(MouseEvent.CLICK, onCancelEditClick, false, 0, true);
			minutesClock.addEventListener(SSPMinutesEvent.CLICK_START_PLAY, onClockStartPlayClicked, false, 0, true);
			minutesClock.addEventListener(SSPMinutesEvent.CLICK_STOP_PLAY, onClockStopPlayClicked, false, 0, true);
		}
		
		private function onNameChange(e:Event):void {
			if (cmbName.selectedIndex == -1) {
				resetControls();
			} else {
				enableSubControls();
			}
		}
		
		private function onActivityChange(e:Event):void {
			if (cmbActivity.selectedIndex == -1) return;
			enableSubControls();
			btnAddUpdate.buttonEnabled = true;
		}
		
		private function onAddUpdateClick(e:MouseEvent):void {
			if (!editRecord) {
				addRecord();
			} else {
				updateRecord();
			}
		}
		
		private function onCancelEditClick(e:MouseEvent):void {
			cancelEdit();
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Records ----------------------------- //
		private function onClockStartPlayClicked(e:SSPMinutesEvent):void {
			var sScreen:SessionScreen = mM.getUnstartedScreen();
			if (!sScreen) {
				displayNoScreenToAdd();
				return;
			}
			if (sScreen.aPlayers.length == 0) {
				mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesNoPlayersPeriodWarning.text(), startPlayConfirmed, sScreen); 
			} else {
				startPlayConfirmed(sScreen);
			}
		}
		
		private function startPlayConfirmed(sScreen:SessionScreen):void {
			var ok:Boolean = mM.addStartPlayRecord(sScreen);
			if (ok) {
				minutesClock.clockStart();
				refreshControlsState();
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT, sScreen.screenId));
			} else {
				displayNoScreenToAdd();
			}
		}
		
		private function onClockStopPlayClicked(e:SSPMinutesEvent):void {
			var strTimeInSeconds:String = minutesClock.getTimeInSeconds();
			var sScreen:SessionScreen = mM.getUnfinishedScreen();
			var ok:Boolean = mM.addStopPlayRecord(sScreen, strTimeInSeconds);
			if (ok) {
				minutesClock.clockStop();
				refreshControlsState();
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT, sScreen.screenId));
			} else {
				this.displayStopTimeError();
			}
		}
		
		private function addRecord():void {
			var sScreen:SessionScreen;
			var strTimeInSeconds:String;
			var playerDataItem:MinutesPlayerItem;
			var teamSideCode:String = "";
			var teamPlayerId:String = "";
			var activityCode:String = "";
			var strComment:String = txtComment.text;
			
			if (cmbName.selectedItem) {
				playerDataItem = cmbName.selectedItem as MinutesPlayerItem;
				teamPlayerId = playerDataItem.teamPlayerId;
				teamSideCode = playerDataItem.teamSideCode;
			} else {
				displayCantAdd();
			}
			
			if (cmbActivity.selectedItem) {
				activityCode = cmbActivity.selectedItem.data;
			} else {
				displayCantAdd();
			}
			
			// Avoid activities.
			if (activityCode == "" ||
				activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY ||
				activityCode == MinutesGlobals.ACTIVITY_LINE_UP
			) {
				return;
			}
			
			strTimeInSeconds = minutesClock.getTimeInSeconds();
			sScreen = mM.getScreenFromTime(strTimeInSeconds);
			
			if (!sScreen) {
				displayGeneralTimeError();
				return;
			}
			
			if (!sScreen.periodMinutes.hasStartPlay) {
				displayGeneralTimeError();
				return;
			}
			var ok:Boolean = mM.addMinutesRecord(sScreen, strTimeInSeconds, activityCode, teamPlayerId, teamSideCode, strComment);
			resetControls();
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT, sScreen.screenId));
			if (MinutesGlobals.getInstance().autoMode && ok && activityCode == MinutesGlobals.ACTIVITY_RED_CARD) {
				// Notify Red Card to remove player from 3D Screen.
				sspEventDispatcher.dispatchEvent(new SSPMinutesEvent(SSPMinutesEvent.TEAM_PLAYER_RED_CARD, {screen:sScreen, teamPlayerId:teamPlayerId, teamSide:teamSideCode}));
			}
		}
		
		private function updateRecord():void {
			if (!editRecord) return;
			// Get data.
			var activityCode:String = (cmbActivity.selectedItem)? cmbActivity.selectedItem.data : "";
			var strComment:String = txtComment.text;
			var playerDataItem:MinutesPlayerItem;
			var teamPlayerId:String = "";
			var teamSideCode:String = "";
			if (cmbName.selectedItem) {
				playerDataItem = cmbName.selectedItem as MinutesPlayerItem;
				teamPlayerId = playerDataItem.teamPlayerId;
				teamSideCode = playerDataItem.teamSideCode;
			}
			var ok:Boolean = mM.editMinutesRecord(editRecord, teamPlayerId, teamSideCode, activityCode, strComment);
			if (!ok) {
				displayGeneralTimeError();
			} else {
				if (MinutesGlobals.getInstance().autoMode && ok && activityCode == MinutesGlobals.ACTIVITY_RED_CARD) {
					// Notify Red Card to remove player from 3D Screen.
					var sScreen:SessionScreen = SessionScreenUtils.getScreenFromScreenId(int(editRecord.screenId), main.sessionView.aScreens);
					sspEventDispatcher.dispatchEvent(new SSPMinutesEvent(SSPMinutesEvent.TEAM_PLAYER_RED_CARD, {screen:sScreen, teamPlayerId:teamPlayerId, teamSide:teamSideCode}));
				}
			}
			editRecord = null; // Remove edit record.
			resetControls();
		}
		
		public function removeRecord(mItem:MinutesItem):void {
			if (!mItem) return;
			var mIdx:int;
			// If button is Start/Stop Play, delete only if it's the last record.
			if (mItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				mIdx = minutesDG.dataProvider.getItemIndex(mItem);
				if (mIdx != minutesDG.length -1) {
					displayCantDelete();
					return;
				}
			}
			mM.removeMinutesItem(mItem);
			if (editRecord) {
				editRecord = null;
			} else {
				//refreshControlsState();
			}
			resetControls();
			refreshControlsState();
		}
		
		public function setEditRecord(mItem:MinutesItem):void {
			if (!mItem) return;
			var mIdx:int;
			// If button is Start/Stop Play, edit only if it's the last record.
			if (mItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY ||
				mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				mIdx = minutesDG.dataProvider.getItemIndex(mItem);
				if (mIdx == 0 && mItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY) {
					displayGeneralTimeError();
					return;
				}
				if (mIdx != minutesDG.length -1 && mItem.activityCode != MinutesGlobals.ACTIVITY_STOP_PLAY) {
					displayCantEdit();
					return;
				}
			}
			editRecord = mItem;
			minutesClock.switchToManual();
			minutesClock.setTimeInSeconds(editRecord.timeInSeconds);
			selectPlayerName(editRecord.teamPlayerId, editRecord.teamSideCode);
			selectActivityName(editRecord.activityCode);
			txtComment.text = editRecord.Comment;
			refreshAddUpdateLabel();
			if (mItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY || mItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
				cmbName.enabled = false;
				cmbActivity.enabled = false;
				btnAddUpdate.buttonEnabled = true;
			} else {
				cmbName.enabled = true;
				cmbName.drawNow();
				cmbActivity.enabled = true;
				cmbActivity.drawNow();
			}
			btnAddUpdate.buttonEnabled = true;
			btnCancelEdit.buttonEnabled = true;
		}
		
		private function cancelEdit():void {
			editRecord = null; // Remove edit record.
			resetControls();
		}
		// -------------------------- End of Records ------------------------- //
		
		
		
		// ----------------------------- Messages ----------------------------- //
		private function displayCantAdd():void {
			mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesCantAddError.text());
		}
		private function displayCantEdit():void {
			mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesCantBeEditedError.text());
		}
		private function displayCantDelete():void {
			mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesCantBeDeletedError.text());
		}
		private function displayNoScreenToAdd():void {
			mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesNoPeriodScreenError.text());
		}
		private function displayGeneralTimeError():void {
			mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesGeneralTimeError.text());
		}
		private function displayStopTimeError():void {
			mB.displayMsgBox(sG.interfaceLanguageDataXML.messages._minutesStopTimeError.text());
		}
		// -------------------------- End of Messages ------------------------- //
		
		
		
		// ----------------------------- Controls ----------------------------- //
		private function refreshAddUpdateLabel():void {
			if (cmbName.selectedIndex > -1 && cmbActivity.selectedIndex > -1) {
				btnAddUpdate.buttonEnabled = true;
			} else {
				btnAddUpdate.buttonEnabled = false;
				btnCancelEdit.buttonEnabled = false; // Only enabled by editing a record.
			}
			btnAddUpdate.label = (editRecord)? strUpdate : strAdd;
		}
		
		public function selectPlayerName(teamPlayerId:String, teamSideCode:String):void {
			if (!_editorEnabled) return;
			var item:MinutesPlayerItem;
			var aDP:Array = cmbName.dataProvider.toArray();
			for (var i:uint = 0;i<aDP.length;i++) {
				if (aDP[i]) {
					item = aDP[i] as MinutesPlayerItem;
					if (item) {
						if (item.teamPlayerId == teamPlayerId && item.teamSideCode == teamSideCode) {
							cmbName.selectedIndex = i;
							enableSubControls();
							return;
						}
					}
				}
			}
			deselectPlayerName();
			
		}
		public function deselectPlayerName():void {
			cmbName.selectedIndex = -1;
			resetControls();
		}
		
		private function selectActivityName(activityCode:String):void {
			var item:String;
			var aDP:Array = cmbActivity.dataProvider.toArray();
			for (var i:uint = 0;i<aDP.length;i++) {
				if (aDP[i] && aDP[i].data) {
					item = String(aDP[i].data);
					if (item == activityCode) {
						cmbActivity.selectedIndex = i;
						return;
					}
				}
			}
			cmbActivity.selectedIndex = -1;
		}
		
		private function setControlsEnabled(value:Boolean):void {
			_controlsEnabled = value;
			btnAddUpdate.buttonEnabled = false;
			btnCancelEdit.buttonEnabled = false; // Only enabled by editing a record.
			cmbName.enabled = value;
			cmbName.drawNow();
			cmbActivity.enabled = false;
			cmbActivity.drawNow();
			txtComment.type = TextFieldType.DYNAMIC;
			txtComment.selectable = false;
			if (txtMinutesHelp) txtMinutesHelp.visible = (value)? false : true;
		}
		
		private function enableSubControls():void {
			//btnAddUpdate.buttonEnabled = true;
			//btnCancelEdit.buttonEnabled = false; // Only enabled by editing a record.
			cmbName.enabled = true;
			cmbName.drawNow();
			cmbActivity.enabled = true;
			cmbActivity.drawNow();
			txtComment.type = TextFieldType.INPUT;
			txtComment.selectable = true;
		}
		
		private function resetControls():void {
			cmbName.selectedIndex = -1;
			cmbActivity.selectedIndex = -1;
			txtComment.text = "";
			//setControlsEnabled(true);
			refreshAddUpdateLabel();
			refreshControlsState();
		}
		
		private function refreshControlsState():void {
			var dataGridEmpty:Boolean = (minutesDG.length > 0)? false : true;
			if (!dataGridEmpty) {
				setControlsEnabled(true);
			} else {
				setControlsEnabled(false);
				minutesClock.clockStopAndReset();
			}
		}
		// -------------------------- End of Controls ------------------------- //
		
		
		
		// ----------------------------- Public ----------------------------- //
		public function updatePlayerNames():void {
			cmbName.dataProvider = mM.getPlayerNamesDataProvider();
			cmbName.selectedIndex = -1;
		}
		
		public function get editorEnabled():Boolean {
			return _editorEnabled;
		}
		
		public function set editorEnabled(value:Boolean):void {
			_editorEnabled = value;
			/*if (_editorEnabled) {
				this.visible = true;
			} else {
				this.visible = false;
			}*/
			refreshControlsState();
		}
		
		public function resetMinutes():void {
			mM.resetMinutes();
			refreshControlsState();
		}
		
		public function updateScoreAndTimeSpent():void {
			mM.updateScoreAndTimeSpent();
		}
		// -------------------------- End of Public ------------------------- //
	}
}