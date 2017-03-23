package src.utils
{
	public class BatchLoaderItem
	{
		public var location:String;
		public var index:int;
		public var asDisplayObject:Boolean;
		public var asBinary:Boolean;
		
		public function BatchLoaderItem(location:String, index:int, asDisplayObject:Boolean, asBinary:Boolean)
		{
			this.location = location;
			this.index = index;
			this.asDisplayObject = asDisplayObject;
			this.asBinary = asBinary;
		}
	}
}