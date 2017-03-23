package src.popup
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.utils.MiscUtils;
	
	public class PopupBtnCameraPosition extends PopupBtnBase
	{
		private var mcRotablePitch:MovieClip;
		private var rotablePitchYOffset:Number;
		private var aCamPos:Vector.<SimpleButton>;
		
		public function PopupBtnCameraPosition()
		{
			super();
		}
		
		protected override function init():void {
			super.init();
			this.popupBtnAlwaysVisible = true;
			popupMc = this.mcPopup;
			popupMc.visible = false;
			popupBtn = this.btnPopup.btnButton;
			mcRotablePitch = popupMc.mcCamPosPitch;
			buttonEnabled = true;
			
			rotablePitchYOffset = mcRotablePitch.y + (mcRotablePitch.height/2);
			initCamPosButtons();
			
			//resetBtn.addEventListener(MouseEvent.CLICK, onResetClick, false, 0, true);
			//slider.addEventListener(SliderEvent.CHANGE, onSliderChange, false, 0, true);
		}
		
		protected override function showPopup(e:MouseEvent = null):void {
			super.showPopup(e);
			updateControls()
		}
		
		protected override function onPopupClick(e:MouseEvent):void {
			super.onPopupClick(e);
			
		}
		
		private function initCamPosButtons():void {
			var pos:String;
			var camBtnName:String = "campos_";
			var camBtn:SimpleButton;
			aCamPos = new Vector.<SimpleButton>();
			var totalCamPos:uint = MiscUtils.movieClipsIn(mcRotablePitch,camBtnName,true).length;
			for(var i:int = 0; i < totalCamPos; i++) {
				pos = camBtnName + i;
				camBtn = mcRotablePitch[pos];
				aCamPos.push(camBtn);
				if (!camBtn.hasEventListener(MouseEvent.CLICK)) camBtn.addEventListener(MouseEvent.CLICK,onCamPosClick);
			}
		}
		
		private function resetCamPosition():void {
			for(var i:int = 0; i < aCamPos.length; i++) {
				aCamPos[i].upState = aCamPos[i].hitTestState;
			}
		}
		
		private function onCamPosClick(e:MouseEvent):void {
			var camPosBtn:SimpleButton = e.target as SimpleButton;
			if (!camPosBtn) return;
			resetCamPosition();
			camPosBtn.upState = camPosBtn.overState;
			var aCamPosName:Array = camPosBtn.name.split("_");
			var camPosNumber:Number = aCamPosName[aCamPosName.length-1];
			
			//Send cam_pos
			sspEventHandler.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CLICK_CAMERA_TARGET_CHANGE,Number(camPosNumber)));
		}
		
		
		
		private function updateControls():void {
			if (!main.sessionView) return;
			updateCamPosButtons(main.sessionView.camController.settings._cameraTarget);
			updateCamAngle(main.sessionView.camController.settings._cameraPanAngle);
		}
		
		private function updateCamPosButtons(camPos:Number):void {
			if (isNaN(camPos) || camPos<0) return;
			resetCamPosition();
			aCamPos[camPos].upState = aCamPos[camPos].overState;
		}
		
		private function updateCamAngle(rotationAngle:Number):void {
			if (isNaN(rotationAngle)) return;
			mcRotablePitch.rotation = 180 - rotationAngle;
			// Reposition rotable pitch.
			var newYPos:Number = -((mcRotablePitch.height / 2) - rotablePitchYOffset);
			mcRotablePitch.y = newYPos;
		}
		
		
/*		private function set_camera() {
			if(popupMc.visible == false) {
				main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide_cam_chooser);
//				popupMc.visible = false;
				for(x = 0; x < totalCamPos; x++) {
					pos = camBtnName + x;
					mcRotablePitch[pos].removeEventListener(MouseEvent.CLICK,choose_cam_pos);
					if(cam_pos_states[x] != null) {
						mcRotablePitch[pos].upState = cam_pos_states[x];
					}
				}
			} else {
				main.stage.addEventListener(MouseEvent.MOUSE_DOWN, hide_cam_chooser);
				for(x = 0; x < totalCamPos; x++) {
					pos = camBtnName + x;
					mcRotablePitch[pos].addEventListener(MouseEvent.CLICK,choose_cam_pos);
					if(cam_pos == x) {
						cam_pos_states[x] = mcRotablePitch[pos].upState;
						mcRotablePitch[pos].upState = mcRotablePitch[pos].overState;
					} else {
						if(cam_pos_states[x] != null) {
							mcRotablePitch[pos].upState = cam_pos_states[x];
						}
					}
				}
//				popupMc.visible = true;
			}
		}*/
		
/*		private function hide_cam_chooser(event:MouseEvent):void {
			if(event.target.parent.name != "cam_select" && event.target.name != "cam_select") {
				set_camera();
			}
		}*/
		
	}
}