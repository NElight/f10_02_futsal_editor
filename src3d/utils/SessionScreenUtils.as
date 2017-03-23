package src3d.utils
{
	import fl.data.DataProvider;
	
	import src3d.ScreenSettingsDefault;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.lines.LineBase;
	import src3d.lines.LineSettings;
	import src3d.lines.LineSmoother;
	import src3d.models.Equipment;
	import src3d.models.SSPObjectBase;
	import src3d.models.soccer.equipment.EquipmentSettings;
	import src3d.models.soccer.players.Player;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.text.Billboard;
	import src3d.text.TextSettings;

	public class SessionScreenUtils
	{
		// Global variables.
		private static var sG:SessionGlobals = SessionGlobals.getInstance();
		private static var sD:XML = SessionGlobals.getInstance().sessionDataXML;
		
		public function SessionScreenUtils() {
		}
		
		public static function updateScreenObjects(sS:SessionScreen, screenXML:XML, players:Boolean, equipment:Boolean, lines:Boolean, texts:Boolean, defaultEquipment:Boolean):void {
			//var screenXML:XML = sView.getScreenXML(false, false);
			var tmpXMLList:XMLList = new XMLList();
			var tmpXML:XML;
			var i:int;

			// Collect pitch objects array.
			var aPl:Vector.<Player> = sS.aPlayers; // Players Array.
			var aEq:Vector.<Equipment> = sS.aEquipment; // Equipment Array.
			var aEqD:Vector.<Equipment> = sS.aDefaultEquipment; // Default Equipment Array.
			var aLi:Vector.<LineBase> = sS.aLines; // Lines Array.
			var aTx:Vector.<Billboard> = sS.aTexts; // Texts Array.
			
			var pSettings:PlayerSettings;
			var eSettings:EquipmentSettings;
			var lSettings:LineSettings;
			var tSettings:TextSettings;
			
			var strFormations:String = "";
			
			// Remove screen objects.
			clearScreen(screenXML, true);
			
			if (players || equipment || lines || texts || defaultEquipment) screenXML._screenChangedFlag = "TRUE"; // TODO: make screenChangedFlag work properly.
			
			// Wrap globalRotationY.
			screenXML._globalRotationY = MiscUtils.wrapAngle( screenXML._globalRotationY ).toFixed(2);
			
			// ---- PLAYERS ---- //
			if (players) {
				// ---- PLAYERS ---- //
				for (i=0;i<aPl.length;i++) {
					if (isObjectOnPitch(sS, aPl[i])) {
						pSettings = aPl[i].settings as PlayerSettings; // Get updated settings.
						tmpXML = new XML(<player/>);
						tmpXML._playerLibraryId = pSettings._libraryId;
						tmpXML._kitId = pSettings._cKit._kitId; // cKit is the custom Kit object of the player.
						tmpXML._kitTypeId = pSettings._cKit._kitTypeId; 
						tmpXML._topColor = pSettings._cKit._topColor;
						tmpXML._bottomColor = pSettings._cKit._bottomColor;
						tmpXML._socksColor = pSettings._cKit._socksColor;
						tmpXML._shoesColor = pSettings._cKit._shoesColor;
						tmpXML._skinColor = pSettings._cKit._skinColor;
						tmpXML._rotationY = MiscUtils.wrapAngle( pSettings._rotationY ).toFixed(2); // Number.toFixed(2) rounds to two decimals to store it in the database.
						tmpXML._x = pSettings._x.toFixed(2);
						tmpXML._y = pSettings._elevationNumber.toFixed(2);
						tmpXML._z = pSettings._z.toFixed(2);
						tmpXML._flipH = pSettings._flipHString; // Converts it to capital 'TRUE' or 'FALSE'.
						// v2 vars.
						tmpXML._stripesType = pSettings._cKit._stripesType;
						tmpXML._skinTexture = pSettings._cKit._skinTexture;
						tmpXML._hairType = pSettings._cKit._hairType;
						tmpXML._hairColor = pSettings._cKit._hairColor;
						tmpXML._stripesType = pSettings._cKit._stripesType;
						tmpXML._stripesColor = pSettings._cKit._stripesColor;
						tmpXML._transparency = pSettings._transparencyString; // Converts it to capital 'TRUE' or 'FALSE'.
						tmpXML._accessories = pSettings._accessories;
						// team settings.
						tmpXML._teamPlayerId = pSettings._teamPlayerId;
						tmpXML._playerPositionId = pSettings._playerPositionId;
						tmpXML._playerNumber = pSettings._playerNumber;
						tmpXMLList += tmpXML;
						strFormations += Math.round(tmpXML._x)+","+Math.round(tmpXML._y)+","+Math.round(tmpXML._z)+"|\r\n";
					} else {
						Logger.getInstance().addText("(A) - 3D Object not on pitch. Excluded from xml.", false);
					}
				}
				// Debug Formation Data.
				//strFormations = strFormations.substr(0,strFormations.length-3)+"\r\n";
				//var formationsXML:XML = new XML(<formations></formations>);
				//formationsXML.formation = "-\r\n"+strFormations+"-\r\n";
				//screenXML.appendChild(formationsXML);
			}
			
			// ---- DEFAULT EQUIPMENT ---- //
			if (defaultEquipment) {
				for (i=0;i<aEqD.length;i++) {
					if (isObjectOnPitch(sS, aEqD[i])) {
						eSettings = aEqD[i].settings as EquipmentSettings; // Get updated settings.
						tmpXML = new XML(<equipment/>);
						tmpXML._equipmentLibraryId = eSettings._libraryId;
						tmpXML._rotationY = MiscUtils.wrapAngle( eSettings._rotationY ).toFixed(2);
						tmpXML._x = eSettings._x.toFixed(2);
						tmpXML._y = eSettings._elevationNumber.toFixed(2);
						tmpXML._z = eSettings._z.toFixed(2);
						tmpXML._flipH = eSettings._flipHString; // Not used in v1. defaults to false.
						tmpXML._onlyDefaultPitches = eSettings._onlyDefaultPitchesString; // Converts it to capital 'TRUE' or 'FALSE'.
						// v2 vars.
						tmpXML._equipColor = eSettings._equipColorHex;
						tmpXML._pathData = eSettings._pathData;
						tmpXML._transparency = eSettings._transparencyString; // Converts it to capital 'TRUE' or 'FALSE'.
						tmpXML._size = eSettings._size.toFixed(2);
						tmpXMLList += tmpXML;
					} else {
						Logger.getInstance().addText("(A) - 3D Object not on pitch. Excluded from xml.", false);
					}
				}
			}
			
			// ---- EQUIPMENT ---- //
			if (equipment) {
				for (i=0;i<aEq.length;i++) {
					if (isObjectOnPitch(sS, aEq[i])) {
						eSettings = aEq[i].settings as EquipmentSettings; // Get updated settings.
						tmpXML = new XML(<equipment/>);
						tmpXML._equipmentLibraryId = eSettings._libraryId;
						tmpXML._rotationY = MiscUtils.wrapAngle( eSettings._rotationY ).toFixed(2);
						tmpXML._x = eSettings._x.toFixed(2);
						tmpXML._y = eSettings._elevationNumber.toFixed(2);
						tmpXML._z = eSettings._z.toFixed(2);
						tmpXML._flipH = eSettings._flipHString; // Not used in v1. defaults to false.
						tmpXML._onlyDefaultPitches = eSettings._onlyDefaultPitchesString; // Converts it to capital 'TRUE' or 'FALSE'.
						// v2 vars.
						tmpXML._equipColor = eSettings._equipColorHex;
						tmpXML._pathData = eSettings._pathData;
						tmpXML._transparency = eSettings._transparencyString; // Converts it to capital 'TRUE' or 'FALSE'.
						tmpXML._size = eSettings._size.toFixed(2);
						tmpXMLList += tmpXML;
					} else {
						Logger.getInstance().addText("(A) - 3D Object not on pitch. Excluded from xml.", false);
					}
				}
			}
			
			// ---- LINES ---- //
			if (lines) {
				for (i=0;i<aLi.length;i++) {
					// Discard empty lines.
					if (aLi[i].pathData.length > 1) {
						if (isObjectOnPitch(sS, aLi[i])) {
							lSettings = aLi[i].settings as LineSettings; // Get updated settings.
							tmpXML = new XML(<line/>);
							tmpXML._linesLibraryId = lSettings._libraryId;
							tmpXML._pathData = LineSmoother.getInstance().trimPathDataString(lSettings._pathData);
							tmpXML._pathCommands = lSettings._pathCommands;
							tmpXML._lineStyle = lSettings._lineStyle;
							tmpXML._lineType = lSettings._lineType;
							tmpXML._lineColor = lSettings._lineColor;
							tmpXML._lineThickness = lSettings._lineThickness;
							tmpXML._useArrowHead = lSettings._useArrowHead;
							tmpXML._arrowThickness = lSettings._arrowThickness;
							tmpXML._useHandles = lSettings._useHandles;
							tmpXMLList += tmpXML;
						} else {
							Logger.getInstance().addText("(A) - 3D Object not on pitch. Excluded from xml.", false);
						}
					}
				}
			}
			
			// ---- TEXTS ---- //
			if (texts) {
				for (i=0;i<aTx.length;i++) {
					if (isObjectOnPitch(sS, aTx[i])) {
						tSettings = aTx[i].settings as TextSettings; // Get updated settings.
						tmpXML = new XML(<text/>);
						tmpXML._textLibraryId = tSettings._libraryId;
						tmpXML._textContent = tSettings._textContent;
						tmpXML._x = tSettings._x.toFixed(2);
						tmpXML._y = tSettings._y.toFixed(2);
						tmpXML._z = tSettings._z.toFixed(2);
						tmpXML._textContent2 = tSettings._textContent2;
						tmpXML._textStyle = tSettings._textStyle;
						tmpXMLList += tmpXML;
					} else {
						Logger.getInstance().addText("(A) - 3D Object not on pitch. Excluded from xml.", false);
					}
				}
			}
			screenXML.appendChild(tmpXMLList);
		}
		
		private static function clearScreen(srcScreenXML:XML, deleteDefaults:Boolean) {
			var i:int;
			// Remove all pitch objects.
			delete srcScreenXML.player;
			delete srcScreenXML.line;
			delete srcScreenXML.text; // Note it will throw a warning when building with warning mode on, because text is also an xml property, but works fine.
			if (deleteDefaults) {
				delete srcScreenXML.equipment;
			} else {
				for (i = srcScreenXML.equipment.length()-1; i>=0; i--) {
					if (srcScreenXML.equipment[i]._onlyDefaultPitches != "TRUE") {
						delete srcScreenXML.equipment[i];
					}
				}
			}
		}
		
		private static function isObjectOnPitch(sS:SessionScreen, obj:SSPObjectBase):Boolean {
			var isOnPitch:Boolean;
			try {
				isOnPitch = sS.isOnPitch(obj);
			} catch (error:Error) {
				var errorStr:String = "Error ("+error.errorID+"): "+error.message;
				Logger.getInstance().addText("(A) - Error while checking Object on pitch: "+errorStr, false);
				isOnPitch = false;
			}
			return isOnPitch;
		}
		
		public static function cloneScreen(sIdx:uint, strNewLabel:String, includeObjects:Boolean, resetComments:Boolean, resetScreenSettings:Boolean):XMLList {
			var strScreenId:String = sIdx.toString();
			var strNewScreenId:String = String (getMaxScreenId() + 1);
			var strDbTransitionId:String = "0"; // 0 is the default value for all new screens.
			var strSIdx:String = sIdx.toString();
			var strComments:String = "";
			var cloneXML:XML = sD.session.screen.(_screenId == strSIdx)[0].copy();
			
			if (!includeObjects) clearScreen(cloneXML, false); // Removes player, equipment (except defaults), lines and text.
			delete cloneXML.pr_minutes;
			delete cloneXML.session_minutes;
			
			cloneXML._screenId = strNewScreenId;
			cloneXML._screenSortOrder = strNewScreenId;
			cloneXML._dbTransitionId = strDbTransitionId;
			cloneXML._screenTitle = strNewLabel;
			cloneXML._screenChangedFlag = "TRUE";
			
			if (resetComments) {
				strComments = sD.session._globalComments.text();
				cloneXML._screenComments = strComments;
			}
			
			// User Image and Video.
			cloneXML._userImageLocation = "";
			cloneXML._userImageExists = "FALSE";
			cloneXML.user_video = ScreenSettingsDefault.USER_VIDEO;
			
			if (resetScreenSettings) {
			//if (sG.sessionTypeIsMatch) {
			//	if (cloneXML._screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
					// Comments.
					cloneXML._skillsPhysicalComment = "";
					cloneXML._skillsPsychologicalComment = "";
					cloneXML._skillsSocialComment = "";
					cloneXML._skillsTacticalComment = "";
					cloneXML._skillsTechnicalComment = "";
					// Skill mix.
					cloneXML._skillsPhysical = "-1";
					cloneXML._skillsPsychological = "-1";
					cloneXML._skillsSocial = "-1";
					cloneXML._skillsTactical = "-1";
					cloneXML._skillsTechnical = "-1";
					cloneXML._timeSpent = "0";
					// Screen formation.
					cloneXML._screenFormat = "";
					cloneXML._screenFormationOurs = "";
					cloneXML._screenFormationOpposition = "";
			//	}
				// Category.
				if (sG.sessionTypeIsMatch) {
					cloneXML._screenCategoryId = "0";
				} else {
					cloneXML._screenCategoryId = sD.session._sessionCategoryId.text();
				}
			//}
			}
			
			// Note that appendChild method in Flash 10 was giving #1009 error when: 'save to pc', then cancel, then click 'add screen' (+) tab.
			sD.session.appendChild(cloneXML);
			
			return sD.session.screen.(_screenId == strNewScreenId);
		}
		
		public static function deleteScreen(sId:uint):void {
			var strSId:String = sId.toString();
			try {
				delete sD.session.screen.(_screenId == strSId)[0];
			}catch (error:Error) {
				var errorStr:String = "Error ("+error.errorID+"): "+error.message;
				Logger.getInstance().addText("Can't delete screen from XML. _screenId: "+strSId+". "+errorStr, true);
			}
		}
		
		
		
		// ----------------------------- Get Screen Values ----------------------------- //
		public static function sortScreensBySortOrder(aScreens:Vector.<SessionScreen>):void {
			aScreens.sort(compareSortOrder);
		}
		private static function compareSortOrder(obj1:SessionScreen, obj2:SessionScreen):Number {
			var sortNumber:int;
			if (!obj1 || !obj2) return 0; // No sorting needed.
			sortNumber = (obj1.screenSortOrder > obj2.screenSortOrder)? 1 : -1;
			return sortNumber;
		}
		
		public static function getMaxScreenId():uint {
			var screenXMLList:XMLList = sD.session.children().(localName() == "screen");
			var currentId:uint;
			var maxId:uint;
			for each(var sXML:XML in screenXMLList) {
				currentId = uint( sXML._screenId.text() );
				if ( currentId > maxId ) maxId = currentId;
			}
			return maxId;
		}
		public static function getMinScreenId():int {
			var screenXMLList:XMLList = sD.session.children().(localName() == "screen");
			var currentId:uint;
			var minId:int;
			if (screenXMLList.length() == 0) return -1;
			minId = uint( screenXMLList[0]._screenId.text() ); // Get an existing value as reference.
			for each(var sXML:XML in screenXMLList) {
				currentId = uint( sXML._screenId.text() );
				if ( currentId < minId ) minId = currentId;
			}
			return minId;
		}
		public static function getMaxScreenIdFromType(strScreenType:String):int {
			var screenXMLList:XMLList = sD.session.children().(localName() == "screen");
			var currentScreenId:uint;
			var currentScreenType:String;
			var maxId:int = -1;
			for each(var sXML:XML in screenXMLList) {
				currentScreenId = uint( sXML._screenId.text() );
				currentScreenType = sXML._screenType.text();
				if ( currentScreenType == strScreenType && currentScreenId > maxId ) maxId = currentScreenId;
			}
			return maxId;
		}
		
		public static function getMaxScreenSortOrder(strScreenType:String):int {
			var screenXMLList:XMLList;
			if (strScreenType && strScreenType != "") {
				screenXMLList = sD.session.children().(localName() == "screen").(_screenType == strScreenType);
			} else {
				screenXMLList = sD.session.children().(localName() == "screen");
			}
			if (!screenXMLList || screenXMLList.length() == 0) return -1;
			var currentSortOrder:uint;
			var maxSortOrder:int = -1;
			for each(var sXML:XML in screenXMLList) {
				currentSortOrder = uint( sXML._screenSortOrder.text() );
				if (currentSortOrder > maxSortOrder ) maxSortOrder = currentSortOrder;
			}
			return maxSortOrder;
		}
		public static function getMinScreenSortOrder(strScreenType:String):int {
			var screenXMLList:XMLList;
			if (strScreenType && strScreenType != "") {
				screenXMLList = sD.session.children().(localName() == "screen").(_screenType == strScreenType);
			} else {
				screenXMLList = sD.session.children().(localName() == "screen");
			}
			if (!screenXMLList || screenXMLList.length() == 0) return -1;
			var currentSortOrder:uint;
			var minSortOrder:int = int(screenXMLList[0]._sortOrder.text());
			for each(var sXML:XML in screenXMLList) {
				currentSortOrder = uint( sXML._screenSortOrder.text() );
				if (currentSortOrder < minSortOrder ) minSortOrder = currentSortOrder;
			}
			return minSortOrder;
		}
		
		public static function getScreenSortOrderFromScreenId(strScreenId:String):String {
			if (!strScreenId) return "-1";
			var screenXMLList:XMLList = sD.session.screen.(_screenId == strScreenId);
			if (!screenXMLList || screenXMLList.length() == 0) return "-1";
			var screenSortOrder:String = screenXMLList[0]._screenSortOrder.text();
			return screenSortOrder;
		}
		
		public static function getScreenIdFromScreenSortOrder(strScreenSO:String):String {
			var screenId:String;
			var screenXMLList:XMLList = sD.session.screen.(_screenSortOrder == strScreenSO);
			if (screenXMLList && screenXMLList.length() > 0) screenId = screenXMLList[0]._screenId.text();
			return screenId;
		}
		
		public static function getScreenXMLFromScreenId(sId:uint):XML {
			var screenXMLList:XMLList = sD.session.children().(localName() == "screen");
			var currentId:uint;
			for each(var sXML:XML in screenXMLList) {
				currentId = uint( sXML._screenId.text() );
				if ( currentId == sId ) return sXML;
			}
			Logger.getInstance().addText("(SessionScreenUtils) - Can't find XML from requested screenId"+sId+".", true);
			return null;
		}
		
		public static function getScreenFromScreenId(sId:uint, aScreens:Vector.<SessionScreen>):SessionScreen {
			for each(var sS:SessionScreen in aScreens) {
				if (!sS.disposeFlag && sS.screenId == sId) return sS;
			}
			Logger.getInstance().addText("(SessionScreenUtils) - Can't find Screen from requested screenId"+sId+".", true);
			return null;
		}
		
		public static function getScreenXMLFromScreenSortOrder(sSO:uint):XML {
			var screenXMLList:XMLList = sD.session.children().(localName() == "screen");
			var currentSO:uint;
			for each(var sXML:XML in screenXMLList) {
				currentSO = uint( sXML._screenId.text() );
				if ( currentSO == sSO ) return sXML;
			}
			Logger.getInstance().addText("(SessionScreenUtils) - Can't find XML from requested screenSortOrder "+sSO+".", true);
			return null;
		}
		
		/**
		 * Returns the first Screen's XML based in _sortOrder. In match mode, you can specify Screen Type.
		 * @param strScreenType String. Use TeamGlobals contant values: TeamGlobals.SCREEN_TYPE_PERIOD or TeamGlobals.SCREEN_TYPE_SET_PIECE.
		 * If null or "", it will use all the available screens. 
		 * @return XML.
		 * @see <code>TeamGlobals</code>
		 */
		public static function getMinScreenXML(strScreenType:String):XML {
			var screenXMLList:XMLList
			var defaultXML:XML;
			var currentSortOrder:uint;
			var minSortOrder:int;
			if (strScreenType && strScreenType != "") {
				screenXMLList = sD.session.children().(localName() == "screen").(_screenType == strScreenType);
			} else {
				screenXMLList = sD.session.children().(localName() == "screen");
			}
			minSortOrder = getMinScreenSortOrder(strScreenType);
			for each(var sXML:XML in screenXMLList) {
				if (!defaultXML) defaultXML = sXML;
				currentSortOrder = int( sXML._screenSortOrder.text() );
				if ( currentSortOrder == minSortOrder ) return sXML;
			}
			return defaultXML;
		}
		
		/**
		 * Returns the last Screen's XML based in _sortOrder. In match mode, you can specify Screen Type.
		 * @param strScreenType String. Use TeamGlobals contant values: TeamGlobals.SCREEN_TYPE_PERIOD or TeamGlobals.SCREEN_TYPE_SET_PIECE.
		 * If null or "", it will use all the available screens. 
		 * @return XML.
		 * @see <code>TeamGlobals</code>
		 */
		public static function getLastScreenXML(strScreenType:String):XML {
			var screenXMLList:XMLList
			var defaultXML:XML;
			var currentSortOrder:uint;
			var maxSortOrder:int;
			if (strScreenType && strScreenType != "") {
				screenXMLList = sD.session.children().(localName() == "screen").(_screenType == strScreenType);
			} else {
				screenXMLList = sD.session.children().(localName() == "screen");
			}
			maxSortOrder = getMaxScreenSortOrder(strScreenType);
			for each(var sXML:XML in screenXMLList) {
				if (!defaultXML) defaultXML = sXML;
				currentSortOrder = int( sXML._screenSortOrder.text() );
				if ( currentSortOrder == maxSortOrder ) return sXML;
			}
			return defaultXML;
		}
		
		/**
		 * Returns the _screenId value from the screen with higher _sortOrder (the last on the list of tabs). In match mode, you can specify Screen Type.
		 * @param strScreenType String. Use TeamGlobals contant values: TeamGlobals.SCREEN_TYPE_PERIOD or TeamGlobals.SCREEN_TYPE_SET_PIECE.
		 * If null or "", it will use all the available screens. 
		 * @return int. The _screenId value or -1 if not found.
		 * @see <code>TeamGlobals</code>
		 */
		public static function getScreenIdFromMaxSortOrder(strScreenType:String):int {
			var screenXMLList:XMLList
			var defaultXML:XML;
			var currentSortOrder:uint;
			var maxSortOrder:int;
			var screenId:int = -1;
			if (strScreenType && strScreenType != "") {
				screenXMLList = sD.session.children().(localName() == "screen").(_screenType == strScreenType);
			} else {
				screenXMLList = sD.session.children().(localName() == "screen");
			}
			maxSortOrder = getMaxScreenSortOrder(strScreenType);
			for each(var sXML:XML in screenXMLList) {
				currentSortOrder = int( sXML._screenSortOrder.text() );
				if ( currentSortOrder == maxSortOrder ) screenId = int( sXML._screenId.text() );
			}
			return screenId;
		}
		
		/**
		 * Returns the _screenId value from the screen with lower _sortOrder (the last on the list of tabs). In match mode, you can specify Screen Type.
		 * @param strScreenType String. Use TeamGlobals contant values: TeamGlobals.SCREEN_TYPE_PERIOD or TeamGlobals.SCREEN_TYPE_SET_PIECE.
		 * If null or "", it will use all the available screens. 
		 * @return int. The _screenId value or -1 if not found.
		 * @see <code>TeamGlobals</code>
		 */
		public static function getScreenIdFromMinSortOrder(strScreenType:String):int {
			var screenXMLList:XMLList
			var defaultXML:XML;
			var currentSortOrder:uint;
			var minSortOrder:int;
			var screenId:int = -1;
			if (strScreenType && strScreenType != "") {
				screenXMLList = sD.session.children().(localName() == "screen").(_screenType == strScreenType);
			} else {
				screenXMLList = sD.session.children().(localName() == "screen");
			}
			minSortOrder = getMinScreenSortOrder(strScreenType);
			for each(var sXML:XML in screenXMLList) {
				currentSortOrder = int( sXML._screenSortOrder.text() );
				if ( currentSortOrder == minSortOrder ) screenId = int( sXML._screenId.text() );
			}
			return screenId;
				}
		
		public static function getSessionCategoriesDataProvider():DataProvider {
			//Populate categories
			var aDP:Array = [];
			var categories:XMLList;
			if (sG.sessionTypeIsMatch) {
				categories = sG.menuDataXML.meta_data.category.(@_globCategoryType == SessionGlobals.CATEGORY_TYPE_MATCH);
			} else {
				categories = sG.menuDataXML.meta_data.category.(@_globCategoryType == SessionGlobals.CATEGORY_TYPE_TRAINING);
			}
			var strCategoryType:String;
			for each(var category in categories) {
				strCategoryType = String(category.attribute("_globCategoryType"));
				if (strCategoryType == SessionGlobals.CATEGORY_TYPE_TRAINING) {
					aDP.push( {data: category.attribute("_globCategoryId"), label: category.attribute("_globCategoryName") } );
				} else if (strCategoryType == SessionGlobals.CATEGORY_TYPE_MATCH) {
					aDP.push( {data: category.attribute("_globCategoryId"), label: category.attribute("_globCategoryName") } );
				}
			}
			aDP.sortOn("label");
			// Add 'Please Select' at the top of the list.
			//aDP.unshift({data: 0, label:pleaseSelectStr }, 0);
			var catDP:DataProvider = new DataProvider(aDP);
			return catDP;
		}
		
		public static function getScreenCategoriesDataProvider(screenType:String):DataProvider {
			//Populate categories
			var aDP:Array = [];
			var categories:XMLList = sG.menuDataXML.meta_data[0].category;
			var strCategoryType:String;
			for each(var category in categories) {
				strCategoryType = String(category.attribute("_globCategoryType"));
				if (sG.sessionType == SessionGlobals.SESSION_TYPE_TRAINING) {
					// If sessionType == Training, use training categories for screens too.
					if (strCategoryType == SessionGlobals.CATEGORY_TYPE_TRAINING) {
						aDP.push( {data: category.attribute("_globCategoryId"), label: category.attribute("_globCategoryName") } );
					}
				} else {
					if (screenType == SessionGlobals.SCREEN_TYPE_SET_PIECE) {
						if (strCategoryType == SessionGlobals.CATEGORY_TYPE_SET_PIECE) {
							aDP.push( {data: category.attribute("_globCategoryId"), label: category.attribute("_globCategoryName") } );
						}
					}
				}
			}
			aDP.sortOn("label");
			// Add 'Please Select' at the top of the list.
			//aDP.unshift({data: 0, label:pleaseSelectStr }, 0);
			var catDP:DataProvider = new DataProvider(aDP);
			if (sG.sessionTypeIsMatch) {
				var pleaseSelectStr:String = sG.interfaceLanguageDataXML.menu._menuPleaseSelect.text();
				catDP.addItemAt({data: 0, label:pleaseSelectStr }, 0);
			}
			return catDP;
		}
		// -------------------------- End of Get Screen Values ------------------------- //
	}
}