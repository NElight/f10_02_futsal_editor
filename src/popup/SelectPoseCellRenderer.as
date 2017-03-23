package src.popup
{
	import fl.controls.listClasses.ICellRenderer;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import src.lists.MCCellRenderer;
	import src.team.SSPTeamEvent;
	
	import src3d.SessionGlobals;
	import src3d.utils.ImageUtils;
	
	public class SelectPoseCellRenderer extends MCCellRenderer implements ICellRenderer
	{
		protected var _playerId:String = "";
		protected var _txtName:TextField = new TextField();
		protected var _btnPose:MovieClip = new MovieClip();
		protected var _bmpIcon:Bitmap = new Bitmap();
		
		public function SelectPoseCellRenderer()
		{
			super();
			this.name = "PlayerPoseCellRenderer";
			
			_txtName = this.txtName;
			_btnPose = this.btnPose;
			this.buttonMode = true;
			this.useHandCursor = true;
		}
		
		protected override function onClick(e:MouseEvent):void {
			this.dispatchEvent(new SSPTeamEvent(SSPTeamEvent.PLAYER_POSE_SELECT, this.playerId, true));
		}
		
		// ----------------------------------- Cell Renderer ----------------------------------- //
		public override function set data(dt:Object):void {
			super.data = dt;
			playerId = dt.playerPoseId;
			bmpIcon = dt.playerPoseBmp as Bitmap;
			playerPoseName = dt.playerPoseName;
			this.invalidate();
		}
		// -------------------------------- End of Cell Renderer ------------------------------- //
		
		
		
		// ----------------------------------- Getters and Setters ----------------------------------- //
		public function set playerId(strPId:String):void {_playerId = strPId;}
		public function get playerId():String {return _playerId;}
		public function set playerPoseName(value:String):void {_txtName.text = value;}
		public function get playerPoseName():String {return _txtName.text;}
		public function set bmpIcon(bmpSource:Bitmap):void {
			if (_bmpIcon && _btnPose.contains(_bmpIcon)) _btnPose.removeChild(_bmpIcon);
			_bmpIcon = ImageUtils.fitImageForContainer(bmpSource, _btnPose, true, 2);
			if (_bmpIcon) _btnPose.addChild(_bmpIcon);
		}
		public function get bmpIcon():Bitmap {return _bmpIcon;}
		// -------------------------------- End of Getters and Setters ----------------------------------- //
	}
}