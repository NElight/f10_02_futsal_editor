package src.popup
{
	import fl.data.DataProvider;
	
	import flash.display.MovieClip;
	
	import src.controls.SSPList;
	import src.team.PlayerIcons;
	import src.team.SSPTeamEvent;

	public class SelectPoseForm extends MovieClip
	{
		public var formContentW:Number = 400;
		public var formContentH:Number = 400;
		private var poseList:SSPList;
		private var _kitId:int = -1;
		private var _kitTypeId:int = -1;
		private var _kitsDataProvider:DataProvider;
		
		public function SelectPoseForm()
		{
			initPoseList();
		}
		
		private function initPoseList():void {
			var pr:SelectPoseCellRenderer = new SelectPoseCellRenderer();
			poseList = new SSPList();
			poseList.width = formContentW;
			poseList.height = formContentH;
			poseList.rowHeight = pr.height;
			poseList.setStyle("cellRenderer", SelectPoseCellRenderer);
			poseList.invalidateList();
			poseList.addEventListener(SSPTeamEvent.PLAYER_POSE_SELECT, onPoseSelect, false, 0, true); // Player Pose Listener.
			this.addChild(poseList);
		}
		
		private function onPoseSelect(e:SSPTeamEvent):void {
			this.dispatchEvent(e);
			closePopup();
		}
		
		public function loadPoseIconsDP(kitId:int, kitTypeId:int):void {
			if (_kitsDataProvider
				&& _kitId == kitId
				&& _kitTypeId == kitTypeId
				) {
				poseList.dataProvider = _kitsDataProvider;
			} else {
				poseList.dataProvider = _kitsDataProvider = PlayerIcons.getInstance().getPlayerIconsDataProvider(kitId, kitTypeId);
			}
		}
		
		private function set selectedPose(poseId:uint):void {
			// TODO: Find pose Id and select it.
			poseList.invalidateList();
		}
		
		private function removeListeners():void {
			
		}
		
		private function closePopup():void {
			removeListeners();
			var popupForm:PopupBox = this.parent.parent as PopupBox;
			if (!popupForm) return;
			popupForm.popupVisible = false;
		}
	}
}