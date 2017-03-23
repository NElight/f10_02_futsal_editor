package src.team
{
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import fl.data.DataProvider;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import src.buttons.SSPButtonOnOff;
	import src.buttons.SSPLabelButton;
	import src.minutes.MinutesGlobals;
	import src.minutes.MinutesManager;
	import src.popup.MessageBox;
	import src.team.list.PRCContainerOpposition;
	import src.team.list.PRCContainerOurTeam;
	import src.team.list.PRCListOpposition;
	import src.team.list.PRCListOurTeam;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.TextUtils;
	
	public class PRTeamSettings extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var tG:TeamGlobals = TeamGlobals.getInstance();
		private var mG:MinutesGlobals = MinutesGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		
		// Team Settings Controls.
		private var cmbTeamPlayersPerTeam:ComboBox;
		private var cmbTeamWePlay:ComboBox;
		private var btnTMinutesEnabled:SSPButtonOnOff;
		
		// Screen Settings Controls.
		private var gradientP:MovieClip;
		private var gradientS:MovieClip;
		private var txtScreenTitle:TextField;
		private var cmbScreenFormationOurs:ComboBox;
		private var cmbScreenFormationOpposition:ComboBox;
		private var strScreenFormat:String = "";
		private var rdoScreenP1:RadioButton; // Period - My Team.
		private var rdoScreenP2:RadioButton; // Period - Two Teams.
		private var rdoGrpScreenFormat:RadioButtonGroup;
		private var btnScreenAutoLayoutPitch:SSPLabelButton;
		private var cmbScreenPlayerNameFormat:ComboBox;
		private var cbxScreenPlayerNameDisplay:CheckBox;
		private var cmbScreenPlayerModelFormat:ComboBox;
		private var cbxScreenPlayerModelDisplay:CheckBox;
		private var cbxScreenPlayerPositionDisplay:CheckBox;
		private var cbxScreenPlayerOmitIdentity:CheckBox;
		private var aPitchLayoutControls:Array = [];
		private var icoPlayer:MovieClip;
		private var icoDisc:MovieClip;
		
		// Team Lists.
		private var listOur:PRCContainerOurTeam;
		private var listOpp:PRCContainerOpposition;
		private var oldMaxPlayersIdx:uint;
		
		private var sXML:XML; // Current Screen XML.
		private var currentFormations:Vector.<SSPFormation>;
		private var currentFormationsNames:Array;
		
		public function PRTeamSettings()
		{
			super();
		}
		
		public function initSettings(listOurTeam:PRCContainerOurTeam, listOppTeam:PRCContainerOpposition):void {
			this.listOur = listOurTeam;
			this.listOpp = listOppTeam;
			
			var tfH1:TextFormat = TextField(this.txtTeamSettings).getTextFormat();
			tfH1.align = TextFormatAlign.CENTER;
			tfH1.bold = true;
			tfH1.size = 16;
			var tfH2:TextFormat = TextField(this.txtTeamSettings).getTextFormat();
			tfH2.align = TextFormatAlign.LEFT;
			tfH2.bold = true;
			tfH2.size = 14;
			var tfH3:TextFormat = TextField(this.txtTeamSettings).getTextFormat();
			tfH3.align = TextFormatAlign.LEFT;
			tfH3.bold = false;
			tfH3.size = 12;
			
			// Team Settings Labels.
			TextField(this.txtTeamSettings).defaultTextFormat = tfH1;
			TextField(this.txtTeamSettings).text = sG.interfaceLanguageDataXML.titles._titleSettingsTeams.text();
			TextField(this.txtTPlayersPerTeam).defaultTextFormat = tfH2;
			TextField(this.txtTPlayersPerTeam).text = sG.interfaceLanguageDataXML.titles._teamPlayersPerTeam.text();
			TextField(this.txtTWePlay).defaultTextFormat = tfH2;
			TextField(this.txtTWePlay).text = sG.interfaceLanguageDataXML.titles._teamWePlay.text();
			TextField(this.txtTMinutesEnabled).defaultTextFormat = tfH2;
			TextField(this.txtTMinutesEnabled).text = sG.interfaceLanguageDataXML.titles._teamUseMinutes.text();
			
			// Team Settings Controls.
			cmbTeamPlayersPerTeam = this.cmbTPlayersPerTeam;
			cmbTeamPlayersPerTeam.textField.setStyle("textFormat", tfH3);
			cmbTeamPlayersPerTeam.rowCount = SSPSettings.DEFAULT_ROW_COUNT;
			cmbTeamWePlay = this.cmbTWePlay;
			cmbTeamWePlay.textField.setStyle("textFormat", tfH3);
			cmbTeamWePlay.rowCount = SSPSettings.DEFAULT_ROW_COUNT;
			btnTMinutesEnabled = this.buttonTMinutesEnabled;
			
			// Screen Settings Labels.
			txtScreenTitle = this.txtSScreenTitle;
			txtScreenTitle.defaultTextFormat = tfH1;
			TextField(this.txtSShowOnPitch).text = sG.interfaceLanguageDataXML.titles._teamShowOnPitch.text();
			TextField(this.txtSShowOnPitch).setTextFormat(tfH2);
			TextField(this.txtSPlayerPositionDisplay).text = sG.interfaceLanguageDataXML.titles._teamPlayerPosition.text();
			
			// Screen Settings Controls.
			gradientP = this.gradientPeriod;
			gradientS = this.gradientSetPiece;
			cmbScreenPlayerNameFormat = this.cmbSPlayerNameFormat;
			cmbScreenPlayerNameFormat.textField.setStyle("textFormat", tfH3);
			cmbScreenPlayerNameFormat.rowCount = SSPSettings.DEFAULT_ROW_COUNT;
			cbxScreenPlayerNameDisplay = this.cbxSPlayerNameDisplay;
			cmbScreenPlayerModelFormat = this.cmbSPlayerModelFormat;
			cmbScreenPlayerModelFormat.textField.setStyle("textFormat", tfH3);
			cmbScreenPlayerModelFormat.rowCount = SSPSettings.DEFAULT_ROW_COUNT;
			cbxScreenPlayerModelDisplay = this.cbxSPlayerModelDisplay;
			cbxScreenPlayerPositionDisplay = this.cbxSPlayerPositionDisplay;
			
			
			// Screen Settings - Pitch Layout.
			TextField(this.txtSPitchLayout).text = sG.interfaceLanguageDataXML.titles._teamPitchLayout.text();
			TextField(this.txtSPitchLayout).setTextFormat(tfH2);
			TextField(this.txtSFormationOurs).text = sG.interfaceLanguageDataXML.titles._teamPitchFormationOurs.text();
			TextField(this.txtSFormationOpposition).text = sG.interfaceLanguageDataXML.titles._teamPitchFormationOpposition.text();
			TextField(this.txtSPlayerOmitIdentity).text = sG.interfaceLanguageDataXML.titles._teamOmitPlayerIdentity.text();
			cmbScreenFormationOurs = this.cmbSFormationOurs;
			cmbScreenFormationOurs.textField.setStyle("textFormat", tfH3);
			cmbScreenFormationOurs.rowCount = SSPSettings.DEFAULT_ROW_COUNT;
			cmbScreenFormationOurs.addEventListener(Event.CHANGE, onSettingsChange);
			cmbScreenFormationOpposition = this.cmbSFormationOpposition;
			cmbScreenFormationOpposition.textField.setStyle("textFormat", tfH3);
			cmbScreenFormationOpposition.rowCount = SSPSettings.DEFAULT_ROW_COUNT;
			cmbScreenFormationOpposition.addEventListener(Event.CHANGE, onSettingsChange);
			rdoScreenP1 = this.rdoSP1;
			rdoScreenP2 = this.rdoSP2;
			rdoGrpScreenFormat = rdoScreenP1.group;
			rdoGrpScreenFormat.addEventListener(Event.CHANGE, onSettingsChange);
			btnScreenAutoLayoutPitch = this.btnSAutoLayoutPitch;
			cbxScreenPlayerOmitIdentity = this.cbxSPlayerOmitIdentity;
			icoPlayer = this.mcIconPlayer;
			icoPlayer.visible = false;
			icoDisc = this.mcIconDisc;
			icoDisc.visible = false;
			
			// Pitch Layout Array.
			aPitchLayoutControls = [
				this.txtSPitchLayout,
				this.txtSFormationOurs,
				this.txtSFormationOpposition,
				this.txtSPlayerOmitIdentity,
				cmbScreenFormationOurs,
				cmbScreenFormationOpposition,
				rdoScreenP1,
				rdoScreenP2,
				btnScreenAutoLayoutPitch,
				cbxScreenPlayerOmitIdentity,
				this.mcSPitchLayoutFrame
			];
			
			initTeamSettings();
			initScreenSettings();
			initLists();
			saveToXML();
		}
		
		private function initTeamSettings():void {
			var aDataProvider:Array;
			var uintCmbValue:uint;
			var strCmbValue:String;
			var intIdx:int;
			
			// Team - Players Per Team.
			aDataProvider = TeamGlobals.getInstance().aPlayersPerTeam;
			if (String(sG.sessionDataXML.session._teamPlayersPerTeam.text()) == "") {
				uintCmbValue = TeamGlobals.getInstance().aPlayersPerTeam[0];
				Logger.getInstance().addError("_teamPlayersPerTeam Missing or Empty value. Using '"+uintCmbValue+"' as default.");
			} else {
				uintCmbValue = uint(sG.sessionDataXML.session._teamPlayersPerTeam.text());
			}
			intIdx = aDataProvider.indexOf(uintCmbValue);
			if (intIdx < 0) intIdx = aDataProvider.length - 1; // Use default element.
			cmbTeamPlayersPerTeam.dataProvider = new DataProvider(aDataProvider);
			cmbTeamPlayersPerTeam.selectedIndex = oldMaxPlayersIdx = intIdx;
			cmbTeamPlayersPerTeam.addEventListener(Event.CHANGE, onSettingsChange);
			
			// Team - We Play.
			aDataProvider = [{label:String(sG.interfaceLanguageDataXML.options._teamWePlayHome.text()), data:tG.aWePlay[0]},
				{label:String(sG.interfaceLanguageDataXML.options._teamWePlayAway.text()), data:tG.aWePlay[1]}];
			strCmbValue = sG.sessionDataXML.session._teamWePlay.text();
			intIdx = tG.aWePlay.indexOf(strCmbValue);
			if (intIdx < 0) intIdx = 0; // Use default element.
			cmbTeamWePlay.dataProvider = new DataProvider(aDataProvider);
			cmbTeamWePlay.selectedIndex = intIdx;
			cmbTeamWePlay.addEventListener(Event.CHANGE, onSettingsChange);
			
			// Team - Minutes.
			mG.matchMinutes = sG.sessionDataXML.session._matchMinutes.text();
			btnTMinutesEnabled.buttonON = mG.useMinutes;
			btnTMinutesEnabled.addEventListener(MouseEvent.MOUSE_DOWN, onToggleMinutes);
			
			// Validate in case invalid values.
			sG.sessionDataXML.session._teamPlayersPerTeam = String(cmbTeamPlayersPerTeam.dataProvider.getItemAt(cmbTeamPlayersPerTeam.selectedIndex).data);
			teamMgr.setWePlay(cmbTeamWePlay.selectedIndex);
		}
		
		private function initScreenSettings():void {
			updateTeamPlayersPerTeam();
			
			// Screen - Player Name Format.
			cmbScreenPlayerNameFormat.dataProvider = new DataProvider(tG.aNameFormat);
			cmbScreenPlayerNameFormat.addEventListener(Event.CHANGE, onSettingsChange);
			
			// Screen - Player Model Format.
			cmbScreenPlayerModelFormat.dataProvider = new DataProvider(tG.aPlayerModelFormat);
			cmbScreenPlayerModelFormat.addEventListener(Event.CHANGE, onSettingsChange);
			
			cbxScreenPlayerNameDisplay.addEventListener(Event.CHANGE, onSettingsChange);
			cbxScreenPlayerModelDisplay.addEventListener(Event.CHANGE, onSettingsChange);
			cbxScreenPlayerPositionDisplay.addEventListener(Event.CHANGE, onSettingsChange);
			cbxScreenPlayerOmitIdentity.addEventListener(Event.CHANGE, onSettingsChange);
			
			// Screen - Period / Set Pieces.
			rdoScreenP1.textField.multiline = rdoScreenP1.textField.wordWrap = true;
			rdoScreenP2.textField.multiline = rdoScreenP2.textField.wordWrap = true;
			rdoScreenP1.label = sG.interfaceLanguageDataXML.options._teamLayoutPeriodMy.text();
			rdoScreenP2.label = sG.interfaceLanguageDataXML.options._teamLayoutPeriodTwo.text();
			rdoScreenP1.value = TeamGlobals.SCREEN_FORMATION_P1;
			rdoScreenP2.value = TeamGlobals.SCREEN_FORMATION_P2;
			btnScreenAutoLayoutPitch.label = sG.interfaceLanguageDataXML.buttons[0]._btnTeamApplyLayout.text();
			btnScreenAutoLayoutPitch.isToggleButton = false;
			btnScreenAutoLayoutPitch.addEventListener(MouseEvent.CLICK, onAutoLayoutPitch);
			
			//var sId:int = SessionScreenUtils.getMinScreenId();
			//if (sId > -1)updateScreenSettings(sId);
		}
		
		public function updateScreenSettings(sId:uint, tabGroupChanged:Boolean):void {
			// Note: 3D Screen updates itself from XML.
			
			sXML = teamMgr.getScreenXML(sId);
			var intIdx:int;
			var defVal:String;
			var textLength:uint = 16;
			var strTitle:String = sXML._screenTitle.text();
			var strScreenType:String = sXML._screenType.text();
			if (strScreenType == "") strScreenType = SessionGlobals.SCREEN_TYPE_SCREEN;
			strTitle = TextUtils.htmlToText(strTitle);
			txtScreenTitle.text = "'" + MiscUtils.cropText(strTitle, textLength) + "'";
			if (strScreenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
				gradientP.visible = false;
				gradientS.visible = true;
				if (tabGroupChanged) {
					// Apply Screen default settings.
					sXML._screenPlayerNameDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_S1_NAME_DISPLAY);
					sXML._screenPlayerModelDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_S1_MODEL_DISPLAY);
					sXML._screenPlayerPositionDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_S1_POSITION_DISPLAY);
				}
				sXML._screenFormat = TeamGlobals.SCREEN_FORMATION_S1;
				togglePitchLayoutControls(false);
			} else {
				gradientP.visible = true;
				gradientS.visible = false;
				if (tabGroupChanged) {
					// Apply Screen default settings.
					sXML._screenPlayerNameDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_P1_NAME_DISPLAY);
					sXML._screenPlayerModelDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_P1_MODEL_DISPLAY);
					sXML._screenPlayerPositionDisplay = MiscUtils.booleanToString(TeamGlobals.DEFAULTS_P1_POSITION_DISPLAY);
				}
				if (sXML._screenFormat == TeamGlobals.SCREEN_FORMATION_S1) sXML._screenFormat = TeamGlobals.SCREEN_FORMATION_P1;
				togglePitchLayoutControls(true);
			}
			
			intIdx = PRTeamManager.getInstance().getFormationIndex(sXML._screenFormationOurs.text(), currentFormations);
			//var isError:Boolean = (sXML._screenType != SessionGlobals.SCREEN_TYPE_PERIOD)? false : true;
			var isError:Boolean = false; // Disable the Error so messages gets logged as Alert.
			var strMsg:String;
			if (intIdx < 0) {
				intIdx = 0;
				defVal = currentFormations[intIdx].name;
				strMsg = "Can't find _screenFormationOurs '"+sXML._screenFormationOurs.text()+
					"' for _teamPlayersPerTeam '"+sG.sessionDataXML.session._teamPlayersPerTeam.text()+"'. Using '"+defVal+"' as default.";
				if (isError) {
					Logger.getInstance().addError(strMsg);
				} else {
					Logger.getInstance().addAlert(strMsg);
				}
				sXML._screenFormationOurs = defVal;
			}
			//sXML._screenFormationOurs = intIdx.toString();
			cmbScreenFormationOurs.selectedIndex = intIdx;
			intIdx = PRTeamManager.getInstance().getFormationIndex(sXML._screenFormationOpposition.text(), currentFormations);
			if (intIdx < 0) {
				intIdx = 0;
				defVal = currentFormations[intIdx].name;
				strMsg = "Can't find _screenFormationOpposition '"+sXML._screenFormationOpposition.text()+
					"' for _teamPlayersPerTeam '"+sG.sessionDataXML.session._teamPlayersPerTeam.text()+"'. Using '"+defVal+"' as default.";
				if (isError) {
					Logger.getInstance().addError(strMsg);
				} else {
					Logger.getInstance().addAlert(strMsg);
				}
				sXML._screenFormationOpposition = defVal;
			}
			cmbScreenFormationOpposition.selectedIndex = intIdx;
			
			intIdx = uint(sXML._screenPlayerNameFormat.text());
			if (intIdx < 0) intIdx = 0; // Use default element.
			cmbScreenPlayerNameFormat.selectedIndex = intIdx;
			
			intIdx = uint(sXML._screenPlayerModelFormat.text());
			if (intIdx < 0) intIdx = 0; // Use default element.
			cmbScreenPlayerModelFormat.selectedIndex = intIdx;
			
			cbxScreenPlayerNameDisplay.selected = MiscUtils.stringToBoolean(sXML._screenPlayerNameDisplay.text());
			cbxScreenPlayerModelDisplay.selected = MiscUtils.stringToBoolean(sXML._screenPlayerModelDisplay.text());
			cbxScreenPlayerPositionDisplay.selected = MiscUtils.stringToBoolean(sXML._screenPlayerPositionDisplay.text());
			
			cmbScreenPlayerModelFormat.enabled = cbxScreenPlayerModelDisplay.selected;
			cmbScreenPlayerModelFormat.drawNow();
			cmbScreenPlayerNameFormat.enabled = cbxScreenPlayerNameDisplay.selected;
			cmbScreenPlayerNameFormat.drawNow();
			
			selectScreenFormation(sXML._screenFormat.text());
			
			updateIcons();
		}
		
		private function initLists():void {
			listOur.initList(new PRCListOurTeam(true), teamMgr.teamOursXML, sG.usePlayerRecords);
			listOpp.initList(new PRCListOpposition(true), teamMgr.teamOppXML, false);
			updateLists();
		}
		
		private function updateLists():void {
			updateTeamPlayersPerTeam();
		}
		
		
		
		// ----------------------------- Handlers ----------------------------- //
		private function onSettingsChange(e:Event):void {
			var cName:String = e.target.name;
			if (!cName || cName == "") return;
			switch(cName) {
				// Team Settings.
				case cmbTeamPlayersPerTeam.name:
					updateTeamPlayersPerTeam();
					break;
				case cmbTeamWePlay.name:
					teamMgr.setWePlay(cmbTeamWePlay.selectedIndex);
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.MINUTES_UPDATE_SCORE_MODE, mG.useMinutes));
					break;
				case cbxScreenPlayerOmitIdentity.name:
					sG.omitTeamPlayerId = cbxScreenPlayerOmitIdentity.selected;
					break;
				case cbxScreenPlayerModelDisplay.name:
					cmbScreenPlayerModelFormat.enabled = cbxScreenPlayerModelDisplay.selected;
					cmbScreenPlayerModelFormat.drawNow();
					break;
				case cbxScreenPlayerNameDisplay.name:
					cmbScreenPlayerNameFormat.enabled = cbxScreenPlayerNameDisplay.selected;
					cmbScreenPlayerNameFormat.drawNow();
					break;
			}
			saveToXML();
			updateScreenPlayerSettings();
		}
		// -------------------------- End of Handlers ------------------------- //
		
		
		
		// ----------------------------- Minutes ----------------------------- //
		private function onToggleMinutes(e:MouseEvent):void {
			mG.useMinutes = (btnTMinutesEnabled.buttonON)? false : true;
			if (btnTMinutesEnabled.buttonON && MinutesManager.getInstance().hasMinutes) {
				// Ask for user confirmation.
				var strMsg:String = sG.interfaceLanguageDataXML.messages._teamUseMinutesOffWarning.text();
				main.msgBox.popupEnabled = true;
				main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onMsgBoxOK, false, 0, true);
				main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onMsgBoxCancel, false, 0, true);
				main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK_CANCEL);
			} else {
				toggleMinutes();
			}
		}
		
		private function onMsgBoxOK(e:Event):void {
			removeMsgBox();
			btnTMinutesEnabled.buttonON = false;
			mG.useMinutes = false;
			toggleMinutes();
		}
		
		private function onMsgBoxCancel(e:Event):void {
			removeMsgBox();
		}
		
		private function removeMsgBox():void {
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onMsgBoxOK);
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onMsgBoxCancel);
			main.msgBox.popupVisible = false;
		}
		
		private function toggleMinutes():void {
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.MINUTES_ENABLED, mG.useMinutes));
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.MINUTES_UPDATE_SCORE_MODE, mG.useMinutes));
		}
		// -------------------------- End of Minutes ------------------------- //
		
		
		
		// ----------------------------- Actions ----------------------------- //
		private function updateTeamPlayersPerTeam():void {
			var ppTeam:uint = cmbTeamPlayersPerTeam.dataProvider.getItemAt(cmbTeamPlayersPerTeam.selectedIndex).data;
			currentFormations = TeamGlobals.getInstance().getFormationList(ppTeam);
			currentFormationsNames = TeamGlobals.getInstance().getFormationListNames(ppTeam);
			cmbScreenFormationOurs.dataProvider = new DataProvider(currentFormationsNames);
			cmbScreenFormationOpposition.dataProvider = new DataProvider(currentFormationsNames);
			cmbScreenFormationOurs.selectedIndex = 0;
			cmbScreenFormationOpposition.selectedIndex = 0;
		}
		
		private function updateScreenPlayerSettings():void {
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.SCREEN_SETTINGS_PLAYER_UPDATE));
			updateIcons();
		}
		
		private function updateIcons():void {
			if (cbxScreenPlayerModelDisplay.selected) {
				icoPlayer.visible = true;
				icoDisc.visible = false;
			} else {
				icoPlayer.visible = false;
				icoDisc.visible = true;
			}
		}
		// -------------------------- End of Actions ------------------------- //
		
		
		// ----------------------------- Pitch Layout ----------------------------- //
		private function togglePitchLayoutControls(value:Boolean):void {
			for each(var obj:DisplayObject in aPitchLayoutControls) {
				obj.visible = value;
			}
		}
		
		private function onAutoLayoutPitch(e:MouseEvent):void {
			var ourTeamFormation:SSPFormation = currentFormations[cmbScreenFormationOurs.selectedIndex];
			var oppTeamFormation:SSPFormation = currentFormations[cmbScreenFormationOpposition.selectedIndex];
			if (!ourTeamFormation || !oppTeamFormation) return;
			
			sXML._screenFormat = rdoGrpScreenFormat.selectedData; // P1, P2, S1.
			
			if (sXML._screenFormat.text() == TeamGlobals.SCREEN_FORMATION_P1) {
				/*cmbScreenPlayerNameFormat.selectedIndex = tG.aNameFormat.indexOf("Family Name");
				cmbScreenPlayerModelFormat.selectedIndex = tG.aPlayerModelFormat.indexOf("Player Model + Number");
				cbxScreenPlayerNameDisplay.selected = TeamGlobals.DEFAULTS_P1_NAME_DISPLAY;
				cbxScreenPlayerModelDisplay.selected = TeamGlobals.DEFAULTS_P1_MODEL_DISPLAY;
				cbxScreenPlayerPositionDisplay.selected = TeamGlobals.DEFAULTS_P1_POSITION_DISPLAY;*/
			} else if (sXML._screenFormat.text() == TeamGlobals.SCREEN_FORMATION_P2) {
				/*cmbScreenPlayerNameFormat.selectedIndex = tG.aNameFormat.indexOf("Family Name");
				cmbScreenPlayerModelFormat.selectedIndex = tG.aPlayerModelFormat.indexOf("Player Model + Number");
				cbxScreenPlayerNameDisplay.selected = TeamGlobals.DEFAULTS_P2_NAME_DISPLAY;
				cbxScreenPlayerModelDisplay.selected = TeamGlobals.DEFAULTS_P2_MODEL_DISPLAY;
				cbxScreenPlayerPositionDisplay.selected = TeamGlobals.DEFAULTS_P2_POSITION_DISPLAY;*/
			} else if (sXML._screenFormat.text() == TeamGlobals.SCREEN_FORMATION_S1) {
				/*cbxScreenPlayerNameDisplay.selected = TeamGlobals.DEFAULTS_S1_NAME_DISPLAY;
				cbxScreenPlayerModelDisplay.selected = TeamGlobals.DEFAULTS_S1_MODEL_DISPLAY;
				cbxScreenPlayerPositionDisplay.selected = TeamGlobals.DEFAULTS_S1_POSITION_DISPLAY;*/
			}
			
			saveToXML();
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.SCREEN_SETTINGS_AUTO_LAYOUT_PITCH, {ourFormation:ourTeamFormation, oppFormation:oppTeamFormation}));
			updateScreenSettings(uint(sXML._screenId.text()), false);
		}
		
		private function saveToXML():void {
			if (!sXML) return;
			// Team Settings. 'We play' and 'Use Minutes' are saved on change.
			sG.sessionDataXML.session._teamPlayersPerTeam = String(cmbTeamPlayersPerTeam.dataProvider.getItemAt(cmbTeamPlayersPerTeam.selectedIndex).data); // Players per team.
			
			var ourTeamFormation:SSPFormation = currentFormations[cmbScreenFormationOurs.selectedIndex];
			var oppTeamFormation:SSPFormation = currentFormations[cmbScreenFormationOpposition.selectedIndex];
			if (ourTeamFormation && oppTeamFormation) {
				sXML._screenFormationOurs = ourTeamFormation.name;
				sXML._screenFormationOpposition = oppTeamFormation.name;
			}
			
			sXML._screenPlayerNameFormat = cmbScreenPlayerNameFormat.selectedIndex.toString();
			sXML._screenPlayerModelFormat = cmbScreenPlayerModelFormat.selectedIndex.toString();
			sXML._screenPlayerNameDisplay = MiscUtils.booleanToString(cbxScreenPlayerNameDisplay.selected);
			sXML._screenPlayerModelDisplay = MiscUtils.booleanToString(cbxScreenPlayerModelDisplay.selected);
			sXML._screenPlayerPositionDisplay = MiscUtils.booleanToString(cbxScreenPlayerPositionDisplay.selected);
			sXML._screenFormat = rdoGrpScreenFormat.selectedData; // P1, P2, S1.
			sG.omitTeamPlayerId = cbxScreenPlayerOmitIdentity.selected;
			
			// Screen Defaults.
			var strScreenType:String = sXML._screenType.text();
			if (strScreenType == "") strScreenType = SessionGlobals.SCREEN_TYPE_SCREEN;
			var dXML:XML = sG.sessionDataXML.session.screen_defaults.(_screenType == strScreenType)[0];
			if (dXML) {
				dXML._screenPlayerNameFormat = cmbScreenPlayerNameFormat.selectedIndex.toString();
				dXML._screenPlayerModelFormat = cmbScreenPlayerModelFormat.selectedIndex.toString();
			}
		}
		
		private function selectScreenFormation(f:String):void {
			if (f == "") f = TeamGlobals.SCREEN_FORMATION_P1;
			for (var i:uint; i<rdoGrpScreenFormat.numRadioButtons; i++) {
				if (rdoGrpScreenFormat.getRadioButtonAt(i).value == f) {
					rdoGrpScreenFormat.selection = rdoGrpScreenFormat.getRadioButtonAt(i);
				}
			}
		}
		// -------------------------- End of Pitch Layout ------------------------- //
	}
}