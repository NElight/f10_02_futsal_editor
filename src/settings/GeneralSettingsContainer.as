package src.settings
{
	import fl.controls.ComboBox;
	import fl.controls.Label;
	import fl.data.DataProvider;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.controls.datechooser.SSPDateChooser;
	import src.controls.texteditor.SSPTextEditor;
	import src.tabbar.SSPTabBarBase;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	public class GeneralSettingsContainer extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var sspSettings:SSPSettings = new SSPSettings();
		
		private var parentForm:SSPSettingsForm;
		private var tabBar:SSPTabBarBase;
		private var _initialized:Boolean;
		
		// General Settings Refs.
		private var txtMessages:MovieClip;
		
		private var lblSessionTitle:Label;
		private var lblSessionLanguage:Label;
		private var lblSessionCategory:Label;
		private var lblSessionSkill:Label;
		private var lblSessionDifficulty:Label;
		
		public var txtSessionTitle:TextField;
		private var cmbSessionLanguage:ComboBox;
		private var cmbSessionCategory:ComboBox;
		private var cmbSessionSkill:ComboBox;
		private var cmbSessionDifficulty:ComboBox;
		private var txtSessionStartTime:SSPDateChooser;
		private var txtSessionOverallDescription:SSPTextEditor;
		
		//private var lstScreensList:ScreensList;
		//private var dgrScreensList:ScreensDataGrid;
		private var screenList:ScreenListScrollPane;
		
		// Screens List.
		private var mcSourceContainer:MovieClip;
		private var aScreenCells:Vector.<ScreenListCellBase> = new Vector.<ScreenListCellBase>();
		
		private var defaultSize:uint = 12;
		private var highlightColor:uint = 0xFF0000;
		private var defaultColor:uint = 0;
		private var defaultTF:TextFormat;
		private var highlightTF:TextFormat;
		
		public function GeneralSettingsContainer()
		{
			super();
			// Refs.
			txtMessages = this.settings_msg;
			lblSessionTitle = this.session_title_label;
			lblSessionLanguage = this.session_language_label;
			lblSessionCategory = this.session_category_label;
			lblSessionSkill = this.session_skill_label;
			lblSessionDifficulty = this.session_difficulty_label;
			txtSessionTitle = this.settings_session_title;
			cmbSessionLanguage = this.settings_session_language;
			cmbSessionCategory = this.settings_session_category;
			cmbSessionSkill = this.settings_session_skill;
			cmbSessionDifficulty = this.settings_session_difficulty;
			
			txtSessionStartTime = new SSPDateChooser();
			txtSessionStartTime.x = 381;
			txtSessionStartTime.y = 22.60;
			this.addChild(txtSessionStartTime);
			
			var txtDescLabel:String = sG.interfaceLanguageDataXML.titles[0]._filingOverallComment.text();
			var txtDescHTMLText:String = sG.sessionDataXML.session[0]._sessionOverallDescription.text();
			txtSessionOverallDescription = new SSPTextEditor(382, 58, 360, 70, 12, txtDescHTMLText, SSPSettings.defaultSessionDescriptionMaxChars, true, txtDescLabel, 335, 12);
			this.addChild(txtSessionOverallDescription);
			
			defaultTF = new TextFormat(SSPSettings.DEFAULT_FONT, defaultSize, defaultColor);
			highlightTF = new TextFormat(SSPSettings.DEFAULT_FONT, defaultSize, highlightColor);
			
			txtSessionTitle.defaultTextFormat = defaultTF;
			txtSessionTitle.setTextFormat(defaultTF);
			cmbSessionLanguage.textField.setStyle("textFormat", defaultTF);
			cmbSessionCategory.textField.setStyle("textFormat", defaultTF);
			cmbSessionSkill.textField.setStyle("textFormat", defaultTF);
			cmbSessionDifficulty.textField.setStyle("textFormat", defaultTF);
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		// ----------------------------- Inits ----------------------------- //
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			startInit();
		}
		
		/**
		 * This function has to be called after ADDED_TO_STAGE event to avoid msgbox size problems.
		 * If settings form hasn't been opened when saving <code>forceInit</code> is used before
		 * <code>checkMetadata</code> function. Otherwise metadata can't be checked properly.
		 * @see <code>checkMetadata</code>
		 * @see <code>forceInit</code>
		 * @see <code>SSPSettingsForm.checkMetaInfo</code>
		 */		
		private function startInit():void {
			if (!mcSourceContainer) mcSourceContainer = new MovieClip();
			if (!screenList) screenList = new ScreenListScrollPane();
			this.addChild(screenList);
			_initialized = true;
			//refreshSettings();
		}
		
		public function forceInit():void {
			this.startInit();
		}
		
		public function initGeneralSettings(parentForm:SSPSettingsForm, tabBar:SSPTabBarBase):void {
			this.parentForm = parentForm;
			this.tabBar = tabBar;
			
			var sL:XML = sG.interfaceLanguageDataXML;
			var sD:XML = sG.sessionDataXML.session[0];
			var strMandat:String;
			
			// Labels.
			if (sG.sessionTypeIsMatch) {
				lblSessionTitle.htmlText = sL.titles._titleMatchTitle.text()+SSPSettings.mandatoryColonStr;
				lblSessionCategory.htmlText = sL.titles._titleMatchCategory.text()+SSPSettings.mandatoryColonStr;
				strMandat = (sG.usePlayerRecords)? SSPSettings.mandatoryColonStr : SSPSettings.nonMandatoryColonStr
				txtSessionStartTime.htmlLabel = sL.titles._filingMatchStartTime.text()+strMandat;
			} else {
				lblSessionTitle.htmlText = sL.titles._titleSession.text()+SSPSettings.mandatoryColonStr;
				lblSessionCategory.htmlText = sL.titles._titleSessionCategory.text()+SSPSettings.mandatoryColonStr;
				txtSessionStartTime.htmlLabel = sL.titles._filingSessionStartTime.text()+SSPSettings.nonMandatoryColonStr;
			}
			lblSessionSkill.htmlText = sL.titles._filingSkillLevel.text()+SSPSettings.mandatoryColonStr;
			lblSessionDifficulty.htmlText = sL.titles._filingDifficultyLevel.text()+SSPSettings.mandatoryColonStr;
			lblSessionLanguage.htmlText = sL.titles._filingLanguage.text()+SSPSettings.nonMandatoryColonStr;
			txtMessages.txtSettingsMessage.text = sL.messages._msgErrorCompleteFields.text();
			
			
			// Tab Index.
			var tIdx:int = 1;
			txtMessages.visible = false;
			txtSessionTitle.tabIndex = tIdx++;
			cmbSessionLanguage.tabIndex = tIdx++;
			
			// Skills and Difficulty. Choose which combo to display.
			var counter:uint;
			var pleaseSelectStr:String = sL.menu._menuPleaseSelect.text();
			var strSessionUseSkillLevel = sD._sessionUseSkillLevel.text();
			if(strSessionUseSkillLevel == "TRUE") {
				
				cmbSessionSkill.visible = true;
				lblSessionSkill.visible = true;
				
				cmbSessionDifficulty.visible = false;
				lblSessionDifficulty.visible = false;
				
				cmbSessionSkill.tabIndex = tIdx++;
				
				//Populate skills
				var skills:XMLList = sG.menuDataXML.meta_data.skill;
				var skillIndex = 0;
				counter = 0;
				cmbSessionSkill.addItem( {data: 0, label:pleaseSelectStr } );
				for each(var skill in skills) {
					if(sD._sessionSkillLevelId.text() == skill.attribute("_globSkillLevelId")) {
						skillIndex = counter+1;
					}
					cmbSessionSkill.addItem( {data: skill.attribute("_globSkillLevelId"), label: skill.attribute("_globSkillLevelName") } );
					counter++;
				}
				cmbSessionSkill.selectedIndex = skillIndex;
				cmbSessionSkill.rowCount = 10;
				
			} else {
				
				cmbSessionSkill.visible = false;
				lblSessionSkill.visible = false;
				
				cmbSessionDifficulty.visible = true;
				lblSessionDifficulty.visible = true;
				
				cmbSessionDifficulty.tabIndex = tIdx++;
				
				//Populate difficulty
				var difficulties:XMLList = sG.menuDataXML.meta_data.difficulty;
				var difficultyIndex = 0;
				counter = 0;
				cmbSessionDifficulty.addItem( {data: 0, label:pleaseSelectStr } );
				for each(var difficulty in difficulties) {
					if(sD._sessionDifficultyLevelId.text() == difficulty.attribute("_globDifficultyId")) {
						difficultyIndex = counter+1;
					}
					cmbSessionDifficulty.addItem( {data: difficulty.attribute("_globDifficultyId"), label: difficulty.attribute("_globDifficultyName") } );
					counter++;
				}
				cmbSessionDifficulty.selectedIndex = difficultyIndex;
				cmbSessionDifficulty.rowCount = 10;
				
			}
			
			//Populate categories
			cmbSessionCategory.dataProvider = SessionScreenUtils.getSessionCategoriesDataProvider();
			// Add 'Please Select' at the top of the list.
			cmbSessionCategory.addItemAt({data: 0, label:pleaseSelectStr }, 0);
			cmbSessionCategory.rowCount = 10;
			
			//Populate Languages
			var languages:XMLList = sG.menuDataXML.meta_data.language;
			var i:uint = 0;
			var langIndex = 0;
			//cmbSessionLanguage.addItem( {data: 0, label:pleaseSelectStr } );
			for each(var lang in languages) {
				cmbSessionLanguage.addItem( {data: lang.attribute("_globLanguageCode"), label: lang.attribute("_globLanguageName") } );
				i++;
			}
			cmbSessionLanguage.rowCount = 10;
			
			// Setup.
			txtMessages.visible = false;
			cmbSessionCategory.tabIndex = tIdx++;
			txtSessionStartTime.tabIndex = tIdx++;
			txtSessionOverallDescription.tabIndex = tIdx++;
			
			// Session Start Time.
			txtSessionStartTime.setMySQLString(sD._sessionStartTime.text());
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Events ----------------------------- //
		private function addListeners():void {
			if (!_initialized || txtSessionTitle.hasEventListener(Event.CHANGE)) return;
			txtSessionTitle.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			cmbSessionLanguage.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			cmbSessionDifficulty.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			cmbSessionSkill.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			//cmbSessionCategory.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			cmbSessionCategory.addEventListener(Event.CHANGE, onMainCategoryChange, false, 0, true);
			txtSessionStartTime.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			txtSessionOverallDescription.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			screenList.addEventListener(SSPEvent.SETTINGS_SCREEN_LIST_CHANGE, onScreensListChange, true, 0, true); // Use capture to get screens cells events.
		}
		
		private function removeListeners():void {
			txtSessionTitle.removeEventListener(Event.CHANGE, onControlsChange);
			cmbSessionLanguage.removeEventListener(Event.CHANGE, onControlsChange);
			cmbSessionDifficulty.removeEventListener(Event.CHANGE, onControlsChange);
			cmbSessionSkill.removeEventListener(Event.CHANGE, onControlsChange);
			//cmbSessionCategory.removeEventListener(Event.CHANGE, onControlsChange);
			cmbSessionCategory.removeEventListener(Event.CHANGE, onMainCategoryChange);
			txtSessionStartTime.removeEventListener(Event.CHANGE, onControlsChange);
			txtSessionOverallDescription.removeEventListener(Event.CHANGE, onControlsChange);
			screenList.removeEventListener(SSPEvent.SETTINGS_SCREEN_LIST_CHANGE, onScreensListChange);
		}
		
		private function onControlsChange(e:Event):void {
			parentForm.updateCommonSettings();
			saveSettingsToXML();
			checkMetaInfo();
		}
		
		private function onScreensListChange(e:SSPEvent):void {
			var target:Object = e.eventData; // Receives e.target from source.
			if (target && target is ComboBox) {
				parentForm.updateCommonSettings();
				saveSettingsToXML();
				checkMetaInfo();
			}
			//var item:ScreensListCell = e.target as ScreensListCell;
			parentForm.updateCommonSettings();
		}
		
		private function onMainCategoryChange(e:Event):void {
			//var selectedIdx:int = cmbSessionCategory.selectedIndex; // Same value if Training screens has 'Please Select' or other 0 value option.
			var selectedIdx:int = cmbSessionCategory.selectedIndex - 1; // -1 because Training screens doesn't have 'Please Select' option.
			var screenListData:ScreenListData;
			var screenXMLList:XMLList;
			var sXML:XML;
			
			// Update Session XML.
			sG.sessionDataXML.session._sessionCategoryId = cmbSessionCategory.selectedItem.data.toString();
			
			if (!sG.sessionTypeIsMatch) {
				// Apply Session Category to all Screens.
				for (var i:uint;i<aScreenCells.length;i++) {
					screenListData = aScreenCells[i].data as ScreenListData;
					// Update if selected index of the combo box is < 0;
					if (screenListData.screenCategoryIdx < 0) {
						screenListData.screenCategoryIdx = selectedIdx;
						
						// Update screen XML.
						screenXMLList = sG.sessionDataXML.session.screen.(_screenId == screenListData.screenId);
						for each(sXML in screenXMLList) {
							if (sXML) sXML._screenCategoryId = cmbSessionCategory.selectedItem.data.toString();
						}
					}
					aScreenCells[i].data = screenListData; // Forces update by setting the data.
				}
				screenList.invalidate();
			}
			
			onControlsChange(e);
		}
		// -------------------------- End of Events ------------------------- //
		
		
		
		// ----------------------------- Data ----------------------------- //
		private function saveSettingsToXML():void {
			if (!_initialized) return;
			var sD:XML = sG.sessionDataXML.session[0];
			
			sD._sessionTitle = txtSessionTitle.htmlText;
			sD._sessionLanguageCode = cmbSessionLanguage.selectedItem.data.toString();
			sD._sessionCategoryId = cmbSessionCategory.selectedItem.data.toString();
			
			if(sG.sessionDataXML.session._sessionUseSkillLevel.text() == "TRUE") {
				sD._sessionSkillLevelId = cmbSessionSkill.selectedItem.data.toString();
				sD._sessionDifficultyLevelId = "1";
			} else {
				sD._sessionSkillLevelId = "0";
				sD._sessionDifficultyLevelId = cmbSessionDifficulty.selectedItem.data.toString();
			}
			sD._sessionStartTime = txtSessionStartTime.getMySQLDate();
			sD._sessionOverallDescription = txtSessionOverallDescription.editorHTMLText;
			
			// NOTE: Screens are updated on control changes, so no need to resave.
		}
		
		public function refreshSettings():void {
			if (!_initialized || !this.parentForm || !this.tabBar) return;
			var sL:XML = sG.interfaceLanguageDataXML;
			var sD:XML = sG.sessionDataXML.session[0];
			var selIdx:int;
			
			// Session Title.
			if( sD._sessionTitle.text().toString() == "") {
				sD._sessionTitle = String(sL.titles._titleBarDefault.text());
			}
			txtSessionTitle.htmlText = sD._sessionTitle.text(); // Use .htmlText when loading from XML and 'sanitized' .text when saving to XML.
			txtSessionTitle.setTextFormat(defaultTF);
			
			// Session Category.
			selIdx = MiscUtils.getIndexFromDataProvider(cmbSessionCategory.dataProvider, sD._sessionCategoryId.text());
			if (selIdx == -1 || selIdx > cmbSessionCategory.dataProvider.length-1) {
				logger.addText("(A) - Can't find Session Category Id "+sD._sessionCategoryId.text()+".", false);
				selIdx = 0;
			}
			cmbSessionCategory.selectedIndex = selIdx;
			
			// Session Language.
			selIdx = MiscUtils.getIndexFromDataProvider(cmbSessionLanguage.dataProvider, sD._sessionLanguageCode.text());
			if (selIdx == -1 || selIdx > cmbSessionLanguage.dataProvider.length-1) {
				logger.addText("(A) - Can't find Session Language Code "+sD._sessionLanguageCode.text()+".", false);
				selIdx = -1;
			}
			cmbSessionLanguage.selectedIndex = selIdx;
			
			updateScreensList();
			checkMetaInfo();
		}
		
		public function checkMetaInfo():Boolean {
//			if (!_initialized) return true;
			var metaInfoOK:Boolean = true;
			var screenListOK:Boolean = true;
			parentForm.toggleSaveButton(false);
			resetSettingsControls();
			saveSettingsToXML();
			
			// Session Title.
			if (txtSessionTitle.text == "" ||
				txtSessionTitle.text == sG.interfaceLanguageDataXML.titles._titleBarDefault.text().toString()
			) {
				metaInfoOK = false;
				txtSessionTitle.textColor = highlightColor;
			}
			
			// Text Highlight Style.
			/*tf = cmbSessionLanguage.textField.getStyle("textFormat") as TextFormat;
			tf.color = highlightColor;*/
			
			//var ct:ColorTransform = new ColorTransform(1,0,0,.5,1,0,0,1);
			
			// Session Language.
			if (!cmbSessionLanguage.selectedItem || cmbSessionLanguage.selectedItem.data.toString() == "") {
				metaInfoOK = false;
				//cmbSessionLanguage.textField.textField.textColor = highlightColor;
				cmbSessionLanguage.textField.setStyle("textFormat", highlightTF);
				//cmbSessionLanguage.textField.getStyle("textFormat").color = highlightColor;
				//cmbSessionLanguage.transform.colorTransform = ct;
			}
			
			// Session Category.
			if (!cmbSessionCategory.selectedItem || cmbSessionCategory.selectedItem.data.toString() == "0") {
				metaInfoOK = false;
				//cmbSessionCategory.textField.textField.textColor = highlightColor;
				cmbSessionCategory.textField.setStyle("textFormat", highlightTF);
				//cmbSessionCategory.textField.getStyle("textFormat").color = highlightColor;
				//cmbSessionCategory.transform.colorTransform = ct;
			}
			
			// Session Skill Level.
			if (sG.sessionDataXML.session._sessionUseSkillLevel.text() == "TRUE" &&
				cmbSessionSkill.selectedItem.data.toString() == "0"
			) {
				metaInfoOK = false;
				//cmbSessionSkill.textField.textField.textColor = highlightColor;
				cmbSessionSkill.textField.setStyle("textFormat", highlightTF);
				//cmbSessionSkill.textField.getStyle("textFormat").color = highlightColor;
				//cmbSessionSkill.transform.colorTransform = ct;
			}
			
			// Session Difficulty Level.
			if (sG.sessionDataXML.session._sessionUseSkillLevel.text() == "FALSE" &&
				cmbSessionDifficulty.selectedItem.data.toString() == "0"
			) {
				metaInfoOK = false;
				//cmbSessionDifficulty.textField.textField.textColor = highlightColor;
				cmbSessionDifficulty.textField.setStyle("textFormat", highlightTF);
				//cmbSessionDifficulty.textField.getStyle("textFormat").color = highlightColor;
				//cmbSessionDifficulty.transform.colorTransform = ct;
			}
			
			// Mandatory for match sessions only.
			if (sG.sessionTypeIsMatch) {
				// Match Date/Time.
				if (sG.usePlayerRecords && !txtSessionStartTime.hasValidDate()) metaInfoOK = false;
			}
			
			// Training Session's screens and Match Set-Pieces' screens.
			for each(var sc:ScreenListCellBase in aScreenCells) {
				var sData:ScreenListData = sc.data as ScreenListData;
				if (sData && (sData.screenType == SessionGlobals.SCREEN_TYPE_SCREEN ||
					sData.screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE)) {
					if (!sc.cmbCategory.selectedItem || sc.cmbCategory.selectedItem.data.toString() == "0") {
						metaInfoOK = false;
						screenListOK = false;
						sc.highlight = true;
					}
				}
			}
			
			if (!screenListOK) {
				// Create border.
				screenList.graphics.lineStyle(2, highlightColor);
				screenList.graphics.drawRect(0, 0, screenList.width+1, screenList.height+1);
				screenList.graphics.endFill();
			}
			
			if(!metaInfoOK) {
				if (sG.showErrorOnSave) txtMessages.visible = true;
			} else {
				sG.showErrorOnSave = false;
				txtMessages.visible = false;
				parentForm.toggleSaveButton(true);
			}
			
			return metaInfoOK;
		}
		
		private function resetSettingsControls():void {
			screenList.graphics.clear();
			txtMessages.visible = false;
			txtSessionTitle.textColor = defaultColor;
			
			/*cmbSessionLanguage.textField.textField.textColor = 0;
			cmbSessionCategory.textField.textField.textColor = 0;
			cmbSessionSkill.textField.textField.textColor = 0;
			cmbSessionDifficulty.textField.textField.textColor = 0;*/
			
			/*cmbSessionLanguage.textField.getStyle("textFormat").color = defaultColor;
			cmbSessionCategory.textField.getStyle("textFormat").color = defaultColor;
			cmbSessionSkill.textField.getStyle("textFormat").color = defaultColor;
			cmbSessionDifficulty.textField.getStyle("textFormat").color = defaultColor;*/
			
			/*cmbSessionLanguage.transform.colorTransform = new ColorTransform();
			cmbSessionCategory.transform.colorTransform = new ColorTransform();
			cmbSessionSkill.transform.colorTransform = new ColorTransform();
			cmbSessionDifficulty.transform.colorTransform = new ColorTransform();*/
			
			/*var tf:TextFormat = cmbSessionLanguage.textField.getStyle("textFormat") as TextFormat;
			tf.color = 0;*/
			
			cmbSessionLanguage.textField.setStyle("textFormat", defaultTF);
			cmbSessionCategory.textField.setStyle("textFormat", defaultTF);
			cmbSessionSkill.textField.setStyle("textFormat", defaultTF);
			cmbSessionDifficulty.textField.setStyle("textFormat", defaultTF);
			
			// Screen Categories.
			for each(var sc:ScreenListCellBase in aScreenCells) {
				var sData:ScreenListData = sc.data as ScreenListData;
				// Training Session's screens and Match Set-Pieces' screens.
				if (sData && (sData.screenType == SessionGlobals.SCREEN_TYPE_SCREEN ||
					sData.screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE)) {
					sc.highlight = false;
				}
			}
		}
		// -------------------------- End of Data ------------------------- //
		
		
		
		// ----------------------------- Screens ----------------------------- //
		public function updateScreensList():void {
			if (!_initialized) return;
			var sData:ScreenListData;
			var categoryDP:DataProvider = SessionScreenUtils.getScreenCategoriesDataProvider(SessionGlobals.SCREEN_TYPE_SET_PIECE);
			var cmbIdx:int;
			var screenCell:ScreenListCellBase;
			var screenCellYPos:Number = 0;
			var strScreenCategoryId:String;
			var strSessionCategoryId:String;
			var intScreenCount:int;
			var intSetPieceCount:int;
			
			// Remove previous Screen Cells if any.
			for each(var sc:ScreenListCellBase in aScreenCells) {
				sc.dispose();
				sc = null;
			}
			aScreenCells = new Vector.<ScreenListCellBase>();
			
			for (var i:uint;i<tabBar.aTabs.length;i++) {
				tabBar.aTabs[i].tabGroup
				// Create Screen Data.
				sData = new ScreenListData();
				sData.label = "";
				sData.screenId = tabBar.aTabs[i].tabScreenId.toString();
				sData.screenSO = tabBar.aTabs[i].tabSortOrder.toString();
				sData.screenType = tabBar.aTabs[i].tabScreenType;
				sData.screenTitle = sG.sessionDataXML.session.screen.(_screenId == sData.screenId)._screenTitle.text();
				
				strScreenCategoryId = tabBar.aTabs[i].tabScreenXML._screenCategoryId.text();
				strSessionCategoryId = sG.sessionDataXML.session._sessionCategoryId.text();
				if (strScreenCategoryId == "0") {
					if (!sG.sessionTypeIsMatch && strSessionCategoryId != "0") {
						logger.addText("("+sData.screenId+","+sData.screenSO+"): _screenCategoryId is 0, but _sessionCategoryId != 0.", true);
					}
					cmbIdx = -1;
				} else {
					cmbIdx = MiscUtils.getIndexFromDataProvider(categoryDP, strScreenCategoryId);
					if (cmbIdx < 0 || cmbIdx > categoryDP.length-1) {
						//logger.addText("(A) - ("+sData.screenId+","+sData.screenSO+"): Can't find Screen Category Id "+cmbIdx+". Using Session Category.", false);
						cmbIdx = MiscUtils.getIndexFromDataProvider(cmbSessionCategory.dataProvider, strSessionCategoryId) - 1;
						if (cmbIdx < 0 || cmbIdx > cmbSessionCategory.dataProvider.length-1) {
							logger.addText("("+sData.screenId+","+sData.screenSO+"): Can't find Session Category Id "+sG.sessionDataXML.session._sessionCategoryId.text()+".", true);
							cmbIdx = -1;
						}
					}
				}
				sData.screenCategoryIdx = cmbIdx;
				sData.screenCategoryDataProvider = categoryDP;
				sData.screenTimeSpent = Number( sG.sessionDataXML.session.screen.(_screenId == sData.screenId)._timeSpent.text() );
				
				// Create Screen Cells.
				if (sData.screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					screenCell = new ScreenListCellPeriod();
					intScreenCount++;
					sData.screenListNum = intScreenCount;
				} else if (sData.screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
					screenCell = new ScreenListCellSetPiece();
					intSetPieceCount++;
					sData.screenListNum = intSetPieceCount;
				} else {
					screenCell = new ScreenListCellTraining();
					intScreenCount++;
					sData.screenListNum = intScreenCount;
				}
				screenCell.data = sData;
				screenCell.y = screenCellYPos;
				screenCellYPos += screenCell.screenListCellHeight;
				//if (!sG.sessionTypeIsMatch) screenCell.cmbCategory.enabled = (cmbSessionCategory.selectedIndex == 0)? false : true;
				aScreenCells.push(screenCell);
				mcSourceContainer.addChild(screenCell);
			}
			screenList.source = mcSourceContainer; // Note that mcSourceContainer must be created in a previous function. Otherwise, controls will throw a #1009 error.
			screenList.invalidate();
			screenList.update();
		}
		// -------------------------- End of Screens ------------------------- //
		
		
		
		public function set settingsEnabled(value:Boolean):void {
			if (!_initialized) return;
			if (value) {
				this.visible = true;
				this.refreshSettings(); // Updates General and Screens List settings.
				this.addListeners();
			} else {
				//this.removeListeners();
				this.saveSettingsToXML();
				this.visible = false;
			}
		}

		public function get initialized():Boolean {
			return _initialized;
		}
	}
}