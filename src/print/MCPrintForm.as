package src.print
{
	import fl.controls.Button;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import src.buttons.SSPLabelButton;
	import src.controls.gallery.Gallery;
	import src.controls.gallery.Thumbnail;
	import src.popup.MessageBox;
	import src.popup.PopupBox;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.ScreenshotItem;
	import src3d.SessionGlobals;
	import src3d.utils.Logger;

	public class MCPrintForm extends MovieClip
	{
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		private var grpPrint:RadioButtonGroup;
		private var rdoPrintAll:RadioButton;
		private var rdoPrintCurrent:RadioButton;
		private var rdoPrintSelect:RadioButton;
		private var galleryArea:MovieClip;
		private var gallery:Gallery;
		private var btnSelAll:Button;
		private var btnSelNone:Button;
		private var btnPrint:SSPLabelButton;
		private var btnCancel:SSPLabelButton;
		
		private var vScreenshots:Vector.<ScreenshotItem>
		
		public function MCPrintForm()
		{
			super();
			rdoPrintAll = this.radioPrintAll;
			rdoPrintCurrent = this.radioPrintCurrent;
			rdoPrintSelect = this.radioPrintSelect;
			galleryArea = this.scrollPaneArea;
			btnSelAll = this.buttonSelectAll;
			btnSelNone = this.buttonSelectNone;
			btnPrint = this.buttonPrint;
			btnCancel = this.buttonCancel;
			grpPrint = new RadioButtonGroup("grpPrint");
			rdoPrintAll.group = grpPrint;
			rdoPrintCurrent.group = grpPrint;
			rdoPrintSelect.group = grpPrint;
			grpPrint.selection = rdoPrintAll;
			
			galleryArea.visible = false;
			gallery = new Gallery(galleryArea.x, galleryArea.y, galleryArea.width, galleryArea.height, 4, 0);
			this.addChild(gallery);
			
			var sL:XML = SessionGlobals.getInstance().interfaceLanguageDataXML;
			rdoPrintAll.label = sL.titles._titlePrintAll.text();
			rdoPrintCurrent.label = sL.titles._titlePrintCurrent.text();
			rdoPrintSelect.label = sL.titles._titlePrintSelected.text();
			btnSelAll.label = sL.buttons._selectAll.text();
			btnSelNone.label = sL.buttons._selectNone.text();
			btnPrint.label = sL.buttons._btnInterfacePrint.text();
			btnCancel.label = sL.buttons._btnInterfaceCancel.text();
			
			rdoPrintAll.tabIndex = 0;
			rdoPrintCurrent.tabIndex = 1;
			rdoPrintSelect.tabIndex = 2;
			gallery.tabIndex = 3;
			btnSelAll.tabIndex = 4;
			btnSelNone.tabIndex = 5;
			btnPrint.tabIndex = 6;
			btnCancel.tabIndex = 7;
			
			rdoPrintAll.useHandCursor = true;
			rdoPrintCurrent.useHandCursor = true;
			rdoPrintSelect.useHandCursor = true;
			btnSelAll.useHandCursor = true;
			btnSelNone.useHandCursor = true;
			btnPrint.useHandCursor = true;
			btnCancel.useHandCursor = true;
			
			// Force drawing buttons to avoid popup box size issues (the default button size is 100x100 until it is rendered).
			btnSelAll.drawNow();
			btnSelNone.drawNow();
		}
		
		public function startPrint():void {
			gallery.galleryEnabled = true;
			var vThumbs:Vector.<Thumbnail> = new Vector.<Thumbnail>();
			var pThumb:PrintThumb;
			var tSize:Rectangle = gallery.getThumbSize();
			vScreenshots = main.sessionView.takeHighResScreenshots(true);
			Logger.getInstance().addText("Preparing Thumbnails.", false);
			if (vScreenshots) {
				for each(var sItem:ScreenshotItem in vScreenshots) {
					pThumb = new PrintThumb(sItem, tSize.width, tSize.height);
					vThumbs.push(pThumb);
				}
			}
			Logger.getInstance().addText("Preparing Thumbnails Done.", false);
			gallery.setData(vThumbs);
			grpPrint.selection = rdoPrintAll;
			updateGroupSelection();
			initListeners();
		}
		
		public function stopPrint():void {
			removeListeners();
			gallery.galleryReset();
			gallery.galleryEnabled = false;
		}
		
		
		
		// ----------------------------- Listeners ----------------------------- //
		private function initListeners():void {
			grpPrint.addEventListener(Event.CHANGE, onGroupChange, false, 0, true);
			btnPrint.addEventListener(MouseEvent.CLICK, onPrintClick, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, onCancelClick, false, 0, true);
			gallery.addEventListener(MouseEvent.CLICK, onGalleryMouseClick, false, 0, true);
			btnSelAll.addEventListener(MouseEvent.CLICK, onSelectAllClick, false, 0, true);
			btnSelNone.addEventListener(MouseEvent.CLICK, onSelectNoneClick, false, 0, true);
		}
		
		private function removeListeners():void {
			grpPrint.removeEventListener(Event.CHANGE, onGroupChange);
			btnPrint.removeEventListener(MouseEvent.CLICK, onPrintClick);
			btnCancel.removeEventListener(MouseEvent.CLICK, onCancelClick);
			gallery.removeEventListener(MouseEvent.CLICK, onGalleryMouseClick);
			btnSelAll.removeEventListener(MouseEvent.CLICK, onSelectAllClick);
			btnSelNone.removeEventListener(MouseEvent.CLICK, onSelectNoneClick);
			sspEventDispatcher.removeEventListener(SSPEvent.PRINT_DONE, onPrintDone);
		}
		
		private function onGroupChange(e:Event):void {
			updateGroupSelection();
		}
		
		private function onGalleryMouseClick(e:MouseEvent):void {
			if (grpPrint.selection != rdoPrintSelect) {
				grpPrint.selection = rdoPrintSelect;
			}
			updatePrintButton();
		}
		
		private function onSelectAllClick(e:MouseEvent):void {
			grpPrint.selection = rdoPrintAll;
			updatePrintButton();
		}
		
		private function onSelectNoneClick(e:MouseEvent):void {
			grpPrint.selection = rdoPrintSelect;
			gallery.gallerySelectNone();
			updatePrintButton();
		}
		
		private function onPrintClick(e:MouseEvent):void {
			if (btnPrint.buttonLocked) return;
			var selectedThumbs:Vector.<ScreenshotItem>;
			if (grpPrint.selection == rdoPrintAll) {
				selectedThumbs = vScreenshots;
			} else {
				selectedThumbs = getSelectedThumbs();
			}
			if (!vScreenshots || vScreenshots.length == 0) {
				closePrint();
				return;
			}
			
			main.msgBox.popupVisible = true;
			main.msgBox.showMsg("- Printing "+selectedThumbs.length+" of "+vScreenshots.length+" screens...", MessageBox.BUTTONS_NONE);
			
			sspEventDispatcher.addEventListener(SSPEvent.PRINT_DONE, onPrintDone, false, 0, true);
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.PRINT_START, selectedThumbs));
		}
		
		private function onPrintDone(e:SSPEvent):void {
			closePrint();
		}
		
		private function onCancelClick(e:MouseEvent):void {
			Logger.getInstance().addText("(U) - User clicked Cancel.", false);
			closePrint();
		}
		// -------------------------- End of Listeners ------------------------- //
		
		
		
		private function closePrint():void {
			closePopup();
			sspEventDispatcher.removeEventListener(SSPEvent.PRINT_DONE, onPrintDone);
			main.msgBox.popupVisible = false;
		}
		
		private function updateGroupSelection():void {
			switch (grpPrint.selection) {
				case rdoPrintAll:
					gallery.gallerySelectAll();
					break;
				case rdoPrintCurrent:
					selectCurrentScreen();
					break;
				case rdoPrintSelect:
					gallery.galleryEnabled = true;
					break;
				default:
					gallery.galleryEnabled = false;
			}
			updatePrintButton();
		}
		
		private function selectCurrentScreen():void {
			gallery.gallerySelectNone();
			var sSelected:Boolean;
			for each(var thumb:PrintThumb in gallery.galleryThumbnails) {
				if (thumb && thumb.screenId == main.sessionView.currentScreenId) {
					sSelected = true;
					thumb.selected = true;
				}
			}
			updatePrintButton();
		}
		
		private function getSelectedThumbs():Vector.<ScreenshotItem> {
			var tmpShots:Vector.<ScreenshotItem> = new Vector.<ScreenshotItem>();
			for each(var thumb:PrintThumb in gallery.galleryThumbnails) {
				if (thumb && thumb.selected) {
					for each (var sItem:ScreenshotItem in vScreenshots) {
						if (sItem.screenId == thumb.screenId) tmpShots.push(sItem); 
					}
				}
			}
			return tmpShots;
		}
		
		private function updatePrintButton():void {
			if (getSelectedThumbs().length > 0) {
				btnPrint.buttonLocked = false;
				btnPrint.alpha = 1;
			} else {
				btnPrint.buttonLocked = true;
				btnPrint.alpha = .5;
			}
		}
		
		private function closePopup():void {
			var popupForm:PopupBox = this.parent.parent as PopupBox;
			if (!popupForm) return;
			popupForm.popupVisible = false;
		}
	}
}