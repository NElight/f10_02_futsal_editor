package src.videos
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src.controls.SSPSeekerBase;
	import src.popup.PopupToolbarBase;
	
	import src3d.SSPEvent;
	import src3d.utils.EventHandler;
	
	public class SSPVideoPlayerBar extends PopupToolbarBase
	{
		private const defaultPlayTime:String = "0:00 / 0:00";
		
		private var _videoPlayer:SSPVideoPlayer;
		private var btnSeeker:SSPSeekerBase;
		private var btnPlay:SimpleButton;
		private var btnPause:SimpleButton;
		//private var btnStop:SimpleButton;
		private var btnVolume:SSPSeekerBase;
		private var txtTime:TextField;
		private var videoPlaying:Boolean;
		private var stageEventHandler:EventHandler;
		private var isSeeking:Boolean;
		
		private var _currentVolume:Number = -1;
		
		public function SSPVideoPlayerBar(videoPlayer:SSPVideoPlayer, targetArea:DisplayObject) {
			super(targetArea, -1, -1, false, DETECTION_METHOD_ENTER_FRAME);
			this._videoPlayer = videoPlayer;
			
			btnSeeker = this.mcVideoSeeker;
			btnPlay = this.btnVideoPlay;
			btnPause = this.btnVideoPause;
			//btnStop = this.btnVideoStop;
			btnVolume = this.mcVideoVolume;
			txtTime = this.txtVideoTime;
			
			// Default values.
			btnSeeker.setSeekPos(0);
			
			startListeners();
		}
		
		override protected function init(e:Event=null):void {
			super.init(e);
			stageEventHandler = new EventHandler(this.stage);
		}
		
		override protected function startControlBar():void {
			super.startControlBar();
			// Start listeners.
		}
		
		override protected function stopControlBar():void {
			super.stopControlBar();
			// Stop listeners.
		}
		
		
		// ----------------------------- Events ----------------------------- //
		private function startListeners():void {
			btnPlay.addEventListener(MouseEvent.CLICK, onBtnPlayClick);
			btnPause.addEventListener(MouseEvent.CLICK, onBtnPauseClick);
			btnSeeker.addEventListener(SSPEvent.CONTROL_CHANGE, onBtnSeekClick);
			btnSeeker.addEventListener(SSPEvent.CONTROL_UPDATE, onBtnSeekMove);
			btnVolume.addEventListener(SSPEvent.CONTROL_CHANGE, onBtnVolumeClick);
			btnVolume.addEventListener(SSPEvent.CONTROL_UPDATE, onBtnVolumeMove);
		}
		
		protected function onBtnPlayClick(e:MouseEvent):void {
			isSeeking = false;
			_videoPlayer.controlPlay();
		}
		
		protected function onBtnPauseClick(e:MouseEvent):void {
			isSeeking = false;
			_videoPlayer.controlPause();
		}
		
		protected function onBtnSeekClick(e:SSPEvent):void {
			isSeeking = false;
			var seekRatio:Number = Number(e.eventData);
			var totalTime:Number = _videoPlayer.controlGetTotalTime();
			var seekTime:Number = Math.round( totalTime * seekRatio );
			_videoPlayer.controlSeek(seekTime, true);
		}
		
		private function onBtnSeekMove(e:SSPEvent):void {
			isSeeking = true;
			var seekRatio:Number = Number(e.eventData);
			var totalTime:Number = _videoPlayer.controlGetTotalTime();
			var seekTime:Number = Math.round( totalTime * seekRatio );
			updateTime(seekTime, totalTime);
		}
		
		protected function onBtnVolumeClick(e:SSPEvent):void {
			var newVolume:Number = Number(e.eventData) * 100;
			_videoPlayer.controlSetVolume(newVolume);
		}
		
		private function onBtnVolumeMove(e:SSPEvent):void {
			var newVolume:Number = Number(e.eventData) * 100;
			_videoPlayer.controlSetVolume(newVolume);
		}
		
		protected function onVolumeChange(e:MouseEvent):void {
			isSeeking = false;
			var volume:uint = 100;
			_videoPlayer.controlSetVolume(volume);
		}
		
		protected function onVideoSeek(e:MouseEvent):void {
			var seconds:Number = 0;
			var allowSeekAhead:Boolean;
			_videoPlayer.controlSeek(seconds, allowSeekAhead);
		}
		
		private function onVideoPlayerStageEnterFrameHandler(e:Event):void {
			updatePlayerStatus();
		}
		// ------------------------- end of Events -------------------------- //
		
		
		// ----------------------------- Actions ----------------------------- //
		
		private function showPause(show:Boolean):void {
			if (show) {
				btnPlay.visible = false;
				btnPause.visible = true;
			} else {
				btnPlay.visible = true;
				btnPause.visible = false;
			}
		}
		
		private function showTime(show:Boolean):void {
			if (!stageEventHandler) return;
			if (show) {
				stageEventHandler.addEventListener(Event.ENTER_FRAME, onVideoPlayerStageEnterFrameHandler, false, 0, true);
			} else {
				stageEventHandler.RemoveEvents();
				updatePlayerStatus();
			}
		}
		
		private function updatePlayerStatus():void {
			if (isSeeking) return;
			var curTime:Number = _videoPlayer.controlGetCurrentTime();
			var totalTime:Number = _videoPlayer.controlGetTotalTime();
			updateTime(curTime, totalTime);
			updateSeekPos(curTime, totalTime);
		}
		
		private function updateSeekPos(curTime:Number, totalTime:Number):void {
			var seekPos:Number = 0;
			if (curTime > -1 && totalTime > -1) {
				seekPos = (curTime / totalTime);
			}
			btnSeeker.setSeekPos(seekPos);
		}
		
		private function updateTime(curTime:Number, totalTime:Number):void {
			var strCurrTime:String = defaultPlayTime;
			var strTotalTime:String = "";
			if (curTime > -1 && totalTime > -1) {
				strCurrTime = formatTime(curTime);
				strTotalTime = " / " + formatTime(totalTime);
			}
			txtTime.text = strCurrTime + strTotalTime;
		}
		
		private function formatTime(t:Number):String {
			t = Math.round(t);
			var min:Number = Math.floor(t / 60);
			var sec = t - min * 60;
			sec = (sec < 10)? "0" + sec : sec;
			return min + ":" + sec;
		}
		// ------------------------- end of Actions -------------------------- //
		
		
		public function resetBar():void {
			txtTime.text = defaultPlayTime;
			btnSeeker.resetSeekPos();
		}
		
		public function set isPlaying(value:Boolean):void {
			if (value) {
				showPause(true);
				showTime(true);
			} else {
				showPause(false);
				showTime(false);
			}
		}
		
		public function setFullScreen(value:Boolean):void {
			
		}
		
		/** 
		 * @return A Number between 0 and 1.
		 */
		public function get currentVolume():Number {
			if (_currentVolume == -1) return -1;
			return btnVolume.getSeekPos();
		}
		
		/** 
		 * @param value Number. Between 0 and 1.
		 */
		public function set currentVolume(value:Number):void {
			//if (value < 0) value = 0;
			//if (value > 1) value = 1;
			_currentVolume = value;
			btnVolume.setSeekPos(value);
		}

	}
}