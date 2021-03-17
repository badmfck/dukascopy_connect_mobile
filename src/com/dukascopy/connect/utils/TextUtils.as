package com.dukascopy.connect.utils {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class TextUtils {
		
		static public const NULL:String = "~!~";
		 
		static private var serviceTextField:TextField;
		static private var serviceSprite:Sprite;
		private var radius:int;
		
		public function TextUtils() { }
		
		public static function truncate(textField:TextField):void {
			var autosizeType:String = textField.autoSize;
			var maxWidth:Number = textField.width;
			textField.autoSize = TextFieldAutoSize.LEFT;
			if (textField.width > maxWidth) {
				textField.appendText("...");
				while(textField.width > maxWidth || textField.numLines > 1) {
					if (textField.length < 4) {
						break;
					}
					textField.text = textField.text.substr(0, -4) + "...";
				}
			}
			else if (textField.multiline == false && textField.numLines > 1) {
				var count:int = 300;
				textField.appendText("...");
				while (textField.numLines > 1) {
					count --;
					if (textField.length < 4) {
						break;
					}
					if (count < 0)
					{
						break;
					}
					textField.text = textField.text.substr(0, -4) + "...";
				}
			}
			textField.autoSize = autosizeType;
		}
		
		public static function getServerName(url:String):String
		{
			var tmp:int = url.indexOf('://');
			if (tmp == -1) return '';
			
			var colonIndex:int = url.indexOf(':', tmp + 3);
			var slashIndex:int = url.indexOf('/', tmp + 3);
			var endIndex:int = Math.min(colonIndex == -1 ? url.length : colonIndex, slashIndex == -1 ? url.length : slashIndex);
			return url.substring(tmp + 3, endIndex);
		}
		
		public static function clearDelimeters(formattedString:String):String {     
			return formattedString.replace(/[\u000d\u000a\u0008]+/g,""); 
		}
		
		static public function getPassStrenghtLevel(passValue:String):int 
		{
			var counter:int;
			
			var validateLvl1 : RegExp = /(\d+)/;
			var validateLvl2 : RegExp = /([a-zа-я]+)/;
			var validateLvl3 : RegExp = /([A-ZА-Я]+)/;
			var validateLvl4 : RegExp = /([^A-Za-zА-Яа-я0-9]+)/;
			
			counter = 0;
			
			if (validateLvl1.test(passValue))
				counter += 1;
			
			if(validateLvl2.test(passValue))
				counter += 1;
			
			if(validateLvl3.test(passValue))
				counter += 1;
			
			if(validateLvl4.test(passValue))
				counter += 1;
			
			if(passValue.length > 8)
				counter += 1;
			
			if(passValue.length > 15)
				counter += 1;
			
			return counter;
		}
		
		public static function createbutton(text:TextFieldSettings, backgroundColor:Number, 
											backgroundAlpha:Number = 0.6, 
											sidePadding:int = -1, 
											outlineColor:Number = NaN, overridedWidth:int = -1, verticalPadding:int = -1, radius:Number = NaN, outlineAlpha:Number = 1):ImageBitmapData
		{
			serviceSprite ||= new Sprite();
			serviceSprite.graphics.clear();
			serviceTextField ||= new TextField();
			var textField:TextField = serviceTextField;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = text.color;
			textFormat.font = Config.defaultFontName;
			textFormat.size = text.size;
			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.width = MobileGui.stage.fullScreenWidth;
			textField.multiline = false;
			textField.wordWrap = false;
			textField.text = text.text;
			textField.setTextFormat(textFormat);
			
			textField.width = textField.textWidth + 4;
			textField.height = textField.textHeight + 4;
			
			if (verticalPadding == -1)
			{
				verticalPadding = Config.MARGIN * 1.2;
			}
			
			var horizontalPadding:int;
			if (sidePadding == -1)
			{
				horizontalPadding = Config.FINGER_SIZE * 1.0;
			}
			else {
				horizontalPadding = sidePadding;
			}
			var itemHeight:int = textField.height + verticalPadding * 2;
			
			var lineStyle:int = 0;
			if (!isNaN(outlineColor))
			{
				lineStyle = Math.max(1, int(Config.FINGER_SIZE * .02));
				serviceSprite.graphics.lineStyle(lineStyle, outlineColor, outlineAlpha);
			}
			
			var itemWidth:int = textField.width + horizontalPadding * 2;
			if (overridedWidth != -1)
			{
				itemWidth = overridedWidth;
				horizontalPadding = int(itemWidth * .5 - textField.width * .5);
			}
			
			serviceSprite.graphics.beginFill(backgroundColor, backgroundAlpha);
			var r:int = itemHeight;
			if (!isNaN(radius))
			{
				r = radius;
			}
			serviceSprite.graphics.drawRoundRect(0, 0, itemWidth, textField.height + verticalPadding * 2, r, r);
			serviceSprite.graphics.endFill();
			
			var bitmapData:ImageBitmapData = new ImageBitmapData("TextUtils.createbutton", serviceSprite.width + lineStyle, serviceSprite.height + lineStyle);
			var matrix1:Matrix = new Matrix();
			matrix1.translate(lineStyle/2, lineStyle/2);
			bitmapData.draw(serviceSprite, matrix1);
			var matrix:Matrix = new Matrix();
			matrix.translate(horizontalPadding, verticalPadding);
			bitmapData.draw(textField, matrix);
			
			return bitmapData;
		}
		
		//used to provide bitmap data with valid actual(minimal possible) width and height of the needed text;
		public static function createTextFieldImage(text:String = "", width:int = 100, height:int = 10, 
												multiline:Boolean = true, align:String =  TextFormatAlign.CENTER, 
												autoSize:String = TextFieldAutoSize.LEFT, 
												fontSize:int = 26, 
												wordWrap:Boolean = false, 
												textColor:uint = 0x686868, 
												backgroundColor:uint = 0xffffff, 
												isTransparent:Boolean = false, 
												html:Boolean = false,
												maxHeight:int = 1500,
												needTrimming:Boolean = true):Vector.<ImageBitmapData>
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			
			serviceTextField ||= new TextField();
			var textFormat:TextFormat = new TextFormat();		
			textFormat.font = Config.defaultFontName;
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.italic = false;
			serviceTextField.autoSize = autoSize;
			serviceTextField.multiline = multiline;
			serviceTextField.wordWrap = wordWrap;
			serviceTextField.textColor = textColor;
			serviceTextField.border = false;
			serviceTextField.defaultTextFormat = textFormat;
			if (html)
			{
				serviceTextField.htmlText = text;
			}
			else {
				serviceTextField.text = text;
			}
			
			serviceTextField.width = width;
			
			serviceTextField.height = serviceTextField.textHeight;
			serviceTextField.height = 100;
			var textFieldWidth:Number;
			if (autoSize == TextFieldAutoSize.LEFT)
			{
				textFieldWidth = Math.min(serviceTextField.width, width);
			}
			else
			{
				textFieldWidth = width;
			}
			
			var newBmd:ImageBitmapData;
			var trimed:ImageBitmapData
			var result:Vector.<ImageBitmapData> = new Vector.<ImageBitmapData>();
			var itemsToDraw:int = Math.ceil(serviceTextField.height / maxHeight);
			
			var matrix:Matrix;
			var startPosition:int = 0;
			var endPosition:int;
			for (var i:int = 0; i < itemsToDraw; i++) 
			{
				startPosition = i * maxHeight;
				endPosition =  (i == itemsToDraw - 1)?serviceTextField.height:(i + 1) * maxHeight;
				newBmd =  new ImageBitmapData("TextUtils.createTextFieldImage", textFieldWidth, endPosition - startPosition, isTransparent, backgroundColor);
				matrix = new Matrix();
				matrix.translate(0, -startPosition);
				newBmd.drawWithQuality(serviceTextField, matrix, null, null, null, false, StageQuality.HIGH);
				
				if (needTrimming)
				{
					result.push(getTrimmed(newBmd, (i==0), (i==itemsToDraw - 1)));
				}
				else {
					result.push(newBmd);
				}
			}
			
			serviceTextField.text = "";
			serviceTextField.height = serviceTextField.textHeight;
			return result;
		}
		
		static private function getTrimmed(source:BitmapData, trimTop:Boolean, trimBottom:Boolean):BitmapData 
		{
			var notAlphaBounds:Rectangle = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			
			if (notAlphaBounds.width == 0 || notAlphaBounds.height == 0)
			{
				return source;
			}
			
			if (!trimTop)
			{
				notAlphaBounds.y = 0;
			}
			if(!trimBottom)
			{
				notAlphaBounds.y = source.height - notAlphaBounds.y;
			}
			
			var trimed:ImageBitmapData = new ImageBitmapData("TextUtils.getTrimmed", notAlphaBounds.width, notAlphaBounds.height, true, 0x00000000);
			trimed.copyPixels(source, notAlphaBounds, new Point());
			source.dispose();
			source = null;
			
			return trimed;
		}
		
		//used to provide bitmap data with valid actual(minimal possible) width and height of the needed text;
		public static function createTextFieldData(
			text:String = "",
			width:int = 100,
			height:int = 10,
			multiline:Boolean = true,
			align:String =  TextFormatAlign.CENTER, 
			autoSize:String = TextFieldAutoSize.LEFT,
			fontSize:int = 26,
			wordWrap:Boolean = false, 
			textColor:uint = 0x686868,
			backgroundColor:uint = 0xffffff, 
			isTransparent:Boolean = false,
			html:Boolean = false,
			truncateText:Boolean = false,
			customFont:String = null,
			textLineMetrics:TextLineMetrics = null):ImageBitmapData {


				if (text == null)
					text = "";
				if (width < 1)
					width = 1;
				if (height < 1)
					height = 1;
				serviceTextField ||= new TextField();
				var textFormat:TextFormat = new TextFormat();
				if (customFont)
					textFormat.font = customFont;
				else
					textFormat.font = Config.defaultFontName;
				textFormat.size = fontSize;
				textFormat.align = align;
				textFormat.italic = false;
				serviceTextField.autoSize = autoSize;
				serviceTextField.multiline = multiline;
				serviceTextField.wordWrap = wordWrap;
				serviceTextField.textColor = textColor;
				serviceTextField.border = false;
				serviceTextField.defaultTextFormat = textFormat;
				if (html)
					serviceTextField.htmlText = text;
				else
					serviceTextField.text = text;
				serviceTextField.width = width;
				if (!multiline && truncateText && (height == 10 || height == 1))
					TextUtils.truncate(serviceTextField);
				serviceTextField.height = serviceTextField.textHeight + 4;
				var textFieldWidth:Number;
				if (autoSize == TextFieldAutoSize.LEFT)
					textFieldWidth = Math.min(serviceTextField.width, width);
				else
					textFieldWidth = width;
				if (textLineMetrics) {
					var fieldMetrics:TextLineMetrics = serviceTextField.getLineMetrics(0);
					textLineMetrics.ascent = fieldMetrics.ascent;
				}
				var resultHeight:int = serviceTextField.height;
				if (height != 10 && height != 1)
					resultHeight = height;
				var newBmd:ImageBitmapData = new ImageBitmapData("TextUtils.temp_1", textFieldWidth, resultHeight, true, 0x00ffffff);

				newBmd.draw(serviceTextField);
				
				var notAlphaBounds:Rectangle = newBmd.getColorBoundsRect(0xFFFFFFFF, textColor, false);
				if (notAlphaBounds.width == 0 || notAlphaBounds.height == 0)
					return newBmd;
				var trimed:ImageBitmapData = new ImageBitmapData("TextUtils.text", notAlphaBounds.width, notAlphaBounds.height, true, 0x00ffffff);
				trimed.copyPixels(newBmd, notAlphaBounds, new Point(), null, null, true);
				
				newBmd.dispose();
				newBmd = null;
				serviceTextField.text = "";
				return trimed;
		}
		
		public static function objectToString(obj : Object, omitNull : Boolean = true, depth : uint = 0, indent : uint = 0, prefix : String = "") : String
		{
			if(obj)
			{
				// Get the description of the class
				var description : XML = describeType(obj);
				var properties : Array = [];
				
				// Get accessors from description
				for each(var a:XML in description.accessor)
				{
					properties.push(String(a.@name));
				}
				
				// Get variables from description
				for each(var v:XML in description.variable)
				{
					properties.push(String(v.@name));
				}
				
				// Get dynamic properties if the class is dynamic
				if(description.@isDynamic == "true")
				{
					for(var p : String in obj)
					{
						properties.push(p);
					}
				}
				// Sort
				properties.sort();
				
				// Build the string with properties and values
				var tabs : String = "";
				for(var t : int = 0; t < indent; t++)
				{
					tabs += "|\t";
				}
				var str : String = tabs + "[";
				if(prefix != "")
					str += prefix + ":";
				
				var desName : String = description.@name;
				str += (desName.search("::") == -1) ? desName : desName.slice(desName.search("::") + 2, desName.length);
				
				var appendAfter : Array = [];
				
				var pL : int = properties.length;
				for(var i : int = 0;i < pL;i++)
				{
					var mustOutput : Boolean = true;
					
					if(omitNull)
					{
						try
						{
							if(obj[properties[i]] == null || obj[properties[i]] == undefined || obj[properties[i]] === "")
								mustOutput = false;
						}
						catch(err : Error)
						{
							mustOutput = false;
						}
					}
					
					if(mustOutput)
					{
						if(depth > 0 && (typeof obj[properties[i]] == "object"))
							appendAfter.push(properties[i]);
						else
							str += " | " + properties[i] + " = " + obj[properties[i]];
					}
				}
				str += "]";
				
				depth--;
				indent++;
				
				var aL : int = appendAfter.length;
				for(var k : int = 0; k < aL; k++)
				{
					str += "\n" + objectToString(obj[appendAfter[k]], omitNull, depth, indent, appendAfter[k]);
				}
				
				return str;
			}
			
			return "";
		}
		
		static public function toReadbleFileSize(bytes:Number):String 
		{
			if (bytes == 0)
			{
				return "0";
			}
			var s:Array = ['b', 'kb', 'MB', 'GB', 'TB', 'PB'];
            var exp:Number = Math.floor(Math.log(bytes)/Math.log(1024));
            return  (bytes / Math.pow(1024, Math.floor(exp))).toFixed(2) + " " + s[exp];
		}

		static public function parseChatInvoiceText(txt:String):String {
			var arr:Array;
			if (txt.indexOf(Config.BOUNDS_INVOICE) == 0) {
				arr = txt.split(Config.BOUNDS_INVOICE);
				
				if (arr.length == 1) {
					return  arr[0];
				} else {
					return arr[1];
				}
			}
			return txt;
		}
		
		static public function generateRandomString(strlen:Number):String
		{
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.";
			var num_chars:Number = chars.length - 1;
			var randomChar:String = "";
			
			for (var i:Number = 0; i < strlen; i++)
			{
				randomChar += chars.charAt(Math.floor(Math.random() * num_chars));
			}
		  return randomChar;
		}
		
		static public function isAvatarLetterSupported(char:String):Boolean {
			var regexp:RegExp = /[a-zA-Zа-яёА-Я]/;
			return regexp.test(char);
		}
		
		static public function checkForNumber(nameValue:String):String 
		{
			if (nameValue != null && nameValue.length > 9 && nameValue.substr(0, 5).toLowerCase() == "user " && 
				!isNaN(Number(nameValue.substr(5, 2))) && !isNaN(Number(nameValue.substr(nameValue.length - 2, 2))))
			{
				return nameValue.substr(0, 7) + ".." + nameValue.substr(nameValue.length - 2, 2);
			}
			else if (nameValue != null && nameValue.length > 8 && nameValue.substr(0, 4).toLowerCase() == "user" && 
				!isNaN(Number(nameValue.substr(4, 2))) && !isNaN(Number(nameValue.substr(nameValue.length - 2, 2))))
			{
				return nameValue.substr(0, 6) + ".." + nameValue.substr(nameValue.length - 2, 2);
			}
			return nameValue;
		}
		
		static public function formatTime(duration:Number):String 
		{
			if (!isNaN(duration))
			{
				return convertToHHMMSS(duration/1000);
			}
			else
			{
				return "";
			}
		}
		
		static public function getTextField():TextField 
		{
			if (serviceTextField == null){
				serviceTextField = new TextField();
			}
			return serviceTextField;
		}
		
		static private function convertToHHMMSS(seconds:Number):String
		{
			var s:Number = seconds % 60;
			var m:Number = Math.floor((seconds % 3600 ) / 60);
			var h:Number = Math.floor(seconds / (60 * 60));
			 
			var hourStr:String = (h == 0) ? "" : doubleDigitFormat(h) + ":";
			var minuteStr:String = doubleDigitFormat(m) + ":";
			var secondsStr:String = doubleDigitFormat(s);
			 
			return hourStr + minuteStr + secondsStr;
		}
		 
		static private function doubleDigitFormat(num:uint):String
		{
			if (num < 10) 
			{
				return ("0" + num);
			}
			return String(num);
		}
		
		static public function getHTMLTemplate(body:String):String {
			body = body.replace(/\t/g, "&#9;");
			body = body.replace(/\n/g, "<br>");
			var head:String = "";
			var html:String = "<!DOCTYPE html>"+
					"<html>"+
					  "<head>"+
						"<meta charset='UTF-8'>" +
					    "<meta name='viewport' content='width=device-width, initial-scale=1, user-scalable=no'>"+
						"<title>title</title>"+
					  "</head>"+
					  "<body style='font-family:Helvetica Neue,Helvetica,Arial,sans-serif;color:#3e4756;padding:"+Config.MARGIN+"px;'>" +
						body + "</body></html>";
			return html;
		}
		
		static public function getReadableDistance(distance:Number):String {
			var km:int = Math.floor(distance);
			if (km > 0) {
				if (km >= 1000)	{
					return Math.floor(km / 1000) + " " + km % 1000 + " " + Lang.kilometers;
				}
				else {
					return km + " " + Lang.kilometers;
				}
			}
			else {
				return Math.floor(distance*1000) + " " + Lang.meters;
			}
		}
		
		static public function scaleBitmapData(bitmapData:BitmapData, scaleValue:Number):ImageBitmapData 
		{
			var scale:Number = Math.abs(scaleValue);
            var width:int = (bitmapData.width * scale) || 1;
            var height:int = (bitmapData.height * scale) || 1;
            var transparent:Boolean = bitmapData.transparent;
            var result:ImageBitmapData = new ImageBitmapData("TextUtils.scaleBitmapData", width, height, transparent);
            var matrix:Matrix = new Matrix();
            matrix.scale(scale, scale);
            result.drawWithQuality(bitmapData, matrix, null, null, null, true, StageQuality.BEST);
            return result;
		}
	}
}