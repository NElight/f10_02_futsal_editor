package src.team.list
{
	import fl.controls.ScrollPolicy;
	import fl.core.InvalidationType;
	import fl.data.DataProvider;
	
	import flash.events.Event;
	
	import src.team.PRCellRendererBase;
	import src.team.PRItem;
	import src.team.PRListBase;
	import src.team.TeamGlobals;
	
	import src3d.models.soccer.players.Player;
	import src3d.utils.MiscUtils;

	public class PRCListBase extends PRListBase
	{
		private var _listExpanded:Boolean = true;
		private var _nameFormat:uint = 0;
		private var _useEdit:Boolean = true;
		public function PRCListBase(useEdit:Boolean)
		{
			super();
			this._useEdit = useEdit;
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.verticalScrollPolicy = ScrollPolicy.ON;
		}
		
		public override function updateSortOrder():void {
			super.updateSortOrder();
		}
		
		public override function invalidate(property:String=InvalidationType.ALL, callLater:Boolean=true):void {
			resetRecordsStyle();
			updatePlayerPositions();
			updateTeamListStyle();
			updateRepeatedItemNumber();
			super.invalidate(property, callLater);
		}
		
		protected function resetRecordsStyle():void {
			if (!this.dataProvider) return;
			var aList:Array = this.dataProvider.toArray();
			for (var i:uint;i<aList.length;i++) {
				aList[i].recordUsed = false;
				aList[i].recordRepeated = false;
			}
		}
		
		protected function updatePlayerPositions():void {
			if (!this.dataProvider) return;
			var prItem:PRItem;
			var aDP:Array = this.dataProvider.toArray();
			var firstGoalkeeper:PRItem;
			
			// 1) If there is no Goalkeeper, the first player without position is made Goalkeeper
			for (var i:uint=0;i<aDP.length;i++) {
				prItem = aDP[i];
				if (prItem) {
					if (prItem.playerIsGoalkeeper) {
						firstGoalkeeper = prItem;
						break;
					}
					if (!firstGoalkeeper) {
						if (prItem.playerPositionId == "" || prItem.playerPositionId == "0") firstGoalkeeper = prItem;
					}
				}
			}
			
			// 2) The first Goalkeeper is always placed in top position.
			if (!firstGoalkeeper) return;
			firstGoalkeeper.playerIsGoalkeeper = true; // Reset if unpositioned player.
			var itemIdx:int = aDP.indexOf(firstGoalkeeper);
			if (itemIdx > 0) {
				//this.dataProvider.removeItem(firstGoalkeeper);
				//this.dataProvider.addItemAt(firstGoalkeeper, 0);
				aDP.splice(itemIdx, 1);
				aDP.unshift(firstGoalkeeper);
				this.dataProvider = new DataProvider(aDP);
			}
			
			updateSortOrder();
		}
		
		protected function updateRepeatedItemNumber():void {
			if (!this.dataProvider) return;
			var i:uint;
			var j:uint;
			var itemA:PRItem;
			var itemB:PRItem;
			var aDP:Array = this.dataProvider.toArray();
			for (i=0;i<aDP.length;i++) {
				itemA = aDP[i];
				if (itemA) {
					for (j=0;j<aDP.length;j++) {
						itemB = aDP[j];
						if (itemB && itemB != itemA && itemB.playerNumber == itemA.playerNumber) {
							itemA.recordRepeated = true;
						}
					}
				}
			}
		}
		
		protected function updateTeamListStyle():void {
			if (!this.dataProvider) return;
			//resetRecordsStyle();
			if (!main.sessionView || !main.sessionView.currentScreen) return;
			var aPlayers:Vector.<Player> = main.sessionView.currentScreen.aPlayers
			var pItem:PRItem;
			var p:Player;
			for (var i:uint;i<aPlayers.length;i++) {
				p = aPlayers[i];
				if (p && p.teamPlayer && p.teamSide == this.teamSide) {
					pItem = this.getPlayerRecordItemFromId(p.teamPlayerId);
					if (pItem) pItem.recordUsed = true;
				}
			}
		}
		
		public function set listExpanded(le:Boolean):void {
			_listExpanded = le;
			var pr:PRCellRendererBase;
			if (_listExpanded) {
				pr = new PRCCellRendererExpanded();
				if (_useEdit) {
					this.setStyle("cellRenderer", PRCCellRendererExpanded);
				} else {
					this.setStyle("cellRenderer", PRCCellRendererExpandedNoEdit);
				}
			} else {
				pr = new PRCCellRendererCompact();
				if (_useEdit) {
					this.setStyle("cellRenderer", PRCCellRendererCompact);
				} else {
					this.setStyle("cellRenderer", PRCCellRendererCompactNoEdit);
				}
			}
			this.rowHeight = pr.height;
			this.width = pr.width + 14.5;
		}
		
		public function get listExpanded():Boolean { return _listExpanded; }
		public function get listUseEdit():Boolean { return _useEdit; }
	}
}