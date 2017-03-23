package src.team
{
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import src.controls.SSPList;
	import src.team.forms.PRCellRendererPopupList;
	
	import src3d.SSPCursors;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class PRListBase extends SSPList
	{
		public static const LIST_NAME_OUR_TEAM:String	= "LIST_NAME_OUR_TEAM";
		public static const LIST_NAME_OPPOSITION:String	= "LIST_NAME_OPPOSITION";
		public static const LIST_NAME_SOURCE:String		= "LIST_NAME_SOURCE";
		public static const LIST_NAME_TARGET:String		= "LIST_NAME_TARGET";
		
		protected var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		//protected var prMain:PRPopupContainer;
		protected var sourceName:String = "";
		protected var listBounds:Rectangle = new Rectangle();
		private var _acceptDrag:Boolean;
		
//		private var prItemClone:PRItem = new PRItem();
//		private var prItemBlank:PRItem;
		private var prItemDrag:PRItem;
		private var oldIdx:int = -1; // -1 indicates that item didn't exist on this list before.
		
		protected var stageHandler:EventHandler;
		
		protected var teamSide:String = "";
		
		public function PRListBase()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			stageHandler = new EventHandler(stage);
			sspEventDispatcher.addEventListener(SSPEvent.PLAYERS_UPDATE_DEFAULT_KITS, onPlayerKitsUpdate);
//			this.addEventListener(ListEvent.ITEM_CLICK, onItemClick);
//			this.addEventListener(Event.CHANGE, onListChange);
			
//			prItemBlank = new PRItem();
//			prItemBlank.playerId = ""; // "" indicates it is an empty record.
		}
		
		protected function onItemClick(e:ListEvent):void {
			//trace("onItemClick()");
		}
		
		protected function onListChange(e:Event):void {
			//notifyListChange();
		}
		
		protected function onPlayerKitsUpdate(e:SSPEvent):void {
			this.invalidateList();
		}
		
		protected function notifyListChange():void {
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_CHANGE)); // Notify to minutes.
		}
		
		
		
		// ----------------------------------- Drag and Drop ----------------------------------- //
		public function startDragging(pr:PRCellRendererBase, sourceName:String):void {
			//trace("startDragging()");
			if (!pr) return;
			var tmpPRItem:PRItem = pr.data as PRItem;
			if (!tmpPRItem) return;
			
			this.sourceName = sourceName;
			
			// Check if item exist on this list.
			oldIdx = getPRItemIndex(tmpPRItem);
			if (oldIdx != -1) {
				prItemDrag = getItemAt(oldIdx) as PRItem; // Use the current item in list.
				if (!prItemDrag) return;
			} else {
				prItemDrag = tmpPRItem.clone(); // We need a clone to allow different cell renderer settings (eg. disable) in source and target lists.
			}
			acceptDrag = true;
		}
		protected function set acceptDrag(accept:Boolean):void {
			_acceptDrag = accept;
			if (_acceptDrag) {
				listBounds = this.getBounds(stage);
				prItemDrag.blankRecord = true;
				this.invalidateList();
				stageHandler.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove, false, 0, true);
				stageHandler.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 0, true);
			} else {
				prItemDrag.blankRecord = false;
				this.invalidateList();
				stageHandler.RemoveEvents();
				SSPCursors.getInstance().reset();
			}
		
		}
		protected function get acceptDrag():Boolean { return _acceptDrag; }
		
		protected function onStageMouseMove(e:MouseEvent):void {
			//trace("onStageMouseMove()");
			if (!acceptDrag) {
				stageHandler.RemoveEvents();
				return;
			}
			
			checkPRDrop();
			
			var mousePos:Point = new Point( mouseX, mouseY );
			mousePos = this.localToGlobal( mousePos );
			if (!isMouseOnList(mousePos)) {
//				removePRDestination();
				if (sourceName == LIST_NAME_TARGET) toggleForbiddenMouseIcon(true); // Items can't be dragged out of the target list in 'Select Teams' form. User has to click X button to remove them.
				return;
			}
			
			toggleForbiddenMouseIcon(false);
			
			// Create destination area if not exist already.
			var newBlankIdx:int = 0;
			var oldBlankIdx:int = this.dataProvider.getItemIndex(prItemDrag);
			if (oldBlankIdx < 0) {
				this.dataProvider.addItem(prItemDrag);
			} else {
				if (newBlankIdx > -1) {
					
					newBlankIdx = (this.length > 0)? getIdxFromMousePos(mousePos) : 0;
					
					if (newBlankIdx >= this.length) newBlankIdx = this.length - 1;
					
					if (oldBlankIdx == newBlankIdx) return;
					
					this.dataProvider.removeItem(prItemDrag);
					
					if (newBlankIdx != -1) {
						this.dataProvider.addItemAt(prItemDrag, newBlankIdx);
					} else {
						//this.dataProvider.addItem(emptyCellRenderer);
					}
				}
			}
		}
		
		protected function onStageMouseUp(e:MouseEvent):void {
			stageHandler.RemoveEvents();
			SSPCursors.getInstance().reset();
			checkPRDrop();
			// If dropped inside.
			if (isMouseOnList()) {
				prItemDrag.recordEnabled = true;
				this.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TARGET_LIST_MOUSE_UP, prItemDrag.playerId));
			} else {
				if (this.name == LIST_NAME_TARGET) {
					sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TARGET_LIST_REMOVE_ITEM, prItemDrag));
				}
			}
			acceptDrag = false;
			//notifyListChange();
		}
		
		private function checkPRDrop():void {
			// If object dropped out of this list.
			if (!isMouseOnList()) {
				// -1 indicates that item didn't exist on this list before.
				if (oldIdx == -1) {
					this.dataProvider.removeItem(prItemDrag);
				} else {
					restorePR(); // Reset positions.
				}
			}
		}
		
		private function restorePR():void {
			// Take item to the original position.
			var newIdx:int = this.dataProvider.getItemIndex(prItemDrag);
			if (newIdx == -1) return;
			if (!prItemDrag) return;
			if (this.dataProvider.getItemIndex(prItemDrag) != -1) this.dataProvider.removeItem(prItemDrag);
			this.dataProvider.addItemAt(prItemDrag, oldIdx);
			return;
		}
		
		/*private function removePR():void {
			if (!prItemDrag) return;
			if (this.dataProvider.getItemIndex(prItemDrag) != -1) this.dataProvider.removeItem(prItemDrag);
		}*/
		
		protected function toggleForbiddenMouseIcon(toggleMouseIcon:Boolean):void {
			if (toggleMouseIcon) {
				SSPCursors.getInstance().setUndo();
			} else {
				SSPCursors.getInstance().reset();
			}
		}
		
		private function getIdxFromMousePos(mousePos:Point):int {
			var newIdx:int = -1;
			// Update destination area position.
			var objUnderPoint:Array = stage.getObjectsUnderPoint( mousePos );
			var objFound:PRCellRendererPopupList;
			var objClassName:String;
			
			var yPos:Number = this.mouseY + this.verticalScrollPosition;
			
			var idx:uint = Math.abs(Math.floor(yPos / this.rowHeight));
			
			return idx;
		}
		private function getParentWithClassName( obj:Object, className:String ):Object
		{
			if(!obj) return null;
			var objParent:Object = null;
			while( obj.parent ) 
			{
				if( obj.parent && getQualifiedClassName( obj.parent ) == className ) 
				{
					objParent = obj.parent;
					break;
				}
				obj = obj.parent;
			}
			return objParent;
		}
		
		protected function isMouseOnList(mousePos:Point = null):Boolean {
			if (!mousePos) mousePos = this.localToGlobal( new Point( mouseX, mouseY ) );
			// Check if mouse is out of this list bounds.
			if (listBounds.containsPoint(mousePos) == true) return true;
			return false;
		}
		// -------------------------------- End of Drag and Drop ------------------------------- //
		
		public function getPRItemIndex(prItem:PRItem):int {
			var pRecord:PRItem;
			var aDp:Array = this.dataProvider.toArray();
			for (var i:uint = 0;i<aDp.length;i++) {
				pRecord = aDp[i] as PRItem;
				if (pRecord) {
					if (pRecord.playerXML == prItem.playerXML) return i;
				}
			}
			return -1;
		}
		
		public function getFirstDuplicateIndex(prItem:PRItem):int {
			var pRecord:PRItem;
			var aDp:Array = this.dataProvider.toArray();
			for (var i:uint = 0;i<aDp.length;i++) {
				pRecord = aDp[i] as PRItem;
				if (pRecord) {
					if (pRecord.playerId == prItem.playerId) return i;
				}
			}
			return -1;
		}
		
		public function removePlayerRecord(prIdx:String):void {
			var item:Object = getItemFromPlayerId(prIdx);
			if (!item) return;
			this.removeItem(item);
		}
		
		/**
		 * Reset the 'recordEnabled' and 'recordUsed' state of each player record in the source list to TRUE. 
		 */		
		public function resetPlayerRecords():void {
			var item:PRItem;
			for each(var obj:Object in this.dataProvider.toArray()) {
				item = obj as PRItem;
				if (item) {
					item.recordEnabled = true;
					item.recordUsed = false;
				}
			}
			this.invalidateList();
		}
		
		public function togglePlayerRecord(strPId:String, prEnabled:Boolean):void {
			var itemIdx:int = getItemIndexFromPlayerId(strPId);
			if (itemIdx < 0) return;
			this.selectedIndex = itemIdx;
			PRItem(this.selectedItem).recordEnabled = prEnabled;
			//this.dataProvider
			//this.dataProvider.toArray()[itemIdx].recordEnabled = false;
			this.selectedItem = null;
		}
		
		private function getItemIndexFromPlayerId(strPId:String):int {
			var aDP:Array = this.dataProvider.toArray();
			for (var i:uint = 0;i<aDP.length;i++) {
				if (aDP[i]["playerId"] == strPId) {
					return i
				}
			}
			return -1;
		}
		
		private function getItemFromPlayerId(strPId:String):Object {
			for each(var obj:Object in this.dataProvider.toArray()) {
				if (obj["playerId"] == strPId) {
				return obj;
				}
			}
			return null;
		}
		
		public function getPlayerRecordItemFromId(strPId:String):PRItem {
			var item:PRItem;
			for each(var obj:Object in this.dataProvider.toArray()) {
				item = obj as PRItem;
				if (item) {
					if (item.playerId == strPId) {
						return item;
					}
				}
			}
			return null;
		}
		
		public function updateSortOrder():void {
			var aDP:Array = this.dataProvider.toArray();
			var prI:PRItem;
			for (var i:uint = 0;i<aDP.length;i++) {
				prI = aDP[i];
				prI.playerSortOrder = i.toString();
			}
		}
		
		public function setDataProviderFromXMLList(xmlList:XMLList, usePR:Boolean):DataProvider {
			if (!xmlList) return this.dataProvider;
			xmlList = MiscUtils.sortXMLList(xmlList, "_sortOrder");
			this.dataProvider = getDataProviderFromXMLList(xmlList, usePR);
			updateSortOrder();
			notifyListChange();
			return this.dataProvider;
		}
		
		public function getDataProviderFromXMLList(xmlList:XMLList, usePR:Boolean):DataProvider {
			var newDP:DataProvider = new DataProvider();
			var item:PRItem;
			var teamXML:XMLList = MiscUtils.sortXMLList(xmlList, "_sortOrder"); // Sorted by _sortOrder.
			
			for each(var xml:XML in teamXML) {
				item = new PRItem();
				/*item.playerId = (usePR)? xml._prPlayerId.text() : xml._nonprPlayerId.text();
				item.playerName = xml._givenName.text();
				item.playerFamName = xml._familyName.text();
				item.playerNumber = xml._playerNumber.text();
				item.playerPositionId = uint( xml._playerPositionId.text() );
				item.playerPoseId = uint( xml._poseId.text() );
				item.playerSortOrder = uint( xml._sortOrder.text() );
				item.playerSquadId = (usePR)? uint( xml._squadId.text() ) : 0;
				item.playerTeamSide = (usePR)? "" : xml._teamSide.text();*/
				item.playerXML = xml;
				newDP.addItem(item);
			}
			
			return newDP;
		}
	}
}