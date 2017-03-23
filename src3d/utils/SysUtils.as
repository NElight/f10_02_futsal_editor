package src3d.utils
{
	import flash.system.Capabilities;
	import flash.system.System;
	
	import src3d.SessionGlobals;

	public class SysUtils
	{
		private var sG:SessionGlobals = SessionGlobals.getInstance();
		
		public function SysUtils()
		{
		}
		
		/**
		 * Stores System Info in sessionGlobals. 
		 */		
		public function storeSystemInfo():Boolean {
			try {
				var processorType:String = "";
				if (Capabilities.supports32BitProcesses) processorType = "32bit";
				if (Capabilities.supports64BitProcesses) processorType = "64bit";
				
				// Get the player’s version by using the flash.system.Capabilities class.
				var versionNumber:String = Capabilities.version;
				// The version number is a list of items divided by ","
				var versionArray:Array = versionNumber.split(",");
				// The main version contains the OS type too so we split it in two
				// and we’ll have the OS type and the major version number separately.
				var platformAndMayorVersion:Array = versionArray[0].split(" ");
				// Get the player's version and full version.
				var platformAndVersion:Array = versionNumber.split(" ");
				
				sG.clientFlashFullVersion = versionNumber;
				sG.clientFlashVersion = platformAndVersion[1];
				sG.clientPlatform = platformAndVersion[0];
				sG.clientFlashVersionMayor = parseInt(platformAndVersion[1]);
				sG.clientFlashVersionMinor = parseInt(versionArray[1]);
				sG.clientFlashVersionBuid = parseInt(versionArray[2]);
				
				sG.clientPlayerType = Capabilities.playerType;
				sG.clientOS = Capabilities.os;
				sG.clientProcessorType = processorType;
				sG.clientBrowserLanguage = Capabilities.language;
				sG.clientRAM = getSystemRAM();
				sG.clientScreen = Capabilities.screenResolutionX+"x"+Capabilities.screenResolutionY;
				sG.clientCPUArchitecture = Capabilities.cpuArchitecture;
			} catch (e:Error) {
				return false;
			}
			return true;
		}
		
		public function getSystemRAM():String {
			return ""+int(System.totalMemory/1024/102.4)/10+"/"+int(System.privateMemory/1024/102.4)/10+"Mb";
		}
	}
}