package src3d.utils
{
	public class SSPXMLSortList
	{
		public var list:Vector.<SSPXMLSortListItem>;
		
		public function SSPXMLSortList()
		{
			list = Vector.<SSPXMLSortListItem>([
				new SSPXMLSortListItem("kit", "_kitId"),
				new SSPXMLSortListItem("lines_library", "_linesLibraryId"),
				new SSPXMLSortListItem("screen", "_screenId"),
				new SSPXMLSortListItem("equipment", "_equipmentLibraryId"),
				new SSPXMLSortListItem("player", "_playerLibraryId"),
				new SSPXMLSortListItem("line", "_linesLibraryId"),
				new SSPXMLSortListItem("text", "_textLibraryId")
			]);
		}
		
		public function getSortByName(elementName:String):String {
			var strSortBy:String = "";
			for (var i:int = 0; i<list.length; i++) {
				if (elementName == list[i].elementName) strSortBy = list[i].sortByName;
			}
			return strSortBy;
		}
	}
}