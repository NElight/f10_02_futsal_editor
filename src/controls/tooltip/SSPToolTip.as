package src.controls.tooltip
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.FlepStudio.ToolTip;
	
	import src3d.utils.EventHandler;
	import src3d.utils.MiscUtils;

	public class SSPToolTip
	{
		private static var _self:SSPToolTip;
		private static var _allowInstance:Boolean = false;
		
		private var _stage:Stage;
		private var toolTip:ToolTip;
		private var bgColor:uint = 0xFFCC00;
		private var txtColor:uint = 0x000000;
		private var txtSize:uint = 12;
		private var txtFont:String = "_sans";
		private var currentTarget:DisplayObject;
		
		private var vSettings:Vector.<SSPToolTipSettings> = new Vector.<SSPToolTipSettings>();
		
		public function SSPToolTip()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():SSPToolTip
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new SSPToolTip();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		public function initToolTips(stage:Stage):void {
			_stage = stage;
		}
		
		public function addToolTip(s:SSPToolTipSettings):void {
			if (s && s.target && s.text && s.text != "" && vSettings.indexOf(s) == -1) {
				vSettings.push(s);
				s.target.addEventListener(MouseEvent.MOUSE_OVER, onShowToolTip, false, 0, true);
			}
		}
		
		public function addToolTips(newSettings:Vector.<SSPToolTipSettings>):void {
			if (!newSettings) return;
			for each (var s:SSPToolTipSettings in newSettings) {
				addToolTip(s);
			}
		}
		
		public function deleteTooltip(s:SSPToolTipSettings, clearSettings:Boolean):void {
			removeToolTip();
			var idx:int = vSettings.indexOf(s);
			if (idx != -1) {
				s.target.removeEventListener(MouseEvent.MOUSE_OVER, onShowToolTip);
				s.target.removeEventListener(MouseEvent.MOUSE_OUT, onRemoveToolTip);
				if (clearSettings) {
					s.target = null;
					s.text = null;
					s = null;
				}
				vSettings.splice(idx, 1);
			}
		}
		
		public function deleteToolTips(newSettings:Vector.<SSPToolTipSettings>, clearSettings:Boolean):void {
			for each (var sD:SSPToolTipSettings in newSettings) {
				deleteTooltip(sD, clearSettings);
			}
		}
		
		private function onShowToolTip(e:MouseEvent):void {
			currentTarget = e.currentTarget as DisplayObject;
			if (!currentTarget) return;
			showToolTip(getTextFromObject(currentTarget));
			currentTarget.addEventListener(MouseEvent.MOUSE_OUT, onRemoveToolTip, false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onTTStageMouseMove, false, 0, true);
			_stage.addEventListener(Event.MOUSE_LEAVE, onTTStageMouseLeave, false, 0, true);
		}
		private function showToolTip(strText:String):void {
			if (!_stage || strText == "" || strText == "undefined") return;
			
			var proximity:Number = 60;
			var mouseXPos:Number = _stage.mouseX;
			var parentBorderPos:Number = _stage.width; 
			var rightSide:Boolean = (Math.abs(parentBorderPos - mouseXPos) < proximity)? true : false;
			
			toolTip=new ToolTip(bgColor,txtColor,txtSize,txtFont,strText,rightSide);
			if (!toolTip) return;
			
			_stage.addChild(toolTip);
			_stage.setChildIndex(toolTip,_stage.numChildren-1);
		}
		
		private function onTTStageMouseMove(e:MouseEvent):void {
			if (!currentTarget) removeToolTip();
			var p:Point = new Point(_stage.mouseX, _stage.mouseY);
			//if (_stage.getObjectsUnderPoint(p).indexOf(currentTarget) == -1) removeToolTip();
			if (!MiscUtils.objectContainsPoint(currentTarget, p, _stage)) removeToolTip();
		}
		private function onTTStageMouseLeave(e:Event):void {
			removeToolTip();
		}
		private function onRemoveToolTip(e:MouseEvent):void {
			removeToolTip();
		}
		public function removeToolTip():void {
			if (currentTarget) currentTarget.removeEventListener(MouseEvent.MOUSE_OUT, onRemoveToolTip);
			if (_stage) {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTTStageMouseMove);
				_stage.removeEventListener(Event.MOUSE_LEAVE, onTTStageMouseLeave);
			}
			if(toolTip!=null) {
				toolTip.destroy();
				toolTip=null;
			}
			currentTarget = null;
		}
		
		private function getTextFromObject(obj:DisplayObject):String {
			if (!obj || !vSettings) return "";
			var strText:String = "";
			for each (var s:SSPToolTipSettings in vSettings) {
				if (s.target == obj) return s.text;
			}
			return strText;
		}
	}
}