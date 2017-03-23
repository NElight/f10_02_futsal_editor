package src.utils
{
	import flash.events.EventDispatcher;
	
	import src3d.SSPEvent;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	
	public class VideoValidator extends EventDispatcher
	{
		public static const VIDEO_OK:String				= "VIDEO_OK";
		public static const VIDEO_INVALID:String		= "VIDEO_INVALID";
		public static const VIDEO_UNVERIFIABLE:String	= "VIDEO_UNVERIFIABLE";
		public static const NO_INFO:String				= "NO_INFO";
		
		private var logger:Logger = Logger.getInstance();
		
		private var infoLoader:FileLoader = new FileLoader();
		private var infoLoaderEventHandler:EventHandler = new EventHandler(infoLoader);
		
		private var videoInfoRetryMax:int = 10;
		private var videoInfoRetry:int;
		
		private var videoSettings:VideoValidatorSettings;
		private var fileInfoLocation:String = "";
		
		public function VideoValidator(videoInfoRetryMax = 10)
		{
			this.videoInfoRetryMax = videoInfoRetryMax;
		}
		
		// ----------------------------------- User Video Manual Load ----------------------------------- //
		public function validateVideoLocation(strLocation:String):void {
			if (!strLocation || strLocation == "") {
				notifyError(VIDEO_INVALID);
				return;
			}
			
			logger.addEntry("Validating video location '"+strLocation+"'.");
			
			var strVideoSource:String = VideoValidatorUtils.getVideoSourceFromLocation(strLocation);
			var strVideoCode:String = VideoValidatorUtils.getVideoCodeFromLocation(strLocation, strVideoSource);
			if (!strVideoCode || strVideoCode == "") {
				logger.addAlert("Can't get videoCode from user's location '"+strLocation+"'.");
				notifyError(VIDEO_INVALID);
				return;
			}
			
			fileInfoLocation = VideoValidatorUtils.getVideoInfoLocation(strVideoSource, strVideoCode);
			if (fileInfoLocation == NO_INFO) {
				// If we don't have info for that video source, continue without verifying data.
				logger.addAlert("No info location for '"+strVideoSource+"' video.");
				validateVideoInfo(strVideoSource, NO_INFO, strVideoCode);
				return;
			}
			
			if (!fileInfoLocation || fileInfoLocation == "") {
				logger.addAlert("Can't get info file location for this code: '"+strVideoCode+"' (source: '"+strVideoSource+"').");
				notifyError(VIDEO_UNVERIFIABLE);
				return;
			}
			
			//infoLoaderEventHandler.addEventListener(SSPEvent.SUCCESS, onVideoInfoLoadOK, false, 0, true);
			
			// Add listener passing video code as parameter.
			infoLoaderEventHandler.addEventListener(
				SSPEvent.SUCCESS, 
				function(evt:SSPEvent)	{
					onVideoInfoLoadOK(evt, strVideoSource, strVideoCode);
				},
				false, 0, true
			);
			
			infoLoaderEventHandler.addEventListener(SSPEvent.ERROR, onVideoInfoLoadError, false, 0, true);
			videoInfoRetry = -1;
			videoInfoLoad();
		}
		
		private function videoInfoLoad():void {
			//var sbt:String = Security.sandboxType; // Debug
			if (!fileInfoLocation || fileInfoLocation == "") {
				logger.addAlert("Can't load video info. Location empty.");
				notifyError(VIDEO_INVALID);
				return;
			}
			videoInfoRetry++;
			if (videoInfoRetry < videoInfoRetryMax) {
				infoLoader.loadFile(fileInfoLocation, false, false, true); // If it gives some loading error, try loading as binary instead of text.
			} else {
				infoLoaderEventHandler.RemoveEvents();
				logger.addAlert("Can't load user video info '"+fileInfoLocation+"'. Max retries of "+videoInfoRetryMax+" reached.");
				notifyError(VIDEO_UNVERIFIABLE);
			}
		}
		
		private function onVideoInfoLoadOK(e:SSPEvent, strVideoSource:String, strVideoCode:String):void {
			infoLoaderEventHandler.RemoveEvents();
			var strInfoData:String = String(e.eventData);
			if (strInfoData) {
				logger.addEntry("Video info file loaded ("+videoInfoRetry+" retries).");
				validateVideoInfo(strVideoSource, strInfoData, strVideoCode);
			} else {
				logger.addError("Null data loading video info.");
				notifyError(VIDEO_UNVERIFIABLE);
			}
		}
		
		private function onVideoInfoLoadError(e:SSPEvent):void {
			//var message:String = ":\n "+String(e.eventData);
			var message:String = ".";
			logger.addAlert("Error loading user video info '"+fileInfoLocation+"'"+message);
			if (videoInfoRetry >= videoInfoRetryMax) {
				infoLoaderEventHandler.RemoveEvents();
				notifyError(null);
				return;
			}
			videoInfoLoad(); // Retry.
			//validateVideoInfo(null);
		}
		
		private function validateVideoInfo(strVideoSource:String, strText:String, strVideoCode:String):void {
			var vi:VideoValidatorInfo;
			
			if (strText) {
				vi = VideoValidatorUtils.parseVideoInfo(strVideoSource, strText, strVideoCode);
			}
			
			if (!vi) {
				logger.addAlert("Video info not parsed.");
				notifyError(VIDEO_UNVERIFIABLE);
			} else if (vi.videoStatusOK) {
				if (vi.videoRestricted) {
					var strRestriction:String =
						"Video is Restricted. \n"+
						vi.videoRestrictedInfo;
					logger.addAlert(strRestriction);
					notifyError(VIDEO_UNVERIFIABLE);
				}
				notifyComplete(vi);
			} else {
				logger.addAlert("Video info parsed, but not valid content.");
				notifyError(VIDEO_UNVERIFIABLE);
			}
			videoInfoLoad();
		}
		// -------------------------------- End of User Video Manual Load ------------------------------- //
		
		
		
		// ----------------------------------- Notify Events ----------------------------------- //
		private function notifyComplete(eventData:Object) {
			this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_COMPLETE, eventData));
		}
		private function notifyAllComplete(eventData:Object) {
			this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_ALL_COMPLETE, eventData));
		}
		private function notifyError(eventData:Object) {
			this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_ERROR, eventData));
		}
		// -------------------------------- End of Notify Events ------------------------------- //
	}
}