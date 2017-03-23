package src.controls
{
	import flash.display.MovieClip;
	
	import src.buttons.SSPLabelButton;
	import src.controls.tooltip.SSPToolTip;
	import src.controls.tooltip.SSPToolTipSettings;

	public class SmallTab extends MovieClip
	{
		public var _big:SSPLabelButton;
		public var _small:SSPLabelButton;
		public var _line:MovieClip;
		
		protected var vTooltipSettings:Vector.<SSPToolTipSettings>;
	
		public function SmallTab(xPos:Number, yPos:Number) {
			this.x = xPos;
			this.y = yPos;
			if (_big) {
				if (_line) _line.y = this.height-1;
			} else if (_small) {
				if (_line) _line.y = this.height-1;
			}
		}
		
		public function get tabSelected():Boolean {
			if (!_big) return false;
			return this._big.visible;
		}
		
		public function set tabSelected(value:Boolean):void {
			if (value) {
				if (_big) {
					_big.buttonLocked = false;
					_big.buttonEnabled = true;
					_big.buttonSelected = true;
					_big.buttonLocked = true;
				}
				if (_small) _small.buttonEnabled = false;
				if (_line) _line.visible = true;
			} else {
				if (_big) {
					_big.buttonLocked = false;
					_big.buttonEnabled = false;
					_big.buttonLocked = true;
				}
				if (_small) _small.buttonEnabled = true;
				if (_line) _line.visible = false;
			}
		}
		
		public function get tabWidth():Number {
			if (_big && _big.visible) return _big.width;
			if (_small && _small.visible) return _small.width;
			return 0;
		}
		
		public function get tabXPos():Number {
			if (_big) return _big.x;
			if (_small) return _small.x;
			return 0;
		}
		public function set tabXPos(value:Number):void {
			if (_big) _big.x = value;
			if (_small) _small.x = value;
		}
		
		public function set tabIsEnabled(value:Boolean):void {
			if (_big) {
				_big.buttonLocked = false;
				_big.buttonEnabled = value;
				_big.buttonLocked = true;
			}
			if (_small) _small.buttonEnabled = value;
			if (_line) _line.visible = value;
		}
		
		public function set tabLabel(value:String):void {
			if (_big) _big.label = value;
		}
		
		public function setToolTipText(tooltipText:String):void {
			if (vTooltipSettings || !tooltipText || tooltipText == "") return;
			vTooltipSettings = new Vector.<SSPToolTipSettings>();
			vTooltipSettings.push(new SSPToolTipSettings(this, tooltipText));
			SSPToolTip.getInstance().addToolTips(vTooltipSettings);
		}
	}
}