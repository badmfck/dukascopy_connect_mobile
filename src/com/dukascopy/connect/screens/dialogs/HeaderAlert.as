package com.dukascopy.connect.screens.dialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.customActions.OpenScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HeaderAlert extends Sprite
	{
		private var action:OpenScreenAction;
		private var processButton:BitmapButton;
		private var message:Bitmap;
		private var itemWidth:int;
		private var back:Sprite;
		private var container:Sprite;
		private var containerMask:Sprite;
		private var animationTime:Number = 0.4;
		
		public function HeaderAlert() 
		{
			container = new Sprite();
			addChild(container);
			
			containerMask = new Sprite();
			addChild(containerMask);
			
			container.mask = containerMask;
		}
		
		public static function show(target:Sprite, positionX:int, positionY:int, itemWidth:int, text:String, action:OpenScreenAction):HeaderAlert
		{
			var item:HeaderAlert = new HeaderAlert();
			target.addChild(item);
			item.x = positionX;
			item.y = positionY;
			item.show(itemWidth, text, action);
			return item;
		}
		
		private function show(itemWidth:int, text:String, action:OpenScreenAction):void 
		{
			this.itemWidth = itemWidth;
			this.action = action;
			
			back = new Sprite();
			container.addChild(back);
			
			createTitle(text);
			createButton(action.getData() as String);
			
			message.x = int(itemWidth * .5 - message.width * .5);
			processButton.x = int(itemWidth * .5 - processButton.width * .5);
			message.y = int(Config.FINGER_SIZE * .5);
			processButton.y = int(message.y + message.height + Config.FINGER_SIZE * .5);
			
			back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			back.graphics.drawRect(0, 0, itemWidth, getHeight());
			back.graphics.endFill();
			
			containerMask.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			containerMask.graphics.drawRect(0, 0, itemWidth, getHeight());
			containerMask.graphics.endFill();
			
			container.y = -getHeight();
			TweenMax.to(container, animationTime, {y:0, ease:Power2.easeOut});
			
			processButton.activate();
		}
		
		private function getHeight():int
		{
			return processButton.y + processButton.height + Config.DIALOG_MARGIN;
		}
		
		private function createButton(text:String):void 
		{
			processButton = new BitmapButton();
			processButton.setStandartButtonParams();
			processButton.setDownColor(NaN);
			processButton.setDownScale(1);
			processButton.setOverlay(HitZoneType.BUTTON);
			processButton.cancelOnVerticalMovement = true;
			processButton.tapCallback = process;
			container.addChild(processButton);
			
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_LIGHT), -1, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			processButton.setBitmapData(buttonBitmap, true);
			
			mouseEnabled = true;
			mouseChildren = true;
		}
		
		private function onDown(e:Event = null):void 
		{
			if (parent != null)
			{
				var position:Point = new Point(x, y);
				position = parent.localToGlobal(position);
				var rect:Rectangle = new Rectangle(position.x, position.y, itemWidth, getHeight());
				var point:Point = new Point(MobileGui.stage.mouseX, MobileGui.stage.mouseY);
				if (rect.containsPoint(point))
				{
					if (e != null)
					{
						e.preventDefault();
						e.stopPropagation();
						e.stopImmediatePropagation();
					}
				}
				else
				{
					hide();
				}
			}
		}
		
		private function process():void 
		{
			if (action != null)
			{
				action.execute();
			}
			hide();
		}
		
		public function hide():void 
		{
			PointerManager.removeDown(MobileGui.stage, onDown);
			
			if (processButton != null)
			{
				processButton.deactivate();
			}
			if (container != null)
			{
				TweenMax.to(container, animationTime, {y:-getHeight(), onComplete:remove})
			}
		}
		
		private function remove():void 
		{
			dispose();
		}
		
		private function createTitle(text:String):void 
		{
			message = new Bitmap();
			container.addChild(message);
			
			message.bitmapData = TextUtils.createTextFieldData(text, itemWidth - Config.DIALOG_MARGIN * 2, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
		}
		
		public function dispose():void
		{
			PointerManager.removeDown(MobileGui.stage, onDown);
			
			TweenMax.killTweensOf(container);
			
			if (message != null)
			{
				UI.destroy(message);
				message = null;
			}
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (containerMask != null)
			{
				UI.destroy(containerMask);
				containerMask = null;
			}
			if (action != null)
			{
				action.dispose();
				action = null;
			}
			if (processButton != null)
			{
				processButton.deactivate();
				processButton.dispose();
				processButton = null;
			}
			if (parent != null && parent.contains(this))
			{
				parent.removeChild(this);
			}
		}
		
		public function activate():void 
		{
			PointerManager.addDown(MobileGui.stage, onDown, false, 10);
		}
	}
}