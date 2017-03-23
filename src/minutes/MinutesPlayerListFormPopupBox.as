package src.minutes
{
	import fl.controls.ScrollPolicy;
	import fl.data.DataProvider;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import src.controls.SSPList;
	import src.popup.PopupBox;
	
	import src3d.SessionGlobals;
	import src3d.utils.MiscUtils;
	
	public class MinutesPlayerListFormPopupBox extends PopupBox // 事件列表中开始事件后点击显示球员列表，弹框
	{
		// ----------------------------- Singleton ----------------------------- //
		// Singleton vars.
		private static var _self:MinutesPlayerListFormPopupBox;
		private static var _allowInstance:Boolean = false;
		
		public function MinutesPlayerListFormPopupBox(st:Stage)
		{
			initFormContent();
			var useHeader:Boolean = (formTitle != "")? true : false;
			super(st, formContent, formTitle, false, true, -1, -1, true, useHeader);
			
			if(!_allowInstance){
				throw new Error("You must use getInstance()");   
			}else{
				//trace("singleton class initialized.");
			}
		}
		
		public static function getInstance(st:Stage):MinutesPlayerListFormPopupBox
		{
			if(_self == null) {
				_allowInstance=true;
				_self = new MinutesPlayerListFormPopupBox(st);
				_allowInstance=false;
			} else {
				//trace("Returning existing instance");
			}
			return _self;
		}
		// -------------------------- End of Singleton ------------------------- //
		
		
		private var contentW:Number = 320;
		private var contentH:Number = 250;
		private var playerListOur:SSPList;
		private var playerListOpp:SSPList;
		private var formContent:MovieClip = new MovieClip();
		private var lblOur:TextField;
		private var lblOpp:TextField;
		private var listMargin:uint = 5;
		private var listRowHeight:uint = 20;
		private var lblSize:uint = 12;
		
		private function initFormContent():void {
			var tmpX:Number = 0;
			var tmpY:Number = 0;
			var colW:Number = contentW/2 - listMargin;
			var colH:Number = contentH;
			
			// Background.
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFFFFFF, 0);
			shape.graphics.drawRect(0, 0, contentW, contentH);
			shape.graphics.endFill();
			formContent.addChild(shape);
			
			// Labels.
			formTitle = SessionGlobals.getInstance().interfaceLanguageDataXML.buttons._btnMinutesPlayerList.text();
			var strLblOur:String = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titleTeamOurs.text();
			var strLblOpp:String = SessionGlobals.getInstance().interfaceLanguageDataXML.titles._titleTeamOpposition.text();
			if (strLblOur != "" || strLblOpp != "") {
				lblOur = MiscUtils.createNewLabel(tmpX, tmpY, colW, lblSize);
				lblOpp = MiscUtils.createNewLabel(tmpX, tmpY, colW, lblSize);
				lblOur.defaultTextFormat = new TextFormat(null,null,null,true,null,null,null,null,TextFormatAlign.CENTER);
				lblOpp.defaultTextFormat = new TextFormat(null,null,null,true,null,null,null,null,TextFormatAlign.CENTER);
				lblOur.text = strLblOur;
				lblOpp.text = strLblOpp;
				formContent.addChild(lblOur);
				formContent.addChild(lblOpp);
				tmpY += lblOur.height + listMargin;
			}
			
			// Our Player List.
			colH -= tmpY;
			playerListOur = new SSPList();
			playerListOur.height = colH;
			playerListOur.width = colW;
			playerListOur.rowHeight = listRowHeight;
			playerListOur.x = tmpX;
			playerListOur.y = tmpY;
			playerListOur.verticalScrollPolicy = ScrollPolicy.AUTO;
			playerListOur.horizontalScrollPolicy = ScrollPolicy.OFF;
			playerListOur.selectable = false;
			playerListOur.setStyle("cellRenderer", ListLineUpNameCellRenderer);
			formContent.addChild(playerListOur);
			
			// Opposition Player List.
			tmpX = playerListOur.x + playerListOur.width + listMargin*2;
			if (lblOpp) lblOpp.x = tmpX;
			playerListOpp = new SSPList();
			playerListOpp.height = colH;
			playerListOpp.width = colW;
			playerListOpp.rowHeight = listRowHeight;
			playerListOpp.x = tmpX;
			playerListOpp.y = tmpY;
			playerListOpp.verticalScrollPolicy = ScrollPolicy.AUTO;
			playerListOpp.horizontalScrollPolicy = ScrollPolicy.OFF;
			playerListOpp.selectable = false;
			playerListOpp.setStyle("cellRenderer", ListLineUpNameCellRenderer);
			formContent.addChild(playerListOpp);
		}
		
		public function set playerListOurTeam(value:DataProvider):void {
			playerListOur.dataProvider = value;
		}
		public function set playerListOppTeam(value:DataProvider):void {
			playerListOpp.dataProvider = value;
		}
		
	}
}