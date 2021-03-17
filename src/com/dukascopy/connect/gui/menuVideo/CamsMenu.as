package com.dukascopy.connect.gui.menuVideo {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.media.Camera;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class CamsMenu extends Sprite {
		
		private var CLOSE_BMD:BitmapData;
		private var CAM_PLAY_BMD:BitmapData;
		private var CAM_STOP_BMD:BitmapData;
		private var CAM_ON_BMD:BitmapData;
		private var CAM_ON_BIG_BMD:BitmapData;
		private var BG_BMD:ImageBitmapData;
		private var REVERSE_BMD:BitmapData;
		private var LOCK_BMD:BitmapData;
		private var UNLOCK_BMD:BitmapData;
		private var BACK_BMD:BitmapData;
		
		private var _viewWidth:int = 0;
		private var _viewHeight:int = 0;
		
		private var _camsAdded:Boolean = false;
		private var _hasActivity:Boolean = false;
		private var _minified:Boolean = false;
		private var _isPublishing:Boolean = false;
		
		private var camsToggleButton:BitmapButton;
		private var reverseCamButton:BitmapButton;
		private var startPublishButton:BitmapButton;
		
		private var background:Bitmap = new Bitmap();
		
		public var camsHolder:Sprite = new Sprite();
		
		private var onCamsToggleCallback:Function;
		private var onPublishToggleCallback:Function;
		private var BUTTON_SIZE:int = 50;
		
		
		/** @CONSTRUCTOR **/
		public function CamsMenu() {
			super();
			createView();
		}
		
		private function createView():void {
			background.alpha = .9;
			addChild(background);
			BUTTON_SIZE =  Math.ceil(Config.FINGER_SIZE * .35) * 2;
			// generate bitmap icons 
			CAM_PLAY_BMD ||= UI.getIconByFrame(1, BUTTON_SIZE, BUTTON_SIZE, "CamsMenu.CAM_PLAY_BMD");
			CAM_STOP_BMD ||= UI.getIconByFrame(2, BUTTON_SIZE, BUTTON_SIZE, "CamsMenu.CAM_STOP_BMD");
			CLOSE_BMD ||= UI.getIconByFrame(3, BUTTON_SIZE, BUTTON_SIZE, "CamsMenu.CLOSE_BMD");
			CAM_ON_BMD ||= UI.getIconByFrame(5, BUTTON_SIZE, BUTTON_SIZE, "CamsMenu.CAM_ON_BMD");
			CAM_ON_BIG_BMD ||= UI.getIconByFrame(5 , BUTTON_SIZE + BUTTON_SIZE * .2, BUTTON_SIZE + BUTTON_SIZE * .2, "CamsMenu.CAM_ON_BIG_BMD");
			
			REVERSE_BMD ||= UI.getIconByFrame(6, BUTTON_SIZE, BUTTON_SIZE, "CamsMenu.REVERSE_BMD");
			LOCK_BMD ||= UI.getIconByFrame(7, BUTTON_SIZE + BUTTON_SIZE * .2, BUTTON_SIZE + BUTTON_SIZE * .2, "CamsMenu.LOCK_BMD");
			UNLOCK_BMD ||= UI.getIconByFrame(8, BUTTON_SIZE + BUTTON_SIZE * .2, BUTTON_SIZE + BUTTON_SIZE * .2, "CamsMenu.UNLOCK_BMD");
			BACK_BMD ||= UI.getIconByFrame(11, BUTTON_SIZE, BUTTON_SIZE, "CamsMenu.BACK_BMD");
			// add toggle button
			camsToggleButton = new BitmapButton();
			camsToggleButton.setBitmapData(CLOSE_BMD);
			camsToggleButton.setOverflow(10, 10, 10, 10);
			addChild(camsToggleButton);
			// start publish button
			startPublishButton = new BitmapButton();
			startPublishButton.setBitmapData(CAM_PLAY_BMD);
			startPublishButton.setOverflow(10, 10, 10, 10);
			addChild(startPublishButton);
			startPublishButton.tapCallback = onPublishTap;
			// reverse cam button
			if(Camera.names.length>1){
				reverseCamButton = new BitmapButton();
				reverseCamButton.setBitmapData(REVERSE_BMD);
				reverseCamButton.setOverflow(10, 10, 10, 10);
				addChild(reverseCamButton);
				reverseCamButton.tapCallback = onReverseClick;
			}
			// background
			BG_BMD = new ImageBitmapData("CamsMenu.BG", 1, 1, false, 0x000000);
			background.bitmapData = BG_BMD;
		}
		
		private function onReverseClick():void {
			var state:Boolean = !CAMS.isFrontCam();
			CAMS.useFrontCamera(state);
		}
		
		private function onPublishTap():void {
			if (isPublishing)
				ChatManager.stopPublishStream();
			else
				ChatManager.startPublishStream();
		}
		
		public function setOnCamsToggle(callback:Function):void {
			onCamsToggleCallback = callback;
			camsToggleButton.tapCallback = onCamsToggleCallback;
		}
		
		public function setOnPublishToggle(callback:Function):void {
			onPublishToggleCallback = callback;
			startPublishButton.tapCallback = onPublishToggleCallback;
		}
		
		private function onPublishValueChange(value:Boolean):void {
			isPublishing = value;
		}
		
		public function activate():void	{
			camsToggleButton.activate();
			startPublishButton.activate();
			if (reverseCamButton) reverseCamButton.activate();
			onMinifyStatusChange();
			ChatManager.S_PUBLISHING.add(onPublishValueChange);
			onPublishValueChange(ChatManager.isPublishing);
		}
		
		public function deactivate():void {
		   camsToggleButton.deactivate();
			startPublishButton.deactivate();
			if (reverseCamButton) reverseCamButton.deactivate();
		   	ChatManager.S_PUBLISHING.remove(onPublishValueChange);
		}
		
		public function showView():void { }
		public function hideView():void { }
		
		private function updateViewPort():void {
			if (background) {
				background.width = _viewWidth;
				background.height = _viewHeight;
			}
			if (camsToggleButton) {
				camsToggleButton.x = _viewWidth - BUTTON_SIZE-20;
				camsToggleButton.y = 45;
				camsToggleButton.visible= !_minified;
			}
			if (startPublishButton) {
				startPublishButton.x = camsToggleButton.x - BUTTON_SIZE*1.4;
				startPublishButton.y =  45;
				startPublishButton.visible = !_minified;
			}
			if (reverseCamButton) {
				reverseCamButton.x = startPublishButton.x - BUTTON_SIZE*1.4;
				reverseCamButton.y =  45;
				reverseCamButton.visible = !_minified;
			}
		}
		
		private function onActivityStatusChange():void 	{
			if (_minified)
				camsToggleButton.isBlinking = _hasActivity;
		}
		
		private function onCamsAddedStatusChange():void {
			if (camsAdded) {
				background.visible = true;
				addChildAt(camsHolder, 1);
			} else
				background.visible = false;
		}
		
		private function onMinifyStatusChange():void {
			background.visible = !_minified;
			if (!_minified)
				onPublishValueChange(ChatManager.isPublishing);
			camsToggleButton.isBlinking = _minified && _hasActivity;
			updateViewPort();
		}
		
		private function onPublishingValueChange():void {
			if (!startPublishButton) return;
			if (_isPublishing)
				startPublishButton.setBitmapData(CAM_STOP_BMD);
			else
				startPublishButton.setBitmapData(CAM_PLAY_BMD);
		}
		
		public function dispose():void {
			if (this.parent)
				this.parent.removeChild(this);
			if (camsHolder != null)
				camsHolder = null;
			if (camsToggleButton != null)
				camsToggleButton.dispose();
			camsToggleButton = null;
			if (reverseCamButton != null)
				reverseCamButton.dispose();
			reverseCamButton = null;
			if (startPublishButton != null)
				startPublishButton.dispose();
			startPublishButton = null;
			UI.destroy(background);
			UI.disposeBMD(CAM_ON_BMD);
			UI.disposeBMD(CAM_ON_BIG_BMD);
			UI.disposeBMD(CAM_PLAY_BMD);
			UI.disposeBMD(CAM_STOP_BMD);
			UI.disposeBMD(REVERSE_BMD);
			UI.disposeBMD(CLOSE_BMD);
			UI.disposeBMD(LOCK_BMD);
			UI.disposeBMD(UNLOCK_BMD);
			UI.disposeBMD(BACK_BMD);
			UI.disposeBMD(BG_BMD);
			
			CAM_ON_BMD = null;
			CAM_ON_BIG_BMD = null;
			CAM_PLAY_BMD = null;
			CAM_STOP_BMD = null;
			REVERSE_BMD = null;
			CLOSE_BMD = null;
			LOCK_BMD = null;
			UNLOCK_BMD = null;
			BACK_BMD = null;
			BG_BMD = null;
			
			
			onCamsToggleCallback = null;
			onPublishToggleCallback = null;
			ChatManager.S_PUBLISHING.add(onPublishValueChange);
		}
		
		public function setSize(w:int, h:int):void {
			_viewWidth = w;
			_viewHeight = h;
			updateViewPort();
		}
		
		public function get viewWidth():int { return _viewWidth; }
		public function set viewWidth(value:int):void {
			if (value == _viewWidth) return;
			_viewWidth = value;
			updateViewPort();
		}
		
		public function get viewHeight():int { return _viewHeight; }
		public function set viewHeight(value:int):void 	{
			if (value == _viewHeight) return;
			_viewHeight = value;
			updateViewPort();
		}
		
		public function get camsAdded():Boolean { return _camsAdded; }
		public function set camsAdded(value:Boolean):void {
			if (value == _camsAdded) return;
			_camsAdded = value;
			onCamsAddedStatusChange();
		}
		
		public function get hasActivity():Boolean 	{ return _hasActivity; }
		public function set hasActivity(value:Boolean):void {
			if (value == _hasActivity) return;
			_hasActivity = value;
			onActivityStatusChange();
		}
		
		public function get minified():Boolean 	{ return _minified; }
		public function set minified(value:Boolean):void {
			if (value == _minified) return;
			_minified = value;
			onMinifyStatusChange();
		}
		
		public function get isPublishing():Boolean 	{ return _isPublishing; }
		public function set isPublishing(value:Boolean):void {
			if (value == _isPublishing) return;
			_isPublishing = value;
			onPublishingValueChange();
		}
	}
}