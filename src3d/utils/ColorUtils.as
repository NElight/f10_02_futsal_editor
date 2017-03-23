package src3d.utils
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.PhongColorMaterial;
	import away3d.materials.WireColorMaterial;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	public class ColorUtils
	{
		public function ColorUtils()
		{
		}
		
		public static function hexColorToBW(col:uint):uint {
			var r = col >> 16;
			var g = col >> 8 & 0xFF;
			var b = col & 0xFF;
			
			var avrg:Number = (r + g + b) / 3;
			r = g = b = avrg;
			
			return (r<<16 | g<<8 | b);
		}
		
		public static function bmdToBW(bmd:BitmapData):BitmapData {
			const rc:Number = 1/3, gc:Number = 1/3, bc:Number = 1/3;
			bmd.applyFilter(	
				bmd,
				bmd.rect,
				new Point(),
				new ColorMatrixFilter([rc, gc, bc, 0, 0,rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0])
			);
			return bmd;
		}
		
		/**
		 * Tints a given BitmapData and returns the tinted BitmapData.
		 *  
		 * @param bmp BitmapData. The BitmapData to be tinted.
		 * @param col uint. The color to tint the bitmap.
		 * @param blend String. Default: BlendMode.MULTIPLY.
		 * @return BitmapData. The BitmapData of the tinted image.
		 * 
		 */		
		public static function colorBmp(bmd:BitmapData, col:uint, blend:String = BlendMode.MULTIPLY, bmdMask:BitmapData = null):BitmapData {
			var finalData:BitmapData = bmd.clone();
			var bmdColor:BitmapData;
			if (bmdMask != null) {
				bmdColor = new BitmapData(bmdMask.width,bmdMask.height,true,0);
				// Create alpha area.
				bmdColor.copyChannel(bmdMask,bmdMask.rect,new Point(),BitmapDataChannel.BLUE,BitmapDataChannel.ALPHA);
				bmdColor.floodFill(0,0,0xFFFFFF);
			} else {
				bmdColor = bmd.clone();
			}
			
			var colT:ColorTransform = new ColorTransform();
			colT.color = col;
			bmdColor.colorTransform(bmdColor.rect,colT);
			finalData.draw(bmdColor,null,null,blend);
			bmdColor = null;
			return finalData;
		}
		
		public static function colorObject(bm:Bitmap, col:uint):Bitmap {
			// Create a new bitmap. Do not modify the existing one.
			var bmp:Bitmap = new Bitmap();
			bmp.bitmapData = bm.bitmapData.clone();
			//var bmd:BitmapData = bmp.bitmapData;
			
			var cT:ColorTransform = bm.transform.colorTransform;
			cT.color = col;
			
			//bmp.bitmapData.colorTransform(bmp.bitmapData.rect,cT);
			bmp.transform.colorTransform = cT;
			cT = null;
			//bmd = null;
			return bmp;
		}
		
		/**
		 * Applies a WireColorMaterial to the specified mesh.
		 * If no mesh is given, it will apply it to all the meshes.
		 * @param id String. The mesh name to color.
		 * @param col uint. The color to apply.
		 * @param wireCol uint. The border color to apply.
		 * @param wireThick Number. The thickness of the border.
		 * @param objectSet Array. Set of objects to apply that color (Used mainly for LOD objects).
		 * 
		 */		
		public static function applyWireColorMaterialToMeshes(objectSet:Array, col:uint, wireCol:uint, wireThick:Number, id:String = ""):void {
			var mat:WireColorMaterial = new WireColorMaterial(col, {thickness:wireThick, wireColor:wireCol});
			for each(var p:Object in objectSet) {
				for each(var obj3d:Object3D in p.children) {
					var mesh:Mesh = obj3d as Mesh;
					if(mesh.name == id){
						// Applies the material only to the specified mesh.
						mesh.material = mat;
						break;
					}else {
						// Applies the material to all the meshes
						mesh.material = mat;
					}
				}
			}
		}
		
		/**
		 * Applies a ColorMaterial to the specified mesh.
		 * If no mesh is given, it will apply it to all the meshes.
		 * 
		 * @param objectSet Array. Set of objects to apply that color (Used mainly for LOD objects).
		 * @param col uint. The color to apply.
		 * @param al Number. Alpha.
		 * @param id String. The mesh name to color.
		 */		
		public static function applyColorMaterialToMeshes(objectSet:Array, col:uint, al:Number = 1, id:String = ""):void {
			var mat:ColorMaterial = new ColorMaterial(col, {alpha:al});
			for each(var p:Object in objectSet) {
				for each(var obj3d:Object3D in p.children) {
					var mesh:Mesh = obj3d as Mesh;
					if(mesh.name == id){
						// Applies the material only to the specified mesh.
						mesh.material = mat;
						break;
					}else {
						// Applies the material to all the meshes
						mesh.material = mat;
					}
				}
			}
		}
		
		/**
		 * Applies a phong color material to the specified mesh.
		 * Note that for awd files, you may need to import files with no texture maps
		 * to avoid conflicts with mesh names (eg: when exporting to .3ds with Max,
		 * uncheck 'preserve Max texture coordinates'.
		 * @param id String. The mesh name to color.
		 * @param col uint. The color to apply.
		 * @param objectSet Array. Set of objects to apply that color (Used mainly for LOD objects).
		 * 
		 */		
		public static function applyPhongColorMaterial(objectSet:Array, col:uint, id:String = ""):void {
			var mat:PhongColorMaterial = new PhongColorMaterial(col, {shininess:15, specular:1});
			for each(var p:Object in objectSet) {
				for each(var obj3d:Object3D in p.children) {
					var mesh:Mesh = obj3d as Mesh;
					if (mesh != null) {
						if(mesh.name == id){
							mesh.material = mat;
							break;
						}
					}
				}
			}
		}
		/**
		 * Applies a specific Bitmap material to a mesh.
		 * @param both Boolean. Enables bothSides rendering in the mesh.
		 * @param id String. The mesh name to apply the texture.
		 * @param bmd BitmapData. The texture to apply.
		 * @param objectSet Array. Set of objects to apply that color (Used mainly for LOD objects).
		 * 
		 */		
		public static function applyMaterialToMesh(objectSet:Array, bmd:BitmapData, id:String = "", both:Boolean = false, alpha:Number = 1):void {
			if(!bmd){
				trace("Embed of "+id+" failed! Check source path or if Flash call 911!");
				return;
			}
			var mat:BitmapMaterial = new BitmapMaterial(bmd);
			if (alpha < 1) mat.alpha = alpha;
			for each(var p:Object in objectSet) {
				for each(var obj3d:Object3D in p.children) {
					var mesh:Mesh = obj3d as Mesh;
					if (mesh != null) {
						//trace("//// "+mesh.name+" ////");
						if(mesh.name == id){
							mesh.material = mat;
							//trace(">> Material Applied to "+id);
							mesh.bothsides = (both)? true : false;
							break;
						} else {
							if (id == "") {
								mesh.material = mat;
								//trace(">> Material Applied to all meshes.");
								mesh.bothsides = (both)? true : false;
							}
						}
						
					}
				}
			}
		}
		
		public static function changeMaterialTransparency(objectSet:Array, alpha:Number):void {
			if (alpha > 1) alpha = 1;
			for each(var p:Object in objectSet) {
				for each(var obj3d:Object3D in p.children) {
					var mesh:Mesh = obj3d as Mesh;
					if (mesh != null) {
						if (mesh.material.hasOwnProperty("alpha")) {
							WireColorMaterial(mesh.material).alpha = alpha;
						}
					}
				}
			}
		}
		
		public static function applyBitmapMaterialToSingleObject(obj:ObjectContainer3D, mat:BitmapMaterial, id:String = "", both:Boolean = false, alpha:Number = 1):void {
			if(!mat){
				trace("Embed of "+id+" failed! Check source path or if Flash call 911!");
				return;
			}
			if (alpha < 1) mat.alpha = alpha;
			for each(var obj3d:Object3D in obj.children) {
				var mesh:Mesh = obj3d as Mesh;
				if (mesh != null) {
					//trace("//// "+mesh.name+" ////");
					if(mesh.name == id){
						mesh.material = mat;
						//trace(">> Material Applied to "+id);
						mesh.bothsides = (both)? true : false;
						break;
					} else {
						if (id == "") {
							mesh.material = mat;
							//trace(">> Material Applied to all meshes.");
							mesh.bothsides = (both)? true : false;
						}
					}
				}
			}
		}
		
		public static function createShape(xPos:Number, yPos:Number, sWidth:Number, sHeight:Number, sColor:uint = 0xFFFFFF, sAlpha:Number = 1):Shape {
			var newShape:Shape = new Shape();
			//newShape.graphics.lineStyle();
			newShape.graphics.beginFill(sColor,sAlpha);
			newShape.graphics.drawRect(xPos,yPos,sWidth,sHeight);
			newShape.graphics.endFill();
			return newShape;
		}
		
		public static function createShapeCircle(xPos:Number, yPos:Number, shapeRadius:Number, fillCol:uint, fillAlpha:Number, lineThickness:Number, lineCol:uint):Shape {
			var newShape:Shape = new Shape();
			if (lineThickness > 0) newShape.graphics.lineStyle(lineThickness, lineCol);
			newShape.graphics.beginFill(fillCol,fillAlpha);
			newShape.graphics.drawCircle(xPos,yPos,shapeRadius);
			newShape.graphics.endFill();
			return newShape;
		}
		
		public static function createSprite(xPos:Number, yPos:Number, sWidth:Number, sHeight:Number, sColor:uint = 0xFFFFFF, sAlpha:Number = 1, useBorder:Boolean = true, sBorderColor:uint = 0x000000, sBorderThickness:int = 1):Sprite {
			var newSprite:Sprite = new Sprite();
			if (useBorder) newSprite.graphics.lineStyle(sBorderThickness, sBorderColor);
			newSprite.graphics.beginFill(sColor,sAlpha);
			newSprite.graphics.drawRect(xPos,yPos,sWidth,sHeight);
			newSprite.graphics.endFill();
			return newSprite;
		}
		
		public static function getColorContrast(srcColor:uint, colA:uint = 0x111111, colB:uint = 0xFFFFFF):uint {
			var strHexColor:String = MiscUtils.getNumberAsHexString(srcColor, 6, false);
			var r = parseInt(strHexColor.substr(0,2),16);
			var g = parseInt(strHexColor.substr(2,2),16);
			var b = parseInt(strHexColor.substr(4,2),16);
			var yiq = ((r*299)+(g*587)+(b*114))/1000;
			return (yiq >= 128) ? colA : colB; // Instead of 0 for colA, use a higher value to allow blank space cropping in certain images.
		}
	}
}