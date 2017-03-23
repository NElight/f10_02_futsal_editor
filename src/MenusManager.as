package src
{
	import src.minutes.MinutesGlobals;
	
	import src3d.SessionGlobals;

	public class MenusManager
	{
		
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:MenusManager;
		private static var _allowInstance:Boolean = false;
		public function MinutesManager()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//init();
			}
		}
		public static function getInstance():MenusManager {
			if(_self == null) {
				_allowInstance=true;
				_self = new MenusManager();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var m:main;
		
		public function MenusManager()
		{
		}
		
		// ----------------------------- Main Menu ----------------------------- //
		public function initialize(_main:main):void {
			this.m = _main;
		}
		public function showTeamMenu():void {
			m._menu.slider(accordion.MENU_5_TEAM);
		}
		public function showTeamSettings():void {
			if (sG.sessionTypeIsMatch) {
				showTeamMenu();
				m._menu.showTeamSettings();
			}
		}
		public function showTeamOurTeam():void {
			if (sG.sessionTypeIsMatch) {
				showTeamMenu();
				m._menu.showTeamOurTeam();
			}
		}
		public function showTeamOppTeam():void {
			if (sG.sessionTypeIsMatch) {
				showTeamMenu();
				m._menu.showTeamOppTeam();
			}
		}
		public function isOurTeamDisplayed():Boolean {
			return (sG.sessionTypeIsMatch)? m._menu.isOurTeamDisplayed() : false;
		}
		public function isOppTeamDisplayed():Boolean {
			return (sG.sessionTypeIsMatch)? m._menu.isOppTeamDisplayed() : false;
		}
		public function isTeamSettingsDisplayed():Boolean {
			return (sG.sessionTypeIsMatch)? m._menu.isTeamSettingsDisplayed() : false;
		}
		
		public function isMenuTeamDisplyed():Boolean {
			return (m._menu.selectedTab == accordion.MENU_5_TEAM)? true : false;
		}
		// -------------------------- End of Main Menu ------------------------- //
		
		
		
		// ----------------------------- Bottom Menu ----------------------------- //
		public function selectMinutes():void {
			if (sG.sessionTypeIsMatch && MinutesGlobals.getInstance().useMinutes) m.bottom.selectMinutes();
		}
		// -------------------------- End of Bottom Menu ------------------------- //
	}
}