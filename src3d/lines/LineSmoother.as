package src3d.lines
{
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	
	import src3d.utils.LineUtils;
	import src3d.utils.Logger;

	public class LineSmoother
	{
		private var logger:Logger = Logger.getInstance();
		
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:LineSmoother;
		private static var _allowInstance:Boolean = false;
		
		public function LineSmoother()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():LineSmoother
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new LineSmoother();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		public function smoothCustomLine(path:Path):void {
			var pathSegmentsTmp:Vector.<PathCommand>;
			var strPathSegments:String;
			var strPathLength:int;
			var charsToRemove:int;
			var strPathSegmentsTrimmed:String;
			var pathTrimmed:Path;
			var lastCommand:int;
			var totalSegments:int;
			
			pathSegmentsTmp =  path.aSegments.concat(); // Use a copy to work with it.
			strPathSegments = LineUtils.pathDataSegmentsToString(path.aSegments);
			//logger.addInfo("-- Processing PathData --\n"+strPathSegments+"\n-- End of Processing PathData --");
			
			// Apply path's default smoothing.
			path.smoothPath(); // This also converts segments from lines to curves.
			//trace("--- Path Length: "+LineUtils.getPathSegmentsLength(path.aSegments));
			
			// Reduce the amount of points used to draw the line.
			pathSegmentsTmp =  path.aSegments.concat(); // Use a copy to work with it.
			totalSegments = pathSegmentsTmp.length;
			LineUtils.convertSegmentsToSmoothCurves(pathSegmentsTmp);
			logger.addInfo("Line _pathData smoothed from "+totalSegments+" to "+pathSegmentsTmp.length+" segments.");
			
			// If path length still high, re-smooth again.
			strPathSegments = LineUtils.pathDataSegmentsToString(pathSegmentsTmp);
			strPathLength = strPathSegments.length;
			if (strPathLength > SSPSettings.defaultLinePathDataMaxChars) {
				logger.addInfo("Line _pathData would use "+strPathLength+" characters. Smoothing more...");
				totalSegments = pathSegmentsTmp.length;
				LineUtils.convertSegmentsToSmoothCurves(pathSegmentsTmp);
				logger.addInfo("Line _pathData smoothed from "+totalSegments+" to "+pathSegmentsTmp.length+" segments.");
			}
			
			// If path length still high, re-smooth again.
			strPathSegments = LineUtils.pathDataSegmentsToString(pathSegmentsTmp);
			strPathLength = strPathSegments.length;
			if (strPathLength > SSPSettings.defaultLinePathDataMaxChars) {
				logger.addInfo("Line _pathData would use "+strPathLength+" characters. Smoothing more again...");
				totalSegments = pathSegmentsTmp.length;
				LineUtils.convertSegmentsToSmoothCurves(pathSegmentsTmp);
				logger.addInfo("Line _pathData smoothed from "+totalSegments+" to "+pathSegmentsTmp.length+" segments.");
			}
			
			// Trim line if needed.
			pathSegmentsTmp = trimCustomLine(pathSegmentsTmp);
			path.aSegments = pathSegmentsTmp.concat();
			
			// Apply path's default smoothing.
			// path.smoothPath(); // Disabled here because it may increase the amount of segments.
			
			strPathSegments = LineUtils.pathDataSegmentsToString(pathSegmentsTmp);
			strPathLength = strPathSegments.length;
			logger.addInfo("Line _pathData length: "+strPathLength+" characters. (max: "+SSPSettings.defaultLinePathDataMaxChars+").");
			///logger.addInfo("-- Processed PathData --\n"+strPathSegments+"\n-- End of Processed PathData --");
		}
		
		public function trimCustomLine(aSegmentsSrc:Vector.<PathCommand>):Vector.<PathCommand> {
			if (!aSegmentsSrc) {
				logger.addError("Can't trim null segments.");
				return new Vector.<PathCommand>();
			}
			var strPathSegments:String;
			var strPathLength:int;
			var pathTrimmed:Path;
			var pathSegmentsTmp:Vector.<PathCommand> = aSegmentsSrc.concat();
			var strPathSegmentsTrimmed:String;
			
			strPathSegments = LineUtils.pathDataSegmentsToString(pathSegmentsTmp);
			strPathLength = strPathSegments.length;
			if (strPathLength > SSPSettings.defaultLinePathDataMaxChars) {
				try {
					logger.addInfo("Line _pathData still would use "+strPathLength+" characters. Trimming...");
					strPathSegmentsTrimmed = trimPathDataString(strPathSegments);
					pathTrimmed = LineUtils.stringToPathData(strPathSegmentsTrimmed);
					//trace(strPathSegmentsTrimmed);
					if (pathTrimmed) {
						pathSegmentsTmp = pathTrimmed.aSegments.concat(); // concat() creates a copy.
					} else {
						logger.addError("There was an error triming this Line. Invalid path returned.\n-- Processed PathData --\n"+strPathSegments+"\n-- End of Processed PathData --");
					}
					//trace("--- Path Length: "+LineUtils.getPathSegmentsLength(pathSegmentsTmp));
					
				} catch(error:Error) {
					logger.addError("Error Triming Line Path Data: "+error.message+"\n-- Processed PathData --\n"+strPathSegments+"\n-- End of Processed PathData --");
				}
			}
			
			if (pathSegmentsTmp) { 
				aSegmentsSrc = pathSegmentsTmp.concat();
			} else {
				logger.addError("There was an error while trimming this Line. Invalid path segments returned. No trimming was done.\n-- Source PathData --\n"+
					LineUtils.pathDataSegmentsToString(aSegmentsSrc)+"\n-- End of Source PathData --");
			}
			return aSegmentsSrc;
		}
		
		public function trimPathDataString(strPathSegments:String):String {
			if (!strPathSegments) {
				logger.addError("Error trimming null path data.");
				return "";
			}
			var charsToRemove:int;
			var lastCommand:int;
			var strPathSegmentsTrimmed:String;
			var strPathLength:int = strPathSegments.length;
			
			if (strPathLength > SSPSettings.defaultLinePathDataMaxChars) {
				charsToRemove = strPathLength - SSPSettings.defaultLinePathDataMaxChars;
				strPathSegmentsTrimmed = strPathSegments.slice(0,-charsToRemove); // Note: using negative 'end' number, will remove from the end of the string.
				
				// Remove the last segment because it may be broken.
				lastCommand = strPathSegmentsTrimmed.lastIndexOf("|C");
				if (lastCommand > 1) {
					strPathSegmentsTrimmed = strPathSegmentsTrimmed.slice(0, lastCommand); 
					//lastCommand = strPathSegmentsTrimmed.lastIndexOf("|L");
					//strPathSegmentsTrimmed = strPathSegmentsTrimmed.slice(0, lastCommand);
					logger.addInfo("Line _pathData trimmed from "+strPathLength+ " to "+strPathSegmentsTrimmed.length+" characters.");
				} else {
					strPathSegmentsTrimmed = strPathSegments; // No trimming done.
				}
			} else {
				strPathSegmentsTrimmed = strPathSegments; // No trimming done.
			}
			return strPathSegmentsTrimmed;
		}
	}
}