package src3d.lines
{
	public class LineLibrary
	{
		public static const NAME_CLASS_BASE_PATH:String = "src3d.lines::"; // Class path to use 'getDefinitionByName'.
		public static const NAME_LINE:String		= "Line"; // Identify Object Name. See DynamicLineBase or LineMaker.
		
		// Line Ids. 1 - Movement, 2 - Custom, 3 - Pass, 4 - Dribble, 5 - Line
		public static const ID_01_MOVEMENT:int					= 1;
		public static const ID_02_CUSTOM:int					= 2;
		public static const ID_03_PASS:int						= 3;
		public static const ID_04_DRIBBLE:int					= 4;
		public static const ID_05_LINE:int						= 5;		
		public static const ID_06_CUSTOM_PASS:int				= 6;
		public static const ID_07_LINE_2:int					= 7;
		public static const ID_08_LINE_3:int					= 8;
		public static const ID_09_LINE_4:int					= 9;
		public static const ID_10_ELEVATED:int					= 10;
		public static const ID_11_PARABOLIC:int					= 11;
		public static const ID_12_SINUSOIDAL:int				= 12;
		public static const ID_13_CUSTOM_SINUSOIDAL:int			= 13;
		public static const ID_14_GRID:int						= 14;
		public static const ID_15_CARRY:int						= 15;
		public static const ID_16_CUSTOM_CARRY:int				= 16;
		public static const ID_17_RUN:int						= 17;
		public static const ID_18_CUSTOM_RUN:int				= 18;
		public static const ID_19_SHOOT:int						= 19;
		
		
		public static const NAME_01_MOVEMENT:String				= "movement";
		public static const NAME_02_CUSTOM:String				= "custom";
		public static const NAME_03_PASS:String					= "pass";
		public static const NAME_04_DRIBBLE:String				= "dribble";
		public static const NAME_05_LINE:String					= "line";		
		public static const NAME_06_CUSTOM_PASS:String			= "custompass";
		public static const NAME_07_LINE_2:String				= "line2";
		public static const NAME_08_LINE_3:String				= "line3";
		public static const NAME_09_LINE_4:String				= "line4";
		public static const NAME_10_ELEVATED:String				= "elevated";
		public static const NAME_11_PARABOLIC:String			= "parabolic";
		public static const NAME_12_SINUSOIDAL:String			= "sin";
		public static const NAME_13_CUSTOM_SINUSOIDAL:String	= "custsin";
		public static const NAME_14_GRID:String					= "grid";
		public static const NAME_15_CARRY:String				= "carry";
		public static const NAME_16_CUSTOM_CARRY:String			= "customcarry";
		public static const NAME_17_RUN:String					= "run";
		public static const NAME_18_CUSTOM_RUN:String			= "customrun";
		public static const NAME_19_SHOOT:String				= "shoot";
		
		// Line Styles.
		public static const STYLE_CONTINUOUS:int				= 0;
		public static const STYLE_DASHED:int					= 1;
		public static const STYLE_DOTTED:int					= 2;
		public static const STYLE_SINUSOIDAL:int				= 3;
		
		// Line Types.
		public static const TYPE_SIMPLE:int						= 0;
		public static const TYPE_CUSTOM:int						= 1;
		public static const TYPE_CURVED:int						= 2;
		public static const TYPE_ELEVATED:int					= 3;
		public static const TYPE_PARABOLIC:int					= 4;
		public static const TYPE_GRID:int						= 5;
		
		// Line Arrow Heads.
		public static const ARROW_HEAD_NONE:int					= 0;
		public static const ARROW_HEAD_END:int					= 1;
		public static const ARROW_HEAD_START:int				= 2;
		public static const ARROW_HEAD_BOTH:int					= 3;
		// Line Thickness.
		public static const LINE_THICKNESS_THICK:int			= 0;
		public static const LINE_THICKNESS_MEDIUM:int			= 1;
		public static const LINE_THICKNESS_THIN:int				= 2;
		// Line Arrow Thickness.
		public static const ARROW_THICKNESS_THICK:int			= 0;
		public static const ARROW_THICKNESS_MEDIUM:int			= 1;
		public static const ARROW_THICKNESS_THIN:int			= 2;
		// Line Handles.
		public static const LINE_HANDLES_NONE:int				= 0;
		public static const LINE_HANDLES_FULL:int				= 1;
		
		// Array of Line Buttons in the interface (see lines.as).
		public static var aLineButtons:Array = new Array(
			{name:NAME_01_MOVEMENT, id:LineLibrary.ID_01_MOVEMENT},
			{name:NAME_02_CUSTOM, id:LineLibrary.ID_02_CUSTOM},
			{name:NAME_03_PASS, id:LineLibrary.ID_03_PASS},
			{name:NAME_04_DRIBBLE, id:LineLibrary.ID_04_DRIBBLE},
			{name:NAME_05_LINE, id:LineLibrary.ID_05_LINE},
			{name:NAME_06_CUSTOM_PASS, id:LineLibrary.ID_06_CUSTOM_PASS},
			{name:NAME_07_LINE_2, id:LineLibrary.ID_07_LINE_2},
			{name:NAME_08_LINE_3, id:LineLibrary.ID_08_LINE_3},
			{name:NAME_09_LINE_4, id:LineLibrary.ID_09_LINE_4},
			//{name:NAME_10_ELEVATED, id:LineLibrary.ID_10_ELEVATED},
			//{name:NAME_11_PARABOLIC, id:LineLibrary.ID_11_PARABOLIC},
			//{name:NAME_12_SINUSOIDAL, id:LineLibrary.ID_12_SINUSOIDAL},
			//{name:NAME_13_CUSTOM_SINUSOIDAL, id:LineLibrary.ID_13_CUSTOM_SINUSOIDAL},
			{name:NAME_14_GRID, id:LineLibrary.ID_14_GRID}
		);
		
		public function LineLibrary()
		{
		}
	}
}