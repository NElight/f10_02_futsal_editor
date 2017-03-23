package src.controls.gallery
{
	import fl.controls.CheckBox;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	import src.SSPLogo;
	
	import src3d.utils.ColorUtils;
	import src3d.utils.MiscUtils;
	
	public class Thumbnail extends ThumbnailButton
	{
		protected var textSize:Number = 11
		protected var textH:Number = 32;
		protected var textDurationW:Number = 35;
		protected var textDurationH:Number = 17;
		protected var strEmpty = "";
		
		protected var txtTitle:TextField;
		protected var txtDetails:TextField;
		
		public function Thumbnail(thumbW:Number = 90, thumbH:Number = 90, selectable:Boolean = false)
		{
			super(thumbW, thumbH-textH, selectable, thumbW, thumbH);
		}
		
		protected override function createControls():void {
			super.createControls();
			txtDetails = MiscUtils.createNewTextField(0, thumbH - textDurationH, thumbW, textDurationH, TextFieldType.DYNAMIC, false, false, false, textSize, 0xFFFFFF, 10, false, true, TextFormatAlign.RIGHT);
			var outline:GlowFilter=new GlowFilter(0,1,3,3,10);
			outline.quality=BitmapFilterQuality.LOW;
			txtDetails.filters=[outline];
			this.addChild(txtDetails);
			txtTitle = MiscUtils.createNewTextField(0, thumbH,  thumbW, textH, TextFieldType.DYNAMIC, false, true, false, textSize, 0, 100, false, true, TextFormatAlign.CENTER);
		}
		
		protected override function addControls():void {
			this.addChild(bgSelect);
			this.addChild(bg);
			this.addChild(txtTitle);
			this.addChild(btnArea);
		}
		
		public function updateThumbnailText(strTitle:String, strDetails:String = ""):void {
			txtTitle.text = (strTitle && strTitle != "")? strTitle : strEmpty;
			if (strDetails && strDetails != "") {
				txtDetails.text = "("+strDetails+")";
				txtDetails.visible = true;
			} else {
				txtDetails.text = "";
				txtDetails.visible = false;
			}
		}
		
		public override function showThumb(bmp:Bitmap = null):void {
			super.showThumb(bmp);
			this.setChildIndex(txtDetails, this.numChildren-1);
			if (this.selectable && cbxSelect) this.setChildIndex(cbxSelect, this.numChildren-1);
			this.setChildIndex(btnArea, this.numChildren-1);
		}
	}
}