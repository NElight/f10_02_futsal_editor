package src3d.lines
{
	import src3d.models.SSPObjectBaseSettings;

	public class LineSettings extends SSPObjectBaseSettings
	{
		public var _pathData:String = "0";
		public var _pathCommands:String = "0";
		public var _lineStyle:int = -1;
		public var _lineType:int = -1;
		public var _lineColor:int = -1;
		public var _lineThickness:int = -1;
		public var _useArrowHead:int = -1;
		public var _arrowThickness:int = -1;
		public var _useHandles:String = "-1";

		public function LineSettings() {}
		
		public function getLineWidth():int {
			var lineWidth:int;
			switch (_lineThickness) {
				case 2:
					lineWidth = 3;
					break;
				case 1:
					lineWidth = 5;
					break;
				case 0:
					lineWidth = 8;
					break;
				default:
					lineWidth = 8;
					break;
			}
			return lineWidth;
		}
		
		public function getArrowSize(arrowThickness:int):Object {
			var arrowSettings:Object = {};
			switch (arrowThickness) {
				case 2:
					arrowSettings.arrowWidth = 30;
					arrowSettings.arrowLength = 25;
					break;
				case 1:
					arrowSettings.arrowWidth = 40;
					arrowSettings.arrowLength = 35;
					break;
				case 0:
					arrowSettings.arrowWidth = 60;
					arrowSettings.arrowLength = 35;
					break;
				default:
					arrowSettings.arrowWidth = 60;
					arrowSettings.arrowLength = 35;
					
					break;
			}
			return arrowSettings;
		}
		
		public override function clone(cloneIn:SSPObjectBaseSettings = null):SSPObjectBaseSettings
		{
			var newObjSettings:LineSettings = (cloneIn)? cloneIn as LineSettings: new LineSettings();
			super.clone(newObjSettings); // Get base settings.
			
			newObjSettings._pathData = this._pathData;
			newObjSettings._pathCommands = this._pathCommands;
			newObjSettings._lineStyle = this._lineStyle;
			newObjSettings._lineType = this._lineType;
			newObjSettings._lineColor = this._lineColor;
			newObjSettings._lineThickness = this._lineThickness;
			newObjSettings._useArrowHead = this._useArrowHead;
			newObjSettings._arrowThickness = this._arrowThickness;
			newObjSettings._useHandles = this._useHandles;
			
			return newObjSettings;
		}
	}
}