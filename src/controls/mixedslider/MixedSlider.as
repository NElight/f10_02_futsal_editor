package src.controls.mixedslider
{
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.CheckBox;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import src3d.SSPEvent;
	
	public class MixedSlider extends MovieClip
	{
		
		public static const barW:int = 500;
		private var barH:int = 30;
		private var barS:int = 20;
		
		private var _sliderValues:MixedSliderValues;
		
		// Bars.
		private var aBars:Vector.<MixedSliderChunk> = new Vector.<MixedSliderChunk>();
		
		private var barsContainer:MovieClip;
		
		private var barTec:MixedSliderChunk;
		private var barTac:MixedSliderChunk;
		private var barPhy:MixedSliderChunk;
		private var barPsy:MixedSliderChunk;
		private var barSoc:MixedSliderChunk;
		
		private var barTecCol:uint = 0xc7deb0;
		private var barTacCol:uint = 0xf6d9ad;
		private var barPhyCol:uint = 0xf2998b;
		private var barPsyCol:uint = 0xaaaaaa;
		private var barSocCol:uint = 0xddd9f0;
		
		// Text.
		private var strTec:String;
		private var strTac:String;
		private var strPhy:String;
		private var strPsy:String;
		private var strSoc:String;
		
		private var selectedBar:MixedSliderChunk;
		private var currentMouseXPos:uint;
		private var barMargin:uint = 30;
		
		private var txtPercentages:TextField;
		
		// Checkbox.
		private var cbxToggleSlider:CheckBox;
		private var _sliderEnabled:Boolean;
		
		// Mask.
		private var barsMask:Shape;
		
		public function MixedSlider()
		{
			super();
			initBars();
			initText();
			initCheckBox();
			resetSlider();
			addBarListeners();
			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function initBars():void {
			_sliderValues = new MixedSliderValues(barW);
			
			// Text language.
			strTec = "Technical";
			strTac = "Tactical";
			strPhy = "Physical";
			strPsy = "Psychological";
			strSoc = "Social";
			
			// Bars.
			barsContainer = new MovieClip();
			this.addChild(barsContainer);
			var useHandle:Boolean = false;
			barTec = new MixedSliderChunk(barTecCol, strTec, barW, barH, barS, useHandle);
			barTac = new MixedSliderChunk(barTacCol, strTac, barW, barH, barS, useHandle);
			barPhy = new MixedSliderChunk(barPhyCol, strPhy, barW, barH, barS, useHandle);
			barPsy = new MixedSliderChunk(barPsyCol, strPsy, barW, barH, barS, useHandle);
			barSoc = new MixedSliderChunk(barSocCol, strSoc, barW, barH, barS, useHandle);
			aBars = Vector.<MixedSliderChunk>([barTec, barTac, barPhy, barPsy, barSoc]);
			//aBars = Vector.<GraphBarChunk>([barSoc, barPsy, barPhy, barTac, barTec]);
			for (var i:uint;i<aBars.length;i++) {
				barsContainer.addChild(aBars[i]);
			}
			
			// Mask.
			barsMask = new Shape();
			barsMask.graphics.beginFill(0xCCCCCC, 1);
			barsMask.graphics.drawRect(0, 0, barW, barH);
			barsMask.graphics.endFill();
			this.addChild(barsMask);
			barsContainer.mask = barsMask;
		}
		
		private function initText():void {
			txtPercentages = getTextField(barW,20);
			txtPercentages.x = barTec.x;
			txtPercentages.y = barTec.height;
			this.addChild(txtPercentages);
		}
		
		private function initCheckBox():void {
			var cbxMargin:uint = 20;
			cbxToggleSlider = new CheckBox();
			cbxToggleSlider.width = 127;
			cbxToggleSlider.height = 22;
			cbxToggleSlider.enabled = true;
			cbxToggleSlider.label = "Use Slider";
			cbxToggleSlider.labelPlacement = ButtonLabelPlacement.LEFT;
			cbxToggleSlider.selected = true;
			cbxToggleSlider.visible = true;
			cbxToggleSlider.x = barTec.x - cbxMargin - cbxToggleSlider.width;
			cbxToggleSlider.y = (this.height-cbxToggleSlider.height)/2;
			this.addChild(cbxToggleSlider);
			cbxToggleSlider.addEventListener(Event.CHANGE, onCbxChange);
		}
		
		private function getTextField(txtW:Number, txtH:Number):TextField {
			var newTxt:TextField;
			var format:TextFormat		= new TextFormat();
			//format.font				= FONT;
			format.font					= "_sans";
			format.size					= 12;
			format.color				= "0x000000";
			
			newTxt = new TextField();
			newTxt.defaultTextFormat	= format;
			newTxt.type					= TextFieldType.DYNAMIC;
			newTxt.selectable			= false;
			newTxt.text					= "";
			newTxt.border				= false;
			//newTxt.x					= 0;
			//newTxt.y					= barH;
			newTxt.multiline			= false;
			newTxt.wordWrap				= false;
			newTxt.background			= false;
			//newTxt.backgroundColor	= 0xFFFF99;
			newTxt.width				= txtW;
			newTxt.height				= txtH;
			//newTxt.maxChars			= 100;
			newTxt.textColor			= 0;
			
			return newTxt;
		}
		
		
		
		// ----------------------------- Mouse Events ----------------------------- //
		private function onCbxChange(e:Event):void {
			this.sliderEnabled = cbxToggleSlider.selected;
			notifyChanges();
		}
		
		private function addBarListeners():void {
			if (!barTec.hasEventListener(MouseEvent.MOUSE_DOWN) &&
				!barTac.hasEventListener(MouseEvent.MOUSE_DOWN) &&
				!barPhy.hasEventListener(MouseEvent.MOUSE_DOWN) &&
				!barPsy.hasEventListener(MouseEvent.MOUSE_DOWN) &&
				!barSoc.hasEventListener(MouseEvent.MOUSE_DOWN)
			) {
				barTec.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
				barTac.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
				barPhy.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
				barPsy.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
				barSoc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
			}
		}
		
		private function removeBarListeners():void {
			barTec.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			barTac.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			barPhy.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			barPsy.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
			barSoc.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
		}
		
		private function onMouseDownHandler(e:MouseEvent):void {
			// TODO: Change mouse cursor.
			cbxToggleSlider.selected = true; // Select checkbox.
			this.sliderEnabled = true; // Enable sliders.
			var clickedBar:MixedSliderChunk = e.currentTarget as MixedSliderChunk;
			if (!clickedBar) return;
			removeBarListeners();
			currentMouseXPos = stage.mouseX;
			selectedBar = getSelectedBar(clickedBar);
			moveBarTo(stage.mouseX);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler, false, 0, true);
		}
		
		private function onStageMouseMoveHandler(e:MouseEvent):void {
			moveBarTo(stage.mouseX);
			updatePercentages();
		}
		
		private function onStageMouseUpHandler(e:MouseEvent):void {
			// TODO: Restore mouse cursor.
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpHandler);
			updatePercentages();
			addBarListeners();
			notifyChanges();
		}
		
		private function getSelectedBar(clickedBar:MixedSliderChunk):MixedSliderChunk {
			// Select the bar next to the clicked bar.
			var idx:int = aBars.indexOf(clickedBar) + 1;
			if (idx >= aBars.length) idx = aBars.length-1;
			return aBars[idx];
		}
		
		private function moveBarTo(xPos:Number):void {
			var newDistance:Number;
			var nearBar:MixedSliderChunk;
			var nearBarXPos:Number;
			
			var newXPos:Number = this.globalToLocal(new Point(xPos, 0)).x;
			
			if (newXPos > selectedBar.x) {
				// Decrease Bar.
				selectedBar.barWidth -= Math.abs(newXPos - selectedBar.x);
				
				nearBar = getNextBar(selectedBar);
				nearBarXPos = (nearBar)? -nearBar.barWidth : 0;
				
				if (selectedBar.barWidth < Math.abs(nearBarXPos-barMargin)) {
					selectedBar.barWidth = Math.abs(nearBarXPos-barMargin);
				}

			} else {
				// Increase Bar.
				selectedBar.barWidth += Math.abs(newXPos - selectedBar.x);
				
				nearBar = getPrevBar(selectedBar);
				nearBarXPos = (nearBar)? -nearBar.barWidth : selectedBar.barWidth;
				
				if (-selectedBar.barWidth < nearBarXPos+barMargin) {
					selectedBar.barWidth = Math.abs(nearBarXPos+barMargin);
				}
			}
			currentMouseXPos = stage.mouseX;
		}
		
		private function getNextBar(currentBar:MixedSliderChunk):MixedSliderChunk {
			// Select the bar next to the clicked bar.
			var idx:int = aBars.indexOf(currentBar) + 1;
			//if (idx >= aBars.length) idx = aBars.length-1;
			if (idx >= aBars.length) return null;
			return aBars[idx];
		}
		private function getPrevBar(currentBar:MixedSliderChunk):MixedSliderChunk {
			// Select the bar next to the clicked bar.
			var idx:int = aBars.indexOf(currentBar) - 1;
			//if (idx >= aBars.length) idx = aBars.length-1;
			if (idx < 0) return null;
			return aBars[idx];
		}
		// -------------------------- End of Mouse Events ------------------------- //
		
		
		
		private function resetSlider():void {
			barTec.barWidth = barW * 1;
			barTac.barWidth = barW * .8;
			barPhy.barWidth = barW * .6;
			barPsy.barWidth = barW * .4;
			barSoc.barWidth = barW * .2;
			updatePercentages();
		}
		
		private function updateSlider():void {
			if (!_sliderValues.hasCorrectValues) {
				this.sliderEnabled = false;
				return;
			} else {
				this.sliderEnabled = true;
			}
			
			var pMargin:Number = barMargin/barW;
			var fullW:Number = barW-(barMargin*aBars.length);
			
			barSoc.barWidth = fullW * _sliderValues.barSocScaleX + barMargin;
			barPsy.barWidth = fullW * _sliderValues.barPsyScaleX + (barMargin * 2);
			barPhy.barWidth = fullW * _sliderValues.barPhyScaleX + (barMargin * 3);
			barTac.barWidth = fullW * _sliderValues.barTacScaleX + (barMargin * 4);
			//barTec.barWidth = fullW * _sliderValues.barTecScaleX + (barMargin * 5);
			barTec.barWidth = barW;
			
			updatePercentages();
		}
		
		private function updatePercentages():void {
			var fullW:Number = barW-(barMargin*aBars.length);
			var strPercentage:String = "";
			var pTec:Number;
			var pTac:Number;
			var pPhy:Number;
			var pPsy:Number;
			var pSoc:Number;
			
			
			if (_sliderEnabled) {
				// Get values.
				pTec = Math.round( (barTec.barWidth-barMargin-barTac.barWidth)/fullW * 100 );
				pTac = Math.round( (barTac.barWidth-barMargin-barPhy.barWidth)/fullW * 100 );
				pPhy = Math.round( (barPhy.barWidth-barMargin-barPsy.barWidth)/fullW * 100 );
				pPsy = Math.round( (barPsy.barWidth-barMargin-barSoc.barWidth)/fullW * 100 );
				//pSoc = Math.round( ( barSoc.barWidth-barMargin )/fullW * 100 );
				pSoc = 100 - (pTec + pTac + pPhy + pPsy);
				
				if (pTec < 0) pTec = 0;
				if (pTac < 0) pTac = 0;
				if (pPhy < 0) pPhy = 0;
				if (pPsy < 0) pPsy = 0;
				if (pSoc < 0) pSoc = 0;
				if (pTec > 100) pTec = 100;
				if (pTac > 100) pTac = 100;
				if (pPhy > 100) pPhy = 100;
				if (pPsy > 100) pPsy = 100;
				if (pSoc > 100) pSoc = 100;
				
				// Adjust values.
				var totalPerc:Number = pTec + pTac + pPhy + pPsy + pSoc;
				var diff:Number = 100 - totalPerc;
				// Use an array to locate the biggest value of the vars.
				var aPerc:Array = [pTec, pTac, pPhy, pPsy, pSoc];
				var biggestPercIdx:uint = 0;
				for (var i:uint = 0;i<aPerc.length;i++) {
					if (aPerc[i] > aPerc[biggestPercIdx]) biggestPercIdx = i;
				}
				switch (biggestPercIdx) {
					case 0:
						pTec += diff;
						break;
					case 1:
						pTac += diff;
						break;
					case 2:
						pPhy += diff;
						break;
					case 3:
						pPsy += diff;
						break;
					case 4:
						pSoc += diff;
						break;
				}
				
				// Store values.
				_sliderValues.setPercents(
					pTec.toString(),
					pTac.toString(),
					pPhy.toString(),
					pPsy.toString(),
					pSoc.toString()
				);
				
				// Set percentages label.
				strPercentage = 
					strTec+": <b>"+uint(pTec)+"%</b>"+"     "+
					strTac+": <b>"+uint(pTac)+"%</b>"+"     "+
					strPhy+": <b>"+uint(pPhy)+"%</b>"+"     "+
					strPsy+": <b>"+uint(pPsy)+"%</b>"+"     "+
					strSoc+": <b>"+uint(pSoc)+"%</b>";
			} else {
				// Store values.
				_sliderValues.setValuesUnused();
				// Set percentages label.
				strPercentage = "";
			}
			
			txtPercentages.htmlText = strPercentage;
		}
		
		private function notifyChanges():void {
			this.dispatchEvent(new SSPEvent(SSPEvent.CONTROL_CHANGE, _sliderValues.getPercents()));
		}
		
		private function get sliderEnabled():Boolean
		{
			return _sliderEnabled;
		}
		
		private function set sliderEnabled(value:Boolean):void
		{
			_sliderEnabled = cbxToggleSlider.selected = value;
			var b:Number = 1;
			if (_sliderEnabled) {
				barEnabled(true);
			} else {
				resetSlider();
				barEnabled(false);
			}
		}
		
		private function barEnabled(value:Boolean):void {
			for each(var slc:MixedSliderChunk in aBars) {
				slc.barEnabled = value;
			}
		}
		
		public function setSkillMixPercentages(percTec:String, percTac:String, percPhy:String, percPsy:String, percSoc:String):void {
			_sliderValues.setPercents(percTec, percTac, percPhy, percPsy, percSoc);
			updateSlider();	
		}
		
		public function getSkillMixPercentages():Object {
			var perc:Object;
			if (_sliderEnabled) {
				perc = _sliderValues.getPercents();
			} else {
				perc = {
					tec:-1,
					tac:-1,
					phy:-1,	
					psy:-1,	
					soc:-1
				};
			}
			return perc;
		}
		
		public function set skillMixCheckBoxLabel(value:String):void {
			cbxToggleSlider.label = value;
		}
		
		public function setSkillMixChunksLabels(strTec:String, strTac:String, strPhy:String, strPsy:String, strSoc:String) {
			barTec.barTitle = strTec;
			barTac.barTitle = strTac;
			barPhy.barTitle = strPhy;
			barPsy.barTitle = strPsy;
			barSoc.barTitle = strSoc;
		}
	}
}