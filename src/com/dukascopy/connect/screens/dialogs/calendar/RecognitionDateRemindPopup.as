package com.dukascopy.connect.screens.dialogs.calendar
{
	import assets.RunIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.QueuePopup;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class RecognitionDateRemindPopup extends BaseScreen
	{
		static public const STATE_START:String = "stateStart";
		static public const STATE_REMOVED:String = "stateRemoved";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var title:Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var padding:int;
		private var state:String;
		private var description:Bitmap;
		private var horizontalLoader:HorizontalPreloader;
		private var firstTime:Boolean;
		private var content:Sprite;
		private var datePanel:DateTimePanelExtended;
		private var closeOnReady:Boolean;
		private var backButton:BitmapButton;
		
		public function RecognitionDateRemindPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			content = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			title = new Bitmap();
			content.addChild(title);
			
			description = new Bitmap();
			content.addChild(description);
			
			horizontalLoader = new HorizontalPreloader(0xB3BDC6);
			content.addChild(horizontalLoader);
			
			datePanel = new DateTimePanelExtended(onRemoveCall, onSubscribeCall);
			content.addChild(datePanel);
			
			_view.addChild(container);
			container.addChild(content);
		}
		
		private function nextClick():void
		{
			DialogManager.closeDialog();
		}
		
		private function backClick():void {
			DialogManager.closeDialog();
			if (Config.FAST_TRACK == true)
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, QueuePopup);
			}
		}
		
		private function drawResultDescription():void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
															Lang.VIScheduleDescription, componentsWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, true, 0x8092A6, 0xFFFFFF, true, true);
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			drawTitle(Lang.appointmentTime);
			drawResultDescription();
			drawBackButton();
			drawNextButton(Lang.textOk);
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.x = padding;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .35;
			
			var hours:TimeRange = new TimeRange(10, 10);
			var minutes:TimeRange = new TimeRange(10, 10);
			var date:Date = new Date();
			
			datePanel.draw(date, componentsWidth, hours, minutes);
			datePanel.x = padding;
			datePanel.y = position;
			position += datePanel.getHeight() + Config.FINGER_SIZE * .35;
			datePanel.visible = false;
			
			description.x = padding;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .35;
			
			nextButton.y = position;
			backButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .3;
			
			backButton.x = padding;
			nextButton.x = int(backButton.x + backButton.width + Config.MARGIN);
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position);
			
			state = STATE_START;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .06));
			horizontalLoader.y = bdDrawPosition;
			
			horizontalLoader.y = bdDrawPosition;
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .06));
			
			if (Calendar.viAppointmentData != null)
			{
				if (Calendar.viAppointmentData.success)
				{
					if (Calendar.viAppointmentData.exist)
					{
						showData();
					}
					else
					{
						closeOnReady = true;
					//	close();
					}
				}
				else
				{
					Calendar.loadAppointmentData();
				}
			}
			else
			{
				horizontalLoader.start();
				Calendar.S_APPOINTMENT_DATA.add(onDataReady);
				Calendar.loadAppointmentData();
			}
		}
		
		private function showData():void 
		{
			datePanel.draw(Calendar.viAppointmentData.date, componentsWidth, Calendar.viAppointmentData.hours, Calendar.viAppointmentData.minutes);
			datePanel.visible = true;
		}
		
		private function close():void 
		{
			DialogManager.closeDialog();
		}
		
		private function onDataReady():void 
		{
			Calendar.S_APPOINTMENT_DATA.remove(onDataReady);
			horizontalLoader.stop();
			if (Calendar.viAppointmentData != null)
			{
				if (Calendar.viAppointmentData.success)
				{
					if (Calendar.viAppointmentData.exist)
					{
						showData();
					}
					else
					{
						close();
					}
				}
				else
				{
					ToastMessage.display(Lang.textError);
				}
			}
		}
		
		private function onRemoveCall():void 
		{
			if (Calendar.viAppointmentData == null)
			{
				ToastMessage.display(Lang.serverError);
				return;
			}
			
			var now:Date = new Date();
			
			if (Calendar.viAppointmentData != null && Calendar.viAppointmentData.date != null)
			{
				var difference:Number = Calendar.viAppointmentData.date.getTime() - now.getTime();
				if (difference > 0 && difference < 1000 * 60 * 60 * 24)
				{
					DialogManager.closeDialog();
					DialogManager.alert(Lang.textWarning, Lang.cantCancelAppointment);
					return;
				}
			}
			
			horizontalLoader.start();
			datePanel.deactivate();
			Calendar.S_APPOINTMENT_BOOK_CANCEL.add(onCancelResult);
			//!!!
			Calendar.cancelVIAppointment(Calendar.viAppointmentData.id);
		}
		
		private function onCancelResult(success:Boolean, errorMessage:String = null):void 
		{
			Calendar.S_APPOINTMENT_BOOK_CANCEL.remove(onCancelResult);
			if (isDisposed)
			{
				return;
			}
			horizontalLoader.stop();
			if (isActivated)
			{
				if (datePanel != null)
				{
					datePanel.activate();
				}
			}
			if (success)
			{
				datePanel.onCancelled();
			}
			else
			{
				ToastMessage.display(errorMessage);
			}
		}
		
		private function onSubscribeCall():void 
		{
			DialogManager.showDialog(SelectRecognitionDatePopup, null);
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData
			
			if (Config.FAST_TRACK == true)
			{
				textSettings = new TextFieldSettings("    " + Lang.fastTrack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
				
				var icon:RunIcon = new RunIcon();
				UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
				var iconBD:ImageBitmapData = UI.getSnapshot(icon);
				
				buttonBitmap = TextUtils.createbutton(textSettings, 0xFCFCFC, 1, Config.FINGER_SIZE * .8, 0xEDEDED, (componentsWidth - Config.MARGIN) * .5);
				
				buttonBitmap.copyPixels(iconBD, iconBD.rect, new Point(Config.FINGER_SIZE * .2, buttonBitmap.height * .5 - iconBD.height * .5), null, null, true);
				iconBD.dispose();
				backButton.setBitmapData(buttonBitmap, true);
			}
			else
			{
				textSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, 0xFCFCFC, 1, Config.FINGER_SIZE * .8, 0xEDEDED, (componentsWidth - Config.MARGIN) * .5);
				backButton.setBitmapData(buttonBitmap, true);
			}
		}
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			var h:int = bg.height;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, h - bdDrawPosition);
			bg.graphics.endFill();
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			datePanel.activate();
			nextButton.activate();
			
			backButton.activate();
			
			if (firstTime == false)
			{
				firstTime = true;
				
				bg.alpha = 0;
				TweenMax.to(bg, 0.3, {alpha:1});
				
				content.alpha = 0;
				TweenMax.to(content, 0.3, {alpha:1, delay:0.15});
			}
			
			if (closeOnReady)
			{
				closeOnReady = false;
				close();
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			
			datePanel.deactivate();
			nextButton.deactivate();
		}
		
		override public function dispose():void
		{
			Calendar.S_APPOINTMENT_DATA.remove(onDataReady);
			Calendar.S_APPOINTMENT_BOOK_CANCEL.remove(onCancelResult);
			
			Overlay.removeCurrent();
			
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
		}
	}
}