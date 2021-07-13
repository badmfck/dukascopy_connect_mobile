package com.dukascopy.connect.gui.list.renderers.chatMessageElements
{
	
	import assets.InstagramIcon;
	import assets.LinksIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.chat.NewsMessageVO;
	import fl.motion.Color;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererNews extends Sprite implements IMessageRenderer
	{
		private var message:TextField;
		private var currentData:ChatSystemMsgVO;
		private var created:Boolean;
		private var verticalPadding:int;
		private var horizontalPadding:int;
		private var mainHeight:Number;
		private var textBoxRadius:Number;
		private var textFormatTitle:TextFormat;
		private var textFormatMessage:TextFormat;
		private var textFormatLink:TextFormat;
		private var image:Sprite;
		private var title:flash.text.TextField;
		private var titleLineHeight:Number = -1;
		private var imageMask:Sprite;
		private var linkClip:Sprite;
		private var linkText:TextField;
		private var linkPadding:int;
		private var linkIcon:assets.LinksIcon;
		private var linkHeight:int;
		private var messageLineHeight:Number = -1;
		private var maxWidth:int;
		private var imageTint:Color;
		private var baseTint:fl.motion.Color;
		private var instagramIcon:InstagramIcon;
		private var matr:Matrix;
		
		public function ChatMessageRendererNews()
		{
			textBoxRadius = Math.ceil(Style.size(Style.MESSAGE_RADIUS));;
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function getContentHeight():Number
		{
			return mainHeight;
		}
		
		public function getWidth():uint
		{
			return width;
		}
		
		public function getBackColor():Number
		{
			return 0xFFFFFF;
		}
		
		public function create():void
		{
			if (created == true)
				return;
			
			created = true;
			
			verticalPadding = Config.FINGER_SIZE * .13;
			horizontalPadding = Config.FINGER_SIZE * .25;
			
			textFormatTitle = new TextFormat();
			textFormatTitle.font = Config.defaultFontName;
			textFormatTitle.size = Config.FINGER_SIZE * .30;
			textFormatTitle.color = Style.color(Style.COLOR_BACKGROUND);
			textFormatTitle.align = TextFormatAlign.LEFT;
			
			textFormatMessage = new TextFormat();
			textFormatMessage.font = Config.defaultFontName;
			textFormatMessage.size = Config.FINGER_SIZE * .24;
			textFormatMessage.color = 0x999999;
			textFormatMessage.align = TextFormatAlign.LEFT;
			
			textFormatLink = new TextFormat();
			textFormatLink.font = Config.defaultFontName;
			textFormatLink.size = Config.FINGER_SIZE * .26;
			textFormatLink.color = 0x3498DB;
			textFormatLink.align = TextFormatAlign.LEFT;
			
			image = new Sprite();
			addChild(image);
			imageTint = new Color();
			imageTint.brightness = -0.5;
			baseTint = new Color();
			
			imageMask = new Sprite();
			addChild(imageMask);
			
			image.mask = imageMask;
			
			title = new TextField();
			title.defaultTextFormat = textFormatTitle;
			title.text = "";
			title.wordWrap = true;
			title.multiline = true;
			title.mouseEnabled = false;
			addChild(title);
			
			message = new TextField();
			message.defaultTextFormat = textFormatMessage;
			message.text = "";
			message.wordWrap = true;
			message.multiline = true;
			message.mouseEnabled = false;
			addChild(message);
			
			title.x = horizontalPadding;
			message.x = horizontalPadding;
			
			linkClip = new Sprite();
			addChild(linkClip);
			
			linkIcon = new LinksIcon();
			linkPadding = Config.FINGER_SIZE * .2;
			linkHeight = Config.FINGER_SIZE * .5;
			UI.scaleToFit(linkIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .25);
			linkClip.addChild(linkIcon);
			linkClip.x = horizontalPadding;
			linkIcon.x = linkPadding;
			linkIcon.y = int(linkHeight * .5 - linkIcon.height * .5);
			
			linkText = new TextField();
			linkText.defaultTextFormat = textFormatLink;
			linkText.text = " ";
			linkText.wordWrap = false;
			linkText.multiline = false;
			linkText.height = linkText.textHeight + 4;
			linkText.mouseEnabled = false;
			linkClip.addChild(linkText);
			
			linkText.x = int(linkIcon.x + linkIcon.width + linkPadding * .5);
			linkText.y = int(linkHeight * .5 - linkText.height * .5);
			
			instagramIcon = new InstagramIcon();
			UI.scaleToFit(instagramIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .8);
			instagramIcon.alpha = 0.15;
			addChild(instagramIcon);
			
			matr = new Matrix();
			matr.rotate(Math.PI/2);
		}
		
		public function updateHitzones(itemHitzones:Array):void
		{
			if (linkClip.visible == true){
				itemHitzones.push( {
					type:HitZoneType.OPEN_NEWS, 
					x:linkClip.x - Config.MARGIN + x,
					y:linkClip.y - Config.MARGIN + y, 
					width:(Config.MARGIN * 2 + linkClip.width),
					height:(Config.MARGIN * 2 + linkClip.height)
				} );
			}
			itemHitzones.push( { type:HitZoneType.BALLOON, x:x , y:y, width:maxWidth, height:mainHeight } );
		}
		
		public function getHeight(itemData:ChatMessageVO, itemWidth:int, listItem:ListItem):uint
		{
			this.maxWidth = itemWidth;
			draw(itemData, itemWidth, listItem);
			return mainHeight;
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void
		{
			var data:ChatSystemMsgVO = messageData.systemMessageVO;
			
			if (currentData == data)
				return;
			
			currentData = data;
			
			create();
			
			title.visible = false;
			message.visible = false;
			linkClip.visible = false;
			image.visible = false;
			instagramIcon.visible = false;
			
			if (data.newsVO == null){
				return;
			}
			
			var text:String = data.newsVO.text;
			var titleText:String = data.newsVO.title;
			
			var position:int = verticalPadding;
			
			var topAreaColor:Number;
			var topAreaHeight:int;
			if (data.newsVO.type == NewsMessageVO.TYPE_INSTAGRAM){
				topAreaHeight = maxWidth;
				topAreaColor = 0x93A2AE;
				image.transform.colorTransform = baseTint;
				title.textColor = Style.color(Style.COLOR_BACKGROUND);
			}else{
				if (data.newsVO.image != null){
					topAreaHeight = Config.FINGER_SIZE * 3.2;
					image.transform.colorTransform = imageTint;
					title.textColor = Style.color(Style.COLOR_BACKGROUND);
				}
				else
				{
					topAreaColor = 0xFFFFFF;
					title.textColor = Style.color(Style.COLOR_TEXT);
				}
			}
			
			if (data.newsVO.image != null){
				position += topAreaHeight;
			}
			
			if (titleText != null) {
				title.visible = true;
				title.width = maxWidth - horizontalPadding * 2;
				title.htmlText = titleText;
				if (titleLineHeight == -1){
					titleLineHeight = title.getLineMetrics(0).height;
				}
				title.height = titleLineHeight * 3 + 4;
				
				if (title.numLines < 3){
					title.height = title.textHeight + 4;
				}
				
				if (data.newsVO.image != null){
					title.y = topAreaHeight - title.height - verticalPadding;
				}
				else{
					title.y = position;
					topAreaHeight = title.y + title.height + verticalPadding * 1.5;
				}
				
				position = title.y + title.height + verticalPadding;
				if (title.htmlText == "")
				{
					position = verticalPadding;
				}
				
				if (data.newsVO.image != null)
				{
					position += verticalPadding;
				}
			}
			
			if (text != null && text != "") {
				message.visible = true;
				message.width = maxWidth - horizontalPadding * 2;
				message.htmlText = text;
				
				if (messageLineHeight == -1){
					messageLineHeight = message.getLineMetrics(0).height;
				}
				
				var maxLines:int = 6;
				if (data.newsVO.type == NewsMessageVO.TYPE_INSTAGRAM){
					maxLines = 5;
				}
				message.height = messageLineHeight * maxLines + 4;
				
				if (message.numLines < maxLines){
					message.height = message.textHeight + 4;
				}
				else if(message.text.length > 4){
					var index:int = 0;
					for (var i:int = 0; i < maxLines; i++) 
					{
						index += message.getLineLength(i);
					}
					
					message.text = message.text.slice(0, index - 3) + "...";
				}
				
				message.y = position;
				position += message.height + verticalPadding;
			}
			
			if (data.newsVO.link != null){
				if (position != verticalPadding)
				{
					position += Config.FINGER_SIZE * .1;
				}
				else
				{
					position = verticalPadding * 1.8;
				}
				
				linkClip.visible = true;
				linkText.text = TextUtils.getServerName(data.newsVO.link);
				linkText.width = Math.min(linkText.textWidth + 4, maxWidth - linkPadding * 3 + linkIcon.width - horizontalPadding * 2);
				
				linkClip.graphics.clear();
				linkClip.graphics.beginFill(0xE7F0FF);
				linkClip.graphics.drawRoundRect(0, 0, linkText.width + linkPadding * 3 + linkIcon.width, linkHeight, linkHeight);
				linkClip.graphics.endFill();
				
				linkClip.y = position;
				position += linkClip.height + verticalPadding * 1.3;
			}
			
			mainHeight = position + verticalPadding * .5;
			
			graphics.clear();
			
			if (titleText != null || data.newsVO.image != null){
				graphics.beginFill(topAreaColor);
				graphics.drawRoundRectComplex(0, 0, maxWidth, topAreaHeight, textBoxRadius, textBoxRadius, 0, 0);
				graphics.endFill();
				
				graphics.beginFill(0xFFFFFF);
				graphics.drawRoundRectComplex(0, topAreaHeight, maxWidth, mainHeight - topAreaHeight, 0, 0, textBoxRadius, textBoxRadius);
				graphics.endFill();
			}
			else{
				graphics.beginFill(0xFFFFFF);
				graphics.drawRoundRect(0, 0, maxWidth, mainHeight, textBoxRadius, textBoxRadius);
				graphics.endFill();
			}
			
			var loadedImg:ImageBitmapData = listItem.getLoadedImage('imageThumbURLWithKey');
			if (loadedImg != null){
				image.visible = true;
				image.graphics.clear();
				imageMask.graphics.clear();
				imageMask.graphics.beginFill(0x232B36);
				imageMask.graphics.drawRoundRectComplex(0, 0, maxWidth, topAreaHeight, textBoxRadius, textBoxRadius, 0, 0);
				imageMask.graphics.endFill();
				ImageManager.drawGraphicImage(image.graphics, 0, 0, maxWidth, topAreaHeight, loadedImg, ImageManager.SCALE_PORPORTIONAL, -1, true);
				if (data.newsVO.type == NewsMessageVO.TYPE_INSTAGRAM){
					matr.createGradientBox(maxWidth, topAreaHeight, Math.PI/2, 0, 1);
					image.graphics.beginGradientFill(GradientType.LINEAR, [0, 0], [0, 0.4], [200, 240], matr, SpreadMethod.PAD);        
					image.graphics.drawRect(0, 0, maxWidth, topAreaHeight);
				}
			}
			else if (data.newsVO.type == NewsMessageVO.TYPE_INSTAGRAM){
				instagramIcon.visible = true;
				instagramIcon.x = int(maxWidth * .5 - instagramIcon.width * .5);
				instagramIcon.y = int(topAreaHeight * .5 - instagramIcon.height * .5);
			}
		}
		
		public function dispose():void
		{
			if (message)
				UI.destroy(message);
			message = null;
			if (image)
				UI.destroy(image);
			image = null;
			if (title)
				UI.destroy(title);
			title = null;
			if (imageMask)
				UI.destroy(imageMask);
			imageMask = null;
			if (linkClip)
				UI.destroy(linkClip);
			linkClip = null;
			if (linkText)
				UI.destroy(linkText);
			linkText = null;
			if (linkIcon)
				UI.destroy(linkIcon);
			linkIcon = null;
			if (instagramIcon)
				UI.destroy(instagramIcon);
			instagramIcon = null;
			
			graphics.clear();
			currentData = null;
			textFormatTitle = null;
			textFormatMessage = null;
			textFormatLink = null;
			matr = null;
		}
		
		public function get animatedZone():AnimatedZoneVO
		{
			return null;
		}
		
		public function get isReadyToDisplay():Boolean
		{
			return true;
		}
		
		public function getSmallGap(listItem:ListItem):int
		{
			return ChatMessageRendererBase.smallGap;
		}
	}
}