package src.videos
{
	import src.controls.SSPSeekerBase;
	
	public class SSPVideoPlayerBarSeeker extends SSPSeekerBase
	{
		public function SSPVideoPlayerBarSeeker()
		{
			super();
			setSeeker(this.mcVideoSeekerCurrent);
		}
	}
}