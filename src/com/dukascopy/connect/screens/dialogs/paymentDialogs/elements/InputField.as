package com.dukascopy.connect.screens.dialogs.paymentDialogs.elements 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.LongClick;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.ViewContainer;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.utils.Loop;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class InputField extends Sprite
	{
		static public const ALIGN_LEFT:String = "alignLeft";
		public var underlineColor:Number;
		private var _decimals:int = -1;
		
		public function set decimals(value:int):void 
		{
			_decimals = value;
			format = value;
		}
		private var _onLongTapFunction:Function;
		private var _onChangedFunction:Function;
		private var _onSelectedFunction:Function;
		private var longClick:LongClick;
		private var selected:Boolean;
		private var _align:String;
		private var defaultValue:Number;
		private var titleValue:String;
		private var typeValue:String;
		private var underlineString:String;
		private var showPasteButton:Boolean;
		private var pasteButtton:BitmapButton;

		public function get align():String
		{
			return _align;
		}

		public function set align(value:String):void
		{
			_align = value;
		}

		protected var title:Bitmap;
		protected var valueField:Bitmap;
		protected var underline:Bitmap;
		protected var input:Input;
		protected var underlineValue:Bitmap;
		protected var itemWidth:int;
		protected var format:int;
		protected var customMode:String;
		protected var backColor:Number;
		protected var right:Sprite;
		protected var valueContainer:Sprite;
		
		public function InputField(format:int = -1, customMode:String = null)
		{
			this.format = format;
			this.customMode = customMode;
			create();
		}
		
		public function set restrict(value:String):void
		{
			if (input != null)
			{
				input.getTextField().restrict = value;
			}
		}
		
		public function set backgroundAlpha(value:Number):void 
		{
			if (input != null)
			{
				input.backgroundAlpha = value;
			}
		}
		
		public function get textY():int
		{
			if (input != null && input.getTextField() != null)
			{
				return input.view.y + input.getTextField().y;
			}
			return 0;
		}
		
		public function get textHeight():int
		{
			if (input != null && input.getTextField() != null)
			{
				return input.getTextField().height;
			}
			return 0;
		}
		
		public function get value():Number
		{
			if (input != null)
			{
				return parseFloat(input.value);
			}
			return 0;
		}
		
		public function get valueString():String
		{
			if (input != null)
			{
				return input.value;
			}
			
			return null;
		}
		
		public function set valueString(val:String):void
		{
			if (input != null)
			{
				input.value = val;
				input.setCurrentColor();
			}
		}
		
		public function set value(val:Number):void
		{
			var startValue:Number = val;
			if (isNaN(val))
			{
				input.value = "";
			}
			else
			{
				if (format != -1)
				{
					var decimal:int = format;
					var result:Number = getFormat(val, decimal);
					if (result == 0)
					{
						decimal += 2;
						result = getFormat(val, decimal);
					}
					if (result == 0)
					{
						decimal += 2;
						result = getFormat(val, decimal);
					}
					if (result == 0)
					{
						decimal = format;
					}
					var resultString:String;
					if (_decimals == -1)
					{
						resultString = parseFloat(val.toFixed(decimal)).toString();
					}
					else
					{
						resultString = val.toFixed(decimal);
					}
					input.value = resultString;
				}
				else
				{
					input.value = val.toString();
				}
			}
		}
		
		private function getFormat(value:Number, decimal:int):Number 
		{
			var k:Number = Math.pow(10, decimal);
			return Math.round(value * k) / k;
		}
		
		protected function create():void 
		{
			var mode:String = Input.MODE_DIGIT_DECIMAL;
			if (customMode != null)
			{
				mode = customMode;
			}
			
			var inputTF:TextFormat = new TextFormat();
			inputTF.color = Style.color(Style.COLOR_TEXT);
			inputTF.font = Config.defaultFontName;
			inputTF.size = Config.FINGER_SIZE * .4;
			if (mode == Input.MODE_DIGIT_DECIMAL)
			{
				inputTF.align = TextFormatAlign.RIGHT;
			}
			else
			{
				inputTF.align = TextFormatAlign.LEFT;
			}
			
			input = new Input(mode);
			input.setBorderVisibility(false);
			input.setLabelText("");
			input.setParams("", mode);
			input.S_CHANGED.add(onChanged);
			input.S_FOCUS_IN.add(onSelected);
			input.S_FOCUS_LOST.add(onFocusOut);
			
			input.setRoundBG(false);
			input.setRoundRectangleRadius(0);
			input.inUse = true;
			input.updateTextFormat(inputTF);
			addChild(input.view);
			
			title = new Bitmap();
			addChild(title);
			
			valueContainer = new Sprite();
			addChild(valueContainer);
			
			valueField = new Bitmap();
			valueContainer.addChild(valueField);
			
			underline = new Bitmap();
			addChild(underline);
			
			underlineValue = new Bitmap();
			addChild(underlineValue);
			
			right = new Sprite();
			right.graphics.beginFill(0x00ff00, 0);
			right.graphics.drawRect(0, 0, Config.FINGER_SIZE * .6, Config.FINGER_SIZE);
			right.graphics.endFill();
		//	addChild(right);
		}
		
		private function onFocusOut():void 
		{
			removePasteButton();
			selected = false;
			drawUnderline(getUnderlineColor());
		}
		
		private function drawType(value:String):void 
		{
			if (valueField.bitmapData)
			{
				valueField.bitmapData.dispose();
				valueField.bitmapData = null;
			}
			if (value != null)
			{
				valueField.bitmapData = TextUtils.createTextFieldData(value, itemWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .4, false, Style.color(Style.COLOR_SUBTITLE), backColor, true, true);
			}
		}
		
		private function drawTitle(value:String):void 
		{
			if (title.bitmapData)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			if (value != null)
			{
				title.bitmapData = TextUtils.createTextFieldData(value, itemWidth, 10, 
																false, TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																FontSize.SUBHEAD,
																false, Style.color(Style.COLOR_SUBTITLE), backColor, false, true);
			}
		}
		
		public function drawUnderlineValue(value:String):void 
		{
			underlineString = value;
			if (underlineValue.bitmapData)
			{
				underlineValue.bitmapData.dispose();
				underlineValue.bitmapData = null;
			}
			
			if (value != null)
			{
				underlineValue.bitmapData = TextUtils.createTextFieldData(value, itemWidth, 10, true, TextFormatAlign.RIGHT, 
																		TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, Style.color(Style.COLOR_SUBTITLE), backColor, false, true);
			}
			if (align == ALIGN_LEFT)
			{
				underlineValue.x = 0;
			}
			else
			{
				underlineValue.x = int(itemWidth - underlineValue.width);
			}
		}
		
		private function drawUnderline(color:Number):void 
		{
			if (underline.bitmapData)
			{
				underline.bitmapData.dispose();
				underline.bitmapData = null;
			}
			underline.bitmapData = UI.getHorizontalLine(color);
		}
		
		public function setPadding(value:int):void
		{
			input.setTextStart(value);
		}
		
		public function drawString(itemWidth:int, titleValue:String, defaultValue:String, underlineString:String = null, typeValue:String = null):void 
		{
			this.titleValue = titleValue;
			this.typeValue = typeValue;
			this.underlineString = underlineString;
			
			this.itemWidth = itemWidth;
			
			drawTitle(titleValue);
			drawType(typeValue);
			
			drawUnderline(getUnderlineColor());
			drawUnderlineValue(underlineString);
			
			setDefaultText(defaultValue);
			
			updatePositions();
		}
		
		public function draw(itemWidth:int, titleValue:String, defaultValue:Number = NaN, underlineString:String = null, typeValue:String = null, backColor:Number = NaN):void 
		{
			this.titleValue = titleValue;
			this.typeValue = typeValue;
			this.underlineString = underlineString;
			
			this.defaultValue = defaultValue;
			if (isNaN(backColor))
			{
				backColor = Style.color(Style.COLOR_BACKGROUND);
			}
			this.backColor = backColor;
			this.itemWidth = itemWidth;
			
			input.backgroundColor = backColor;
			
			drawTitle(titleValue);
			drawType(typeValue);
			drawUnderline(getUnderlineColor());
			drawUnderlineValue(underlineString);
			
			if (customMode == Input.MODE_INPUT)
			{
				
			}
			else
			{
				if (!isNaN(defaultValue) && value != defaultValue)
				{
					value = defaultValue;
				}
			}
			
			updatePositions();
		}
		
		private function getUnderlineColor():Number 
		{
			var lineColor:Number = Style.color(Style.CONTROL_INACTIVE);
			if (!isNaN(underlineColor))
			{
				lineColor = underlineColor;
			}
			return lineColor;
		}
		
		public function updatePositions():void 
		{
			var tf:TextField = input.getTextField();
			var line:TextLineMetrics = tf.getLineMetrics(0);
			
			var titleHeight:int = FontSize.SUBHEAD;
			
			input.view.y = int(title.y + titleHeight - Config.FINGER_SIZE * .15);
			if (valueField.width > 0)
			{
				input.width = (itemWidth - valueField.width - Config.FINGER_SIZE*.1);
			}
			else
			{
				input.width = itemWidth;
			}
			
			valueContainer.x = int(input.view.x + itemWidth - valueField.width);
			valueContainer.y = int(input.view.y + tf.y + line.ascent - valueField.height + 2);
			underline.width = itemWidth;
			underline.y = int(input.view.y + input.linePosition);
			
			if (align == ALIGN_LEFT)
			{
				underlineValue.x = 0;
			}
			else
			{
				underlineValue.x = int(itemWidth - underlineValue.width);
			}
			underlineValue.y = int(underline.y + Config.FINGER_SIZE * .16);
		}
		
		public function showValue():void
		{
			if (input != null)
			{
				input.view.visible = true;
			}
		}
		
		public function activate():void
		{
			if (input != null)
			{
				input.activate();
			}
			if (longClick != null)
			{
				longClick.activate();
			}
		//	PointerManager.addTap(right, select);
		}
		
		private function select(e:Event = null):void{
			e.preventDefault();
			e.stopImmediatePropagation();
			e.stopPropagation();
			TweenMax.delayedCall(5,input.requestKeyboard,null,true);
		}
		
		private function selectText():void 
		{
			if (input)
			{
				input.requestKeyboard();
				input.getTextField().setSelection(input.value.length, input.value.length);
			}
		}
		
		public function deactivate():void
		{
			if (input != null)
			{
				input.deactivate();
			}
			if (longClick != null)
			{
				longClick.deactivate();
			}
			PointerManager.removeTap(right, select);
		}
		
		public function dispose():void
		{
			_onChangedFunction = null;
			_onSelectedFunction = null;
			_onLongTapFunction = null;
			
			TweenMax.killTweensOf(pasteButtton);
			deletePasteButton();
			
			TweenMax.killDelayedCallsTo(selectText);
			
			if (longClick != null)
			{
				longClick.dispose();
				longClick = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null
			}
			if (valueField != null)
			{
				UI.destroy(valueField);
				valueField = null
			}
			if (underline != null)
			{
				UI.destroy(underline);
				underline = null
			}
			if (underlineValue != null)
			{
				UI.destroy(underlineValue);
				underline = null
			}
			if (valueContainer != null)
			{
				UI.destroy(valueContainer);
				valueContainer = null
			}
			if (input != null)
			{
				input.S_CHANGED.remove(onChanged);
				input.S_FOCUS_IN.remove(onSelected);
				input.S_FOCUS_LOST.remove(onFocusOut);
				input.dispose();
				input = null
			}
		}
		
		public function getHeight():int 
		{
			if (underlineValue != null && underlineValue.bitmapData != null)
			{
				return underlineValue.y + underlineValue.height;
			}
			else if (underline != null)
			{
				return underline.y + underline.height;
			}
			return 0;
		}
		
		public function invalid():void 
		{
			if (underline != null)
			{
				UI.colorize(underline, Color.RED);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function valid():void 
		{
			underline.transform.colorTransform = new ColorTransform();
		}
		
		public function setDefaultText(value:String):void 
		{
			input.setLabelText(value, Style.color(Style.COLOR_SUBTITLE));
		}
		
		public function forceFocusOut():void 
		{
			if (input != null)
			{
				input.forceFocusOut();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function setMaxChars(value:int):void 
		{
			if (input != null)
			{
				input.getTextField().maxChars = value;
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function updateTextFormat(value:TextFormat):void 
		{
			if (input != null)
			{
				input.updateTextFormat(value);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function isSelected():Boolean 
		{
			return selected;
		}
		
		public function disable():void 
		{
			if (input != null)
			{
				input.disable();
			}
		}
		
		public function enable():void 
		{
			if (input != null)
			{
				input.enable();
			}
		}
		
		public function getFullHeight():int 
		{
			return underline.y + Config.FINGER_SIZE * .3;
		}
		
		public function linePosition():int 
		{
			return underline.y;
		}
		
		public function getUnderlineValue():String 
		{
			return underlineString;
		}
		
		public function setBackground(color:Number):void 
		{
			if (input != null)
			{
				input.backgroundColor = color;
			}
		}
		
		public function hideValue():void 
		{
			if (input != null)
			{
				input.view.visible = false;
			}
		}
		
		public function implementPaste():void 
		{
			showPasteButton = true;
		}
		
		public function getTextWidth():int 
		{
			if (input != null)
			{
				return input.getTextWidth();
			}
			return 0;
		}
		
		public function get textAscent():int 
		{
			if (input != null)
			{
				return input.textAscent;
			}
			return 0;
		}
		
		private function onSelected():void 
		{
			selected = true;
			if (input != null)
			{
				if (!isNaN(defaultValue) && !isNaN(Number(input.value)) && Number(input.value) == defaultValue && defaultValue == 0)
				{
					input.value = "";
				}
				
				//trace(input.value.length);
				if (input.getTextField().selectionBeginIndex == input.getTextField().selectionEndIndex && 
					input.value != null && 
					input.value.length > 0)
					{
						if (input.getTextField().selectionEndIndex < input.value.length)
						{
							if (input.value.length == 1)
							{
								input.getTextField().setSelection(1, 1);
							}
							else if (input.value.length == 2)
							{
								if (input.getTextField().selectionEndIndex == 1)
								{
									input.getTextField().setSelection(2, 2);
								}
							}
							else if (input.value.length > 2)
							{
								if (input.getTextField().selectionEndIndex > input.value.length - 2)
								{
									input.getTextField().setSelection(input.value.length, input.value.length);
								}
							}
						}
					}
				
			}
			if (_onSelectedFunction != null)
			{
				_onSelectedFunction();
			}
			drawUnderline(Color.GREEN);
			
			if (valueString == "" && showPasteButton)
			{
				addPasteButton();
			}
		}
		
		private function addPasteButton():void 
		{
			if (pasteButtton == null)
			{
				pasteButtton = new BitmapButton();
				pasteButtton.setStandartButtonParams();
				pasteButtton.tapCallback = onPasteClick;
				pasteButtton.disposeBitmapOnDestroy = true;
				pasteButtton.setDownScale(1);
			//	pasteButtton.setOverlay(HitZoneType.BUTTON);
				addChild(pasteButtton);
				
				var clip:Sprite = new Sprite();
				var text:Bitmap = new Bitmap(TextUtils.createTextFieldData(Lang.paste, itemWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, Style.color(Style.COLOR_BACKGROUND),
																		Style.color(Style.COLOR_BUTTON_ACCENT)));
				clip.addChild(text);
				var vGap:int = Config.FINGER_SIZE * .2;
				var hGap:int = Config.FINGER_SIZE * .25;
				text.x = hGap;
				text.y = vGap;
				clip.graphics.beginFill(Style.color(Style.COLOR_BUTTON_ACCENT));
				var r:int = Config.FINGER_SIZE * .2;
				clip.graphics.drawRoundRect(0, 0, text.width + hGap * 2, text.height + vGap * 2, r, r);
				clip.graphics.endFill();
				clip.graphics.beginFill(Style.color(Style.COLOR_BUTTON_ACCENT));
				clip.graphics.moveTo(r * 1, text.height + vGap * 2);
				clip.graphics.lineTo(r * 2, text.height + vGap * 2);
				clip.graphics.lineTo(r * 1.5, text.height + vGap * 2 + r / 2);
				clip.graphics.lineTo(r * 1, text.height + vGap * 2);
				clip.graphics.endFill();
				pasteButtton.setBitmapData(UI.getSnapshot(clip), true);
				UI.destroy(text);
				UI.destroy(clip);
				
				pasteButtton.x = int(input.view.x + Config.FINGER_SIZE * .1);
				pasteButtton.y = int(input.view.y - pasteButtton.height + input.getTextField().y - Config.FINGER_SIZE * .05);
				pasteButtton.activate();
			}
		}
		
		private function onPasteClick():void 
		{
			removePasteButton();
			var clip:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			if (clip != null)
			{
				valueString = clip;
			}
		}
		
		private function onChanged():void 
		{
			removePasteButton();
			
			if (customMode == Input.MODE_DIGIT_DECIMAL)
            {
                if (valueString != null && valueString.length > 0 && valueString.charAt(0) == "0" && !isNaN(Number(valueString)))
                {
                    if (valueString.length > 1 && (valueString.charAt(1) == "." || valueString.charAt(1) == ","))
                    {
						
                    }
                    else
                    {
                        value = Number(valueString);
                    }
                }
            }
			
			if (_onChangedFunction != null)
			{
				_onChangedFunction();
			}
		}
		
		private function removePasteButton():void 
		{
			if (pasteButtton != null)
			{
				TweenMax.killTweensOf(pasteButtton);
				TweenMax.to(pasteButtton, 0.2, {delay:0.2, alpha:0, onComplete:deletePasteButton});
			}
		}
		
		private function deletePasteButton():void
		{
			TweenMax.killTweensOf(pasteButtton);
			if (pasteButtton != null)
			{
				if (contains(pasteButtton))
				{
					removeChild(pasteButtton);
				}
				pasteButtton.dispose();
				pasteButtton = null;
			}
		}
		
		public function set onChangedFunction(value:Function):void 
		{
			_onChangedFunction = value;
		}
		
		public function set onLongTapFunction(value:Function):void 
		{
			_onLongTapFunction = value;
			if (longClick != null)
			{
				longClick.dispose();
				longClick = null;
			}
			longClick = new LongClick(input.view as ViewContainer, _onLongTapFunction);
		}
		
		public function set onSelectedFunction(value:Function):void 
		{
			_onSelectedFunction = value;
		}
		
		public function get contentPosition():int
		{
			return valueContainer.y;
		}
	}
}