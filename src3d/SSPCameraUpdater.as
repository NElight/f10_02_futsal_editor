package src3d
{
	import src3d.models.soccer.pitches.PitchTarget;
	import src3d.models.soccer.pitches.PitchViewLibrary;
	import src3d.models.soccer.pitches.PitchViewSettings;
	import src3d.utils.Logger;

	public class SSPCameraUpdater
	{
		public function SSPCameraUpdater()
		{
		}
		
		/**
		 * With some camera pan, tilt and angle combinations, View.render() can't detect if the camera is stopped.
		 * This causes the renderer works and use CPU when the right behaviour is to return the already renderer image.
		 * To avoid it, we have updated the PitchView default settings.
		 * This function will detect and udpate those values on session load.
		 * This class won't be needed when updating to Away3D 4.x.
		 * 
		 * @param sSXML
		 * @see PitchViewLibrary
		 * @see PitchViewSettings
		 * @see SessionLoader
		 */		
		public static function updatePitchTargets(sSXML:XML):void {
			if (!sSXML) return;
			
			//var camTarget:uint	= uint( sSXML._cameraTarget.text() );
			var camPanAngle:Number	= Number( sSXML._cameraPanAngle.text() );
			var camTiltAngle:Number	= Number( sSXML._cameraTiltAngle.text() );
			var camZoom:Number		= Number( sSXML._cameraZoom.text() );
			//var camFOV			= Number( sSXML._cameraFOV.text() );
			var strNewPanAngle:String;
			var strNewTiltAngle:String;
			var strNewZoom:String;
			
			var aPV:Vector.<PitchViewSettings> = PitchViewLibrary.getInstance().aPV;
			
			for (var i:int = 0; i<aPV.length; i++) {
				if ((camPanAngle == aPV[i].camOldPanAngle ||
					 camPanAngle == aPV[i].camOldPanAngleAlt) &&
					camTiltAngle == aPV[i].camOldTiltAngle &&
					camZoom == aPV[i].camOldZoom)
				{
					strNewPanAngle = (camPanAngle == aPV[i].camOldPanAngleAlt)? aPV[i].camPanAngleAlt.toFixed(2) : aPV[i].camPanAngle.toFixed(2);
					strNewTiltAngle = aPV[i].camTiltAngle.toFixed(2);
					strNewZoom = aPV[i].camZoom.toFixed(2);
					Logger.getInstance().addInfo("Updating Camera settings (pan|tilt|zoom) from: ("+
						camPanAngle.toFixed(2) + ", " +
						camTiltAngle.toFixed(2) + ", " +
						camZoom.toFixed(2) + ") to (" +
						strNewPanAngle + ", " +
						strNewTiltAngle + ", " +
						strNewZoom + ")."
					);
					sSXML._cameraPanAngle = strNewPanAngle;
					sSXML._cameraTiltAngle = strNewTiltAngle;
					sSXML._cameraZoom = strNewZoom;
					break;
				}
			}
		}
	}
}