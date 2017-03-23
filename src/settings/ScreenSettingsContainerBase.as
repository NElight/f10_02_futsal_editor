package src.settings
{
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import fl.events.SliderEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	import src.controls.mixedslider.MixedSlider;
	import src.controls.slider.SSPSlider;
	import src.tabbar.SSPTabBar;
	import src.tabbar.SSPTabBarBase;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.SessionScreenUtils;
	
	public class ScreenSettingsContainerBase extends MovieClip
	{
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		protected var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		protected var logger:Logger = Logger.getInstance();
		
		protected var parentForm:SSPSettingsForm;
		protected var tabBar:SSPTabBarBase;
		protected var initialized:Boolean;
		
		protected var strScreenTimeSpent:String;
		protected var strScreenTimeSpentUnits:String;
		protected var _categoryDP:DataProvider;
		protected var _currentScreenId:String;
		
		// Labels.
		protected var _lblTitle:TextField;
		protected var _lblCategory:TextField;
		protected var _lblTimeSpent:TextField;
		protected var _lblTimeSpentCount:TextField;
		protected var _lblSkillMix:TextField;
		protected var _lblLearningObjectives:TextField;
		protected var _lblObjectivesTechnical:TextField;
		protected var _lblObjectivesTactical:TextField;
		protected var _lblObjectivesPhysical:TextField;
		protected var _lblObjectivesPsychological:TextField;
		protected var _lblObjectivesSocial:TextField;
		
		// Controls.
		protected var _txtTitle:TextField;
		protected var _cmbCategory:ComboBox;
		protected var _sldTimeSpent:SSPSlider;
		protected var _skillsMix:MixedSlider; 
		protected var _txtObjectivesTechnical:TextField;
		protected var _txtObjectivesTactical:TextField;
		protected var _txtObjectivesPhysical:TextField;
		protected var _txtObjectivesPsychological:TextField;
		protected var _txtObjectivesSocial:TextField;
		protected var _controlsUpdated:Boolean;
		
		public function ScreenSettingsContainerBase()
		{
			super();
			
			initRefs();
			initControls();
			initLabels();
			addListeners();
		}
		
		protected function initRefs():void {}
		
		public function initGeneralSettings(parentForm:SSPSettingsForm, tabBar:SSPTabBarBase):void {
			this.parentForm = parentForm;
			this.tabBar = tabBar;
		}
		
		protected function initControls():void {
			_categoryDP = SessionScreenUtils.getScreenCategoriesDataProvider(SessionGlobals.SCREEN_TYPE_SET_PIECE);
			
			_skillsMix = new MixedSlider();
			_skillsMix.x = 180;
			_skillsMix.y = 180;
			this.addChild(_skillsMix);
			
			_txtTitle.maxChars = SSPSettings.defaultScreenTitleMaxChars;
			_txtObjectivesTechnical.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesTactical.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesPhysical.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesPsychological.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesSocial.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtTitle.tabIndex = 0;
			_cmbCategory.tabIndex = 1;
			_sldTimeSpent.tabIndex = 2;
			_skillsMix.tabIndex = 3;
			_txtObjectivesTechnical.tabIndex = 4;
			_txtObjectivesTactical.tabIndex = 5;
			_txtObjectivesPhysical.tabIndex = 6;
			_txtObjectivesPsychological.tabIndex = 7;
			_txtObjectivesSocial.tabIndex = 8;
		}
		
		protected function initLabels():void {
			var sLTitlesXML:XML = sG.interfaceLanguageDataXML.titles[0];
			var screenTitleStr:String = sLTitlesXML._filingScreenTitles.text();
			_lblTitle.text = screenTitleStr+SSPSettings.nonMandatoryColonStr;
			
			_lblCategory.text = sLTitlesXML._titleScreenCategories.text()+SSPSettings.nonMandatoryColonStr;
			
			strScreenTimeSpent = sLTitlesXML._filingDrillDuration.text();
			strScreenTimeSpentUnits = sLTitlesXML._filingDrillDurationUnits.text();
			_lblTimeSpent.text = strScreenTimeSpent+SSPSettings.nonMandatoryColonStr;
			
			_lblSkillMix.text = sLTitlesXML._filingSkillsMix.text();
			_skillsMix.skillMixCheckBoxLabel = sLTitlesXML._filingSkillMixUse.text();
			_skillsMix.setSkillMixChunksLabels(
				sLTitlesXML._filingSkillsTechnical.text(),
				sLTitlesXML._filingSkillsTactical.text(),
				sLTitlesXML._filingSkillsPhysical.text(),
				sLTitlesXML._filingSkillsPsychological.text(),
				sLTitlesXML._filingSkillsSocial.text()
			);
			
			_lblLearningObjectives.text = sLTitlesXML._filingObjectivesTitle.text();
			_lblObjectivesTechnical.text = sLTitlesXML._filingObjectivesTechnical.text();
			_lblObjectivesTactical.text = sLTitlesXML._filingObjectivesTactical.text();
			_lblObjectivesPhysical.text = sLTitlesXML._filingObjectivesPhysical.text();
			_lblObjectivesPsychological.text = sLTitlesXML._filingObjectivesPsychological.text();
			_lblObjectivesSocial.text = sLTitlesXML._filingObjectivesSocial.text();
		}

		// ----------------------------------- Events ----------------------------------- //
		protected function addListeners():void {
			_txtTitle.addEventListener(Event.CHANGE, onTitleChange, false, 0, true);
			_cmbCategory.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_sldTimeSpent.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_sldTimeSpent.addEventListener(SliderEvent.THUMB_DRAG, onSliderDragHandler, false, 0, true);
			_skillsMix.addEventListener(SSPEvent.CONTROL_CHANGE, onSkillMixChange, false, 0, true);
			_txtObjectivesTechnical.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesTactical.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesPhysical.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesPsychological.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesSocial.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
		}
		protected function removeListeners():void {
			_txtTitle.removeEventListener(Event.CHANGE, onTitleChange);
			_cmbCategory.removeEventListener(Event.CHANGE, onControlsChange);
			_sldTimeSpent.removeEventListener(Event.CHANGE, onControlsChange);
			_sldTimeSpent.removeEventListener(SliderEvent.CHANGE, onSliderDragHandler);
			_skillsMix.removeEventListener(SSPEvent.CONTROL_CHANGE, onSkillMixChange);
			_txtObjectivesTechnical.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesTactical.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesPhysical.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesPsychological.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesSocial.removeEventListener(Event.CHANGE, onControlsChange);
		}
		
		protected function onControlsChange(e:Event):void {
			_cmbCategory.invalidate();
			_sldTimeSpent.invalidate();
			saveSettingsToXML();
		}
		
		protected function onTitleChange(e:Event):void {
			saveSettingsToXML();
			parentForm.updateCommonSettings();
		}
		
		protected function onSliderDragHandler(e:SliderEvent):void {
			updateTimeSpentLabel();
		}
		
		protected function onSkillMixChange(e:SSPEvent):void {
			saveSettingsToXML();
		}
		// -------------------------------- End of Events ------------------------------- //
		
		
		
		// ----------------------------------- Data ----------------------------------- //
		protected function updateSettings():void {
			var sXML:XML = sG.sessionDataXML.session.screen.(_screenId == _currentScreenId)[0];
			// Title.
			var screenTitleStr:String = sG.interfaceLanguageDataXML.titles._filingScreenTitles.text();
			_lblTitle.text = screenTitleStr+SSPSettings.nonMandatoryColonStr;
			_txtTitle.htmlText = sXML._screenTitle.text();
			
			// Category.
			_cmbCategory.dataProvider = _categoryDP;
			var screenCatId:String = sG.sessionDataXML.session.screen.(_screenId == _currentScreenId)[0]._screenCategoryId.text();
			var screenSO:String = sG.sessionDataXML.session.screen.(_screenId == _currentScreenId)[0]._screenSortOrder.text();
			var cmbIdx:int = MiscUtils.getIndexFromDataProvider(_categoryDP, screenCatId);
			if (cmbIdx < 0 || cmbIdx > _categoryDP.length-1) {
				//logger.addText("(A) - ("+_currentScreenId+","+screenSO+"): Can't find Screen Category Id "+cmbIdx+". Using Session Category.", false);
				cmbIdx = MiscUtils.getIndexFromDataProvider(_categoryDP, sG.sessionDataXML.session._sessionCategoryId.text()) - 1;
				if (cmbIdx < 0 || cmbIdx > _categoryDP.length-1) {
					logger.addText("A) - ("+_currentScreenId+","+screenSO+"): Can't find Session Category Id "+sG.sessionDataXML.session._sessionCategoryId.text()+".", false);
				}
			}
			
			// Category Combo Box (Also used in 'ScreenListCellBase.as'.
			if (cmbIdx < 0 || cmbIdx > _cmbCategory.dataProvider.length-1) {
				_cmbCategory.prompt = "- - -";
				//_cmbCategory.selectedIndex = 0; // Reset combobox selection to ('Please Select').
				_cmbCategory.selectedIndex = -1; // Reset combobox selection to none.
				//_cmbCategory.invalidate();
				cmbIdx = -1;
			}
			_cmbCategory.selectedIndex = cmbIdx;
			if (!sG.sessionTypeIsMatch) _cmbCategory.enabled = ( cmbIdx == -1)? false : true;
			_cmbCategory.invalidate();
			_cmbCategory.drawNow();
			
			// Time Spent.
			var ts:uint = uint(sXML._timeSpent.text());
			_sldTimeSpent.value = (ts > _sldTimeSpent.maximum)? _sldTimeSpent.maximum : ts;
			_sldTimeSpent.invalidate();
			updateTimeSpentLabel();
			
			// Skill Mix.
			_skillsMix.setSkillMixPercentages(
				sXML._skillsTechnical.text(),
				sXML._skillsTactical.text(),
				sXML._skillsPhysical.text(),
				sXML._skillsPsychological.text(),
				sXML._skillsSocial.text()
			);
			
			// Learning Objectives.
			_txtObjectivesTechnical.htmlText = sXML._skillsTechnicalComment.text();
			_txtObjectivesTactical.htmlText = sXML._skillsTacticalComment.text();
			_txtObjectivesPhysical.htmlText = sXML._skillsPhysicalComment.text();
			_txtObjectivesPsychological.htmlText = sXML._skillsPsychologicalComment.text();
			_txtObjectivesSocial.htmlText = sXML._skillsSocialComment.text();
			
			_controlsUpdated = true;
		}
		
		protected function saveSettingsToXML():void {
			if (!_controlsUpdated || !_currentScreenId || _currentScreenId == "") return;
			var sXML:XML = sG.sessionDataXML.session.screen.(_screenId == _currentScreenId)[0];
			sXML._screenTitle = _txtTitle.htmlText;
			if (_cmbCategory.selectedItem) sXML._screenCategoryId = _cmbCategory.selectedItem.data.toString();
			sXML._timeSpent = _sldTimeSpent.value.toString();
			updateTimeSpentLabel();
			
			// Get percentages. An Object with the following properties: tec, tac, phy, psy, soc (in String format).
			var cPerc:Object = _skillsMix.getSkillMixPercentages();
			sXML._skillsTechnical = cPerc.tec;
			sXML._skillsTactical = cPerc.tac;
			sXML._skillsPhysical = cPerc.phy;
			sXML._skillsPsychological = cPerc.psy;
			sXML._skillsSocial = cPerc.soc;
			
			// Save objectives' comments.
			sXML._skillsTechnicalComment = _txtObjectivesTechnical.htmlText;
			sXML._skillsTacticalComment = _txtObjectivesTactical.htmlText;
			sXML._skillsPhysicalComment = _txtObjectivesPhysical.htmlText;
			sXML._skillsPsychologicalComment = _txtObjectivesPsychological.htmlText;
			sXML._skillsSocialComment = _txtObjectivesSocial.htmlText;
		}
		protected function updateTimeSpentLabel():void {
			var strTimeSpent:String = _sldTimeSpent.value.toFixed().toString();
			_lblTimeSpentCount.htmlText = "<b>" + strTimeSpent + strScreenTimeSpentUnits + "</b>";
		}
		// -------------------------------- End of Data ------------------------------- //
		
		
		
		// ----------------------------------- Public ----------------------------------- //
		public function set settingsEnabled(value:Boolean):void {
			if (value) {
				this.visible = true;
				this.updateSettings(); // Updates Screen settings.
			} else {
				saveSettingsToXML();
				this.visible = false;
			}
		}

		public function get selectedScreenId():String
		{
			return _currentScreenId;
		}

		public function set selectedScreenId(value:String):void
		{
			_currentScreenId = value;
			updateSettings();
		}
		// -------------------------------- End of Public ------------------------------- //
	}
}