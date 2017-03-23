package src.team
{
	import fl.data.DataProvider;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	import src3d.SessionGlobals;
	import src3d.models.KitColorSettings;
	import src3d.models.KitsLibrary;
	import src3d.models.soccer.players.MCPlayer;
	import src3d.models.soccer.players.PlayerLibrary;
	import src3d.utils.ImageUtils;
	import src3d.utils.Logger;
	import src3d.utils.MiscUtils;

	public class PlayerIcons
	{
		// Singleton.
		private static var _self:PlayerIcons;
		private static var _allowInstance:Boolean = false;
		
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		private var _vIcons:Vector.<Vector.<Vector.<Bitmap>>> = new Vector.<Vector.<Vector.<Bitmap>>>();
		
		private var _vPlayers:Vector.<Vector.<Bitmap>> = new Vector.<Vector.<Bitmap>>();
		private var _vKeepers:Vector.<Vector.<Bitmap>> = new Vector.<Vector.<Bitmap>>();
		private var _vOfficials:Vector.<Vector.<Bitmap>> = new Vector.<Vector.<Bitmap>>();
		
		private var mcPlayerIcons:MovieClip;
		
		public function PlayerIcons()
		{
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
				init();
			}
		}
		
		public static function getInstance():PlayerIcons
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new PlayerIcons();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		private function init():void {
			// TODO: Listen to player kit changes and update these kits.
			_vIcons[KitsLibrary.KIT_ID_OUR] = new Vector.<Vector.<Bitmap>>();
			_vIcons[KitsLibrary.KIT_ID_OPP] = new Vector.<Vector.<Bitmap>>();
			//_vIcons[KitsLibrary.KIT_ID_OFF] = new Vector.<Vector.<Bitmap>>();
			
			_vIcons[KitsLibrary.KIT_ID_OUR][PlayerLibrary.TYPE_PLAYER] = new Vector.<Bitmap>();
			_vIcons[KitsLibrary.KIT_ID_OUR][PlayerLibrary.TYPE_KEEPER] = new Vector.<Bitmap>();
			
			_vIcons[KitsLibrary.KIT_ID_OPP][PlayerLibrary.TYPE_PLAYER] = new Vector.<Bitmap>();
			_vIcons[KitsLibrary.KIT_ID_OPP][PlayerLibrary.TYPE_KEEPER] = new Vector.<Bitmap>();
			
			//_vIcons[KitsLibrary.KIT_ID_OFF][PlayerLibrary.TYPE_PLAYER] = new Vector.<Bitmap>(); // Officials kit are displayed in the 'players' section of the Player Kits tabs.
			//_vIcons[KitsLibrary.KIT_ID_OFF][PlayerLibrary.TYPE_KEEPER] = new Vector.<Bitmap>(); // Empty by default.
			
			mcPlayerIcons = new mc_players_list();
			//var mcOfficialIcons:MovieClip = new mc_officials_list();
			var kitXML:XML;
			var pProp:Object;
			var kId:uint;
			var kTypeId:uint;
			var bmp:Bitmap;
			var mcPlayer:MCPlayer;
			var playerProp:Object;
			
			// Loop kit id's.
			for (kId = 0;kId<_vIcons.length;kId++) {
				// Loop kit type id's.
				for (kTypeId = 0;kTypeId<_vIcons[kId].length;kTypeId++) {
					kitXML = sG.sessionDataXML.session.kit.(_kitId == String(kId) && _kitTypeId == String(kTypeId))[0];
					if (kitXML) {
						for (var i:uint = 0; i < mcPlayerIcons.numChildren; i++){
							mcPlayer = mcPlayerIcons.getChildAt(i) as MCPlayer;
							if (mcPlayer) {
								playerProp = PlayerLibrary.getPlayerPropertiesFromId(mcPlayer.objectId);
								if (mcPlayer && playerProp.PlayerType == kTypeId) {
									mcPlayer.setKitColorFromXML(kitXML); // Color Player Icon.
									if (mcPlayer.dragEnabled) mcPlayer.dragEnabled = false;
									bmp = mcPlayer.getScreenshot(); // Take screenshot.
									bmp.name = mcPlayer._objectId.toString(); // Get PlayerId from objectId (See MCPlayer.as and Drag2DObject.as).
									_vIcons[kId][kTypeId].push(bmp); // Add screenshot to vector.
								}
							}
						}
					} else {
						Logger.getInstance().addText("No default <kit> tag found in session data for kitId("+kId+"), kitTypeId("+kTypeId+").", true);
					}
				}
			}
		}
		
		public function getPlayerIcon(pId:int, kitId:int, kitTypeId:int, targetContainer:DisplayObjectContainer, padding:Number):Bitmap {
			var srcBmpIcon:Bitmap = getPlayerBmp(pId, kitId, kitTypeId);
			var bmpIcon:Bitmap = ImageUtils.fitImageForContainer(srcBmpIcon, targetContainer, true, padding);
			bmpIcon.name = srcBmpIcon.name;
			return bmpIcon;
		}
		private function getPlayerBmp(pId:int, kitId:int, kitTypeId:int):Bitmap {
			var newBmp:Bitmap = new Bitmap();
			
			if (kitId != -1 && kitTypeId != -1) {
				for each (var bmp:Bitmap in _vIcons[kitId][kitTypeId]) {
					if (bmp.name == pId.toString()) {
						newBmp.bitmapData = bmp.bitmapData;
						newBmp.name = bmp.name;
						return newBmp;
					}
				}
			}
			
			// Loop kit id's.
			/*var kId:uint;
			var kTypeId:uint;
			for (kId = 0;kId<_vIcons.length;kId++) {
				// Loop kit type id's.
				for (kTypeId = 0;kTypeId<_vIcons[kId].length;kTypeId++) {
					for each (var bmp:Bitmap in _vIcons[kId][kTypeId]) {
						if (bmp.name == pId.toString()) {
							newBmp.bitmapData = bmp.bitmapData;
							newBmp.name = bmp.name;
							break;
						}
					}
				}
			}*/
			return newBmp;
		}
		
		
		/**
		 * @return a DataProvider list with the poses.
		 * @see <code>src.team.forms.PlayerPoseCellRenderer.data()</code>
		 */		
		public function getPlayerIconsDataProvider(kId:int = -1, kTypeId:int = -1):DataProvider {
			var newDP:DataProvider = new DataProvider();
			var iconItem:Object; // playerPoseBmp, playerPoseId, PlayerPoseName.
			var kBmp:Bitmap;
			if (kId != -1 && kTypeId != -1) {
				for each(kBmp in _vIcons[kId][kTypeId]) {
					iconItem = getPlayerIconItem(kBmp);
					newDP.addItem(iconItem);
				}
			} else if (kId == -1 && kTypeId != -1) {
				for (kId = 0;kId<_vIcons.length;kId++) {
					for each(kBmp in _vIcons[kId][kTypeId]) {
						iconItem = getPlayerIconItem(kBmp);
						newDP.addItem(iconItem);
					}
				}
				
			} else if (kId != -1 && kTypeId == -1) {
				for (kTypeId = 0;kTypeId<_vIcons[kId].length;kTypeId++) {
					for each(kBmp in _vIcons[kId][kTypeId]) {
						iconItem = getPlayerIconItem(kBmp);
						newDP.addItem(iconItem);
					}
				}
			} else {
				// Loop kit id's (ours, opposition).
				for (kId = 0;kId<_vIcons.length;kId++) {
					// Loop kit type id's (players, keepers, officials).
					for (kTypeId = 0;kTypeId<_vIcons[kId].length;kTypeId++) {
						for each(kBmp in _vIcons[kId][kTypeId]) {
							iconItem = getPlayerIconItem(kBmp);
							newDP.addItem(iconItem);
						}
					}
				}
			}
			return newDP;
		}
		private function getPlayerIconItem(kBmp:Bitmap):Object {
			var iconItem:Object; // playerPoseBmp, playerPoseId, PlayerPoseName.
			var tagName:String;
			var poseName:String;
			var poseBmp:Bitmap;
			
			poseBmp = new Bitmap(kBmp.bitmapData);
			poseBmp.name = kBmp.name;
			tagName = "_tagPosition"+MiscUtils.addLeadingZeros(poseBmp.name, SSPSettings.namesDigits);;
			poseName = sG.interfaceLanguageDataXML.tags[0][tagName].text();
			iconItem = {
				playerPoseId:poseBmp.name,
					playerPoseName:poseName,
					playerPoseBmp:poseBmp
			};
			return iconItem;
		}
	}
}