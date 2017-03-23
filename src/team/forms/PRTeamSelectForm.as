package src.team.forms
{
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.buttons.SSPLabelButton;
	import src.buttons.SSPSimpleButton;
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;
	import src.popup.MessageBox;
	import src.team.PRItem;
	import src.team.PRTeamManager;
	import src.team.SSPTeamEvent;
	
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;
	
	public class PRTeamSelectForm extends MovieClip
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var teamMgr:PRTeamManager = PRTeamManager.getInstance();
		
		private var prs:PRPopupListSource;
		private var prt:PRPopupListTarget;
		public var prContainer:MovieClip;
		
		private var listW:Number = 357;
		private var listH:Number = 390;
		
		private var _cmbFixture:ComboBox;
		private var _cmbSquadSelector:ComboBox;
		private var _lblSquadSelector:TextField;
		private var _btnOK:MovieClip;
		private var _btnRemoveAll:SSPLabelButton;
		private var _btnAddAll:SSPLabelButton;
		private var _lblTeamThisMatch:TextField;
		
		private var fTF:TextFormat
		
		private var stageHandler:EventHandler;
		
		// Tooltip Settings.
		private var vTooltipSettings:Vector.<SSPToolTipSettings>;
		
		public function PRTeamSelectForm()
		{
			var sL:XML = sG.interfaceLanguageDataXML;
			var boldTF:TextFormat = new TextFormat(null, null, null, true);
			
			_lblSquadSelector = this.lblSquadSelector;
			
			TextField(this.lblDragPlayers).text = sL.titles._titleTeamSelectDragPlayers.text();
			TextField(this.lblFixture).text = sL.titles._titleTeamSelectFixture.text();
			TextField(this.lblFixture).setTextFormat(boldTF);
			_lblSquadSelector.text = sL.titles._titleTeamSelectSquad.text();
			_lblSquadSelector.setTextFormat(boldTF);
			
			this._cmbFixture = this.cmbFixture;
			_cmbFixture.text = sL.titles._teamEditNumber.text();
			this._cmbSquadSelector = this.cmbSquadSelector;
			_cmbSquadSelector.text = sL.titles._teamEditNumber.text();
			_btnRemoveAll = this.btnRemoveAll;
			_btnRemoveAll.label = sL.buttons._removeAll.text();
			_btnRemoveAll.setToolTipText(sL.tags._btnTeamDeletePlayers.text());
			_btnAddAll = this.btnAddAll;
			_btnAddAll.label = sL.buttons._addAll.text();
			_btnAddAll.setToolTipText(sL.tags._btnSelectTeamAddAll.text());
			_lblTeamThisMatch = this.lblTeamThisMatch;
			_lblTeamThisMatch.defaultTextFormat = boldTF;
			
			// Player Records List Source.
			prs = new PRPopupListSource();
			prs.move(60,80);
			prs.setSize(listW, listH);
			prs.useHandCursor = true;
			//_list.columnWidth = 300;
			//_list.rowHeight = 130;
			this.addChild(prs);
			
			// Player Records List Target
			prt = new PRPopupListTarget();
			prt.move(530,80);
			prt.setSize(listW, listH);
			prt.useHandCursor = true;
			this.addChild(prt);
			
			// Player Record draggable cell.
			prContainer = new PRCellRendererPopupList();
			
			// Fixture.
			updateFixtureStyle();
			_cmbFixture.prompt = sL.menu._menuPleaseSelect.text();
			_cmbFixture.dataProvider = teamMgr.getFixtureDataProvider();
			
			// Squad Selector.
			_cmbSquadSelector.prompt = sL.menu._menuPleaseSelect.text();
			_cmbSquadSelector.dataProvider = teamMgr.getSquadSelectorDataProvider();
			
			this._btnOK = this.btnOK;
			this._btnOK.buttonMode = true;
			
			var strFixtureId:String = teamMgr.getFixtureId();
			updateFixtureSelector(strFixtureId);
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			if (!stageHandler) stageHandler = new EventHandler(stage);
			//borderThickness
			initListeners();
		}
		
		private function initListeners():void {
			sspEventDispatcher.addEventListener(SSPTeamEvent.SOURCE_LIST_DRAG_ITEM, onSourceListItemDrag, false, 0, true);
			_btnOK.addEventListener(MouseEvent.CLICK, onOK);
			_cmbFixture.addEventListener(Event.CHANGE, onSettingsChange);
			_cmbSquadSelector.addEventListener(Event.CHANGE, onSettingsChange);
			_btnRemoveAll.addEventListener(MouseEvent.CLICK, onRemoveAll);
			_btnAddAll.addEventListener(MouseEvent.CLICK, onAddAll);
		}
		
		private function updateFixtureStyle():void {
			var col1:uint = 0x0064A0;
			var col2:uint = 0x0082BB;
			var col3:uint = 0x009FD5;
			if (!fTF) {
				fTF = _cmbFixture.textField.textField.defaultTextFormat;
				fTF.font = SSPSettings.DEFAULT_FONT;
				fTF.size = 16;
				fTF.color = 0xFFFFFF;
				fTF.bold = true;
			}
			//_cmbFixture.dropdown.setStyle("cellRenderer", FixtureCellRenderer);
			_cmbFixture.textField.setStyle("textFormat", fTF);
			_cmbFixture.textField.setStyle("defaultTextFormat", fTF);
			_cmbFixture.textField.textField.background = true;
			_cmbFixture.textField.textField.backgroundColor = col3;
			
			//_cmbFixture.dropdown.setStyle("textFormat", fTF);
			//_cmbFixture.dropdown.setStyle("defaultTextFormat", fTF);
			//_cmbFixture.dropdown.setRendererStyle("textFormat", fTF);
			//_cmbFixture.dropdown.setRendererStyle("defaultTextFormat", fTF);
			//var lTF:Object = _cmbFixture.dropdown.getStyle("textFormat");
			_cmbFixture.dropdown.setStyle("cellRenderer", FixtureCellRenderer);
		}
		
		
		
		// ----------------------------------- Drag and Drop ----------------------------------- //
		private function onSourceListItemDrag(e:SSPTeamEvent):void {
			//trace("onSourceListItemDrag()");
			try {
				var tmpCellRenderer:PRCellRendererPopupList = e.eventData as PRCellRendererPopupList;
			} catch (error:Error) {
				return;
			}
			if (!tmpCellRenderer || !tmpCellRenderer.recordEnabled) return;
			if (prContainer && this.contains(prContainer)) removePlayerContainer();
			
			// Select object in source list.
			prs.selectedIndex = prs.dataProvider.getItemIndex(tmpCellRenderer);
			
			// Use a screenshot of the Cell Renderer to drag.
			var cloneBmp:Bitmap = MiscUtils.takeScreenshot(tmpCellRenderer, false);
			prContainer = new MovieClip();
			prContainer.addChild(cloneBmp);
			prContainer.scaleX = tmpCellRenderer.scaleX;
			prContainer.scaleY = tmpCellRenderer.scaleY;
			prContainer.scaleZ = tmpCellRenderer.scaleZ;
			var newPos:Point = tmpCellRenderer.localToGlobal(new Point(tmpCellRenderer.x, tmpCellRenderer.y));
			prContainer.x = newPos.x - tmpCellRenderer.x;
			prContainer.y = newPos.y - tmpCellRenderer.y - this.y;
			
			if (!prContainer) return;
			this.addChild(prContainer);
			
			// Tells target list to accept dragging of prContainer.
			
			var sourceName:String;
			if (tmpCellRenderer.parent) {
				sourceName = tmpCellRenderer.listData.owner.name;
			} else {
				sourceName = "";
			}
			prt.startDragging(tmpCellRenderer, sourceName); // prt accepts drag and drop from source list and from itself (to reorder items).
			//prs.startDragging(prContainer, sourceName); // prs don't accept drag and drop, but shows a 'forbidden' mouse icon when dragging from prt.
			prContainer.startDrag();
			
			// Listen for mouse events.
			sspEventDispatcher.removeEventListener(SSPTeamEvent.SOURCE_LIST_DRAG_ITEM, onSourceListItemDrag);
			stageHandler.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			prt.addEventListener(SSPTeamEvent.TARGET_LIST_MOUSE_UP, onTargetListMouseUp, false, 0, true);
		}
		
		private function onTargetListMouseUp(e:SSPTeamEvent):void {
			prt.removeEventListener(SSPTeamEvent.TARGET_LIST_MOUSE_UP, onTargetListMouseUp);
			if (e.eventData == null || e.eventData < 0) return;
			var strPId:String = e.eventData;
			prs.togglePlayerRecord(strPId, false);
		}
		
		private function onStageMouseUp(e:MouseEvent):void {
			resetContainerDrag();
		}
		
		private function resetContainerDrag():void {
			stageHandler.RemoveEvents();
			removePlayerContainer();
			initListeners();
		}
		
		private function removePlayerContainer():void {
			if (prContainer) {
				prContainer.stopDrag();
				if (this.contains(prContainer)) this.removeChild(prContainer);
				prContainer = null;
			}
			//prContainer = null;
		}
		// -------------------------------- End of Drag and Drop ------------------------------- //
		
		
		
		// ----------------------------------- Add All ----------------------------------- //
		protected function onAddAll(e:MouseEvent):void {
			var sDP:Array = prs.dataProvider.toArray();
			var tDP:Array = prt.dataProvider.toArray();
			for each(var p:PRItem in sDP) {
				if (prt.getFirstDuplicateIndex(p) == -1) tDP.push(p.clone());
			}
			updateTargetList(new DataProvider(tDP));
		}
		// -------------------------------- End of Add All ------------------------------- //
		
		
		// ----------------------------------- Remove All ----------------------------------- //
		protected function onRemoveAll(e:MouseEvent):void {
			// Ask for user confirmation.
			var strMsg:String = sG.interfaceLanguageDataXML.messages._interfaceAreYouSure.text();
			main.msgBox.popupEnabled = true;
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onClearAllOK, false, 0, true);
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onClearAllCancel, false, 0, true);
			main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK_CANCEL);
		}
		
		private function onClearAllOK(e:Event):void {
			removeMsgBox();
			removeAll();
		}
		
		private function onClearAllCancel(e:Event):void {
			removeMsgBox();
		}
		
		private function removeMsgBox():void {
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onClearAllOK);
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onClearAllCancel);
			main.msgBox.popupVisible = false;
		}
		
		protected function removeAll():void {
			updateTargetList(new DataProvider());
		}
		// -------------------------------- End of Remove All ------------------------------- //
		
		
		
		public function updateTargetList(dp:DataProvider):void {
			if (!dp) return;
			prt.dataProvider = dp.clone();
			updateSourceList();
		}
		
		private function updateSourceList():void {
			prs.resetPlayerRecords();
			// Disable the matching items from the target list.
			var tgtItem:PRItem;
			var srcItem:PRItem;
			for each(var obj:Object in prt.dataProvider.toArray()) {
				tgtItem = obj as PRItem;
				if (tgtItem) {
					srcItem = prs.getPlayerRecordItemFromId(tgtItem.playerId);
					if (srcItem) {
						srcItem.recordEnabled = false;
						prs.invalidateItem(srcItem);
					}
				}
			}
			updateTeamName();
		}
		
		private function onOK(e:MouseEvent):void {
			sspEventDispatcher.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.OUR_TEAM_UPDATE, prt.dataProvider));
			closePopup();
		}
		
		private function closePopup():void {
			var popupForm:PRTeamSelectFormPopupBox = this.parent.parent as PRTeamSelectFormPopupBox;
			if (!popupForm) return;
			popupForm.popupVisible = false;
		}
		
		
		
		// ----------------------------- Handlers ----------------------------- //
		private function onSettingsChange(e:Event):void {
			var cName:String = e.target.name;
			var cValue:Object = -1;
			if (!cName || cName == "") return;
			switch(cName) {
				case _cmbFixture.name:
					var strFixtureId:String = e.target.selectedItem.data as String;
					teamMgr.setFixtureId(strFixtureId);
					updateSquadSelector(strFixtureId);
					updateTeamName();
					updateFixtureStyle();
					break;
				case _cmbSquadSelector.name:
					updateSquadList(e.target.selectedItem.data);
					break;
			}
		}
		// -------------------------- End of Handlers ------------------------- //
		
		
		
		// ----------------------------- Fixture and Squads ----------------------------- //
		private function updateFixtureSelector(strFixtureId:String):void {
			var aFixtures:Array = _cmbFixture.dataProvider.toArray();
			var sqId:int = int(strFixtureId);
			if (sqId > 0) {
				for (var i:uint;i<aFixtures.length;i++) {
					if (aFixtures[i].data == sqId) {
						_cmbFixture.selectedIndex = i;
						break;
					}
				}
			}
			updateTeamName();
			updateSquadSelector(strFixtureId);
		}
		
		private function updateSquadSelector(strSquadId:String):void {
			var sqId:int = int(strSquadId);
			//if (sqId == 0) sqId = teamMgr.getFirstCoachSquadId();
			var aSquads:Array = _cmbSquadSelector.dataProvider.toArray();
			if (sqId > 0) {
				for (var i:uint;i<aSquads.length;i++) {
					if (aSquads[i].data == strSquadId) {
						_cmbSquadSelector.selectedIndex = i;
						updateSquadList(strSquadId);
						break;
					}
				}
				_lblSquadSelector.textColor = 0;
				_cmbSquadSelector.enabled = true;
				_cmbSquadSelector.textField.textField.textColor = 0;
				_cmbSquadSelector.drawNow();
			} else {
				_cmbSquadSelector.selectedIndex = -1;
				prs.dataProvider = new DataProvider();
				_cmbSquadSelector.enabled = false;
				_lblSquadSelector.textColor = 0xCCCCCC;
			}
		}
		
		private function updateSquadList(strSquadId:String):void {
			prs.setDataProviderFromXMLList(teamMgr.getTeamSquad(strSquadId).pr_team_player, sG.usePlayerRecords);
			updateSourceList();
		}
		
		private function updateTeamName():void {
			var strThisMatch:String = sG.interfaceLanguageDataXML.titles._titleTeamThisMatch.text() + " " + sG.sessionDataXML.session._teamNameOurs.text();
			/*if (_cmbFixture.selectedItem) {
				_lblTeamThisMatch.text = strThisMatch + " (" + String(_cmbFixture.selectedLabel) + ")";
			} else {
				_lblTeamThisMatch.text = strThisMatch;
			}*/
			_lblTeamThisMatch.text = strThisMatch;
		}
		// -------------------------- End of Fixture and Squads ------------------------- //
	}
}