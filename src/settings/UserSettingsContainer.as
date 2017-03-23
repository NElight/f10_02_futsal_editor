package src.settings
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.TextEvent;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.images.SSPImageItem;
	import src.tabbar.SSPTab;
	import src.tabbar.SSPTabBarBase;
	import src.user.UserMediaManager;
	import src.utils.BatchLoader;
	import src.utils.BatchLoaderEvent;
	import src.utils.BatchLoaderItem;
	import src.utils.URLNavigator;
	import src.utils.VideoValidatorUtils;
	import src.utils.VideoValidatorInfo;
	
	import src3d.SSPEvent;
	import src3d.ScreenshotItem;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.TextUtils;
	
	public class UserSettingsContainer extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var uM:UserMediaManager = UserMediaManager.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		private var parentForm:SSPSettingsForm;
		private var tabBar:SSPTabBarBase;
		private var _initialized:Boolean;
		
		private var videoImageList:UserSettingsList;
		private var mcSourceContainer:MovieClip;
		private var vCells:Vector.<UserSettingsListCell> = new Vector.<UserSettingsListCell>();
		
		
		private var loadStarted:Boolean;
		private var batchLoadIdx:int;
		
		private var strURLTitle:String = sG.interfaceLanguageDataXML.messages._filingVideoTitle.text();
		private var strURLInvalid:String = sG.interfaceLanguageDataXML.messages._filingErrorVideoInvalid.text();
		private var strInvalid:String = sG.interfaceLanguageDataXML.messages._filingErrorVideoInvalid.text();
		private var strTitle:String = sG.interfaceLanguageDataXML.messages._filingVideoTitle.text();
		
		private var serverDataLoaded:Boolean;
		
		public function UserSettingsContainer(parentForm:SSPSettingsForm, tabBar:SSPTabBarBase):void {
			this.parentForm = parentForm;
			this.tabBar = tabBar;
			if (!mcSourceContainer) mcSourceContainer = new MovieClip();
			var mcHeader:MovieClip = this.mcHeaderBG;
			videoImageList = new UserSettingsList(mcHeader.x, mcHeader.y+mcHeader.height, mcHeader.width, 390);
			var txtYouTubePDFHelpLink:TextField = this.textYouTubePDFHelpLink;
			var icoPDF:MovieClip = this.mcIconPDF;
			var txtHdrVideoURL:TextField = this.textHdrVideoURL;
			var txtHdrImageURL:TextField = this.textHdrImageURL;
			var txtHdrScreenshot:TextField = this.textHdrScreenshot;
			var tf:TextFormat = new TextFormat(SSPSettings.DEFAULT_FONT, 16, 0xFFFFFF, true);
			txtHdrVideoURL.defaultTextFormat = tf;
			txtHdrImageURL.defaultTextFormat = tf;
			txtHdrScreenshot.defaultTextFormat = tf;
			TextUtils.applyLinkStyle(txtYouTubePDFHelpLink, "#9DE4FF", "#FFFFFF", "#FFFFFF", "#9DE4FF");
			
			var sL:XML = sG.interfaceLanguageDataXML;
			txtHdrVideoURL.text = sL.titles._filingVideoUrl.text();
			txtHdrImageURL.text = sL.titles._filingUploadImage.text();
			txtHdrScreenshot.text = sL.titles._filingDownloadImage.text();
			var strPDFHelpLabel:String = sL.messages._filingVideoYouTubeHowto.text();
			var strYoutubeHelpCode:String = "youtube_help";
			var ytHelpXMLList:XMLList = sG.sessionDataXML.session.link_item.(_itemCode == strYoutubeHelpCode);
			if (ytHelpXMLList.length() > 0) {
				var strPDFLocation:String = ytHelpXMLList[0]._itemLocation.text();
				if (!strPDFLocation || strPDFLocation == "") {
					logger.addError("Empty "+strYoutubeHelpCode+" location found. Link not displayed.");
					txtYouTubePDFHelpLink.visible = false;
					icoPDF.visible = false;
				} else {
					strPDFLocation = sG.sessionDataXML.session._interfaceBaseUrl.text() +
						sG.sessionDataXML.session._itemBaseUrl.text() +
						sG.sessionDataXML.session._interfaceLanguageCode.text() +
						strPDFLocation;
					txtYouTubePDFHelpLink.visible = true;
					icoPDF.visible = true;
					txtYouTubePDFHelpLink.htmlText = "<a href='event:"+strPDFLocation+"'>"+strPDFHelpLabel+"</a>";
					txtYouTubePDFHelpLink.addEventListener(TextEvent.LINK, onHyperLinkEventHandler);
				}
			} else {
				logger.addError("Can't find "+strYoutubeHelpCode+" link_item.");
				txtYouTubePDFHelpLink.visible = false;
				icoPDF.visible = false;
			}
			
			
			this.addChild(videoImageList);
		}
		
		// ----------------------------- Events ----------------------------- //
		private function addListeners():void {
			
		}
		
		private function removeListeners():void {
			
		}
		
		private function onHyperLinkEventHandler(e:TextEvent):void {
			logger.addUser("Clicked on link: 'How to Upload to YouTube'.");
			// Use switch/case for multiple links.
			/*switch(e.text){
				case "home.html":
					onHyperlinkClick(e.text, "_home");
					break;
				case "wiki":
					onHyperlinkClick(e.text, "_wiki");
					break;
				default:
					onHyperlinkClick(e.text, "_new");
					break;
			}*/
			var strLocation:String = e.text;
			var strTarget:String = "_new";
			onHyperlinkClick(strLocation, strTarget);
		}
		private function onHyperlinkClick(location:String, target:String) : void {
			URLNavigator.openLocation(location, target);
		}
		// -------------------------- End of Events ------------------------- //
		
		
		
		// ----------------------------- Screens ----------------------------- //
		private function loadServerData():void {
			loadStarted = true;
			uM.addEventListener(BatchLoaderEvent.ALL_COMPLETE, onServerDataLoaded);
			uM.startDataLoad();
		}
		private function onServerDataLoaded(e:BatchLoaderEvent):void {
			serverDataLoaded = true;
			loadStarted = false;
			updateList();
		}
		public function updateList():void {
			if (loadStarted) return;
			if (!serverDataLoaded) loadServerData();
			
			var vCell:UserSettingsListCell;
			var cellYPos:Number = 0;
			var intScreenCount:int;
			var intSetPieceCount:int;
			var tabXML:XML;
			var screenId:int;
			var screenSO:int;
			var screenType:String;
			var screenCount:int;
			var screenLabel:String;
			
			// Take new screenshots.
			uM.updateScreenshots();
			var validated:Boolean = uM.userVideosValidated();
			
			// Remove previous Cells if any.
			for each(var sc:UserSettingsListCell in vCells) {
				sc.dispose();
				sc = null;
			}
			vCells = new Vector.<UserSettingsListCell>();
			
			// Create Overall Data.
			screenId = -1;
			screenSO = -1;
			screenType = "";
			screenCount = 0;
			screenLabel = sG.interfaceLanguageDataXML.titles._filingVideoOverallSession.text();
			vCell = new UserSettingsListCell(this, true, screenId, screenSO, screenType, screenCount, screenLabel);
			vCell.y = cellYPos;
			cellYPos += vCell.height;
			vCells.push(vCell);
			mcSourceContainer.addChild(vCell);
			
			// Create Screen Cells.
			for (var i:uint = 0;i<tabBar.aTabs.length;i++) {
				tabXML = tabBar.aTabs[i].tabScreenXML;
				// Create Screen Data.
				screenId = tabBar.aTabs[i].tabScreenId;
				screenSO = tabBar.aTabs[i].tabSortOrder;
				screenType = tabBar.aTabs[i].tabScreenType;
				screenLabel = tabBar.aTabs[i].tabLabel;
				if (screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
					intSetPieceCount++;
					screenCount = intSetPieceCount;
				} else {
					intScreenCount++;
					screenCount = intScreenCount;
				}
				// Create Screen Cell.
				vCell = new UserSettingsListCell(this, false, screenId, screenSO, screenType, screenCount, screenLabel);
				vCell.y = cellYPos;
				cellYPos += vCell.height;
				vCells.push(vCell);
				mcSourceContainer.addChild(vCell);
			}
			serverDataLoaded = true;
			videoImageList.source = mcSourceContainer; // Note that mcSourceContainer must be created in a previous function. Otherwise, controls will throw a #1009 error.
			videoImageList.invalidate();
			videoImageList.update();
		}
		// -------------------------- End of Screens ------------------------- //
		
		
		
		// ----------------------------------- Public ----------------------------------- //
		public function set settingsEnabled(value:Boolean):void {
			if (value) {
				this.visible = true;
				this.updateList(); // Updates Screen settings.
			} else {
//				saveSettingsToXML();
				this.visible = false;
			}
		}
		// -------------------------------- End of Public ------------------------------- //
	}
}