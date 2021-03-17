package com.dukascopy.connect.gui.topBar {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TopBarWithUserStatus extends TopBarScreen {
		
		private var _circleStatusHeight:int;
		private var _maxTextWidth:int;
		
		private var statusNetwork:Boolean;
		private var statusBlock:Boolean;
		
		private var status:Sprite;
		private var statusTxt:Bitmap;
		
		protected var statusUserUID:String;
		
		public function TopBarWithUserStatus() {
			super();
		}
		
		override public function drawView(width:int):void {
			super.drawView(width);
			
			_circleStatusHeight = Config.TOP_BAR_HEIGHT * .11;
		}
		
		override public function activate(delay:Number = .15, onlyBack:Boolean = false):void {
			super.activate(delay);
			
			updateUserStatus();
		}
		
		override public function deactivate():void {
			super.deactivate();
			
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.USER_BLOCK_CHANGED.remove(onBlockChanged);
		}
		
		private function onUserBlockStatusChanged(data:Object):void {
			updateUserStatus();
		}
		
		private function updateUserStatus():void {
			if (statusUserUID == null || statusUserUID.length == 0)
				return;
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.USER_BLOCK_CHANGED.add(onBlockChanged);
			onUserOnlineStatusChanged(UsersManager.isOnline(statusUserUID), null);
		}
		
		private function onBlockChanged(data:Object):void {
			if (data == null)
				return;
			if (data.uid != statusUserUID)
				return;
			if (data.status == UserBlockStatusType.NO_CHANGE)
				return;
			var statusBlockOld:Boolean = statusBlock;
			statusBlock = false;
			if (Auth.blocked != null && Auth.blocked.indexOf(statusUserUID) !=-1)
				statusBlock = true;
			if (statusBlock != statusBlockOld)
				drawStatus();
		}
		
		private function onUserOnlineStatusChanged(m:OnlineStatus, method:String):void {
			if (m != null && m.uid != statusUserUID)
				return;
			if (method == null)
				if (Auth.blocked != null && Auth.blocked.indexOf(statusUserUID) !=-1)
					statusBlock = true;
			var statusNetworkOld:Boolean = statusNetwork;
			statusNetwork = false;
			if (m != null)
				statusNetwork = m.online;
			if (method == null || statusNetwork != statusNetworkOld)
				drawStatus();
		}
		
		private function drawStatus():void {
			var txt:String = Lang.textOffline;
			if (statusNetwork == true)
				txt = Lang.textOnline;
			if (statusBlock == true)
				txt += "-" + Lang.textBlocked;
			if (statusTxt == null) {
				statusTxt = new Bitmap();
				statusTxt.x = _circleStatusHeight * 2 + Config.MARGIN;
			}
			if (statusTxt.bitmapData != null)
				statusTxt.bitmapData.dispose();
			statusTxt.bitmapData = UI.renderText(txt, titleWidth, Config.FINGER_SIZE_DOT_25, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.TOP_BAR_HEIGHT * .25, false, Style.color(Style.TOP_BAR_STATUS_TEXT_COLOR), 0, true, "ChatTop.status");
			var metrics:TextLineMetrics = UI.getTextField().getLineMetrics(0);
			var _circleCenterY:Number = UI.getTextField().textHeight - metrics.descent - _circleStatusHeight + 2;
			metrics = null;
			if (status == null)
				status = new Sprite();
			status.graphics.clear();
			status.graphics.beginFill((statusNetwork == true) ? 0x65BF37 : 0xC5D1DB);
			status.graphics.drawCircle(_circleStatusHeight, _circleCenterY, _circleStatusHeight);
			if (status.parent == null) {
				addChild(status);
				status.addChild(statusTxt);
				status.x = titleBitmap.x + 2;
				displayUserStatus();
			}
		}
		
		private function displayUserStatus():void {
			updateUserStatus();
			status.alpha = 0;
			TweenMax.killTweensOf(status);
			TweenMax.to(status, 0.7, { alpha:1, delay:1 } );
			status.visible = true;
			updateTitleVerticalPosition();
		}
		
		private function updateTitleVerticalPosition():void {
			var space:int = (Config.TOP_BAR_HEIGHT - titleBitmap.height - status.height) * .33;
			var newPosition:int = Config.APPLE_TOP_OFFSET + space;
			TweenMax.killTweensOf(titleBitmap);
			TweenMax.to(titleBitmap, 0.7, { y:newPosition, delay:1 } );
			status.y = titleBitmap.y + titleBitmap.height - space;
			TweenMax.to(status, 0.7, { y:int(newPosition + titleBitmap.height - space), delay:1 } );
		}
		
		override public function dispose():void {
			super.dispose();
			statusUserUID = null;
			UI.destroy(statusTxt);
			statusTxt = null;
			if (status != null) {
				if (status.parent != null)
					status.parent.removeChild(status);
				status.graphics.clear();
			}
			status = null;
		}
	}
}