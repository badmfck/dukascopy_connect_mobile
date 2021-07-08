package com.dukascopy.connect.gui.list.renderers.trade {
	
	import assets.SortHorizontalIcon;
	import assets.SortVerticalIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.Separator;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ListMarketplaceItem extends BaseRenderer implements IListRenderer
	{
		static public const MESSAGE_TYPE_ORDER:String = "messageTypeOrder";
		
		static private var COLOR_BG_WHITE:uint = 0xFFFFFF;
		
		private var avatarSize:int = 50;
		private var minHeight:int = 50;
		
		protected var sideMargin:int = 10;
		
		private var dateFormat:TextFormat;
		private var likesFormat:TextFormat;
		private var mainFormat:TextFormat;
		
		private var avatarDoubleSize:int;
		
		private var securityIconSize:int;
		
		private var fontSize:int;
		
		private var txtColorFile:uint = 0x000000;
		protected var divider:Sprite;
		private var horizontalIcon:SortHorizontalIcon;
		private var verticalIcon:SortVerticalIcon;
		private var bestPriceText1:Bitmap;
		private var bestPriceText2:Bitmap;
		
		protected var colorTransform:ColorTransform;
		protected var lastBackgroundBrightness:Number = NaN;
		protected var itemsNum:TextField;
		protected var lastRenderer:IMarketplaceRenderer;
		protected var _orderRenderer:IMarketplaceRenderer;
		protected var bidClip:Sprite;
		protected var askClip:Sprite;
		protected var numClip:Sprite;
		protected var bidClipText:Bitmap;
		protected var askClipText:Bitmap;
		protected var markGroupClip:Sprite;
		protected var collapseClip:Sprite;
		protected var collapseText:Bitmap;
		
		public function ListMarketplaceItem()
		{
			colorTransform = new ColorTransform();
			
			// set constants
			securityIconSize = Config.FINGER_SIZE * .25;
			avatarSize = Config.FINGER_SIZE * .33;
			avatarDoubleSize = avatarSize * 2;
			
			fontSize = Math.ceil(Config.FINGER_SIZE * .25);
			
			sideMargin = Config.FINGER_SIZE * .5;
			minHeight = avatarSize;
			
			if (fontSize < 9)
				fontSize = 9;
			
			mainFormat = new TextFormat("Tahoma", fontSize);
			
			var smallFontSize:int = Config.FINGER_SIZE * .19;
			if (smallFontSize < 9)
				smallFontSize = 9;
			dateFormat = new TextFormat("Tahoma", smallFontSize, 0xFFFFFF);
			
			mainFormat.size = Config.FINGER_SIZE * .26;
		//	mainFormat.bold = true;
			mainFormat.color = 0x999999;
			
			var tf:TextFormat = new TextFormat();
			tf.font = Config.defaultFontName;
			tf.color = AppTheme.GREY_MEDIUM;
			tf.size = smallFontSize;
			
			numClip = new Sprite();
			
			likesFormat = getNumTextFormat();
			itemsNum = new TextField();
			itemsNum.autoSize = TextFieldAutoSize.LEFT;
			itemsNum.defaultTextFormat = likesFormat;
			itemsNum.multiline = false;
			itemsNum.wordWrap = false;
			itemsNum.text = "00";
			itemsNum.height = itemsNum.textHeight + 4;
			numClip.addChild(itemsNum);
			
			bidClip = new Sprite();
			bidClipText = new Bitmap();
			bidClip.addChild(bidClipText);
			addChild(bidClip);
			bidClipText.bitmapData = TextUtils.createTextFieldData(Lang.bid.toUpperCase(), avatarSize * 2.6, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0x5485A8, 0xF5F5F5);
			
			askClip = new Sprite();
			askClipText = new Bitmap();
			askClip.addChild(askClipText);
			addChild(askClip);
			askClipText.bitmapData = TextUtils.createTextFieldData(Lang.ask.toUpperCase(), avatarSize * 2.6, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	false, 0x5DA34E, 0xF5F5F5);
			
			addChild(numClip);
			
			markGroupClip = new Sprite();
			addChild(markGroupClip);
			
			collapseClip = new Sprite();
			addChild(collapseClip);
			collapseText = new Bitmap();
			collapseClip.addChild(collapseText);
			collapseText.bitmapData = TextUtils.createTextFieldData("-", avatarSize * 2.6, 10, 
																	false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .36, 
																	false, 0xFFFFFF, 0xF5F5F5);
			
			divider = new Sprite()
			addChild(divider);
			
			horizontalIcon = new SortHorizontalIcon();
			UI.scaleToFit(horizontalIcon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			divider.addChild(horizontalIcon);
			
			verticalIcon = new SortVerticalIcon();
			UI.scaleToFit(verticalIcon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			divider.addChild(verticalIcon);
		}
		
		protected function getNumTextFormat():TextFormat 
		{
			return new TextFormat("Tahoma", Config.FINGER_SIZE * .24, 0xFFFFFF);
		}
		
		private function drawAskClip():void 
		{
			var buttonSize:int = Math.min(avatarSize * 2.5, height);
			if (askClip.width != buttonSize - 3)
			{
				askClip.graphics.clear();
				askClip.graphics.lineStyle(1, 0xCFCFCF, 1, true);
				askClip.graphics.beginFill(0xF5F5F5);
				askClip.graphics.drawRoundRect(1, 1, buttonSize - 2, buttonSize - 2, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			}
			
			askClipText.x = int(buttonSize * .5 - askClipText.width * .5);
			askClipText.y = int(buttonSize * .5 - askClipText.height * .5);
		}
		
		private function drawBidClip(itemHeight:int):void 
		{
			var buttonSize:int = Math.min(avatarSize * 2.5, itemHeight);
			if (bidClip.width != buttonSize - 3)
			{
				bidClip.graphics.clear();
				bidClip.graphics.lineStyle(1, 0xCFCFCF, 1, true);
				bidClip.graphics.beginFill(0xF5F5F5);
				bidClip.graphics.drawRoundRect(2, 1, buttonSize - 2, buttonSize - 2, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			}
			
			bidClipText.x = int(buttonSize * .5 - bidClipText.width * .5);
			bidClipText.y = int(buttonSize * .5 - bidClipText.height * .5);
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var result:HitZoneData;
			
			if (listItem.data == null)
			{
				result = new HitZoneData();
				result.disabled = true;
				return result;
			}
			
			if (listItem.data is TradingOrder) {
				var order:TradingOrder = listItem.data as TradingOrder;
				var messageType:String = getMessageType(order);
				var renderer:IMarketplaceRenderer = getRenderer(messageType);
				
				var h:int;
				
				if (renderer != null && renderer is MarketplaceRendererOrder)
				{
					h = getHeight(listItem, listItem.width);
					getView(listItem, h, listItem.width, false);
					
					var zone:Rectangle;
					
					if (numClip.visible)
					{
						zone = numClip.getRect(this);
						zone.x -= Config.MARGIN * 2;
						zone.y -= Config.MARGIN * 2;
						zone.width += Config.MARGIN * 4;
						zone.height += Config.MARGIN * 4;
						if (zone.contains(itemTouchPoint.x, itemTouchPoint.y))
						{
							result = new HitZoneData();
							result.radius = zone.height;
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
							result.x = zone.x;
							result.y = zone.y;
							result.width = zone.width;
							result.height = zone.height;
							return result;
						}
					}
					else if (collapseClip.visible)
					{
						zone = collapseClip.getRect(this);
						zone.x -= Config.MARGIN * 2;
						zone.y -= Config.MARGIN * 2;
						zone.width += Config.MARGIN * 4;
						zone.height += Config.MARGIN * 4;
						if (zone.contains(itemTouchPoint.x, itemTouchPoint.y))
						{
							result = new HitZoneData();
							result.radius = zone.height;
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
							result.x = zone.x;
							result.y = zone.y;
							result.width = zone.width;
							result.height = zone.height;
							return result;
						}
					}
					
					return renderer.getSelectedHitzone(itemTouchPoint, listItem);
				}
			}
			else if (listItem.data is Separator)
			{
				result = new HitZoneData();
				result.disabled = true;
				return result;
			}
			
			return null;
		}
		
		public function getHeight(listItem:ListItem, width:int):int {
			if (listItem.data is Separator)
			{
				return Config.FINGER_SIZE * 1.0;
			}
			if (!(listItem.data is TradingOrder)) {
				if (!listItem.data)
					return Config.FINGER_SIZE * 1.0;
					
			//	listItem.elementYPosition = Config.FINGER_SIZE * 0.3;
				listItem.elementYPosition = 0;
				return Config.FINGER_SIZE * .5 + listItem.elementYPosition;
			}
			
		//	listItem.addImageFieldForLoading('avatar');
			
			var messageType:String = getMessageType(listItem.data);
			var maxItemWidth:int = getMaxItemWidth(width, messageType);
			var renderer:IMarketplaceRenderer = getRenderer(messageType);
		//	setChildIndex(avatar, numChildren - 1);
		//	setChildIndex(avatarDefault, numChildren - 1);
		//	setChildIndex(avatarWithLetter, numChildren - 1);
		//	setChildIndex(avatarWithLetter, numChildren - 1);
			var h:int = minHeight;
			var smallGap:int = Config.FINGER_SIZE * .06;
			if (renderer)
				h = renderer.getHeight(listItem.data, maxItemWidth, listItem);
			
		//	h += usernameH + Config.FINGER_SIZE * .04;
			
		//	listItem.elementYPosition = smallGap * 3;
			listItem.elementYPosition = smallGap * 3;
			h += smallGap * 3;
			
			return Math.min(8000, h);
		}
		
		private function needShowUsername(order:TradingOrder, listItem:ListItem):Boolean
		{	
			var result:Boolean = false;	
			return result;
		}
		
		protected function getMessageType(itemData:Object):String {
			return MESSAGE_TYPE_ORDER;
		}
		
		protected function getMaxItemWidth(widthValue:int, messageType:String):int {
			var result:int;
			if (messageType == MESSAGE_TYPE_ORDER)
				result = widthValue * .9 - sideMargin * 2;
			return result;
		}
		
		protected function getRenderer(messageType:String):IMarketplaceRenderer {
			switch (messageType) {
				case MESSAGE_TYPE_ORDER: {
					return orderRenderer;
				}
			}
			return null;
		}
		
		public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			hideRenderers();
			
			numClip.visible = false;
			
			bidClip.visible = false;
			askClip.visible = false;
			
			divider.visible = false;
			horizontalIcon.visible = false;
			verticalIcon.visible = false;
			
			markGroupClip.graphics.clear();
			
			collapseClip.visible = false;
			
			if (height == 0){
				return this;
			}
			
			var hitZones:Array;
				
			if (data.data is Separator)
			{
				divider.visible = true;
				divider.y = height * .5 + Config.FINGER_SIZE * .06 * 1.5;
				
				if (bestPriceText1 == null)
				{
					bestPriceText1 = new Bitmap();
					divider.addChild(bestPriceText1);
					bestPriceText1.bitmapData = TextUtils.createTextFieldData(Lang.bestPrice.toUpperCase(), width*.5 - Config.FINGER_SIZE*0.7, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0x999999, 0xFFFFFF, false, true);
				}
				
				if (bestPriceText2 == null)
				{
					bestPriceText2 = new Bitmap();
					divider.addChild(bestPriceText2);
					bestPriceText2.bitmapData = TextUtils.createTextFieldData(Lang.bestPrice.toUpperCase(), width*.5 - Config.FINGER_SIZE*0.7, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0x999999, 0xFFFFFF, false, true);
				}
				
				bestPriceText1.visible = true;
				bestPriceText2.visible = true;
				
				bestPriceText1.x = int(width * .25 - bestPriceText1.width * .5);
				bestPriceText2.x = int(width * .75 - bestPriceText2.width * .5);
				
				bestPriceText1.y = int(- bestPriceText1.height * .5);
				bestPriceText2.y = int(- bestPriceText2.height * .5);
				
				
				divider.graphics.clear();
				divider.graphics.lineStyle(int(Config.FINGER_SIZE * .03), 0xD9D9D9);
				
				divider.graphics.moveTo(0, 0);
				divider.graphics.lineTo(bestPriceText1.x - Config.FINGER_SIZE * .15, 0);
				
				divider.graphics.moveTo(bestPriceText1.x + bestPriceText1.width + Config.FINGER_SIZE*.15, 0);
				divider.graphics.lineTo(bestPriceText2.x - Config.FINGER_SIZE * .15, 0);
				
				divider.graphics.moveTo(bestPriceText2.x + bestPriceText2.width + Config.FINGER_SIZE*.15, 0);
				divider.graphics.lineTo(width, 0);
				
				divider.graphics.beginFill(0xFFFFFF);
				divider.graphics.drawCircle(width * .5, 0, Config.FINGER_SIZE * .3);
				divider.graphics.endFill();
				
				if ((data.data as Separator).type == Separator.HORIZONTAL)
				{
					horizontalIcon.visible = true;
					horizontalIcon.x = int(width * .5 - horizontalIcon.width * .5);
					horizontalIcon.y = int( -horizontalIcon.height * .5);
				}
				else
				{
					verticalIcon.visible = true;
					verticalIcon.x = int(width * .5 - verticalIcon.width * .5);
					verticalIcon.y = int( -verticalIcon.height * .5);
				}
				
				hitZones = data.getHitZones();
				if (hitZones == null)
				{
					hitZones = new Array();
				}
				else
				{
					hitZones.length = 0;
				}
				hitZones.push( { type: HitZoneType.CHANGE_LAYOUT, x: width*.5 - Config.FINGER_SIZE * .5, y: divider.y - Config.FINGER_SIZE * .5,
									width: Config.FINGER_SIZE * 1, height: Config.FINGER_SIZE * 1 } );
				if (data.getHitZones() == null)
				{
					data.setHitZones(hitZones);
				}
				
				return this;
			}
			
			if (bestPriceText1 != null)
			{
				bestPriceText1.visible = false;
			}
			if (bestPriceText2 != null)
			{
				bestPriceText2.visible = false;
			}
			
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
					drawBidClip(height);
					bidClip.visible = true;
					
					renderer.x = int(sideMargin + avatarSize * 2 + int(Config.FINGER_SIZE * .26));
					bidClip.x = int(renderer.x - bidClip.width - Config.FINGER_SIZE * .1 - 2);
				}
				else
				{
					drawAskClip();
					askClip.visible = true;
					
					renderer.x = int(width - sideMargin - int(Config.FINGER_SIZE * .26) - renderer.getWidth() - avatarSize * 2);
					askClip.x = int(renderer.x + renderer.getWidth() + Config.FINGER_SIZE * .1);
				}
				
				if (orderData.suboffers != null && orderData.suboffers.length > 0)
				{
					numClip.visible = true;
				//	setChildIndex(numClip, numChildren - 1);
					itemsNum.text = "+" + orderData.suboffers.length.toString();
					itemsNum.x = int(Config.FINGER_SIZE * .09);
					itemsNum.y = int(Config.FINGER_SIZE * .015);
					itemsNum.width = itemsNum.textWidth + 4;
					numClip.graphics.clear();
					var color:Number = leftSide?0x68A5D0:0x71C65F;
					
					
					var fullFillOrKill:Boolean = true;
					var l:int = orderData.suboffers.length;
					for (var i:int = 0; i < l; i++) 
					{
						if (!(orderData.suboffers[i] as TradingOrder).fillOrKill)
						{
							fullFillOrKill = false;
							break;
						}
					}
					if (fullFillOrKill == true)
					{
						color = 0xD06565;
					}
					numClip.graphics.beginFill(color);
					numClip.graphics.drawRoundRect(0, 0, itemsNum.width + Config.FINGER_SIZE * .18, itemsNum.height + Config.FINGER_SIZE * .03, itemsNum.height + Config.FINGER_SIZE * .03, itemsNum.height + Config.FINGER_SIZE * .03);
					numClip.graphics.endFill();
					
					if (leftSide)
					{
						numClip.x = Math.max(Config.FINGER_SIZE*.1, bidClip.x - numClip.width*.5);
					}
					else
					{
						numClip.x = Math.min(width - numClip.width - Config.FINGER_SIZE * .05, askClip.x + askClip.width - numClip.width * .5);
					}
				}
				
				renderer.y = data.elementYPosition;
				
				var customContentHeight:Number = renderer.getContentHeight();					
				if ("getCustomContentHeight" in renderer){
					var overrideHeight:Number = renderer['getCustomContentHeight']();
					if(overrideHeight>0){
						customContentHeight = overrideHeight;
					}
				}					
				var avatarY:int = renderer.y + customContentHeight;
				
				askClip.y = int(renderer.y + customContentHeight * .5 - askClip.height * .5);
				bidClip.y = int(renderer.y + customContentHeight * .5 - bidClip.height * .5);
				var maxPosition:int = renderer.y + customContentHeight - numClip.height;
				
				var calcPosition:int;
				if (leftSide)
				{
					calcPosition = bidClip.y + bidClip.height - numClip.height * .5;
				}
				else
				{
					calcPosition = askClip.y + askClip.height - numClip.height * .5;
				}
				
				numClip.y = Math.min(maxPosition, calcPosition);
				
				if (numClip.visible)
				{											
					hitZones.push( { type: HitZoneType.EXPAND, x: numClip.x - Config.MARGIN * 2, y: numClip.y - Config.MARGIN * 2,
									width: numClip.width + Config.MARGIN * 2 * 2, height: numClip.height + Config.MARGIN * 2 * 2 } );
				}
				
				
				hitZones.push( { type: HitZoneType.GET, x: renderer.x, y: renderer.y,
									width: renderer.getWidth(), height: renderer.getContentHeight() } );
				
				var point:Point;
				if (orderData.last == true)
				{
					if (leftSide)
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(Config.FINGER_SIZE * .4, askClip.y + askClip.height * .8);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x -= Config.FINGER_SIZE * .2;
						point.y -= Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y + Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
					else
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(width - Config.FINGER_SIZE * .4, askClip.y + askClip.height * .8);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x += Config.FINGER_SIZE * .2;
						point.y -= Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y + Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
					
					collapseClip.visible = true;
					setChildIndex(collapseClip, numChildren - 1);
					collapseText.x = int(Config.FINGER_SIZE * .22 - collapseText.width * .5);
					collapseText.y = int(Config.FINGER_SIZE * .22 - collapseText.height * .5);
					collapseClip.graphics.clear();
					collapseClip.graphics.beginFill(leftSide?0x68A5D0:0x71C65F);
					collapseClip.graphics.drawRoundRect(0, 0, Config.FINGER_SIZE * .44, Config.FINGER_SIZE * .44, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
					collapseClip.graphics.endFill();
						
					if (leftSide)
					{
						collapseClip.x = Math.max(Config.FINGER_SIZE * .1, bidClip.x - collapseClip.width * .5);
					}
					else
					{
						collapseClip.x = Math.min(width - collapseClip.width - Config.FINGER_SIZE * .05, askClip.x + askClip.width - collapseClip.width * .5);
					}
					
					maxPosition = renderer.y + customContentHeight - collapseClip.height;
					
					if (leftSide)
					{
						calcPosition = bidClip.y + bidClip.height - collapseClip.height * .5;
					}
					else
					{
						calcPosition = askClip.y + askClip.height - collapseClip.height * .5;
					}
					
					collapseClip.y = Math.min(maxPosition, calcPosition);
					
					hitZones.push( { type: HitZoneType.COLLAPSE, x: collapseClip.x - Config.MARGIN * 2, y: collapseClip.y - Config.MARGIN * 2,
									width: collapseClip.width + Config.MARGIN * 2 * 2, height: collapseClip.height + Config.MARGIN * 2 * 2 } );
				}
				else if (orderData.middle == true)
				{
					if (leftSide)
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(Config.FINGER_SIZE * .2, height);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
					else
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(width - Config.FINGER_SIZE * .2, height);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, 0);
					}
				}
				else if (orderData.first == true)
				{
					if (leftSide)
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(Config.FINGER_SIZE * .4, askClip.y + askClip.height * .2);
						
						markGroupClip.graphics.moveTo(point.x, point.y);
						point.x -= Config.FINGER_SIZE * .2;
						point.y += Config.FINGER_SIZE * .2;
						markGroupClip.graphics.curveTo(point.x, point.y - Config.FINGER_SIZE * .2, point.x, point.y);
						markGroupClip.graphics.lineTo(point.x, height);
					}
					else
					{
						markGroupClip.graphics.lineStyle(int(Config.FINGER_SIZE * .05), 0x999999);
						
						point = new Point(width - Config.FINGER_SIZE * .4, askClip.y + askClip.height * .2);
						
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
		
		private function displayTypeClip(yPosition:int):void 
		{
			
		}
		
		protected function hideRenderers():void
		{
			if (_orderRenderer != null)
				_orderRenderer.visible = false;
		}
		
		private function existNextMessage(listItem:ListItem):Boolean {
			if (listItem.list.data == null)
				return false;
			return listItem.num <= listItem.list.data.length && listItem.list.data[listItem.num + 1] is ChatMessageVO;
		}
		
		public function dispose():void {
			
			if (bidClip){
				UI.destroy(bidClip);
				bidClip = null;
			}
			if (bestPriceText1){
				UI.destroy(bestPriceText1);
				bestPriceText1 = null;
			}
			if (bestPriceText2){
				UI.destroy(bestPriceText2);
				bestPriceText2 = null;
			}
			if (askClip){
				UI.destroy(askClip);
				askClip = null;
			}
			if (bidClipText){
				UI.destroy(bidClipText);
				bidClipText = null;
			}
			if (collapseText){
				UI.destroy(collapseText);
				collapseText = null;
			}
			if (askClipText){
				UI.destroy(askClipText);
				askClipText = null;
			}
			if (_orderRenderer != null) {
				_orderRenderer.dispose();
				_orderRenderer = null;
			}
			if (horizontalIcon != null) {
				UI.destroy(horizontalIcon);
				horizontalIcon = null;
			}
			if (verticalIcon != null) {
				UI.destroy(verticalIcon);
				verticalIcon = null;
			}
			
			lastRenderer = null;
			
			dateFormat = null;
			mainFormat = null;
			likesFormat = null;
			avatarDoubleSize = 0;
			
			if (markGroupClip) {
				UI.destroy(markGroupClip);
				markGroupClip = null;
			}
		}
		
		public function getMessageHitzone(listItem:ListItem):HitZoneData {
			var messageType:String = getMessageType(listItem.data as TradingOrder);
			if (messageType != null) {
				var hitZoneType:String;
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				
				if (hitZoneType != null) {
					var height:int = getHeight(listItem, listItem.width);
					getView(listItem, height, listItem.width);
					
					var hitzone:HitZoneData = new HitZoneData();
					if (lastRenderer != null) {
						hitzone.x = lastRenderer.x;
						hitzone.y = lastRenderer.y;
						hitzone.width = lastRenderer.getWidth();
						hitzone.height = lastRenderer.getContentHeight();
						hitzone.type = hitZoneType;
						
						return hitzone;
					}
				}
			}
			return null;
		}
		
		protected function get orderRenderer():IMarketplaceRenderer
		{
			if (_orderRenderer == null)
			{
				_orderRenderer = new MarketplaceRendererOrder();
				addChild(_orderRenderer as Sprite);
			}
			return _orderRenderer;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean
		{
			return true;
		}
	}
}