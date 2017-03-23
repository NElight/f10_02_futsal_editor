package src3d.models
{
	import away3d.core.geom.Path;
	import away3d.events.MouseEvent3D;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import src3d.ButtonSettings;
	import src3d.SSPCursors;
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.SessionView;
	import src3d.lines.AreaBase;
	import src3d.lines.DynamicLine;
	import src3d.lines.LineBase;
	import src3d.lines.LineLibrary;
	import src3d.lines.LineSettings;
	import src3d.models.soccer.ObjectTypeLibrary;
	import src3d.models.soccer.equipment.EquipmentSettings;
	import src3d.models.soccer.players.PlayerSettings;
	import src3d.text.TextSettings;
	import src3d.utils.LineUtils;
	import src3d.utils.Logger;

	public class ObjectCloner
	{
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var item:SSPObjectBase;
		private var useMouse:Boolean;
		private var sessionView:SessionView;
		private var sScreen:SessionScreen;
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		public function ObjectCloner(sessionScreen:SessionScreen)
		{
			this.sScreen = sessionScreen;
			this.sessionView = sessionScreen.sessionView;
		}
		
		public function startCloning(newItem:SSPObjectBase, useMouse:Boolean):void {
			trace("ObjectCloner().startCloning()");
			if (!newItem) return;
			item = newItem;
			this.useMouse = useMouse;
			sG.createMode = true;
			sG.camLocked = true;
			sessionView.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
		}
		
		public function stopCloning():void {
			trace("ObjectCloner().stopCloning()");
			//if (!sG.cloneMode || !sessionView.view || !sessionView.stage) return;
			if (sessionView.view) sessionView.view.scene.removeEventListener(MouseEvent3D.MOUSE_UP, onViewMouseUp);
			if (sessionView.stage) {
				sessionView.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				sessionView.stage.removeEventListener(MouseEvent.CLICK, onStageMouseClick);
			}
			SSPEventDispatcher.getInstance().dispatchEvent(new SSPEvent(SSPEvent.CREATE_OBJECT_BY_CLONING, false));
		}
		
		/**
		 * Starts listening for stage clicks and view mouse ups on the first mouse down,
		 * otherwise, the first mouse click comes from the clone button click. 
		 * @param e MouseEvent
		 */		
		private function onStageMouseDown(e:MouseEvent):void {
			//trace("ObjectClonner.onStageMouseDown()");
			sessionView.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			
			sessionView.view.scene.addEventListener(MouseEvent3D.MOUSE_UP, onViewMouseUp);
			sessionView.stage.addEventListener(MouseEvent.CLICK, onStageMouseClick);
		}
		
		private function onViewMouseUp(e:MouseEvent3D):void {
			trace("ObjectClonner.onViewMouseUp()");
			if (useMouse) {
				cloneItem(sessionView.drag3d.getIntersect());
			} else {
				cloneItem();
			}
		}
		
		private function onStageMouseClick(e:MouseEvent):void {
			//trace("ObjectClonner.onStageMouseClick()");
			if (!sessionView.isMouseOn3DView() || !sG.createMode) {
				stopCloning();
			}
		}
		
		private function cloneItem(newPos:Vector3D = null):void {
			trace("cloneItem()");
			if (!sG.createMode || !item) {
				stopCloning();
				return;
			}
			var objEnabled:Boolean = false;
			// Add the object to the objects collection.
			switch(item.objectType) {
				case ObjectTypeLibrary.OBJECT_TYPE_PLAYER:
					var pSettings:PlayerSettings = item.settings.clone() as PlayerSettings; // Clone the settings.
					if (pSettings) {
						if (newPos) {
							if (!isPosOnPitch(sScreen, newPos)) return;
							pSettings._x = newPos.x;
							pSettings._z = newPos.z;
						}
						sScreen.createNewObject3D(pSettings, false, objEnabled);
					}
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_EQUIPMENT:
					var eSettings:EquipmentSettings = item.settings.clone() as EquipmentSettings; // Clone the settings.
					if (eSettings) {
						if (newPos) {
							if (!isPosOnPitch(sScreen, newPos)) return;
							eSettings._x = newPos.x;
							eSettings._z = newPos.z;
						}
						sScreen.createNewObject3D(eSettings, false, objEnabled);
					}
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_LINE:
					var lSettings:LineSettings = item.settings.clone() as LineSettings; // Clone the settings.
					if (lSettings) {
						var p:Path = LineUtils.stringToPathData(lSettings._pathData);
						if (p == null || p.length == 0 || p.aSegments.length == 0) return;
						if (newPos) {
							if (!isPathOnPitch(sScreen, p, newPos)) return;
							var newLine:LineBase = sScreen.createNewLine3D(lSettings, objEnabled);
							if (newLine) {
								newLine.moveLineTo(newPos);
							}
						}
					}
					break;
				case ObjectTypeLibrary.OBJECT_TYPE_TEXT:
					var tSettings:TextSettings = item.settings.clone() as TextSettings; // Clone the settings.
					if (tSettings) {
						if (newPos) {
							if (!isPosOnPitch(sScreen, newPos)) return;
							tSettings._x = newPos.x;
							tSettings._z = newPos.z;
						}
						
						sScreen.createNewText(tSettings, false, objEnabled);
					}
					break;
			}
		}
		
		private function isPosOnPitch(sS:SessionScreen, pos:Vector3D):Boolean {
			var isOnPitch:Boolean;
			try {
				isOnPitch = sS.isPosOnPitch(pos);
			} catch (error:Error) {
				var errorStr:String = "Error ("+error.errorID+"): "+error.message;
				Logger.getInstance().addText("(A) - Error while checking Position on pitch: "+errorStr, false);
				isOnPitch = false;
			}
			return isOnPitch;
		}
		
		private function isObjectOnPitch(sS:SessionScreen, obj:*):Boolean {
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
		
		private function isPathOnPitch(sS:SessionScreen, path:Path, pos:Vector3D):Boolean {
			var isOnPitch:Boolean;
			try {
				isOnPitch = sS.isPathOnPitch(path, pos)
			} catch (error:Error) {
				var errorStr:String = "Error ("+error.errorID+"): "+error.message;
				Logger.getInstance().addText("(A) - Error while checking Path Position on pitch: "+errorStr, false);
				isOnPitch = false;
			}
			return isOnPitch;
		}
		
		public function dispose():void {
			// Remove listeners.
			stopCloning();
			// Remove references.
			item = null;
			sessionView = null;
			sScreen = null;
			sG = null;
		}
	}
}