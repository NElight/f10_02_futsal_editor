package src.header
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src.minutes.MinutesGlobals;
	import src.team.TeamGlobals;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	
	public class Score extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var mG:MinutesGlobals = MinutesGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		private var _mcScore:MovieClip;
		private var _txtScore:TextField;
		private var _txtScoreLabel:TextField;
		private var _btnScoreOurUp:SimpleButton;
		private var _btnScoreOurDown:SimpleButton;
		private var _btnScoreOppUp:SimpleButton;
		private var _btnScoreOppDown:SimpleButton;
		private var _scoreModeManual:Boolean; // Debug.
		private var _scoreEnabled:Boolean;
		
		private var scoreSep:String = ":";
		
		public function Score()
		{
			super();
			initScore();
		}
		
		private function initScore():void {
			_mcScore = this.mcScoreSimple;
			_txtScore = this.mcScoreSimple.txtScore;
			_txtScoreLabel = this.mcScoreSimple.txtScoreLabel;
			_btnScoreOurUp = this.btnScoreLeftUp;
			_btnScoreOurDown = this.btnScoreLeftDown;
			_btnScoreOppUp = this.btnScoreRightUp;
			_btnScoreOppDown = this.btnScoreRightDown;
			
			this.visible = false; // Default intial mode.
		}
		
		private function addScoreButtonsListeners():void {
			_btnScoreOurUp.addEventListener(MouseEvent.CLICK, onScoreOurUp, false, 0, true);
			_btnScoreOurDown.addEventListener(MouseEvent.CLICK, onScoreOurDown, false, 0, true);
			_btnScoreOppUp.addEventListener(MouseEvent.CLICK, onScoreOppUp, false, 0, true);
			_btnScoreOppDown.addEventListener(MouseEvent.CLICK, onScoreOppDown, false, 0, true);
		}
		private function removeScoreButtonsListeners():void {
			_btnScoreOurUp.removeEventListener(MouseEvent.CLICK, onScoreOurUp);
			_btnScoreOurDown.removeEventListener(MouseEvent.CLICK, onScoreOurDown);
			_btnScoreOppUp.removeEventListener(MouseEvent.CLICK, onScoreOppUp);
			_btnScoreOppDown.removeEventListener(MouseEvent.CLICK, onScoreOppDown);
		}
		
		private function addMinutesListeners():void {
			sspEventHandler.addEventListener(SSPEvent.MINUTES_UPDATE_SCORE, onMinutesUpdateScore);
			sspEventHandler.addEventListener(SSPEvent.MINUTES_UPDATE_SCORE_MODE, onMinutesUpdateScoreMode);
		}
		
		private function removeMinutesListeners():void {
			sspEventHandler.RemoveEvents();
		}
		
		private function onScoreOurUp(e:MouseEvent):void {
			if (mG.scoreOur < SSPSettings.scoreLimit -1) mG.scoreOur++;
			updateScoreDisplay();
		}
		private function onScoreOurDown(e:MouseEvent):void {
			if (mG.scoreOur > 0) mG.scoreOur--;
			updateScoreDisplay();
		}
		private function onScoreOppUp(e:MouseEvent):void {
			if (mG.scoreOpp < SSPSettings.scoreLimit -1) mG.scoreOpp++;
			updateScoreDisplay();
		}
		private function onScoreOppDown(e:MouseEvent):void {
			if (mG.scoreOpp > 0) mG.scoreOpp--;
			updateScoreDisplay();
		}
		
		private function updateScoreDisplay():void {
			if (sG.sessionDataXML.session._teamWePlay.text() == TeamGlobals.PLAY_HOME) {
				_txtScore.text = mG.scoreOur + scoreSep + mG.scoreOpp;
			} else {
				_txtScore.text = mG.scoreOpp + scoreSep + mG.scoreOur;
			}
		}
		
		
		
		// ----------------------------- Minutes ----------------------------- //
		private function onMinutesUpdateScoreMode(e:SSPEvent):void {
			//this.scoreModeManual = (mG.matchMinutes == MinutesGlobals.MINUTES_MODE_MANUAL)? true : false;
			this.scoreModeManual = (mG.matchMinutes == MinutesGlobals.MINUTES_MODE_OFF)? true : false;
		}
		
		private function onMinutesUpdateScore(e:SSPEvent):void {
			updateScoreDisplay();
		}
		// -------------------------- End of Minutes ------------------------- //
		
		
		
		private function updateScoreMode():void {
			// Note that objects are aligned to the right.
			if (_scoreModeManual) {
				_btnScoreOppUp.x = 0;
				_btnScoreOppDown.x = 0;
				_mcScore.x = -_btnScoreOppUp.width;
				_btnScoreOurUp.x = -(_mcScore.width + _btnScoreOppUp.width);
				_btnScoreOurDown.x = -(_mcScore.width + _btnScoreOppUp.width);
				_btnScoreOurUp.visible = true;
				_btnScoreOurDown.visible = true;
				_btnScoreOppUp.visible = true;
				_btnScoreOppDown.visible = true;
				addScoreButtonsListeners();
			} else {
				_btnScoreOppUp.x = 0;
				_btnScoreOppDown.x = 0;
				_mcScore.x = 0;
				_btnScoreOurUp.x = 0;
				_btnScoreOurDown.x = 0;
				_btnScoreOurUp.visible = false;
				_btnScoreOurDown.visible = false;
				_btnScoreOppUp.visible = false;
				_btnScoreOppDown.visible = false;
				removeScoreButtonsListeners();
			}
		}
		
		public function get scoreModeManual():Boolean {
			return _scoreModeManual;
		}

		public function set scoreModeManual(value:Boolean):void {
			//if (_scoreModeManual == value) return;
			_scoreModeManual = value;
			updateScoreMode();
			updateScoreDisplay();
		}
		
		public function set scoreEnabled(value:Boolean):void {
			if (_scoreEnabled == value) return;
			_scoreEnabled = value;
			
			if (_scoreEnabled) {
				this.visible = true;
				if (_scoreModeManual) addScoreButtonsListeners();
				addMinutesListeners();
			} else {
				this.visible = false;
				removeScoreButtonsListeners();
				removeMinutesListeners();
			}
			
			// Update score state.
			if (mG.useMinutes) {
				this.scoreModeManual = false;
			} else {
				this.scoreModeManual = true;
			}
		}
		
		public function set scoreLabel(value:String):void {
			_txtScoreLabel.text = value;
		}
	}
}