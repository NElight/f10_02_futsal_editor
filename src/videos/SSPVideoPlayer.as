package src.videos
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.system.System;
	
	import src.StageManager;
	import src.popup.PopupBox;
	import src.utils.FileLoader;
	import src.utils.VideoValidatorUtils;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.ColorUtils;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	
	public class SSPVideoPlayer extends PopupBox
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:SSPVideoPlayer;
		private static var _allowInstance:Boolean = true;
		
		public function SSPVideoPlayer(ref:main, boxW:Number = NaN, boxH:Number = NaN)
		{
			contentW = (isNaN(boxW))? ref.stage.stageWidth * .9 : boxW;
			contentH = (isNaN(boxH))? ref.stage.stageHeight * .9 : boxH;
			initFormContent();
			var useHeader:Boolean = (formTitle != "")? true : false;
			var title:String = "SSP";
			super(ref.stage, formContent, title, false, false, contentW, contentH, true, useHeader, true, true, true);
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance(ref:main, boxW:Number = NaN, boxH:Number = NaN):SSPVideoPlayer
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new SSPVideoPlayer(ref, boxW, boxH);
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		// More info in https://developers.google.com/youtube/flash_api_reference
		
		private var fileLoader:FileLoader = new FileLoader();
		private var eventHandler:EventHandler = new EventHandler(fileLoader);
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var playerObject:Object;
		private var videoURL:String;
		
		private var formContent:Sprite = new Sprite();
		private var contentW:Number = 640;
		private var contentH:Number = 390;
		private var btnMargin:Number = 25;
		private var bg:Shape;
		private var videoMask:Shape;
		
		private var btnMax:SimpleButton;
		private var btnMin:SimpleButton;
		
		private var useExternalPlayer:Boolean = false;
		private var useCustomPlayer:Boolean = false;
		private var sspPlayerBar:SSPVideoPlayerBar;
		private var lastVideoItem:SSPVideoItem;
		
		private var hadErrorLoadingVideoPlayer:Boolean;
		
		private function initFormContent():void {
			formContent.name = "videoPlayerContainer";
			bg = ColorUtils.createShape(-1, -1, contentW+2, contentH+2, 0, 1); // 1px bigger to cover 3D Screen on full screen.
			formContent.addChild(bg);
			videoMask = ColorUtils.createShape(0, 0, contentW, contentH+2, 0, 1);
			formContent.addChild(videoMask);
		}
		
		private function retryOpenVideo():void {
			if (lastVideoItem) openVideo(lastVideoItem);
		}
		
		public function openVideo(vItem:SSPVideoItem):void {
			if (!vItem) return;
			lastVideoItem = vItem;
			var videoSource:String = vItem.videoSource;
			var videoCode:String = vItem.videoCode;
			var videoW:Number = 500;
			var videoH:Number = 389;
			if (videoSource == "" || videoCode == "") {
				logger.addError("Can't open video code '"+videoCode+"' from '"+videoSource+".");
				return;
			}
			
			// Set Title.
			this.formTitle = vItem.videoTitle;
			// Prepare URL.
			videoURL = VideoValidatorUtils.getVideoLocation(videoSource, videoCode, useCustomPlayer);
			if (videoURL == "") {
				logger.addError("Can't get video URL (code:'"+videoCode+"'. source:'"+videoSource+".");
				return;
			}
			
			// If it has to be played externally or if flash is being played locally, use the external player.
			if (useExternalPlayer || vItem.playExternally || SessionGlobals.getInstance().isLocal) {
				// Use external player. Using default Width and Height for QQ player.
				if (vItem.videoSource == VideoValidatorUtils.SOURCE_QQ) {
					videoW = 500; // Use 500+50 if using parameter "&tiny=0" (big toolbar).
					videoH = -1; // Use 389+90 if using parameter "&tiny=0" (big toolbar).
				} else if (vItem.videoSource == VideoValidatorUtils.SOURCE_YOUTUBE) {
					videoW = 500;
					videoH = -1;
				}
				playExternally(videoURL, videoW, videoH);
				return;
			}
			
			if (playerObject) {
				playerObject.loadVideoById(videoCode);
			} else {
				initVideoPlayer(videoURL);
			}
			this.popupVisible = true;
		}
		
		private function initVideoPlayer(url:String, flashVars:Object = null):void {
			if (videoURL == "") return;
			destroyPlayerObject(); // Prepares the player object to be reused.
			eventHandler.addEventListener(SSPEvent.SUCCESS, onLoadOK);
			eventHandler.addEventListener(SSPEvent.ERROR, onLoadError);
			eventHandler.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			fileLoader.loadFile(videoURL, true);
		}
		
		private function onLoadOK(e:SSPEvent):void {
			eventHandler.RemoveEvents();
			playerObject = e.eventData;
			if (!playerObject as DisplayObject) {
				logger.addError("Invalid data loading file '"+videoURL+"'.");
				return;
			}
			if (!playerObject.hasEventListener(Event.ADDED_TO_STAGE))
				playerObject.addEventListener(Event.ADDED_TO_STAGE, onPlayerAddedToStage, false, 0, true);
			if (!playerObject.hasEventListener("onReady"))
				playerObject.addEventListener("onReady", onPlayerReady, false, 0, true); // YouTube.
			if (!playerObject.hasEventListener("onError"))
				playerObject.addEventListener("onError", onPlayerError, false, 0, true); // YouTube.
			if (!playerObject.hasEventListener("onStateChange"))
				playerObject.addEventListener("onStateChange", onPlayerStateChange, false, 0, true);
			if (!playerObject.hasEventListener("onPlaybackQualityChange"))
				playerObject.addEventListener("onPlaybackQualityChange", onPlayerQualityChange, false, 0, true);
			try {
				formContent.addChild(playerObject as DisplayObject);
			} catch (error:Error) {
				logger.addError("Can't add video player to stage: "+error.message);
			}
		}
		
		private function onLoadError(e:SSPEvent):void {
			if (!hadErrorLoadingVideoPlayer) {
				logger.addAlert("Alert loading file '"+videoURL+"'. Using SSP Custom Player: "+useCustomPlayer+".");
			} else {
				logger.addError("Error loading file '"+videoURL+"'. Using SSP Custom Player: "+useCustomPlayer+".");
			}
			hadErrorLoadingVideoPlayer = true;
			eventHandler.RemoveEvents();
			handlePlayerError();
		}
		
		private function onLoadProgress(e:ProgressEvent):void {
			//trace("Loading..."+e.bytesLoaded/1000+" of "+e.bytesTotal/1000);
		}
		
		private function onPlayerAddedToStage(e:Event):void {
			playerObject.removeEventListener(Event.ADDED_TO_STAGE, onPlayerAddedToStage);
			//this.popupVisible = true;
		}
		
		private function onPlayerReady(e:Event):void{
			if (!playerObject) return;
			//trace("player ready:", Object(e).data);
			resizePlayer();
			// Note that these are YouTube API commands.
			try {
				playerObject.controls = 0;
				//playerObject.mask = videoMask;
				//playerObject.loadVideoById(playerVideoId,0);
				//playerObject.show_deprecation_notice = 0;
				if (useCustomPlayer) {
					if (!sspPlayerBar) {
						sspPlayerBar = new SSPVideoPlayerBar(this, formContent);
					}
					if (sspPlayerBar) {
						if (sspPlayerBar.currentVolume == -1) {
							sspPlayerBar.currentVolume = playerObject.getVolume() / 100;
						} else {
							playerObject.setVolume(Math.round(sspPlayerBar.currentVolume * 100));
						}
						formContent.addChild(sspPlayerBar);
						sspPlayerBar.toolbarEnabled = true;
					}
				}
			} catch (error:Error) {
				logger.addAlert("Could not change YouTube player settings: "+error.message);
			}
			
			this.popupVisible = true;
		}
		
		private function onPlayerError(e:Event):void {
			logger.addError("YouTube Player Error: "+ Object(e).data);
			handlePlayerError();
			// Values:
			//   2 – The request contains an invalid parameter value. For example, this error occurs if you specify a video ID that does not have 11 characters, or if the video ID contains invalid characters, such as exclamation points or asterisks.
			// 100 – The video requested was not found. This error occurs when a video has been removed (for any reason) or has been marked as private.
			// 101 – The owner of the requested video does not allow it to be played in embedded players.
			// 150 – This error is the same as 101. It is just a 101 error in disguise!
		}
		
		private function onPlayerStateChange(e:Event):void {
			trace("YouTube Player State Change: "+ Object(e).data);
			// Values: -1 (unstarted), 0 (ended), 1 (playing), 2 (paused), 3 (buffering), 5 (video cued).
			var stateValue:Object = Object(e).data;
			if (useCustomPlayer && sspPlayerBar) {
				sspPlayerBar.isPlaying = (stateValue == 1)? true : false;
			}
		}
		
		private function onPlayerQualityChange(e:Event):void {
			trace("YouTube Player Quality Change: "+ Object(e).data);
			// Values: small, medium, large, hd720, hd1080, highres, default
		}
		
		private function resizePlayer():void {
			if ("setSize" in playerObject) {
				// Note that these are YouTube API commands.
				playerObject.setSize(contentW, contentH);
			} else if ("width" in playerObject && "height" in playerObject) {
				playerObject.width = contentW;
				playerObject.height = contentH;
			}
			//playerObject.x = (contentW - playerObject.width) / 2;
			//playerObject.y = (contentH - playerObject.height) / 2;
			videoMask.width = contentW;
			videoMask.height = contentH;
		}
		
		private function handlePlayerError():void {
			destroyPlayerObject();
			this.popupVisible = false;
			
			if (useCustomPlayer == false) {
				logger.addInfo("Retrying video with SSP Custom Player");
				useCustomPlayer = true;
				retryOpenVideo();
				return;
			}
			
			/*if (useExternalPlayer == false) {
			logger.addInfo("Retrying video with External Player");
			useCustomPlayer = false;
			useExternalPlayer = true;
			retryOpenVideo();
			return;
			}*/
		}
		
		
		// ----------------------------- Custom Video Controls ----------------------------- //
		public function controlPlay():void {
			if (playerObject) playerObject.playVideo();
		}
		public function controlPause():void {
			if (playerObject) playerObject.pauseVideo();
		}
		public function controlStop():void {
			if (playerObject) playerObject.stopVideo();
		}
		/**
		 * Seeks to a specified time in the video. If the player is paused when the function is called, it will remain paused. 
		 * If the function is called from another state (playing, video cued, etc.), the player will play the video.
		 * <br>
		 * The player will advance to the closest keyframe before that time unless the player has already downloaded 
		 * the portion of the video to which the user is seeking. In that case, the player will advance to the closest keyframe 
		 * before or after the specified time as dictated by the seek() method of the Flash player's NetStream object. 
		 * (See Adobe's documentation for more information.)
		 * <br>
		 * @param seconds Number. Identifies the time to which the player should advance.
		 * @param allowSeekAhead Boolean. Determines whether the player will make a new request to the server if the seconds parameter 
		 * specifies a time outside of the currently buffered video data.
		 * <br>
		 * We recommend that you set this parameter to false while the user drags the mouse along a video progress bar 
		 * and then set it to true when the user releases the mouse. This approach lets a user scroll to different points 
		 * of a video without requesting new video streams by scrolling past unbuffered points in the video. 
		 * When the user releases the mouse button, the player advances to the desired point in the video and requests a new video stream if necessary. 
		 */
		public function controlSeek(seconds:Number, allowSeekAhead:Boolean):void {
			//if (!playerObject || playerObject.getPlayerState() == -1 || playerObject.getDuration() <= 0) {
			if (!playerObject || playerObject.getDuration() <= 0) {
				if (sspPlayerBar) sspPlayerBar.resetBar();
			} else {
				playerObject.seekTo(seconds, allowSeekAhead);
			}
		}
		public function controlMute():void {
			if (playerObject) playerObject.mute();
		}
		public function controUnMute():void {
			if (playerObject) playerObject.unMute();
		}
		/**
		 * Sets the volume.
		 * @param value uint. Accepts an integer between 0 and 100.
		 * 
		 */
		public function controlSetVolume(value:uint):void {
			if (value > 100) value = 100;
			if (playerObject) playerObject.setVolume(value);
		}
		public function controlIsMuted():Boolean {
			return (playerObject)? playerObject.isMuted() : false;
		}
		/**
		 * Returns the player's current volume, an integer between 0 and 100. 
		 * Note that getVolume() will return the volume even if the player is muted. 
		 * @return uint. An integer between 0 and 100.
		 */
		public function controlGetVolume():uint {
			return (playerObject)? playerObject.getVolume() : 100;
		}
		/**
		 * Returns the elapsed time in seconds since the video started playing.
		 * @return Number. A number in the format "00.000".
		 */
		public function controlGetCurrentTime():Number {
			return (playerObject)? playerObject.getCurrentTime() : -1;
		}
		/**
		 * Returns the duration in seconds of the currently playing video. Note that getDuration() will return 0 
		 * until the video's metadata is loaded, which normally happens just after the video starts playing.
		 * <br>
		 * If the currently playing video is a live event, the getDuration() function will return the elapsed time since the live video stream began. 
		 * Specifically, this is the amount of time that the video has streamed without being reset or interrupted. 
		 * In addition, this duration is commonly longer than the actual event time since streaming may begin before the event's start time. 
		 * @return Number. The duration in seconds of the currently playing video.
		 */
		public function controlGetTotalTime():Number {
			return (playerObject)? playerObject.getDuration() : -1;
		}
		
		// ------------------------- end of Custom Video Controls -------------------------- //
		
		
		// ----------------------------- External Interface ----------------------------- //
		private function playExternally(strURL:String, playerW:Number = -1, playerH:Number = -1):void {
			try {
				if (!strURL || strURL == "undefined" || strURL == "") {
					logger.addError("No video URL to play.");
					return;
				}
				logger.addInfo("Playing Video Externally ("+strURL+").");
				
				//var vH:Number = 500+50; // Default for QQ Player.
				//var vH:Number = 389+90; // Default for QQ Player.
				
				var vW:Number = playerW < 0? 500 : playerW;
				var vHDRatioH:Number = Math.round((vW/16)*9);
				var vH:Number = playerH < 0? vHDRatioH : playerH;
				
				var minW:Number = vW;
				var minH:Number = vHDRatioH;
				
				//ExternalInterface.call("playExternalVideo('"+strURL+"')");
				
				/* 
				*  Flash external player. Sends a jQuery function to the browser.
				*  Note that this needs jQuery and jQuery UI to work.
				*  Tested and working with jQuery v1.6.1 and jQuery UI v1.11.3.
				*/
				ExternalInterface.call("function(strURL){" +
					"var vW = "+vW+";" +
					"var vH = "+vH+";" +
					"var minW = "+minW+";" +
					"var minH = "+minH+";" +
					"var iframe = $(\"<iframe src='\"+strURL+\"'  width='\"+vW+\"' height='\"+vH+\"' frameborder='0' marginwidth='0' marginheight='0' allowfullscreen></iframe>\");" +
					"var dialog = $('<div></div>').append(iframe).appendTo('body').dialog({" +
					"dialogClass: 'ssp_video_player'," +
					"title: 'SSP Player'," +
					"autoOpen: true," +
					"modal: true," +
					"resizable: true," +
					"draggable: true," +
					"width: 'auto'," +
					"height: 'auto'," +
					"minWidth: minW," +
					"minHeight: minH," +
					"open: function( event, ui ) {" +
					"$('.ui-widget-overlay').bind('click', function() {" +
					"dialog.dialog('close');"+
					"})" +
					"}," +
					"close: function ( event, ui ) {" +
					"$('.ui-widget-overlay').unbind('click');" +
					"iframe.attr('src', '');" +
					"iframe.remove();" +
					"dialog.remove();" +
					"}" +
					"});" +
					"}", strURL);
				
			} catch(error:Error) {
				logger.addError("Can't play external video: "+error.message);
			}
		}
		// ------------------------- end of External Interface -------------------------- //
		
		
		// ----------------------------- Full Screen ----------------------------- //
		private function onToggleStageSize(e:MouseEvent):void {
			StageManager.getInstance().toggleStageSize();
		}
		
		private function onStageResizeHandler(e:SSPEvent):void {
			trace("SSPVideoPlayer.onStageResizeHandler(). displayState: " + e.eventData);
			updateStageSizeButton(e.eventData);
		}
		
		private function updateStageSizeButton(displayState:String = ""):void {
			if (!btnMax || !btnMin) return;
			if (!displayState || displayState == "") displayState = _stage.displayState;
			if (displayState == StageDisplayState.NORMAL) {
				btnMax.visible = true;
				btnMin.visible = false;
			} else {
				btnMax.visible = false;
				btnMin.visible = true;
			}
		}
		// -------------------------- End of Full Screen ------------------------- //
		
		
		protected override function showBox():void {
			System.useCodePage=false;
			SessionGlobals.getInstance().editMode = true;
			super.showBox();
			startControlListeners();
		}
		
		protected override function closeBox():void {
			System.useCodePage=true;
			destroyPlayerObject();
			SessionGlobals.getInstance().editMode = false;
			super.closeBox();
			stopControlListeners();
		}
		
		public override function updateBox():void {
			super.updateBox();
			if (!btnMax) btnMax = new btnMaximizeVideo();
			if (!btnMin) btnMin = new btnMinimizeVideo();
			btnMax.x = btnMin.x = this.btnFormClose.x - btnMax.width - 7;
			btnMax.y = btnMin.y = this.btnFormClose.y;
			btnMax.height = btnMin.height = btnFormClose.height;
			btnMax.scaleX = btnMin.scaleX = btnMax.scaleY;
			box.addChild(btnMax);
			box.addChild(btnMin);
			if (txtFormTitle) txtFormTitle.width = btnMax.x;
			updateStageSizeButton();
		}
		
		
		
		private function startControlListeners():void {
			if (btnMax && !btnMax.hasEventListener(MouseEvent.CLICK)) {
				btnMax.addEventListener(MouseEvent.CLICK, onToggleStageSize, false, 0, true);
			}
			if (btnMin && !btnMin.hasEventListener(MouseEvent.CLICK)) {
				btnMin.addEventListener(MouseEvent.CLICK, onToggleStageSize, false, 0, true);
			}
			sspEventDispatcher.addEventListener(SSPEvent.STAGE_RESIZE, onStageResizeHandler, false, 0, true);
		}
		
		private function stopControlListeners():void {
			btnMax.removeEventListener(MouseEvent.CLICK, onToggleStageSize);
			btnMin.removeEventListener(MouseEvent.CLICK, onToggleStageSize);
			sspEventDispatcher.removeEventListener(SSPEvent.STAGE_RESIZE, onStageResizeHandler);
		}
		
		private function destroyPlayerObject():void {
			eventHandler.RemoveEvents();
			if (sspPlayerBar) {
				sspPlayerBar.isPlaying = false;
				sspPlayerBar.toolbarEnabled = false;
				if (formContent.contains(sspPlayerBar)) formContent.removeChild(sspPlayerBar);
			}
			if (playerObject) {
				if (formContent.contains(playerObject as DisplayObject)) {
					formContent.removeChild(playerObject as DisplayObject);
				}
				playerObject.removeEventListener(Event.ADDED_TO_STAGE, onPlayerAddedToStage)
				playerObject.removeEventListener("onReady", onPlayerReady);
				playerObject.removeEventListener("onError", onPlayerError);
				playerObject.removeEventListener("onStateChange", onPlayerStateChange);
				playerObject.removeEventListener("onPlaybackQualityChange", onPlayerQualityChange);
				if ("unload" in playerObject) playerObject.unload();
				if ("destroy" in playerObject) playerObject.destroy(); // YouTube API command.
				playerObject = null;
			}
			if (fileLoader) fileLoader.unLoadAndStop();
		}
	}
}