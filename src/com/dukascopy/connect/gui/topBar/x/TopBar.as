package com.dukascopy.connect.gui.topBar.x 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.button.ActionButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.topBar.x.controller.IBarController;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TopBar extends Sprite
	{
		private var controller:IBarController;
		
		private var container:Sprite;
		private var title:Bitmap;
		private var subtitle:Bitmap;
		private var backButton:BitmapButton;
		private var componentWidth:int;
		private var componentHeight:int;
		private var buttons:Vector.<ActionButton>;
		private var buttonsPadding:int;
		private var isActive:Boolean;
		private var subtitleValue:String;
		private var titleValue:String;
		private var leftMargin:int;
		
		public function TopBar(controller:IBarController) 
		{
			this.controller = controller;
			controller.setView(this);
			createView();
			updatePositions();
		}
		
		public function get isActivated():Boolean
		{
			return isActive;
		}
		
		private function createView():void 
		{
			leftMargin = Style.size(Style.SCREEN_PADDING_LEFT) * 1.3;
			buttonsPadding = Config.FINGER_SIZE * .25;
			
			container = new Sprite();
			addChild(container);
			container.y = Config.APPLE_TOP_OFFSET;
			
			title = new Bitmap();
			container.addChild(title);
			
			subtitle = new Bitmap();
			subtitle.alpha = 0.6;
			container.addChild(subtitle);
		}
		
		private function createBackButton():void 
		{
			if (backButton == null)
			{
				backButton = new BitmapButton();
				backButton.listenNativeClickEvents(true);
				backButton.setStandartButtonParams();
				backButton.setDownScale(1.3);
				backButton.setDownColor(0xFFFFFF);
				backButton.tapCallback = backClick;
				backButton.disposeBitmapOnDestroy = true;
				
				backButton.show();
				container.addChild(backButton);
				
				var iconSize:int = Style.size(Style.CHAT_TOP_ICON_SIZE);
				var icon:Sprite = new (Style.icon(Style.ICON_BACK));
				UI.scaleToFit(icon, iconSize, iconSize);
				var overflow:int = (componentHeight - iconSize) * .5;
				backButton.setOverflow(overflow, overflow, overflow, overflow);
				UI.colorize(icon, Style.color(Style.TOP_BAR_ICON_COLOR));
				backButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "ChatTop.backButon"), true);
			}
		}
		
		public function setWidthAndHeight(w:int, h:int):void
		{
			this.componentWidth = w;
			this.componentHeight = h;
			
			updateBack();
			updatePositions();
			createBackButton();
		}
		
		public function activate():void
		{
			isActive = true;
			
			if (backButton != null && backButton.parent != null)
			{
				backButton.activate();
			}
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].activate();
				}
			}
		}
		
		public function deactivate():void
		{
			isActive = false;
			
			if (backButton != null)
			{
				backButton.deactivate();
			}
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].deactivate();
				}
			}
		}
		
		private function updateBack():void 
		{
			graphics.clear();
			graphics.beginFill(Style.color(Style.TOP_BAR));
			graphics.drawRect(0, 0, componentWidth, componentHeight + Config.APPLE_TOP_OFFSET);
			graphics.endFill();
		}
		
		private function backClick():void 
		{
			if (controller != null)
			{
				controller.onBack();
			}
		}
		
		override public function get height():Number 
		{
			return Config.APPLE_TOP_OFFSET + componentHeight;
		}
		
		public function dispose():void
		{
			if (controller != null)
			{
				controller.dispose();
			}
			clearButtons();
			
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (subtitle != null)
			{
				UI.destroy(subtitle);
				subtitle = null;
			}
			if (backButton != null)
			{
				UI.destroy(backButton);
				backButton = null;
			}
		}
		
		public function update():void
		{
			if (controller != null)
			{
				controller.update();
			}
		}
		
		public function drawTitle(value:String):void 
		{
			if (title == null)
			{
				ApplicationErrors.add();
				return;
			}
			
			titleValue = value;
			
			var maxTextWidth:int = componentWidth - Style.size(Style.SCREEN_PADDING_LEFT) - leftMargin;
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(value, maxTextWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.TITLE_2, true, Style.color(Style.TOP_BAR_TEXT_COLOR),
																		Style.color(Style.TOP_BAR));
		}
		
		public function updatePositions():void 
		{
			if (buttons != null)
			{
				var buttonPosition:int = componentWidth - Style.size(Style.SCREEN_PADDING_LEFT);
				for (var i:int = buttons.length - 1; i >= 0; i--) 
				{
					buttonPosition -= buttons[i].width;
					buttons[i].x = buttonPosition;
					buttons[i].y = int(componentHeight * .5 - buttons[i].height * .5);
					buttonPosition -= buttonsPadding;
				}
			}
			
			var titlePosition:int = leftMargin;
			if (backButton != null)
			{
				backButton.x = leftMargin;
				backButton.y = int(componentHeight * .5 - backButton.height * .5);
				titlePosition += backButton.x + backButton.width;
			}
			
			title.x = titlePosition;
			subtitle.x = titlePosition;
			
			if (subtitleValue == null)
			{
				title.y = int(componentHeight * .5 - title.height * .5);
			}
			else
			{
				var gap:int = Config.FINGER_SIZE * .1;
				title.y = int(componentHeight * .5 - (title.height + subtitle.height + gap) * .5);
				subtitle.y = int(title.y + title.height + gap);
			}
		}
		
		public function updateButtons(buttonsData:Vector.<IScreenAction>):void 
		{
			clearButtons();
			buttons = new Vector.<ActionButton>();
			if (buttonsData != null)
			{
				for (var i:int = 0; i < buttonsData.length; i++) 
				{
					var button:ActionButton = new ActionButton(buttonsData[i]);
					button.build(Config.FINGER_SIZE, Style.size(Style.CHAT_TOP_ICON_SIZE), buttonsData[i].getIconScale());
					buttons.push(button);
					container.addChild(button);
					
					if (isActive)
					{
						button.activate();
					}
				}
			}
		}
		
		public function setSubtitle(value:String):void 
		{
			if (subtitle == null)
			{
				ApplicationErrors.add();
				return;
			}
			
			subtitleValue = value;
			
			var maxTextWidth:int = componentWidth - Style.size(Style.SCREEN_PADDING_LEFT) - leftMargin;
			if (subtitle.bitmapData != null)
			{
				subtitle.bitmapData.dispose();
				subtitle.bitmapData = null;
			}
			if (value != null)
			{
				subtitle.bitmapData = TextUtils.createTextFieldData(value, maxTextWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD_14, true, Style.color(Style.TOP_BAR_TEXT_COLOR),
																		Style.color(Style.TOP_BAR));
			}
		}
		
		private function clearButtons():void 
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].dispose();
					if (container != null && container.contains(buttons[i]))
					{
						container.removeChild(buttons[i]);
					}
				}
			}
			buttons = null;
		}
	}
}