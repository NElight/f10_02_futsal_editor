package src.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;
	import src3d.utils.EventHandler;
	import src3d.utils.SSPError;

	public class FileLoader extends EventDispatcher
	{
		private var loader:Loader = new Loader(); // For images and SWF. Loaded as Display Object.
		private var loaderHandler:EventHandler = new EventHandler(loader.contentLoaderInfo);
		private var urlLoader:URLLoader = new URLLoader(); // For text, xml and binary data access.
		private var urlLoaderHandler:EventHandler = new EventHandler(urlLoader);
		private var _pathURL:String;
		
		public function FileLoader()
		{
		}
		
		/**
		 * Load specified file. Note that this class does not allow bulk loading. Only one load at a time can be done.
		 * @param pathURL String. The file location.
		 * @param asDisplayObject. Boolean. TRUE to load SWF and images as a display object. FALSE to load text, xml or need to access to binary data.
		 * @param asBinary Boolean. Specify if the file has to be loaded as binary or text. This option is ignored if asDisplayObject is TRUE.
		 * @param urlReqHeaders Vector.<URLRequestHeader>. Specify a list of URLRequestHeaders if needed.
		 * @param useNewLoaderContext Boolean. Specify if a new LoaderContext should be used (only works with 'asDisplayObject = true').
		 * @param noCache Boolean. Use an 'anti-cache' var when loading the file.
		 */		
		public function loadFile(location:String, asDisplayObject:Boolean, asBinary:Boolean = false, noCache:Boolean = true, urlReqHeaders:Vector.<URLRequestHeader> = null, loaderContextParams:Object = null, newAppDomain:Boolean = false):void {
			unLoadAndStop();
			if (asDisplayObject) {
				loadDisplayObjectFile(location, noCache, urlReqHeaders, loaderContextParams, newAppDomain);
			} else {
				loadFileURL(location, asBinary, noCache, urlReqHeaders);
			}
		}
		
		public function unLoadAndStop():void {
			stopListeners();
			loader.unloadAndStop(true);
		}
		
		private function loadFileURL(location:String, asBinary:Boolean, noCache:Boolean = true, urlReqHeaders:Vector.<URLRequestHeader> = null):void {
			var urlReq:URLRequest;
			if (noCache) location = getNoCache(location);
			trace("Loading File as Text ("+location+")");
			urlReq = new URLRequest(location);
			if (urlReqHeaders && urlReqHeaders.length > 0) {
				for each (var rh:URLRequestHeader in urlReqHeaders) {
					if (rh) urlReq.requestHeaders.push(rh);
				}
			}
			urlLoaderHandler.addEventListener(Event.COMPLETE, onURLLoaderComplete, false, 0, true);
			urlLoaderHandler.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			urlLoaderHandler.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			urlLoaderHandler.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);
			urlLoaderHandler.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			urlLoader.dataFormat = (asBinary)? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
			urlLoader.load(urlReq);
		}
		
		private function loadDisplayObjectFile(location:String, noCache:Boolean = true, urlReqHeaders:Vector.<URLRequestHeader> = null, loaderContextParams:Object = null, newAppDomain:Boolean = false):void {
			var urlReq:URLRequest;
			var loaderContext:LoaderContext;
			if (noCache) location = getNoCache(location);
			trace("Loading File as Binary ("+location+")");
			urlReq = new URLRequest(location);
			if (urlReqHeaders && urlReqHeaders.length > 0) {
				for each (var rh:URLRequestHeader in urlReqHeaders) {
					if (rh) urlReq.requestHeaders.push(rh);
				}
			}
			if (loaderContextParams) {
				if (!loaderContext) loaderContext = new LoaderContext();
				loaderContext.parameters = loaderContextParams;
			}
			if (newAppDomain) {
				if (!loaderContext) loaderContext = new LoaderContext();
				loaderContext.applicationDomain = new ApplicationDomain();
			} else {
				if (loaderContext) loaderContext.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
			//if (useNewApplicationDomain) loaderContext = new LoaderContext(false, new ApplicationDomain());
			loaderHandler.addEventListener(Event.COMPLETE, onLoaderComplete, false, 0, true);
			loaderHandler.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			loaderHandler.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			loaderHandler.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);
			loaderHandler.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			loader.load(urlReq, loaderContext);
		}
		
		private function getNoCache(location:String):String {
			var strNoCache:String = "";
			var isLocal:Boolean = SessionGlobals.getInstance().isLocal;
			if (!isLocal) {
				strNoCache = (location.indexOf("?") == -1)? "?" : "&";
				strNoCache += "nocache=" + String(new Date().getTime());
			}
			return location + strNoCache;
		}
		
		private function onLoaderComplete(e:Event):void {
			trace("File loaded as Binary.");
			stopListeners();
			var objectData;
			try {
				objectData = e.currentTarget.content;
			} catch(error:Error) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, "Error accessing loaded data. Error ("+error.errorID+"): "+error.message));
				return;
			}
			if (!objectData) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, "Null data"));
			} else {
				this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS, objectData));
			}
		}
		
		private function onURLLoaderComplete(e:Event):void {
			trace("File loaded as Text.");
			stopListeners();
			var objectData;
			try {
				objectData = e.currentTarget.data;
			} catch(error:Error) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, "Error accessing loaded data. Error ("+error.errorID+"): "+error.message));
				return;
			}
			if (!objectData) {
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, "Null data"));
			} else {
				this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS, objectData));
			}
		}
		
		private function onIOError(e:IOErrorEvent) {
			stopListeners();
			trace("IOError: \n" + e);
			this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, "IOError Details: "+e.text));
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			stopListeners();
			trace("SecurityError: \n" + e);
			this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, "SecError Details: "+e.text));
		}
		private function onHTTPStatus(e:HTTPStatusEvent):void {
			if (!SessionGlobals.getInstance().isLocal) {
				if(e.status < 100) {
					trace("httpStatus (error): "+e);
					//this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR, "HTTPStatus: "+e.status.toString() )));
				} else if(e.status < 200) {
					trace("httpStatus (info): "+e);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPEvent.ERROR, "HTTPStatus: "+e.status.toString() )));
				} else if(e.status < 300) {
					trace("httpStatus (success): "+e);
				} else if(e.status < 400) {
					trace("httpStatus (redirection): "+e);
				} else if(e.status < 500) {
					trace("httpStatus (clientError): "+e);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPEvent.ERROR, "HTTPStatus: "+e.status.toString() )));
				} else if(e.status < 600) {
					trace("httpStatus (serverError): "+e);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPEvent.ERROR, "HTTPStatus: "+e.status.toString() )));
				}
			}
		}
		
		private function onProgress(e:ProgressEvent):void {
			this.dispatchEvent(e);
		}
		
		private function stopListeners():void {
			loaderHandler.RemoveEvents();
			urlLoaderHandler.RemoveEvents();
		}
	}
}