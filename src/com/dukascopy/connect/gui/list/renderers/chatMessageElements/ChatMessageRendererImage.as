package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.ErrorYellowIcon;
	import assets.Hourglass;
	import assets.IconSave;
	import assets.PlayVideoButton;
	import assets.PuzzleBack;
	import assets.PuzzleIcon;
	import assets.RejectIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	import com.dukascopy.connect.vo.chat.PuzzleMessageVO;
	import com.dukascopy.connect.vo.chat.VideoMessageVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.plugins.ColorTransformPlugin;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import fl.motion.Color;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererImage extends ChatMessageRendererBase implements IMessageRenderer {
		
		private var imageRenderer:InChatMessageRendererImageDisplay;
		private var maxWidth:int;
		private const boarderSize:int = Config.FINGER_SIZE * .1;
		private var isAnimateImmediately:Boolean;
		private var _isImageReady:Boolean;
		private var playButton:PlayVideoButton;
		private var preloader:Sprite;
		private var centerPoint:Point;
		private var colorBlack:fl.motion.Color;
		private var colorNormal:ColorTransform;
		private var textField:TextField;
		private var textBack:Sprite;
		private var currentData:ChatSystemMsgVO;
		private var cancelIcon:RejectIcon;
		private var colorRed:fl.motion.Color;
		private var targetWidth:int;
		private var errorIcon:ErrorYellowIcon;
		private var puzzleIcon:PuzzleIcon;
		private var puzzleBack:PuzzleBack;
		private var iconPaid:acceptButtonIcon;
		private var iconSave:IconSave;
		private var puzzlePriceBack:Sprite;
		private var puzzlePrice:TextField;
		protected var textFormatFileSize:TextFormat = new TextFormat();
		protected var textFormatPuzzlePrice:TextFormat = new TextFormat();
		
		public function ChatMessageRendererImage() {
			super();
			
			var bgSize:int = textBoxRadius * 3;
			
			puzzleBack = new PuzzleBack();
			UI.scaleToFit(puzzleBack, Config.FINGER_SIZE * 3.2, Config.FINGER_SIZE * 3.2);
			addChild(puzzleBack);
			
			initBg(COLOR_BG_WHITE);
			
			imageRenderer = new InChatMessageRendererImageDisplay(textBoxRadius * 0.6);
			addChild(imageRenderer);
			
			playButton = new PlayVideoButton();
			UI.scaleToFit(playButton, Config.FINGER_SIZE, Config.FINGER_SIZE);
			addChild(playButton);
			
			preloader = new Sprite();
			addChild(preloader);
			
			colorBlack = new fl.motion.Color();
			colorBlack.brightness = -0.6;
			
			colorRed = new fl.motion.Color();
			colorRed.color = 0xD5503F;
			
			colorNormal = new ColorTransform();
			
			textFormatFileSize.font = Config.defaultFontName;
			textFormatFileSize.size = Config.FINGER_SIZE * .26;
			textFormatFileSize.color = 0xFFFFFF;
			
			textFormatPuzzlePrice.font = Config.defaultFontName;
			textFormatPuzzlePrice.size = Config.FINGER_SIZE * .26;
			textFormatPuzzlePrice.align = TextFormatAlign.CENTER;
			textFormatPuzzlePrice.color = 0xFFFFFF;
			
			textBack = new Sprite();
			addChild(textBack);
			
			textField = new TextField();
				textField.defaultTextFormat = textFormatFileSize;
				textField.text = "1:00";
				textField.height = textField.textHeight + 4;
				textField.width = textField.textWidth + 4 + Config.MARGIN;
				textField.text = "";
				textField.wordWrap = false;
				textField.multiline = false;
			addChild(textField);
			
			cancelIcon = new RejectIcon();
			UI.scaleToFit(cancelIcon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			addChild(cancelIcon);
			
			errorIcon = new ErrorYellowIcon();
			UI.scaleToFit(errorIcon, Config.FINGER_SIZE * 1.2, Config.FINGER_SIZE * 1.2);
			addChild(errorIcon);
			
			puzzleIcon = new PuzzleIcon();
			UI.scaleToFit(puzzleIcon, Config.FINGER_SIZE * 3, Config.FINGER_SIZE * 3);
			addChild(puzzleIcon);
			
			iconSave = new IconSave();
			UI.scaleToFit(iconSave, Config.FINGER_SIZE * 0.8, Config.FINGER_SIZE * 0.8);
			addChild(iconSave);
			
			puzzlePriceBack = new Sprite();
			addChild(puzzlePriceBack);
			
			puzzlePrice = new TextField();
				puzzlePrice.defaultTextFormat = textFormatPuzzlePrice;
				puzzlePrice.text = "1:00";
				puzzlePrice.height = puzzlePrice.textHeight + 4;
				puzzlePrice.width = puzzlePrice.textWidth + 4 + Config.MARGIN;
				puzzlePrice.text = "";
				puzzlePrice.wordWrap = false;
				puzzlePrice.multiline = false;
			addChild(puzzlePrice);
			
			iconPaid = new acceptButtonIcon();
			var color:fl.motion.Color = new fl.motion.Color();
			color.color = 0xFFFFFF;
			iconPaid.transform.colorTransform = color;
			UI.scaleToFit(iconPaid, Config.FINGER_SIZE * 0.33, Config.FINGER_SIZE * 0.33);
			addChild(iconPaid);
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (imageRenderer)
				imageRenderer.dispose();
			imageRenderer = null;
			
			if (playButton != null) {
				UI.destroy(playButton);
				playButton = null;
			}
			if (preloader != null) {
				UI.destroy(preloader);
				preloader = null;
			}
			if (textField != null) {
				UI.destroy(textField);
				textField = null;
			}
			if (textBack != null) {
				UI.destroy(textBack);
				textBack = null;
			}
			if (cancelIcon != null) {
				UI.destroy(cancelIcon);
				cancelIcon = null;
			}
			if (errorIcon != null) {
				UI.destroy(errorIcon);
				errorIcon = null;
			}
			if (puzzleIcon != null) {
				UI.destroy(puzzleIcon);
				puzzleIcon = null;
			}
			if (puzzleBack != null) {
				UI.destroy(puzzleBack);
				puzzleBack = null;
			}
			if (iconPaid != null) {
				UI.destroy(iconPaid);
				iconPaid = null;
			}
			if (iconSave != null) {
				UI.destroy(iconSave);
				iconSave = null;
			}
			
			if (puzzlePriceBack != null) {
				UI.destroy(puzzlePriceBack);
				puzzlePriceBack = null;
			}
			if (puzzlePrice != null) {
				UI.destroy(puzzlePrice);
				puzzlePrice = null;
			}
			
			centerPoint = null;
			colorNormal = null;
			colorBlack = null;
			colorRed = null;
			textFormatFileSize = null;
			currentData = null;
			textFormatPuzzlePrice = null;
		}
		
		public function getContentHeight():Number {
			return height;
		}
		
		public function updateHitzones(itemHitzones:Vector.<HitZoneData>):void {
			var cancelButtonExist:Boolean = false;
			var resendButtonExist:Boolean = false;
			var saveButtonExist:Boolean = false;
			
			if (currentData != null && 
				currentData.fileType == ChatSystemMsgVO.FILETYPE_VIDEO &&
				currentData.videoVO != null) {
				if (currentData.videoVO.loaded == true)	{
					if (currentData.videoVO.saveAvaliable == true) {
						saveButtonExist = true;
					}
				}
				else {
					if (currentData.videoVO.rejected == true) {
						resendButtonExist = true;
					}
					else {
						cancelButtonExist = true;
					}
				}
			}
			
			var hz:HitZoneData;
			if (parent)	{
				if (cancelButtonExist == true && cancelIcon.visible == true) {
					hz = new HitZoneData();
						hz.type = HitZoneType.CANCEL;
						hz.x = cancelIcon.x + x - Config.FINGER_SIZE_DOT_25;
						hz.y = cancelIcon.y + y - Config.FINGER_SIZE_DOT_25;
						hz.width = Config.FINGER_SIZE;
						hz.height = Config.FINGER_SIZE;
					itemHitzones.push(hz);
				}
				else if (resendButtonExist == true && textBack.visible == true)	{
					hz = new HitZoneData();
						hz.type = HitZoneType.RESEND;
						hz.x = textBack.x + x;
						hz.y = textBack.y + y;
						hz.width = textBack.width;
						hz.height = textBack.height;
					itemHitzones.push(hz);
				}
				
				if (saveButtonExist == true) {
					hz = new HitZoneData();
						hz.type = HitZoneType.SAVE;
						
						hz.x = iconSave.x + x;
						hz.y = iconSave.y + y;
						hz.width = iconSave.width;
						hz.height = iconSave.height;
					itemHitzones.push(hz);
				}
				
				hz = new HitZoneData();
						hz.type = HitZoneType.BALLOON;
						hz.x = x;
						hz.y = y;
						hz.width = maxWidth;
						hz.height = maxWidth;
				itemHitzones.push(hz);
			}
		}
		
		public function getHeight(itemData:ChatMessageVO, targetWidth:int, listItem:ListItem):uint {
			this.maxWidth = targetWidth;
			//TODO зачем єто здесь?
			// чтобы прописывать в общую хитзону
			
			if (imageRenderer)
				imageRenderer.setSize(targetWidth - boarderSize * 2, targetWidth - boarderSize * 2);
			
			return targetWidth;
		}
		
		public function getBackColor():Number {
			if (boxBg.transform.colorTransform.color == 0)
			{
				return 0xFFFFFF;
			}
			return boxBg.transform.colorTransform.color;
		}
		
		public function getWidth():uint {
			return maxWidth;
		}
		
		public function draw(messageVO:ChatMessageVO, targetWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			_isImageReady = false;
			this.targetWidth = targetWidth;
			
			if (imageRenderer)
				imageRenderer.setSize(targetWidth - boarderSize * 2, targetWidth - boarderSize * 2);
			
			currentData = messageVO.systemMessageVO;
			
			boxBg.width = targetWidth;
			boxBg.height = targetWidth;
			var isUseSequrityKey:Boolean = false;
			var loadedImg:ImageBitmapData;
			
			if (loadedImg == null) {
				isUseSequrityKey = true;
				loadedImg = listItem.getLoadedImage('imageThumbURLWithKey');
			}
			
			playButton.visible = false;
			cancelIcon.visible = false;
			textField.visible = false;
			preloader.visible = false;
			textBack.visible = false;
			errorIcon.visible = false;
			puzzleIcon.visible = false;
			puzzleBack.visible = false;
			iconPaid.visible = false;
			iconSave.visible = false;
			puzzlePrice.visible = false;
			puzzlePriceBack.visible = false;
			
			imageRenderer.mask = null;
			boxBg.visible = true;
			
			imageRenderer.filters = [];
			
			var contentReady:Boolean = true;
			imageRenderer.transform.colorTransform = colorNormal;
			boxBg.transform.colorTransform = colorNormal;
			if (messageVO.systemMessageVO != null && 
				messageVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO)
			{
				if (loadedImg != null)
				{
					contentReady = drawVideoControls(messageVO.systemMessageVO.videoVO);
				}
				imageRenderer.setVideoIcon();
			}
			else if(messageVO.systemMessageVO != null && messageVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_PUZZLE_CRYPTED)
			{
				contentReady = drawPuzzleControls(messageVO.systemMessageVO.puzzleVO);
				imageRenderer.hideIcon();
			}
			else
			{
				imageRenderer.setPhotoIcon();
				imageRenderer.transform.colorTransform = colorNormal;
			}
			
			if (loadedImg != null) {
				if (messageVO.systemMessageVO != null && messageVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO && contentReady == true)
				{
					playButton.visible = true;
					playButton.x = targetWidth * .5 - playButton.width * .5;
					playButton.y = targetWidth * .5 - playButton.height * .5;
				}
				
				if (!isUseSequrityKey)
					securityKey = null;
				_isImageReady = true;
				imageRenderer.drawImage(loadedImg, targetWidth - boarderSize * 2, targetWidth - boarderSize * 2, securityKey);
			} else {
				imageRenderer.clearImage();
			}
			imageRenderer.x = boarderSize;
			imageRenderer.y = boarderSize;
			
			if (loadedImg != null && !loadedImg.isDisposed)
				isAnimateImmediately = true;
			else
				isAnimateImmediately = false;
		}
		
		private function drawPuzzleControls(value:PuzzleMessageVO):Boolean 
		{
			if (value != null) {
				boxBg.visible = false;
				puzzleIcon.visible = true;
				puzzleIcon.x = int(targetWidth * .5 - puzzleIcon.width * .5);
				puzzleIcon.y = int(targetWidth * .5 - puzzleIcon.height * .5);
				imageRenderer.mask = puzzleIcon;
				
				puzzleBack.visible = true;
				puzzleBack.x = int(puzzleIcon.x + puzzleIcon.width * .5 - puzzleBack.width * .5);
				puzzleBack.y = int(puzzleIcon.y + puzzleIcon.height * .5 - puzzleBack.height * .5);
				
				puzzlePrice.text = value.amount + " " + value.currency;
				puzzlePrice.width = puzzlePrice.textWidth + 6;
				puzzlePrice.visible = true;
				
				var verticalPadding:int = Config.MARGIN * .7;
				var horizontalPadding:int = Config.MARGIN;
				
				var backWidth:int = puzzlePrice.width + horizontalPadding * 2.5;
				
				var priceBackColor:Number = AppTheme.RED_MEDIUM;// 0xD92626;
				if (value.isPaid == true) {
					priceBackColor = com.dukascopy.connect.sys.style.presets.Color.GREEN;
					backWidth += iconPaid.width + Config.MARGIN;
					iconPaid.visible = true;
				}
				
				puzzlePriceBack.graphics.clear();
				puzzlePriceBack.visible = true;
				puzzlePriceBack.graphics.beginFill(priceBackColor);
				puzzlePriceBack.graphics.drawRoundRect(0, 0, 
														backWidth, 
														puzzlePrice.height + verticalPadding * 2, 
														puzzlePrice.height + verticalPadding * 2, 
														puzzlePrice.height + verticalPadding * 2);
				
				var backPosition:int = maxWidth * .5;
				if (backPosition > maxWidth - puzzlePriceBack.width)
				{
					backPosition = maxWidth - puzzlePriceBack.width;
				}
				puzzlePriceBack.x = backPosition;
				puzzlePriceBack.y = int(maxWidth - Config.MARGIN * 4.5 - puzzlePriceBack.height);
				
				if (value.isPaid == true) {
					iconPaid.x = int(puzzlePriceBack.x + horizontalPadding);
					iconPaid.y = int(puzzlePriceBack.y + puzzlePriceBack.height * .5 - iconPaid.height * .5);
					puzzlePrice.x = int(iconPaid.x + iconPaid.width + horizontalPadding);
				}
				else {
					puzzlePrice.x = int(puzzlePriceBack.x + horizontalPadding);
				}
				
				puzzlePrice.y = int(puzzlePriceBack.y + verticalPadding);
			}
			return true;
		}
		
		private function drawVideoControls(value:VideoMessageVO):Boolean 
		{
			var videoReady:Boolean = true;
			imageRenderer.transform.colorTransform = colorNormal;
			if (value != null)
			{
				drawFileSize(value);
				
				if (value.loaded == false)
				{
					videoReady = false;
					
					if (value.error == false)
					{
						if (value.rejected == false)
						{
							cancelIcon.visible = true;
							cancelIcon.x = int(targetWidth * .5 - cancelIcon.width * .5);
							cancelIcon.y = int(targetWidth * .5 - cancelIcon.height * .5);
							
							if (value.percent == 0)
							{
								drawInfiniteProgress(value.encodeProgress);
							}
							else
							{
								drawProgress(value.percent);
							}
							imageRenderer.transform.colorTransform = colorBlack;
						}
						else
						{
							errorIcon.visible = true;
							errorIcon.x = int(targetWidth * .5 - errorIcon.width * .5);
							errorIcon.y = int(targetWidth * .4 - errorIcon.height * .5);
							drawResendButton();
							boxBg.transform.colorTransform = colorRed;
							imageRenderer.transform.colorTransform = colorBlack;
						}
					}
					else
					{
						errorIcon.visible = true;
						errorIcon.x = int(targetWidth * .5 - errorIcon.width * .5);
						errorIcon.y = int(targetWidth * .4 - errorIcon.height * .5);
						drawErrorText();
						boxBg.transform.colorTransform = colorRed;
						imageRenderer.transform.colorTransform = colorBlack;
					}
				}
				else
				{
					if (value.saveAvaliable == true) {
						iconSave.alpha = 1;
					}
					else {
						iconSave.alpha = 0.5;
					}
					
					iconSave.visible = true;
					iconSave.x = int(Config.DOUBLE_MARGIN);
					iconSave.y = int(maxWidth - iconSave.height - Config.DOUBLE_MARGIN);
					
					imageRenderer.transform.colorTransform = colorNormal;
				}
			}
			else
			{
				videoReady = false;
				imageRenderer.transform.colorTransform = colorNormal;
			}
			
			return videoReady;
		}
		
		private function drawInfiniteProgress(value:int):void 
		{
			preloader.visible = true;
			preloader.x = targetWidth * .5;
			preloader.y = targetWidth * .5;
			
			if (centerPoint == null)
			{
				centerPoint = new Point(0, 0);
			}
			preloader.graphics.clear();
			
			var alpha:Number;
			
			for (var i:int = 0; i < 8; i++) 
			{
				if (value%8 == i)
				{
					alpha = 0.7;
				}
				else {
					alpha = 0.2;
				}
				
				preloader.graphics.lineStyle(Config.FINGER_SIZE * .1, 0xFFFFFF, alpha, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
				BaseGraphicsUtils.drawCircleSegment(preloader.graphics, centerPoint, Math.PI * 45*i/180, Math.PI * (45*i+ 20)/180, Config.FINGER_SIZE * .5);
			}
		}
		
		private function drawResendButton():void 
		{
			drawText(Lang.sendAgain, 0x75BB25, 1);
			
			textBack.x = int(targetWidth * .5 - textBack.width * .5);
			textBack.y = int(errorIcon.y + errorIcon.height + Config.DOUBLE_MARGIN);
			textField.x = int(textBack.x + Config.MARGIN);
			textField.y = int(textBack.y + Config.MARGIN);
		}
		
		private function drawErrorText():void 
		{
			drawText(Lang.textError);
			
			textBack.x = int(targetWidth * .5 - textBack.width * .5);
			textBack.y = int(errorIcon.y + errorIcon.height + Config.DOUBLE_MARGIN);
			textField.x = int(textBack.x + Config.MARGIN);
			textField.y = int(textBack.y + Config.MARGIN);
		}
		
		private function drawFileSize(value:VideoMessageVO):void 
		{
			if (value != null && 
				value.error == false && 
				value.rejected == false && 
				value.duration != 0)
			{
				drawText(TextUtils.formatTime(value.duration));
				
				textBack.x = int(Config.DOUBLE_MARGIN);
				textBack.y = int(Config.DOUBLE_MARGIN);
				textField.x = int(textBack.x + Config.MARGIN);
				textField.y = int(textBack.y + Config.MARGIN);
			}
		}
		
		private function drawText(value:String, backColor:Number = 0, backAlpha:Number = 0.5):void 
		{
			textField.visible = true;
			textBack.visible = true;
			textField.text = value;
			
			textField.width = textField.textWidth + 4;
			textBack.graphics.clear();
			textBack.graphics.beginFill(backColor, backAlpha);
			textBack.graphics.drawRoundRect(0, 0, textField.width + Config.DOUBLE_MARGIN, textField.height + Config.DOUBLE_MARGIN, Config.MARGIN, Config.MARGIN);
			textBack.graphics.endFill();
		}
		
		private function drawProgress(value:int):void 
		{
			preloader.visible = true;
			preloader.x = targetWidth * .5;
			preloader.y = targetWidth * .5;
			
			if (centerPoint == null)
			{
				centerPoint = new Point(0, 0);
			}
			preloader.graphics.clear();
			
			preloader.graphics.lineStyle(Config.FINGER_SIZE * .1, 0xFFFFFF, 0.2, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			BaseGraphicsUtils.drawCircleSegment(preloader.graphics, centerPoint, 0, Math.PI * 2, Config.FINGER_SIZE * .5);
			
			
			preloader.graphics.lineStyle(Config.FINGER_SIZE * .1, 0xFFFFFF, 0.7, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			BaseGraphicsUtils.drawCircleSegment(preloader.graphics, centerPoint, 0, Math.PI * value/180, Config.FINGER_SIZE * .5);
		}
		private function get rect():Rectangle {
			var res:Rectangle = new Rectangle(x + boxBg.x, y + boxBg.y, boxBg.width, boxBg.height);
			return res;
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return new AnimatedZoneVO("imageThumbURLWithKey", rect, isAnimateImmediately);
		}
		
		public function get isReadyToDisplay():Boolean {
			if (currentData != null && 
				currentData.fileType == ChatSystemMsgVO.FILETYPE_PUZZLE_CRYPTED)
			{
				return false;
			}
			return _isImageReady;
		}
		
		override protected function initBg(color:int, roundedTop:Boolean = true, roundedBottom:Boolean = true):void {
			var bgSize:int = textBoxRadius * 10;
			if (boxBg == null)
				boxBg = new Shape();
			else
				boxBg.graphics.clear();
			var rTop:int = (roundedTop == true) ? textBoxRadius : 0;
			var rBottom:int = (roundedBottom == true) ? textBoxRadius : 0;
			boxBg.graphics.beginFill(color, 1);
			boxBg.graphics.drawRoundRectComplex(0, 0, bgSize, bgSize, rTop, rTop, rBottom, rBottom);
			var frameSize:Number = boarderSize;
			boxBg.graphics.drawRoundRectComplex(frameSize, frameSize, bgSize-frameSize*2, bgSize-frameSize*2, rTop, rTop, rBottom, rBottom);
			boxBg.graphics.endFill();
			
			
			boxBg.scale9Grid = new Rectangle(textBoxRadius+frameSize, textBoxRadius+frameSize, 10, 10);
			if (boxBg.parent == null)
				addChild(boxBg);
		}
	}
}