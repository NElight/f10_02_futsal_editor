package src.controls.mixedslider
{
	import src3d.utils.Logger;

	public class MixedSliderValues
	{
		private var sliderWidth:Number;
		
		// Percentages.
		private var percTec:Number = -1;
		private var percTac:Number = -1;
		private var percPhy:Number = -1;
		private var percPsy:Number = -1;
		private var percSoc:Number = -1;
		
		// Corresponding Chunk Scales.
		private var _barTecScaleX:Number = 1;
		private var _barTacScaleX:Number = .8;
		private var _barPhyScaleX:Number = .6;
		private var _barPsyScaleX:Number = .4;
		private var _barSocScaleX:Number = .2;
		
		private var _hasCorrectValues:Boolean;
		
		public function MixedSliderValues(sliderWidth:Number)
		{
			this.sliderWidth = sliderWidth;
		}
		
		/**
		 * Returns an object with the percentages.
		 * Example: var perc:Object = getPercents();
		 * var numSocialPerc:Number = perc.Soc. 
		 * @return Object. With the following properties: tec, tac, phy, psy, soc (in String format).
		 */
		public function getPercents():Object {
			updateCorrespondingPercentages();
			var perc:Object = {
				soc:percSoc.toString(),
				psy:percPsy.toString(),
				phy:percPhy.toString(),
				tac:percTac.toString(),
				tec:percTec.toString()
			};
			return perc;
		}
		
		private function updateCorrespondingPercentages():void {
			if (scalesOK()) {
				/*percSoc = _barSocScaleX * 100;
				percPsy = (_barPsyScaleX) * 100;
				percPhy = (_barPhyScaleX) * 100;
				percTac = (_barTacScaleX) * 100;
				percTec = (_barTecScaleX) * 100;*/
				
				percTec = Math.round( (_barTecScaleX-_barTacScaleX) * 100 );
				percTac = Math.round( (_barTacScaleX-_barPhyScaleX) * 100 );
				percPhy = Math.round( (_barPhyScaleX-_barPsyScaleX) * 100 );
				percPsy = Math.round( (_barPsyScaleX-_barSocScaleX) * 100 );
				percSoc = Math.round( (_barSocScaleX) * 100 );
				//percSoc = 100 - (percTec + percTac + percPhy + percPsy);
				fixPercentages();
			} else {
				resetValues();
			}
		}

		/**
		 * This method is used to load new values in the mixed slider.
		 * Gets regular percentages and covert them to mixed slider format, following these rules.
		 * If any of the skill mix variables for a given screen = -1, make them all = -1.
		 * If none of the numeric skills mix values = -1,
		 * make sure they all add up to 100 by making: skills_social=100-sum(first 4 skills).
		 *  
		 * @param pTec String. Tecnical.
		 * @param pTac String. Tactical.
		 * @param pPhy String. Physical.
		 * @param pPsy String. Psychological.
		 * @param pSoc String. Social.
		 * @return 
		 */
		public function setPercents(pTec:String, pTac:String, pPhy:String, pPsy:String, pSoc:String):void {
			// Check data.
			percTec = Number(pTec);
			percTac = Number(pTac);
			percPhy = Number(pPhy);
			percPsy = Number(pPsy);
			percSoc = Number(pSoc);
			fixPercentages(); // Fix if needed.
			updateCorrespondingScalesX();
		}
		
		private function fixPercentages():void {
			if (percTec+percTac+percPhy+percPsy+percSoc == -5) {
				Logger.getInstance().addInfo("Default values in Skills Mix. No fix done.");
				return;
			}
			Logger.getInstance().addInfo("Checking Skills Mix (Tec:"+percTec+", Tac:"+percTac+", Phy:"+percPhy+", Psy:"+percPsy+", Soc:"+percSoc+").");
			if (percTec < 0) percTec = 0;
			if (percTac < 0) percTac = 0;
			if (percPhy < 0) percPhy = 0;
			if (percPsy < 0) percPsy = 0;
			if (percSoc < 0) percSoc = 0;
			if (percTec > 100) percTec = 100;
			if (percTac > 100) percTac = 100;
			if (percPhy > 100) percPhy = 100;
			if (percPsy > 100) percPsy = 100;
			if (percSoc > 100) percSoc = 100;
			var totalPerc:Number = percTec + percTac + percPhy + percPsy + percSoc;
			var diff:Number = 100 - totalPerc;
			if (diff == 0) return;
			Logger.getInstance().addAlert("Invalid Skills Mix values. Fixing...");
			//percSoc = 100 - (percTec + percTac + percPhy + percPsy); // Adjust the diff in the last chunck.
			
			// Use an array to locate the biggest value of the vars.
			var aPerc:Array = [percTec, percTac, percPhy, percPsy, percSoc];
			var biggestPercIdx:uint = 0;
			for (var i:uint = 0;i<aPerc.length;i++) {
				if (aPerc[i] > aPerc[biggestPercIdx]) biggestPercIdx = i;
			}
			switch (biggestPercIdx) {
				case 0:
					percTec += diff;
					break;
				case 1:
					percTac += diff;
					break;
				case 2:
					percPhy += diff;
					break;
				case 3:
					percPsy += diff;
					break;
				case 4:
					percSoc += diff;
					break;
			}
			
			totalPerc = percTec + percTac + percPhy + percPsy + percSoc;
			if (totalPerc != 100 ||
				percTec < 0 || percTac < 0 || percPhy < 0 || percPsy < 0 || percSoc < 0 ||
				percTec > 100 || percTac > 100 || percPhy > 100 || percPsy > 100 || percSoc > 100
			) {
				Logger.getInstance().addError("Can't fix SkillMix values (Tec:"+percTec+", Tac:"+percTac+", Phy:"+percPhy+", Psy:"+percPsy+", Soc:"+percSoc+". Total:"+totalPerc+").");
			} else {
				Logger.getInstance().addInfo("SkillMix fixed (Tec:"+percTec+", Tac:"+percTac+", Phy:"+percPhy+", Psy:"+percPsy+", Soc:"+percSoc+". Total:"+totalPerc+").");
			}
		}
		
		private function updateCorrespondingScalesX():void {
			if (percentagesOK()) {
				_barTecScaleX = 1;
				_barTacScaleX = 1*Number(_barTecScaleX.toFixed(2)) - percTec/100;
				_barPhyScaleX = 1*Number(_barTacScaleX.toFixed(2)) - percTac/100;
				_barPsyScaleX = 1*Number(_barPhyScaleX.toFixed(2)) - percPhy/100;
				_barSocScaleX = 1*Number(_barPsyScaleX.toFixed(2)) - percPsy/100;
			} else {
				resetValues();
			}
		}
		
		private function percentagesOK():Boolean {
			if (percTec+percTac+percPhy+percPsy+percSoc != 100 ||
				percTec < 0 || percTac < 0 || percPhy < 0 || percPsy < 0 || percSoc < 0 ||
				percTec > 100 || percTac > 100 || percPhy > 100 || percPsy > 100 || percSoc > 100
			) {
				_hasCorrectValues = false;
			} else {
				_hasCorrectValues = true;
			}
			return _hasCorrectValues;
		}
		
		private function scalesOK():Boolean {
			if (_barTecScaleX < 0 || _barTacScaleX < 0 || _barPhyScaleX < 0 || _barPsyScaleX < 0 || _barSocScaleX < 0 ||
				_barTecScaleX > 1 || _barTacScaleX > 1 || _barPhyScaleX > 1 || _barPsyScaleX > 1 || _barSocScaleX > 1
			) {
				_hasCorrectValues = false;
			} else {
				_hasCorrectValues = true;
			}
			return _hasCorrectValues;
		}
		
		private function resetValues():void {
			percTec = -1;
			percTac = -1;
			percPhy = -1;
			percPsy = -1;
			percSoc = -1;
			_barTecScaleX = 1;
			_barTacScaleX = .8;
			_barPhyScaleX = .6;
			_barPsyScaleX = .4;
			_barSocScaleX = .2;
		}
		
		public function setValuesUnused():void {
			_barTecScaleX = -1;
			_barTacScaleX = -1;
			_barPhyScaleX = -1;
			_barPsyScaleX = -1;
			_barSocScaleX = -1;
		}

		public function get hasCorrectValues():Boolean
		{
			return _hasCorrectValues;
		}

		public function set hasCorrectValues(value:Boolean):void
		{
			_hasCorrectValues = value;
		}

		public function get barTecScaleX():Number
		{
			return _barTecScaleX;
		}

		public function get barTacScaleX():Number
		{
			return _barTacScaleX;
		}

		public function get barPhyScaleX():Number
		{
			return _barPhyScaleX;
		}

		public function get barPsyScaleX():Number
		{
			return _barPsyScaleX;
		}

		public function get barSocScaleX():Number
		{
			return _barSocScaleX;
		}


	}
}