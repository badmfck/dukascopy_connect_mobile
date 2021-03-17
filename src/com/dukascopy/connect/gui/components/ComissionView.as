package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ComissionView extends Sprite
	{
		private var totalTitle:Bitmap;
		private var totalValue:Bitmap;
		
		private var firstTitle:Bitmap;
		private var firstValue:Bitmap;
		
		private var lowTitle:Bitmap;
		private var lowValue:Bitmap;
		
		private var mainTitle:Bitmap;
		private var mainValue:Bitmap;
		private var componentsWidth:int;
		
		public function ComissionView() 
		{
			
		}
		
		public function dispose():void 
		{
			removeFirst();
			removeLowLiquidity();
			removeMain();
			removeTotal();
		}
		
		private function removeTotal():void 
		{
			if (totalTitle != null) {
				removeChild(totalTitle);
				UI.destroy(totalTitle);
				totalTitle = null;
			}
			if (totalValue != null) {
				removeChild(totalValue);
				UI.destroy(totalValue);
				totalValue = null;
			}
		}
		
		public function draw(componentsWidth:int, commissionData:Object):void 
		{
			this.componentsWidth = componentsWidth;
			
			if (commissionData != null)
			{
				if ("total" in commissionData && commissionData.total != null && "readable" in commissionData.total)
					drawTotal(commissionData.total.readable);
				else
					drawTotal();
				
				if ("first_transaction" in commissionData && commissionData.first_transaction != null && "readable" in commissionData.first_transaction)
					drawFirst(commissionData.first_transaction.readable);
				else
					removeFirst();
				
				
				if ("low_liquidity" in commissionData && commissionData.low_liquidity != null && "readable" in commissionData.low_liquidity)
					drawLowLiquidity(commissionData.low_liquidity.readable);
				else
					removeLowLiquidity();
				
				
				if ("main" in commissionData && commissionData.main != null && "readable" in commissionData.main)
					drawMain(commissionData.main.readable);
				else
					removeMain();
			}
			else
			{
				drawTotal();
				removeFirst();
				removeLowLiquidity();
				removeMain();
			}
			
			updatePositions();
		}
		
		private function drawTotal(text:String = null):void 
		{
			addTotal();
			
			if (totalValue.bitmapData != null)
			{
				totalValue.bitmapData.dispose();
				totalValue.bitmapData = null;
			}
			
			if (text != null)
			{
				totalValue.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	componentsWidth * .5, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.BODY, 
																	false, 
																	Style.color(Style.COLOR_TEXT), 
																	Style.color(Style.COLOR_BACKGROUND));
			}
			
			if (totalTitle.bitmapData != null)
			{
				totalTitle.bitmapData.dispose();
				totalTitle.bitmapData = null;
			}
			
			var titleText:String = Lang.totalComissionFee;
			if (text == null)
			{
				titleText += " " + Lang.calculation;
			}
			totalTitle.bitmapData = TextUtils.createTextFieldData(
																	titleText, 
																	componentsWidth - totalValue.width - Config.DIALOG_MARGIN, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.BODY, 
																	false, 
																	Style.color(Style.COLOR_TEXT), 
																	Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function updatePositions():void 
		{
			var position:int = 0;
			
			if (totalValue != null)
			{
				totalValue.y = position;
				totalValue.x = int(componentsWidth - totalValue.width);
			}
			if (totalTitle != null)
			{
				totalTitle.y = position;
				position += totalTitle.height + Config.FINGER_SIZE * .2;
			}
			
			if (firstValue != null)
			{
				firstValue.y = position;
				firstValue.x = int(componentsWidth - firstValue.width);
			}
			if (firstTitle != null)
			{
				firstTitle.y = position;
				position += firstTitle.height + Config.FINGER_SIZE * .2;
			}
			
			if (lowValue != null)
			{
				lowValue.y = position;
				lowValue.x = int(componentsWidth - lowValue.width);
			}
			if (lowTitle != null)
			{
				lowTitle.y = position;
				position += lowTitle.height + Config.FINGER_SIZE * .2;
			}
			
			if (mainValue != null)
			{
				mainValue.y = position;
				mainValue.x = int(componentsWidth - mainValue.width);
			}
			if (mainTitle != null)
			{
				mainTitle.y = position;
				position += mainTitle.height + Config.FINGER_SIZE * .2;
			}
			
		}
		
		private function drawMain(text:String):void 
		{
			addMain();
			
			if (mainValue.bitmapData != null)
			{
				mainValue.bitmapData.dispose();
				mainValue.bitmapData = null;
			}
			
			mainValue.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	componentsWidth * .5, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, 
																	false, 
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
			
			if (mainTitle.bitmapData != null)
			{
				mainTitle.bitmapData.dispose();
				mainTitle.bitmapData = null;
			}
			
			mainTitle.bitmapData = TextUtils.createTextFieldData(
																	Lang.commissionFee, 
																	componentsWidth - totalValue.width - Config.DIALOG_MARGIN, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, 
																	false, 
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function addMain():void 
		{
			if (mainTitle == null) {
				mainTitle = new Bitmap();
				addChild(mainTitle);
			}
			if (mainValue == null) {
				mainValue = new Bitmap();
				addChild(mainValue);
			}
		}
		
		private function removeMain():void 
		{
			if (mainTitle != null) {
				removeChild(mainTitle);
				UI.destroy(mainTitle);
				mainTitle = null;
			}
			if (mainValue != null) {
				removeChild(mainValue);
				UI.destroy(mainValue);
				mainValue = null;
			}
		}
		
		private function addTotal():void 
		{
			if (totalTitle == null) {
				totalTitle = new Bitmap();
				addChild(totalTitle);
			}
			if (totalValue == null) {
				totalValue = new Bitmap();
				addChild(totalValue);
			}
		}
		
		private function removeLowLiquidity():void 
		{
			if (lowTitle != null) {
				removeChild(lowTitle);
				UI.destroy(lowTitle);
				lowTitle = null;
			}
			if (lowValue != null) {
				removeChild(lowValue);
				UI.destroy(lowValue);
				lowValue = null;
			}
		}
		
		private function drawLowLiquidity(text:String):void 
		{
			addLowLiquidity();
			
			if (text == null)
			{
				text = Lang.calculation;
			}
			
			if (lowValue.bitmapData != null)
			{
				lowValue.bitmapData.dispose();
				lowValue.bitmapData = null;
			}
			
			lowValue.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	componentsWidth * .5, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, 
																	false, 
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
			
			if (lowTitle.bitmapData != null)
			{
				lowTitle.bitmapData.dispose();
				lowTitle.bitmapData = null;
			}
			
			lowTitle.bitmapData = TextUtils.createTextFieldData(
																	Lang.lowLiquidityFee, 
																	componentsWidth - totalValue.width - Config.DIALOG_MARGIN, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, 
																	false, 
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function addLowLiquidity():void 
		{
			if (lowTitle == null) {
				lowTitle = new Bitmap();
				addChild(lowTitle);
			}
			if (lowValue == null) {
				lowValue = new Bitmap();
				addChild(lowValue);
			}
		}
		
		private function drawFirst(text:String):void 
		{
			addFirst();
			
			if (text == null)
			{
				text = Lang.calculation;
			}
			
			if (firstValue.bitmapData != null)
			{
				firstValue.bitmapData.dispose();
				firstValue.bitmapData = null;
			}
			
			firstValue.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	componentsWidth * .5, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, 
																	false, 
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
			
			if (firstTitle.bitmapData != null)
			{
				firstTitle.bitmapData.dispose();
				firstTitle.bitmapData = null;
			}
			
			firstTitle.bitmapData = TextUtils.createTextFieldData(
																	Lang.firstTransactionFee, 
																	componentsWidth - totalValue.width - Config.DIALOG_MARGIN, 
																	10, 
																	false, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, 
																	false, 
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function addFirst():void 
		{
			if (firstTitle == null) {
				firstTitle = new Bitmap();
				addChild(firstTitle);
			}
			if (firstValue == null) {
				firstValue = new Bitmap();
				addChild(firstValue);
			}
		}
		
		private function removeFirst():void 
		{
			if (firstTitle != null) {
				removeChild(firstTitle);
				UI.destroy(firstTitle);
				firstTitle = null;
			}
			if (firstValue != null) {
				removeChild(firstValue);
				UI.destroy(firstValue);
				firstValue = null;
			}
		}
	}
}