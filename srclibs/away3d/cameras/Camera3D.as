package away3d.cameras
{
	import away3d.arcane;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * Dispatched when the focus or zoom properties of a camera update.
	 * 
	 * @eventType away3d.events.CameraEvent
	 * 
	 * @see #focus
	 * @see #zoom
	 */
	[Event(name="cameraUpdated",type="away3d.events.CameraEvent")]
	
	/**
	 * Basic camera used to resolve a view.
	 * 
	 * @see	away3d.containers.View3D
	 */
    public class Camera3D extends Object3D
    {
    	private var _fovDirty:Boolean;
    	private var _zoomDirty:Boolean;
        private var _aperture:Number = 22;
    	private var _dof:Boolean = false;
        private var _flipY:Matrix3D = new Matrix3D();
        private var _focus:Number;
        private var _zoom:Number = 10;
        private var _lens:AbstractLens;
        private var _fov:Number = 0;
        private var _clipping:Clipping;
        private var _clipTop:Number;
        private var _clipBottom:Number;
        private var _clipLeft:Number;
        private var _clipRight:Number;
    	private var _viewMatrix:Matrix3D = new Matrix3D();
    	private var _view:View3D;
    	private var _cameraVarsStore:CameraVarsStore;
    	private var _verts:Vector.<Number>;
    	private var _screenVertices:Vector.<Number> = new Vector.<Number>();
    	private var _screenUVs:Vector.<Number> = new Vector.<Number>();
		private var _cameraupdated:CameraEvent;
		
        private function notifyCameraUpdate():void
        {
            if (!hasEventListener(CameraEvent.CAMERA_UPDATED))
                return;
			
            if (_cameraupdated == null)
                _cameraupdated = new CameraEvent(CameraEvent.CAMERA_UPDATED, this);
                
            dispatchEvent(_cameraupdated);
        }
        
        protected const toRADIANS:Number = Math.PI/180;
		protected const toDEGREES:Number = 180/Math.PI;
		
    	public var invViewMatrix:Matrix3D = new Matrix3D();
        
		public var fixedZoom:Boolean;
		
		/**
		 * Used in <code>DofSprite3D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite3D
		 */
		public function get aperture():Number
		{
			return _aperture;
		}
		
		public function set aperture(value:Number):void
		{
			_aperture = value;
			DofCache.aperture = _aperture;
		}
        
		/**
		 * Used in <code>DofSprite3D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite3D
		 */
		public function get dof():Boolean
		{
			return _dof;
		}
		
		public function set dof(value:Boolean):void
		{
			_dof = value;
			if (_dof)
				enableDof();
			else
				disableDof();
		}		
		/**
		 * A divisor value for the perspective depth of the view.
		 */
		public function get focus():Number
		{
			return _focus;
		}
		
		public function set focus(value:Number):void
		{
			if (_focus == value)
				return;
			
			_focus = value;			
			DofCache.focus = _focus;
			
			_zoomDirty = false;
			_fovDirty = true;
			
			notifyCameraUpdate();
		}
		
		/**
		 * Provides an overall scale value to the view
		 */
		public function get zoom():Number
		{
			return _zoom;
		}
		
		public function set zoom(value:Number):void
		{
			if (_zoom == value)
				return;
			
			_zoom = value;
			
			_zoomDirty = false;
			_fovDirty = true;
			
			notifyCameraUpdate();
		}
		
		/**
		 * Defines a lens object used in vertex projection
		 */
		public function get lens():AbstractLens
		{
			return _lens;
		}
		
		public function set lens(value:AbstractLens):void
		{
			if (_lens == value)
				return;
			
			_lens = value;
			
			notifyCameraUpdate();
		}
		
		/**
		 * Defines the field of view of the camera in a vertical direction.
		 */
		public function get fov():Number
		{
			return _fov;
		}
		
		public function set fov(value:Number):void
		{
			if (_fov == value)
				return;
			
			_fov = value;
			
			_fovDirty = false;
			_zoomDirty = true;
			
			notifyCameraUpdate();
		}
		
		/**
		 * Used in <code>DofSprite3D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite3D
		 */
        public var maxblur:Number = 150;
        
        /**
		 * Used in <code>DofSprite3D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite3D
		 */
        public var doflevels:Number = 16;
        
        public function get view():View3D
        {
        	return _view;
        }
        public function set view(val:View3D):void
        {
        	if (_view == val)
        		return;
        	
        	_view = val;
        	_cameraVarsStore = val.cameraVarsStore;
        }
        
		/**
		 * Returns the transformation matrix used to resolve the scene to the view.
		 * Used in the <code>ProjectionTraverser</code> class
		 * 
		 * @see	away3d.core.traverse.ProjectionTraverser
		 */
        public function get viewMatrix():Matrix3D
        {
        	invViewMatrix.rawData = sceneTransform.rawData;
        	invViewMatrix.prepend(_flipY);
        	
        	_viewMatrix.rawData = invViewMatrix.rawData;
        	_viewMatrix.invert();
        	
        	return _viewMatrix;
        }
    	
		/**
		 * Creates a new <code>Camera3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Camera3D(init:Object = null)
        {
            super(init);
            
            fov = ini.getNumber("fov", _fov);
            focus = ini.getNumber("focus", 100);
            zoom = ini.getNumber("zoom", _zoom);
            fixedZoom = ini.getBoolean("fixedZoom", true);
            lens = ini.getObject("lens", AbstractLens) as AbstractLens || new ZoomFocusLens();
            aperture = ini.getNumber("aperture", 22);
            maxblur = ini.getNumber("maxblur", 150);
	        doflevels = ini.getNumber("doflevels", 16);
            dof = ini.getBoolean("dof", false);
            
            var lookat:Vector3D = ini.getPosition("lookat");
			
			_flipY.appendScale(1, -1, 1);
			
            if (lookat)
                lookAt(lookat);
        }
        
        /**
		 * Used in <code>DofSprite3D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite3D
		 */
        public function enableDof():void
        {
        	DofCache.doflevels = doflevels;
          	DofCache.aperture = aperture;
        	DofCache.maxblur = maxblur;
        	DofCache.focus = focus;
        	DofCache.resetDof(true);
        }
                
        /**
		 * Used in <code>DofSprite3D</code>
		 * 
		 * @see	away3d.sprites.DofSprite3D
		 */
        public function disableDof():void
        {
        	DofCache.resetDof(false);
        }
    	

    	
    	/**
    	 * Returns a <code>ScreenVertex</code> object describing the resolved x and y position of the given <code>Vertex</code> object.
    	 * 
    	 * @param	object	The local object for the Vertex. If none exists, use the <code>Scene3D</code> object.
    	 * @param	vertex	The vertex to be resolved.
    	 * 
    	 * @see	away3d.containers.Scene3D
    	 */
        public function screen(object:Object3D, vertex:Vertex = null):Vector3D
        {
        	update();
        	
            if (vertex == null)
                _verts = Vector.<Number>([0, 0, 0]);
            else
            	_verts = Vector.<Number>([vertex.x, vertex.y, vertex.z]);
            
            _cameraVarsStore.createViewTransform(object).rawData = viewMatrix.rawData;
            (_cameraVarsStore.viewTransformDictionary[object] as Matrix3D).prepend(object.sceneTransform);
            
			_screenVertices.length = 0;
			_screenUVs.length = 0;
            _lens.project(_cameraVarsStore.viewTransformDictionary[object], _verts, _screenVertices, _screenUVs);

			return new Vector3D(_screenVertices[uint(0)], _screenVertices[uint(1)], _lens.getScreenZ(_screenUVs[uint(2)]));
        }
    	        
		/**
		 * Updates the transformation matrix used to resolve the scene to the view.
		 * Used in the <code>BasicRender</code> class
		 * 
		 * @see	away3d.core.render.BasicRender
		 */
        public function update():void
        {
        	_view.updateScreenClipping();
        	
        	_clipping  = _view.screenClipping;
        	
        	if (_clipTop != _clipping.minY || _clipBottom != _clipping.maxY || _clipLeft != _clipping.minX || _clipRight != _clipping.maxX) {
        		
        		if (!_fovDirty && !_zoomDirty) {
	        		if (fixedZoom)
		        		_fovDirty = true;
		        	else
		        		_zoomDirty = true;
		        }
		        
	        	_clipTop = _clipping.minY;
	        	_clipBottom = _clipping.maxY;
	        	_clipLeft = _clipping.minX;
	        	_clipRight = _clipping.maxX;
        	}
        	
        	lens.setView(_view);
        	
        	if (_fovDirty) {
        		_fovDirty = false;
        		_fov = lens.getFOV();
        	}
        	
        	if (_zoomDirty) {
        		_zoomDirty = false;
        		_zoom = lens.getZoom();
        	}
        }
        
		/**
		 * Rotates the camera in its vertical plane.
		 * 
		 * Tilting the camera results in a motion similar to someone nodding their head "yes".
		 * 
		 * @param	angle	Angle to tilt the camera.
		 */
        public function tilt(angle:Number):void
        {
            super.pitch(angle);
        }
    	
		/**
		 * Rotates the camera in its horizontal plane.
		 * 
		 * Panning the camera results in a motion similar to someone shaking their head "no".
		 * 
		 * @param	angle	Angle to pan the camera.
		 */
        public function pan(angle:Number):void
        {
            super.yaw(angle);
        }
		
		/**
		 * Duplicates the camera's properties to another <code>Camera3D</code> object.
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied.
		 * @return						The new object instance with duplicated properties applied.
		 */
        public override function clone(object:Object3D = null):Object3D
        {
            var camera:Camera3D = (object as Camera3D) || new Camera3D();
            super.clone(camera);
            camera.zoom = zoom;
            camera.focus = focus;
            camera.lens = lens;
            return camera;
        }
		
		public function unproject(mX:Number, mY:Number):Vector3D
		{	
			var persp:Number = (focus*zoom) / focus;
			var vector:Vector3D = new Vector3D(mX/persp, -mY/persp, focus);
			vector = transform.deltaTransformVector(vector);
			return vector;
		}
		
		/**
		 * Default method for adding a cameraUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnCameraUpdate(listener:Function):void
        {
            addEventListener(CameraEvent.CAMERA_UPDATED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a cameraUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnCameraUpdate(listener:Function):void
        {
            removeEventListener(CameraEvent.CAMERA_UPDATED, listener, false);
        }
    }
}
