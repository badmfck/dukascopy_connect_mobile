package com.dukascopy.connect.gui.puzzle 
{
	import asssets.EmptyImage;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.RemoveImageAction;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.LightBoxItemVO;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.puzzle.PuzzleGame;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ImageContextMenuType;
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import com.telefision.sys.signals.Signal;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	
	/**
	 * Static Class that manages puzzle and puzzle lightbox 
	 * @author Alexey Skuryat

	 */
	public class Puzzle 
	{
		private static var _stageRef:Stage;
		private static var _viewWidth:int = 0;
		private static var _viewHeight:int = 0;
		public static var S_PUZZLE_OPENED:Signal = new Signal("Puzzle.S_PUZZLE_OPENED");
		public static var S_PUZZLE_CLOSED:Signal = new Signal("Puzzle.S_PUZZLE_CLOSED");
		private static var _isOpened:Boolean = false;
		
		private static var gameView:PuzzleGame; 		
		private static var stageReady:Boolean = false;
		private static var _view:DisplayObjectContainer;		
		
		private static  var currentLightBoxVO:LightBoxItemVO;	
		private static var _currentInvoiceData:PayTaskVO
		
		private static var reloadImageCount:int = 0;
		private static const MAX_RELOAD_COUNT:int = 3;
		
		
		public function Puzzle() {	}
		
		
		
		/** OPEN  */
		public static function openPuzzle():void {			
			_isOpened = true;						
			if(gameView == null){			
				gameView = new PuzzleGame();			
				_view.addChild(gameView);
			}
			gameView.setSize(_stageRef.stageWidth, _stageRef.stageHeight);
			gameView.backButtonCallback = closePuzzle;
			gameView.buyButtonCallback = showBuyDialog;
			gameView.dialogCallback = showBuyDialog;
			gameView.clearGame();
			gameView.show();			
			gameView.activate();			
			
			// Show animation
			gameView.y = MobileGui.stage.stageHeight;
			TweenMax.killTweensOf(gameView);
			TweenMax.to(gameView, .5, {y:0 , ease:Quint.easeInOut});
			S_PUZZLE_OPENED.invoke();
				
			InvoiceManager.S_STOP_PROCESS_INVOICE.add(onStopProcessInvoice);
			InvoiceManager.S_PAY_TASK_COMPLETED.add(onPaymentComplete);
		}
	
		
			
		
		/** CLOSE **/
		public static function closePuzzle(useAnimation:Boolean = true, dealyTime:Number = 0):void {
			_isOpened = false;
			_currentInvoiceData  = null;
			
			reloadImageCount = 0;
			TweenMax.killDelayedCallsTo(tryReloadImage);
			
			if (currentLightBoxVO != null){				
				currentLightBoxVO.reset();
			}				
			InvoiceManager.S_STOP_PROCESS_INVOICE.remove(onStopProcessInvoice);
			
			if (gameView != null){
				TweenMax.killTweensOf(gameView);				
				if (!useAnimation){
					TweenMax.to(gameView, 0, {y:MobileGui.stage.stageHeight , ease:Quint.easeInOut,delay:dealyTime, onComplete:function():void	{
							if (gameView != null){
								gameView.hide();
							}
							S_PUZZLE_CLOSED.invoke();
						}
					});
				}else{
					TweenMax.to(gameView, .5, {y:MobileGui.stage.stageHeight , ease:Quint.easeInOut, delay:dealyTime, onComplete:function():void	{
							if (gameView != null){
								gameView.hide();
							}
							S_PUZZLE_CLOSED.invoke();
						}
					});
				}
			}	
		}
		

		// Invoice Payment Completed Buy Completed 
		static private function onPaymentComplete(invoiceVO:PayTaskVO):void	{
			
			if (invoiceVO.taskType == PayTaskVO.TASK_TYPE_PAY_PUZZLE_BY_UID){
				
				var puzzleMsgVO:ChatMessageVO = invoiceVO.messageVO;
				if (puzzleMsgVO != null  && puzzleMsgVO.systemMessageVO != null && puzzleMsgVO.systemMessageVO.puzzleVO != null){
					
					var puzzleObj:Object = {
						amount:	puzzleMsgVO.systemMessageVO.puzzleVO.amount,
						currency:puzzleMsgVO.systemMessageVO.puzzleVO.currency,
						isPaid:true	
					};	
					
					var msg:String = JSON.stringify({ 
							method:ChatSystemMsgVO.METHOD_FILE_SENDED,
							type:ChatSystemMsgVO.TYPE_FILE,
							title:puzzleMsgVO.name,
							fileType:ChatSystemMsgVO.FILETYPE_PUZZLE_CRYPTED,
							additionalData:puzzleMsgVO.systemMessageVO.fileID + ',' + puzzleMsgVO.systemMessageVO.originalImageWidth + ',' + puzzleMsgVO.systemMessageVO.originalImageHeight,
							puzzleData:puzzleObj				
					} );
					
					
					ChatManager.updatePuzzle(Config.BOUNDS + msg, puzzleMsgVO.id, puzzleMsgVO.chatUID);
					//
					var customData:Object = { chatUID:puzzleMsgVO.chatUID, type:"text",text:"{name} bought your puzzle" /** , anonymous:true **/}; 					
					WSClient.call_pushToUser([puzzleMsgVO.userUID], "custom", "42.caf", customData);
			
					
					// call puzzle paid 
					 WSClient.call_blackHole([puzzleMsgVO.userUID], "puzzlePaid", { chatUID:puzzleMsgVO.chatUID, user_uid:Auth.uid , user_name:Auth.login} );
					
					
					if (_currentInvoiceData != null && _currentInvoiceData.messageVO != null && _currentInvoiceData.messageVO.id == puzzleMsgVO.id){
						
						var title:String = "";
						if (currentLightBoxVO != null && currentLightBoxVO.name != null){
							title = currentLightBoxVO.name;
						}
						
						LightBox.add(puzzleMsgVO.imageURLWithKey, true,title, null, null, puzzleMsgVO.imageThumbURLWithKey, null);
						LightBox.show(puzzleMsgVO.imageURLWithKey, "", true);
						InvoiceManager.stopProcessInvoice();// this is temporary 
						closePuzzle(false);
					}
				}
				
				
			}
					
		}	
	
		
		// Invoice Start
		static private function onStartProcessInvoice():void {
			if (_isOpened){
				gameView.visible = false;
				//gameView.mouseChildren = gameView.mouseEnabled = false;
				// esli invoice screen started to open -> make visible false
			}
		}
		
		// Invoice Stop
		static private function onStopProcessInvoice():void {
			if (_isOpened){
				
						
				if (gameView != null){
					gameView.visible = true;
					gameView.hidePrelaoder(); 
				}
				
				//gameView.mouseChildren = gameView.mouseEnabled = true;
				// esli invoice screen zakrivatersa
				InvoiceManager.S_START_PROCESS_INVOICE.remove(onStartProcessInvoice);
			}
		}
		

			
		static private function onPaymentsAccountCheckEnded():void {
			if (gameView != null){
				gameView.hidePrelaoder(); // if image is loaded 
			}
			InvoiceManager.S_STOP_PREPROCESS_INVOICE.remove(onPaymentsAccountCheckEnded);
			//onStartProcessInvoice();
		}
		
		
		private static function showBuyDialog():void 	{
			if (_currentInvoiceData != null && !isNaN(_currentInvoiceData.amount) && _currentInvoiceData.currency!= null){
				var bodyString:String = Lang.imageIsLockedBody;
					bodyString = LangManager.replace(Lang.regExtValue, bodyString, _currentInvoiceData.amount.toString() );
					bodyString = LangManager.replace(Lang.regExtValue, bodyString, _currentInvoiceData.currency);
					DialogManager.alert(Lang.imageIsLocked ,  bodyString, onBuyDialogCallback, Lang.CANCEL, Lang.BUY);
			}
		}
			
		public static function onBuyDialogCallback(val:int):void {			
			if (val == 2) {
				TweenMax.delayedCall(2,buy,null,true);				
			}
		}
		
		private static function buy():void 	{
			if (_currentInvoiceData != null){
				
				
			
				//trace("Puzzle.buy() Image " + _currentInvoiceData);
				if (gameView != null){
					gameView.showPreloader();
				}	
				
				if (!InvoiceManager.isPreProcessing){
					
					var msgID:Number = _currentInvoiceData.messageVO.id;
					if (InvoiceManager.hasTransactionWithChatMessageID(msgID) ){
						// Item is processing 
						//DialogManager.alert(Lang.imageIsLocked ,  bodyString, onBuyDialogCallback, Lang.CANCEL, Lang.BUY);
						return;
					}			
					
					InvoiceManager.S_STOP_PREPROCESS_INVOICE.add(onPaymentsAccountCheckEnded);
					InvoiceManager.S_START_PROCESS_INVOICE.add(onStartProcessInvoice);
					InvoiceManager.preProcessInvoce(_currentInvoiceData);	
				}
							
			}
		}
		

		
		
		/**
		 * Adds to stock LightBoxItemVO for later use by calling method show(url);
		 * @param	url 
		 * @param	crypt
		 * @param	name
		 * @param	okCallback
		 * @param	cancelCallback
		 */
		public static function add(	invoice:PayTaskVO,
									url:String, 
									crypt:Boolean = false, 
									name:String = "", 
									okCallback:Function = null, 
									cancelCallback:Function = null, 
									smallPreview:String = null, 
									imageActions:Vector.<IScreenAction> = null):void {
			
			var cryptKey:String;
			if (url.indexOf(ImageCrypterOld.imageKeyFlag) != -1){
				var pathElements:Array = url.split(ImageCrypterOld.imageKeyFlag);
				cryptKey = (pathElements[1] as String);
			}
				
			
			reloadImageCount = 0;
			TweenMax.killDelayedCallsTo(tryReloadImage);
			// Lets combine InvoiceVO and LightboxVO 
			
			_currentInvoiceData = invoice;				
			//Create and reuse lightbox vo 
			if (currentLightBoxVO != null){
				currentLightBoxVO.reset();
			}else{
				currentLightBoxVO = new LightBoxItemVO();
			}
			currentLightBoxVO.URL =  url;
			currentLightBoxVO.cryptKey = cryptKey;
			currentLightBoxVO.previewURL = smallPreview;
			//newVO.imageActions = imageActions;
			currentLightBoxVO.crypt = crypt;
			currentLightBoxVO.name = name;
			currentLightBoxVO.okCallback = okCallback;
			currentLightBoxVO.cancelCallback = cancelCallback;				
			if (gameView != null){
				gameView.setTitle(currentLightBoxVO.name);
			}
			ImageManager.loadImage(currentLightBoxVO.URL, onImageLoadComplete, true);
			
		}	
		
		
		private static function tryReloadImage():void
		{
			//trace("Try Reload " + reloadImageCount);
			if (reloadImageCount < MAX_RELOAD_COUNT){
				reloadImageCount ++;
				if (currentLightBoxVO != null && currentLightBoxVO.URL != ""){
					ImageManager.loadImage(currentLightBoxVO.URL, onImageLoadComplete, true);
				} // 				
			}else{
				// Fake Image 
				var image:EmptyImage = new EmptyImage();
				UI.scaleToFit(image, Math.min(_viewWidth, _viewHeight), Math.min(_viewWidth, _viewHeight));
				var bmd:ImageBitmapData = UI.getSnapshot(image, StageQuality.HIGH, "LightBox.emptyImage");
				image = null;
				addBitmap(bmd,true);
			}
		}
		
	
		private static function onImageLoadComplete(url:String, bmd:ImageBitmapData):void {
			echo("Puzzle", "onImageLoadComplete", "START");
			if (currentLightBoxVO !=null && currentLightBoxVO.URL == url) { // check if loadded image is exactly same as currently awaiting image 
				if (currentLightBoxVO.crypt){					
					if (!bmd){ 
						//
						TweenMax.killDelayedCallsTo(tryReloadImage);
						TweenMax.delayedCall(3, tryReloadImage);
						return;
					}					
					if (!bmd.decrypted)	{						
						if (ChatManager.getCurrentChat() != null) {
							var key:Array = ChatManager.getCurrentChat().imageKey;
							if (key.length > 100)
								addBitmap(Crypter.decryptImage(bmd, key));
						}
					}else{
						addBitmap(bmd);
					}
					
				}else{
					addBitmap(bmd);
				}				
			}else {
				ImageManager.unloadImage(url);
				//trace("Puzzle loaded URL is different from Current ");
			}
			echo("Puzzle", "onImageLoadComplete", "END");
		}
		
		
		
		private static function addBitmap(bmp:ImageBitmapData, isPreview:Boolean = false):void {			
			if (gameView != null ){
				gameView.setupGame(currentLightBoxVO.URL, bmp, 3, 4, 6, isPreview);	
			}
		}
		
		
		public static function setStage(stageRef:Stage,view:DisplayObjectContainer):void {
			if (stageRef != null) {
				_stageRef  = stageRef;
				//_stageRef.addEventListener(Event.RESIZE, onResize);
				_view = view;
				stageReady = true;
				_viewWidth = _stageRef.stageWidth;
				_viewHeight = _stageRef.stageHeight;
			} else {
				//trace("Puzzle -> cannot assign stage reference because it cannot be null  ");
			}
		}
		
		
		
		
		
		public static function setSize(width:int, height:int):void {
			echo("Puzzle", "setSize", "START");
			_viewWidth = width;
			_viewHeight = height;
			if (gameView!=null){
				gameView.setSize(_viewWidth, _viewHeight);
			} 
			echo("Puzzle", "setSize", "END");
		}
		
		
		
		/** ON RESIZE **/
		static private function onResize(e:Event = null):void  {
			echo("Puzzle", "onResize", "START");
			var orientation:String = MobileGui.currentOrientation;			
			if (_stageRef == null)	{
				return;
			}			
			var w:int;
			var h:int;	
			w = _stageRef.stageWidth;
			h = _stageRef.stageHeight;
			setSize(w, h);
			echo("Puzzle", "onResize", "END");	
		}
		
		static public function get isOpened():Boolean { return _isOpened;	}
		
		
	}

}