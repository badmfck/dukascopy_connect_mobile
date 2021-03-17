package com.dukascopy.connect.screens.layout
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TitleScreen extends BaseScreen
	{
		private var topBar:TopBarScreen;
		private var horizontalLoader:HorizontalPreloader;
		
		private var messageClip:Sprite;
		private var messageText:Bitmap;
		
		private var back:Sprite;
		
		public function TitleScreen()
		{
		
		}
		
		override protected function createView():void
		{
			super.createView();
			
			back = new Sprite();
			_view.addChild(back);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		protected function overrideOnBack(call:Function):void
		{
			if (topBar != null)
			{
				topBar.onBackFunction = call;
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		override protected function drawView():void
		{
			super.drawView();
			back.graphics.clear();
			back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			back.graphics.drawRect(0, 0, _width, _height);
			back.graphics.endFill();
		}
		
		protected function showMessage(message:String, success:Boolean = false):void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (message == null)
			{
				message = Lang.textError;
			}
			
			removeMessageClip();
			
			messageClip = new Sprite();
			messageText = new Bitmap();
			messageClip.addChild(messageText);
			messageText.x = Config.DIALOG_MARGIN;
			messageText.y = Config.DIALOG_MARGIN + Config.APPLE_TOP_OFFSET;
			view.addChild(messageClip);
			
			var backColor:Number;
			if (success)
			{
				backColor = Color.GREEN;
			}
			else
			{
				backColor = Color.RED;
			}
			messageText.bitmapData = TextUtils.createTextFieldData(message, _width - Config.DIALOG_MARGIN * 2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Color.WHITE, backColor, false, true);
			messageClip.graphics.beginFill(backColor);
			messageClip.graphics.drawRect(0, 0, _width, Config.DIALOG_MARGIN * 2 + Config.APPLE_TOP_OFFSET + messageText.height);
			messageClip.y = -messageClip.height;
			TweenMax.to(messageClip, 0.3, {ease: Power3.easeOut, y: 0});
			TweenMax.to(messageClip, 0.3, {ease: Power3.easeIn, y: -messageClip.height, onComplete: removeMessageClip, delay: 5});
		}
		
		protected function removeMessageClip():void
		{
			if (messageClip != null)
			{
				TweenMax.killTweensOf(messageClip);
				if (view.contains(messageClip))
				{
					view.removeChild(messageClip);
				}
				UI.destroy(messageClip);
				messageClip = null;
			}
			if (messageText != null)
			{
				UI.destroy(messageText);
				messageText = null;
			}
		}
		
		protected function showPreloader():void
		{
			if (horizontalLoader == null)
			{
				horizontalLoader = new HorizontalPreloader(Color.GREEN);
				horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
				view.addChild(horizontalLoader);
				horizontalLoader.y = topBar.y + topBar.trueHeight;
			}
			horizontalLoader.start();
		}
		
		protected function hidePreloader():void
		{
			if (horizontalLoader != null)
			{
				horizontalLoader.stop();
			}
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			var title:String = "";
			if (data != null && "title" in data && data.title != null)
			{
				title = data.title;
			}
			topBar.setData(title, true);
			topBar.drawView(_width);
			
			if (horizontalLoader != null)
			{
				horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
				horizontalLoader.y = topBar.y + topBar.trueHeight;
			}
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.activate();
			super.activateScreen();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.deactivate();
			super.deactivateScreen();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			removeMessageClip();
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			if (back != null)
				UI.destroy(back);
			back = null;
		}
		
		protected function getContentPosition():int
		{
			return topBar.trueHeight;
		}
	}
}