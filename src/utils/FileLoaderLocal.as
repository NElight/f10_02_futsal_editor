package src.utils
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import src3d.SSPEvent;
	
	public class FileLoaderLocal extends EventDispatcher
	{
		public static const FILTER_TYPE_IMAGES:Object = {description:"Images: (*.jpg, *.jpeg, *.png, *.gif)", extension:"*.jpg; *.jpeg; *.png; *.gif;"};
		
		private var fileRef:FileReference;
		private var loadStarted:Boolean;
		
		public function FileLoaderLocal(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function start(fileFilterType:Object):void {
			if (loadStarted || !fileFilterType || !fileFilterType.description || !fileFilterType.extension) return;
			loadStarted = true;
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, onFileSelect);
			var fileFilter:FileFilter = new FileFilter(fileFilterType.description, fileFilterType.extension);
			fileRef.browse([fileFilter]);
		}
		
		private function onFileSelect(e:Event):void {
			fileRef.removeEventListener(Event.SELECT, onFileSelect);
			fileRef.addEventListener(Event.CANCEL, onDataCancel);
			fileRef.addEventListener(Event.COMPLETE, onDataComplete);
			fileRef.load();
		}
		
		private function onDataCancel(e:Event):void {
			fileRef.removeEventListener(Event.COMPLETE, onDataComplete);
			fileRef.removeEventListener(Event.CANCEL, onDataCancel);
			loadStarted = false;
			this.dispatchEvent(new SSPEvent(SSPEvent.CANCEL));
		}
		
		private function onDataComplete(e:Event):void {
			fileRef.removeEventListener(Event.COMPLETE, onDataComplete);
			fileRef.removeEventListener(Event.CANCEL, onDataCancel);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.loadBytes(fileRef.data);
		}
		
		private function onLoadComplete(event:Event):void {
			var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
			loaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loadStarted = false;
			this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS, loaderInfo.content));
		}
	}
}