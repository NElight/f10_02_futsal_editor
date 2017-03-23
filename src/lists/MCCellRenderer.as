package src.lists
{
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.buttons.SSPButtonToggle;
	
	import src3d.SSPEventDispatcher;
	
	public class MCCellRenderer extends SSPButtonToggle implements ICellRenderer
	{
		protected var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		
		// Cell Renderer Vars.
		protected var _data:Object;
		protected var _listData:ListData;
		protected var _mouseState:String;
		public var label:String;
		public var icon:DisplayObject;
		
		public function MCCellRenderer()
		{
			super();
		}
		
		protected override function init(e:Event):void {
			super.init(e);
			this.useHandCursor = true;
			this.buttonEnabled = true;
			this.isToggleButton = false;
		}
		
		protected override function toggleButton():void {
			// Cell Renderers don't use the toggle function.
		}
		
		public override function set buttonSelected(sel:Boolean):void {
			//if (!isToggleButton) return;
			if (!sel) {
				isToggled = false;
				this.gotoAndStop(UP);
			} else {
				isToggled = true;
				this.gotoAndStop(SELECTED);
			}
		}
		
		protected override function onMouseUp(e:MouseEvent):void {
			
		}
		
		protected override function onMouseDown(e:MouseEvent):void {
			
		}
		
		// ----------------------------------- Cell Renderer Interface ----------------------------------- //
		protected function invalidate():void
		{
			// Override in extending classes if needed.
		}
		
		public function setStyle(style:String, value:Object):void {
			invalidate();
		}
		
		public function setSize(width:Number, height:Number):void
		{
			this.width = width;
			this.height = height;
			this.invalidate();
		}
		
		public function get listData():ListData
		{
			return _listData;
		}
		
		public function set listData(value:ListData):void
		{
			_listData = value;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		public function get selected():Boolean
		{
			return this.buttonSelected;
		}
		
		public function set selected(value:Boolean):void
		{
			this.buttonSelected = value;
			this.invalidate();
		}
		
		public function setMouseState(state:String):void
		{
			_mouseState = state;
			this.invalidate();
		}
		// -------------------------------- End of Cell Renderer Interface ------------------------------- //
	}
}