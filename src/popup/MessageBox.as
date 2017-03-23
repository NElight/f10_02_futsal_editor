package src.popup
{
	import fl.controls.Button;
	import fl.controls.ScrollBar;
	import fl.controls.ScrollBarDirection;
	import fl.controls.UIScrollBar;
	import fl.core.InvalidationType;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	import src3d.utils.MiscUtils;
	
	/**
	 * Dynamic message box.
	 * 
	 * Examples of use:
	 *   var mb:MessageBox = new MessageBox(MovieClip(this), new Point(500, 300), true);
	 * 
	 * - Simple OK message:
	 *   mb.showMsg("Loading Completed", MessageBox.BUTTONS_OK);
	 * 
	 * - Progress messages:
	 *   mb.showMsg("Loading Scene", MessageBox.BUTTONS_NONE);
	 *   mb.addMsg("Loading Objects...", MessageBox.BUTTONS_CANCEL);
	 *   mb.addMsg("Loading Completed", MessageBox.BUTTONS_OK);
	 * 
	 * - Change displayed buttons:
	 *   mb.showButtons(MessageBox.BUTTONS_OK_CANCEL);
	 * 
	 * - Add buttons listeners:
	 *   mb.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onCancelHandler);
	 *   mb.addEventListener(MessageBox.MESSAGEBOX_EVENT_RETRY, onCancelHandler);
	 *   mb.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onCancelHandler);
	 * 
	 * @author Hector Rodriguez.
	 */	
	public class MessageBox extends PopupBox
	{
		// Events Dispatched.
		public static const MESSAGEBOX_EVENT_OK:String				= "MESSAGEBOX_EVENT_OK";
		public static const MESSAGEBOX_EVENT_RETRY:String			= "MESSAGEBOX_EVENT_RETRY";
		public static const MESSAGEBOX_EVENT_CANCEL:String			= "MESSAGEBOX_EVENT_CANCEL";
		public static const MESSAGEBOX_EVENT_SAVE:String			= "MESSAGEBOX_EVENT_SAVE";
		public static const MESSAGEBOX_EVENT_SAVE_TO_PC:String		= "MESSAGEBOX_EVENT_SAVE_TO_PC";
		
		// Buttons to be displayed.
		public static const BUTTONS_UNCHANGED:String				= "BUTTONS_UNCHANGED"; // To add new messages while keeping the current buttons.
		public static const BUTTONS_NONE:String						= "BUTTONS_NONE";
		public static const BUTTONS_OK:String						= "BUTTONS_OK";
		public static const BUTTONS_OK_CANCEL:String				= "BUTTONS_OK_CANCEL";
		public static const BUTTONS_RETRY:String					= "BUTTONS_RETRY";
		public static const BUTTONS_RETRY_CANCEL:String				= "BUTTONS_RETRY_CANCEL";
		public static const BUTTONS_CANCEL:String					= "BUTTONS_CANCEL";
		public static const BUTTONS_OK_COPY:String					= "BUTTONS_OK_COPY";
		public static const BUTTONS_RETRY_COPY:String				= "BUTTONS_RETRY_COPY";
		public static const BUTTONS_SAVE:String						= "BUTTONS_SAVE";
		public static const BUTTONS_SAVE_TO_PC:String				= "BUTTONS_SAVE_TO_PC";
		public static const BUTTONS_OK_SAVE_TO_PC:String			= "BUTTONS_OK_SAVE_TO_PC";
		public static const BUTTONS_RETRY_SAVE_TO_PC:String			= "BUTTONS_RETRY_SAVE_TO_PC";
		
		protected var mcContent:MovieClip;
		private var mcMainContent:Sprite;
		private var txtMessage:TextField;
		private var txtVScrollbar:UIScrollBar;
		private var txtBorderColor:uint = 0xCCCCCC;
		private var btnOK:Button;
		private var btnCancel:Button;
		private var btnRetry:Button;
		private var btnCopy:Button;
		private var btnSave:Button;
		private var btnSaveToLocal:Button;
		private var btnMarginTop:int = 10;
		private var btnW:Number = 100;
		private var btnH:Number = 30;
		private var btnSpace:int = 30;
		
		private var useTextField:Boolean;
		private var initialTxtW:Number = 350;
		private var initialTxtH:Number = 150;
		private var _autoSize:Boolean;
		
		private var functionConfirmed:Function;
		private var functionConfirmedParams:Object;
		
		public function MessageBox(st:Stage, useTextField = true)
		{
			this.useTextField = useTextField;
			initContent();
			formTitle = "SSP";
			super(st, mcMainContent, formTitle, false, true, -1, -1, true, true, false, false, false);
			this.name = "MessageBox";
		}
		
		private function initContent():void {
			mcMainContent = new Sprite();
			mcContent = new MovieClip();
			mcMainContent.addChild(mcContent);
			if (useTextField) initTextField();
			initButtons();
		}
		
		private function initTextField():void {
			txtMessage = MiscUtils.createNewTextField(0, 0, initialTxtW, initialTxtH, TextFieldType.DYNAMIC, true, true, false, 12, 0, 0, false);
			this.autoSize = false;
			txtMessage.background = false;
			txtMessage.border = false;
			//txtMessage.borderColor = txtBorderColor;
			mcContent.addChild(txtMessage);
			txtVScrollbar = new UIScrollBar();
			txtVScrollbar.direction = ScrollBarDirection.VERTICAL;
			txtVScrollbar.scrollTarget = txtMessage;
			txtVScrollbar.height = txtMessage.height;
			txtVScrollbar.move(txtMessage.x+txtMessage.width, txtMessage.y);
			txtVScrollbar.drawNow();
			mcContent.addChild(txtVScrollbar);
		}
		
		private function initButtons():void {
			btnOK = createButton(0,0, btnW, btnH);
			btnCancel = createButton(0,0, btnW, btnH);
			btnRetry = createButton(0,0, btnW, btnH);
			btnCopy = createButton(0,0, btnW, btnH);
			btnSave = createButton(0,0, btnW, btnH);
			btnSaveToLocal = createButton(0,0, btnW, btnH);
			setButtonsLabels("", "", "", "", "", "");
			mcMainContent.addChild(btnOK);
			mcMainContent.addChild(btnCancel);
			mcMainContent.addChild(btnRetry);
			mcMainContent.addChild(btnCopy);
			mcMainContent.addChild(btnSave);
			mcMainContent.addChild(btnSaveToLocal);
			btnOK.drawNow();
			btnCancel.drawNow();
			btnRetry.drawNow();
			btnCopy.drawNow();
			btnSave.drawNow();
			btnSaveToLocal.drawNow();
			//resetButtons();
		}
		
		
		
		// ----------------------------- Old Message Box ----------------------------- //
		/**
		 * Displays a message in the message box. 
		 * @param msg String. The message to display.
		 * @param buttons int. What buttons to display. Use the public static consts (BUTTONS_NONE, BUTTONS_OK, BUTTONS_OK_CANCEL, etc.).
		 * @param title String. Optional box title (default "SSP").
		 */		
		public function showMsg(msg:String, buttons:String, title:String = "SSP", useDarkBG:Boolean = true):void {
			if (!_popupEnabled) return;
			showBox();
			this.formTitle = title;
			txtMessage.text = msg;
			txtVScrollbar.visible = (txtMessage.maxScrollV >1);
			txtMessage.scrollV = txtMessage.numLines;
			txtVScrollbar.update();
			showButtons(buttons);
		}
		
		/**
		 * Appends a message to the current message in the Message Box. It als can change buttons. 
		 * @param newMsg String. The new message to be added.
		 * @param useBreak Boolean. Indicate if it uses a line break before the new message.
		 * @param buttons Int. Use MsgBox static consts, eg: MsgBox.BUTTONS_OK_CANCEL.
		 */		
		public function addMsg(newMsg:String, useBreak:Boolean = true, buttons:String = BUTTONS_UNCHANGED):void {
			if (!_popupEnabled) return;
			var msg:String;
			msg = (useBreak)? "\n"+newMsg : newMsg;
			txtMessage.appendText(msg);
			txtVScrollbar.visible = (txtMessage.maxScrollV >1);
			txtMessage.scrollV = txtMessage.numLines;
			txtVScrollbar.update();
			showButtons(buttons);
			showBox();
		}
		// -------------------------- End of Old Message Box ------------------------- //
		
		
		
		// ----------------------------- Auto Message Box ----------------------------- //
		public function displayMsgBox(message:String, functionOnConfirm:Function = null, parameter:Object = null):void {
			var strMsg:String = message;
			functionConfirmed = functionOnConfirm;
			functionConfirmedParams = parameter;
			main.msgBox.popupEnabled = true;
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onMsgBoxOK, false, 0, true);
			main.msgBox.addEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onMsgBoxCancel, false, 0, true);
			if (functionConfirmed) {
				main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK_CANCEL);
			} else {
				main.msgBox.showMsg(strMsg, MessageBox.BUTTONS_OK);
			}
		}
		
		private function onMsgBoxOK(e:Event):void {
			if (functionConfirmed) {
				if (functionConfirmedParams) {
					functionConfirmed(functionConfirmedParams)
				} else {
					functionConfirmed();
				}
			}
			removeMsgBox();
		}
		
		private function onMsgBoxCancel(e:Event):void {
			removeMsgBox();
		}
		
		private function removeMsgBox():void {
			functionConfirmed = null;
			functionConfirmedParams = null;
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_OK, onMsgBoxOK);
			main.msgBox.removeEventListener(MessageBox.MESSAGEBOX_EVENT_CANCEL, onMsgBoxCancel);
			main.msgBox.popupVisible = false;
		}
		// -------------------------- End of Auto Message Box ------------------------- //
		
		
		
		// ----------------------------- Events ----------------------------- //
		protected override function set listenersEnabled(lEnabled:Boolean):void {
			super.listenersEnabled = lEnabled;
			if (lEnabled) {
				if (!btnOK.hasEventListener(MouseEvent.CLICK)) btnOK.addEventListener(MouseEvent.CLICK, onOK, false, 0, true);
				if (!btnRetry.hasEventListener(MouseEvent.CLICK)) btnRetry.addEventListener(MouseEvent.CLICK, onRetry, false, 0, true);
				if (!btnCancel.hasEventListener(MouseEvent.CLICK)) btnCancel.addEventListener(MouseEvent.CLICK, onCancel, false, 0, true);
				if (!btnCopy.hasEventListener(MouseEvent.CLICK)) btnCopy.addEventListener(MouseEvent.CLICK, onCopy, false, 0, true);
				if (!btnSave.hasEventListener(MouseEvent.CLICK)) btnSave.addEventListener(MouseEvent.CLICK, onSave, false, 0, true);
				if (!btnSaveToLocal.hasEventListener(MouseEvent.CLICK)) btnSaveToLocal.addEventListener(MouseEvent.CLICK, onSaveToPC, false, 0, true);
			} else {
				btnOK.removeEventListener(MouseEvent.CLICK, onOK);
				btnRetry.removeEventListener(MouseEvent.CLICK, onRetry);
				btnCancel.removeEventListener(MouseEvent.CLICK, onCancel);
				btnCopy.removeEventListener(MouseEvent.CLICK, onCopy);
				btnSave.removeEventListener(MouseEvent.CLICK, onSave);
				btnSaveToLocal.removeEventListener(MouseEvent.CLICK, onSaveToPC);
			}
		}
		
		private function onOK(e:MouseEvent):void {
			closeBox();
			this.dispatchEvent(new Event(MESSAGEBOX_EVENT_OK));
		}
		private function onRetry(e:MouseEvent):void {
			closeBox();
			this.dispatchEvent(new Event(MESSAGEBOX_EVENT_RETRY));
		}
		private function onCancel(e:MouseEvent):void {
			closeBox();
			this.dispatchEvent(new Event(MESSAGEBOX_EVENT_CANCEL));
		}
		private function onCopy(e:MouseEvent):void {
			//closeBox();
			txtMessage.alwaysShowSelection = true;
			txtMessage.setSelection(0, txtMessage.text.length);
			System.setClipboard(txtMessage.text);
		}
		private function onSave(e:MouseEvent):void {
			closeBox();
			this.dispatchEvent(new Event(MESSAGEBOX_EVENT_SAVE));
		}
		private function onSaveToPC(e:MouseEvent):void {
			closeBox();
			this.dispatchEvent(new Event(MESSAGEBOX_EVENT_SAVE_TO_PC));
		}
		// -------------------------- End of Events ------------------------- //
		
		
		
		// ----------------------------- Buttons ----------------------------- //
		private function createButton(xPos:Number, yPos:Number, w:Number = NaN, h:Number = NaN):Button {
			var btn:Button = new Button();
			//btn.emphasized = false;
			//btn.enabled = true;
			//btn.selected = false;
			//btn.toggle = false;
			//btn.visible = true;
			btn.x = xPos;
			btn.y = yPos;
			if (!isNaN(w)) btn.width = w;
			if (!isNaN(h)) btn.height = h;
			//btn.drawNow();
			return btn;
		}
		
		public function setButtonsLabels(okStr:String, cancelStr:String, retryStr:String, copyStr:String, saveStr:String, saveToLocalStr:String):void {
			if (okStr == "") okStr = "OK";
			if (cancelStr == "") cancelStr = "Cancel";
			if (retryStr == "") retryStr = "Retry";
			if (copyStr == "") copyStr = "Copy to Clipboard";
			if (saveStr == "") saveStr = "Save";
			if (saveToLocalStr == "") saveToLocalStr = "Save to PC";
			btnOK.label = okStr;
			btnCancel.label = cancelStr;
			btnRetry.label = retryStr;
			btnCopy.label = copyStr;
			btnSave.label = saveStr;
			btnSaveToLocal.label = saveToLocalStr;
		}
		
		private function resetButtons():void {
			if (!_popupEnabled) return;
			// Hide all buttons.
			btnOK.visible = false;
			btnCancel.visible = false;
			btnRetry.visible = false;
			btnCopy.visible = false;
			btnSave.visible = false;
			btnSaveToLocal.visible = false;
			var yPos:Number = mcContent.y + mcContent.height + btnMarginTop;
			btnOK.move(0,yPos);
			btnCancel.move(0,yPos);
			btnRetry.move(0,yPos);
			btnCopy.move(0,yPos);
			btnSave.move(0,yPos);
			btnSaveToLocal.move(0,yPos);
		}
		
		private function alignButtons(btn1:Button, btn2:Button = null, btn3:Button = null):void {
			var btnsWidth:Number = btn1.width;
			var containerW:Number = (this.usePadding)? this.boxWidth - this.boxPadding*2 : this.boxWidth;
			var xPos:Number = 0;
			var yPos:Number = mcContent.y + mcContent.height + btnMarginTop;
			
			if (btn2) btnsWidth += btnSpace + btn2.width;
			if (btn3) btnsWidth += btnSpace + btn3.width;
			
			xPos = (containerW - btnsWidth) / 2;
			btn1.move(xPos, yPos);
			xPos += btnSpace + btn1.width;
			if (btn2) {
				btn2.move(xPos, yPos);
				xPos += btnSpace + btn2.width;
			}
			if (btn3) {
				btn3.move(xPos, yPos);
			}
		}
		
		/**
		 * Changes the buttons displayed in the curent Message Box. 
		 * @param buttons String. What buttons to display. Use the public static consts (BUTTONS_NONE, BUTTONS_OK, BUTTONS_OK_CANCEL, etc.).
		 * 
		 */		
		public function showButtons(buttons:String):void {
			if (buttons == BUTTONS_UNCHANGED) return;
			listenersEnabled = true;
			resetButtons();
			switch(buttons) {
				case BUTTONS_NONE:
					break;
				case BUTTONS_OK:
					btnOK.visible = true;
					alignButtons(btnOK);
					break;
				case BUTTONS_OK_CANCEL:
					btnOK.visible = true;
					btnCancel.visible = true;
					alignButtons(btnOK, btnCancel);
					break;
				case BUTTONS_RETRY:
					btnRetry.visible = true;
					alignButtons(btnRetry);
					break;
				case BUTTONS_RETRY_CANCEL:
					btnRetry.visible = true;
					btnCancel.visible = true;
					alignButtons(btnRetry, btnCancel);
					break;
				case BUTTONS_CANCEL:
					btnCancel.visible = true;
					alignButtons(btnCancel);
					break;
				case BUTTONS_OK_COPY:
					btnOK.visible = true;
					btnCopy.visible = true;
					alignButtons(btnOK, btnCopy);
					break;
				case BUTTONS_RETRY_COPY:
					btnRetry.visible = true;
					btnCopy.visible = true;
					alignButtons(btnRetry, btnCopy);
					break;
				case BUTTONS_SAVE:
					btnSave.visible = true;
					alignButtons(btnSave);
					break;
				case BUTTONS_SAVE_TO_PC:
					btnSaveToLocal.visible = true;
					alignButtons(btnSaveToLocal);
					break;
				case BUTTONS_OK_SAVE_TO_PC:
					btnOK.visible = true;
					btnSaveToLocal.visible = true;
					alignButtons(btnOK, btnSaveToLocal);
				case BUTTONS_RETRY_SAVE_TO_PC:
					btnRetry.visible = true;
					btnSaveToLocal.visible = true;
					alignButtons(btnRetry, btnSaveToLocal);
			}
			updateBox();
		}
		// -------------------------- End of Buttons ------------------------- //
		
		
		
		protected override function showBox():void {
			//resetButtons();
			super.showBox();
		}
		
		protected override function closeBox():void {
			//resetButtons();
			super.closeBox();
		}
		
		public function get autoSize():Boolean {
			return _autoSize;
		}
		public function set autoSize(value:Boolean):void {
			_autoSize = value;
			txtMessage.autoSize = (_autoSize)? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
		}
	}
}