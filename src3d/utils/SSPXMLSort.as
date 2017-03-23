package src3d.utils
{
	public class SSPXMLSort
	{
		private static var sspSortList:SSPXMLSortList = new SSPXMLSortList();
		
		public function SSPXMLSort()
		{
		}
		
		public static function sortSSPXML(xml:XML):XMLList {
			if (!xml || xml.length() == 0) return new XMLList();
			var xmlList:XMLList = xml.copy().children();
			var newXMLList:XMLList;
			var tmpXMLList:XMLList; // For debugging purposes.
			var baseName:String = xml[0].localName();
			
			for (var i:int = 0; i<xmlList.length(); i++) {
				if (MiscUtils.xmlIsElement(xmlList[i])) {
					tmpXMLList = sortSSPXML(xmlList[i]);
					sortXMLListElementsById(tmpXMLList);
					xmlList[i] = tmpXMLList;
				}
			}
			
			var tmpXML:XML = new XML("<"+baseName+"/>");
			newXMLList = new XMLList(tmpXML);
			if (xmlList.length() > 1) {
				tmpXMLList = MiscUtils.sortXMLListByName(xmlList);
			} else {
				tmpXMLList = xmlList;
			}
			
			newXMLList[0].setChildren(tmpXMLList);
			return newXMLList;
		}
		
		private static function sortXMLListElementsById(xmlList:XMLList):void {
			var strElementName:String = "";
			var tmpXMLList:XMLList;
			var sortedXMLList:XMLList;
			var i:int
			var j:int;
			for (i = 0; i<sspSortList.list.length; i++) {
				strElementName = sspSortList.list[i].elementName;
				tmpXMLList = xmlList.children().(localName() == strElementName);
				sortedXMLList = MiscUtils.sortXMLList(tmpXMLList, sspSortList.list[i].sortByName, Array.NUMERIC);
				for (j = 0; j<tmpXMLList.length(); j++) {
					tmpXMLList[j] = sortedXMLList[j].copy();
				}
			}
		}
	}
}