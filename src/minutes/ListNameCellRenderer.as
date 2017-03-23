package src.minutes
{
	import fl.controls.listClasses.CellRenderer;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import src3d.utils.ColorUtils;
	
	public class ListNameCellRenderer extends CellRenderer
	{
		protected var numTextField:TextField;
		protected var numTextFieldWidth:int = 22;
		protected var _defaultTF:TextFormat;
		
		protected var startPlayColor:uint = 0x008D00;
		protected var stopPlayColor:uint = 0xCC0000;
		protected var defaultTextColor:uint = 0;
		
		public function ListNameCellRenderer()
		{
			super();
			this.textField.defaultTextFormat = this.defaultTF;
			this.textField.setTextFormat(this.defaultTF);
		}
		
		private function get defaultTF():TextFormat {
			if (!_defaultTF) {
				_defaultTF = this.textField.defaultTextFormat;
				_defaultTF.align = TextFormatAlign.LEFT;
				_defaultTF.font = SSPSettings.DEFAULT_FONT;
				_defaultTF.size = 11;
			}
			return _defaultTF;
		}
		
		override protected function configUI():void {
			super.configUI();
			var numTF:TextFormat;
			numTextField = new TextField();
			numTextField.type = TextFieldType.DYNAMIC;
			numTextField.selectable = false;
			//numTextField.setTextFormat(numTF);
			numTextField.defaultTextFormat = defaultTF;
			numTF = numTextField.defaultTextFormat;
			numTF.align = TextFormatAlign.RIGHT;
			numTextField.defaultTextFormat = numTF;
			addChild(numTextField);
		}
		
		override protected function drawLayout():void {
			super.drawLayout();
			// Fit number label
			var mPItem:MinutesItem = data as MinutesItem;
			if (numTextField && numTextField.text.length > 0) {
				numTextField.visible = true;
				numTextField.width = numTextFieldWidth;
				numTextField.height = textField.height;
				//numTextField.x = textField.x;
				numTextField.x = 1;
				numTextField.y = textField.y;
				textField.width = textField.width - numTextField.width;
				textField.x = numTextField.x + numTextField.width;
			} else {
				numTextField.visible = false;
			}
			var mPItem:MinutesItem = data as MinutesItem;
			if (mPItem) {
				if (mPItem.activityCode == MinutesGlobals.ACTIVITY_START_PLAY) {
					numTextField.textColor = startPlayColor;
					textField.textColor = startPlayColor;
				} else if (mPItem.activityCode == MinutesGlobals.ACTIVITY_STOP_PLAY) {
					numTextField.textColor = stopPlayColor;
					textField.textColor = stopPlayColor;
				} else {
					numTextField.textColor = ColorUtils.getColorContrast(numTextField.backgroundColor);
					textField.textColor = ColorUtils.getColorContrast(textField.backgroundColor);
				}
			}
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			var mPItem:MinutesItem = data as MinutesItem;
			if (mPItem) numTextField.text = mPItem.teamPlayerNumber;
		}
	}
}