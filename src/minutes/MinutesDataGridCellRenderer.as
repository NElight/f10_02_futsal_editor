package src.minutes
{
	import fl.controls.BaseButton;
	import fl.controls.LabelButton;
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ListData;
	import fl.core.InvalidationType;
	
	import flash.text.TextFormat;
	
	public class MinutesDataGridCellRenderer extends CellRenderer//事件cell视图
	{
		private static var normalStyles:Object = {upSkin:"CellRenderer_upSkin",downSkin:"CellRenderer_downSkin",overSkin:"CellRenderer_overSkin",
			disabledSkin:"CellRenderer_disabledSkin",
			selectedDisabledSkin:"CellRenderer_selectedDisabledSkin",
			selectedUpSkin:"CellRenderer_selectedUpSkin",selectedDownSkin:"CellRenderer_selectedDownSkin",selectedOverSkin:"CellRenderer_selectedOverSkin",
			textFormat:null,
			disabledTextFormat:null,
			embedFonts:null,
			//textPadding:2,
			textColor:0};
		private static var buttonStyles:Object = {upSkin:"SSPButtonBlue_upSkin",downSkin:"SSPButtonBlue_downSkin",overSkin:"SSPButtonBlue_overSkin",
			disabledSkin:"SSPButtonBlue_disabledSkin",selectedDisabledSkin:"SSPButtonBlue_selectedDisabledSkin",selectedUpSkin:"SSPButtonBlue_selectedUpSkin",
			selectedDownSkin:"SSPButtonBlue_selectedDownSkin",selectedOverSkin:"SSPButtonBlue_selectedOverSkin",
			textFormat:null,
			disabledTextFormat:null,
			embedFonts:null,
			//textPadding:2,
			textColor:0xFFFFFF};
		private static var defaultStyles:Object = normalStyles;
		
		private static var _useButtonSkin:Boolean;
		
		public function MinutesDataGridCellRenderer()
		{
			super();
			textField.wordWrap = true; 
			textField.autoSize = "left";
		}

		override protected function drawLayout():void {             
			textField.width = this.width; 
			super.drawLayout();
		}
		
		public static function getStyleDefinition():Object { 
			//return defaultStyles;
			return mergeStyles(defaultStyles, BaseButton.getStyleDefinition());
		}

		public function get useButtonSkin():Boolean
		{
			return _useButtonSkin;
		}

		public function set useButtonSkin(value:Boolean):void
		{
			_useButtonSkin = value;
		}
		
		public override function get data():Object {
			return _data;
		}		
		public override function set data(value:Object):void {
			_useButtonSkin = (value.isButton)? true : false;
			updateSkinStyles();
			super.data = value;
		}
		
		private function updateSkinStyles():void {
			var newStyle:Object;
			//defaultStyles = (value.isButton)? buttonStyles : normalStyles;
			if (_useButtonSkin) {
				//mergeStyles(defaultStyles, buttonStyles);
				newStyle = buttonStyles;
				this.useHandCursor = true;
				this.toggle = false;
			} else {
				//mergeStyles(defaultStyles, normalStyles);
				newStyle = normalStyles;
				this.useHandCursor = false;
				this.toggle = true;
			}
			
			this.setStyle("upSkin", newStyle.upSkin);
			this.setStyle("downSkin", newStyle.downSkin);
			this.setStyle("overSkin", newStyle.overSkin);
			this.setStyle("disabledSkin", newStyle.disabledSkin);
			this.setStyle("selectedDisabledSkin", newStyle.selectedDisabledSkin);
			this.setStyle("selectedUpSkin", newStyle.selectedUpSkin);
			this.setStyle("selectedDownSkin", newStyle.selectedDownSkin);
			this.setStyle("selectedOverSkin", newStyle.selectedOverSkin);
			this.setStyle("textColor",newStyle.textColor);
			
			var tf:TextFormat = this.textField.getTextFormat();
			tf.color = (_useButtonSkin)? 0xFFFFFF : 0;
			//this.textField.defaultTextFormat = tf;
			//this.textField.setTextFormat(tf);
			this.setStyle("defaultTextFormat",tf);
			this.setStyle("textFormat",tf);
		}
	}
}