package src3d.utils
{
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	
	import src3d.SSPEvent;
	import src3d.SessionGlobals;

	public class ObjectLoader extends EventDispatcher
	{
		private var loader:URLLoader;
		private var _pathURL:String;
		
		public function ObjectLoader()
		{
		}
		
		/**
		 * Loads a file from the specified path and returns the data inside the  event
		 * including the id you specified, which can be used to track the returned event
		 * when requesting several files.
		 * 
		 * @param pathURL String. The path or url to get the xml file.
		 * @param id String. An id name that will be included in the completed event
		 * to track the corresponding event when requesting several files at the same time.
		 * 
		 * @see <code>XMLLoaderEvent</code>
		 * 
		 */		
		public function loadXML(pathURL:String, noCache:Boolean = true) : void {
			trace("Loading XML ("+pathURL+")");
			var urlReq:URLRequest;
			var _noCacheVar:String = "";
			var isLocal:Boolean = SessionGlobals.getInstance().isLocal;
			loader = new URLLoader();
			if (!isLocal && noCache) {
				_noCacheVar = (pathURL.indexOf("?") == -1)? "?" : "&";
				_noCacheVar += "nocache=" + String(new Date().getTime());
			}
			urlReq = new URLRequest(pathURL+_noCacheVar);
				loader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
				loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);
				loader.load(urlReq);
		}
		
		private function onComplete(e:Event):void {
			trace("XML file loaded.");
			stopListeners();
			try {
				var objectData:XML = new XML(e.currentTarget.data);
				if(!objectData.session._sessionToken) {
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "Invalid XML")));
				}
			} catch (error:Error) {
				trace("Error getting data from file: "+e);
				this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, error.message)));
				return;
			}
			this.dispatchEvent(new SSPEvent(SSPEvent.SUCCESS, objectData));
		}
		
		private function onIOError(e:IOErrorEvent) {
			stopListeners();
			this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "IOError Details: "+e.text)));
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			stopListeners();
			trace("SecurityError: \n" + e);
			this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "SecError Details: "+e.text)));
		}
		private function onHTTPStatus(e:HTTPStatusEvent):void {
			if (!SessionGlobals.getInstance().isLocal) {
				if(e.status < 100) {
					trace("httpStatus (error): "+e);
					//this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "HTTPStatus: "+e.status.toString() )));
				} else if(e.status < 200) {
					trace("httpStatus (info): "+e);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "HTTPStatus: "+e.status.toString() )));
				} else if(e.status < 300) {
					trace("httpStatus (success): "+e);
				} else if(e.status < 400) {
					trace("httpStatus (redirection): "+e);
				} else if(e.status < 500) {
					trace("httpStatus (clientError): "+e);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "HTTPStatus: "+e.status.toString() )));
				} else if(e.status < 600) {
					trace("httpStatus (serverError): "+e);
					this.dispatchEvent(new SSPEvent(SSPEvent.ERROR, new SSPError(SSPError.ERROR_CODE_ID_300_LOADING_SESSION_DATA, "HTTPStatus: "+e.status.toString() )));
				}
			}
		}
		
		private function stopListeners():void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
		}
	}
}