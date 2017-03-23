package src.settings
{
	public class ScreenSettingsContainer extends ScreenSettingsContainerBase
	{
		public function ScreenSettingsContainer()
		{
			super();
		}
		
		protected override function initRefs():void {
			// Labels refs.
			_lblTitle = this.lblScreenTitle;
			_lblCategory = this.lblScreenCategory;
			_lblTimeSpent = this.lblScreenTimeSpent;
			_lblTimeSpentCount = this.lblScreenTimeSpentCount;
			_lblSkillMix = this.lblSkillMix;
			_lblLearningObjectives = this.lblLearningObjectives;
			_lblObjectivesTechnical = this.lblObjectivesTechnical;
			_lblObjectivesTactical = this.lblObjectivesTactical;
			_lblObjectivesPhysical = this.lblObjectivesPhysical;
			_lblObjectivesPsychological = this.lblObjectivesPsychological;
			_lblObjectivesSocial = this.lblObjectivesSocial;
			
			// Controls refs.
			_txtTitle = this.txtScreenTitle;
			_cmbCategory = this.cmbScreenCategory;
			_sldTimeSpent = this.sldScreenTimeSpent;
			_txtObjectivesTechnical = this.txtObjectivesTechnical;
			_txtObjectivesTactical = this.txtObjectivesTactical;
			_txtObjectivesPhysical = this.txtObjectivesPhysical;
			_txtObjectivesPsychological = this.txtObjectivesPsychological;
			_txtObjectivesSocial = this.txtObjectivesSocial;
		}
	}
}