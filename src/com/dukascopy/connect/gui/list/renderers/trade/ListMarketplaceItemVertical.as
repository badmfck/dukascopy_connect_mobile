package com.dukascopy.connect.gui.list.renderers.trade {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	public class ListMarketplaceItemVertical extends ListMarketplaceItem
	{
		
		public function ListMarketplaceItemVertical()
		{
			super();
			sideMargin = Config.FINGER_SIZE * .3;
			if (collapseText.bitmapData != null)
			{
				collapseText.bitmapData.dispose();
				collapseText.bitmapData = null;
			}
			collapseText.bitmapData = TextUtils.createTextFieldData("-", Config.FINGER_SIZE*.4, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .36, 
																	false, 0x666666, 0xF5F5F5);
		}
		
		override protected function getMaxItemWidth(widthValue:int, messageType:String):int {
			var result:int;
			if (messageType == MESSAGE_TYPE_ORDER)
				result = widthValue - sideMargin * 2;
			return result;
		}
		
		override protected function get orderRenderer():IMarketplaceRenderer
		{
			if (_orderRenderer == null)
			{
				_orderRenderer = new MarketplaceRendererOrderVertical();
				addChild(_orderRenderer as Sprite);
			}
			return _orderRenderer;
		}
		
		override protected function getNumTextFormat():TextFormat 
		{
			return new TextFormat("Tahoma", Config.FINGER_SIZE * .24, 0x666666);
		}
		
		override public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			hideRenderers();
			
			numClip.visible = false;
			bidClip.visible = false;
			askClip.visible = false;
			divider.visible = false;
			
			markGroupClip.graphics.clear();
			
			collapseClip.visible = false;
			
			if (height == 0){
				return this;
			}
			
			var hitZones:Array;
			
			var orderData:TradingOrder = data.data as TradingOrder;
			
			if (orderData == null)
				return this;
			
			var leftSide:Boolean = orderData.side == TradingOrder.BUY;
			var messageType:String = getMessageType(orderData);
			
			var maxItemWidth:int = getMaxItemWidth(width, messageType);
			
			var renderer:IMarketplaceRenderer = getRenderer(messageType);
			lastRenderer = renderer;
			var needUpdateHitzones:Boolean = true;
			if (data.drawnHeight == height && data.drawnWidth == width)
				needUpdateHitzones = false;
			
			data.drawnHeight = height;
			data.drawnWidth = width;
			
			hitZones = data.getHitZones();
			if (hitZones == null)
			{
				hitZones = new Array();
			}
			else
			{
				hitZones.length = 0;
			}
			
			if (renderer) {
				renderer.visible = true;
				renderer.draw(orderData, maxItemWidth, data);
				
				if (leftSide)
				{
					renderer.x = sideMargin;
				}
				else
				{
					renderer.x = sideMargin;
				}
				
				if (orderData.suboffers != null && orderData.suboffers.length > 0)
				{
					numClip.visible = true;
				//	setChildIndex(numClip, numChildren - 1);
					itemsNum.text = "+" + orderData.suboffers.length.toString();
					itemsNum.x = int(Config.FINGER_SIZE * .06);
					itemsNum.y = int(Config.FINGER_SIZE * .010);
					itemsNum.width = itemsNum.textWidth + 4;
					numClip.graphics.clear();
				//	numClip.graphics.lineStyle(int(Config.FINGER_SIZE * .03), leftSide?0x5383A6:0x599C4B);
					numClip.graphics.beginFill(leftSide?0xBDD8F0:0xC6F5B8);
					numClip.graphics.drawRoundRect(0, 0, itemsNum.width + Config.FINGER_SIZE * .12, itemsNum.height + Config.FINGER_SIZE * .02, itemsNum.height + Config.FINGER_SIZE * .02, itemsNum.height + Config.FINGER_SIZE * .02);
					numClip.graphics.endFill();
					
					setChildIndex(numClip, numChildren - 1);
					if (leftSide)
					{
						numClip.x = int(renderer.x + renderer.getWidth() - numClip.width - Config.FINGER_SIZE * .07);
					}
					else
					{
						numClip.x = int(Config.FINGER_SIZE * .1);
					}
				}
				
				renderer.y = data.elementYPosition;
				
				var customContentHeight:Number = renderer.getContentHeight();					
				if ("getCustomContentHeight" in renderer){
					var overrideHeight:Number = renderer['getCustomContentHeight']();
					if (overrideHeight > 0)
					{
						customContentHeight = overrideHeight;
					}
				}					
				var avatarY:int = renderer.y + customContentHeight;
				
				var maxPosition:int = renderer.y + customContentHeight - numClip.height;
				
				var calcPosition:int;
				if (leftSide)
				{
					calcPosition = renderer.y + renderer.height - numClip.height * .5;
				}
				else
				{
					calcPosition = renderer.y + renderer.height - numClip.height * .5;
				}
				
				numClip.y = renderer.y + customContentHeight - numClip.height - Config.FINGER_SIZE * .08;
				
				if (numClip.visible)
				{											
					hitZones.push( { type: HitZoneType.EXPAND, x: numClip.x - Config.MARGIN * 1, y: numClip.y - Config.MARGIN * 1,
									width: numClip.width + Config.MARGIN * 2 * 1, height: numClip.height + Config.MARGIN * 2 * 1 } );
				}
				
				hitZones.push( { type: HitZoneType.GET, x: renderer.x, y: renderer.y,
									width: renderer.getWidth(), height: renderer.getContentHeight() } );
				
				var point:Point;
				if (orderData.last == true)
				{
					if (!leftSide)
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(Config.FINGER_SIZE * .4, renderer.y + customContentHeight * .8);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x -= Config.FINGER_SIZE * .2;
						point.y -= Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y + Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
					else
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(width - Config.FINGER_SIZE * .3, renderer.y + customContentHeight * .8);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x += Config.FINGER_SIZE * .2;
						point.y -= Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y + Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
					
					collapseClip.visible = true;
					setChildIndex(collapseClip, numChildren - 1);
					collapseText.x = int(Config.FINGER_SIZE * .18 - collapseText.width * .5);
					collapseText.y = int(Config.FINGER_SIZE * .20 - collapseText.height * .5);
					collapseClip.graphics.clear();
					collapseClip.graphics.beginFill(leftSide?0xBDD8F0:0xC6F5B8);
					collapseClip.graphics.drawRoundRect(0, 0, Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36);
					collapseClip.graphics.endFill();
						
					/*if (!leftSide)
					{
						collapseClip.x = Math.max(Config.FINGER_SIZE * .1, bidClip.x - collapseClip.width * .5);
					}
					else
					{
						collapseClip.x = Math.min(width - collapseClip.width - Config.FINGER_SIZE * .05, askClip.x + askClip.width - collapseClip.width * .5);
					}*/
					
					if (leftSide)
					{
						collapseClip.x = int(renderer.x + renderer.getWidth() - collapseClip.width - Config.FINGER_SIZE * .07);
					}
					else
					{
						collapseClip.x = int(Config.FINGER_SIZE * .1);
					}
					
					maxPosition = renderer.y + customContentHeight - collapseClip.height;
					
					if (!leftSide)
					{
						calcPosition = bidClip.y + bidClip.height - collapseClip.height * .5;
					}
					else
					{
						calcPosition = askClip.y + askClip.height - collapseClip.height * .5;
					}
					
					collapseClip.y = renderer.y + customContentHeight - collapseClip.height - Config.FINGER_SIZE * .08;
				//	collapseClip.y = Math.min(maxPosition, calcPosition);
					
					hitZones.push( { type: HitZoneType.COLLAPSE, x: collapseClip.x - Config.MARGIN * 2, y: collapseClip.y - Config.MARGIN * 2,
									width: collapseClip.width + Config.MARGIN * 2 * 2, height: collapseClip.height + Config.MARGIN * 2 * 2 } );
				}
				else if (orderData.middle == true)
				{
					if (!leftSide)
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(Config.FINGER_SIZE * .1, height);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
					else
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(width - Config.FINGER_SIZE * .1, height);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
				}
				else if (orderData.first == true)
				{
					if (!leftSide)
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(Config.FINGER_SIZE * .3, renderer.y + customContentHeight * .2);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x -= Config.FINGER_SIZE * .2;
						point.y += Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y - Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, height);
					}
					else
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(width - Config.FINGER_SIZE * .3, renderer.y + customContentHeight * .2);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x += Config.FINGER_SIZE * .2;
						point.y += Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y - Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, height);
					}
				}
				
				if (needUpdateHitzones)
				{
					renderer.updateHitzones(hitZones);
					
					if (data.getHitZones() == null)
					{
						data.setHitZones(hitZones);
					}
				}
			}
			
			return this;
		}
	}
}