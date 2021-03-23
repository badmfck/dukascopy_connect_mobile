package com.dukascopy.connect.screens.payments.settings {
	
	import assets.IconLimitDollar;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.payments.vo.AccountLimit;
	import com.dukascopy.connect.sys.payments.vo.AccountLimitVO;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ItemVerificationLimit extends Sprite {
		
		private const TF_PERCENTAGE:TextFormat = new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_SUBTITLE), null, null, null, null, null, TextFormatAlign.CENTER);
		private const TF_CURRENT_AMOUNT:TextFormat = new TextFormat(Config.defaultFontName, FontSize.AMOUNT, Color.GREEN, true, null, null, null, null, TextFormatAlign.CENTER);
		private const TF_MAX_AMOUNT:TextFormat = new TextFormat(Config.defaultFontName, FontSize.CAPTION_1, Style.color(Style.COLOR_SUBTITLE), null, null, null, null, null, TextFormatAlign.CENTER);
		
		private const RAD:Number = Math.PI / 180;
		
		private var title:Bitmap;
		private var graph:Shape;
		private var icon:Bitmap;
		private var percent:TextField;
		private var maxAmount:TextField;
		private var currAmount:TextField;
		private var resetDate:Bitmap;
		
		private var accLimitVO:AccountLimitVO;
		
		private var colorCircle:uint = Color.GREEN;
		private var _width:Number;
		private var _graphR:int;
		private var _offset:Number;
		private var description:Bitmap;
		
		public function ItemVerificationLimit(vo:AccountLimitVO) {
			accLimitVO = vo;
			
			if (accLimitVO.percent * .01 > .8) {
				colorCircle = Color.RED;
				TF_CURRENT_AMOUNT.color = Color.RED;
			}
			
			createView();
		}
		
		private function createView():void {
			title = new Bitmap();
			addChild(title);
			
			percent = new TextField();
			percent.multiline = false;
			percent.wordWrap = false;
			percent.defaultTextFormat = TF_PERCENTAGE;
			percent.text = "|";
			percent.height = percent.textHeight + 4;
			percent.text = "";
			percent.mouseEnabled = false;
			percent.selectable = false;
			addChild(percent);
			
			currAmount = new TextField();
			currAmount.multiline = false;
			currAmount.wordWrap = false;
			currAmount.defaultTextFormat = TF_CURRENT_AMOUNT;
			currAmount.text = "|";
			currAmount.height = currAmount.textHeight + 4;
			currAmount.text = "";
			currAmount.mouseEnabled = false;
			currAmount.selectable = false;
			addChild(currAmount);
			
			maxAmount = new TextField();
			maxAmount.multiline = false;
			maxAmount.wordWrap = false;
			maxAmount.defaultTextFormat = TF_MAX_AMOUNT;
			maxAmount.text = "|";
			maxAmount.height = maxAmount.textHeight + 4;
			maxAmount.text = "";
			maxAmount.mouseEnabled = false;
			maxAmount.selectable = false;
			addChild(maxAmount);
			
			resetDate = new Bitmap();
			addChild(resetDate);
			
			description = new Bitmap();
			addChild(description);
			
			drawIcon();
		}
		
		private function onInfoButtonClick():void {
			navigateToURL(new URLRequest("https://www.dukascopy.bank/swiss/faq/?lang=" + LangManager.model.getCurrentLanguageID() + "#faq03"));
		}
		
		private function drawIcon():void {
			var ico:DisplayObject = new IconLimitDollar();
			var myColorTransform:ColorTransform = new ColorTransform();
			myColorTransform.color = colorCircle;
			ico.transform.colorTransform = myColorTransform;
			ico.width = Config.FINGER_SIZE_DOT_5;
			ico.height = Config.FINGER_SIZE_DOT_5;
			if (icon == null) {
				icon = new Bitmap();
				addChild(icon);
			} else if (icon.bitmapData != null)
				UI.disposeBMD(icon.bitmapData);
			icon.bitmapData = UI.getSnapshot(ico, StageQuality.HIGH, "ImageFrames.frame");
			icon.smoothing = true;
		}
		
		private function setTexts():void {
			
			drawTitle(getTitleValue());
			drawDescription(getDescriptionValue());
			drawResetDate(getResetDateValue());
			
			percent.text = int(accLimitVO.percent) + "%";
			currAmount.text = "$ " + accLimitVO.current;
			maxAmount.text = Lang.textOf.toLowerCase() + " " + accLimitVO.maxLimit;
		}
		
		private function getResetDateValue():String 
		{
			if (accLimitVO.type != AccountLimit.TOTAL_EQUITY_USD) {
				return Lang.textResetDate + ": " +  accLimitVO.resetDate;
			}
			return null;
		}
		
		private function drawResetDate(text:String):void 
		{
			if (resetDate.bitmapData != null)
			{
				resetDate.bitmapData.dispose();
				resetDate.bitmapData = null;
			}
			if (text != null)
			{
				resetDate.bitmapData = TextUtils.createTextFieldData(text, 
																_width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
			}
		}
		
		private function drawDescription(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			description.bitmapData = TextUtils.createTextFieldData(text, 
																_width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.BODY, true, Style.color(Style.COLOR_SUBTITLE));
		}
		
		private function drawTitle(text:String):void 
		{
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(text, 
																_width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
		}
		
		private function getTitleValue():String 
		{
			var result:String = "";
			switch (accLimitVO.type) {
				case AccountLimit.TOTAL_EQUITY_USD : {
					return Lang.TOTAL_EQUITY_USD;
					break;
				}
				case AccountLimit.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q : {
					return Lang.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q;
					break;
				}
			}
			return "";
		}
		
		private function getDescriptionValue():String 
		{
			var result:String = "";
			switch (accLimitVO.type) {
				case AccountLimit.TOTAL_EQUITY_USD : {
					return Lang.totalLimitDescription;
					break;
				}
				case AccountLimit.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q : {
					return Lang.quarterLimitDescription;
					break;
				}
			}
			return "";
		}
		
		public function setWidthAndHeight(width:int, obligatory:Boolean = false):void {
			if (_width == width)
				return;
			_width = width;
			_graphR = _width * .225;
			
			setTexts();
			
			percent.width = currAmount.width = maxAmount.width = _graphR * 2;
			
			drawCirclesComponents(accLimitVO.percent * .01);
			updatePositions();
		}
		
		private function drawCirclesComponents(percent:Number):void {
			if (graph == null) {
				graph = new Shape();
				addChild(graph);
			} else
				graph.graphics.clear();
			var startAngle:Number = -250 * RAD;
			graph.graphics.lineStyle(1, colorCircle);
			BaseGraphicsUtils.drawCircleSegment(graph.graphics, new Point(0, 0), startAngle, 70 * RAD, _graphR);
			graph.graphics.lineStyle(5, colorCircle);
			BaseGraphicsUtils.drawCircleSegment(graph.graphics, new Point(0, 0), startAngle, (320 * percent - 250) * RAD, _graphR);
		}
		
		private function updatePositions():void {
			
			var position:int = Config.DIALOG_MARGIN;
			
			title.x = Config.DIALOG_MARGIN;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .3;
			
			description.x = Config.DIALOG_MARGIN;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .3;
			
			if (resetDate.height > 0)
			{
				resetDate.x = Config.DIALOG_MARGIN;
				resetDate.y = position;
				position += resetDate.height + Config.FINGER_SIZE * .4;
			}
			
			graph.x = int((_width) * .5);
			graph.y = int(position + _graphR);
			
			icon.x = int(graph.x - Config.FINGER_SIZE_DOT_25);
			icon.y = int(graph.y + _graphR - Config.FINGER_SIZE_DOT_25);
			
			var insideHeight:int = percent.height + currAmount.height + maxAmount.height + Config.MARGIN * 3;
			
			percent.x = currAmount.x = maxAmount.x = int(graph.x - _graphR);
			
			percent.y = int(graph.y - insideHeight * .5);
			currAmount.y = int(percent.y + percent.height + Config.MARGIN * .9);
			maxAmount.y = int(currAmount.y + currAmount.height + Config.MARGIN * .5);
		}
		
		override public function get width():Number {
			return _width;
		}
		
		override public function set height(value:Number):void {
			super.height = value;
		}
		
		public function get offset():Number {
			if (isNaN(_offset) == true)
				_offset = _width * .05;
			return _offset;
		}
		
		public function dispose():void {
			if (parent != null)
				parent.removeChild(this);
			accLimitVO = null;
			if (currAmount != null)
				UI.destroy(currAmount);
			currAmount = null;
			if (percent != null)
				UI.destroy(percent);
			percent = null;
			if (maxAmount != null)
				UI.destroy(maxAmount);
			maxAmount = null;
			if (title != null)
				UI.destroy(title);
			title = null;
			if (resetDate != null)
				UI.destroy(resetDate);
			resetDate = null;
			if (icon != null)
				UI.destroy(icon);
			icon = null;
			if (graph != null)
				graph.graphics.clear();
			graph = null;
			if (description != null)
				UI.destroy(description);
			description = null;
		}
	}
}