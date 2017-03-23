package src.print
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.printing.PrintJobOrientation;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.ScreenshotItem;
	import src3d.SessionGlobals;
	import src3d.utils.ColorUtils;
	import src3d.utils.ImageUtils;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;

	public class SSPPrinter extends EventDispatcher
	{
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var logger:Logger = Logger.getInstance();
		private var _stage:Stage;
		
		private var printForm:PrintFormPopup
		
		public function SSPPrinter(st:Stage)
		{
			_stage = st;
			printForm = PrintFormPopup.getInstance(_stage);
			sspEventDispatcher.addEventListener(SSPEvent.PRINT_START, onPrintStart);
		}
		
		private function onPrintStart(e:SSPEvent):void {
			printHighResBmp(e.eventData);
		}
		
		public function printHighResBmp(vScreenshots:Vector.<ScreenshotItem>):void {
			if (!vScreenshots || vScreenshots.length == 0) {
				logger.addText("Can't start Print Job. No Screenshots.", true);
				sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.PRINT_DONE, false));
				return;
			}
			var bmp:Bitmap;
			var txtField:TextField;
			var txtSize:uint = 12;
			var txtAlign:String = TextFormatAlign.CENTER;
			var txtBold:Boolean = false;
			var txtWidth:Number = 40;
			var txtHeight = 40;
			var pj:PrintJob = new PrintJob();
			var pjOptions:PrintJobOptions = new PrintJobOptions(true);
			var printArea:Rectangle;
			var marginX:Number;
			var marginY:Number;
			var spContainer:Sprite;
			var bmpContainer:Bitmap;
			var sp:Sprite;
			var printJobOK:Boolean = true;
			
			var sessionTitle:String = String(SessionGlobals.getInstance().sessionDataXML.session._sessionTitle.text());
			if (sessionTitle && sessionTitle != "") sessionTitle += "\n";
			
			logger.addText("Starting Print Job", false);
			if (pj.start()) {
				logger.addText("- Print settings received from system. Preparing Print Job.", false);
				for (var i:uint=0;i<vScreenshots.length;i++) {
					bmp = vScreenshots[i].bitmap;
					bmp.smoothing = true;
					if (pj.orientation == PrintJobOrientation.PORTRAIT) {
						txtWidth = pj.pageHeight;
						bmp.width = pj.pageHeight;
						bmp.scaleY = bmp.scaleX;
						marginX =  ((pj.pageHeight-bmp.width)/2);
						marginY =  ((pj.pageWidth-bmp.height)/2);
					} else {
						txtWidth = pj.pageWidth;
						bmp.width = pj.pageWidth;
						bmp.scaleY = bmp.scaleX;
						marginX =  ((pj.pageWidth-bmp.width)/2);
						marginY =  ((pj.pageHeight-bmp.height)/2);
					}
					
					bmp.x += marginX;
					bmp.y += marginY;
					
					if (!txtField) txtField = MiscUtils.createNewTextField(0, 0, txtWidth, txtHeight, TextFieldType.DYNAMIC, false, true, false, txtSize, 0, 200, false, txtBold, txtAlign);
					txtField.text = String(sessionTitle + vScreenshots[i].text);
					txtField.x = 0;
					txtField.y = 0;
					
					spContainer = new Sprite();
					spContainer.addChild(bmp);
					spContainer.addChild(txtField);
					bmpContainer = MiscUtils.takeScreenshot(spContainer, false, 0xFFFFFF, false, 0);
					sp = new Sprite();
					if (bmpContainer) sp.addChild(bmpContainer);
					
					if (pj.orientation == PrintJobOrientation.PORTRAIT) sp.rotation = -90;
					
					sp.x = 2000;
					// To avoid blank pages when printing as bitmap (PrintJobOptions(true)), we need to add the sprite to stage.
					main.stage.addChild(sp);
					
					//printArea = new Rectangle(-marginX, -marginX, pj.pageWidth, pj.pageHeight); // Center image in page.
					logger.addText("- Adding pages to Print Job.", false);
					try {
						pj.addPage(sp, printArea, pjOptions);
					} catch(e:Error) {
						logger.addText("Can't add page to Print Job: "+e.message+".", true);
					}
					main.stage.removeChild(sp);
				}
				logger.addText("- Sending Print Job.", false);
				try {
					pj.send();
				} catch(e:Error) {
					logger.addText("Can't send Print Job: "+e.message+".", true);
					printJobOK = false;
				}
				pj = null; // Delete job from memory.
				if (printJobOK) logger.addText("- Print Job sent.", false);
			} else {
				logger.addText("Print Job Canceled.", false);
			}
			sspEventDispatcher.dispatchEvent(new SSPEvent(SSPEvent.PRINT_DONE, true));
		}
	}
}