package com.dukascopy.connect.screens.dialogs.paymentDialogs.elements 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.LongClick;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.ViewContainer;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
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
		private var _onLongTapFunction:Function;
		private var _onChangedFunction:Function;
		private var _onSelectedFunction:Function;
		private var longClick:LongClick;
		private var selected:Boolean;
		
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
					input.value = parseFloat(val.toFixed(decimal)).toString();
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
			selected = false;
			drawUnderline(Style.color(Style.CONTROL_INACTIVE));
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
		}
		
		private function drawUnderline(color:Number):void 
		{
			if (underline.bitmapData)
			{
				underline.bitmapData.dispose();
				underline.bitmapData = null;
			}
			underline.bitmapData = UI.getHorizontalLine(3, color);
		}
		
		public function setPadding(value:int):void
		{
			input.setPadding(value);
		}
		
		public function drawString(itemWidth:int, titleValue:String, defaultValue:String, underlineString:String = null, typeValue:String = null):void 
		{
			this.itemWidth = itemWidth;
			
			drawTitle(titleValue);
			drawType(typeValue);
			drawUnderline(Style.color(Style.CONTROL_INACTIVE));
			drawUnderlineValue(underlineString);
			
			valueString = defaultValue;
			
			updatePositions();
		}
		
		public function updatePositions():void 
		{
			var tf:TextField = input.getTextField();
			var line:TextLineMetrics = tf.getLineMetrics(0);
			
			var titleHeight:int = Config.FINGER_SIZE * .26;
			
			input.view.y = int(title.y + titleHeight - Config.FINGER_SIZE * .1);
			input.width = itemWidth - valueField.width;
			
			valueContainer.x = int(input.view.x + itemWidth - valueField.width);
			valueContainer.y = int(input.view.y + tf.y + line.ascent - valueField.height + 2);
			underline.width = itemWidth;
			underline.y = int(input.view.y + input.height - Config.FINGER_SIZE * .10);
			
			underlineValue.x = int(itemWidth - underlineValue.width);
			underlineValue.y = int(underline.y + Config.FINGER_SIZE * .16);
		}
		
		public function draw(itemWidth:int, titleValue:String, defaultValue:Number = NaN, underlineString:String = null, typeValue:String = null, backColor:Number = NaN):void 
		{
			if (isNaN(backColor))
			{
				backColor = Style.color(Style.COLOR_BACKGROUND);
			}
			this.backColor = backColor;
			this.itemWidth = itemWidth;
			
			input.backgroundColor = backColor;
			
			drawTitle(titleValue);
			drawType(typeValue);
			drawUnderline(Style.color(Style.CONTROL_INACTIVE));
			drawUnderlineValue(underlineString);
			
			if (customMode == Input.MODE_INPUT)
			{
				
			}
			else
			{
				if (!isNaN(defaultValue))
				{
					value = defaultValue;
				}
			}
			
			updatePositions();
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
		
		public function setDefaultText(defaultText:String):void 
		{
			if (valueString == "")
			{
				input.setLabelText("0.0000", Style.color(Style.COLOR_SUBTITLE));
			}
			else
			{
				ApplicationErrors.add();
			}
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
		
		private function onSelected():void 
		{
			selected = true;
			if (input != null)
			{
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
		}
		
		private function onChanged():void 
		{
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