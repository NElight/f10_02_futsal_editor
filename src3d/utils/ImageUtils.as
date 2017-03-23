package src3d.utils
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class ImageUtils
	{
		public function ImageUtils()
		{
		}
		
		/**
		 * Resize an image to fit in a specified DisplayObjectContainer.
		 * The difference with <code>fitImage</code> is that it includes the DisplayObjectContainer scale.
		 * @param srcImg Bitmap. The image to fit in the movieclip.
		 * @param destObj DisplayObjectContainer. The target container (Eg. a movieclip).
		 * @param centerImage Boolean. Indicate if the image will be centered in the target container.
		 * @param destPadding Number. Target container's padding (0 = no padding).
		 * @param resampleBmd. Boolean. If set to True, a new BitmapData is created for the new image and then resampled.
		 * If set to False, the BitmapData object is not modified and the Bitmap object is resized. 
		 * @return A new Bitmap from the source provided, scaled to fit in the specified container.
		 * @see <code>fitImage</code>
		 * 
		 */		
		public static function fitImageForContainer(srcImg:Bitmap, destObj:DisplayObjectContainer, centerImage:Boolean = false, destPadding:Number = 0, resampleBmd:Boolean = false):Bitmap {
			//var targetWidth:Number = destObj.width/destObj.scaleX-(destPadding*2);
			//var targetHeight:Number = destObj.height/destObj.scaleY-(destPadding*2);
			var targetWidth:Number = destObj.width/destObj.scaleX;
			var targetHeight:Number = destObj.height/destObj.scaleY;
			var destW:Number = targetWidth - (destPadding*2); // Apply padding.
			var destH:Number = targetHeight - (destPadding*2); // Apply padding.
			var newBmp:Bitmap = fitImage(srcImg, destW, destH, resampleBmd);
			if (centerImage) {
				newBmp.x = (destW - newBmp.width)/2+destPadding;
				newBmp.y = (destH - newBmp.height)/2+destPadding;
			}
			return newBmp;
		}
		
		/**
		 * Resize an image to make it fit in the specified dimensions, while keeping the aspect ratio.
		 * Not that resampleBmd = True, will create a new Bitmap object with new BitmapData.
		 * resampleBmd = False, will produce a new Bitmap object, but keeping the same BitmapData.
		 * Note that this function does not modify the source bmp, it returns a copy of the provided bitmap. 
		 * @param srcImg Bitmap. The image to fit.
		 * @param destW Number. Destination Width.
		 * @param destH Number. Destination Height.
		 * @param resampleBmd. Boolean. If set to True, a new BitmapData is created for the new image and then resampled.
		 * If set to False, the BitmapData object is not modified and the Bitmap object is resized. 
		 * @return A new Bitmap from the source provided, scaled as specified.
		 * @see <code>fitImageForContainer</code>
		 * 
		 */		
		public static function fitImage(srcImg:Bitmap, destW:Number, destH:Number, resample:Boolean):Bitmap {
			if (!srcImg || !srcImg.bitmapData) return new Bitmap();
			var newBmd:BitmapData;
			var newImage:Bitmap;
			var ratio:Number = srcImg.width/srcImg.height; // Get the image aspect ratio.
			var newW:Number;
			var newH:Number;
			var srcLandscape:Boolean = (ratio > 1)? true : false;
			var destLandscape:Boolean = (destW > destH)? true : false;
			
			// If destination is landscape.
			if (destLandscape) {
				// Fit to width.
				newW = destW;
				newH =  Math.round(destW/ratio);
				if (newH > destH) {
					// Fit to height.
					newH = destH;
					newW = Math.round(destH*ratio);
				}
			} else {
				// Fit to height.
				newH = destH;
				newW = Math.round(destH*ratio);
				if (newW > destW) {
					// Fit to width.
					newW = destW;
					newH =  Math.round(destW/ratio);
				}
			}
			
			if (resample) {
				newBmd = resampleBmd(srcImg.bitmapData.clone(), newW, newH);
				newImage = new Bitmap(newBmd, PixelSnapping.NEVER, true);
			} else {
				newImage = new Bitmap(srcImg.bitmapData, PixelSnapping.NEVER, true);
				newImage.width = newW;
				newImage.height = newH;
			}
			return newImage;
		}
		
		/**
		 * Returns a new BitmapData object of the specified size. The source BitmapData object is not modified.
		 * Note that this method doesn't use any antialias or smoothing. To get that, create the Bitmap object like this:
		 * var bmp:Bitmap = new Bitmap(resizedBitmapData, PixelSnapping.NEVER, true);
		 * @param bmd BitmapData.
		 * @param newWidth Number.
		 * @param newHeight Number.
		 * @return BitmapData.
		 */		
		public static function resizeBmd(bmd:BitmapData, newWidth:Number, newHeight:Number):BitmapData {
			if (isNaN(newWidth) || newWidth < 0) newWidth = 1;
			if (isNaN(newHeight) || newHeight < 0) newWidth = 1;
			var scaleX:Number = Math.abs(newWidth / bmd.width);
			var scaleY:Number = Math.abs(newHeight / bmd.height);
			var transparent:Boolean = bmd.transparent;
			var newBmd:BitmapData = new BitmapData(newWidth, newHeight, transparent);
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleX, scaleY);
			newBmd.draw(bmd, matrix, null, null, null, true);
			return newBmd;
		}
		
		public static function resampleBmd(bmd:BitmapData, newW:uint, newH:uint):BitmapData
		{
			const scaleDrop:Number = .5;
			var finalScale:Number = Math.min(newW/bmd.width, newH/bmd.height);
			var finalData:BitmapData = bmd;
			
			if (finalScale > 1) {
				/*finalData = new BitmapData(bmd.width*finalScale, bmd.height*finalScale, true, 0);
				finalData.draw(bmd, new Matrix(finalScale, 0, 0, finalScale), null, null, null, true);
				return finalData;*/
				finalData = resizeBmd(bmd, bmd.width*finalScale, bmd.height*finalScale);
			}
			
			var initialScale:Number = finalScale;
			while (initialScale/scaleDrop <1) initialScale /= scaleDrop;
			
			/*var bd:BitmapData = new BitmapData(Math.ceil(bmd.width*initialScale), Math.ceil(bmd.height*initialScale));
			bd.draw(finalData, new Matrix(initialScale, 0, 0, initialScale), null, null, null, true);
			finalData = bd;*/
			
			finalData = resizeBmd(finalData, Math.ceil(bmd.width*initialScale), Math.ceil(bmd.height*initialScale));
			
			for (var scale:Number = initialScale*scaleDrop; Math.round(scale*1000)>= Math.round(finalScale*1000); scale *= scaleDrop) {
				/*bd = new BitmapData(Math.ceil(bmd.width*scale), Math.ceil(bmd.height*scale));
				bd.draw(finalData, new Matrix(scaleDrop, 0, 0, scaleDrop), null, null, null, true);
				finalData = bd;*/
				finalData = resizeBmd(finalData, Math.ceil(bmd.width*scale), Math.ceil(bmd.height*scale));
			}
			
			return finalData;
		}
		
		public static function bmdToJPG(bmd:BitmapData, encQuality:uint = 60):ByteArray {
			if (encQuality > 100) encQuality = 100;
			var jpgEncoder:JPGEncoder = new JPGEncoder(encQuality);
			var jpgData:ByteArray = jpgEncoder.encode(bmd);
			return jpgData;
		}
	}
}