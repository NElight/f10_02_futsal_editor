package src.team
{
	import flash.geom.Vector3D;
	
	import src3d.SessionGlobals;

	public class TeamGlobals
	{
		private static var _self:TeamGlobals;
		private static var _allowInstance:Boolean = false;
		
		// Team Settings Vars.
		private var _initialSelectTeamSourceCellSettings:PRCellRendererFormat; // Global 'select team' form's source list cell renderer settings.
		private var _initialSelectTeamTargetCellSettings:PRCellRendererFormat; // Global 'select team' form's target list cell renderer settings.
		private var _initialCompactCellSettings:PRCellRendererFormat; // Global compact cell renderer settings in team lists.
		private var _initialExpandedCellSettings:PRCellRendererFormat; // Global expanded cell renderer settings in team lists.
		private var _aPlayersPerTeam:Array		= []; // Populated from session data _maxPlayersPerTeam.
		
		public static const PLAY_HOME:String			= "Home";
		public static const PLAY_AWAY:String			= "Away";
		
		public static const PLAYER_NUMBER:String		= "Number";
		public static const PLAYER_POSE:String			= "Pose";
		
		public static const TEAM_OUR:String				= "Ours";
		public static const TEAM_OPP:String				= "Opposition";
		
		public var aWePlay:Array						= [PLAY_HOME, PLAY_AWAY];
		public var aNumberFormat:Array					= [PLAYER_NUMBER, PLAYER_POSE];
		
		public static const SCREEN_FORMATION_P1:String	= "P1"; // Period My Team.
		public static const SCREEN_FORMATION_P2:String	= "P2"; // Period 2 Teams.
		public static const SCREEN_FORMATION_S1:String	= "S1"; // Set-piece.
		
		public static const DEFAULTS_PLAYER_NAME_FORMAT:String		= "4"; // Family Name. Used only if no <screen_defaults> found.
		public static const DEFAULTS_PLAYER_MODEL_FORMAT:String		= "1"; // Player Model + Number. Used only if no <screen_defaults> found.
		public static const DEFAULTS_S1_NAME_DISPLAY:Boolean		= false;
		public static const DEFAULTS_S1_MODEL_DISPLAY:Boolean		= false;
		public static const DEFAULTS_S1_POSITION_DISPLAY:Boolean	= false;
		public static const DEFAULTS_P1_NAME_DISPLAY:Boolean		= true;
		public static const DEFAULTS_P1_MODEL_DISPLAY:Boolean		= false;
		public static const DEFAULTS_P1_POSITION_DISPLAY:Boolean	= false;
		public static const DEFAULTS_P2_NAME_DISPLAY:Boolean		= true;
		public static const DEFAULTS_P2_MODEL_DISPLAY:Boolean		= false;
		public static const DEFAULTS_P2_POSITION_DISPLAY:Boolean	= false;
		
		public static const delimiter:String			= "|"; // Formation delimiter.
		
		public static const PLAYER_ID_DIGITS:uint		= 9; // Number of digits used to create new _nonprPlayerId's.
		public static const PLAYER_NUMBER_MAX_CHARS		= 3;
		public static const NONPR_PLAYER_ID_MAX:uint	= 255;
		
		public static const PR_PLAYER_XML:XML			= new XML(<pr_team_player>
																	<_prPlayerId>0</_prPlayerId>																    
																	<_squadMember></_squadMember>
																    <_lastTeam></_lastTeam>
																    <_playerNumber></_playerNumber>
																    <_playerPositionId></_playerPositionId>
																    <_poseId>0</_poseId>
																    <_sortOrder></_sortOrder>
																    <_squadId></_squadId>
																  </pr_team_player>);
		
		public static const NONPR_PLAYER_XML:XML		= new XML(<nonpr_team_player>
																    <_nonprPlayerId>0</_nonprPlayerId>
																    <_givenName></_givenName>
																    <_familyName></_familyName>
																    <_playerNumber></_playerNumber>
																    <_playerPositionId></_playerPositionId>
																    <_poseId>0</_poseId>
																    <_sortOrder></_sortOrder>
																    <_teamSide></_teamSide>
																  </nonpr_team_player>);
		
		public static const vFormations:Vector.<SSPFormation> = new <SSPFormation>[
			new SSPFormation(11, "4-4-2", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,388|488,0,164|488,0,-164|488,0,-388|160,0,164|160,0,-164"),
			new SSPFormation(11, "4-4-2 (D)", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|584,0,0|434,0,276|434,0,-276|286,0,0|100,0,164|100,0,-164"),
			new SSPFormation(11, "4-5-1", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,490|488,0,250|488,0,0|488,0,-250|488,0,-490|160,0,0"),
			new SSPFormation(11, "4-3-3", "1070,0,12|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,300|488,0,0|488,0,-300|160,0,300|160,0,0|160,0,-300"),
			new SSPFormation(11, "4-2-3-1", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,164|488,0,-164|280,0,300|280,0,0|280,0,-300|70,0,0"),
			new SSPFormation(11, "4-1-4-1", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,0|280,0,388|280,0,164|280,0,-164|280,0,-388|70,0,0"),
			new SSPFormation(11, "4-1-3-2", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,0|280,0,300|280,0,0|280,0,-300|70,0,164|70,0,-164"),
			new SSPFormation(11, "4-4-1-1", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,388|488,0,164|488,0,-164|488,0,-388|280,0,0|70,0,0"),
			new SSPFormation(11, "3-1-5-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0|280,0,490|280,0,250|280,0,0|280,0,-250|280,0,-490|70,0,0"),
			new SSPFormation(11, "3-2-3-1-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|584,0,164|584,0,-164|434,0,300|434,0,0|434,0,-300|286,0,0|100,0,0"),
			new SSPFormation(11, "3-1-4-2", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0|280,0,388|280,0,164|280,0,-164|280,0,-388|70,0,164|70,0,-164"),
			new SSPFormation(11, "5-3-2", "1070,0,0|783,0,490|783,0,250|783,0,0|783,0,-250|783,0,-490|488,0,300|488,0,0|488,0,-300|160,0,164|160,0,-164"),
			new SSPFormation(11, "5-3-1-1", "1070,0,0|783,0,490|783,0,250|783,0,0|783,0,-250|783,0,-490|488,0,300|488,0,0|488,0,-300|280,0,0|70,0,0"),
			new SSPFormation(11, "1-4-4-1", "1070,0,0|783,0,0|488,0,388|488,0,164|488,0,-164|488,0,-388|280,0,388|280,0,164|280,0,-164|280,0,-388|70,0,0"),
			new SSPFormation(11, "3-2-2-3", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,164|488,0,-164|280,0,490|280,0,-490|70,0,300|70,0,0|70,0,-300"),
			new SSPFormation(11, "3-5-1-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,490|488,0,250|488,0,0|488,0,-250|488,0,-490|280,0,0|70,0,0"),
			new SSPFormation(11, "3-5-2", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,490|488,0,250|488,0,0|488,0,-250|488,0,-490|160,0,164|160,0,-164"),
			new SSPFormation(11, "3-4-3", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,388|488,0,164|488,0,-164|488,0,-388|160,0,300|160,0,0|160,0,-300"),
			
			new SSPFormation(9, "4-2-2", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,164|488,0,-164|160,0,164|160,0,-164"),
			new SSPFormation(9, "4-3-1", "1070,0,0|783,0,388|783,0,164|783,0,-164|783,0,-388|488,0,300|488,0,0|488,0,-300|160,0,0"),
			new SSPFormation(9, "3-3-2", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,300|488,0,0|488,0,-300|160,0,164|160,0,-164"),
			new SSPFormation(9, "2-4-2", "1070,0,0|783,0,164|783,0,-164|488,0,388|488,0,164|488,0,-164|488,0,-388|160,0,164|160,0,-164"),
			new SSPFormation(9, "3-3-1-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,300|488,0,0|488,0,-300|280,0,0|70,0,0"),
			new SSPFormation(9, "1-4-2-1", "1070,0,0|783,0,0|488,0,388|488,0,164|488,0,-164|488,0,-388|280,0,490|280,0,-490|70,0,0"),
			new SSPFormation(9, "1-3-3-1", "1070,0,0|783,0,0|488,0,300|488,0,0|488,0,-300|280,0,300|280,0,0|280,0,-300|70,0,0"),
			new SSPFormation(9, "3-1-3-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0|280,0,300|280,0,0|280,0,-300|70,0,0"),
			
			new SSPFormation(8, "3-2-2", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,164|488,0,-164|160,0,164|160,0,-164"),
			new SSPFormation(8, "3-3-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,300|488,0,0|488,0,-300|160,0,0"),
			new SSPFormation(8, "3-2-1-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,164|488,0,-164|280,0,0|70,0,0"),
			new SSPFormation(8, "1-2-3-1", "1070,0,0|783,0,0|488,0,164|488,0,-164|280,0,300|280,0,0|280,0,-300|70,0,0"),
			new SSPFormation(8, "1-3-2-1", "1070,0,0|783,0,0|488,0,300|488,0,0|488,0,-300|280,0,490|280,0,-490|70,0,0"),
			new SSPFormation(8, "1-2-2-2", "1070,0,0|783,0,0|488,0,164|488,0,-164|280,0,490|280,0,-490|70,0,164|70,0,-164"),
			new SSPFormation(8, "2-1-3-1", "1070,0,0|783,0,164|783,0,-164|488,0,0|280,0,300|280,0,0|280,0,-300|70,0,0"),
			new SSPFormation(8, "2-2-1-2", "1070,0,0|783,0,164|783,0,-164|488,0,164|488,0,-164|280,0,0|70,0,300|70,0,-300"),
			
			new SSPFormation(7, "2-2-1-1", "1070,0,0|783,0,164|783,0,-164|488,0,164|488,0,-164|280,0,0|70,0,0"),
			new SSPFormation(7, "2-1-2-1", "1070,0,0|783,0,164|783,0,-164|488,0,0|280,0,490|280,0,-490|70,0,0"),
			new SSPFormation(7, "3-2-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,164|488,0,-164|160,0,0"),
			new SSPFormation(7, "3-1-1-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0|280,0,0|70,0,0"),
			new SSPFormation(7, "3-1-2", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0|160,0,164|160,0,-164"),
			new SSPFormation(7, "1-2-2-1", "1070,0,0|783,0,0|488,0,164|488,0,-164|280,0,490|280,0,-490|70,0,0"),
			new SSPFormation(7, "1-2-1-2", "1070,0,0|783,0,0|488,0,164|488,0,-164|280,0,0|70,0,164|70,0,-164"),
			
			new SSPFormation(6, "2-2-1", "1070,0,0|783,0,164|783,0,-164|488,0,164|488,0,-164|160,0,0"),
			new SSPFormation(6, "2-1-2", "1070,0,0|783,0,164|783,0,-164|488,0,0|160,0,164|160,0,-164"),
			new SSPFormation(6, "2-1-1-1", "1070,0,0|783,0,164|783,0,-164|488,0,0|280,0,0|70,0,0"),
			new SSPFormation(6, "1-2-2", "1070,0,0|783,0,0|488,0,164|488,0,-164|160,0,164|160,0,-164"),
			new SSPFormation(6, "1-1-2-1", "1070,0,0|783,0,0|488,0,0|280,0,490|280,0,-490|70,0,0"),
			new SSPFormation(6, "3-1-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0|160,0,0"),
			
			new SSPFormation(5, "1-2-1", "1070,0,0|783,0,0|488,0,164|488,0,-164|160,0,0"),
			new SSPFormation(5, "2-1-1", "1070,0,0|783,0,164|783,0,-164|488,0,0|160,0,0"),
			new SSPFormation(5, "1-1-2", "1070,0,0|783,0,0|488,0,0|160,0,164|160,0,-164"),
			new SSPFormation(5, "3-1", "1070,0,0|783,0,300|783,0,0|783,0,-300|488,0,0"),
			
			new SSPFormation(4, "2-1", "1070,0,0|783,0,164|783,0,-164|488,0,0"),
			new SSPFormation(4, "1-1-1", "1070,0,0|783,0,0|488,0,0|160,0,0"),
			new SSPFormation(4, "1-2", "1070,0,0|783,0,0|488,0,164|488,0,-164")
		];
		
		public function getFormationListNames(playersPerTeam:uint):Array {
			var newFormationNames:Array = [];
			var fList:Vector.<SSPFormation> = getFormationList(playersPerTeam);
			for each(var sspForm:SSPFormation in fList) {
				newFormationNames.push(sspForm.name);
			}
			return newFormationNames;
		}
		public function getFormationList(playersPerTeam:uint):Vector.<SSPFormation> {
			var newFormation:Vector.<SSPFormation> = new Vector.<SSPFormation>();
			for each(var sspForm:SSPFormation in vFormations) {
				if (sspForm.numPlayers == playersPerTeam) {
					newFormation.push(sspForm);
				}
			}
			return newFormation;
		}
		public function getFormationListArray(playersPerTeam:uint):Array {
			var newFormation:Array = [];
			for each(var sspForm:SSPFormation in vFormations) {
				if (sspForm.numPlayers == playersPerTeam) {
					newFormation.push(sspForm);
				}
			}
			return newFormation;
		}
		
		/**
		 * Returns the positions of each player in a pitch according to the specified formation.
		 *  
		 * @param formation String. Eg. '4-4-2'. See <code>aFormation</code> for details.
		 * @param pitchWidth Number. The length of the pitch in the Z axis.
		 * @param pitchLength. Number. The length of the pitch in the X axis.
		 * @return A Vector.<Vector.<Vector3D>> with each player positions per row.
		 * @see <code>aFormation</code>
		 */		
		public function getFormationPos(formation:String, pitchWidth:Number, pitchLength:Number):Vector.<Vector.<Vector3D>> {
			var totalRows:Array = formation.split("-");
			var rowSpace:Number = (pitchLength / totalRows.length) + 1; // Get space between rows in pitch.
			var vFormation:Vector.<Vector.<Vector3D>> = new Vector.<Vector.<Vector3D>>();
			var newRow:Vector.<Vector3D>;
			for (var i:uint;i<totalRows.length;i++) {
				newRow = this.getRowPos(totalRows[i], pitchWidth, rowSpace);
				vFormation.push( newRow );
				rowSpace++;
			}
			return vFormation;
		}
		
		/**
		 * Returns the positions of each player in a row (alongside the pitch width). 
		 * @param divisions uint. How many players in the row.
		 * @param distance Number. The row distance (eg. the pitch width).
		 * @return A Vector.<Vector3D> with each player position in the row.
		 * @see <code>getFormationPos</code>
		 */		
		private function getRowPos(divisions:uint, rowLength:Number, rowXPos:Number):Vector.<Vector3D> {
			var newRow:Vector.<Vector3D> = new Vector.<Vector3D>();
			var space:Number = (rowLength / divisions) + 1; // Get space between players in row.
			var initialDistance:Number = -(rowLength/2);
			var tmpV:Vector3D;
			
			for (var i:uint;i<divisions;i++) {
				tmpV = new Vector3D(rowXPos, 0, initialDistance+space);
				newRow.push(tmpV);
				initialDistance += space;
			}
			
			return newRow;
		}
		
		public function TeamGlobals() {
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance():TeamGlobals {
			if(_self == null) {
				_allowInstance=true;
				_self = new TeamGlobals();
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		
		public function get aPlayersPerTeam():Array {
			if (_aPlayersPerTeam.length > 0) return _aPlayersPerTeam;
			for each (var f:SSPFormation in vFormations) {
				if (_aPlayersPerTeam.indexOf(f.numPlayers) == -1) _aPlayersPerTeam.push(f.numPlayers);
			}
			return _aPlayersPerTeam;
		}
		
		public function get aNameFormat():Array {
			// "Full Name", "Initial + Family Name", "Given Name + Initial", "Initials", "Family Name", "Given Name", "Family Name + Given Name".
			var sL:XML = SessionGlobals.getInstance().interfaceLanguageDataXML;
			return [String(sL.options._teamShowFullName.text()),
				String(sL.options._teamShowInitialFamily.text()),
				String(sL.options._teamShowGivenInitial.text()),
				String(sL.options._teamShowInitials.text()),
				String(sL.options._teamShowFamily.text()),
				String(sL.options._teamShowGiven.text()),
				String(sL.options._teamShowFamilyGiven.text())];
		}
		
		public function get aPlayerModelFormat():Array {
			// "Player Model", "Player Model + Number".
			var sL:XML = SessionGlobals.getInstance().interfaceLanguageDataXML;
			return [String(sL.options._teamShowPitchModel.text()),
				String(sL.options._teamShowPitchModelNumber.text())];
		}
		
		public function get initialSelectTeamSourceCellSettings():PRCellRendererFormat {
			if (!_initialSelectTeamSourceCellSettings) {
				_initialSelectTeamSourceCellSettings = new PRCellRendererFormat();
				
				// Format.
				_initialSelectTeamSourceCellSettings.displayName = true;
				_initialSelectTeamSourceCellSettings.displayFamName = true;
				_initialSelectTeamSourceCellSettings.displayNumber = true;
				_initialSelectTeamSourceCellSettings.displayPicture = true;
				_initialSelectTeamSourceCellSettings.displayRemove = false;
				
				// Format extended.
				_initialSelectTeamSourceCellSettings.displayEdit = false;
				_initialSelectTeamSourceCellSettings.displayPose = false;
				_initialSelectTeamSourceCellSettings.displayPosition = true;
			}
			return _initialSelectTeamSourceCellSettings;
		}
		public function get initialSelectTeamTargetCellSettings():PRCellRendererFormat {
			if (!_initialSelectTeamTargetCellSettings) {
				_initialSelectTeamTargetCellSettings = new PRCellRendererFormat();
				_initialSelectTeamTargetCellSettings.displayName = true;
				_initialSelectTeamTargetCellSettings.displayFamName = true;
				_initialSelectTeamTargetCellSettings.displayNumber = true;
				_initialSelectTeamTargetCellSettings.displayPicture = true;
				_initialSelectTeamTargetCellSettings.displayRemove = true;
				_initialSelectTeamTargetCellSettings.displayEdit = false;
				_initialSelectTeamTargetCellSettings.displayPose = false;
				_initialSelectTeamTargetCellSettings.displayPosition = true;
			}
			return _initialSelectTeamTargetCellSettings;
		}
		
		public function get initialCompactCellSettings():PRCellRendererFormat {
			if (!_initialCompactCellSettings) {
				_initialCompactCellSettings = new PRCellRendererFormat();
				_initialCompactCellSettings.displayName = true;
				_initialCompactCellSettings.displayFamName = false;
				_initialCompactCellSettings.displayNumber = true;
				_initialCompactCellSettings.displayPicture = false;
				_initialCompactCellSettings.displayRemove = true;
				_initialCompactCellSettings.displayEdit = true;
				_initialCompactCellSettings.displayPose = false;
				_initialCompactCellSettings.displayPosition = false;
			}
			return _initialCompactCellSettings;
		}
		
		public function get initialExpandedCellSettings():PRCellRendererFormat {
			if (!_initialExpandedCellSettings) {
				_initialExpandedCellSettings = new PRCellRendererFormat();
				_initialExpandedCellSettings.displayName = true;
				_initialExpandedCellSettings.displayFamName = false;
				_initialExpandedCellSettings.displayNumber = true;
				_initialExpandedCellSettings.displayPicture = false;
				_initialExpandedCellSettings.displayRemove = true;
				_initialExpandedCellSettings.displayEdit = true;
				_initialExpandedCellSettings.displayPose = false;
				_initialExpandedCellSettings.displayPosition = true;
			}
			return _initialExpandedCellSettings;
		}
	}
}