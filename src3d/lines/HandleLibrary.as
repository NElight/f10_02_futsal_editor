package src3d.lines
{
	public class HandleLibrary
	{
		// Handle types.
		public static const HANDLE_TYPE_BASIC:int						= 0;
		public static const HANDLE_TYPE_AREA:int						= 1;
		public static const HANDLE_TYPE_AREA_RESIZE:int					= 2;
		public static const HANDLE_TYPE_ELEVATION:int					= 3;
		public static const HANDLE_TYPE_ELEVATION_CONTROL:int			= 4;
		public static const HANDLE_TYPE_ELEVATION_POSITION_CONTROL:int	= 5;
		
		// What axis to use when updating position.
		public static const CONTROL_AXIS_ALL:uint	= 0;
		public static const CONTROL_AXIS_X:uint		= 1;
		public static const CONTROL_AXIS_Y:uint		= 2;
		public static const CONTROL_AXIS_Z:uint		= 3;
		public static const CONTROL_AXIS_XZ:uint	= 4;
		
		// Handle point to control.
		public static const P_NONE:int = -1;
		public static const P_START:int = 0;
		public static const P_CONTROL:int = 1;
		public static const P_END:int = 2;
		
		public function HandleLibrary()
		{
		}
	}
}