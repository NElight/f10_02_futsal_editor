package src.videos
{
	import src.controls.SSPSeekerBase;
	
	public class SSPVideoPlayerBarVolume extends SSPSeekerBase
	{
		public function SSPVideoPlayerBarVolume()
		{
			super();
			setSeeker(this.mcVideoVolumeMask);
		}
	}
}