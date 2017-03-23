package src.utils
{
	import flash.utils.ByteArray;

	public class FileSaverLocalItem
	{
		public var data:Object;
		public var location:String;
		
		public function FileSaverLocalItem(data:Object, location:String)
		{
			this.data = data;
			this.location = location;
		}
		
		public function get dataByteArray():ByteArray {
			var ba:ByteArray
			if (!data is ByteArray) {
				ba = getByteArray(String(data));
			} else {
				ba = data as ByteArray;
			}
			return ba;
		}
		
		private function getByteArray(strData:String):ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(strData);
			return ba;
		}
	}
}