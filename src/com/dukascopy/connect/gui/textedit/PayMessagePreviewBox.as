package com.dukascopy.connect.gui.textedit {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class PayMessagePreviewBox extends Sprite {
		
		private static var PLUS_BMD:BitmapData;
		private static var EDIT_BMD:BitmapData;
		private static var BUTTON_SIZE:int;
		
		private var _viewWidth:int = 100;
		private var _viewHeight:int = 100;
		
		private var hPadding:int = 0;
		private var buttonWidth:int = 0;
		private var  baseCreated:Boolean = false;
		private var _emptyLabelText:String = "";
		private var _textValue:String = "";
		
		private var descriptionCanvas:Bitmap;
		private var underscoreCanvas:Bitmap;
		private var iconCanvas:Bitmap;
		private var currentIconBMD:BitmapData;
		private var textRenderer:TextField;
		
		public var updateCallback:Function;
		
		public function PayMessagePreviewBox() {
			super();
		}
		
		/** called before use **/
		public function init():void {
			if(_emptyLabelText == ""){
				emptyLabelText = Lang.emptyLabel;
			}
			if (descriptionCanvas == null) {
				descriptionCanvas = new Bitmap();
				addChild(descriptionCanvas);
			}
			if (underscoreCanvas == null) {
				underscoreCanvas = new Bitmap();
				addChild(underscoreCanvas);
			}
			if (iconCanvas == null) {
				iconCanvas = new Bitmap();
				addChild(iconCanvas);
			}
			BUTTON_SIZE= Math.ceil(Config.FINGER_SIZE * .35) * 2;
			PLUS_BMD ||= UI.getIconByFrame(15,BUTTON_SIZE,BUTTON_SIZE);
			EDIT_BMD ||=  UI.getIconByFrame(17,BUTTON_SIZE,BUTTON_SIZE);
			baseCreated = true;
		}
		
		/** fully clear component */
		public function dispose():void {
			clearDescription();
			clearUnderscore();
			if (textRenderer)
				textRenderer.text = "";
			textRenderer = null;
			if (descriptionCanvas != null)
				UI.destroy(descriptionCanvas);
			descriptionCanvas = null;
			if (underscoreCanvas != null)
				UI.destroy(underscoreCanvas);
			underscoreCanvas = null;
			if (iconCanvas != null)
				UI.destroy(iconCanvas);
			iconCanvas = null;
			if (EDIT_BMD != null)
				EDIT_BMD.dispose();
			EDIT_BMD = null;
			if (PLUS_BMD != null)
				PLUS_BMD.dispose();
			PLUS_BMD = null;
			baseCreated = false;
		}
		
		private function updateViewPort():void {
			if (!baseCreated)
				return;
			buttonWidth = BUTTON_SIZE + Config.DOUBLE_MARGIN;
			clearUnderscore();
			underscoreCanvas.bitmapData = UI.drawInputUnderLine(AppTheme.GREY_MEDIUM, _viewWidth - buttonWidth, 8, 2);
			onTextValueChanged();
			underscoreCanvas.y = descriptionCanvas.y + descriptionCanvas.height;
			iconCanvas.x = _viewWidth - iconCanvas.width;
			if (updateCallback != null)
				updateCallback();
		}
		
		/** ON TEXT CHANGE **/
		private function onTextValueChanged():void {
			if (UI.isEmpty(_textValue)) {
				// render empty label value
				clearDescription();
				descriptionCanvas.bitmapData = renderBitmapText(emptyLabelText);
				descriptionCanvas.x = hPadding;
				//set Plus icon
				PLUS_BMD ||= UI.getIconByFrame(15);
				setIcon(PLUS_BMD);
			} else {
				// render label value
				clearDescription();
				descriptionCanvas.bitmapData = renderBitmapText(_textValue);
				descriptionCanvas.x = hPadding;
				// set edit icon
				EDIT_BMD ||=  UI.getIconByFrame(17);
				setIcon(EDIT_BMD);
			}
			if (underscoreCanvas != null)
				underscoreCanvas.y = descriptionCanvas.y + descriptionCanvas.height;
			if (updateCallback != null)
				updateCallback();
		}
		
		/** SET ICON BMD */
		private function setIcon(bmd:BitmapData):void {
			if (currentIconBMD == bmd) return;
			currentIconBMD = bmd;
			if (iconCanvas != null) {
				iconCanvas.bitmapData = currentIconBMD;
			}
		}
		
		/** Render textsnapshot **/
		private function renderBitmapText(s:String):BitmapData {
			textRenderer ||= new TextField();// textRef.item;
			var itemHeight:int = Config.FINGER_SIZE * .8;
			var fmt:TextFormat = new TextFormat("Tahoma", itemHeight * .7 - Config.MARGIN * 2, 0x999999);
			
			textRenderer.width = _viewWidth - buttonWidth - hPadding * 2;
			textRenderer.height = 10;
			textRenderer.multiline = true;
			textRenderer.wordWrap = true;
			textRenderer.defaultTextFormat = fmt;
			textRenderer.autoSize = TextFieldAutoSize.LEFT;
			textRenderer.text = UI.trim(s);
			textRenderer.textColor = AppTheme.GREY_MEDIUM;
			
			// Cropping
			if (textRenderer.numLines > 3) {
				var firstLine:String  = textRenderer.getLineText(0);
				var secondLine:String  = textRenderer.getLineText(1);
				if (!UI.isEmpty(secondLine)) {
					secondLine = UI.trimRight(secondLine) + "...";
				}
				var result:String  = firstLine + secondLine;
				textRenderer.text = result;
			}
			
			var destWidth:int = _viewWidth;
			var destHeight:Number = textRenderer.height + 2;
			var bmd:ImageBitmapData = new ImageBitmapData("PayMessagePreviewBox.textsnapshot", destWidth, destHeight, true, 0x000000);
			bmd.draw(textRenderer);
			
			textRenderer.autoSize = TextFieldAutoSize.NONE;
			fmt = textRenderer.getTextFormat();
			fmt.align = TextFormatAlign.LEFT;
			
			return bmd;
		}
		
		private final function clearDescription():void {
			if (descriptionCanvas != null && descriptionCanvas.bitmapData != null) {
				descriptionCanvas.bitmapData.dispose();
				descriptionCanvas.bitmapData = null;
			}
		}
		
		private final function clearUnderscore():void {
			if (underscoreCanvas != null && underscoreCanvas.bitmapData != null) {
				underscoreCanvas.bitmapData.dispose();
				underscoreCanvas.bitmapData = null;
			}
		}
		
		private final function clearIcon():void {
			if (iconCanvas != null && iconCanvas.bitmapData != null) {
				iconCanvas.bitmapData.dispose();
				iconCanvas.bitmapData = null;
			}
		}
		
		// GETTERS AND SETTERS  =======================================================
		public function get textValue():String { return _textValue;	}
		public function set textValue(value:String):void {
			if (_textValue == value)
				return;
			_textValue = value;
			onTextValueChanged();
		}
		
		public function get viewWidth():int { return _viewWidth; }
		public function set viewWidth(value:int):void {
			if (_viewWidth == value)
				return;
			_viewWidth = value;
			if (_viewWidth < 1)
				_viewWidth = 1;
			updateViewPort();
		}

		public function get emptyLabelText():String { return _emptyLabelText; }
		public function set emptyLabelText(value:String):void {
			if (value == _emptyLabelText)
				return;
			_emptyLabelText = value;
			if (UI.isEmpty(_textValue)) {
				clearDescription();
				if (descriptionCanvas != null) {
					descriptionCanvas.bitmapData = renderBitmapText(_emptyLabelText);
					descriptionCanvas.x = hPadding;
				}
			}
		}
	}
}