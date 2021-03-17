package com.dukascopy.connect.gui.chatInput
{
	
	import assets.SendButtonRed;
	import assets.SortVerticalIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankInfoInput extends Sprite
	{
		
		private var bg:Shape;
		private var tfBMP:Bitmap;
		private var buttonHome:BitmapButton;
		
		private var trueWidth:int;
		
		private var firstTime:Boolean = true;
		
		private var _homeCallback:Function;
		private var _sendCallback:Function;
		private var _title:String;
		
		private var _isActive:Boolean = false;
		
		private var buttonSize:int = Config.FINGER_SIZE * .5;
		private var componentHeight:int = Config.FINGER_SIZE * .8;
		private var padding:int = Config.FINGER_SIZE * .25;
		private var leftPadding:int = Config.FINGER_SIZE * .25;
		
		public function BankInfoInput(title:String)
		{
			_title = title;
			
			bg = new Shape();
			addChild(bg);
			
			tfBMP = new Bitmap();
			addChild(tfBMP);
			
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			bg.graphics.drawRect(0, 0, 2, componentHeight + Config.APPLE_BOTTOM_OFFSET);
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
		}
		
		// create Home 
		public function createHomeButton(leftOffset:int = 0):void
		{
			if (buttonHome == null)
			{
				buttonHome = new BitmapButton();
				buttonHome.setBitmapData(UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_BANK)), Style.color(Style.ICON_COLOR)), buttonSize, buttonSize), true);
				buttonHome.setOverflow(Config.FINGER_SIZE * .2, leftOffset, Config.FINGER_SIZE * .15, Config.FINGER_SIZE * .2);
				buttonHome.setDownAlpha(0);
				buttonHome.y = int(height * .5 - buttonHome.height * .5);
			//	buttonHome.hide();
				buttonHome.tapCallback = onHomeButtonTap;
				addChild(buttonHome);
				buttonHome.show(0);
			}
			else
			{
				buttonHome.setOverflow(Config.FINGER_SIZE * .2, leftOffset, Config.FINGER_SIZE * .15, Config.FINGER_SIZE * .2);
			}
		}
		
		public function updateComponentsPosition():void
		{
			var buttonsTotalWidth:int = 0;
			var leftSpace:int = leftPadding;
			var leftOffset:int = leftPadding;
			var rightSpace:int = 0;
			var halfFreeSpace:int = 0;
			createHomeButton(leftOffset);
			buttonHome.x = leftSpace;
			buttonsTotalWidth += Config.FINGER_SIZE * .7;
			leftSpace += buttonHome.width + padding;
			leftOffset = int(Config.FINGER_SIZE * .1);
			
			if (tfBMP.bitmapData != null)
			{
				tfBMP.bitmapData.dispose();
				tfBMP.bitmapData = null;
			}
			tfBMP.bitmapData = UI.renderText(_title, trueWidth - buttonsTotalWidth, 10, false, TextFormatAlign.LEFT, 
											TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, false, 
											Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_INPUT_BACKGROUND));
			halfFreeSpace = (trueWidth - (leftSpace + rightSpace)) * .5 - tfBMP.width * .5;
			tfBMP.x = leftSpace + halfFreeSpace;
			tfBMP.y = int((componentHeight - tfBMP.height) * .5);
		}
		
		public function destroyHomeButton():void
		{
			if (buttonHome != null)
			{
				buttonHome.dispose();
				buttonHome = null;
			}
		}
		
		private function onHomeButtonTap():void
		{
			if (_homeCallback != null)
			{
				_homeCallback();
				return;
			}
		}
		
		public function setWidth(val:int):void
		{
			if (trueWidth == val)
				return;
			trueWidth = val;
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			bg.graphics.drawRect(0, 0, trueWidth, componentHeight + Config.APPLE_BOTTOM_OFFSET);
			
			updateComponentsPosition();
		}
		
		public function activate():void
		{
			_isActive = true;
			PointerManager.addTap(this, onTap);
			PointerManager.addDown(this, onDown);
			buttonHome.activate();
		}
		
		private var ts:Number;
		
		private function onDown(e:Object):void
		{
			if (tfBMP == null)
				return;
			if ("localX" in e == true && e.localX > tfBMP.x && e.localX < tfBMP.x + tfBMP.width && "localY" in e == true && e.localY < tfBMP.y + tfBMP.height)
			{
				ts = new Date().getTime();
				PointerManager.addUp(MobileGui.stage, onUp);
			}
		}
		
		private function onUp(e:Object):void
		{
			PointerManager.removeUp(MobileGui.stage, onUp);
			var newTS:Number = new Date().getTime();
			if (newTS - ts < 5000)
				return;
		}
		
		private function onTap(e:Object):void
		{
			var newTS:Number = new Date().getTime();
			if (newTS - ts > 5000)
				return;
			if (tfBMP == null)
				return;
			if ("localX" in e == true && e.localX > tfBMP.x && e.localX < tfBMP.x + tfBMP.width && "localY" in e == true && e.localY < tfBMP.y + tfBMP.height)
				onSendButtonTap();
		}
		
		private function onSendButtonTap():void
		{
			if (_sendCallback != null)
			{
				_sendCallback();
				return;
			}
		}
		
		public function deactivate():void
		{
			_isActive = false;
			if (buttonHome != null)
				buttonHome.deactivate();
			PointerManager.addDown(this, onDown);
			PointerManager.removeUp(MobileGui.stage, onUp);
			PointerManager.removeTap(this, onTap);
		}
		
		public function set sendCallback(val:Function):void
		{
			_sendCallback = val;
		}
		
		public function set homeCallback(val:Function):void
		{
			_homeCallback = val;
		}
		
		public function getHeight():int
		{
			return componentHeight + Config.APPLE_BOTTOM_OFFSET;
		}
		
		public function dispose():void
		{
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (tfBMP != null)
				UI.destroy(tfBMP);
			tfBMP = null;
			if (buttonHome != null)
				buttonHome.dispose();
			buttonHome = null;
			_homeCallback = null;
			_sendCallback = null;
		}
	}
}