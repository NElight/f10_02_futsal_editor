package src.team.list
{
	import fl.controls.Button;
	import fl.data.DataProvider;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import src.buttons.SSPSimpleButton;
	import src.popup.MessageBox;
	import src.team.PRItem;
	import src.team.PRTeamManager;
	import src.team.SSPTeamEvent;
	import src.team.TeamGlobals;
	import src.team.forms.PRPlayerEditFormPopupBox;
	import src.team.forms.PRTeamSelectFormPopupBox;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;
	
	public class PRCContainerBase extends MovieClip
	{
		// Global Vars.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		// List Vars.
		private var popupSelectTeam:PRTeamSelectFormPopupBox;
		private var prList:PRCListBase;
		private var teamXML:XML;
		private var usePlayerRecords:Boolean;
		protected var teamSide:String;
		
		private var popupEditPlayer:PRPlayerEditFormPopupBox;
		
		private var prContainer:MovieClip; // Drag and Drop container.
		private var playerSettings:PlayerSettings;
		
		// Common controls.
		protected var _lblTeamName:TextField;
		protected var _txtTeamName:TextField;
		protected var _btnRemoveAll:SSPSimpleButton;
		protected var _btnAddPlayer:Button;
		protected var _btnSelectTeam:Button; // Our Team List Only.
		protected var _txtGenerateDummyTeam:TextField;
		protected var _btnGenerateDummyTeam:Button;
		
		// Current values.
		private var currentNameFormatIdx:uint;
		private var currentNumberFormatIdx:uint;
		private var _listExpanded:Boolean;
		
		public function PRCContainerBase()
		{
			super();
		}
		
		public function initList(prList:PRCListBase, teamXML:XML, usePR:Boolean):void {
			if (!prList) return;
			this.prList = prList;
			this.teamXML = teamXML;
			this.usePlayerRecords = usePR;
			
			prList.move(4,90);
			//var prcr:PRCCellRendererCompact = new PRCCellRendererCompact();
			//prList.setSize(prcr.width+prList.verticalScrollBar.width,435);
			//prList.setSize(213,438);
			prList.height = 382;
			prList.listExpanded = false;
			updateDataProviderFromTeamXMLList();
			this.addChild(prList);
			
			prList.addEventListener(SSPTeamEvent.TEAM_LIST_EDIT_ITEM, onTeamListEditItem);
			prList.addEventListener(SSPTeamEvent.TEAM_LIST_REMOVE_ITEM, onTeamListRemoveItem);
			sspEventDispatcher.addEventListener(SSPTeamEvent.TEAM_LIST_DRAG_ITEM, onTeamListDragItem, false, 0, true);
		}
		
		
		
		// ----------------------------------- List Format ----------------------------------- //
		protected function initControls():void {
			
			// Language and Tooltips.
			_lblTeamName.text = sG.interfaceLanguageDataXML.titles._teamName.text();
			
			_btnAddPlayer.label = sG.interfaceLanguageDataXML.buttons._menuBtnAddPlayer.text();
			_btnRemoveAll.setToolTipText(sG.interfaceLanguageDataXML.tags._btnTeamDeletePlayers.text());
			
			// Listeners.
			_txtTeamName.addEventListener(FocusEvent.FOCUS_IN, onTeamNameFocusIn);
			_txtTeamName.addEventListener(FocusEvent.FOCUS_OUT, onTeamNameFocusOut);
			_txtTeamName.addEventListener(Event.CHANGE, onTeamNameChange);
			_btnAddPlayer.addEventListener(MouseEvent.CLICK, onAddPlayer);
			_btnRemoveAll.addEventListener(MouseEvent.CLICK, onRemoveAll);
			setTeamNameEnabled(false);
			
			// Specific controls.
			var strTeamName:String;
			if (teamSide == TeamGlobals.TEAM_OUR) {
				strTeamName = sG.interfaceLanguageDataXML.titles._teamNameOursDefault.text();
				if (String(sG.sessionDataXML.session._teamNameOurs.text()) == "") {
					logger.addText("(A) - _teamNameOurs Missing or Empty value. Using '"+strTeamName+"' as default.", false);
					sG.sessionDataXML.session._teamNameOurs = strTeamName;
				}
				_txtTeamName.text = sG.sessionDataXML.session._teamNameOurs.text();
				_btnSelectTeam.label = sG.interfaceLanguageDataXML.buttons._menuBtnSelectTeam.text();
				sspEventDispatcher.addEventListener(SSPTeamEvent.OUR_TEAM_UPDATE, this.onSelectedTeamUpdate);
			} else {
				strTeamName = sG.interfaceLanguageDataXML.titles._teamNameOppositionDefault.text();
				if (String(sG.sessionDataXML.session._teamNameOpposition.text()) == "") {
					logger.addText("(A) - _teamNameOpposition Missing or Empty value. Using '"+strTeamName+"' as default.", false);
					sG.sessionDataXML.session._teamNameOpposition = strTeamName;
				}
				_txtTeamName.text = sG.sessionDataXML.session._teamNameOpposition.text();
				sspEventDispatcher.addEventListener(SSPTeamEvent.OPP_TEAM_UPDATE, this.onSelectedTeamUpdate);
				if (_btnGenerateDummyTeam) {
					_btnGenerateDummyTeam.label = sG.interfaceLanguageDataXML.buttons._menuBtnDummyTeam.text();
					_btnGenerateDummyTeam.addEventListener(MouseEvent.CLICK, onCreateDummyTeam);
				}
				if (_txtGenerateDummyTeam) {
					_txtGenerateDummyTeam.text = sG.interfaceLanguageDataXML.titles._teamDummyHelp.text();
					_txtGenerateDummyTeam.setTextFormat(new TextFormat(null, null, null, true));
				}
			}
			if (sG.usePlayerRecords && teamSide == TeamGlobals.TEAM_OUR) {
				_btnAddPlayer.visible = false;
				if (_btnSelectTeam) _btnSelectTeam.visible = true;
				if (_btnSelectTeam) _btnSelectTeam.addEventListener(MouseEvent.CLICK, onSelectTeam);
			} else {
				if (_btnSelectTeam) _btnSelectTeam.visible = false;
				_btnAddPlayer.visible = true;
				_btnAddPlayer.addEventListener(MouseEvent.CLICK, onAddPlayer);
			}
			
			// Team - Name Format (full name, initial+name, etc.).
			currentNameFormatIdx = uint(sG.sessionDataXML.session._teamPlayerNameFormat.text());
			
			// Team - Number Format (show number or pose).
			currentNumberFormatIdx = uint(sG.sessionDataXML.session._teamPlayerNumberFormat.text());
			
			// Team - Display Position (show or hide player details).
			this.listExpanded = MiscUtils.stringToBoolean(sG.sessionDataXML.session._teamPlayerPositionDisplay.text());
			
			updateListStatus();
		}
		
		public function get listTotalPlayers():uint {
			return prList.length;
		}
		
		private function saveToXML():void {
			var sXML:XML = sG.sessionDataXML.session[0];
			// Team - Name Format (full name, initial+name, etc.).
			sXML._teamPlayerNameFormat = currentNameFormatIdx.toString();
			
			// Team - Number Format (show number or pose).
			sXML._teamPlayerNumberFormat = currentNumberFormatIdx.toString();
			
			
			sXML._teamPlayerPositionDisplay = MiscUtils.booleanToString(this.listExpanded);
			
			// Team - Display Position (show or hide player details).
			this.listExpanded = MiscUtils.stringToBoolean(sG.sessionDataXML.session._teamPlayerPositionDisplay.text());
		}
		// -------------------------------- End of List Format ------------------------------- //
		
		
		
		// ----------------------------------- Team Name ----------------------------------- //
		private function onTeamNameKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.NUMPAD_ENTER) {
				//setTeamNameEnabled(false);
				if (this.stage) this.stage.focus = this.stage;
			}
		}
		
		private function onTeamNameFocusIn(e:FocusEvent):void {
			setTeamNameEnabled(true);
			if (_txtTeamName.selectedText == "") setTimeout(e.target.setSelection, 50, 0, e.target.text.length);
		}
		
		private function onTeamNameFocusOut(e:FocusEvent):void {
			saveTeamNameToXML();
			setTeamNameEnabled(false);
		}
		
		private function onTeamNameChange(e:Event):void {
			if (teamSide == TeamGlobals.TEAM_OUR) {
				//if (_txtTeamName.text == "") _txtTeamName.text = sG.interfaceLanguageDataXML.titles._teamNameOursDefault.text();
				sG.sessionDataXML.session._teamNameOurs = _txtTeamName.text;
			} else {
				//if (_txtTeamName.text == "") _txtTeamName.text = sG.interfaceLanguageDataXML.titles._teamNameOppositionDefault.text();
				sG.sessionDataXML.session._teamNameOpposition = _txtTeamName.text;
			}
		}
		
		private function setTeamNameEnabled(value:Boolean):void {
			if (value) {
				_txtTeamName.type = TextFieldType.INPUT;
				_txtTeamName.selectable = true;
				_txtTeamName.border = true;
				_txtTeamName.borderColor = 0;
				_txtTeamName.addEventListener(KeyboardEvent.KEY_DOWN, onTeamNameKeyDown, false, 0, true);
			} else {
				_txtTeamName.type = TextFieldType.DYNAMIC;
				_txtTeamName.selectable = false;
				_txtTeamName.border = false;
				_txtTeamName.borderColor = 0xCCCCCC;
				_txtTeamName.removeEventListener(KeyboardEvent.KEY_DOWN, onTeamNameKeyDown);
			}
		}
		
		private function saveTeamNameToXML():void {
			if (teamSide == TeamGlobals.TEAM_OUR) {
				if (_txtTeamName.text == "") _txtTeamName.text = sG.interfaceLanguageDataXML.titles._teamNameOursDefault.text();
				sG.sessionDataXML.session._teamNameOurs = _txtTeamName.text;
			} else {
				if (_txtTeamName.text == "") _txtTeamName.text = sG.interfaceLanguageDataXML.titles._teamNameOppositionDefault.text();
				sG.sessionDataXML.session._teamNameOpposition = _txtTeamName.text;
			}
		}
		// -------------------------------- End of Team Name ------------------------------- //
		
		
		
		private function onSelectTeam(e:MouseEvent):void {
			// Team Popup Form.
			if (!popupSelectTeam) popupSelectTeam = new PRTeamSelectFormPopupBox(this.stage);
			popupSelectTeam.popupVisible = true;
			popupSelectTeam.formContent.updateTargetList(prList.dataProvider);
		}
		
		private function onAddPlayer(e:MouseEvent):void {
			var playerItem:PRItem = new PRItem();
			playerItem.playerXML = (usePlayerRecords)? TeamGlobals.PR_PLAYER_XML.copy() : TeamGlobals.NONPR_PLAYER_XML.copy();
			playerItem.playerTeamSide = teamSide;
			playerItem.playerSortOrder = teamMgr.getMaxSortOrder(teamXML).toString();
			playerItem.playerId = teamMgr.getNewNonPRPlayerId();
			popupPlayerEditForm(playerItem, true);
		}
		
		private function onRemoveAll(e:MouseEvent):void {
			// Ask for user confirmation.
			var strMsg:String = sG.interfaceLanguageDataXML.messages[0]._interfaceAreYouSure.text();
			main.msgBox.displayMsgBox(strMsg, removeAll);
		}
		
		private function removeAll():void {
			// Clear players list.
			teamMgr.removeAllPlayerFromTeamXML(teamSide);
			//sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_REMOVE_ALL, prList.dataProvider.toArray()));
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_REMOVE_ALL, teamSide));
			//prList.removeAll();
			updateDataProviderFromTeamXMLList();
		}
		
		private function onTeamListEditItem(e:SSPTeamEvent):void {
			var playerItem:PRItem = e.eventData as PRItem;
			if (!playerItem) return;
			popupPlayerEditForm(playerItem, false);
		}
		
		private function onTeamListRemoveItem(e:SSPTeamEvent):void {
			// Ask for user confirmation.
			var strMsg:String = sG.interfaceLanguageDataXML.messages[0]._interfaceAreYouSure.text();
			main.msgBox.displayMsgBox(strMsg, teamListRemoveItem, e);
		}
		
		private function teamListRemoveItem(e:SSPTeamEvent):void {
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_REMOVE_ITEM, e.eventData));
			var prItem:PRItem = e.eventData as PRItem;
			if (!prItem) return; // Accept only single items.
			if (!usePlayerRecords && prItem.playerTeamSide != teamSide) return;
			if (usePlayerRecords && !prItem.playerRecord) return;
			prList.removeItem(prItem);
			var pIdx:int = prItem.playerXML.childIndex();
			if (pIdx == -1) return;
			prItem.playerXML._removeFlag = "TRUE"; // Mark xml as removable to locate it and delete it.
			
			var tmpXMLList:XMLList = teamXML.children();
			for (var i:uint;i<tmpXMLList.length();i++) {
				if (tmpXMLList[i]._removeFlag != undefined)	delete tmpXMLList[i];
			}
			updateDataProviderFromTeamXMLList();
			prList.invalidateList();
			
			// If deleted player is goalkeeper, update the new goalkeeper's kit.
			/*if (prItem.playerSortOrder == "0") {
				var newGK:PRItem = prList.getChildAt(0) as prItem;
				if (newGK) sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_PLAYER_KIT_UPDATE, newGK));
			}*/
			
			delete prItem.playerXML._removeFlag; // Remove the flag in the source item to not reuse it.
			prItem = null;
		}
		
		private function popupPlayerEditForm(prItem:PRItem, addMode:Boolean):void {
			if (!prItem) return;
			if (!popupEditPlayer) popupEditPlayer = PRPlayerEditFormPopupBox.getInstance(this.stage);
			if (!popupEditPlayer.popupVisible) {
				popupEditPlayer.popupVisible = true;
				popupEditPlayer.setPlayerData(prItem, prItem.playerTeamSide, addMode);
			}
		}
		
		private function onSelectedTeamUpdate(e:SSPTeamEvent):void {
			// eventData may contain two type of objects: DataProvider (from the 'Select Team' form) and PRItem (from the 'Add a Player' form).
			if (!e.eventData) return;
			var dp:DataProvider = e.eventData as DataProvider;
			
			// If data provider, update teamXML.
			if (dp) {
				updateTeamXMLFromDataProvider(dp);
				updateDataProviderFromTeamXMLList();
				// Depersonalize all but existing ones.
				var objExclude:Object = {excludeList:prList.dataProvider.toArray(), teamSide:this.teamSide};
				sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_REMOVE_ALL, objExclude));
			} else {
				// If not data provider, add new item if 'addMode' or update current item.
				if (!e.eventData.addMode) {
					prList.invalidateList();
					return;
				}
				var prItem:PRItem = e.eventData.prItem as PRItem;
				if (!prItem || !prItem.playerXML || !prItem.playerXML.length() > 0) return;
				teamMgr.addNonPRPlayerToTeamDataXML(prItem.playerXML);
				updateDataProviderFromTeamXMLList();
			}
			
			//prList.invalidateList();
			updateTeamListStyle();
			
			notifyListChange();
		}
		
		private function updateTeamXMLFromDataProvider(dp:DataProvider):void {
			var newTeamXMLList:XMLList = new XMLList();
			var prItem:PRItem;
			var itemCount:uint;
			
			var strPId:String;
			var tmpXML:XML;
			
			for (var i:uint;i<dp.length;i++) {
				prItem = dp.getItemAt(i) as PRItem;
				if (prItem) {
					prItem.playerSortOrder = itemCount.toString();
					prItem.playerLastTeam = "TRUE";
					newTeamXMLList += prItem.playerXML;
					itemCount++;
				}
			}

			teamXML.setChildren(newTeamXMLList); // Replace the team list with new data.
		}
		
		private function updateDataProviderFromTeamXMLList():void {
			prList.setDataProviderFromXMLList(teamXML.children(), usePlayerRecords);
			updateListStatus();
		}
		
		protected function notifyListChange():void {
			//sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.TEAM_LIST_CHANGE)); // Notify team list change to ScreenController.
		}
		
		
		
		// ----------------------------------- Drag and Drop ----------------------------------- //
		private function onTeamListDragItem(e:SSPTeamEvent):void {
			// TODO: In the future, see if it's better to change this for a screenshot that includes data properties. Same in Team Form.
			// -- Taken from Drag2DObject.as -- //
			removeDrag2DListeners();
			// Send the event to deselect the object in the 3d screen.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_BY_CLONING, false)); // This cancels pinning mode if it is running.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.SESSION_SCREEN_SELECT_OBJECT, null));
			// -- //
			
			try {
				var tmpCellRenderer:PRCCellRendererBase = e.eventData as PRCCellRendererBase;
			} catch (error:Error) {
				return;
			}
			if (!tmpCellRenderer || !tmpCellRenderer.data || !tmpCellRenderer.recordEnabled) return;
			if (prContainer && this.contains(prContainer)) removePlayerContainer();
			
			var sourceName:String;
			if (tmpCellRenderer.parent) {
				sourceName = tmpCellRenderer.listData.owner.name;
			} else {
				sourceName = "";
			}
			
			if (sourceName != prList.name) return; // Only the dispatching list can handle the event.
			
			// Get Player Settings to be sent to 3D screen.
			playerSettings = PRItem(tmpCellRenderer.data).getPlayerSettings();
			
			// Select object in source list.
			prList.selectedIndex = prList.dataProvider.getItemIndex(tmpCellRenderer);
			
			// Use a screenshot of the Cell Renderer to drag.
			var cloneBmp:Bitmap = MiscUtils.takeScreenshot(tmpCellRenderer, false);
			prContainer = new MovieClip();
			prContainer.addChild(cloneBmp);
			prContainer.scaleX = tmpCellRenderer.scaleX;
			prContainer.scaleY = tmpCellRenderer.scaleY;
			prContainer.scaleZ = tmpCellRenderer.scaleZ;
			var newPos:Point = tmpCellRenderer.localToGlobal(new Point(tmpCellRenderer.x, tmpCellRenderer.y));
			prContainer.x = newPos.x - tmpCellRenderer.x;
			prContainer.y = newPos.y - tmpCellRenderer.y;
			
			this.stage.addChild(prContainer);
			this.stage.setChildIndex(prContainer, this.stage.numChildren-1);
			prContainer.visible = true;
			
			// Tells target list to accept dragging of prContainer.
			prList.startDragging(tmpCellRenderer, sourceName); // accepts drag and drop from itself (to reorder items).
			prContainer.startDrag();
			
			// Remove this function's event.
			sspEventDispatcher.removeEventListener(SSPTeamEvent.TEAM_LIST_DRAG_ITEM, onTeamListDragItem);
			// Listen when the mouse is over the 3D MovieClip Container.
			if (this.stage && main.sessionView) {
				//this.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 0, true);
				//main.sessionView.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove, false, 0, true);
			}
		}
		
		private function cancelDragDrop():void {
			removeDrag2DListeners();
			sspEventDispatcher.removeEventListener(SSPTeamEvent.TEAM_LIST_DRAG_ITEM, onTeamListDragItem);
		}
		
		private function removeDrag2DListeners():void {
			if (this.stage) {
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			}
		}
		
		private function onStageMouseMove(e:MouseEvent):void{
			if ( MiscUtils.objectContainsPoint(main.sessionView, new Point(this.stage.mouseX, this.stage.mouseY), this.stage) ) {
				resetContainerDrag();
				// Dispatches the event for the 3D scene.
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DRAG_OBJECT2D_OVER3D, playerSettings));
			}
		}
		
		private function onStageMouseUp(e:MouseEvent):void {
			/*resetContainerDrag();
			if (isNaN(this.stage.mouseX) || isNaN(this.stage.mouseY)) return;
			if ( MiscUtils.objectContainsPoint(main.sessionView, new Point(this.stage.mouseX, this.stage.mouseY), this.stage) ) {
				// Dispatches the event for the 3D scene.
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DROP_OBJECT2D_OVER3D, playerSettings));
			}*/
			resetContainerDrag();
		}
		
		private function resetContainerDrag():void {
			removeDrag2DListeners();
			removePlayerContainer();
			prList.updateSortOrder();
			//			initListeners();
			sspEventDispatcher.addEventListener(SSPTeamEvent.TEAM_LIST_DRAG_ITEM, onTeamListDragItem, false, 0, true);
		}
		
		private function removePlayerContainer():void {
			if (prContainer) {
				prContainer.stopDrag();
				if (this.stage.contains(prContainer)) this.stage.removeChild(prContainer);
				prContainer = null;
			}
		}

		public function get listExpanded():Boolean
		{
			return _listExpanded;
		}

		public function set listExpanded(value:Boolean):void
		{
			_listExpanded = value;
			if (prList) prList.listExpanded = _listExpanded;
		}

		// -------------------------------- End of Drag and Drop ------------------------------- //
		
		
		
		// ----------------------------- Dummy Team Creation ----------------------------- //
		private function updateListStatus():void {
			if (this.teamSide != TeamGlobals.TEAM_OPP) return;
			
			//if (teamXML.nonpr_team_player.length() > 0) {
			if (prList.length > 0) {
				prList.visible = true;
				_txtGenerateDummyTeam.visible = false;
				_btnGenerateDummyTeam.visible = false;
			} else {
				prList.visible = false;
				_txtGenerateDummyTeam.visible = true;
				_btnGenerateDummyTeam.visible = true;
			}
		}
		
		private function onCreateDummyTeam(e:MouseEvent):void {
			if (this.teamSide != TeamGlobals.TEAM_OPP) return;
			teamMgr.createDummyTeamOpp();
			//teamXML = teamMgr.teamOppXML;
			updateDataProviderFromTeamXMLList();
		}
		// -------------------------- End of Dummy Team Creation ------------------------- //
		
		public function updateTeamListStyle():void {
			if (prList) prList.invalidateList();
		}
		
		public function invalidateList():void {
			if (prList) prList.invalidateList();
		}
	}
}