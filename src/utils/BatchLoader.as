package src.utils
{
	import flash.events.ProgressEvent;
	import flash.utils.Timer;
	
	import src3d.SSPEvent;
	import src3d.utils.EventHandler;

	public class BatchLoader extends FileLoader
	{
		private var loader:FileLoader = new FileLoader();
		private var loaderEventHandler:EventHandler = new EventHandler(loader);
		
		private var vItems:Vector.<BatchLoaderItem>;
		private var currentItem:BatchLoaderItem;
		
		private var fileIdx:int;
		
		private var loadStarted:Boolean;
		private var hasErrors:Boolean;
		
		public function BatchLoader()
		{
			super();
		}
		
		public function add(location:String, index:int, asDisplayObject:Boolean, asBinary:Boolean = false):void {
			if (!location || location == "") return;
			if (!vItems) vItems = new Vector.<BatchLoaderItem>();
			vItems.push(new BatchLoaderItem(location, index, asDisplayObject, asBinary));
		}
		
		public function start():void {
			if (loadStarted) return;
			stop();
			if (!vItems || vItems.length == 0) {
				hasErrors = true;
				this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.ALL_COMPLETE, hasErrors));
				return;
			}
			loadStarted = true;
			loaderEventHandler.addEventListener(SSPEvent.SUCCESS, onFileLoadOK);
			loaderEventHandler.addEventListener(SSPEvent.ERROR, onFileLoadError);
			checkProgress();
		}
		
		public function stop():void {
			loaderEventHandler.RemoveEvents();
			currentItem = null;
			fileIdx = -1;
			hasErrors = false;
			loadStarted = false;
		}
		
		private function checkProgress():void {
			fileIdx++;
			if (fileIdx < vItems.length) {
				currentItem = vItems[fileIdx];
				loader.loadFile(currentItem.location, currentItem.asDisplayObject, currentItem.asBinary, true);
			} else {
				this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.ALL_COMPLETE, hasErrors));
				stop();
				vItems = null;
			}
		}
		
		private function onFileLoadOK(e:SSPEvent):void {
			this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.FILE_COMPLETE, {index:fileIdx, item:currentItem, data:e.eventData}));
			checkProgress();
		}
		
		private function onFileLoadError(e:SSPEvent):void {
			hasErrors = true;
			this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.FILE_ERROR, {message:e.eventData, item:currentItem}));
			checkProgress();
		}
		
		private function onFileLoadProgress(e:ProgressEvent):void {
			this.dispatchEvent(new BatchLoaderEvent(BatchLoaderEvent.FILE_PROGRESS, {event:e, item:currentItem}));
		}
		
		public function get totalFiles():int {
			var total:int = (vItems)? vItems.length : 0;
			return total;
		}
	}
}