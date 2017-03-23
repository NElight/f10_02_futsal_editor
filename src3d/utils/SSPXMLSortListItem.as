package src3d.utils
{
	public class SSPXMLSortListItem
	{
		private var _elementName:String;
		private var _sortByName;
		public function SSPXMLSortListItem(elementName:String, sortByName:String)
		{
			_elementName = elementName;
			_sortByName = sortByName;
		}

		public function get elementName():String
		{
			return _elementName;
		}

		public function get sortByName()
		{
			return _sortByName;
		}


	}
}