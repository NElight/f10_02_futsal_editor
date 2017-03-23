package src.popup
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import src3d.ButtonSettings;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.models.soccer.pitches.PitchLibrary;
	import src3d.utils.EventHandler;
	
	public class PopupToolbar extends PopupToolbarBase {
		private var _ref:main;
		public var _controls:MovieClip;
		
		private var arrow_pos:Number 		= 0;
		private var arrow_pos_states:Array 	= [];
		
		private var cam_lock:Number			= 2;
		
		private var item_size:Number		= 0;
		private var pitch_style:Number		= 1;
		
		private var cam_psition:String = "cam_centre";
		private var btnSettingsVector:Vector.<ButtonSettings> = new Vector.<ButtonSettings>; // Selected 3D object's settings.
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var sspEventHandler:EventHandler = new EventHandler(SSPEventDispatcher.getInstance());
		
		public function PopupToolbar(targetArea:DisplayObject, ref:main, initialXPos:Number = -1, initialYPos:Number = -1) {
			super(targetArea, initialXPos, initialYPos);
			this._ref = ref;
			initControls();
			init2DControlsListeners();
			init3DControlsListeners();
			initExternalEventsListeners();
		}
		
		private function initControls():void {
			_controls = this;
			_controls.stop();
			// Make toolbar double size than viewer's.
			this.scaleX = 2;
			this.scaleY = 2;
		}
		
		private function init2DControlsListeners():void {
			_controls.ctrl_zoom_in.zibutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_zoom_in.zibutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_zoom_out.zobutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_zoom_out.zobutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_camera_right.ccrbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_camera_right.ccrbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_camera_left.cclbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_camera_left.cclbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_camera_up.ccubutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_camera_up.ccubutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_camera_down.ccdbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_camera_down.ccdbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_pitch_style.psbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_pitch_style.psbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_camera_position.btnPopup.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_camera_position.btnPopup.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_item_size.isbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_item_size.isbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_cam_lock.lock_icon.gotoAndStop(cam_lock);
			_controls.ctrl_cam_lock.cclkbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_cam_lock.cclkbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_mirror.mbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_mirror.mbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_rotate_ccw.crcbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_rotate_ccw.crcbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_rotate_cw.crccbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_rotate_cw.crccbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			_controls.ctrl_delete.cdbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_delete.cdbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
			
			// Custom Line Arrowhead position.
			_controls.ctrl_arrow_pos.visible = false;
			_controls.ctrl_arrow_pos.csrbutton.addEventListener(MouseEvent.MOUSE_OVER,button_hover);
			_controls.ctrl_arrow_pos.csrbutton.addEventListener(MouseEvent.MOUSE_OUT,button_out);
		}
		
		private function init3DControlsListeners():void {
			// 3D CONTROLS
			_controls.ctrl_zoom_in.zibutton.addEventListener(MouseEvent.MOUSE_DOWN,controls_btn_down);
			_controls.ctrl_zoom_out.zobutton.addEventListener(MouseEvent.MOUSE_DOWN,controls_btn_down);
			_controls.ctrl_camera_right.ccrbutton.addEventListener(MouseEvent.MOUSE_DOWN, controls_btn_down);
			_controls.ctrl_camera_left.cclbutton.addEventListener(MouseEvent.MOUSE_DOWN, controls_btn_down);
			_controls.ctrl_camera_up.ccubutton.addEventListener(MouseEvent.MOUSE_DOWN, controls_btn_down);
			_controls.ctrl_camera_down.ccdbutton.addEventListener(MouseEvent.MOUSE_DOWN, controls_btn_down);
			_controls.ctrl_rotate_ccw.crcbutton.addEventListener(MouseEvent.MOUSE_DOWN, controls_btn_down);
			_controls.ctrl_rotate_cw.crccbutton.addEventListener(MouseEvent.MOUSE_DOWN, controls_btn_down);
			
			_controls.ctrl_pitch_style.psbutton.addEventListener(MouseEvent.CLICK,toggle_pitch_style);
			_controls.ctrl_item_size.isbutton.addEventListener(MouseEvent.CLICK,toggle_item_size);
			_controls.ctrl_cam_lock.cclkbutton.addEventListener(MouseEvent.CLICK,toggle_screen_lock);
			_controls.ctrl_mirror.mbutton.addEventListener(MouseEvent.CLICK, controls_btn_click);
			_controls.ctrl_delete.cdbutton.addEventListener(MouseEvent.CLICK, controls_btn_click);
			
			_controls.ctrl_arrow_pos.csrbutton.addEventListener(MouseEvent.CLICK,arrow_chooser);
		}
		
		private function controls_btn_down(event:MouseEvent):void {
			var btnName:String = event.currentTarget.name;
			//trace("controls_btn_down - "+btnName);
			switch(btnName) {
				case "zibutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_ZOOM_IN,true));
					break;
				case "zobutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_ZOOM_OUT,true));
					break;
				case "cclbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_LEFT,true));
					break;
				case "ccrbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_RIGHT,true));
					break;
				case "ccubutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_UP,true));
					break;
				case "ccdbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_CAMERA_DOWN,true));
					break;
				case "cldbutton":
					// 2D Line Draw.
					break;
				case "crccbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_ROTATE,true)); // TODO: Fix simple button instance name.
					break;
				case "crcbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_DOWN_ROTATE,false)); // TODO: Fix simple button instance name.
					break;
				case "cmbutton":
					// Move Button.
					break;
			}
		}
		
		private function controls_btn_click(event:MouseEvent):void {
			var btnName:String = event.currentTarget.name;
			//trace("controls_btn_click - "+btnName);
			switch(btnName) {
				case "pcbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_PLAYER_CUSTOMIZE));
					break;
				case "cdbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_DELETE));
					break;
				case "mbutton":
					sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_FLIP_H));
					break;
			}
		}
		
		public function updateControls(screenId:int):void {
			var strScreenId:String = String(screenId);
			var sS:XMLList = sG.sessionDataXML.session.screen.(_screenId == strScreenId);
			if(sS.length() > 0) {
				item_size	= int(sS._globalObjScale.text());
				pitch_style	= int(sS._pitchFloorId.text());
			}
			_controls.ctrl_pitch_style.ps_icon.gotoAndStop(pitch_style);
			_controls.ctrl_item_size.is_icon.gotoAndStop(item_size+1);
			cam_lock = 2;
			_controls.ctrl_cam_lock.lock_icon.gotoAndStop(cam_lock);
			//_controls.ctrl_camera_position.updateControls();
		}
		
		private function button_hover(event:MouseEvent):void {
			var btn:MovieClip = event.target.parent as MovieClip;
			if (btn.name != "ctrl_item_clone" &&
				btn.name != "ctrl_item_pin") {
				btn.gotoAndStop(2); // If button is not pin or clone, go to mouse over mode.
			}
		}
		
		private function button_out(event:MouseEvent):void {
			var btn:MovieClip = event.target.parent as MovieClip;
			if (btn.name != "ctrl_item_clone" &&
				btn.name != "ctrl_item_pin") {
				btn.gotoAndStop(1);
			}
		}
		
		private function toggle_pitch_style(event:MouseEvent):void {
			pitch_style = (pitch_style + 1 >= PitchLibrary.getInstance().aPF.length)? 1 : pitch_style + 1;
			_controls.ctrl_pitch_style.ps_icon.gotoAndStop(pitch_style);
			// Dispatch event to 3D.
			trace("Pitch Style: " + pitch_style);
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_PITCH_TEXTURE_CHANGE,Number(pitch_style)));
		}
		
		private function choose_arrow_pos(event:MouseEvent):void {
			var arrow_pos_obj = event.target;
			var arrow_pos_array:Array = arrow_pos_obj.name.split("_");
			arrow_pos = arrow_pos_array[arrow_pos_array.length-1];
			arrow_chooser(event);
			//Send arrow_pos
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.LINE_UPDATE_SINGLE_LINE,Number(arrow_pos)));
		}
		
		private function arrow_chooser(event:MouseEvent):void { 
			set_arrow();
		}
		
		private function set_arrow() {
			var x:int;
			var pos:String;
			if(_controls.arrow_select.visible == true) {
				_ref.stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide_arrow_chooser);
				_controls.arrow_select.visible = false;
				for(x = 0; x < 4; x++) {
					pos = "arrowpos_" + x;
					_controls.arrow_select[pos].removeEventListener(MouseEvent.CLICK,choose_arrow_pos);
					if(arrow_pos_states[x] != null) {
						_controls.arrow_select[pos].upState = arrow_pos_states[x];
					}
				}
			} else {
				_ref.stage.addEventListener(MouseEvent.MOUSE_DOWN, hide_arrow_chooser);
				for(x = 0; x < 4; x++) {
					pos = "arrowpos_" + x;
					_controls.arrow_select[pos].addEventListener(MouseEvent.CLICK,choose_arrow_pos);
					if(arrow_pos == x) {
						arrow_pos_states[x] = _controls.arrow_select[pos].upState;
						_controls.arrow_select[pos].upState = _controls.arrow_select[pos].overState;
					} else {
						if(arrow_pos_states[x] != null) {
							_controls.arrow_select[pos].upState = arrow_pos_states[x];
						}
					}
				}
				_controls.arrow_select.visible = true;
			}
		}
		
		private function hide_arrow_chooser(event:MouseEvent):void {
			if(event.target.parent.name != "arrow_select" && event.target.name != "arrow_select") {
				set_arrow();
			}
		}
		
		private function toggle_item_size(event:MouseEvent):void {
			switch(item_size) {
				case 0:
					item_size = 1;
					_controls.ctrl_item_size.is_icon.gotoAndStop(item_size+1);
					break;
				case 1:
					item_size = 2;
					_controls.ctrl_item_size.is_icon.gotoAndStop(item_size+1);
					break;
				case 2:
					item_size = 3;
					_controls.ctrl_item_size.is_icon.gotoAndStop(item_size+1);
					break;
				case 3:
					item_size = 0;
					_controls.ctrl_item_size.is_icon.gotoAndStop(item_size+1);
					break;		
			}
			// Dispatch event to 3D.
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_SCALE_CHANGE,Number(item_size)));
		}
		
		private function toggle_screen_lock(event:MouseEvent):void {
			if(cam_lock == 2) {
				cam_lock = 1;
				_controls.ctrl_cam_lock.lock_icon.gotoAndStop(cam_lock);
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_SCREEN_LOCK,true));
			} else {
				cam_lock = 2;
				_controls.ctrl_cam_lock.lock_icon.gotoAndStop(cam_lock);
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_SCREEN_LOCK,false));
			}
		}
		
		private function showCustomKit(event:MouseEvent):void {
			// Get the settings from the btnSettingsVector var that has been set in button_visible();
			var btnSettings:ButtonSettings = getButtonSettings(ButtonSettings.CTRL_CUSTOM_PLAYER_KIT);
			if (!btnSettings) return;
			if (btnSettings.btnVisible) {
				// btnData contains the current player's custom kit.
				_ref._menu._kits.openCustomKit(btnSettings.btnData);
			} else {
				// Maybe back to action kits?
			}
		}
		
		private function initExternalEventsListeners():void {
			sspEventDispatcher.addEventListener(SSPEvent.CONTROL_VISIBLE, button_visible);
		}
		
		private function button_visible(e:SSPEvent):void {
			// eventData contains a Vector.<ButtonSettings>. Some objects can enable more than one button (eg: color and elevation).
			btnSettingsVector = e.eventData as Vector.<ButtonSettings>;
			for each(var btnSettings:ButtonSettings in btnSettingsVector) {
				//trace("Button "+btnSettings.btnName+" visible: "+btnSettings.btnVisible);
				switch(btnSettings.btnName) {
					case ButtonSettings.CTRL_CUSTOM_ARROWHEAD_POS:
						// From DynamicLine.as - selected().
						if (btnSettings.btnData) arrow_pos = btnSettings.btnData.arrowPos;
						_controls.ctrl_arrow_pos.visible = btnSettings.btnVisible;
						break;
					case ButtonSettings.CTRL_CAMERA_POSITION:
						// From SessionView - selectObject().
						_controls.ctrl_camera_position.buttonEnabled = btnSettings.btnVisible;
						if (btnSettings.btnVisible && btnSettings.btnData) _controls.ctrl_camera_position.updateButton(btnSettings.btnData);
						break;
				}
			}
		}
		
		// Get the specified button settings from the vector.
		private function getButtonSettings(btnName:String):ButtonSettings {
			if (!btnSettingsVector) return null;
			for each(var btnSettings:ButtonSettings in btnSettingsVector) {
				if (btnSettings.btnName == btnName) return btnSettings;
			}
			return null;
		}
		
		override public function set toolbarEnabled(enabled:Boolean):void {
			if (enabled && !_toolbarEnabled) {
				_ref.bringPopupToolbarContainerToFront();
			}
			super.toolbarEnabled = enabled;
		}
		
	}
}