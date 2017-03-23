package src3d.models
{
	public class KitColorSettings
	{
		public var hair:uint;
		public var skin:uint;
		public var top:uint;
		public var bottom:uint;
		public var socks:uint;
		public var shoes:uint;
		
		public function KitColorSettings(hair = 0,skin = 0,top = 0,bottom = 0,socks = 0,shoes = 0)
		{
			this.hair = hair;
			this.skin = skin;
			this.top = top;
			this.bottom = bottom;
			this.socks = socks;
			this.shoes = shoes;
		}
	}
}