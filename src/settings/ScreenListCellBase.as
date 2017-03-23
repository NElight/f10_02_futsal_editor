package src.settings
{
	import fl.controls.ComboBox;
	import fl.controls.Label;
	import fl.events.SliderEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import src.controls.slider.SSPSlider;
	import src.minutes.MinutesGlobals;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	
	public class ScreenListCellBase extends MovieClip
	{
		protected var sG:SessionGlobals = SessionGlobals.getInstance();
		protected var textFieldsMaxChars:uint = 100;
		protected var col1:uint = 0xFFFFFF;
		protected var col2:uint = 0xCCCCCC;
		protected var w:uint = 740;
		protected var h:uint = 60;
		protected var aXPos:Vector.<Number>;
		
		protected var _data:ScreenListData;
		
		protected var _bg:Sprite;
		protected var _lblTitle:Label;
		protected var _lblCategory:Label;
		protected var _lblTimeSpent:Label;
		
		protected var _txtTitle:TextField;
		protected var _cmbCategory:ComboBox;
		protected var _sldTimeSpent:SSPSlider;
		
		protected var strScreenTitle:String;
		protected var strScreenCategory:String;
		protected var strScreenTimeSpent:String; // TODO: time spent language.
		protected var strTimeSpent:String = "0";
		
		protected var _screenCategoryEnabled:Boolean;
		
		protected var useCategory:Boolean; // True for Set-pieces, False for Periods.
		protected var useTimeSpent:Boolean; // True for Periods, False for Set-pieces.
		protected static var defaultCategoryId:String = "0";
		protected static var defaultTimeSpent:uint = 0;
		
		private var defaultSize:uint = 12;
		private var highlightColor:uint = 0xFF0000;
		private var defaultColor:uint = 0;
		private var defaultTF:TextFormat;
		private var highlightTF:TextFormat;
		
		public function ScreenListCellBase()
		{
			super();
			initBg();
			init();
		}
		
		protected function init():void {
			defaultTF = new TextFormat(SSPSettings.DEFAULT_FONT, defaultSize, defaultColor);
			highlightTF = new TextFormat(SSPSettings.DEFAULT_FONT, defaultSize, highlightColor);
			
			if (_txtTitle) {
				_txtTitle.defaultTextFormat = defaultTF;
				_txtTitle.setTextFormat(defaultTF);
			}
			if (_cmbCategory) {
				_cmbCategory.textField.setStyle("defaultTextFormat", defaultTF);
				_cmbCategory.textField.setStyle("textFormat", defaultTF);
			}
			
			/*var tIdx:int = 0;
			_txtTitle.tabIndex = tIdx++;
			if (useCategory && _cmbCategory) _cmbCategory.tabIndex = tIdx++;
			if (useTimeSpent && _sldTimeSpent) _sldTimeSpent.tabIndex = tIdx++;*/
		}
		
		protected function addListeners():void {
			_txtTitle.addEventListener(Event.CHANGE, onChangeHandler, false, 0, true);
			if (useCategory) _cmbCategory.addEventListener(Event.CHANGE, onChangeHandler, false, 0, true);
			if (useTimeSpent) _sldTimeSpent.addEventListener(Event.CHANGE, onChangeHandler, false, 0, true);
			if (useTimeSpent) _sldTimeSpent.addEventListener(SliderEvent.THUMB_DRAG, onSliderDrageHandler, false, 0, true);
		}
		protected function removeListeners():void {
			_txtTitle.removeEventListener(Event.CHANGE, onChangeHandler);
			if (useCategory) _cmbCategory.removeEventListener(Event.CHANGE, onChangeHandler);
			if (useTimeSpent) _sldTimeSpent.removeEventListener(Event.CHANGE, onChangeHandler);
			if (useTimeSpent) _sldTimeSpent.removeEventListener(SliderEvent.CHANGE, onSliderDrageHandler);
		}
		
		
		
		// ----------------------------------- Controls ----------------------------------- //
		private function initBg():void {
			_bg = new Sprite();
			_bg.graphics.beginFill(col1);
			_bg.graphics.drawRect(0,0,w,h);
			_bg.graphics.beginFill(col2);
			_bg.graphics.drawRect(0,h-1,w,1);
			_bg.graphics.endFill();
//			this.addChild(_bg);
		}
		// -------------------------------- End of Controls ------------------------------- //
		
		
		
		// ----------------------------------- Data ----------------------------------- //
		protected function onChangeHandler(e:Event):void {
			updateSSPData();
			this.dispatchEvent(new SSPEvent(SSPEvent.SETTINGS_SCREEN_LIST_CHANGE, e.target));
		}
		
		protected function updateSSPData():void {
			if (useCategory) {
				_cmbCategory.invalidate();
				_cmbCategory.drawNow();
			}
			if (useTimeSpent) {
				_sldTimeSpent.invalidate();
				_sldTimeSpent.drawNow();
			}
			updateTimeSpentStatus();
			var strId:String = _data.screenId;
			var sdXML:XML = sG.sessionDataXML.session.screen.(_screenId == strId)[0];
			sdXML._screenTitle = _txtTitle.htmlText;
			if (useCategory && _cmbCategory && _cmbCategory.selectedItem) {
				sdXML._screenCategoryId = (useCategory)? _cmbCategory.selectedItem.data.toString() : defaultCategoryId;
			} else {
				sdXML._screenCategoryId = defaultCategoryId;
			}
			sdXML._timeSpent = strTimeSpent;
		}
		
		protected function onSliderDrageHandler(e:SliderEvent):void {
			//updateTimeSpentStatus();
			updateSSPData();
			this.dispatchEvent(new SSPEvent(SSPEvent.SETTINGS_SCREEN_LIST_CHANGE, e.target));
		}
		
		protected function updateTimeSpentStatus():void {
			if (!useTimeSpent) return;
			var sData:ScreenListData = data as ScreenListData;
			if (!sData) return;
			if (!MinutesGlobals.getInstance().useMinutes) strTimeSpent = _sldTimeSpent.value.toFixed().toString();
			var strLabelTitle:String;
			if (sG.sessionTypeIsMatch) {
				strLabelTitle = (sData.screenType == SessionGlobals.SCREEN_TYPE_PERIOD)?
					sG.interfaceLanguageDataXML.titles._filingPeriodDuration.text() :
					sG.interfaceLanguageDataXML.titles._filingSetPieceDuration.text();
			} else {
				strLabelTitle = sG.interfaceLanguageDataXML.titles._filingDrillDuration.text()
			}
			var strDurationUnits:String = sG.interfaceLanguageDataXML.titles._filingDrillDurationUnits.text();
			_lblTimeSpent.text = strLabelTitle +
				SSPSettings.nonMandatoryColonStr+
				"  ("+strTimeSpent+strDurationUnits+")";
			
			// Grey-out Duration slider unless _matchMinutes="Off".
			if (useTimeSpent) _sldTimeSpent.enabled = (MinutesGlobals.getInstance().useMinutes)? false : true;
		}
		
		public function get data():ScreenListData {
			updateData();
			return this._data;
		}
		public function set data(sData:ScreenListData):void {
			_data = sData;
			
			if (!_data) return;
			
			// Title.
			updateTitleData();
			
			// Category.
			updateCategoryData();
			
			// Time Spent.
			updateTimeSpentData();
		}
			
		protected function updateData():void {
			if (_data) {
				_data.screenTitle = _txtTitle.text;
				_data.screenCategoryIdx = (useCategory)? _cmbCategory.selectedIndex : -1;
				_data.screenTimeSpent = (useTimeSpent)? _sldTimeSpent.value : defaultTimeSpent;
			}
		}
		
		protected function updateTitleData():void {
			var strLabelTitle:String;
			if (sG.sessionTypeIsMatch) {
				strLabelTitle = (_data.screenType == SessionGlobals.SCREEN_TYPE_PERIOD)?
					sG.interfaceLanguageDataXML.titles._filingPeriodTitles.text() :
					sG.interfaceLanguageDataXML.titles._filingSetpieceTitles.text();
			} else {
				strLabelTitle = sG.interfaceLanguageDataXML.titles._filingScreenTitles.text()
			}
			_lblTitle.text = strLabelTitle+" "+_data.screenListNum+SSPSettings.nonMandatoryColonStr;
			_txtTitle.htmlText = _data.screenTitle;
			_txtTitle.setTextFormat(defaultTF);
		}
		
		protected function updateCategoryData():void {
			if (!useCategory) return;
			var strLabelTitle:String;
			if (sG.sessionTypeIsMatch) {
				strLabelTitle = (_data.screenType == SessionGlobals.SCREEN_TYPE_PERIOD)?
					sG.interfaceLanguageDataXML.titles._titleSPeriodCategories.text() :
					sG.interfaceLanguageDataXML.titles._titleSetpieceCategories.text();
			} else {
				strLabelTitle = sG.interfaceLanguageDataXML.titles._titleScreenCategories.text()
			}
			_lblCategory.htmlText = (!sG.sessionTypeIsMatch)? strLabelTitle+SSPSettings.nonMandatoryColonStr : strLabelTitle+SSPSettings.mandatoryColonStr;
			_cmbCategory.dataProvider = _data.screenCategoryDataProvider;
			_cmbCategory.rowCount = 10;
			
			var cmbIdx:int = _data.screenCategoryIdx;
			
			// Category Combo Box (Also used in 'ScreenSettingsContainerBase.as'.
			if (cmbIdx < 0 || cmbIdx > _cmbCategory.dataProvider.length-1) {
				if (!sG.sessionTypeIsMatch) _cmbCategory.prompt = "- - -";
				//_cmbCategory.selectedIndex = 0; // Reset combobox selection to ('Please Select').
				_cmbCategory.selectedIndex = -1; // Reset combobox selection to none.
				//_cmbCategory.invalidate();
				cmbIdx = -1;
			}
			_cmbCategory.selectedIndex = cmbIdx;
			if (!sG.sessionTypeIsMatch) _cmbCategory.enabled = ( cmbIdx == -1)? false : true;
			_cmbCategory.invalidate();
			_cmbCategory.drawNow();
		}
		
		protected function updateTimeSpentData():void {
			if (!useTimeSpent) return;
			strTimeSpent = (_data.screenTimeSpent > _sldTimeSpent.maximum)? _sldTimeSpent.maximum.toString() : _data.screenTimeSpent.toString();
			_sldTimeSpent.value = int(strTimeSpent);
			_sldTimeSpent.invalidate();
			updateTimeSpentStatus();
		}
		
		/*public function get screenTitle():String {
			return _txtTitle.text;
		}
		public function get screenCategoryId():String {
			return (useCategory)? _cmbCategory.selectedItem.data.toString() : defaultCategoryId;
		}
		public function get screenDuration():String {
			return strTimeSpent;
		}*/
		// -------------------------------- End of Data ------------------------------- //
		
		
		
		public function get cmbCategory():ComboBox {
			return _cmbCategory;
		}
		
		public function get screenListCellHeight():Number {
			return _bg.height;
		}
		public function get screenListCellWidth():Number {
			return _bg.width;
		}
		
		public function set highlight(value:Boolean) {
			if (!_cmbCategory) return;
			if (value) {
				_cmbCategory.textField.setStyle("textFormat", highlightTF);
			} else {
				_cmbCategory.textField.setStyle("textFormat", defaultTF);
			}
		}
		
		public function dispose():void {
			removeListeners();
			if (parent) parent.removeChild(this);
		}
	}
}