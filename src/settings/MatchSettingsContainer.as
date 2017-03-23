package src.settings
{
	import flash.events.Event;
	
	import src.controls.mixedslider.MixedSlider;
	
	import src3d.SSPEvent;

	public class MatchSettingsContainer extends ScreenSettingsContainerBase
	{
		public function MatchSettingsContainer()
		{
			super();
		}
		
		protected override function initRefs():void {
			// Labels refs.
			_lblSkillMix = this.lblSkillMix;
			_lblLearningObjectives = this.lblLearningObjectives;
			_lblObjectivesTechnical = this.lblObjectivesTechnical;
			_lblObjectivesTactical = this.lblObjectivesTactical;
			_lblObjectivesPhysical = this.lblObjectivesPhysical;
			_lblObjectivesPsychological = this.lblObjectivesPsychological;
			_lblObjectivesSocial = this.lblObjectivesSocial;
			
			// Controls refs.
			_txtObjectivesTechnical = this.txtObjectivesTechnical;
			_txtObjectivesTactical = this.txtObjectivesTactical;
			_txtObjectivesPhysical = this.txtObjectivesPhysical;
			_txtObjectivesPsychological = this.txtObjectivesPsychological;
			_txtObjectivesSocial = this.txtObjectivesSocial;
		}
		
		protected override function initControls():void {
			_skillsMix = new MixedSlider();
			_skillsMix.x = 180;
			_skillsMix.y = 44;
			_skillsMix.tabIndex = 0;
			this.addChild(_skillsMix);
			
			_txtObjectivesTechnical.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesTactical.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesPhysical.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesPsychological.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesSocial.maxChars = SSPSettings.defaultSkillsCommentsMaxChars;
			_txtObjectivesTechnical.tabIndex = 1;
			_txtObjectivesTactical.tabIndex = 2;
			_txtObjectivesPhysical.tabIndex = 3;
			_txtObjectivesPsychological.tabIndex = 4;
			_txtObjectivesSocial.tabIndex = 5;
		}
		
		protected override function initLabels():void {
			var sLTitlesXML:XML = sG.interfaceLanguageDataXML.titles[0];
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
		protected override function addListeners():void {
			_skillsMix.addEventListener(SSPEvent.CONTROL_CHANGE, onSkillMixChange, false, 0, true);
			_txtObjectivesTechnical.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesTactical.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesPhysical.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesPsychological.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
			_txtObjectivesSocial.addEventListener(Event.CHANGE, onControlsChange, false, 0, true);
		}
		protected override function removeListeners():void {
			_skillsMix.removeEventListener(SSPEvent.CONTROL_CHANGE, onSkillMixChange);
			_txtObjectivesTechnical.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesTactical.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesPhysical.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesPsychological.removeEventListener(Event.CHANGE, onControlsChange);
			_txtObjectivesSocial.removeEventListener(Event.CHANGE, onControlsChange);
		}
		
		protected override function onControlsChange(e:Event):void {
			saveSettingsToXML();
		}
/*		
		protected override function onTitleChange(e:Event):void {
			saveSettingsToXML();
			parentForm.updateCommonSettings();
		}
		
		protected override function onSliderDragHandler(e:SliderEvent):void {
			updateTimeSpentLabel();
		}*/
		
		protected override function onSkillMixChange(e:SSPEvent):void {
			saveSettingsToXML();
		}
		// -------------------------------- End of Events ------------------------------- //
		
		
		
		// ----------------------------------- Data ----------------------------------- //
		protected override function updateSettings():void {
			var sXML:XML = sG.sessionDataXML.session.screen[0]; // Use first screen as reference.
			if (!sXML) return;
			
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
		
		protected override function saveSettingsToXML():void {
			if (!_controlsUpdated) return;
			// Clone settings to all screens.
			var sXMLList:XMLList = sG.sessionDataXML.session.screen;
			// Get percentages. An Object with the following properties: tec, tac, phy, psy, soc (in String format).
			var cPerc:Object = _skillsMix.getSkillMixPercentages();
			
			for each (var sXML:XML in sXMLList) {
				// Save skill mix percentages.
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
		}
/*		protected override function updateTimeSpentLabel():void {
			var strTimeSpent:String = _sldTimeSpent.value.toFixed().toString();
			_lblTimeSpentCount.htmlText = "<b>" + strTimeSpent + strScreenTimeSpentUnits + "</b>";
		}*/
		// -------------------------------- End of Data ------------------------------- //
		
		
		
		// ----------------------------------- Public ----------------------------------- //
/*		public function set settingsEnabled(value:Boolean):void {
			if (value) {
				this.visible = true;
				this.updateSettings(); // Updates Screen settings.
			} else {
				saveSettingsToXML();
				this.visible = false;
			}
		}*/
		// -------------------------------- End of Public ------------------------------- //
	}
}