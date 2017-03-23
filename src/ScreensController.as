package src
{
	import src.events.SSPMinutesEvent;
	import src.events.SSPScreenEvent;
	import src.minutes.MinutesGlobals;
	import src.minutes.MinutesManager;
	import src.team.PRTeamManager;
	import src.team.SSPTeamEvent;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.SessionView;
	import src3d.models.PlayersManager;
	import src3d.models.soccer.players.Player;
	import src3d.utils.EventHandler;
	import src3d.utils.Logger;
	import src3d.utils.SessionScreenUtils;

	public class ScreensController
	{
		// Global variables.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		private var mM:MinutesManager = MinutesManager.getInstance();
		private var logger:Logger = Logger.getInstance();
		
		// Refs.
		private var ref:main;
		private var sV:SessionView;
		
		private var flagAddingScreen:Boolean;
		
		// Events.
		//private var stageEventHandler:EventHandler;
		//private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		public function ScreensController(ref:main, sessionView:SessionView)
		{
			this.ref = ref;
			this.sV = sessionView;
			init();
		}
		
		private function init():void {
			// TabBar.
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_ADD, onSessionScreenAdd);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_CREATED, onSessionScreenCreated);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_REMOVE, onSessionScreenRemove);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_SELECT, onSessionScreenSelect);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_TITLE_CHANGE, onSessionScreenTabTitleChange);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_UPDATE_TEAM_SETTINGS, onSessionScreenUpdateTeamSettings);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_REORDER, onSessionScreenReorder);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_CLONE_FROM_TAB, onScreenCloneFromTab);
			ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_CLONE_TOGGLE, onScreenCloneToggle);
			
			// Team Settings Menu.
			if (sG.sessionType == SessionGlobals.SESSION_TYPE_MATCH) {
				sspEventHandler.addEventListener(SSPTeamEvent.SCREEN_SETTINGS_AUTO_LAYOUT_PITCH, onAutoLayoutPitch);
				sspEventHandler.addEventListener(SSPTeamEvent.SCREEN_SETTINGS_PLAYER_UPDATE, onUpdatePlayerTeamSettings);
				sspEventHandler.addEventListener(SSPTeamEvent.TEAM_LIST_REMOVE_ITEM, onTeamListRemoveItem);
				sspEventHandler.addEventListener(SSPTeamEvent.TEAM_LIST_REMOVE_ALL, onTeamListRemoveAll);
				sspEventHandler.addEventListener(SSPTeamEvent.TEAM_LIST_CHANGE, onTeamListChange);
				sspEventHandler.addEventListener(SSPTeamEvent.TEAM_SETTINGS_CHANGE_NAME_FORMAT, onPlayerNameChangeFormat);
				sspEventHandler.addEventListener(SSPEvent.SESSION_SCREEN_SELECT_TEAM_PLAYER, onSelectTeamPlayer);
				sspEventHandler.addEventListener(SSPEvent.PLAYERS_UPDATE_DEFAULT_KITS, onPlayerKitsUpdate);
			}
			
			// Settings Form.
			//ref.tabBar.addEventListener(SSPEvent.SESSION_SCREEN_TITLE_CHANGE, onSettingsScreenTitleChange);
			
			// Screens.
			sspEventHandler.addEventListener(SSPScreenEvent.SCREEN_PLAYER_CREATED, onPlayerCreated);
			sspEventHandler.addEventListener(SSPScreenEvent.SCREEN_PLAYER_REMOVED, onPlayerRemoved);
			sspEventHandler.addEventListener(SSPScreenEvent.SCREEN_PLAYER_SUBSTITUTION, onPlayerSubstitution);
			sspEventHandler.addEventListener(SSPScreenEvent.SCREEN_PLAYER_SELECTED, onPlayerSelected);
			sspEventHandler.addEventListener(SSPScreenEvent.SCREEN_PLAYER_DESELECTED, onPlayerDeselected);
			
			// Minutes.
			sspEventHandler.addEventListener(SSPMinutesEvent.TEAM_PLAYER_RED_CARD, onTeamPlayerRedCard);
		}
		
		
		
		// ----------------------------- Team Settings ----------------------------- //
		private function onAutoLayoutPitch(e:SSPTeamEvent):void {
			sV.autoLayoutPitch(e);
//			ref.tabBar.tabUpdateGroup(sV.currentScreenId);
		}
		private function onUpdatePlayerTeamSettings(e:SSPTeamEvent):void {
			sV.updatePlayerTeamSettings(e);
		}
		private function onTeamListRemoveItem(e:SSPTeamEvent):void {
			sV.clearPlayerTeamData(e);
		}
		private function onTeamListRemoveAll(e:SSPTeamEvent):void {
			sV.clearPlayerTeamData(e);
		}
		private function onTeamListChange(e:SSPTeamEvent):void {
			// Minutes.
			mM.teamListChanged(sV.currentScreen);
		}
		private function onPlayerKitsUpdate(e:SSPEvent):void {
			// Minutes.
			mM.teamListChanged(sV.currentScreen);
		}
		private function onPlayerNameChangeFormat(e:SSPTeamEvent):void {
			mM.teamListPlayerNameChanged();
		}
		private function onSelectTeamPlayer(e:SSPEvent):void {
			sV.selectTeamPlayer(e);
		}
		// -------------------------- End of Team Settings ------------------------- //
		
		
		
		// ----------------------------- Tab bar ----------------------------- //
		private function onSessionScreenAdd(e:SSPEvent):void {
			flagAddingScreen = true;
			// Tell SessionView to create a 3D Screen.
			var sId:uint = e.eventData as uint;
			logger.addInfo("Creating screen (id "+sId+").");
			// 3D.
			sV.sessionScreenAdd(sId);
		}
		private function onSessionScreenCreated(e:SSPEvent):void {
			flagAddingScreen = false;
			// If SessionView has created the 3D screen, update comments and settings.
			var sId:int = e.eventData;
			if (sId == -1) return;
			// Comments.
			ref._comments.displayScreenComments(sId);
			// Settings.
//			ref.settingsForm.form.refreshSettings();
			// 2D Toolbars.
			ref.updateToolbars();
			logger.addInfo("Screen created (id "+sId+").");
		}
		private function onSessionScreenRemove(e:SSPEvent):void {
			var sId:uint = e.eventData as uint;
			logger.addInfo("Deleting screen (id "+sId+").");
			// 3D.
			sV.sessionScreenRemove(sId);
			// Comments.
			ref._comments.displayScreenComments(-1);
			// Settings.
//			ref.settingsForm.form.refreshSettings();
			// 2D Toolbars.
			ref.updateToolbars();
			// Minutes.
			mM.screenDeleted(String(sId));
			logger.addInfo("End of screen deletion.");
		}
		private function onSessionScreenSelect(e:SSPEvent):void {
			var sId:uint = e.eventData as uint;
			logger.addInfo("Selecting screen (id "+sId+").");
			var menusManager:MenusManager = MenusManager.getInstance();
			// 3D.
			sV.sessionScreenSelect(sId);
			// Comments.
			ref._comments.displayScreenComments(sId);
			// 2D Toolbars.
			ref.updateToolbars();
			
			// Match Mode.
			if (!SessionGlobals.getInstance().sessionTypeIsMatch) return;
			// Team Menu.
			ref._menu.updateScreenSettings(sId, false);
			ref._menu.updateTeamLists();
			
			if (!MinutesGlobals.getInstance().useMinutes || !mM.playStarted) {
				// If Period.
				if (SessionScreenUtils.getScreenFromScreenId(sId, sV.aScreens).screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					menusManager.showTeamSettings();
				} else {
					// If Set-piece.
					if (!menusManager.isOurTeamDisplayed() && !menusManager.isOppTeamDisplayed()){
						menusManager.showTeamOurTeam();
					} else {
						menusManager.showTeamMenu();
					}
				}
			} else {
				// If Period.
				if (SessionScreenUtils.getScreenFromScreenId(sId, sV.aScreens).screenType == SessionGlobals.SCREEN_TYPE_PERIOD) {
					if (mM.playStarted){
						if (flagAddingScreen) {
							menusManager.showTeamSettings();
						} else if (!menusManager.isOurTeamDisplayed() && !menusManager.isOppTeamDisplayed()) {
							menusManager.showTeamOurTeam();
						} else {
							menusManager.showTeamMenu();
						}
					}
				} else {
					// If Set-piece.
					if (!menusManager.isOurTeamDisplayed() && !menusManager.isOppTeamDisplayed()){
						menusManager.showTeamOurTeam();
					} else {
						menusManager.showTeamMenu();
					}
				}
			}
			
			// Minutes.
			mM.screenSelected(String(sId));
		}
		private function onSessionScreenTabTitleChange(e:SSPEvent):void {
			var sId:uint = e.eventData as uint;
			// Settings.
//			ref.settingsForm.form.refreshSettings();
			// Team Settings.
			ref._menu.updateScreenSettings(sId, false);
		}
		private function onSessionScreenUpdateTeamSettings(e:SSPEvent):void {
			var sId:uint = e.eventData.tabScreenId as uint;
			var tabGroupChanged:Boolean = e.eventData.tabGroupChanged as Boolean;
			// Team Settings.
			ref._menu.updateScreenSettings(sId, tabGroupChanged);
			// 3D.
			if (tabGroupChanged) sV.autoLayoutPitch(null); // Using null, session screen will update camera settings and update existing players (no new players added).
		}
		private function onSessionScreenReorder(e:SSPEvent):void {
			// Settings.
			mM.screenReorder();
		}
		private function onScreenCloneFromTab(e:SSPEvent):void {
			//logger.addText("Cloning Screen From Tab (Id:"+e.eventData+").", false);
			sV.screenClone(e.eventData as Number);
		}
		private function onScreenCloneToggle(e:SSPEvent):void {
			if (e.eventData == null) return;
			sV.screenCloneToggle(e.eventData as Boolean);
		}
		// -------------------------- End of Tab bar ------------------------- //
		
		
		
		// ----------------------------- Settings ----------------------------- //
		/*private function onSettingsScreenTitleChange(e:SSPEvent):void {
			var sId:uint = e.eventData as uint;
			// Tabs.
			ref.tabBar.updateTabTitle(sId);
		}*/
		// -------------------------- End of Settings ------------------------- //
		
		
		
		// ----------------------------- Minutes ----------------------------- //
		private function onTeamPlayerRedCard(e:SSPMinutesEvent):void {
			if (!e || !e.eventData || !e.eventData.screen || !e.eventData.teamPlayerId || !e.eventData.teamSide) return; 
			var sScreen:SessionScreen = e.eventData.screen as SessionScreen;
			sScreen.deleteTeamPlayerFromId(e.eventData.teamPlayerId, e.eventData.teamSide);
		}
		// -------------------------- End of Minutes ------------------------- //
		
		
		
		// ----------------------------- Others ----------------------------- //
		private function onPlayerSubstitution(e:SSPScreenEvent):void {
			ref._menu.updateTeamLists(); // Team Player Lists.
			// Minutes.
			mM.playerSubstitution(sV.currentScreen, e.eventData.playerOutSettings, e.eventData.playerInSettings);
		}
		
		private function onPlayerSelected(e:SSPScreenEvent):void {
			// Minutes.
			var p:Player = e.eventData as Player;
			if (p && p.teamPlayer && MinutesGlobals.getInstance().useMinutes) {
				MenusManager.getInstance().selectMinutes();
				mM.playerSelected(e.eventData as Player);
			}
		}
		
		private function onPlayerDeselected(e:SSPScreenEvent):void {
			// Minutes.
			mM.playerDeselected();
		}
		
		private function onPlayerCreated(e:SSPScreenEvent):void {
			ref._menu.updateTeamLists(); // Team Player Lists.
		}
		
		private function onPlayerRemoved(e:SSPScreenEvent):void {
			ref._menu.updateTeamLists(); // Team Player Lists.
			if (e && e.eventData && e.eventData.screen && e.eventData.playerSettings) {
				mM.playerRemoved(e.eventData.screen, e.eventData.playerSettings);
			}
		}
		// -------------------------- End of Others ------------------------- //
	}
}