package src3d.utils
{
	import away3d.tools.utils.Drag3D;
	
	import fl.data.DataProvider;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class MiscUtils
	{
		public function MiscUtils()
		{
		}
		public static function mouseTo3D(d3D:Drag3D, screenX:Number, screenY:Number, screenZ:Number = 0):Vector3D {
			//var n3D:Vector3D = new Vector3D;
			// var persp:Number = view.camera.zoom / view.camera.focus;
			// Use Fabrice's Drag3D class...
			//var d3D:Dragger = new Dragger( view );
			//d3D.plane = "xz"; // (same than in SessionView.initDrag).
			//n3D = d3D.getIntersect();
			// 8? WTF?
			/*if (camera.lens is OrthogonalLens) {
				n3D.x /= 8;
				n3D.y /= 8;
				n3D.z /= 8;
			}*/
			//return n3D;
			//var _mousePos3D:Vector3D = d3D.getIntersect();
			//return new Vector3D(_mousePos3D.x, _mousePos3D.y, _mousePos3D.z);
			return d3D.getIntersect().clone();
		}
		/*public static getMousePos3D():Vector3D {
		//var _mousePos3D:Vector3D = _view.camera.unproject(_view.mouseX, _view.mouseY);
 		//var _mousePos3D:Vector3D = MiscUtils.mouseTo3D(_sessionView._drag3d, Math.round(_view.mouseX), Math.round(_view.mouseY));
		var _mousePos3D:Vector3D = _sessionView._drag3d.getIntersect();
		return new Vector3D(_mousePos3D.x, _mousePos3D.y, _mousePos3D.z);
		//return _sessionView._drag3d.getIntersect(Math.round(_view.mouseX), Math.round(_view.mouseY));
		}*/
		
		public static function booleanToString(bln:Boolean):String {
			if (bln) {
				return "TRUE";
			}
			return "FALSE";
		}
		public static function stringToBoolean(string:String):Boolean {
			var aStrings:Array = ["TRUE", "true", "True", "1"];
			for (var i:int = 0;i<aStrings.length;i++) {
				if (aStrings[i] == string) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Creates a new instance from a specified class name.
		 * Eg: var mySprite:Sprite = getClassInstance("mySpriteClassName") as Sprite;
		 * @param className
		 * @return An instance of the class.
		 * 
		 */		
		public static function getClassInstance(className:String):Object {
			var classReference:Class;
			var classInstance:Object;
			try {
				classReference = getDefinitionByName(className) as Class;
				classInstance = new classReference ();
			} catch (e:Error) {
				trace("Error: MiscUtils.getClassInstance()");
				classInstance = null;
			}
			
			return classInstance;
		}
		
		public static function getClassDefinitionByName(className:String):Class {
			var classReference:Class;
			try {
				classReference = getDefinitionByName(className) as Class;
			} catch (e:Error) {
				trace("Error: MiscUtils.getClassDefinitionByName()");
				classReference = null;
			}
			return classReference;
		}

		
		/**
		 * Get the base class name from a Class.
		 * Eg: For Sprite class name 'flash.display::SPrite', it trims 'flash.display::' and returns 'Sprite'.
		 *  
		 * @param obj Any class to get the name from.
		 * @return  String. The base class name.
		 * 
		 */		
		public static function getClassName(obj:*):String {
			var strQCN:String = "";
			try {
				strQCN = getQualifiedClassName(obj);
				strQCN = strQCN.substring(strQCN.indexOf("::")+2);
			} catch (e:Error) {
				trace("Error: MiscUtils.getClassName()");
				strQCN = "";
			}
			return strQCN;
		}
		
		/**
		 * Register a class from an external SWF, so it can be used in the main SWF.
		 * Passing the class to the function is enough to be linked into the SWF.
		 * 
		 * Eg:
		 *   From external SWF:
		 *      MainSWF.registerType(path.to.MyClass);
		 *   From main SWF:
		 *      var myClass:Class = getDefinitionByName("MyClass");
		 * 
		 * @param newClass Class.
		 * 
		 * @see flash.utils.describeType
		 * @see flash.utils.getQualifiedClassName
		 * @see flash.utils.getDefinitionByName
		 */		
		public static function registerNewClass(newClass:Class):void {
			// Passing the class to the function is enough to be registered in the SWF.
		}
		
		/**
		 * Returns the index in the array of a given object in the array with a given value. 
		 * @param objArray Array. The Array to search in.
		 * @param objName String. The Property in the array.
		 * @param objValue *. The value of that property
		 * @return 
		 * 
		 */		
		public static function indexInArray(objArray:Array, objName:String, objValue:*):int {
			var id:int = -1;
			for (var i:int = 0;i<objArray.length;i++) {
				if (objArray[i][objName] == objValue) {
					id = i;
					break;
				}
			}
			return id;
		}
		
		/*public static function takeScreenshot(mcObj:MovieClip, bgTransparent:Boolean = true, bgColor:uint = 0x00FFFFFF):Bitmap {
			var bounds:Rectangle = mcObj.getBounds(mcObj);
			var cloneBmp:Bitmap = new Bitmap();
			cloneBmp.bitmapData = new BitmapData( int( bounds.width + 0.5 ), int( bounds.height + 0.5 ), bgTransparent, bgColor);
			cloneBmp.bitmapData.draw(mcObj, new Matrix(1,0,0,1,-bounds.x,-bounds.y) );
			return cloneBmp;
		}*/
		
		public static function takeScreenshot(dispObj:DisplayObject, bgTransparent:Boolean = true, bgColor:uint = 0x00FFFFFF, cropBlankSpace:Boolean = false, margin:Number = 0.5):Bitmap {
			var bounds:Rectangle = dispObj.getBounds(dispObj);
			var tx:Number = -(bounds.x-(margin/2));
			var ty:Number = -(bounds.y-(margin/2));
			var cloneBmp:Bitmap = new Bitmap();
			cloneBmp.bitmapData = new BitmapData( int( bounds.width + margin ), int( bounds.height + margin ), bgTransparent, bgColor);
			cloneBmp.bitmapData.draw(dispObj, new Matrix(1,0,0,1,tx,ty) );
			if (cropBlankSpace) cloneBmp = new Bitmap(cropOutWhiteSpace(cloneBmp.bitmapData));
			return cloneBmp;
		}
		
		public static function cropOutWhiteSpace(sourceBmd:BitmapData):BitmapData {
			var bounds:Rectangle = sourceBmd.getColorBoundsRect(0xFFFFFF, 0x00000000, false);
			if (bounds.width == 0 || bounds.height == 0) return null;
			var newBmd:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
			newBmd.draw(sourceBmd, new Matrix(1,0,0,1, -bounds.x, -bounds.y));
			return(newBmd);
		}
		
		public static function sortXMLElement(source:XML, elementName:Object, fieldName:String, options:Object = null):XML {
			// list of elements we're going to sort
			var list:XMLList=source.elements("*").(name()==elementName);
			
			// list of elements not included in the sort -
			// we place these back into the source node at the end
			var excludeList:XMLList=source.elements("*").(name()!=elementName);
			
			list= sortXMLList(list,fieldName,options);
			list += excludeList;
			
			source.setChildren(list);
			return source;
		}
		
		/*public static function sortXMLList(list:XMLList, fieldName:String, options:Object = null, asNumber:Boolean = true):XMLList {
			if (list.length() <= 1) return list;
			var arr:Array = new Array();
			var ch:XML;
			var tmpObj:Object;
			if (options == null) options = Array.NUMERIC;
			for each(ch in list)
			{
				tmpObj = {xml:ch, sortOrder:(asNumber)? int(ch[fieldName]):fieldName};
				arr.push(tmpObj);
			}
			var resultArr:Array = fieldName==null ?
				options==null ? arr.sort() :arr.sort(options)
				: arr.sortOn("sortOrder", options);
			
			var result:XMLList = new XMLList();
			for(var i:int=0; i<resultArr.length; i++)
			{
				result += resultArr[i].xml;
			}
			return result;
		}*/
		
		/**
		 * Get the XMLList given, and returns a sorted XMLList. The source XMLList is not modified.
		 * @param list
		 * @param fieldName Object. - A string that identifies a field to be used as the sort value, or an array in which the first element represents the primary sort field, the second represents the secondary sort field, and so on.
		 * @param options Object [optional] - One or more numbers or names of defined constants, separated by the bitwise OR (|) operator, that change the sorting behavior. The following values are acceptable for the options parameter:
		 *   Array.CASEINSENSITIVE or 1.
		 *   Array.DESCENDING or 2.
		 *   Array.UNIQUESORT or 4.
		 *   Array.RETURNINDEXEDARRAY or 8.
		 *   Array.NUMERIC or 16.
		 * @return A new XMLList object with the elements sorted.
		 * @see <code>Array.sortOn()</code>
		 */		
		public static function sortXMLList(list:XMLList, fieldName:String, options:Object = Array.NUMERIC):XMLList {
			if (list.length() <= 1) return list;
			var arr:Array = new Array();
			var ch:XML;
			for each(ch in list)
			{
				arr.push(ch);
			}
			var resultArr:Array = (fieldName == null) ?
				(options == null) ? arr.sort() :arr.sort(options)
				: arr.sortOn(fieldName, options);
			
			var result:XMLList = new XMLList();
			for(var i:uint=0; i<resultArr.length; i++)
			{
				result += resultArr[i];
			}
			return result;
		}
		
		public static function sortXMLbyElementName(xml:XML):XMLList {
			if (!xml || xml.length() == 0) return new XMLList();
			var xmlList:XMLList = xml.copy().children();
			var newXMLList:XMLList;
			var tmpXMLList:XMLList; // For debugging purposes.
			var baseName:String = xml[0].localName();
			
			for (var i:int = 0; i<xmlList.length(); i++) {
				if (xmlIsElement(xmlList[i])) {
					tmpXMLList = sortXMLbyElementName(xmlList[i]);
					xmlList[i] = tmpXMLList;
				}
			}
			
			var tmpXML:XML = new XML("<"+baseName+"/>");
			newXMLList = new XMLList(tmpXML);
			if (xmlList.length() > 1) {
				tmpXMLList = sortXMLListByName(xmlList);
			} else {
				tmpXMLList = xmlList;
			}
			
			newXMLList[0].setChildren(tmpXMLList);
			return newXMLList;
		}
		
		public static function xmlIsElement(xml:XML):Boolean {
			return (xml.nodeKind() == "element")? true : false;
		}
		
		public static function xmlCountElements(xml:XML):int{
			return xmlListCountElements(xml.children());
		}
		
		public static function xmlListCountElements(xmlList:XMLList):int{
			var count:int = 0;
			for (var i:int=0; i<xmlList.length(); i++){
				if (xmlIsElement(xmlList[i])) count++;
			}
			return count;
		}
		
		public static function sortXMLListByName(xmlList:XMLList):XMLList {
			if (xmlList.length() <= 1) return xmlList;
			var aXML:Vector.<XML> = new Vector.<XML>();
			var element:XML;
			for each(element in xmlList)
			{
				aXML.push(element);
			}
			aXML.sort(compareXMLName);
			
			var sortedXMLList:XMLList = new XMLList();
			for(var i:uint=0; i<aXML.length; i++)
			{
				sortedXMLList += aXML[i];
			}
			return sortedXMLList;
		}
		private static function compareXMLName(obj1:XML, obj2:XML):Number {
			var sortNumber:int;
			if (!obj1 || !obj2) return 0; // No sorting needed.
			
			// Create array of names.
			var name1:String = obj1.localName();
			var name2:String = obj2.localName();
			var aNames:Array = [name1, name2];
			var aSortedNames:Array = [name1, name2];
			aSortedNames.sort();
			
			sortNumber = (aNames[0] != aSortedNames[0])? 1 : -1;
			return sortNumber;
		}
		
		public static function xmlListSplice(xmlList:XMLList, fromIdx:uint):XMLList {
			for(var i:int = xmlList.length()-1; i>fromIdx-1 ;i--){
				delete xmlList[i];
			}
			return xmlList;
		}
		
		public static function vectorToArray(iterable:*):Array {
			var ret:Array = [];
			for each (var elem:Object in iterable) ret.push(elem);
			return ret;
		}
		
		/**
		 * Converts a uint into a string in the format “0x123456789ABCDEF”.
		 * This function is quite useful for displaying hex colors as text.
		 *
		 * @author Mims H. Wright (modified by Pimm Hogeling)
		 *
		 * @example 
		 * <listing version="3.0">
		 * getNumberAsHexString(255); // 0xFF
		 * getNumberAsHexString(0xABCDEF); // 0xABCDEF
		 * getNumberAsHexString(0x00FFCC); // 0xFFCC
		 * getNumberAsHexString(0x00FFCC, 6); // 0x00FFCC
		 * getNumberAsHexString(0x00FFCC, 6, false); // 00FFCC
		 * </listing>
		 *
		 *
		 * @param number The number to convert to hex. Note, numbers larger than 0xFFFFFFFF may produce unexpected results.
		 * @param minimumLength The smallest number of hexits to include in the output.
		 *                                          Missing places will be filled in with 0’s.
		 *                                          e.g. getNumberAsHexString(0xFF33, 6); // results in "0x00FF33"
		 * @param showHexDenotation If true, will append "0x" to the front of the string.
		 * @return String representation of the number as a string starting with "0x"
		 */
		public static function getNumberAsHexString(number:uint, minimumLength:uint = 6, showHexDenotation:Boolean = true):String {
			// The string that will be output at the end of the function.
			var string:String = number.toString(16).toUpperCase();
			
			// While the minimumLength argument is higher than the length of the string, add a leading zero.
			while (minimumLength > string.length) {
				string = "0" + string;
			}
			
			// Return the result with a "0x" in front of the result.
			if (showHexDenotation) { string = "0x" + string; }
			
			return string;
		}
		
		public static function removeCarriageReturnsAndNewLines(str:String):String {
			var newString:String;
			var findCarriageReturnRegExp:RegExp = new RegExp("\r", "gi");
			newString = str.replace(findCarriageReturnRegExp, "");
			var findNewLineRegExp:RegExp = new RegExp("\n", "gi");
			newString = newString.replace(findNewLineRegExp, "");
			return newString;
		}
		
		public static function scaleImage(srcImg:DisplayObject, newWidth:Number, newHeight:Number):BitmapData {
				var mat:Matrix = new Matrix();
				mat.scale(newWidth/srcImg.width, newHeight/srcImg.height);
				var bmpd_draw:BitmapData = new BitmapData(newWidth, newHeight, true, 0xFFFFFF);
				bmpd_draw.draw(srcImg, mat, null, null, null, true);
				return bmpd_draw;
		}
		
		public static function stripHTML(str:String) {
			if (str == "" || str == null) return "";
			var removeHTML:RegExp = new RegExp("[<>]", "gi");
			var safeStr:String = str.replace(removeHTML, "");
			return safeStr;
		}
		
		public static function escapeHTML(str:String):String {
			if (str == "" || str == null) return "";
			var htmlChars:Array = new Array();
			
			//We can add as many as we wish...
			htmlChars["\\"] = "";
			htmlChars["\""] = "";
			htmlChars["<img>"] = "";
			htmlChars["</img>"] = "";
			
			htmlChars["<"] = "&#60;";
			htmlChars[">"] = "&#62;";
			htmlChars["/"] = "&#47;";
			
			for (var htmlChar:Object in htmlChars) {
				str = str.split(htmlChar).join(htmlChars[htmlChar]);
			}
			return str;
		}
		
		public static function wrapAngle(angle:Number):Number {
			//return angle % 360;
			var newAngle:Number = angle % 360;
			if (newAngle < 0) newAngle = 360 + newAngle;
			//var newAngle:Number = 360-(((angle%=360)<0) ? angle+360 : angle);
			return (newAngle==360) ? 0 : newAngle;
		}
		
		/**
		 * Check if a movie clip is near the border of his parent. (Work in progress)
		 * @param parentBorder A String that can be "r", "l", "t", "b" (right, left, top, bottom).
		 * @param childMC
		 * @param parentMC
		 * @param proximity A margin allowed to take the decision.
		 * @return 
		 */		
		public static function isCloseToBorder(parentBorder:String, childMC:MovieClip, parentMC:DisplayObjectContainer, proximity:int):Boolean {
			var childMaxPos:Number;
			var parentBorderPos:Number;
			var isClose:Boolean;
			if (parentBorder == "r") {
				childMaxPos = childMC.getBounds(parentMC).right;
				parentBorderPos = parentMC.width; 
			}
			if (Math.abs(parentBorderPos - childMaxPos) < proximity) isClose = true;
			return isClose;
		}
		
		/**
		 * Takes a DisplayObjectContainer (eg:MovieClip) and populates an Array with containing childrens with the specified instance name. 
		 * @param displayObjectContainer A MovieClip, Button or other container.
		 * @param instanceName String with the specified instance name to search for.
		 * @param includedInName Boolean. True if you want to search a string match inside the full name.
		 * @return Array containing the display objects matching the specified name. You can use Array.length to get the total number of objects.
		 * 
		 */		
		public static function movieClipsIn(displayObjectContainer:DisplayObjectContainer, instanceName:String, includedInName:Boolean):Array {
			var aDispObjs:Array = [];
			var dispObj:DisplayObject;
			var i:uint;
			for(i=0; i<displayObjectContainer.numChildren; i++) {
				dispObj = displayObjectContainer.getChildAt(i);
				if (dispObj) {
					if (includedInName) {
						if (dispObj.name.indexOf(instanceName) != -1) aDispObjs.push(dispObj);
					} else {
						if (dispObj.name == instanceName) aDispObjs.push(dispObj);
					}
				}
			}
			return aDispObjs;
		}
		
		/**
		 * Returns the x,y Point to center an object in a container, based on the object bounds.
		 * No matter where it's the central point. 
		 * @param obj DisplayObject. The object to be centered.
		 * @param containerWidth Number. The width of the container to be centered in.
		 * @param containerHeight Number. The height of the container to be centered in.
		 * @return Point.
		 */		
		public static function getPosToCenterInContainer(obj:DisplayObject, containerWidth:Number, containerHeight:Number):Point {
			var contWidth:Number = containerWidth || 0;
			var contHeight:Number = containerHeight || 0;
			var topLeftPos:Point = new Point();
			var centerPos:Point = new Point();
			var rec:Rectangle = obj.getBounds(obj);
			
			topLeftPos.x = (contWidth - rec.width) / 2;
			topLeftPos.y = (contHeight - rec.height) / 2;
			
			centerPos.x = topLeftPos.x + Math.abs(rec.x);
			centerPos.y = topLeftPos.y + Math.abs(rec.y);
			
			return centerPos;
		}
		
		public static function isObjectUnder2DPos(obj:DisplayObject, pos:Point, container:DisplayObjectContainer):Boolean {
			if (!obj || !pos || !container) return false;
			var objects:Array = container.getObjectsUnderPoint(pos);
			for (var i:uint=0; i<objects.length; i++) {
				if (objects[i] == obj) return true;
			}
			return false;
		}
		
		public static function objectContainsPoint(obj:DisplayObject, pos:Point, container:DisplayObjectContainer):Boolean {
			var blnContainsPoint:Boolean;
			var objBounds:Rectangle = obj.getBounds(container);
			blnContainsPoint = objBounds.containsPoint(pos);
			/*trace("objectContainsPoint: "+blnContainsPoint
				+": r.x="+objBounds.x+": r.y="+objBounds.y+": r.w="+objBounds.width+": r.h="+objBounds.height
				+". - Pos: "+pos.x+","+pos.y+"."
			);*/
			return blnContainsPoint;
		}
		
		/**
		 * Takes a number with lot of decimals and return the number with only two decimals max. 
		 * @param num
		 * @return Number with two decimals.
		 * 
		 */		
		public static function trimNum2Dec(num:Number):Number {
			return Math.round(num * 100) / 100;
		}
		
		/**
		 * Converts a vector to an array.
		 * @param	vector:*	The vector to be converted
		 * @return	Array		A converted array
		 */
		/*public static function vectorToArray(vec:*):Array
		{
			var newArray:Array = [];
			for(var i:int = 0; i < vec.length; i++) newArray[i] = vec[i];
			return newArray;
		}*/
		
		/**
		 * Converts a vector to an array and sorts it by specified fieldName and options.
		 * To convert the given Array back to the same Vector type, see the next example:
		 * var vSorted:Vector.<[MyVectorType]> = Vector.<[MyVectorType]>(MiscUtils.vectorSortToArray(myVector, "id", Array.NUMERIC));
		 * Note that [] marks are added only for code completion compatibility.
		 * @param	vector:*			the source vector
		 * @param	fieldName:Object	a string that identifies a field to be used as the sort value
		 * @param	options:Object		one or more numbers or names of defined constants
		 * @return	Array		A sorted array
		 * @see Array.sortOn
		 */
		public static function vectorSortToArray(vector:*, fieldName:Object, options:Object  = null):Array
		{
			if (!options) options = Array.NUMERIC;
			var arr:Array = vectorToArray(vector);
			arr.sortOn(fieldName,options);
			return arr;
		}
		
		public static function vectorToString(vector:*, fieldName:String, useBreak:Boolean):String {
			var newArray:Array = vectorToArray(vector);
			var newString:String = "";
			for (var i:uint;i<newArray.length;i++) {
				newString += newArray[i][fieldName].toString();
				newString += (useBreak)? "\n" : ", ";
			}
			return newString;
		}
		
		public static function addLeadingZeros(strNumber:String, maxZeros:uint):String {
			var newStrNumber:String = (strNumber)? strNumber : "";
			while (maxZeros > newStrNumber.length) {
				newStrNumber = "0" + newStrNumber;
			}
			return newStrNumber;
		}
		
		public static function cropText(text:String, length:uint, chars:String = "..."):String {
			var newText:String;
			if (text.length > length) {
				newText = text.substr(0,length-1);
				newText += chars;
			} else {
				newText = text;
			}
			return newText;
		}
		
		public static function getFlashDateFromMySQL(mysqlDate:String):Date {
			// mysqlDate is a string in the format "0000-00-00 00:00:00".
			var newDate:Date;
			var aDateTime:Array;
			var aDate:Array;
			var aTime:Array;
			var numYear:Number = 0;
			var numMonth:Number = 0;
			var numDay:Number = 0;
			var numHour:Number = 0;
			var numMin:Number = 0;
			var numSec:Number = 0;
			var numMs:Number = 0;
			
			try {
				// Separate Date and Time.
				aDateTime = mysqlDate.split(" ");
				
				// Process date.
				aDate = aDateTime[0].split("-");
				numYear = Number(aDate[0]);
				numMonth = Number(aDate[1])-1; // Flash months starts at 0;
				numDay = Number(aDate[2]);
				
				// Process time.
				aTime = aDateTime[1].split(":");
				numHour = Number(aTime[0]);
				numMin = Number(aTime[1]);
				numSec = Number(aTime[2]);
				
				// Create new Flash Date.
				newDate = new Date(numYear, numMonth, numDay, numHour, numMin, numSec, numMs);
			} catch(error:Error) {
				trace("Error parsing date");
				return null;
			}
			
			return newDate;
		}
		
		public static function roundUpToN(value:Number, n:uint, roundUp:Boolean):int {
			// We can use module (value % 5), but it won't give us the closest higher number.
			value = int(value);
			var rounded:int = (roundUp)? Math.ceil(value/5)*5 : Math.floor(value/5)*5;
			return rounded;
		}
		
		public static function roundDateToNext5mins(date:Date):Date {
			var rTodaysDate:Date = new Date();
			rTodaysDate.setTime(date.getTime());
			var todaysMins:int = rTodaysDate.minutes;
			if (todaysMins < 5) {
				todaysMins = 5;
			} else if (todaysMins < 10) {
				todaysMins = 10;
			} else if (todaysMins < 15) {
				todaysMins = 15;
			} else if (todaysMins < 20) {
				todaysMins = 20;
			} else if (todaysMins < 25) {
				todaysMins = 25;
			} else if (todaysMins < 30) {
				todaysMins = 30;
			} else if (todaysMins < 35) {
				todaysMins = 35;
			} else if (todaysMins < 40) {
				todaysMins = 40;
			} else if (todaysMins < 45) {
				todaysMins = 45;
			} else if (todaysMins < 50) {
				todaysMins = 50;
			} else if (todaysMins < 55) {
				todaysMins = 55;
			} else if (todaysMins < 60) {
				todaysMins = 00;
				rTodaysDate.hours += 1;
			}
			rTodaysDate.minutes = todaysMins;
			rTodaysDate.seconds = 0;
			rTodaysDate.milliseconds = 0;
			return rTodaysDate;
		}
		
		public static function getIndexFromDataProvider(dataProvider:DataProvider, data:Object):int {
			var idx:int = -1;
			if (!dataProvider || !data) return -1;
			for (var i:uint = 0;i<dataProvider.length;i++) {
				if (dataProvider.getItemAt(i).data.toString() == data.toString()) return i;
			}
			return idx;
		}
		
		public static function createNewLabel(xPos:Number = 0, yPos:Number = 0, lblWidth:Number = 100, lblFontSize:Number = 11, lblHeight:Number = 22):TextField {
			return createNewTextField(xPos, yPos, lblWidth, lblHeight, TextFieldType.DYNAMIC, false, false, false, lblFontSize, 0, 100, false);
		}
		
		public static function createNewTextField(xPos:Number, yPos:Number, fieldWidth:Number, fieldHeight:Number, fieldType:String, selectable:Boolean, multiline:Boolean, useBorder:Boolean, fontSize:Number, fontColor:uint = 0, maxChars:uint = 100, useBackground = true, textBold:Boolean = false, textAlign:String = TextFormatAlign.LEFT):TextField {
			var textFormat:TextFormat = new TextFormat(SSPSettings.DEFAULT_FONT, fontSize, fontColor, textBold, null, null, null, null, textAlign);
			var newTxtField:TextField = new TextField;
			newTxtField.defaultTextFormat = textFormat;
			//newTxtField.name = "txtField";
			//newTxtField.type = TextFieldType.INPUT;
			newTxtField.type = fieldType;
			newTxtField.width = fieldWidth;
			newTxtField.height = fieldHeight;
			newTxtField.background = useBackground;
			newTxtField.border = useBorder;
			newTxtField.selectable = selectable;
			newTxtField.maxChars = maxChars;
			newTxtField.multiline = multiline;
			newTxtField.wordWrap = true;
			newTxtField.text = "";
			newTxtField.x = xPos;
			newTxtField.y = yPos;
			return newTxtField;
		}
		
		public static function cycleArrayIdx(array:Array, currentIdx:uint):uint {
			var newIdx:uint = currentIdx + 1;
			if (newIdx >= array.length) newIdx = 0;
			return newIdx;
		}
	}
}