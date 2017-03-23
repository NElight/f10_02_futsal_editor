package src3d.lines
{
	
	public class LineHandle extends HandleBase
	{
		public function LineHandle(handleIdx:int, handleControlPoint:int):void
		{
			super(handleIdx, handleControlPoint, HandleLibrary.HANDLE_TYPE_BASIC, new btn_line_handle());
		}
	}
}