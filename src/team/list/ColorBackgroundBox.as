package src.team.list
{
	import flash.display.MovieClip;
	
	public class ColorBackgroundBox extends MovieClip
	{
		private var _boxW:uint = 26;
		private var _boxH:uint = 26;
		private var _boxDefaultBgColor:uint = 0xF6F6F6;
		private var _boxDefaultLineColor:uint = 0xAAAAAA;
		private var _boxDefaultLineThickness:uint = 1;
		private var _boxBgColor:uint = _boxDefaultBgColor;
		private var _boxLineColor:uint = _boxDefaultLineColor;
		
		public function ColorBackgroundBox()
		{
			super();
			/*for (var i:uint=0; i<this.numChildren; i++){
				this.removeChild(this.getChildAt(i));
			}*/
			boxSetColor(_boxDefaultBgColor, _boxDefaultLineColor);
		}
		
		public function boxSetColor(newBgColor:uint, newLineColor:Number):void {
			_boxBgColor = newBgColor;
			_boxLineColor = newLineColor;
			this.graphics.clear();
			this.graphics.lineStyle(_boxDefaultLineThickness, _boxLineColor);
			this.graphics.beginFill(_boxBgColor);
			this.graphics.drawRect(0,0,_boxW,_boxH);
			this.graphics.endFill();
		}
		
		public function boxSetBgColor(newBgColor:uint):void {
			boxSetColor(newBgColor, _boxLineColor);
		}
		
		public function boxSetLineColor(newLineColor:uint):void {
			boxSetColor(_boxBgColor, newLineColor);
		}
		
		public function boxReset():void {
			boxSetColor(_boxDefaultBgColor, _boxDefaultLineColor);
		}
		
		public function boxResetLineColor():void {
			boxSetLineColor(_boxDefaultLineColor);
		}
		
		public function get boxBgColor():uint { return _boxBgColor; }
		public function get boxLineColor():uint { return _boxLineColor; }
	}
}