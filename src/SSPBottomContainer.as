package src
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.bottom.SmallTabComments;
	import src.bottom.SmallTabMinutes;
	import src.bottom.SmallTabVideos;
	import src.buttons.SSPLabelButton;
	import src.controls.SmallTab;
	import src.controls.texteditor.SSPCommentsEditor;
	import src.minutes.MinutesGlobals;
	import src.minutes.SSPMinutesEditor;
	import src.videos.VideoGallery;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	
	public class SSPBottomContainer extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		// Tabs.
		private var aTabs:Vector.<SmallTab>;
		private var _tabMinutes:SmallTabMinutes;
		private var _tabComments:SmallTabComments;
		private var _tabVideos:SmallTabVideos;
		private var tabsInitialXPos:Number = 0;
		private var tabsPadding:Number = 2;
		
		// Editors.
		public var comments:SSPCommentsEditor;
		public var minutes:SSPMinutesEditor;
		public var videos:VideoGallery;
		
		private var paddingX:uint = 10;
		private var paddingY:uint = 8;
		
		public function SSPBottomContainer()
		{
			super();
			_tabMinutes = new SmallTabMinutes(paddingX, paddingY);
			_tabComments = new SmallTabComments(paddingX, paddingY);
			_tabVideos = new SmallTabVideos(paddingX, paddingY);
			this.addChild(_tabMinutes);
			this.addChild(_tabComments);
			this.addChild(_tabVideos);
			aTabs = Vector.<SmallTab>([_tabMinutes, _tabComments, _tabVideos]);
			
			this.x = 248;
			this.y = 455;
			
			comments = new SSPCommentsEditor(paddingX, paddingY+_tabComments.height+2, 646, 100, 13, "", 0, false);
			this.addChild(comments);
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			_tabMinutes.tabLabel = sG.interfaceLanguageDataXML.buttons._btnTabMinutes.text();
			_tabComments.tabLabel = sG.interfaceLanguageDataXML.buttons._btnTabComments.text();
			_tabVideos.tabLabel = sG.interfaceLanguageDataXML.buttons._btnTabVideos.text();
			
			_tabMinutes.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTabMinutes.text());
			_tabComments.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTabComments.text());
			_tabVideos.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTabVideos.text());
			
			initVideosContainer();
			if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				initMinutesContainer();
				if (MinutesGlobals.getInstance().useMinutes) {
					selectMinutes();
				} else {
					selectComments();
				}
			} else {
				selectComments();
			}
			
			sspEventDispatcher.addEventListener(SSPEvent.MINUTES_ENABLED, onToggleMinutes);
			addListeners();
		}
		
		private function initMinutesContainer():void {
			//minutes = new SSPMinutesEditor(lineComments.x, lineMinutes.y+lineMinutes.height);
			minutes = new mcMinutesEditor();
			minutes.x = paddingX;
			minutes.y = paddingY+_tabMinutes.height+2;
			this.addChild(minutes);
		}
		
		private function initVideosContainer():void {
			videos = new VideoGallery(642, 101);
			videos.x = paddingX;
			videos.y = paddingY+_tabVideos.height+2;
			this.addChild(videos);
		}
		
		private function addListeners():void {
			_tabMinutes.addEventListener(MouseEvent.CLICK, onTabsClick, false, 0, true);
			_tabComments.addEventListener(MouseEvent.CLICK, onTabsClick, false, 0, true);
			_tabVideos.addEventListener(MouseEvent.CLICK, onTabsClick, false, 0, true);
		}
		
		private function removeListeners():void {
			_tabMinutes.removeEventListener(MouseEvent.CLICK, onTabsClick);
			_tabComments.removeEventListener(MouseEvent.CLICK, onTabsClick);
			_tabVideos.removeEventListener(MouseEvent.CLICK, onTabsClick);
		}
		
		private function deselectTabs():void {
			for each (var t:SmallTab in aTabs) {
				t.tabSelected = false;
			}
		}
		
		private function selectTab(tab:SmallTab):void {
			if (!tab) return;
			deselectTabs();
			for each (var t:SmallTab in aTabs) {
				if (t == tab) {
					t.tabSelected = true;
				} else {
					t.tabSelected = false;
				}
			}
			updateTabsLayout();
		}
		
		private function onToggleMinutes(e:SSPEvent):void {
			deselectTabs();
			if (!MinutesGlobals.getInstance().useMinutes) {
				//_tabComments.tabSelected = true;
				selectComments();
			} else {
				//_tabMinutes.tabIsEnabled = true;
				selectMinutes();
			}
			if (minutes) minutes.updateScoreAndTimeSpent();
		}
		
		private function updateTabsLayout():void {
			// Minutes.
			if (!MinutesGlobals.getInstance().useMinutes) {
				_tabMinutes.tabIsEnabled = false;
				if (minutes) {
					minutes.resetMinutes();
					minutes.editorEnabled = false;
					minutes.updateScoreAndTimeSpent();
				}
			}
			
			// Videos.
			var numVideos:int = sG.sessionDataXML.video.length();
			if (numVideos == 0) {
				_tabVideos.tabIsEnabled = false;
				if (videos) videos.galleryEnabled = false;
			}
			
			// Tabs Pos.
			var xPosTmp:Number = tabsInitialXPos;
			for each (var t:SmallTab in aTabs) {
				t.tabXPos = xPosTmp;
				xPosTmp += t.tabWidth + tabsPadding;
			}
		}
		
		private function onTabsClick(e:MouseEvent):void {
			var btn:SmallTab = e.currentTarget as SmallTab;
			if (!btn) return;
			switch(btn) {
				case _tabMinutes:
					selectMinutes();
					break;
				case _tabComments:
					selectComments();
					break;
				case _tabVideos:
					selectVideos();
					break;
			}
		}
		
		private function displayMinutes():void {
			hideAll();
			if (minutes) {
				minutes.editorEnabled = true;
				minutes.visible = true;
			}
		}
		
		private function displayComments():void {
			hideAll();
			if (comments) {
				comments.editorEnabled = true;
				comments.visible = true;
			}
		}
		
		private function displayVideos():void {
			hideAll();
			if (videos) {
				videos.galleryEnabled = true;
				videos.visible = true;
			}
		}
		
		private function hideAll():void {
			if (comments) {
				comments.editorEnabled = false;
				comments.visible = false;
			}
			if (minutes) {
				minutes.editorEnabled = false;
				minutes.visible = false;
			}
			if (videos) {
				videos.galleryEnabled = false;
				videos.visible = false;
			}
		}
		
		public function selectMinutes():void {
			displayMinutes();
			selectTab(_tabMinutes);
		}
		
		public function selectComments():void {
			displayComments();
			selectTab(_tabComments);
		}
		
		public function selectVideos():void {
			displayVideos();
			selectTab(_tabVideos);
		}
	}
}