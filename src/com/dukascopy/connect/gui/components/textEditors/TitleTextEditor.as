package com.dukascopy.connect.gui.components.textEditors 
{
	import assets.EditIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TitleTextEditor extends Sprite
	{
		private var input:Input;
		private var editTitleButton:BitmapButton;
		private var acceptTitleButton:BitmapButton;
		
		private var titleEditing:Boolean;
		private var lastValue:String;
		private var _value:String;
		private var nameInputBottom:Bitmap;
		private var showButtons:Boolean;
		
		public var S_CHANGED:Signal = new Signal("TitleTextEditor.S_CHANGED");
		private var _prompt:String;
		
		public function TitleTextEditor(showButtons:Boolean = true) 
		{
			this.showButtons = showButtons;
			create();
		}
		
		public function set value(value:String):void
		{
			input.value = value;
		}
		
		public function get value():String 
		{
			return input.value;
		}
		
		public function get prompt():String 
		{
			return input.getDefValue();
		}
		
		public function set prompt(value:String):void 
		{
			input.setLabelText(value);
		}
		
		public function draw(componentWidth:int):void 
		{
			var inputWidth:int = componentWidth;
			
			input.width = inputWidth;
			
			if (showButtons)
			{
				inputWidth -= editTitleButton.width + Config.MARGIN;
				
				editTitleButton.x = int(inputWidth + input.view.x + Config.MARGIN);
				editTitleButton.y = int(input.view.y + input.view.height * .5 - editTitleButton.height * .5);
				
				acceptTitleButton.x = int(inputWidth + input.view.x + Config.MARGIN);
				acceptTitleButton.y = int(input.view.y + input.view.height * .5 - acceptTitleButton.height * .5);
			}
			
			nameInputBottom.width = inputWidth;
			nameInputBottom.y = input.height - Config.MARGIN * .5;
		}
		
		public function activate():void 
		{
			input.activate();
			if (showButtons)
			{
				if (editTitleButton.visible)
				{
					editTitleButton.activate();
				}
				
				if (acceptTitleButton.visible)
				{
					acceptTitleButton.activate();
				}
			}
		}
		
		public function deactivate():void 
		{
			input.deactivate();
			if (showButtons)
			{
				editTitleButton.deactivate();
				acceptTitleButton.deactivate();
			}
		}
		
		private function onFocusOut():void 
		{
			TweenMax.killDelayedCallsTo(saveTitle);
			TweenMax.delayedCall(30, saveTitle, null, true);
		}
		
		private function create():void 
		{
			input = new Input();
			input.setBorderVisibility(false);
			input.setRoundBG(false);
			input.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			input.setMode(Input.MODE_INPUT);
			input.S_FOCUS_OUT.add(onFocusOut);
			input.S_TAPPED.add(editTitle);
			input.S_FOCUS_IN.add(onTitleFocusIn);
			input.setRoundRectangleRadius(0);
			input.inUse = true;
			
			addChild(input.view);
			
			if (showButtons)
			{
				editTitleButton = new BitmapButton();
				editTitleButton.setStandartButtonParams();
				editTitleButton.setDownScale(1);
				editTitleButton.setDownColor(0xFFFFFF);
				editTitleButton.tapCallback = editTitle;
				editTitleButton.disposeBitmapOnDestroy = true;
				editTitleButton.show();
				
				addChild(editTitleButton);
				
				acceptTitleButton = new BitmapButton();
				acceptTitleButton.setStandartButtonParams();
				acceptTitleButton.setDownScale(1);
				acceptTitleButton.setDownColor(0xFFFFFF);
				acceptTitleButton.tapCallback = saveTitle;
				acceptTitleButton.disposeBitmapOnDestroy = true;
				acceptTitleButton.hide();
				
				addChild(acceptTitleButton);
				
				var editIcon:EditIcon = new EditIcon();
				UI.scaleToFit(editIcon, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
				editTitleButton.setBitmapData(UI.getSnapshot(editIcon, StageQuality.HIGH, "TitleTextEditor.editTitleButton"), true);
				
				var acceptIcon:acceptButtonIcon = new acceptButtonIcon();
				UI.scaleToFit(acceptIcon, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
				acceptTitleButton.setBitmapData(UI.getSnapshot(acceptIcon, StageQuality.HIGH, "TitleTextEditor.acceptTitleButton"), true);
				
				var horizontalOverflow:int = Math.max(0, (Config.FINGER_SIZE - editTitleButton.width) * .5);
				var verticalOverflow:int = Math.max(0, (Config.FINGER_SIZE - editTitleButton.height) * .5);
				editTitleButton.setHitZone(editTitleButton.width, editTitleButton.height);
				editTitleButton.setOverflow(verticalOverflow, horizontalOverflow, horizontalOverflow, verticalOverflow);
				
				acceptTitleButton.setHitZone(acceptTitleButton.width, acceptTitleButton.height);
				acceptTitleButton.setOverflow(verticalOverflow, horizontalOverflow, horizontalOverflow, verticalOverflow);
			}
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(AppTheme.GREY_MEDIUM);
			nameInputBottom = new Bitmap(hLineBitmapData);
			addChild(nameInputBottom);
		}
		
		private function editTitle():void
		{
			lastValue = input.value;
			input.setFocus();
			input.getTextField().setSelection(0, input.getTextField().length);
			input.getTextField().requestSoftKeyboard();
			if (showButtons)
			{
				editTitleButton.visible = false;
				acceptTitleButton.visible = true;
				
				acceptTitleButton.activate();
				editTitleButton.deactivate();
			}	
		}
		
		private function onTitleFocusIn():void 
		{
			lastValue = input.value;
			
			input.getTextField().setSelection(0, input.getTextField().length);
			if (showButtons)
			{
				editTitleButton.hide();
				acceptTitleButton.show();
				
				acceptTitleButton.activate();
				editTitleButton.deactivate();
			}
		}
		
		private function saveTitle():void 
		{
			TweenMax.killDelayedCallsTo(saveTitle);
			if (showButtons)
			{
				editTitleButton.show();
				acceptTitleButton.hide();
				
				acceptTitleButton.deactivate();
				editTitleButton.activate();
			}
			
			if (input.value == "")
			{
				input.value = lastValue;
			}
			if (input.value != lastValue)
			{
				lastValue = input.value;
				changeChatTitle();
			}
		}
		
		public function dispose():void
		{
			TweenMax.killDelayedCallsTo(editTitle);
			if (S_CHANGED)
			{
				S_CHANGED.dispose();
				S_CHANGED = null;
			}
			if (input)
			{
				input.S_FOCUS_OUT.remove(onFocusOut);
				input.S_TAPPED.remove(editTitle);
				input.S_FOCUS_IN.remove(onTitleFocusIn);
				input.dispose();
				input = null;
			}
			TweenMax.killDelayedCallsTo(saveTitle);
			if (editTitleButton)
			{
				editTitleButton.dispose();
				editTitleButton = null;
			}
			if (acceptTitleButton)
			{
				acceptTitleButton.dispose();
				acceptTitleButton = null;
			}
			if (nameInputBottom)
			{
				UI.destroy(nameInputBottom);
				nameInputBottom = null;
			}
		}
		
		private function changeChatTitle():void 
		{
			S_CHANGED.invoke();
		}
		
		private function onChatTitleChange(data:Object):void 
		{
			if (data.success)
			{
				lastValue = input.value;
			}
			else
			{
				input.value = lastValue;
			}
		}
		
	}

}