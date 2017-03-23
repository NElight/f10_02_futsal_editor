package src.user
{
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	
	import src.images.SSPImageItem;
	import src.utils.BatchLoader;
	import src.utils.BatchLoaderEvent;
	import src.utils.BatchLoaderItem;
	import src.utils.VideoValidator;
	import src.utils.VideoValidatorEvent;
	import src.utils.VideoValidatorInfo;
	import src.videos.SSPVideoItem;
	
	import src3d.ScreenshotItem;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.ImageUtils;
	import src3d.utils.Logger;
	import src3d.utils.SessionScreenUtils;

	public class UserMediaManager extends EventDispatcher
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:UserMediaManager;
		private static var _allowInstance:Boolean = false;
		public function MinutesGlobals()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		public static function getInstance():UserMediaManager {
			if(_self == null) {
				_allowInstance=true;
				_self = new UserMediaManager();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var vUserVideos:Vector.<SSPVideoItem> = new Vector.<SSPVideoItem>();
		private var vUserImages:Vector.<SSPImageItem> = new Vector.<SSPImageItem>();
		private var vScreenshots:Vector.<ScreenshotItem> = new Vector.<ScreenshotItem>();
		
		// Image load.
		private var imageLoader:BatchLoader = new BatchLoader();
		private var imageLoaderEventHandler:EventHandler = new EventHandler(imageLoader);
		private var batchLoadStarted:Boolean;
		private var serverDataLoaded:Boolean;
		
		// Validation.
		private var videoValidator:VideoValidator = new VideoValidator(10);
		private var videoValidatorEventHandler:EventHandler = new EventHandler(videoValidator);
		private var vValidateVideos:Vector.<SSPVideoItem>;
		private var validationProgressIdx:int;
		private var validationCurrentItem:SSPVideoItem;
		private var _validationStarted:Boolean;
		
		
		// ----------------------------------- Batch Auto Load ----------------------------------- //
		public function startDataLoad():void {
			if (batchLoadStarted || serverDataLoaded) {
				this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.ALL_COMPLETE));
				return;
			}
			stopBatchLoad();
			collectData();
			batchLoadStarted = true;
			serverDataLoaded = true;
			// Start user image batch load.
			startBatchLoad();
		}
		
		private function collectData():void {
			var sessionXML:XML = sG.sessionDataXML;
			var sXMLList:XMLList = sG.sessionDataXML.session.screen;
			var interfaceBase:String = sessionXML.session._interfaceBaseUrl.text();
			var userImageBase:String = sessionXML.session._userImageBase.text();
			var screenId:int;
			var videoCode:String;
			var videoDuration:String;
			var videoSource:String;
			var videoTitle:String;
			var imageLocation:String;
			
			// Create Overall Data.
			screenId = -1;
			videoCode = sessionXML.session.user_video._videoCode.text();
			videoSource = sessionXML.session.user_video._videoSource.text();
			videoTitle = sessionXML.session.user_video._videoTitle.text();
			videoDuration = sessionXML.session.user_video._videoDuration.text();
			imageLocation = ""; // There is no overall session image.
			addUserVideo(screenId, videoSource, videoCode, videoTitle, videoDuration, true, "");
			//imageLoader.add(imageLocation, screenId, true, false); // Create Loader Data.
			
			// Create Screen Data. 
			for each(var sXML:XML in sXMLList) {
				screenId = int(sXML._screenId.text());
				videoCode = sXML.user_video._videoCode.text();
				videoDuration = sXML.user_video._videoDuration.text();
				videoSource = sXML.user_video._videoSource.text();
				videoTitle = sXML.user_video._videoTitle.text();
				imageLocation = sXML._userImageLocation.text();
				imageLocation = (imageLocation != "")? interfaceBase + userImageBase + imageLocation : "";
				addUserVideo(screenId, videoSource, videoCode, videoTitle, videoDuration, true, "");
				imageLoader.add(imageLocation, screenId, true, false); // Create Loader Data.
			}
		}
		
		private function startBatchLoad():void {
			if (imageLoader.totalFiles == 0) {
				this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.ALL_COMPLETE));
				return;
			}
			imageLoaderEventHandler.RemoveEvents();
			imageLoaderEventHandler.addEventListener(BatchLoaderEvent.FILE_COMPLETE, onImageLoadOK);
			imageLoaderEventHandler.addEventListener(BatchLoaderEvent.FILE_ERROR, onImageLoadError);
			imageLoaderEventHandler.addEventListener(BatchLoaderEvent.ALL_COMPLETE, onImageLoadAllComplete);
			imageLoader.start();
		}
		
		private function stopBatchLoad():void {
			imageLoaderEventHandler.RemoveEvents();
			batchLoadStarted = false;
		}
		
		private function onImageLoadOK(e:BatchLoaderEvent):void {
			var itemIdx:int = e.eventData.index;
			var item:BatchLoaderItem = e.eventData.item as BatchLoaderItem;
			var bmp:Bitmap = e.eventData.data as Bitmap;
			if (!bmp) {
				logger.addError("ScreenId "+item.index+"Null image data loaded from '"+item.location+"'.");
				addUserImage(item.index, null, "");
			} else {
				addUserImage(item.index, bmp, item.location);
			}
		}
		
		private function onImageLoadError(e:BatchLoaderEvent):void {
			var item:BatchLoaderItem = e.eventData.item as BatchLoaderItem;
			var lInfo:String = (item && item.location)? " '"+item.location+"'" : "";
			var message:String = String(e.eventData.message);
			logger.addAlert("Can't load video thumbnail"+lInfo+":\n "+message);
			addUserImage(item.index, null, "");
		}
		
		private function onImageLoadAllComplete(e:BatchLoaderEvent):void {
			stopBatchLoad();
			this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.ALL_COMPLETE));
		}
		// -------------------------------- End of Batch Auto Load ------------------------------- //
		
		
		
		// ----------------------------- Screenshots ----------------------------- //
		public function updateScreenshots(includeLogo:Boolean = true):void {
			vScreenshots = main.sessionView.takeHighResScreenshots(true);
		}
		
		public function getScreenshot(sId:int):ScreenshotItem {
			if (!vScreenshots) updateScreenshots();
			if (!vScreenshots) return null;
			for each (var sItem:ScreenshotItem in vScreenshots) {
				if (sItem && sItem.screenId == sId) return sItem;
			}
			return null;
		}
		
		public function getScreenshotThumb(sId:int, sW:Number, sH:Number, keepAspect:Boolean):Bitmap {
			var sItem:ScreenshotItem = getScreenshot(sId);
			if (!sItem) return null;
			var bmp:Bitmap = sItem.bitmap;
			var thumb:Bitmap;
			if (!bmp) return null;
			if (bmp.width == sW && bmp.height == sH) {
				thumb = new Bitmap(bmp.bitmapData);
				return thumb;
			}
			if (keepAspect) {
				thumb = ImageUtils.fitImage(bmp, sW, sH, true);
			} else {
				thumb = new Bitmap(bmp.bitmapData);
				thumb.width = sW;
				thumb.height = sH;
			}
			return thumb;
		}
		// -------------------------- End of Screenshots ------------------------- //
		
		
		
		// ----------------------------- User Videos ----------------------------- //
		public function resetUserVideos():void {
			vUserVideos = new Vector.<SSPVideoItem>();
		}
		
		public function addUserVideo(screenId:int, videoSource:String, videoCode:String, videoTitle:String, videoDuration:String, videoValidated:Boolean, preValidateLocation:String):SSPVideoItem {
			var found:Boolean;
			var item:SSPVideoItem;
			for each (item in vUserVideos) {
				if (item && item.screenId == screenId) {
					item.screenId = screenId;
					item.videoSource = videoSource;
					item.videoCode = videoCode;
					item.videoTitle = videoTitle;
					item.videoDuration = videoDuration;
					item.videoValidated = videoValidated;
					item.preValidateLocation = preValidateLocation;
					found = true;
					break;
				}
			}
			if (!found || !item) {
				item = new SSPVideoItem(screenId, videoSource, videoCode, videoTitle, videoDuration, 0, "", videoValidated, preValidateLocation);
				vUserVideos.push(item);
			}
			return item;
		}
		
		public function getUserVideo(sId:int):SSPVideoItem {
			var iItem:SSPVideoItem;
			for each (var item:SSPVideoItem in vUserVideos) {
				if (item && item.screenId == sId) {
					iItem = item;
					break;
				}
			}
			if (!iItem) iItem = new SSPVideoItem(sId);
			return iItem;
		}
		
		public function videoExists(sId:int):Boolean {
			var userVideoItem:SSPVideoItem = getUserVideo(sId);
			var videoExists:Boolean = (userVideoItem && userVideoItem.videoCode && userVideoItem.videoCode != "")? true : false;
			return videoExists;
		}
		
		public function userVideosValidated():Boolean {
			var validated:Boolean = true;
			for each (var item:SSPVideoItem in vUserVideos) {
				if (item && !item.videoValidated) validated = false;
			}
			// return true; // Debug.
			return validated;
		}
		// -------------------------- End of User Videos ------------------------- //
		
		
		
		// ----------------------------- User Images ----------------------------- //
		public function resetUserImages():void {
			vUserImages = new Vector.<SSPImageItem>();
		}
		
		public function addUserImage(screenId:int, data:Bitmap, imageLocation:String):void {
			var found:Boolean;
			for each (var item:SSPImageItem in vUserImages) {
				if (item && item.screenId == screenId) {
					item.data = data;
					item.imageLocation = imageLocation;
					found = true;
					break;
				}
			}
			if (!found) {
				item = new SSPImageItem(screenId, data, imageLocation);
				vUserImages.push(item);
			}
		}
		
		public function getUserImage(sId:int):SSPImageItem {
			var iItem:SSPImageItem;
			for each (var item:SSPImageItem in vUserImages) {
				if (item && item.screenId == sId) {
					iItem = item;
					break;
				}
			}
			if (!iItem) iItem = new SSPImageItem(sId);
			return iItem;
		}
		public function getUserImageThumb(sId:int, sW:Number, sH:Number, keepAspect:Boolean):Bitmap {
			var bmp:Bitmap = getUserImage(sId).data;
			var thumb:Bitmap;
			if (!bmp) return null;
			if (bmp.width == sW && bmp.height == sH) {
				thumb = new Bitmap(bmp.bitmapData);
				return thumb;
			}
			if (keepAspect) {
				thumb = ImageUtils.fitImage(bmp, sW, sH, true);
			} else {
				thumb = new Bitmap(bmp.bitmapData);
				thumb.width = sW;
				thumb.height = sH;
			}
			return thumb;
		}
		
		public function imageExists(sId:int):Boolean {
			var userImageItem:SSPImageItem = getUserImage(sId);
			var imageExists:Boolean = (userImageItem && userImageItem.imageExists)? true : false;
			return imageExists;
		}
		// -------------------------- End of User Images ------------------------- //
		
		
		
		// ----------------------------- Play/Open ----------------------------- //
		public function playUserVideoFromScreenSO(strScreenSO:String):void {
			var strSId:String = SessionScreenUtils.getScreenIdFromScreenSortOrder(strScreenSO);
			if (!strSId || strSId == "") return;
			playUserVideoFromScreenId(strSId);
		}
		
		public function playUserVideoFromScreenId(strScreenId:String):void {
			var intSId:int = int(strScreenId);
			var vItem:SSPVideoItem = getUserVideo(intSId);
			main.videoPlayer.openVideo(vItem);
		}
		
		public function playUserImageFromScreenSO(strScreenSO:String):void {
			var strSId:String = SessionScreenUtils.getScreenIdFromScreenSortOrder(strScreenSO);
			if (!strSId || strSId == "") return;
			playUserImageFromScreenId(strSId);
		}
		
		public function playUserImageFromScreenId(strScreenId:String):void {
			var intSId:int = int(strScreenId);
			var iItem:SSPImageItem = getUserImage(intSId);
			if (!iItem) return;
			main.imageViewer.openImage(iItem.data);
		}
		// -------------------------- End of Play/Open ------------------------- //
		
		
		
		// ----------------------------------- Batch Video Validation ----------------------------------- //
		public function validateVideoLocation(screenId:int, strLocation:String):void {
			if (_validationStarted) {
				logger.addAlert("Validation already started. Can't start twice.");
				this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_ERROR));
				return;
			}
			vValidateVideos = new Vector.<SSPVideoItem>();
			vValidateVideos.push(new SSPVideoItem(screenId, "", "", "", "", 0, "", false, strLocation));
			startVideoValidation();
		}
		
		public function validateAllUserVideos():void {
			if (_validationStarted) {
				logger.addAlert("Validation already started. Can't start twice.");
				this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_ALL_COMPLETE, false));
				return;
			}
			vValidateVideos = vUserVideos;
			startVideoValidation();
		}
		
		public function startVideoValidation():void {
			if (!vValidateVideos || vValidateVideos.length == 0) {
				logger.addAlert("User Videos array is empty. Can't start User Video Validation.");
				this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_ERROR));
				return;
			}
			stopVideoValidation();
			_validationStarted = true;
			videoValidatorEventHandler.addEventListener(VideoValidatorEvent.VALIDATION_COMPLETE, onVideoValidationOK);
			videoValidatorEventHandler.addEventListener(VideoValidatorEvent.VALIDATION_ERROR, onVideoValidationError);
			checkValidationProgress();
		}
		
		private function stopVideoValidation():void {
			videoValidatorEventHandler.RemoveEvents();
			validationProgressIdx = -1;
			validationCurrentItem = null;
			_validationStarted = false;
		}
		
		private function checkValidationProgress():void {
			validationProgressIdx++;
			if (validationProgressIdx < vValidateVideos.length) {
				validationCurrentItem = vValidateVideos[validationProgressIdx];
				if (!validationCurrentItem.videoValidated) {
					videoValidator.validateVideoLocation(validationCurrentItem.preValidateLocation);
				} else {
					checkValidationProgress();
				}
			} else {
				this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.VALIDATION_ALL_COMPLETE, true));
				stopVideoValidation();
			}
		}
		
		private function onVideoValidationOK(e:VideoValidatorEvent):void {
			var vi:VideoValidatorInfo = e.eventData;
			addUserVideo(validationCurrentItem.screenId, vi.videoSource, vi.videoCode, vi.videoTitle, vi.videoDuration, true, validationCurrentItem.preValidateLocation);
			this.dispatchEvent(e);
			//this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.COMPLETE, e.eventData));
			checkValidationProgress();
		}
		
		private function onVideoValidationError(e:VideoValidatorEvent):void {
			logger.addAlert("User Video location for screenId "+validationCurrentItem.screenId+" '"+validationCurrentItem.preValidateLocation+"' unverifiable.");
			validationCurrentItem.videoValidated = true;
			this.dispatchEvent(e);
			//this.dispatchEvent(new VideoValidatorEvent(VideoValidatorEvent.ERROR, e.eventData));
			checkValidationProgress();
		}
		
		public function get validationStarted():Boolean {
			return _validationStarted;
		}
		// -------------------------------- End of Batch Video Validation ------------------------------- //
	}
}