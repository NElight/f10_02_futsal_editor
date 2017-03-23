package src.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.aszip.compression.CompressionMethod;
	import org.aszip.saving.Method;
	import org.aszip.zip.ASZip;
	
	import src3d.SSPEvent;
	import src3d.utils.Logger;
	
	public class FileSaverLocal extends EventDispatcher
	{
		private var logger:Logger = Logger.getInstance();
		
		private var fileRef:FileReference;
		private var aFiles:Vector.<FileSaverLocalItem>;
		private var isSaving:Boolean;
		
		public function FileSaverLocal()
		{
		}
		
		public function addFile(data:Object, location:String):void {
			if (!aFiles) aFiles = new Vector.<FileSaverLocalItem>();
			aFiles.push(new FileSaverLocalItem(data, location));
		}
		
		public function start():void {
			if (isSaving || !aFiles || aFiles.length == 0) return;
			if (aFiles.length == 1) {
				saveFileToLocal(aFiles[0].dataByteArray, aFiles[0].location);
			} else {
				saveZipToLocal();
			}
		}
		
		private function saveZipToLocal():void {
			logger.addText("Compressing...", false);
			var myZip:ASZip = new ASZip(CompressionMethod.GZIP);
			for (var i:uint=0;i<aFiles.length;i++) {
				myZip.addFile(aFiles[i].dataByteArray, aFiles[i].location);
			}
			var bA:ByteArray = myZip.saveZIP(Method.LOCAL);
			logger.addText("Done.", false);
			saveFileToLocal(bA, "my_session_data.zip");
		}
		
		private function saveFileToLocal(ba:ByteArray, location:String):void {
			logger.addText("Saving file to Local", false);
			if (!ba) {
				logger.addText("(A) - Can't get data to save to '"+location+"'.", false);
			} else {
				logger.addText("Data Size: "+Math.round(ba.length/1024)+"Kb", false);
			}
			
			if (fileRef) {
				fileRef.removeEventListener(Event.SELECT, onRefSelect);
				fileRef.removeEventListener(Event.CANCEL, onRefCancel);
			}
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, onRefSelect, false, 0, true);
			fileRef.addEventListener(Event.CANCEL, onRefCancel, false, 0, true);
			fileRef.save(ba, location);
		}
		
		private function onRefSelect(e:Event):void {
			//trace("File Saved to PC.");
			logger.addText("Saved.", false);
			fileRef.removeEventListener(Event.SELECT, onRefSelect);
			fileRef.removeEventListener(Event.CANCEL, onRefCancel);
			this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS));
		}
		
		private function onRefCancel(e:Event):void {
			//trace("Saving to PC Canceled.");
			logger.addText("(U) - Canceled.", false);
			fileRef.removeEventListener(Event.SELECT, onRefSelect);
			fileRef.removeEventListener(Event.CANCEL, onRefCancel);
			this.dispatchEvent(new SSPEvent(SSPEvent.CANCEL));
		}
	}
}