package  src.controls.datechooser {
	
	import fl.controls.Button;
	import fl.controls.ComboBox;
	import fl.controls.NumericStepper;
	import fl.controls.SliderDirection;
	import fl.data.DataProvider;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import src.controls.slider.SSPSlider;
	
	public class SSPCalendarControlsBase extends Sprite {
		
		protected var dateCellName:String = "dateCell";
		private var colorBg:uint = 0xFFFFFF;
		private var colorBorder:uint = 0xF7B54A;
		private var colorCell:uint = 0x000000;
		private var colorDayName:uint = 0x000000;
		private var colorDateBg:uint = 0xF7F7F7;
		protected var colorDateBorder:uint = 0xF7B54A;
		private var colorToday:uint = 0xFFF0D0;
		protected var colorSelected:uint = 0x95DDFF;
		protected var colorSelector:uint = 0x2D9DDA;
		protected var colorDateBgLast:uint;
		
		private var bg:Shape;
		
		protected var aDateCells:Vector.<TextField> = new Vector.<TextField>();
        private var dateCellFormat:TextFormat;
		private var txtToday:TextField;
		protected var txtSelected:TextField;
		
        private var dayLabelTxtFmt:TextFormat;
		
		private var firstDayColumn:uint;
		private var aMonthDays:Array;
		private var maxDays:uint;
		
		// Month.
		protected var cbxMonth:ComboBox;
		
		// Year.
		protected var nmsYear:NumericStepper;
		
		// Time.
		protected var lblTime:TextField;
		protected var lblHour:TextField;
		protected var lblMin:TextField;
		protected var txtTime:TextField;
		protected var sldHour:SSPSlider;
		protected var sldMin:SSPSlider;
		
		// Buttons.
		protected var btnNow:Button;
		protected var btnDone:Button;
		
		// Format.
		private var calendarWidth:Number = 230;
		private var calendarHeight:Number = 310;
		private var calendarMargin:uint = 10;
		
		private var dayNameWidth:uint = 30;
		private var dayNameHeight:uint = 25;
		private var cellWidth:uint = 30;
		private var cellHeight:uint = 30;
		private var cellPadding:uint = 3;
		private var datesGridBottom:Number = 0;
		
		private var cols:uint = 7;
		private var rows:uint = 6;
		private var totalCells:uint = 42; // 7 cols * 6 rows.
		
		private var fontSize:int = 15;
		private var yearsRange:int = 39;
		private var monthDayAlpha:Number = 1;
		protected var noMonthDayAlpha:Number = 0.3;
		
		protected var calSettings:SSPCalendarSettings = new SSPCalendarSettings(true);
		
        public function SSPCalendarControlsBase(fontFace:String = "_self") {
			firstDayColumn = calSettings.firstDay.day;
			aMonthDays = calSettings.aMonthDays;
			setTextFormat(fontFace, fontSize);
			initBg();
			initMonthSelector();
			initYearSelector();
			initDaysNames();
			initDatesGrid();
			initTimeSelector();
			initButtons();
			initShadow();
		}
		
		
		
		// ----------------------------- Inits ----------------------------- //
		private function initBg():void {
			bg = new Shape;
			bg.graphics.lineStyle(2, colorBorder);
			bg.graphics.beginFill(colorBg);
			bg.graphics.drawRect(0, 0, calendarWidth, calendarHeight);
			bg.graphics.endFill();
			this.addChild(bg);
		}
        
        private function setTextFormat(whichFont:String, size:int):void	{
			// Day Name Format.
			dayLabelTxtFmt = new TextFormat();
			dayLabelTxtFmt.font = "_sans";
			dayLabelTxtFmt.color = colorDayName;
			dayLabelTxtFmt.size = size - 3;
			// Date Cell Format.
			dateCellFormat = new TextFormat();
			dateCellFormat.font = whichFont;
			dateCellFormat.color = colorCell;
			dateCellFormat.size = size;
			dateCellFormat.align = "center";
		}
		
		private function initMonthSelector():void {
			cbxMonth = new ComboBox();
			cbxMonth.dataProvider = new DataProvider(calSettings.getMonthNames());
			cbxMonth.x = calendarMargin;
			cbxMonth.y = calendarMargin;
			cbxMonth.selectedIndex = calSettings.flashTodaysDate.month;
			addChild(cbxMonth);
		}
		
		private function initYearSelector():void {
			nmsYear = new NumericStepper();
			nmsYear.maximum = calSettings.flashTodaysDate.fullYear + yearsRange;
			nmsYear.minimum = calSettings.flashTodaysDate.fullYear - yearsRange;
			nmsYear.value = calSettings.flashTodaysDate.fullYear;
			nmsYear.x = calendarWidth - nmsYear.width - calendarMargin;
			nmsYear.y = calendarMargin;
			addChild(nmsYear);
		}
		
		private function initDaysNames():void {
			var xPos:Number = calendarMargin;
			var yPos:Number = nmsYear.y + nmsYear.height + calendarMargin;
			for (var i:int = 0; i < cols; i++)	{
				var dayLabel:TextField = new TextField();
				addChild(dayLabel);
				dayLabel.selectable = false;
				dayLabel.text = calSettings.getDayNames()[i];
				dayLabel.name = "lbl"+dayLabel.text;
				dayLabel.setTextFormat(dayLabelTxtFmt);
				dayLabel.width = dayNameWidth;
				dayLabel.height = dayNameHeight;
				dayLabel.x = xPos + (cellWidth * i);
				dayLabel.y = yPos;
				//dayLabel.backgroundColor = 0xFF0000; // Debug.
				//dayLabel.background = true; // Debug.
				
			}
		}
		
		private function initDatesGrid():void {
			var xPos:Number = calendarMargin;
			var yPos:Number = cbxMonth.y + cbxMonth.height + dayNameHeight + calendarMargin;
			totalCells = cols * rows;
			for (var i:int = 0; i < totalCells; i++) {
				var dateCell:TextField = new TextField();
				// Position cells in a grid (7 x 6 = 42).
				dateCell.x = xPos + (cellWidth * (i-(Math.floor(i/cols)*cols)));
				dateCell.y = yPos + (cellHeight * Math.floor(i/cols));
				dateCell.name = dateCellName;
				aDateCells.push(dateCell);
				addChild(dateCell);
			}
			datesGridBottom = yPos + (cellHeight * rows);
		}
		
		private function initTimeSelector():void {
			var txtHeight:uint = 20;
			var lblWidth:uint = 60;
			var ctrlWidth:uint = 150;
			sldMin = new SSPSlider();
			
			// Labels.
			lblTime = getTextField(lblWidth,txtHeight);
			lblTime.x = calendarMargin;
			lblTime.y = datesGridBottom;
			lblTime.text = "Time";
			lblTime.border = false;
			this.addChild(lblTime);
			
			lblHour = getTextField(lblWidth,txtHeight);
			lblHour.x = calendarMargin;
			lblHour.y = lblTime.y + lblTime.height;
			lblHour.text = "Hour";
			lblHour.border = false;
			this.addChild(lblHour);
			
			lblMin = getTextField(lblWidth,txtHeight);
			lblMin.x = calendarMargin;
			lblMin.y = lblHour.y + lblHour.height;
			lblMin.text = "Minute";
			lblMin.border = false;
			this.addChild(lblMin);
			
			// Controls.
			sldHour = getSSPSlider(ctrlWidth - calendarMargin*2);
			sldHour.maximum = 23;
			sldHour.snapInterval = 1;
			sldHour.value = calSettings.flashTodaysDate.hours;
			sldHour.x = lblHour.x + lblHour.width + calendarMargin;
			sldHour.y = lblHour.y + lblHour.height/2;
			this.addChild(sldHour);
			
			sldMin = getSSPSlider(ctrlWidth - calendarMargin*2);
			sldMin.maximum = 55;
			sldMin.snapInterval = 5;
			sldMin.value = calSettings.flashTodaysDate.minutes;
			sldMin.x = lblMin.x + lblMin.width + calendarMargin;
			sldMin.y = lblMin.y + lblMin.height/2;
			this.addChild(sldMin);
			
			txtTime = getTextField(ctrlWidth,txtHeight);
			txtTime.x = lblTime.x+lblTime.width;
			txtTime.y = lblTime.y;
			txtTime.text = calSettings.getTimeForCalendar();
			txtTime.border = false;
			this.addChild(txtTime);
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
		
		private function getSSPSlider(w:Number):SSPSlider {
			var newSlider:SSPSlider = new SSPSlider();
			newSlider.width = w;
			newSlider.direction = SliderDirection.HORIZONTAL;
			newSlider.enabled = true;
			newSlider.liveDragging = true;
			newSlider.minimum = 0;
			newSlider.tickInterval = 0;
			newSlider.visible = true;
			return newSlider;
		}
		
		private function initButtons():void {
			var btnWidth:uint = 80;
			var btnMargin:uint = 20;
			btnNow = new Button();
			btnNow.width = btnWidth;
			btnNow.label = "Now";
			btnNow.x = lblMin.x;
			btnNow.y = lblMin.y + lblMin.height + btnMargin;
			this.addChild(btnNow);
			
			btnDone = new Button();
			btnDone.width = btnWidth;
			btnDone.label =  "Done";
			btnDone.x = bg.width - btnNow.x - btnDone.width;
			btnDone.y = btnNow.y;
			this.addChild(btnDone);
			
			if (bg.height < btnDone.y + btnDone.height) {
				bg.height = btnDone.y + btnDone.height + btnMargin;
			}
		}
		
		private function initShadow():void {
			var dropShadow:DropShadowFilter = new DropShadowFilter();
			dropShadow.distance = 5;
			dropShadow.angle = 45;
			dropShadow.color = 0x000000;
			dropShadow.alpha = 1;
			dropShadow.blurX = 6;
			dropShadow.blurY = 6;
			dropShadow.strength = .5; // Values from 0 to 255.
			dropShadow.quality = BitmapFilterQuality.LOW;
			dropShadow.inner = false;
			dropShadow.knockout = false;
			dropShadow.hideObject = false;
			this.filters = [dropShadow];
		}
		// -------------------------- End of Inits ------------------------- //
		
		
		
		// ----------------------------- Update ----------------------------- //
		protected function updateCalendar():void {
			updateAllControls();
			updateMonth();
			updateCalendarTime();
		}
		
		private function updateAllControls():void {
			nmsYear.value = calSettings.calendarFullYear;
			nmsYear.invalidate();
			cbxMonth.selectedIndex = calSettings.calendarMonth;
			cbxMonth.invalidate();
			sldHour.value = calSettings.calendarHours;
			sldMin.value = calSettings.calendarMinutes;
		}

		protected function updateMonth():void {
			for (var i:int = 0; i < totalCells; i++){
				aDateCells[i].text = "";
				aDateCells[i].name = dateCellName;
				aDateCells[i].background = true;
				aDateCells[i].backgroundColor = colorDateBg;
				aDateCells[i].border = true;
				aDateCells[i].borderColor = colorDateBorder;
				aDateCells[i].selectable = false;
				aDateCells[i].width = aDateCells[i].height = cellWidth - cellPadding;
				aDateCells[i].setTextFormat(dateCellFormat);
			}
			updateDays();
			updatePrevMonthDays();
			updateNextMonthDays();
		}
		
		private function updateDays():void {
			// Update firstDay's month and year.
			calSettings.firstDay.month = calSettings.calendarMonth;
			calSettings.firstDay.fullYear = calSettings.calendarFullYear;
			// Get column number for first day of the month.
			if (calSettings.firstDay.day == 0) {
				// When last date of previous month is on saturday then move to second row.
				firstDayColumn = calSettings.firstDay.day + cols;
			} else {
				firstDayColumn = calSettings.firstDay.day;
			}
			// Get max days for current month w.r.t leap year if any.
			maxDays = (calSettings.firstDay.getFullYear()%4 == 0 && calSettings.firstDay.getMonth() == 1 ? 29 : aMonthDays[calSettings.firstDay.getMonth()]);
			txtToday = null;
			
			// Put dates for current month.
			var dateCell:TextField;
			for (var i:int = 0; i < maxDays; i++) {
				dateCell = aDateCells[firstDayColumn + i];
				dateCell.text = String(i + 1);
				dateCell.setTextFormat(dateCellFormat);
				dateCell.alpha = monthDayAlpha;
				dateCell.border = true;
				
				// Highlight today.
				if (calSettings.firstDay.fullYear == calSettings.flashTodaysDate.fullYear && calSettings.firstDay.month == calSettings.flashTodaysDate.month) {					
					if(dateCell.text == calSettings.flashTodaysDate.date.toString()) {
						dateCell.backgroundColor = colorToday;
						txtToday = dateCell;
					}
				}
				
				// Highlight selected.
				if (dateCell.alpha != noMonthDayAlpha && dateCell.text == String(calSettings.calendarDate)) {
					txtSelected = dateCell;
					txtSelected.backgroundColor = colorSelected;
				}
			}
		}
		
		private function updatePrevMonthDays():void {
			var prevMonthFirstDay:Date = new Date(calSettings.firstDay.fullYear,calSettings.firstDay.month,calSettings.firstDay.date - 1);
			for (var i:int = firstDayColumn-1; i >= 0; i--) {
				aDateCells[i].text = String( prevMonthFirstDay.date - ((firstDayColumn - 1) - i) );
				aDateCells[i].setTextFormat(dateCellFormat);
				aDateCells[i].alpha = noMonthDayAlpha;
				aDateCells[i].border = false;
			}
		}
		
		private function updateNextMonthDays():void {
			for (var i:int = 1; i < (totalCells - maxDays - (firstDayColumn - 1)); i++) {
				aDateCells[(firstDayColumn - 1) + i + maxDays].text = i.toString();
				aDateCells[(firstDayColumn - 1) + i + maxDays].setTextFormat(dateCellFormat);
				aDateCells[(firstDayColumn - 1) + i + maxDays].alpha = noMonthDayAlpha;
				aDateCells[(firstDayColumn - 1) + i + maxDays].border = false;
			}
		}
		
		protected function updateCalendarTime():void {
			txtTime.text = calSettings.getTimeForCalendar();
		}
		// -------------------------- End of Update ------------------------- //
	}
}