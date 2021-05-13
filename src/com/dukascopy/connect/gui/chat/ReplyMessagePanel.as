package com.dukascopy.connect.gui.chat 
{
	import assets.NewCloseIcon;
	import assets.ReplyIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ReplyMessagePanel extends Sprite
	{
		private var userName:Bitmap;
		private var message:Bitmap;
		private var iconReply:ReplyIcon;
		private var closeButton:BitmapButton;
		private var itemWidth:int;
		private var drawn:Boolean;
		private var position:int;
		private var animationTime:Number = 0.3;
		private var animData:Object;
		private var container:Sprite;
		private var onRemove:Function;
		private var hPadding:Number;
		private var isDisposed:Boolean;
		private var vPadding:Number;
		private var maskClip:Sprite;
		private var data:ChatMessageVO;
		private var onTapCallback:Function;
		private var onResize:Function;
		
		public function ReplyMessagePanel(onRemove:Function, onTap:Function, onResize:Function) 
		{
			this.onRemove = onRemove;
			this.onTapCallback = onTap;
			this.onResize = onResize;
			
			container = new Sprite();
			addChild(container);
			
			maskClip = new Sprite();
			addChild(maskClip);
			
			container.mask = maskClip;
			
			hPadding = Config.FINGER_SIZE * .23;
			vPadding = Config.FINGER_SIZE * .21;
			userName = new Bitmap();
			userName.y = vPadding;
			container.addChild(userName);
			
			message = new Bitmap();
			container.addChild(message);
			
			iconReply = new ReplyIcon();
			var iconSize:int = Config.FINGER_SIZE * .4;
			UI.scaleToFit(iconReply, iconSize, iconSize);
			iconReply.x = hPadding;
			container.addChild(iconReply);
			
			userName.x = int(iconReply.x + iconReply.width + hPadding);
			message.x = int(iconReply.x + iconReply.width + hPadding);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownColor(NaN);
			closeButton.setDownScale(0.7);
			closeButton.setOverlay(HitZoneType.CIRCLE);
			closeButton.cancelOnVerticalMovement = true;
			closeButton.tapCallback = onButtonCloseClick;
			closeButton.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			closeButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			closeButton.activate();
			container.addChild(closeButton);
			
			var icon:NewCloseIcon = new NewCloseIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .3), int(Config.FINGER_SIZE * .3));
			closeButton.setBitmapData(UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS))));
			UI.destroy(icon);
			
			PointerManager.addTap(container, onTapEvent);
		}
		
		private function onTapEvent(e:Event = null):void 
		{
			if (onTapCallback != null)
			{
				onTapCallback(data);
			}
		}
		
		private function onButtonCloseClick():void 
		{
			closeButton.deactivate();
			if (animData != null)
			{
				TweenMax.killTweensOf(animData);
			}
			animData = new Object();
			animData.value = height;
			PointerManager.removeTap(container, onTapCallback);
			TweenMax.to(animData, animationTime, {value:0, onUpdate:update, onComplete:remove});
		}
		
		private function remove():void 
		{
			if (onRemove != null)
			{
				onRemove();
			}
		}
		
		public function setPosition(value:int):void
		{
			y = value;
		}
		
		public function draw(messageVO:ChatMessageVO, itemWidth:int, animate:Boolean = true):Boolean
		{
			data = messageVO;
			
			this.itemWidth = itemWidth;
			graphics.clear();
			var text:String = getText(messageVO);
			var user:String = getUserName(messageVO);
			
			if (text != null && user != null)
			{
				drawName(user);
				drawMessage(text);
				
				message.y = int(userName.y + userName.height + vPadding);
				
				var resultHeight:int = message.y + message.height + vPadding;
				
				closeButton.x = int(itemWidth - closeButton.width - hPadding);
				closeButton.y = int(resultHeight * .5 - closeButton.height * .5);
				
				iconReply.y = int(resultHeight * .5 - iconReply.height * .5);
				
				container.graphics.clear();
				container.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				container.graphics.drawRect(0, 0, itemWidth, resultHeight);
				container.graphics.endFill();
				
				container.graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER));
				container.graphics.drawRect(0, 0, itemWidth, 1);
				container.graphics.endFill();
				
				container.graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER));
				container.graphics.drawRect(0, resultHeight - 1, itemWidth, 1);
				container.graphics.endFill();
				
				maskClip.graphics.beginFill(0);
				maskClip.graphics.drawRect(0, 0, itemWidth, resultHeight);
				maskClip.graphics.endFill();
				maskClip.y = - resultHeight;
				
				if (animate == true)
				{
					animData = new Object();
					animData.value = 0;
					TweenMax.to(animData, animationTime, {value:resultHeight, onUpdate:update});
				}
				else
				{
					container.y = - resultHeight;
				}
				
				return true;
			}
			else
			{
				ApplicationErrors.add();
				return false;
			}
		}
		
		private function update():void 
		{
			if (isDisposed)
			{
				return;
			}
			container.y = - animData.value;
			if (onResize != null)
			{
				onResize();
			}
		}
		
		private function drawName(text:String):void 
		{
			if (userName.bitmapData != null)
			{
				userName.bitmapData.dispose();
				userName.bitmapData = null;
			}
			userName.bitmapData = TextUtils.createTextFieldData(text, getTextWidth(itemWidth), 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.SUBHEAD, false, Color.BLUE);
		}
		
		private function drawMessage(text:String):void 
		{
			if (message.bitmapData != null)
			{
				message.bitmapData.dispose();
				message.bitmapData = null;
			}
			message.bitmapData = TextUtils.createTextFieldData(text, getTextWidth(itemWidth), 10, 
																false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.SUBHEAD, false, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), false, false, true);
		}
		
		private function getUserName(messageVO:ChatMessageVO):String 
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.COMPANY)
			{
				if (messageVO.userUID != Auth.uid)
				{
					return Lang.textSupport;
				}
			}
			
			if (messageVO != null && messageVO.userVO != null)
			{
				return messageVO.userVO.getDisplayName();
			}
			
			return null;
		}
		
		private function getText(messageVO:ChatMessageVO):String 
		{
			if (messageVO != null)
			{
				return messageVO.text;
			}
			return null;
		}
		
		private function getTextWidth(itemWidth:int):int 
		{
			return itemWidth - closeButton.width - iconReply.width - hPadding * 4;
		}
		
		public function dispose():void
		{
			isDisposed = true;
			
			data = null;
			onRemove = null;
			onTapCallback = null;
			onResize = null;
			animData = null;
			
			PointerManager.removeTap(container, onTapCallback);
			
			if (animData != null)
			{
				TweenMax.killTweensOf(animData);
			}
			
			if (userName != null)
			{
				UI.destroy(userName);
				userName = null;
			}
			if (message != null)
			{
				UI.destroy(message);
				message = null;
			}
			if (iconReply != null)
			{
				UI.destroy(iconReply);
				iconReply = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (maskClip != null)
			{
				UI.destroy(maskClip);
				maskClip = null;
			}
			if (closeButton != null)
			{
				closeButton.dispose();
				closeButton = null;
			}
		}
		
		public function getHeight():int 
		{
			if (container != null)
			{
				return -container.y;
			}
			return 0;
		}
		
		public function getMessage():String 
		{
			return data.text;
		}
		
		public function removePanel():void 
		{
			onButtonCloseClick();
		}
		
		public function getReplayNum():int 
		{
			return data.num;
		}
		
		public function getUser():String 
		{
			if (data != null && data.userVO != null)
			{
				return data.userVO.getDisplayName();
			}
			
			return "";
		}
	}
}