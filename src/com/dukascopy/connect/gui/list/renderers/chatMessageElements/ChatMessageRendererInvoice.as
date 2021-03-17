package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.CancelButtonIconRed;
	import assets.IconDone;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.langs.Lang;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererInvoice extends ChatMessageRendererBase implements IMessageRenderer {
		
		private var amountTitle:TextField;
		private var purposeTitle:TextField;
		private var amount:TextField;
		private var purpose:TextField;
		private var payButtonText:TextField;
		private var cancelButtonText:TextField;
		private var retryButtonText:TextField;
		private var statusLabel:TextField;
		
		private var data:ChatMessageInvoiceData;
		private var paddingSide:int;
		private var mainBack:Shape;
		private var amountBack:Sprite;
		private var paddingVertical:int;
		private var contentContainer:Sprite;
		private var itemWidth:int;
		private var payButton:Sprite;
		private var cancelButton:Sprite;
		private var bottomLine:Sprite;
		private var textBoxRadius:Number;
		private var dashedLine:Sprite;
		
		private var mine:Boolean;
		private var isToMe:Boolean;
		private var isSentByMe:Boolean;
		
		private var retryButton:Sprite;
		
		private var acceptedIcon:Sprite;
		private var rejectedIcon:CancelButtonIconRed;
		private var lastInitWidth:int = -1;
		private var isLastForwarded:Boolean = false;
		private var lastInitBackgroundWidth:int = -1;
		
		protected var textFormatAmountTitle:TextFormat = new TextFormat();
		protected var textFormatPurposeTitle:TextFormat = new TextFormat();
		protected var textFormatAmountCancelled:TextFormat = new TextFormat();
		protected var textFormatAmount:TextFormat = new TextFormat();
		protected var textFormatPurpose:TextFormat = new TextFormat();
		protected var textFormatPurposeCancelled:TextFormat = new TextFormat();
		protected var textFormatPayButton:TextFormat = new TextFormat();
		protected var textFormatCancelButton:TextFormat = new TextFormat();
		protected var textFormatRetryButton:TextFormat = new TextFormat();
		protected var textFormatStatus:TextFormat = new TextFormat();
		protected var textFormatStatusCenterAlign:TextFormat = new TextFormat();
		
		private var lastHeight:int;
		
		private var _lastCommonWidth:int;
		private function get lastCommonWidth():int { return _lastCommonWidth; }
		
		private var invoiceContainer:DisplayObjectContainer;
		
		public function ChatMessageRendererInvoice() {
			init();
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function getContentHeight():Number {
			if (isContainsForwardView == true)
				return forwardView.height + vTextMargin;
			return lastHeight;
		}
		
		public function getBackColor():Number {
			return AppTheme.WHITE;
		}
		
		public function  updateHitzones(itemHitzones:Array):void {
			if (data == null)
				return;
			if (parent == null)
				return;
			
			var rejectPoint:Point;
			
			if (data.status == InvoiceStatus.NEW) {
				if (!isSentByMe) {
					var acceptPoint:Point = new Point(payButton.x, payButton.y);
					acceptPoint.x += x;
					acceptPoint.y += y;
					itemHitzones.push( { type:HitZoneType.INVOICE_ACCEPT, x:acceptPoint.x , y:acceptPoint.y, width:payButton.width, height:payButton.height } );
					
					rejectPoint = new Point(cancelButton.x, cancelButton.y);
					rejectPoint.x += x;
					rejectPoint.y += y;
					itemHitzones.push( { type:HitZoneType.INVOICE_REJECT, x:rejectPoint.x , y:rejectPoint.y, width:cancelButton.width, height:cancelButton.height } );
				} else
				{
					rejectPoint = new Point(cancelButton.x, cancelButton.y);
					rejectPoint.x += x;
					rejectPoint.y += y;
					itemHitzones.push( { type:HitZoneType.INVOICE_CANCELLED, x:rejectPoint.x , y:rejectPoint.y, width:cancelButton.width, height:cancelButton.height } );
				}
			} else if (data.status == InvoiceStatus.ACCEPTED && !isSentByMe) {
				var retryPoint:Point = new Point(retryButton.x, retryButton.y);
				retryPoint.x += x;
				retryPoint.y += y;
				itemHitzones.push( { type:HitZoneType.INVOICE_RETRY, x:retryPoint.x , y:retryPoint.y, width:retryButton.width, height:retryButton.height } );
			}
		}
		
		private function initTextFormats():void {
			vTextMargin = Math.ceil(Config.FINGER_SIZE * .15);
			
			textFormatAmountTitle.font = Config.defaultFontName;
			textFormatAmountTitle.size = Config.FINGER_SIZE * .25;
			textFormatAmountTitle.color = AppTheme.GREY_MEDIUM;
			
			textFormatPurposeTitle.font = Config.defaultFontName;
			textFormatPurposeTitle.size = Config.FINGER_SIZE * .25;
			textFormatPurposeTitle.color = AppTheme.GREY_MEDIUM;
			
			textFormatAmountCancelled.font = Config.defaultFontName;
			textFormatAmountCancelled.size = Config.FINGER_SIZE * .35;
			textFormatAmountCancelled.color = AppTheme.GREY_MEDIUM;
			
			textFormatAmount.font = Config.defaultFontName;
			textFormatAmount.size = Config.FINGER_SIZE * .35;
			textFormatAmount.color = AppTheme.GREY_DARK;
			
			textFormatPurpose.font = Config.defaultFontName;
			textFormatPurpose.size = Config.FINGER_SIZE * .25;
			textFormatPurpose.color = AppTheme.GREY_DARK;
			
			textFormatPurposeCancelled.font = Config.defaultFontName;
			textFormatPurposeCancelled.size = Config.FINGER_SIZE * .25;
			textFormatPurposeCancelled.color = AppTheme.GREY_MEDIUM;
			
			textFormatPayButton.font = Config.defaultFontName;
			textFormatPayButton.size = Config.FINGER_SIZE * .28;
			textFormatPayButton.align = TextFormatAlign.CENTER;
			textFormatPayButton.color = MainColors.WHITE;
			
			textFormatCancelButton.font = Config.defaultFontName;
			textFormatCancelButton.size = Config.FINGER_SIZE * .28;
			textFormatCancelButton.align = TextFormatAlign.CENTER;
			textFormatCancelButton.color = AppTheme.GREEN_LIGHT;
			
			textFormatRetryButton.font = Config.defaultFontName;
			textFormatRetryButton.size = Config.FINGER_SIZE * .28;
			textFormatRetryButton.align = TextFormatAlign.CENTER;
			textFormatRetryButton.color = AppTheme.GREEN_LIGHT;
			
			textFormatStatus.align = TextFormatAlign.LEFT;
			textFormatStatus.font = Config.defaultFontName;
			textFormatStatus.size = Config.FINGER_SIZE * .28;
			textFormatStatus.color = AppTheme.GREY_DARK;
			
			textFormatStatusCenterAlign.font = Config.defaultFontName;
			textFormatStatusCenterAlign.align = TextFormatAlign.CENTER;
			textFormatStatusCenterAlign.size = Config.FINGER_SIZE * .28;
			textFormatStatusCenterAlign.color = AppTheme.GREY_DARK;
		}
		
		private function init():void {
			initTextFormats();
			
			invoiceContainer = new Sprite();
			addChild(invoiceContainer);
			
			textBoxRadius = Math.ceil(Config.FINGER_SIZE * .25);
			paddingSide = Config.FINGER_SIZE * .25;
			paddingVertical = Config.FINGER_SIZE * .13;
			
			contentContainer = new Sprite();
			
			mainBack = new Shape();
			invoiceContainer.addChild(mainBack);
			
			var bgSize:int = textBoxRadius * 3;
			
			mainBack.graphics.beginFill(MainColors.WHITE, 1);
			mainBack.graphics.drawRoundRectComplex(0, 0, bgSize, bgSize, textBoxRadius, textBoxRadius, 0, 0);
			mainBack.graphics.endFill();
			mainBack.scale9Grid = new Rectangle(textBoxRadius, textBoxRadius, bgSize - textBoxRadius * 2, bgSize - textBoxRadius * 2);
			
			amountBack = new Sprite();
			contentContainer.addChild(amountBack);
			
			amountTitle = new TextField();
				amountTitle.defaultTextFormat = textFormatAmountTitle;
				amountTitle.text = "Pp";
				amountTitle.height = amountTitle.textHeight + 4;
				amountTitle.text = "";
				amountTitle.wordWrap = true;
				amountTitle.multiline = true;
			contentContainer.addChild(amountTitle);
			
			purposeTitle = new TextField();
				purposeTitle.defaultTextFormat = textFormatPurposeTitle;
				purposeTitle.text = "Pp";
				purposeTitle.height = purposeTitle.textHeight + 4;
				purposeTitle.text = "";
				purposeTitle.wordWrap = false;
				purposeTitle.multiline = false;
			contentContainer.addChild(purposeTitle);
			
			amount = new TextField();
				amount.defaultTextFormat = textFormatAmount;
				amount.text = "Pp";
				amount.height = amount.textHeight + 4;
				amount.text = "";
				amount.wordWrap = false;
				amount.multiline = false;
			contentContainer.addChild(amount);
			
			purpose = new TextField();
				purpose.defaultTextFormat = textFormatPurpose;
				purpose.text = "Pp";
				purpose.height = purpose.textHeight + 4;
				purpose.text = "";
				purpose.wordWrap = true;
				purpose.multiline = true;
			contentContainer.addChild(purpose);
			
			dashedLine = new Sprite();
			invoiceContainer.addChild(dashedLine);
			
			bottomLine = new Sprite();
			invoiceContainer.addChild(bottomLine);
			
			statusLabel = new TextField();
				statusLabel.defaultTextFormat = textFormatStatus;
				statusLabel.text = "Pp";
				statusLabel.height = statusLabel.textHeight + 4;
				statusLabel.text = "";
				statusLabel.autoSize = TextFieldAutoSize.LEFT;
				statusLabel.wordWrap = true;
				statusLabel.multiline = true;
			contentContainer.addChild(statusLabel);
			
			rejectedIcon = new CancelButtonIconRed();
			UI.scaleToFit(rejectedIcon, int(Config.FINGER_SIZE * .3), int(Config.FINGER_SIZE * .3));
			contentContainer.addChild(rejectedIcon);
			
			var raduis:int = Config.FINGER_SIZE * 1.2;
			
			acceptedIcon = new Sprite();
			acceptedIcon.graphics.beginFill(MainColors.GREEN, 1);
			acceptedIcon.graphics.drawCircle(int(raduis / 2), int(raduis / 2), int(raduis / 2));
			acceptedIcon.graphics.endFill();
			contentContainer.addChild(acceptedIcon);
			
			invoiceContainer.addChild(contentContainer);
			
			var icon:IconDone = new IconDone();
			UI.scaleToFit(icon, int(raduis * 0.6), int(raduis * 0.6));
			acceptedIcon.addChild(icon);
			icon.x = int(raduis * .5 - icon.width * .5);
			icon.y = int(raduis * .5 - icon.height * .5);
			
			amountTitle.x = paddingSide;
			amountBack.x = paddingSide;
			purposeTitle.x = paddingSide;
			purpose.x = paddingSide;
			amount.x = int(amountBack.x + Config.FINGER_SIZE * .2);
			
		}
		
		public function getHeight(itemData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint {
			data = itemData.systemMessageVO.invoiceVO;
			
			if (data == null)
				return 0;		
			
			updateIsMine(data);
			
			createElements();
			
			initElements(maxWidth, data.forwardedFromUserID != null);
			this.itemWidth = maxWidth;
			
			var statusLabelHeight:int = redrawStatusLabel(data);
			var purposeLabelHeight:int = redrawPurpose(data);
			var titleHeight:int = redrawAmountTitle(data);
			var yPos:int = paddingVertical * 4.6 + titleHeight + amount.height + Config.FINGER_SIZE * .2;
			
			if (data.message != null && data.message != "")
				yPos += purposeTitle.height + purposeLabelHeight + paddingVertical * 2;
			
			if (data.status == InvoiceStatus.ACCEPTED) {
				if (isSentByMe == true)
					yPos += statusLabelHeight + acceptedIcon.height + paddingVertical * 2;
				else
					yPos += statusLabelHeight + acceptedIcon.height + paddingVertical * 3 + payButton.height;
			} else if (data.status == InvoiceStatus.REJECTED)
				yPos += statusLabelHeight;
			else if (data.status == InvoiceStatus.CANCELLED)
				yPos += statusLabelHeight;
			else if (data.status == InvoiceStatus.NEW)
				yPos += payButton.height;
			
			yPos += Config.FINGER_SIZE * .21;
			
			if (data.forwardedFromUserID != null)
				yPos += forwardView.textCommentHeight + Config.FINGER_SIZE * .2;
				
			if (data.showCancel == false && isSentByMe && data.status == InvoiceStatus.NEW) {
				yPos -= cancelButton.height;
			}
			lastHeight = yPos;
			return yPos;
		}
		
		private function createElements():void {
			if (data.status == InvoiceStatus.NEW || 
				(data.status == InvoiceStatus.ACCEPTED && isSentByMe == false)) {
				createPayButton();
				redrawPayButton();
			}
			if (data.status == InvoiceStatus.NEW || data.showCancel == true) {
				createCancelButton();
				redrawCancelButton();
			}
			if (data.status == InvoiceStatus.ACCEPTED) {
				createRetryButton();
				redrawRetryButton();
			}
		}
		
		private function createRetryButton():void {
			if (retryButton != null)
				return;
			
			retryButton = new Sprite();
			contentContainer.addChild(retryButton);
			
			retryButtonText = new TextField();
				retryButtonText.defaultTextFormat = textFormatRetryButton;
				retryButtonText.text = "Pp";
				retryButtonText.height = retryButtonText.textHeight + 4;
				retryButtonText.text = "";
				retryButtonText.wordWrap = false;
				retryButtonText.multiline = false;
			retryButton.addChild(retryButtonText);
		}
		
		private function createCancelButton():void {
			if (cancelButton != null)
				return;
			
			cancelButton = new Sprite();
			contentContainer.addChild(cancelButton);
			
			cancelButtonText = new TextField();
				cancelButtonText.defaultTextFormat = textFormatCancelButton;
				cancelButtonText.text = "Pp";
				cancelButtonText.height = cancelButtonText.textHeight + 4;
				cancelButtonText.text = "";
				cancelButtonText.wordWrap = false;
				cancelButtonText.multiline = false;
			cancelButton.addChild(cancelButtonText);
		}
		
		private function createPayButton():void {
			if (payButton != null)
				return;
			
			payButton = new Sprite();
			contentContainer.addChild(payButton);
			payButton.x = paddingSide;
			payButtonText = new TextField();
				payButtonText.defaultTextFormat = textFormatPayButton;
				payButtonText.text = "Pp";
				payButtonText.height = payButtonText.textHeight + 4;
				payButtonText.text = "";
				payButtonText.wordWrap = false;
				payButtonText.multiline = false;
			payButton.addChild(payButtonText);
		}
		
		private function initElements(widthValue:int, isForwarded:Boolean):void {
			if (lastInitWidth == widthValue && isLastForwarded == isForwarded)
				return;
			lastInitWidth = widthValue;
			isLastForwarded = isForwarded;
			isLastForwarded = isForwarded;
			lastInitBackgroundWidth = widthValue
			if (isForwarded == true) {
				var quotesOffset:int = forwardView.rightQuoteWidth + Config.FINGER_SIZE * .24;
				lastInitBackgroundWidth = widthValue - quotesOffset;
			}
			
			redrawPurposeTitle();
			redrawPayButton();
			redrawCancelButton();
			redrawRetryButton();
			
			dashedLine.graphics.clear();
			dashedLine.graphics.lineStyle(1, AppTheme.GREY_SEMI_LIGHT);
			BaseGraphicsUtils.drawDash(dashedLine.graphics, 0, 0, lastInitBackgroundWidth, 0, int(Config.FINGER_SIZE * 0.14), int(Config.FINGER_SIZE * 0.07));
			
			redrawBottomTriangles();
		}
		
		private function updateIsMine(data:ChatMessageInvoiceData):void {
			mine = (data.fromUserUID == Auth.uid);
			isToMe = (data.toUserUID == Auth.uid);
			isSentByMe = mine;
			if (data.forwardedFromUserID != null)
				isSentByMe = (data.forwardedFromUserID == Auth.uid);
		}
		
		public function draw(messageData:ChatMessageVO, itemWidth:int, listItem:ListItem = null, securityKey:Array = null):void {
			data = messageData.systemMessageVO.invoiceVO;
			
			if (data == null)
				return;
			
			initElements(itemWidth, data.forwardedFromUserID != null);
			
			this.data = data;
			this.itemWidth = itemWidth;
			updateIsMine(data);
			var quotesOffset:int = 0;
			var isForwarded:Boolean = data.forwardedFromUserID != null;
			if (isForwarded)
				quotesOffset = Config.FINGER_SIZE * .24;
			else
				removeForwardView();
			
			redrawAmountTitle(data);
			redrawAmount();
			redrawPurpose(data);
			var statusLabelHeight:int = redrawStatusLabel(data);
			
			var yPos:int = paddingVertical;
			amountTitle.y = yPos;
			
			yPos = amountTitle.y + amountTitle.height + paddingVertical;
			amountBack.y = yPos;
			
			yPos = amountBack.y + Config.FINGER_SIZE * .1;
			amount.y = yPos;
			
			yPos = amountBack.y + amountBack.height + paddingVertical;
			purposeTitle.y = yPos;
			
			yPos = purposeTitle.y + purposeTitle.height + paddingVertical;
			purpose.y = yPos;
			
			if (data.message != null && data.message != "")
				yPos = purpose.y + purpose.height + paddingVertical;
			else
				yPos = amountBack.y + amountBack.height + paddingVertical;
			
			dashedLine.y = yPos;
			
			yPos += paddingVertical;
			
			if(payButton != null)
				payButton.y = yPos;
			
			if (retryButton != null)
				retryButton.x = int(lastInitBackgroundWidth * .5 - retryButton.width * .5);
			
			if (data.showCancel == true){
				if (isSentByMe == true) 
				{
					if (cancelButton == null)
					{
						createCancelButton();
					}
					cancelButton.x = int(lastInitBackgroundWidth * .5 - cancelButton.width * .5);
				} else {
					if (payButton != null && cancelButton != null) {
						payButton.x = paddingSide;
						if (cancelButton == null)
						{
							createCancelButton();
						}
						cancelButton.x = payButton.x + payButton.width + paddingSide;
					}
				}
				if (cancelButton != null && cancelButton.parent == null) {
					contentContainer.addChild(cancelButton);
				}
				if (cancelButton != null)
					cancelButton.y = yPos;
			} else {
				if (cancelButton != null && cancelButton.parent != null) {
					cancelButton.parent.removeChild(cancelButton);
				}
				if (payButton != null && cancelButton != null)
					payButton.x = int(lastInitBackgroundWidth * .5 - payButton.width * .5);
			}
			
			var resHeight:int = 0;
			if (data.status == InvoiceStatus.ACCEPTED) {
				statusLabel.x = int(lastInitBackgroundWidth * .5 - statusLabel.width * .5);
				
				acceptedIcon.x = int(lastInitBackgroundWidth * .5 - acceptedIcon.width * .5);
				acceptedIcon.y = int(dashedLine.y + paddingVertical * 2);
				
				statusLabel.y = int(acceptedIcon.y + acceptedIcon.height + paddingVertical);
				retryButton.y = int(statusLabel.y + statusLabel.height + paddingVertical);
				if (isSentByMe == true)
					resHeight = retryButton.y;
				else
					resHeight = retryButton.y + retryButton.height + paddingVertical;
			} else if (data.status == InvoiceStatus.REJECTED) {
				statusLabel.y = int(dashedLine.y + paddingVertical);
				rejectedIcon.y = int(statusLabel.y + statusLabel.height * .5 - rejectedIcon.height * .5);
				
				rejectedIcon.x = int(lastInitBackgroundWidth * .5 - (statusLabel.width + rejectedIcon.width + Config.MARGIN) * .5);
				statusLabel.x = int(rejectedIcon.x + rejectedIcon.width + Config.MARGIN);
				
				resHeight = statusLabel.y + statusLabel.height + paddingVertical;
			} else if (data.status == InvoiceStatus.CANCELLED) {
				statusLabel.y = int(dashedLine.y + paddingVertical);
				rejectedIcon.y = int(statusLabel.y + statusLabel.height * .5 - rejectedIcon.height * .5);
				
				rejectedIcon.x = int(lastInitBackgroundWidth * .5 - (statusLabel.width + rejectedIcon.width + Config.MARGIN) * .5);
				statusLabel.x = int(rejectedIcon.x + rejectedIcon.width + Config.MARGIN);
				
				resHeight = statusLabel.y + statusLabel.height + paddingVertical;
			} else if (data.status == InvoiceStatus.NEW) {
				resHeight = payButton.y + payButton.height + paddingVertical;
			}
			
			if (data.showCancel == false && isSentByMe && data.status == InvoiceStatus.NEW)
			{
				resHeight -= cancelButton.height;
			}
			mainBack.height = resHeight;
			mainBack.width = lastInitBackgroundWidth;
			if (isForwarded == true) {
				invoiceContainer.x = forwardView.rightQuoteWidth + quotesOffset;
				forwardView.coverDisplayObject(mainBack, messageData, itemWidth,!isSentByMe);
				addChild(forwardView);
			} else {
				if (isContainsForwardView)
					removeChild(forwardView);
				invoiceContainer.x = 0;
			}
			updateElementsVisibility();
			
			bottomLine.y = mainBack.y + mainBack.height;
		}
		
		override public function dispose():void {
			super.dispose();
			var displayItems:Dictionary = new Dictionary();
			
			UI.destroy(mainBack);
			mainBack = null;
			UI.destroy(amountBack);
			amountBack = null;
			UI.destroy(amountTitle);
			amountTitle = null;
			UI.destroy(purposeTitle);
			purposeTitle = null;
			UI.destroy(amount);
			amount = null;
			UI.destroy(purpose);
			purpose = null;
			UI.destroy(contentContainer);
			contentContainer = null;
			
			if(payButton != null)
				UI.destroy(payButton);
			payButton = null;
			
			if(cancelButton != null)
				UI.destroy(cancelButton);
			cancelButton = null;
			
			if(payButtonText != null)
				UI.destroy(payButtonText);
			payButtonText = null;
			
			if(cancelButtonText != null)
				UI.destroy(cancelButtonText);
			cancelButtonText = null;
			
			UI.destroy(bottomLine);
			bottomLine = null;
			UI.destroy(dashedLine);
			dashedLine = null;
			UI.destroy(statusLabel);
			statusLabel = null;
			UI.destroy(dashedLine);
			dashedLine = null;
			
			if(retryButton != null)
				UI.destroy(retryButton);
			retryButton = null;
			
			if(retryButtonText != null)
				UI.destroy(retryButtonText);
			retryButtonText = null;
			
			UI.destroy(acceptedIcon);
			acceptedIcon = null;
			
			data = null;
			
			textFormatAmountTitle = null;
			textFormatPurposeTitle = null;
			textFormatAmountCancelled = null;
			textFormatAmount = null;
			textFormatPurpose = null;
			textFormatPurposeCancelled = null;
			textFormatPayButton = null;
			textFormatCancelButton = null;
			textFormatRetryButton = null;
			textFormatStatus = null;
			textFormatStatusCenterAlign = null;
		}
		
		private function updateElementsVisibility():void {
			if(retryButton != null)
				retryButton.visible = false;
			if (data.status == InvoiceStatus.NEW) {
				if (isSentByMe == true) {
					if(payButton != null)
						payButton.visible = false;
				}
				else {
					if(payButton != null)
						payButton.visible = true;
				}
				if(cancelButton != null)
					cancelButton.visible = true;
				if(retryButton != null)
					retryButton.visible = false;
				rejectedIcon.visible = false;
				acceptedIcon.visible = false;
				statusLabel.visible = false;
			} else if (data.status == InvoiceStatus.REJECTED) {
				if(payButton != null)
					payButton.visible = false;
				if(cancelButton != null)
					cancelButton.visible = false;
				if(retryButton != null)
					retryButton.visible = false;
				acceptedIcon.visible = false;
				rejectedIcon.visible = true;
				statusLabel.visible = true;
			} else if (data.status == InvoiceStatus.CANCELLED) {
				if(payButton != null)
					payButton.visible = false;
				if(cancelButton != null)
					cancelButton.visible = false;
				if(retryButton != null)
					retryButton.visible = false;
				acceptedIcon.visible = false;
				rejectedIcon.visible = true;
				statusLabel.visible = true;
			} else if (data.status == InvoiceStatus.ACCEPTED) {
				if(payButton != null)
					payButton.visible = false;
				if(cancelButton != null)
					cancelButton.visible = false;
				if (!isSentByMe){
					if(retryButton != null)
						retryButton.visible = true;
				}
				acceptedIcon.visible = true;
				rejectedIcon.visible = false;
				statusLabel.visible = true;
			}
			if (data.message != null && data.message != "") {
				purpose.visible = true;
				purposeTitle.visible = true;
			} else {
				purpose.visible = false;
				purposeTitle.visible = false;
			}
		}
		
		private function redrawBottomTriangles():void {
			var triangles:int = lastInitBackgroundWidth / (Config.FINGER_SIZE * .25);
			bottomLine.graphics.clear();
			bottomLine.graphics.beginFill(MainColors.WHITE, 1);
			var triangleWidth:Number = lastInitBackgroundWidth / triangles;
			bottomLine.graphics.moveTo(0, triangleWidth / 2);
			for (var i:int = 0; i < triangles; i++) {
				bottomLine.graphics.lineTo(triangleWidth * i + triangleWidth / 2, 0);
				bottomLine.graphics.lineTo(triangleWidth * (i + 1), triangleWidth / 2);
			}
			bottomLine.graphics.lineTo(triangleWidth * (i), 0);
			bottomLine.graphics.lineTo(0, 0);
			bottomLine.graphics.endFill();
		}
		
		private function redrawRetryButton():void {
			if (retryButton == null)
				return;
			
			retryButtonText.text = Lang.retryPayment;
			retryButtonText.width = retryButtonText.textWidth + 4;
			var retryButttonWidth:int = retryButtonText.width + Config.MARGIN * 2;
			if (retryButttonWidth >= lastInitWidth - Config.FINGER_SIZE / 2) {
				retryButttonWidth = lastInitWidth - Config.FINGER_SIZE / 2
			}
			retryButtonText.width = retryButttonWidth - Config.MARGIN * 2;
			TextUtils.truncate(retryButtonText);
			
			retryButton.graphics.clear();
			retryButton.graphics.lineStyle(1, MainColors.GREEN_LIGHT, 1, true);
			retryButton.graphics.beginFill(MainColors.WHITE);
			retryButton.graphics.drawRoundRect(0, 0, retryButttonWidth, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			retryButton.graphics.endFill();
			retryButtonText.x = int(retryButttonWidth * .5 - retryButtonText.width * .5);
			retryButtonText.y = int(Config.FINGER_SIZE * .3 - retryButtonText.height * .5);
		}
		
		private function redrawStatusLabel(dataObject:ChatMessageInvoiceData):int {
			var statusText:String = "";
			switch(dataObject.status) {
				case InvoiceStatus.REJECTED:
					if (isSentByMe == true)
						statusText = dataObject.toUserName + " " + Lang.cancelledPayment;
					else
						statusText = Lang.youCancelledPayment;
					break;
				case InvoiceStatus.CANCELLED:
					if (mine == true)
						statusText = Lang.youCancelledInvoice;
					else if (dataObject.forwardedFromUserID == null)
						statusText = dataObject.fromUserName + " " + Lang.cancelledInvoice;
					else
						statusText = dataObject.forwardedFromUserName + " " + Lang.cancelledInvoice;
					break;
				case InvoiceStatus.ACCEPTED:
					if (isSentByMe == true)
						statusText = dataObject.toUserName + " " + Lang.acceptedPayment;
					else
						statusText = Lang.youAcceptedPayment;
					break;
				case InvoiceStatus.NEW:
					statusText = "new message";
					break;
				default:
					statusText = "default";
					break;
			}
			
			var statusMaxWidth:int;
			if (dataObject.status == InvoiceStatus.REJECTED || dataObject.status == InvoiceStatus.CANCELLED)
				statusMaxWidth = lastInitBackgroundWidth - paddingSide * 2 - rejectedIcon.width - Config.MARGIN;
			else
				statusMaxWidth = lastInitBackgroundWidth - paddingSide * 2;

			statusLabel.text = statusText;
			statusLabel.width = statusMaxWidth;
			statusLabel.height = statusLabel.textHeight + 4;
			
			if (dataObject.status == InvoiceStatus.ACCEPTED)
				statusLabel.setTextFormat(textFormatStatusCenterAlign);
			else
				statusLabel.setTextFormat(textFormatStatus);
			return statusLabel.height;
		}
		
		private function redrawPayButton():void {
			if (payButton == null)
				return;
			
			payButtonText.text = Lang.textPay;
			var buttonWidth:int = (lastInitBackgroundWidth - paddingSide * 3) / 2;
			payButtonText.width = buttonWidth;
			TextUtils.truncate(payButtonText);
			
			payButton.graphics.clear();
			payButton.graphics.lineStyle(1, MainColors.GREEN_LIGHT, 1, true);
			payButton.graphics.beginFill(MainColors.GREEN_LIGHT);
			payButton.graphics.drawRoundRect(0, 0, buttonWidth, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			payButton.graphics.endFill();
			payButtonText.x = int(((lastInitBackgroundWidth - paddingSide * 3) / 2) * .5 - payButtonText.width * .5);
			payButtonText.y = int(Config.FINGER_SIZE * .3 - payButtonText.height * .5);
		}
		
		private function redrawCancelButton():void {
			if (cancelButton == null)
				return;
			
			cancelButtonText.text =  Lang.textCancel;
			var buttonWidth:int = (lastInitBackgroundWidth - paddingSide * 3) / 2;
			cancelButtonText.width = buttonWidth;
			TextUtils.truncate(cancelButtonText);
			
			cancelButton.graphics.clear();
			cancelButton.graphics.lineStyle(1, MainColors.GREEN_LIGHT, 1, true);
			cancelButton.graphics.beginFill(MainColors.WHITE);
			cancelButton.graphics.drawRoundRect(0, 0, buttonWidth, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			cancelButton.graphics.endFill();
			cancelButtonText.x = int(((lastInitBackgroundWidth - paddingSide * 3) / 2) * .5 - cancelButtonText.width * .5);
			cancelButtonText.y = int(Config.FINGER_SIZE * .3 - cancelButtonText.height * .5);
		}
		
		private function redrawPurpose(data:ChatMessageInvoiceData):int {
			purpose.text = (data.message == null) ? "" : data.message;
		//	purpose.text = data.message;
			updateIsMine(data);
			var quotesOffset:int = 0;
			var isForwarded:Boolean = data.forwardedFromUserID != null;
			if (isForwarded)
				quotesOffset = (forwardView.leftQuoteWidth + Config.FINGER_SIZE * .24);	
			purpose.width = lastInitBackgroundWidth - paddingSide * 2 - quotesOffset;
			
			if (data.status == InvoiceStatus.REJECTED || data.status == InvoiceStatus.CANCELLED)
				purpose.setTextFormat(textFormatPurposeCancelled);
			else
				purpose.setTextFormat(textFormatPurpose);
			purpose.height = purpose.textHeight + 4;
			return purpose.textHeight + 4;
		}
		
		private function redrawAmount():void {
			if (data.status == InvoiceStatus.REJECTED || data.status == InvoiceStatus.CANCELLED)
				amount.defaultTextFormat = textFormatAmountCancelled;
			else
				amount.defaultTextFormat = textFormatAmount;
			
			var currencyText:String = data.currency;
			if (Lang[currencyText] != null)
			{
				currencyText = Lang[currencyText];
			}
			amount.text = currencyText + " " + data.amount;
			amount.width = amount.textWidth + 4;
			amountBack.graphics.clear();
			amountBack.graphics.beginFill(AppTheme.GREY_LIGHT, 1);
			amountBack.graphics.drawRoundRect(
				0,
				0,
				int(amount.width + Config.FINGER_SIZE * .4), 
				int(amount.height + Config.FINGER_SIZE * .2), 
				Config.FINGER_SIZE * .1, 
				Config.FINGER_SIZE * .1
			);
			amountBack.graphics.endFill();
		}
		
		private function redrawAmountTitle(dataObject:ChatMessageInvoiceData):int {
			var titleText:String = "";
			if (mine == true) {
				titleText = Lang.youSentInvoiceTo + " " + dataObject.toUserName;
			} else {
				//var user:UserProfileVO = UserProfileManager.getUserData(dataObject.fromUserUID, false);
				var userName:String;
				//if (user != null)
					//userName = user.name;
				//else
					userName = dataObject.fromUserName;
				if (isToMe == true)
					titleText = userName + " " + Lang.sendYouInvoice;
				else if (dataObject.toUserName != null)
					titleText = userName + " " + Lang.sendInvoiceTo + " " + dataObject.toUserName;
				else
					titleText = "";
			}
			amountTitle.text = titleText;
			amountTitle.width = lastInitBackgroundWidth - paddingSide * 2;
			
			amountTitle.height = amountTitle.textHeight + 4;
			
			return amountTitle.textHeight + 4;
		}
		
		private function redrawPurposeTitle():void {
			purposeTitle.text = Lang.purposeOfPayment;
			purposeTitle.width = lastInitBackgroundWidth - paddingSide * 2;
		}
		
		public function getCurrentHeight():int {
			return int(mainBack.height);
		}
		
		private function getHitzoneItem(item:Sprite, type:String):Object {
			return { type:type, x:item.x, y:item.y, width:item.width, height:item.height};
		}
		
		override public function get width():Number {
			if (isContainsForwardView == true)
				return forwardView.width;
			return mainBack.width;
		}
		
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
	}
}