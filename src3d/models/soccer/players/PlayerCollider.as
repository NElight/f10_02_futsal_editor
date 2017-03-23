package src3d.models.soccer.players
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import src.team.SSPTeamEvent;
	
	import src3d.SSPEvent;
	import src3d.SSPEventDispatcher;
	import src3d.SessionGlobals;
	import src3d.SessionScreen;
	import src3d.utils.EventHandler;

	public class PlayerCollider
	{
		// Global Vars.
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		private var sspEventDispatcher:SSPEventDispatcher = SSPEventDispatcher.getInstance();
		private var stageEventHandler:EventHandler;
		
		private var sScreen:SessionScreen;
		private var sPlayer:Player; // Source Player.
		private var tPlayer:Player; // Target Player.
		private var currentTeams:Vector.<Player>;
		private var teamCollision:Boolean;
		
		public function PlayerCollider(sScreen:SessionScreen, sPlayer:Player)
		{
			this.sScreen = sScreen;
			this.sPlayer = sPlayer;
			stageEventHandler = new EventHandler(sScreen.stage);
		}
		
		// ----------------------------- Collision Deletion ----------------------------- //
		public function startTeamCollisionDetection():void {
			stageEventHandler.RemoveEvents();
			if (!sPlayer) return;
			updateTeams();
			stageEventHandler.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			stageEventHandler.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		public function stopTeamCollisionDetection():void {
			stageEventHandler.RemoveEvents();
			for each(var p:Player in sScreen.aPlayers) {
				// Remove highlight.
				p.highlightTeamPlayer = false;
			}
		}
		
		private function updateTeams():void {
			currentTeams = new Vector.<Player>();
			for each(var p:Player in sScreen.aPlayers) {
				if (p.teamPlayer) currentTeams.push(p);
			}
		}
		
		private function onStageEnterFrame(e:Event):void {
			var dist:Number = -1;
			var oldDist:Number = -1;
			var closestPlayer:Player;
			teamCollision = false;
			for each(var p:Player in sScreen.aPlayers) {
				if (p.cKit._kitId == sPlayer.cKit._kitId && sPlayer != p) {
					dist = playerCollisionTestDistance(sPlayer,p);
					if (dist > -1) {
						if (closestPlayer) {
							if (oldDist > dist) {
								closestPlayer = p;
								oldDist = dist;
							}
						} else {
							closestPlayer = p;
							oldDist = dist;
						}
						//trace("TEAM PLAYER COLLIDES ("+dist+")");
						teamCollision = true;
					} else {
						//trace("TEAM PLAYER NOT COLLIDES ("+dist+")"
						p.highlightTeamPlayer = false;
						sPlayer.highlightTeamPlayer = false;
					}
				}
			}
			if (main.keysManager.isKeyDown(Keyboard.CONTROL)) teamCollision = false;
			if (closestPlayer) {
				if (tPlayer) tPlayer.highlightTeamPlayer = false;
				tPlayer = closestPlayer;
				tPlayer.highlightTeamPlayer = teamCollision;
				sPlayer.highlightTeamPlayer = teamCollision;
			}
		}
		
		private function onStageMouseUp(e:Event):void {
			stopTeamCollisionDetection();
			if (!sPlayer || !tPlayer || !teamCollision) return;
			teamCollision = false;
			
			// Get tPlayer position and rotation.
			var tmpRotationY:Number = sPlayer.objectRotationY;
			var tmpElevation:Number = sPlayer.elevationNumber;
			var tmpOldPos:Vector3D = sPlayer.oldPos;
			var tmpTeamPlayerData:Object;
			
			// If source is already on pitch.
			if (tmpOldPos) {
				// If source is teamPlayer, source goes back to initial position.
				if (sPlayer.teamPlayer) {
					sPlayer.dropTo(tmpOldPos);
					
					// Swap player details.
					tmpTeamPlayerData = sPlayer.getTeamPlayerData();
					sPlayer.setTeamPlayerData(tPlayer.getTeamPlayerData());
					tPlayer.setTeamPlayerData(tmpTeamPlayerData);
				} else {
					// If not team player, both swap positions.
					sPlayer.objectRotationY = tPlayer.objectRotationY;
					sPlayer.elevationNumber = tPlayer.elevationNumber;
					sPlayer.dropTo(tPlayer.position);
					
					tPlayer.objectRotationY = tmpRotationY;
					tPlayer.elevationNumber = tmpElevation;
					tPlayer.dropTo(tmpOldPos);
					
					// Swap player details.
					tmpTeamPlayerData = sPlayer.getTeamPlayerData();
					sPlayer.setTeamPlayerData(tPlayer.getTeamPlayerData());
					tPlayer.setTeamPlayerData(tmpTeamPlayerData);
				}
			} else {
				// Else, source came from 2D menu.
				// If source is not a team player, target get source pose.
				if (!sPlayer.teamPlayer) {
					// Swap player details.
					tmpTeamPlayerData = sPlayer.getTeamPlayerData();
					sPlayer.setTeamPlayerData(tPlayer.getTeamPlayerData());
					tPlayer.setTeamPlayerData(tmpTeamPlayerData);
					
					// Source gets target position.
					sPlayer.objectRotationY = tPlayer.objectRotationY;
					sPlayer.elevationNumber = tPlayer.elevationNumber;
					sPlayer.dropTo(tPlayer.position);
					// Target is deleted.
					sScreen.deletePlayer(tPlayer);
				} else {
					// Swap player details.
					tmpTeamPlayerData = sPlayer.getTeamPlayerData();
					sPlayer.setTeamPlayerData(tPlayer.getTeamPlayerData());
					tPlayer.setTeamPlayerData(tmpTeamPlayerData);
					
					// If both are team players, substitution.
					if (tPlayer.teamPlayer) {
						// Substitute and delete.
						sScreen.substitutePlayers(sPlayer, tPlayer);
					} else {
						// Else delete Source.
						sScreen.deletePlayer(sPlayer);
					}
				}
			}
			tPlayer = null;
		}
		
		public function playerCollisionTestDistance(objA:Player, objB:Player):Number {
			var dist:Number=Vector3D.distance(objA.position,objB.position);
			if(dist<=(objA.centralDiscRadius+objB.centralDiscRadius)){
				return dist;
			}
			return -1;
		}
		
		public function dispose():void {
			sPlayer = null;
			tPlayer = null;
			sScreen = null;
			currentTeams = new Vector.<Player>();
			stageEventHandler.RemoveEvents();
			stageEventHandler = null;
		}
	}
}