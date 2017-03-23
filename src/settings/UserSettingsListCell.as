package src.settings
{
	import fl.controls.Button;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import src.controls.gallery.ThumbnailButton;
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	import src.user.UserMediaManager;
	import src.utils.FileLoader;
	import src.utils.FileLoaderLocal;
	import src.utils.FileSaverLocal;
	import src.utils.VideoValidator;
	import src.utils.VideoValidatorEvent;
	import src.utils.VideoValidatorInfo;
	import src.utils.VideoValidatorSettings;
	import src.utils.VideoValidatorUtils;
	import src.videos.SSPVideoItem;
	
	import src3d.SSPEvent;
	import src3d.ScreenshotItem;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.ImageUtils;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	import src3d.utils.TimeUtils;
	
	public class UserSettingsListCell extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var uM:UserMediaManager = UserMediaManager.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		// Utils.
		private var videoValidatorEventHandler:EventHandler = new EventHandler(uM);
		private var videoSettings:VideoValidatorSettings;
		private var imageLoader:FileLoader = new FileLoader();
		private var imageEventHandler:EventHandler = new EventHandler(imageLoader);
		private var screenSaver:FileSaverLocal = new FileSaverLocal();
		private var screenEventHandler:EventHandler = new EventHandler(screenSaver);
		private var fileUploader:FileLoaderLocal;
		private var fileInfoLocation:String;
		
		// Data.
		private var screenId:int = -1;
		private var screenSO:int = -1;
		private var screenType:String = "";
		private var screenCount:int;
		private var screenLabel:String = "";
		private var userVideo:SSPVideoItem;
		private var screenshotThumb:Bitmap;
		private var imageThumb:Bitmap;
		
		// Controls.
		private var txtScreenTitle:TextField;
		private var txtVideoLocation:TextField;
		private var txtVideoStatus:TextField;
		private var txtVideonInfo:TextField;
		private var btnApplyVideoLocation:Button;
		private var btnRemoveVideoLocation:SimpleButton;
		private var btnPlayVideo:SimpleButton;
		private var btnAddImage:Button;
		private var btnRemoveImage:SimpleButton;
		private var btnImage:ThumbnailButton;
		private var btnScreenshot:ThumbnailButton;
		private var container:UserSettingsContainer;
		
		// Settings.
		private var uintColorOK:uint = 0;
		private var uintColorError:uint = 0xFF0000;
		private var vTooltipSettings:Vector.<SSPToolTipSettings>;
		private var _isHeader:Boolean;
		
		// Language tags.
		private var strUnverifiable:String;
		private var strInvalid:String;
		
		public function UserSettingsListCell(container:UserSettingsContainer, header:Boolean,
											 screenId:int, screenSO:int, screenType:String, screenCount:int, screenLabel:String)
		{
			this.container = container;
			this._isHeader = header;
			this.screenId = screenId;
			this.screenSO = screenSO;
			this.screenType = screenType;
			this.screenCount = screenCount;
			this.screenLabel = screenLabel;
			init();
		}
		
		private function init():void {
			txtScreenTitle = this.textScreenTitle;
			txtVideoLocation = this.textVideoLocation;
			txtVideonInfo = this.textVideoInfo;
			txtVideoStatus = this.textVideoStatus;
			btnApplyVideoLocation = this.buttonApplyVideoLocation;
			btnRemoveVideoLocation = this.buttonRemoveVideoLocation;
			btnPlayVideo = this.buttonPlayVideo;
			btnAddImage = this.buttonAddImage;
			btnRemoveImage = this.buttonRemoveImage;
			
			var mcImagePlaceholder:MovieClip = this.btnImagePlaceholder;
			var mcScreenshotPlaceholder:MovieClip = this.btnScreenshotPlaceholder;
			mcImagePlaceholder.visible = false;
			mcScreenshotPlaceholder.visible = false;
			btnImage = new ThumbnailButton(mcImagePlaceholder.width, mcImagePlaceholder.height, false);
			btnImage.x = mcImagePlaceholder.x;
			btnImage.y = mcImagePlaceholder.y;
			this.addChild(btnImage);
			this.swapChildren(btnImage, btnRemoveImage);
			btnScreenshot = new ThumbnailButton(mcScreenshotPlaceholder.width, mcScreenshotPlaceholder.height, false);
			btnScreenshot.x = mcScreenshotPlaceholder.x;
			btnScreenshot.y = mcScreenshotPlaceholder.y;
			this.addChild(btnScreenshot);
			
			txtVideoLocation.tabIndex = 0;
			btnApplyVideoLocation.tabIndex = 1;
			btnPlayVideo.tabIndex = 2;
			btnRemoveVideoLocation.tabIndex = 3;
			btnAddImage.tabIndex = 4;
			btnImage.tabIndex = 5;
			btnRemoveImage.tabIndex = 6;
			btnScreenshot.tabIndex = 7;
			
			btnApplyVideoLocation.useHandCursor = true;
			btnAddImage.useHandCursor = true;
			
			btnApplyVideoLocation.drawNow();
			btnAddImage.drawNow();
			
			btnImage.visible = false;
			
			// Language tags.
			var sL:XML = sG.interfaceLanguageDataXML;
			txtScreenTitle.text = "";
			txtVideonInfo.text = "";
			txtVideoStatus.text = "";
			btnApplyVideoLocation.label = sL.buttons._btnInterfaceApply.text();
			btnAddImage.label = sL.buttons._btnInterfaceAddImage.text();
			strUnverifiable = sG.interfaceLanguageDataXML.messages._filingVideoUnverifiable.text();
			strInvalid = sG.interfaceLanguageDataXML.messages._filingErrorVideoInvalid.text();
			
			// Tooltips
			var tooltipText:String = sL.tags._btnDownloadImage.text();
			vTooltipSettings = new Vector.<SSPToolTipSettings>();
			vTooltipSettings.push(new SSPToolTipSettings(btnScreenshot, tooltipText));
			SSPToolTip.getInstance().addToolTips(vTooltipSettings);
			
			// Initial status.
			userVideoEnabled(false);
			
			updateData();
			
			addListeners();
		}
		
		
		
		// ----------------------------------- Data ----------------------------------- //
		private function updateData():void {
			txtScreenTitle.text = screenLabel;
			
			// Update video data.
			//uM.addUserVideo(screenId, videoSource, videoCode, videoTitle, videoDuration);
			userVideo = uM.getUserVideo(screenId);
			txtVideoLocation.text = "";
			var strVideoLocation:String = VideoValidatorUtils.getVideoLocation(userVideo.videoSource, userVideo.videoCode);
			if (strVideoLocation != "") {
				setVideoTitle(userVideo.videoTitle);
			} else {
				if (!userVideo.videoValidated) {
					txtVideoLocation.text = String(userVideo.preValidateLocation);
				}
				setVideoData();
				setVideoStatus("", false);
			}
			
			updateUserImageControls();
			
			screenshotThumb = uM.getScreenshotThumb(screenId, btnScreenshot.thumbnailW, btnScreenshot.thumbnailH, true);
			btnScreenshot.showThumb(screenshotThumb);
		}
		
		private function setVideoData(videoSource:String = "", videoCode:String = "", videoTitle:String = "", videoDuration:String = ""):void {
			var preValidLocation:String = txtVideoLocation.text;
			userVideo = uM.addUserVideo(screenId, videoSource, videoCode, videoTitle, videoDuration, userVideo.videoValidated, preValidLocation);
		}
		// -------------------------------- End of Data ------------------------------- //
		
		
		
		// ----------------------------------- Events ----------------------------------- //
		private function addListeners():void {
			btnApplyVideoLocation.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
			btnPlayVideo.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
			btnRemoveVideoLocation.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
			if (!_isHeader) {
				btnAddImage.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
				btnRemoveImage.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
				btnImage.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
				btnScreenshot.addEventListener(MouseEvent.CLICK, onControlClickHandler, false, 0, true);
			}
			txtVideoLocation.addEventListener(Event.CHANGE, onVideoLocationTextInput, false, 0, true);
		}
		private function removeListeners():void {
			btnApplyVideoLocation.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			btnPlayVideo.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			btnRemoveVideoLocation.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			btnAddImage.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			btnRemoveImage.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			btnImage.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			btnScreenshot.removeEventListener(MouseEvent.CLICK, onControlClickHandler);
			txtVideoLocation.removeEventListener(Event.CHANGE, onVideoLocationTextInput);
		}
		
		private function onControlClickHandler(e:MouseEvent):void {
			switch(e.currentTarget) {
				case btnApplyVideoLocation:
					validateVideoLocation();
					break;
				case btnPlayVideo:
					playUserVideo();
					break;
				case btnRemoveVideoLocation:
					removeVideoLocation();
					break;
				case btnAddImage:
					addUserImage();
					break;
				case btnRemoveImage:
					removeUserImage();
					break;
				case btnImage:
					showUserImage();
					break;
				case btnScreenshot:
					saveScreenshotToPC();
					break;
			}
		}
		
		private function onVideoLocationTextInput(e:Event):void {
			userVideo.videoValidated = false;
			userVideo.preValidateLocation = txtVideoLocation.text;
			setVideoData(userVideo.videoSource, userVideo.videoCode, userVideo.videoTitle, userVideo.videoDuration);
		}
		// -------------------------------- End of Events ------------------------------- //
		
		
		
		// ----------------------------------- User Video Manual Load ----------------------------------- //
		private function validateVideoLocation():void {
			if (uM.validationStarted) return;
			if (txtVideoLocation.text == "") return;
			logger.addUser("Validating video location '"+txtVideoLocation.text+"'.");
			setVideoData(); // Reset video data.
			//updateVideoInfo(null);
			setVideoStatus("- - -", false);
			videoValidatorEventHandler.addEventListener(VideoValidatorEvent.VALIDATION_COMPLETE, onVideoValidationComplete);
			videoValidatorEventHandler.addEventListener(VideoValidatorEvent.VALIDATION_ERROR, onVideoValidationError);
			uM.validateVideoLocation(screenId, txtVideoLocation.text);
		}
		
		private function onVideoValidationComplete(e:VideoValidatorEvent):void {
			videoValidatorEventHandler.RemoveEvents();
			updateVideoInfo(e.eventData as VideoValidatorInfo);
		}
		
		private function onVideoValidationError(e:VideoValidatorEvent):void {
			videoValidatorEventHandler.RemoveEvents();
			var errorType:String = String(e.eventData);
			if (errorType == VideoValidator.VIDEO_INVALID) {
				var strStatus:String = strInvalid;
				setVideoStatus(strStatus, true);
				return;
			}
			updateVideoInfo(null);
		}
		
		private function updateVideoInfo(vi:VideoValidatorInfo):void {
			var strTitleLabel:String = sG.interfaceLanguageDataXML.messages._filingVideoTitle.text();
			var strTitle:String;
			var strStatus:String = "";
			var hasErrors:Boolean;
			
			setVideoData(); // Clear Video Data.
			if (!vi) {
				logger.addAlert("Video info is null.");
				strStatus = strUnverifiable;
				hasErrors = true;
				setVideoStatus(strStatus, hasErrors);
			} else if (vi.videoStatusOK) {
				strTitle = strTitleLabel + " " + vi.videoTitle;
				setVideoTitle(strTitle);
				setVideoData(vi.videoSource, vi.videoCode, vi.videoTitle, vi.videoDuration);
			} else {
				logger.addAlert("Video info parsed, but not valid content.");
				strStatus = strUnverifiable;
				hasErrors = true;
				setVideoStatus(strStatus, hasErrors);
			}
		}
		
		private function setVideoTitle(strText:String):void {
			userVideoEnabled(true);
			txtVideoStatus.text = "";
			txtVideonInfo.text = strText;
			txtVideoLocation.text = "";
		}
		
		private function setVideoStatus(strText:String, asError:Boolean):void {
			userVideoEnabled(false);
			txtVideonInfo.text = "";
			txtVideoStatus.textColor = (asError)? uintColorError : uintColorOK;
			txtVideoStatus.text = strText;
		}
		
		private function removeVideoLocation():void {
			uM.addUserVideo(screenId, "", "", "", "", true, "");
			txtVideonInfo.text = "";
			userVideoEnabled(false);
			txtVideoLocation.text = "";
		}
		
		private function playUserVideo():void {
			main.videoPlayer.openVideo(userVideo);
		}
		// -------------------------------- End of User Video Manual Load ------------------------------- //
		
		
		
		// ----------------------------------- User Image Manual Load ----------------------------------- //
		private function addUserImage():void {
			logger.addUser("User image load to Flash started.");
			fileUploader = new FileLoaderLocal();
			fileUploader.addEventListener(SSPEvent.SUCCESS, onUserImageLoaded, false, 0, true);
			fileUploader.addEventListener(SSPEvent.CANCEL, onUserImageCanceled, false, 0, true);
			fileUploader.start(FileLoaderLocal.FILTER_TYPE_IMAGES);
		}
		
		private function onUserImageLoaded(e:SSPEvent):void {
			fileUploader.removeEventListener(SSPEvent.SUCCESS, onUserImageLoaded);
			fileUploader.removeEventListener(SSPEvent.CANCEL, onUserImageCanceled);
			var bmp:Bitmap = e.eventData as Bitmap;
			if (!bmp) logger.addError("User image data invalid.");
			if (bmp.width > SSPSettings.userImageMaxWidth || bmp.height > SSPSettings.userImageMaxHeight) {
				bmp = ImageUtils.fitImage(bmp, SSPSettings.userImageMaxWidth, SSPSettings.userImageMaxHeight, true);
			}
			uM.addUserImage(screenId, bmp, ""); // Empty location means not from Server.
			updateUserImageControls();
			logger.addUser("User image load to Flash done.");
		}
		
		private function onUserImageCanceled(e:SSPEvent):void {
			fileUploader.removeEventListener(SSPEvent.SUCCESS, onUserImageLoaded);
			fileUploader.removeEventListener(SSPEvent.CANCEL, onUserImageCanceled);
			logger.addUser("User image upload canceled.");
		}
		// -------------------------------- End of User Image Manual Load ------------------------------- //
		
		
		
		// ----------------------------------- Save Screenshot to PC ----------------------------------- //
		private function saveScreenshotToPC():void {
			logger.addUser("ScreenId "+screenId+" screenshot save started.");
			try {
				var screenshotItem:ScreenshotItem = uM.getScreenshot(screenId);
				var screenshotBmp:Bitmap = screenshotItem.bitmap;
				var imgByteArray:ByteArray = ImageUtils.bmdToJPG(screenshotBmp.bitmapData);
				if (screenSaver) {
					screenSaver.removeEventListener(SSPEvent.SUCCESS, onScreenshotSaved);
					screenSaver.removeEventListener(SSPEvent.CANCEL, onScreenshotCanceled);
				}
				screenSaver = new FileSaverLocal();
				screenSaver.addEventListener(SSPEvent.SUCCESS, onScreenshotSaved, false, 0, true);
				screenSaver.addEventListener(SSPEvent.CANCEL, onScreenshotCanceled, false, 0, true);
				screenSaver.addFile(imgByteArray, getScreenshotName());
				screenSaver.start();
			} catch(error:Error) {
				logger.addError("Can't get screenshot for screenId "+screenId+". "+error.message);
				return;
			}
		}
		
		private function onScreenshotSaved(e:SSPEvent):void {
			screenSaver.removeEventListener(SSPEvent.SUCCESS, onScreenshotSaved);
			screenSaver.removeEventListener(SSPEvent.CANCEL, onScreenshotCanceled);
			logger.addEntry("Screenshot save done.");
		}
		
		private function onScreenshotCanceled(e:SSPEvent):void {
			screenSaver.removeEventListener(SSPEvent.SUCCESS, onScreenshotSaved);
			screenSaver.removeEventListener(SSPEvent.CANCEL, onScreenshotCanceled);
			logger.addUser("Screenshot save canceled.");
		}
		
		private function getScreenshotName():String {
			var strScreenSortOrder:int = int(screenSO) + 1;
			var strName:String = "ssp"+TimeUtils.getDateAsYYYYMMDD(true, "_")+"_"+strScreenSortOrder+".jpg";
			return strName;
		}
		// -------------------------------- End of Save Screenshot to PC ------------------------------- //
		
		
		
		public function updateUserImageControls():Boolean {
			var imageOK:Boolean;
			btnImage.showThumb(null); // Remove existing image.
			btnImage.visible = false;
			btnAddImage.visible = false;
			btnRemoveImage.visible = false;
			btnScreenshot.visible = (_isHeader)? false : true;
			imageThumb = uM.getUserImageThumb(screenId, btnImage.thumbnailW, btnImage.thumbnailH, true);
			
			if (imageThumb) {
				if (!_isHeader) {
					btnRemoveImage.visible = true;
					btnImage.visible = true;
					btnImage.showThumb(imageThumb);
					imageOK = true;
				}
			} else {
				if (!_isHeader) {
					btnAddImage.visible = true;
					//btnImage.showThumb(null);
				}
			}
			return imageOK;
		}
		
		private function removeUserImage():void {
			uM.addUserImage(screenId, null, ""); // Empty location means not from Server.
			updateUserImageControls();
		}
		
		private function showUserImage():void {
			uM.playUserImageFromScreenId(screenId.toString());
		}
		
		private function notifyChanges():void {
			this.dispatchEvent(new SSPEvent(SSPEvent.UPDATE));
		}
		
		private function userVideoEnabled(value:Boolean):void {
			if (value) {
				txtVideoLocation.visible = false;
				btnApplyVideoLocation.visible = false;
				txtVideonInfo.visible = true;
				btnRemoveVideoLocation.visible = true;
				btnPlayVideo.visible = true;
			} else {
				txtVideoLocation.visible = true;
				btnApplyVideoLocation.visible = true;
				txtVideonInfo.visible = false;
				btnRemoveVideoLocation.visible = false;
				btnPlayVideo.visible = false;
			}
		}
		
		public function get isHeader():Boolean {
			return _isHeader;
		}
		
		public function dispose():void {
			videoValidatorEventHandler.RemoveEvents();
			imageEventHandler.RemoveEvents();
			SSPToolTip.getInstance().deleteToolTips(vTooltipSettings, true);
			removeListeners();
			btnImage.showThumb(null);
			if (parent) parent.removeChild(this);
		}
	}
}