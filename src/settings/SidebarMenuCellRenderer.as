package src.settings
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import src.lists.MCCellRenderer;
	
	import src3d.utils.ColorUtils;
	import src3d.utils.MiscUtils;
	
	public class SidebarMenuCellRenderer extends MCCellRenderer
	{
		var _txtTitle:TextField;
		public function SidebarMenuCellRenderer()
		{
			super();
			_txtTitle = this.txtScreenTitle;
			var sprArea:Sprite = ColorUtils.createSprite(0,0,this.width,this.height,0xFFFFFF,0,false);
			this.addChild(sprArea);
			this.buttonMode = true;
			this.useHandCursor = true;
		}
		
		
		
		// ----------------------------------- Cell Renderer ----------------------------------- //
		public override function set data(d:Object):void { 
			super.data = d; 
			if (!_data) return;
			_txtTitle.text = _data.label;
		} 
		// -------------------------------- End of Cell Renderer ------------------------------- //
	}
}