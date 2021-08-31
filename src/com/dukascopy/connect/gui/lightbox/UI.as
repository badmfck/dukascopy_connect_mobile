package com.dukascopy.connect.gui.lightbox {

	import assets.Filter_affiliate;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.shapes.BorderBox;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.TransferType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.telefision.shapes.Box3D;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Alexey
	 */
	public class UI 
	{
		private static var buttonTemplate2:Sprite;
		private static var buttonBox:Box3D;
		private static var textfield2:TextField;
		private static var textFormat2:TextFormat;
		
		private static var buttonTemplate:Sprite;
		private static var box:BorderBox;
				
		private static var textfield:TextField;
		private static var textFormat:TextFormat;
		private static var padding:int = 10;
		
		
		
		private static	var iconTemplateMC:SWFMinifyButton;
		private static var avatarIcon:SWFEmptyAvatar;
		
		private static var reusableMatrix:Matrix = new Matrix();
		private static var reusableRect:Rectangle = new Rectangle();		
		private static var reusableShape:Shape = new Shape();
		private static var tempSprite:Sprite = new Sprite();errorMsg : "chat.22 Access restricted" 

		
		public function UI() { }

		
		public static function getSafeParam(param:String, data:Object):String {
			if (data == null) return "";
			if (data.param == null) return "";
			return data.param;		
		}
		
		public static function tracedObj(obj:Object):String {
			var res:String = "";
			var first:Boolean = true;
			if (obj == null)
				return "null";
			for (var x:String in obj) {
				if (first == false)
					res += "\n";
				first = false;
				res += "		" + (x + ":  " + obj[x]);
			}
			return res;
		}
		
		// init
		private static function createButtonTemplate():void {
			buttonTemplate ||= new Sprite();			
			box ||= new BorderBox(0xffffff, 0x000000, 1, 1, 1,0);
			textfield ||= new TextField();
			textFormat ||= new TextFormat();		
			buttonTemplate.addChild(box);
			buttonTemplate.addChild(textfield);
		}
		
		private static function createNewButtonTemplate():void {
			buttonTemplate2 ||= new Sprite();			
			buttonBox ||= new Box3D(0xffffff, 0x000000, 1, 1, 5,1);
			textfield2 ||= new TextField();
			textFormat2 ||= new TextFormat();		
			buttonTemplate2.addChild(buttonBox);
			buttonTemplate2.addChild(textfield2);
		}
		
		private static function createIconButtonTemplate():void {
			buttonTemplate ||= new Sprite();			
			box ||= new BorderBox(0xffffff, 0x000000, 1, 1, 1,0);
			buttonTemplate.addChild(box);
			if (textfield != null && textfield.parent!=null)  {
				textfield.parent.removeChild(textfield);
			}
		}
		
		//
		// Render Asset Util 
		// 
		public static function renderAsset(instance:DisplayObject, fitWidth:int, fitHeight:int, destroyInstance:Boolean=true, name:String = ""):ImageBitmapData
		{
			if (instance == null) return null;		
			instance.scaleX = instance.scaleY = 1;		
			var scale:Number = getMinScale(instance.width, instance.height, fitWidth, fitHeight);
			instance.scaleX = instance.scaleY = scale;
			//trace(scale);
			var result:ImageBitmapData = getSnapshot(instance, StageQuality.HIGH, name);
			if(destroyInstance)
				destroy(instance);			
			
			return result;			
		}
		
		public static function renderAssetExtended(instance:DisplayObject, fitWidth:int, fitHeight:int, destroyInstance:Boolean=true, name:String = ""):ImageBitmapData
		{
			var result1:ImageBitmapData = getSnapshot(instance, StageQuality.HIGH, name + "_test");
			
			if (instance == null) return null;		
			instance.scaleX = instance.scaleY = 1;		
			var scale:Number = getMinScale(instance.width, instance.height, fitWidth, fitHeight);
			
			if(destroyInstance)
				destroy(instance);
			
			var result:ImageBitmapData = TextUtils.scaleBitmapData(result1, scale);
			
			result1.dispose();
			result1 = null;
			
			return result;			
		}
		
		public static function renderLockButtonRound(fitWidth:int, fitHeight:int, borderSize:int = 0, borderColor:uint = 0xFFFFFF):ImageBitmapData
		{
			var borderRadius:int = fitWidth * .5;			
			var tmp:SWFLockButonBasic = new SWFLockButonBasic();
			tmp.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 99, 192, 43, 0);
			var scale:Number = (fitWidth / 3)/tmp.width;//(fitWidth / tmp.width) * .4;
			
			var gfx:Graphics = tempSprite.graphics;
			gfx.clear();
			gfx.beginFill(borderColor, 1);
			gfx.drawCircle(borderRadius, borderRadius, borderRadius);
			gfx.endFill();
			
			var result:ImageBitmapData = new ImageBitmapData("UI.renderLockButtonRound", fitWidth, fitWidth, true, 0x00FFFF00);
			result.draw(tempSprite);
			var m:Matrix = new Matrix();
			m.scale(scale,scale);
			m.translate((fitWidth-tmp.width*scale)/2,(fitWidth-tmp.width*scale)/2.2);
			result.draw(tmp,m,tmp.transform.concatenatedColorTransform);
			
			gfx.clear();
			tmp = null;
			return result;			
		}
		
		public static function renderLockButton(fitWidth:int, fitHeight:int):BitmapData
		{
			return renderButtonBitmapByClass(Style.icon(Style.ICON_LOCK), fitWidth, fitHeight, Style.color(Style.TOP_BAR_ICON_COLOR));
		}
		
		public static function renderUnlockButton(fitWidth:int, fitHeight:int):BitmapData
		{
			return renderButtonBitmapByClass(Style.icon(Style.ICON_UNLOCK), fitWidth, fitHeight, Style.color(Style.TOP_BAR_ICON_COLOR));
		}
		
		private static function renderButtonBitmapByClass(classForRendering:Class, fitWidth:int, fitHeight:int, color:Number = NaN):BitmapData
		{
			var mc:Sprite = new classForRendering() as Sprite;
			var scale:Number = getMinScale(mc.width, mc.height, fitWidth, fitHeight);
			mc.scaleX = mc.scaleY = scale;
			if (!isNaN(color))
			{
				colorize(mc, color);
			}
			var result:BitmapData = getSnapshot(mc, StageQuality.HIGH, "UI.renderButtonBitmapByClass." + getQualifiedClassName(classForRendering));
			mc = null;
			return result;			
		}
		
	/*	public static function renderSegmentButton(
													text:String = "",
													_width:int = 100, 
													_height:int = 10, 
													first:Boolean = true, 
													last:Boolean = true, 
													radius:int = 20, 
													_bgColor:uint = 0xff0000, 
													_textColor:uint =0xffffff):ImageBitmapData
		{
			var textColor:uint = _textColor;
			var bgColor:uint = _bgColor;		
			
			
			if (_width < 1) _width = 1;
			if (_height < 1) _height = 1;
			
			createButtonTemplate();
			textFormat.font = "Tahoma";
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.italic = false;
			textFormat.bold = false;
			textfield.autoSize = TextFieldAutoSize.NONE;
			textfield.multiline = false;
			textfield.wordWrap = true;
			textfield.border = false;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			textfield.text = text;
			textfield.width = _width;
			textfield.x = 0;
			textfield.height = textfield.textHeight+4;
			textfield.y = (_height * .5 - textfield.height * .5);
			
			var leftRadius:int = first? radius:0;
			var rightRadius:int = last?radius:0;					
			//drawSegmentRoundRect(box.graphics, bgColor, _width, _height, leftRadius, rightRadius);
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderSegmentButton", _width,_height,true,0x000000);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			return newBmd;			
		}*/
		
		public static function renderButton(
											text:String = "", 
											width:int = 100, 
											height:int = 40, 
											textColor:uint = 0x686868, 
											fillColor:uint = 0xffffff, 
											sideColor:uint = 0x686868, 
											borderRadius:int = 0, 
											sideHeight:int = 8):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			createNewButtonTemplate();
			
			textFormat2.font = "Tahoma";
			textFormat2.size = Config.FINGER_SIZE * .28;
			textFormat2.align = TextFormatAlign.CENTER;
			textFormat2.italic = false;
			textFormat2.bold = false;
			textfield2.autoSize = TextFieldAutoSize.NONE;
			textfield2.multiline = false;
			textfield2.wordWrap = true;
			textfield2.border = false;
			textfield2.defaultTextFormat = textFormat2;
			textfield2.textColor = textColor;
			textfield2.text = text;
			textfield2.width = width - padding * 2;
			textfield2.x = padding;
			textfield2.height = textfield2.textHeight+4;
			textfield2.y = ((height - sideHeight) * .5 - textfield2.height * .5);
		
			// set bg params 
			buttonBox.allowRedraw = false;
			buttonBox.width = width;
			buttonBox.height = height;
			buttonBox.color = fillColor;
			buttonBox.sideColor = sideColor;
			buttonBox.sideHeight = sideHeight;
			buttonBox.radius = borderRadius;
			buttonBox.allowRedraw = true;		
		
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderButton", width,height,true,0x000000);
			//newBmd.draw(buttonTemplate);
			newBmd.drawWithQuality(buttonTemplate2,null,null,null,null,false,StageQuality.HIGH);			
			buttonBox.graphics.clear();		
			
			return newBmd;			
		}	
		
		
		
		public static function renderButtonWithIcon(
											text:String = "", 
											fontSize:int = 20,
											width:int = 100, 
											height:int = 40, 
											textColor:uint = 0x686868, 
											fillColor:uint = 0xffffff, 
											sideColor:uint = 0x686868, 
											borderRadius:int = 0, 
											sideHeight:int = 8,
											icon:DisplayObject = null, 
											bootomOffset:int = 0, 
											horizontalPadding:int = 0, // only for autosized btn
											autoSize:Boolean = false):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			createNewButtonTemplate();
			
			textFormat2.font = "Tahoma";
			textFormat2.size = fontSize;// Config.FINGER_SIZE * .28;
			textFormat2.align = TextFormatAlign.LEFT;
			textFormat2.italic = false;
			textFormat2.bold = false;
			textfield2.autoSize = TextFieldAutoSize.LEFT;
			textfield2.multiline = false;
			textfield2.wordWrap = false;
			textfield2.border = false;
			textfield2.defaultTextFormat = textFormat2;
			textfield2.textColor = textColor;
			textfield2.text = text;
			textfield2.width = width - padding * 2;
			textfield2.x = padding;
			textfield2.height = textfield2.textHeight+4;
			textfield2.y = ((height - sideHeight) * .5 - textfield2.height * .5);
		
			
			
		
			var autosizeWidth:int = width;
			if (icon != null){			
				icon.y = (height - sideHeight)*.5 - icon.height*.5;
				buttonBox.addChild(icon);	
				
				if (autoSize){				
					icon.x = horizontalPadding;
					textfield2.x = icon.x + icon.width + padding;
					autosizeWidth = textfield2.x + textfield2.width + horizontalPadding;
				}else{
					textfield2.x = width * .5 - textfield2.width * .5+ icon.width*.5 + padding;
					icon.x = textfield2.x - icon.width - padding;
				}
				
			
			}else{
				textfield2.x = width*.5 - textfield2.width * .5;
			}
				
			// set bg params 
			buttonBox.allowRedraw = false;
			buttonBox.width = autoSize?autosizeWidth:width;
			buttonBox.height = height+bootomOffset;
			buttonBox.color = fillColor;
			buttonBox.sideColor = sideColor;
			buttonBox.sideHeight = sideHeight;
			buttonBox.radius = borderRadius;
			buttonBox.allowRedraw = true;				
			
			var newBmd:ImageBitmapData;
			if (autoSize){				
				newBmd =  new ImageBitmapData("UI.renderButton", autosizeWidth, height + bootomOffset, true, 0x000000);				
			}else{
				newBmd =  new ImageBitmapData("UI.renderButton", width, height + bootomOffset, true, 0x000000);
			}
		
			newBmd.drawWithQuality(buttonTemplate2,null,null,null,null,false,StageQuality.HIGH);
			buttonBox.graphics.clear();
			
			if (icon != null && icon.parent != null) {
				icon.parent.removeChild(icon);
			}
			return newBmd;
		}
		
		public static function renderButtonOld(
												text:String = "", 
												width:int = 100, 
												height:int = 40, 
												textColor:uint = 0x686868, 
												fillColor:uint = 0xffffff, 
												borderColor:uint = 0x686868, 
												borderRadius:int = 0):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			createButtonTemplate();
			textFormat.font = "Tahoma";
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.italic = false;
			textFormat.bold = false;
			textfield.autoSize = TextFieldAutoSize.NONE;
			textfield.multiline = false;
			textfield.wordWrap = true;
			textfield.border = false;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			textfield.text = text;
			textfield.width = width - padding * 2;
			textfield.x = padding;
			textfield.height = textfield.textHeight+4;
			textfield.y = (height * .5 - textfield.height * .5);
		
			box.width = width ;
			box.height = height;
			box.color = fillColor;
			box.borderColor = borderColor;
			box.thickness = 1;
			box.radius = borderRadius;
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderButtonOld", width, height, true, 0x000000);
			//newBmd.draw(buttonTemplate);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			return newBmd;			
		}
				
		
		
		public static function renderDropdownButton(
													text:String = "", 
													width:int = 100, 
													height:int = 40, 
													textColor:uint = 0x686868, 
													fillColor:uint = 0xffffff, 
													borderColor:uint = 0x686868, 
													borderRadius:int = 0, 
													triangleColor:uint = 0x000000):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			createButtonTemplate();
			var PADDING:int = Config.FINGER_SIZE_DOT_25;
			textFormat.font = "Tahoma";
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.italic = false;
			textFormat.bold = false;
			textfield.autoSize = TextFieldAutoSize.NONE;
			textfield.multiline = false;
			textfield.wordWrap = true;
			textfield.border = false;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			textfield.text = text;
			textfield.width = width - PADDING * 2;
			textfield.x =  PADDING;
			textfield.height = textfield.textHeight+4;
			textfield.y = (height * .5 - textfield.height * .5);
		
			box.width = width ;
			box.height = height;
			box.color = fillColor;
			box.borderColor = borderColor;
			box.thickness = 1;
			box.radius = borderRadius;
			
			
			if (reusableShape == null)
				reusableShape = new Shape();
				
			reusableShape.scaleX  = reusableShape.scaleY = 1;
				
			
			var arrowHeight:Number = height * 0.15;
			var arrowCathetus:Number  = height * 0.12;	

			var gfx:Graphics = reusableShape.graphics;
			gfx.clear();			
			gfx.beginFill(triangleColor, 1);
			gfx.moveTo(0, 0);
			gfx.lineTo(arrowCathetus, arrowHeight);
			gfx.lineTo(arrowCathetus*2, 0);
			gfx.lineTo(0, 0);
			gfx.endFill();
			
			reusableShape.x = width - arrowCathetus*2 - PADDING;
			reusableShape.y = (height - reusableShape.height) * .5;			
			buttonTemplate.addChild(reusableShape);
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderDropdownButton", width,height,true,0x000000);
			//newBmd.draw(buttonTemplate);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);		
			if (reusableShape.parent) {
				reusableShape.parent.removeChild(reusableShape);	
			}
			reusableShape.graphics.clear();
			box.graphics.clear();
			return newBmd;			
		}	
		
		
		public static function renderDialogButton(
													text:String = "", 
													width:int = 100, 
													height:int = 40, 
													textColor:uint = 0x686868, 
													fillColor:uint = 0xffffff, 
													borderColor:uint = 0x686868, 
													TLRadius:int = 0, 
													TRRadius:int = 0, 
													BRRadius:int = 0, 
													BLRadius:int = 0):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			createButtonTemplate();
			textFormat.font = "Tahoma";
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.italic = false;
			textfield.autoSize = TextFieldAutoSize.NONE;
			textfield.multiline = false;
			textfield.wordWrap = true;
			textfield.border = false;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			textfield.text = text;
			textfield.width = width - padding * 2;
			textfield.x = padding;
			textfield.height = textfield.textHeight+4;
			textfield.y = (height * .5 - textfield.height * .5);
			
			
			drawRoundRect(box.graphics, fillColor, width, height, TLRadius, TRRadius, BLRadius, BRRadius, 1, borderColor, 1);
			//box.width = width ;
			//box.height = height;
			//box.color = fillColor;
			//box.borderColor = borderColor;
			//box.thickness = 1;
			//box.radius = borderRadius;
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderDialogButton", width,height,true,0x000000);
			//newBmd.draw(buttonTemplate);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			return newBmd;			
		}
		
		
		
																				//multiline:Boolean = true, align:String =  TextFormatAlign.CENTER, autoSize:String = TextFieldAutoSize.LEFT, fontSize:int = 26, wordWrap:Boolean = false, textColor:uint = 0x686868, backgroundColor:uint = 0xffffff, isTransparent:Boolean=false ):BitmapData {
		public static function renderTextPlane(
												text:String = "", 
												width:int = 100, 
												height:int = 40, 
												__isMultiline:Boolean = true, 
												__textFormatAlign:String =  TextFormatAlign.CENTER, 
												__textFieldAutoSize:String = TextFieldAutoSize.LEFT, 
												__fontSize:int = 26, 
												__wordWrap:Boolean = false, 
												textColor:uint = 0x686868, 
												fillColor:uint = 0xffffff, 
												borderColor:uint = 0x686868, 
												borderRadius:int = 0, 
												borderThickness:int = 0,
												__paddingH:int = 10, 
												__paddingV:int = 10, 
												__icon:DisplayObject = null, _isIconCenter:Boolean = false, _isHtml:Boolean = false, _rightOffset:int = 0, isTransparent:Boolean = false):ImageBitmapData {
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			
			//var __fontSize:Number = Config.FINGER_SIZE * .28;
			var __leading:Number = 0;
			//var __textFormatAlign:String = TextFormatAlign.CENTER;
			//var __textFieldAutoSize:String = TextFieldAutoSize.LEFT;
			var __isItalic:Boolean = false;
			var __isBold:Boolean = false;
			var __textBorder:Boolean = false;
			var iconWidth:int = __icon != null? __icon.width+__paddingH*2:0;
		
			createButtonTemplate();
			textFormat.font = "Tahoma";
			textFormat.size = __fontSize;
			textFormat.leading = __leading;
			textFormat.align = __textFormatAlign;
			textFormat.italic = __isItalic;
			textFormat.bold = __isBold;
			textfield.autoSize =__textFieldAutoSize;
			textfield.multiline = __isMultiline;
			textfield.wordWrap = __wordWrap;
			textfield.border = __textBorder;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			if(_isHtml)
				textfield.htmlText = text;
			else	
				textfield.text = text;
			if (width == 1 && _isIconCenter){
				width = textfield.textWidth + 4 + iconWidth + __paddingH* 2+_rightOffset;
			}
			textfield.width = width - __paddingH * 2-iconWidth-_rightOffset;
			textfield.x = __paddingH+iconWidth;
			textfield.height = textfield.textHeight + 4;
			
			textfield.y = __paddingV;// (height * .5 - textfield.height * .5);
		
			if (__textFieldAutoSize != TextFieldAutoSize.NONE && height == 8) {
				height = textfield.height + __paddingV * 2;
			}
			else
			{
				textfield.y = int(height * .5 - textfield.height * .5);
			}
			if (_isIconCenter){
				height = textfield.height;
				textfield.y = 0;
			}
			if (isTransparent) {
				box.graphics.clear();
			} else {
				box.width = width;
				box.height = height;
				box.color = fillColor;
				box.borderColor = borderColor;
				box.thickness = borderThickness;
				box.radius = borderRadius;
			}
			if (__icon != null) {
				box.addChild(__icon);
				
				if (_isIconCenter) {
					var paddingIcon:int = (height -__icon.height) * .5
					__icon.y = paddingIcon;
					__icon.x = __paddingH;
				}
			}
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderTextPlane", width, height, true, 0x000000);
			//newBmd.draw(buttonTemplate);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			if (__icon != null && __icon.parent!=null) {
				__icon.parent.removeChild(__icon);
			}
			
			return newBmd;			
		}		
				
		
		public static function renderTextPlane2(
												text:String = "", 
												width:int = 100, 
												height:int = 40, 
												__isMultiline:Boolean = true, 
												__textFormatAlign:String =  TextFormatAlign.CENTER, 
												__textFieldAutoSize:String = TextFieldAutoSize.LEFT, 
												__fontSize:int = 26, 
												__wordWrap:Boolean = false, 
												textColor:uint = 0x686868, 
												fillColor:uint = 0xffffff, 
												borderColor:uint = 0x686868, 
												borderRadius:int = 0, 
												borderThickness:int = 0,
												__paddingL:int = 10, 
												__paddingR:int = 10, 
												__paddingV:int = 10, 
												_isHtml:Boolean = false, 
												_rightOffset:int = 0, 
												isTransparent:Boolean = false,
												_alignVertical:Boolean  = true):ImageBitmapData {
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			
			var __leading:Number = 0;
			var __isItalic:Boolean = false;
			var __isBold:Boolean = false;
			var __textBorder:Boolean = false;
		
			createButtonTemplate();
			
			textFormat.font = "Tahoma";
			textFormat.size = __fontSize;
			textFormat.leading = __leading;
			textFormat.align = __textFormatAlign;
			textFormat.italic = __isItalic;
			textFormat.bold = __isBold;
			textfield.autoSize =__textFieldAutoSize;
			textfield.multiline = __isMultiline;
			textfield.wordWrap = __wordWrap;
			textfield.border = __textBorder;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			
			
			if(_isHtml){
				textfield.htmlText = text;
			}else{	
				textfield.text = text;
			}	
	
			
			textfield.width = width - __paddingL-__paddingR -_rightOffset;
			textfield.x = __paddingL;
			textfield.height = textfield.textHeight + 4;
			
			if(_alignVertical==true){
				textfield.y = (height - textfield.height)*.5;
			}else{
				textfield.y = __paddingV;			
			}
				
		

			if (isTransparent) {
				box.graphics.clear();
			} else {
				box.width = width;
				box.height = height;
				box.color = fillColor;
				box.borderColor = borderColor;
				box.thickness = borderThickness;
				box.radius = borderRadius;
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderTextPlane", width, height, false, 0x000000);
			//newBmd.draw(buttonTemplate);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();	
			return newBmd;			
		}
		
		
		public static function renderSettingsText(
													text:String = "", 
													width:int = 100, 
													height:int = 40, 
													__isMultiline:Boolean = true, 
													__textFormatAlign:String = TextFormatAlign.CENTER, 
													__textFieldAutoSize:String = TextFieldAutoSize.LEFT, 
													__fontSize:int = 26, 
													__wordWrap:Boolean = false, 
													textColor:uint = 0x686868, 
													__paddingH:int = 10, 
													__paddingV:int = 10,
													__icon:DisplayObject = null,
													customName:String = ""):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			
			//var __fontSize:Number = Config.FINGER_SIZE * .28;
			var __leading:Number = 0;
			var __isItalic:Boolean = false;
			var __isBold:Boolean = false;
			var __textBorder:Boolean = false;
			var iconWidth:int = __icon != null? __icon.width + __paddingH:0;
			if (iconWidth > 0 && iconWidth < Config.FINGER_SIZE_DOT_5)
				iconWidth = Config.FINGER_SIZE_DOT_5;
			createButtonTemplate();
			
			textFormat.font = "Tahoma";
			textFormat.size = __fontSize;
			textFormat.leading = __leading;
			textFormat.align = __textFormatAlign;
			textFormat.italic = __isItalic;
			textFormat.bold = __isBold;
			textfield.autoSize =__textFieldAutoSize;
			textfield.multiline = __isMultiline;
			textfield.wordWrap = __wordWrap;
			textfield.border = __textBorder;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			textfield.text = text;
			textfield.width = width - __paddingH-iconWidth;
			//textfield.x = Config.FINGER_SIZE * .6;// __paddingH + iconWidth;
			textfield.height = textfield.textHeight + 4;
			
			var minimalLeft:Number =  __paddingH + iconWidth< Config.FINGER_SIZE * .6?Config.FINGER_SIZE*.6: __paddingH + iconWidth;
			var textX:int = __icon == null?__paddingH: minimalLeft;
			textfield.x = textX;
			textfield.y = __paddingV;// (height * .5 - textfield.height * .5);
		
			if (__textFieldAutoSize != TextFieldAutoSize.NONE) {
				height = textfield.height + __paddingV * 2;
			}
			
			box.graphics.clear();				
			if (__icon != null) {
				box.addChild(__icon);	
				__icon.y = (height - __icon.height) * .5;
			}
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderSettingsText." + customName, width, height, true, 0x000000);
			newBmd.drawWithQuality(buttonTemplate, null, null, null, null, false, StageQuality.HIGH);
				
			if (__icon != null && __icon.parent!=null) {
				__icon.parent.removeChild(__icon);
			}			
			return newBmd;			
		}
		
		public static function renderSettingsButtonCustomPositions(
																width:int = 100, 
																height:int = 40, 
																title:TextFieldSettings = null,
																subtitle:TextFieldSettings = null,
																rightText:TextFieldSettings = null,
																iconPosition:int = 10, 
																textPosition:int = 30,
																iconLeft:DisplayObject = null,
																iconRight:DisplayObject = null ):ImageBitmapData {
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			
			textfield ||= new TextField();
			textFormat ||= new TextFormat();
			
			var mainTextfieldWidth:int = width;
			
			var __leading:Number = 0;
			var __isItalic:Boolean = false;
			var __isBold:Boolean = false;
			var __textBorder:Boolean = false;
			
			var titleFontSize:Number = (title == null)?0:title.size;
			var subtitleFontSize:Number = (subtitle == null)?0:subtitle.size;
			
			var maxTextSize:int = Math.max(titleFontSize, subtitleFontSize);
			var drawPositon:int = width;
			
			var matrix:Matrix = new Matrix();
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderSettingsButtonCustomPositions", width, height, true, 0x000000);
			
			if (iconRight)
			{
				drawPositon -= iconRight.width;
				
				
				matrix = iconRight.transform.matrix;
				matrix.tx = drawPositon;
				matrix.ty = int(height*.5 - iconRight.height*.5);
				
				newBmd.drawWithQuality(iconRight, matrix, iconRight.transform.colorTransform, null, null, false, StageQuality.HIGH);
				drawPositon -= Config.MARGIN;
				mainTextfieldWidth -= iconRight.width + Config.MARGIN;
			}
			if (rightText)
			{
				textFormat.font = "Tahoma";
				textFormat.size = rightText.size;
				textFormat.leading = __leading;
				textFormat.align = rightText.align;
				textFormat.italic = __isItalic;
				textFormat.bold = __isBold;
				textfield.autoSize = TextFieldAutoSize.NONE;
				textfield.multiline = false;
				textfield.wordWrap = false;
				textfield.border = __textBorder;
				textfield.defaultTextFormat = textFormat;
				textfield.textColor = rightText.color;
				textfield.text = rightText.text;
				textfield.width = textfield.textWidth + 4;
				textfield.height = textfield.textHeight + 4;
				
				drawPositon -= textfield.width;
				
				
				matrix = new Matrix();
				matrix.tx = drawPositon;
				matrix.ty = int(height*.5 - textfield.height*.5) - 1;
				
				newBmd.drawWithQuality(textfield, matrix, null, null, null, false, StageQuality.HIGH);
				drawPositon -= Config.MARGIN;
				
				mainTextfieldWidth -= textfield.width + Config.MARGIN;
			}
			
			mainTextfieldWidth -= textPosition;
			
			if (!title)
			{
				//!TODO;
			}
			
			drawPositon = textPosition;
			
		//	var textLineMetricsTitle:TextLineMetrics = new TextLineMetrics(0, 100, 100, 10, 10, 10);
			
			var titleBD:BitmapData = TextUtils.createTextFieldData(
															title.text, 
															mainTextfieldWidth, 
															1, 
															false, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, 
															title.size, 
															false, 
															title.color, 
															MainColors.WHITE, 
															true, 
															false, 
															true, 
															"Tahoma");
			
			var subtitleBD:BitmapData;
			if (subtitle)
			{
				subtitleBD = TextUtils.createTextFieldData(
															subtitle.text, 
															mainTextfieldWidth, 
															1, 
															false, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, 
															subtitle.size, 
															false, 
															subtitle.color, 
															MainColors.WHITE, 
															true, 
															false, 
															true, 
															"Tahoma");
			}
			
			var titleBottomPadding:int = Config.FINGER_SIZE*.06;
			var titleXPos:int = drawPositon;
			var titleYPos:int;
			if (subtitleBD)
			{
				titleYPos = height * .5 - (titleFontSize/1.27 + subtitleBD.height + titleBottomPadding) * .5;
			}
			else
			{
				titleYPos = int(height * .5 - (titleFontSize/1.27) * .5);
			}
			
			newBmd.copyPixels(titleBD, titleBD.rect, new Point(titleXPos, titleYPos));
			if (subtitleBD)
			{
				newBmd.copyPixels(subtitleBD, subtitleBD.rect, new Point(titleXPos, titleYPos + titleBD.height + titleBottomPadding));
			}
			
		//	newBmd.drawWithQuality(textfield, matrix, null, null, null, false, StageQuality.HIGH);
			
			if (iconLeft)
			{
				drawPositon = iconPosition - iconLeft.width*.5;
				
				
				matrix = iconLeft.transform.matrix;
				matrix.tx = drawPositon;
				matrix.ty = int(height*.5 - iconLeft.height*.5);
				
				newBmd.drawWithQuality(iconLeft, matrix, iconLeft.transform.colorTransform, null, null, false, StageQuality.HIGH);
			}
			titleBD.dispose();
			if (subtitleBD)
			{
				subtitleBD.dispose();
			}
			titleBD = null;
			subtitleBD = null;
			return newBmd;			
		}
		
		public static function renderSettingsTextAdvanced(
															text:String = "", 
															width:int = 100, 
															height:int = 40, 
															__isMultiline:Boolean = true, 
															__textFormatAlign:String =  TextFormatAlign.CENTER, 
															__textFieldAutoSize:String = TextFieldAutoSize.LEFT, 
															__fontSize:int = 26,
															__wordWrap:Boolean = false, 
															textColor:uint = 0x686868, 
															__paddingH:int = 10, 
															__paddingV:int = 10, 
															__icon:DisplayObject = null, 
															__icon2:DisplayObject = null):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			
			//var __fontSize:Number = Config.FINGER_SIZE * .28;
			var __leading:Number = 0;
			var __isItalic:Boolean = false;
			var __isBold:Boolean = false;
			var __textBorder:Boolean = false;
			
			
			var iconWidth:int = __icon != null? __icon.width + __paddingH:0;
			var iconWidth2:int = __icon2 != null? __icon2.width + __paddingH:0;
			var MIN_ICON_WIDTH:int = Config.FINGER_SIZE * .8;
			
			if (iconWidth > 0 && iconWidth < MIN_ICON_WIDTH)
				iconWidth = MIN_ICON_WIDTH;
				
			if (iconWidth2 > 0 && iconWidth2 < MIN_ICON_WIDTH)
				iconWidth2 = MIN_ICON_WIDTH;
				
			var minimalRight:Number =  __paddingH + iconWidth2 < MIN_ICON_WIDTH?MIN_ICON_WIDTH: __paddingH + iconWidth2;
			var textRight:int = __icon2 == null?__paddingH: minimalRight;
			
			createButtonTemplate();
			
			textFormat.font = "Tahoma";
			textFormat.size = __fontSize;
			textFormat.leading = __leading;
			textFormat.align = __textFormatAlign;
			textFormat.italic = __isItalic;
			textFormat.bold = __isBold;
			textfield.autoSize =__textFieldAutoSize;
			textfield.multiline = __isMultiline;
			textfield.wordWrap = __wordWrap;
			textfield.border = __textBorder;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = textColor;
			if (text == null)
				textfield.text = "";
			else
				textfield.text = text;
			
			textfield.width = width - __paddingH - iconWidth - textRight;
			//textfield.x = Config.FINGER_SIZE * .6;// __paddingH + iconWidth;
			textfield.height = textfield.textHeight + 4;
			
			var textX:int = __icon == null?Config.DOUBLE_MARGIN: int(Config.FINGER_SIZE * .8);
			textfield.x = textX;
			//textfield.y = __paddingV;// (height * .5 - textfield.height * .5);
			textfield.y =  int(height * .5 - textfield.height * .5);
		
			if (__textFieldAutoSize != TextFieldAutoSize.NONE) {
				height = textfield.height + __paddingV * 2;
			}
			
			box.graphics.clear();				
			if (__icon != null) {
				box.addChild(__icon);	
				__icon.y = (height - __icon.height) * .5;
				__icon.x = Config.DOUBLE_MARGIN;
			}
			
			if (__icon2 != null) {
				box.addChild(__icon2);	
				__icon2.y = (height - __icon2.height) * .5;
				__icon2.x = width - __icon2.width - Config.DOUBLE_MARGIN;
			}
			
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderSettingsTextAdvanced", width, height, true, 0x000000);
			newBmd.drawWithQuality(buttonTemplate, null, null, null, null, false, StageQuality.HIGH);
				
			if (__icon != null && __icon.parent!=null) {
				__icon.parent.removeChild(__icon);
			}	
			if (__icon2 != null && __icon2.parent!=null) {
				__icon2.parent.removeChild(__icon2);
			}			
			return newBmd;			
		}
		
		public static function drawSegmentRoundRect(gfx:Graphics,bgColor:uint, width:int ,height:int, leftRadius:int, rightRadius:int, opacity:Number=1):void {
				
			gfx.clear();
			gfx.beginFill(bgColor, opacity);
			gfx.moveTo( 0,leftRadius );
			gfx.curveTo( 0, 0, leftRadius, 0 );
			gfx.lineTo(width - rightRadius, 0);
			gfx.curveTo( width, 0, width, rightRadius );
			gfx.lineTo(width, height - rightRadius);
			gfx.curveTo( width, height,width - rightRadius, height );
			gfx.lineTo(leftRadius, height);
			gfx.curveTo( 0,height, 0, height - leftRadius );
			gfx.endFill();
			
		}
		
		public static function drawRoundRect(gfx:Graphics,bgColor:uint, width:int ,height:int, tl:int, tr:int, bl:int, br:int, thick:int =0, borderColor:uint = 0x000000, opacity:Number=1):Graphics {
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			var rect:Graphics = gfx;
			
			gfx.clear();
			//gfx.beginFill(borderColor, 1);
			
			if (thick != 0) gfx.lineStyle(thick, borderColor);
			//if(thick!=0){
				gfx.beginFill(bgColor, opacity);
				// Border
				gfx.moveTo( 0, tl );
				gfx.curveTo( 0, 0, tl, 0 );
				gfx.lineTo(width - tr, 0);
				gfx.curveTo( width, 0, width, tr );
				gfx.lineTo(width, height - br);
				gfx.curveTo( width, height, width - br, height );
				gfx.lineTo(bl, height);
				gfx.curveTo( 0, height, 0, height - bl );
				
				// fill
				//gfx.beginFill(bgColor, 1);			
				//gfx.moveTo( thick, tl+thick );
				//gfx.curveTo( thick, thick, tl+thick, thick );
				//gfx.lineTo(width - tr-thick*2, thick);
				//gfx.curveTo( width-thick*2, thick, width-thick*2, tr-thick*2 );
				//gfx.lineTo(width-thick*2, height - br-thick*2);
				//gfx.curveTo( width-thick*2, height-thick*2, width - br-thick*2, height-thick*2);
				//gfx.lineTo(bl+thick, height-thick*2);
				//gfx.curveTo( thick, height-thick*2, thick, height - bl-thick*2 );
				//
			
			//}
			gfx.endFill();
			return gfx;
		}


		static private var checkBoxTemplate:Shape=null;
		static public function renderCheckBox(
												check:Boolean = false, 
												size:int = -1, 
												borderSize:int = 2,
												backgroundColor:uint = 0xEBEBEB, 
												borderColor:uint = 0x333333,
												borderAlpha:Number = .3, 
												birdColor:uint = 0xd23a2c):ImageBitmapData
		{
			if (size == -1)
				size = Config.FINGER_SIZE * .6;
				
			if (checkBoxTemplate == null)
				checkBoxTemplate = new Shape();
			checkBoxTemplate.graphics.clear();
			
			var sx:int = 0;
			if (borderSize > 0) {
				checkBoxTemplate.graphics.beginFill(borderColor,borderAlpha);
				checkBoxTemplate.graphics.drawRect(0, 0, size, size);
				checkBoxTemplate.graphics.endFill();
			}
			
			checkBoxTemplate.graphics.beginFill(backgroundColor);
			checkBoxTemplate.graphics.drawRect(borderSize, borderSize, size-borderSize*2, size-borderSize*2);
			checkBoxTemplate.graphics.endFill();
			
			
			if (check == true) {
				var birdSize:int=size*.5;
				checkBoxTemplate.graphics.beginFill(birdColor);
				var x:int = (size-birdSize) * .5;
				var y:int = x;
				checkBoxTemplate.graphics.drawRect(x, y, birdSize, birdSize);
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderCheckBox", size, size, true, 0);
			newBmd.drawWithQuality(checkBoxTemplate, null, null, null, null, false, StageQuality.HIGH);
			checkBoxTemplate.graphics.clear();
			return newBmd;
			
		}
		
		public static function renderIconButton(
												icon:DisplayObject = null, 
												width:int = 100, 
												height:int = 100 , 
												fillColor:uint = 0xffffff, 
												borderColor:uint = 0x686868, 
												borderRadius:int = 0):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			createIconButtonTemplate();
			
			box.width = width ;
			box.height = height; 
			box.color = fillColor;
			box.borderColor = borderColor;
			box.thickness = 1;
			box.radius = borderRadius;
			
			if(icon){
				buttonTemplate.addChild(icon);
				icon.x = width * .5  - icon.width * .5;
				icon.y = height * .5  - icon.height * .5;
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderIconButton", width, height, true);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			if(icon){
				buttonTemplate.removeChild(icon);
			}
			return newBmd;
		}
		
		// render ui bar 
		//public static function renderProfileMenuItem(text, left icon, right icon
		
		public static function renderText(
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
			customName:String = "",
			italic:Boolean = false,
			truncate:Boolean = false):ImageBitmapData {
				if (text == null)
					return null;
				
				if (width < 1) width = 1;
				if (height < 1) height = 1;
				
				textfield ||= new TextField();
				textFormat ||= new TextFormat();
				textFormat.font = "Tahoma";
				textFormat.size = fontSize;
				textFormat.align = align;
				textFormat.italic = italic;
				textfield.autoSize = autoSize;
				textfield.multiline = multiline;
				textfield.wordWrap = wordWrap;
				textFormat.color =  textColor;
				textFormat.bold = false;
				textfield.textColor = textColor;
				textfield.border = false;
				textfield.defaultTextFormat = textFormat;
				textfield.width = width;
				textfield.text = text;
				if (italic == true)
					textfield.appendText(" ");
				textfield.x = 0;
				textfield.y = 0;
				if (autoSize == TextFieldAutoSize.NONE) {
					textfield.height = height;
					if (truncate == true)
						TextUtils.truncate(textfield);
				} else {
					textfield.height = textfield.textHeight + 4;
				}
				if (autoSize == TextFieldAutoSize.LEFT && multiline == false && textfield.width < width) {
					width = textfield.width;
				}
				
				var newBmd:ImageBitmapData = new ImageBitmapData("UI.renderText" + "." + customName, width, textfield.height, isTransparent, backgroundColor);
				newBmd.draw(textfield,textfield.transform.matrix);
				return newBmd;
		}
		
		public static function renderTextByHeightWithMinMaxFontSize(
											text:String = "",
											width:int = 100,
											height:int = 10,
											multiline:Boolean = true,
											align:String =  TextFormatAlign.CENTER,
											autoSize:String = TextFieldAutoSize.LEFT,
											minfontSize:int = 26,
											maxfontSize:int = 26,
											wordWrap:Boolean = false,
											textColor:uint = 0x686868,
											backgroundColor:uint = 0xffffff,
											isTransparent:Boolean = false,
											customName:String = ""):ImageBitmapData {
			if (text == null)
				return null;
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			textfield ||= new TextField();
				textfield.autoSize = autoSize;
				textfield.multiline = multiline;
				textfield.wordWrap = wordWrap;
				textfield.textColor = textColor;
				textfield.border = false;
				textfield.width = width;
				textfield.text = text;
				textfield.x = 0;
				textfield.y = 0;
				textFormat ||= new TextFormat();
					textFormat.font = Config.defaultFontName;
					textFormat.align = align;
					textFormat.italic = false;
			if (autoSize == TextFieldAutoSize.NONE) {
				textfield.height = height;
			} else {
				textfield.height = textfield.textHeight + 4;
				if (autoSize == TextFieldAutoSize.LEFT && multiline == false && textfield.width < width)
					width = textfield.width;
			}
			var textHeightIsSmaller:Boolean = false;
			while (maxfontSize >= minfontSize) {
				textFormat.size = maxfontSize;
				textfield.setTextFormat(textFormat);
				textfield.height = textfield.textHeight + 4;
				if (textfield.height <= height) {
					textHeightIsSmaller = true;
					break;
				}
				maxfontSize--;
			}
			var newBmd:ImageBitmapData = new ImageBitmapData("UI.renderText" + "." + customName, width, (textHeightIsSmaller) ? textfield.height : height, isTransparent, backgroundColor);
			newBmd.draw(textfield, textfield.transform.matrix);
			return newBmd;
		}
		
		public static function getTextField():TextField {
			textfield ||= new TextField();
			return textfield;
		}

		public static function renderTextShadowedUnderline(text:String = "", width:int = 100, height:int = 10, multiline:Boolean = true, bold:Boolean = false, align:String =  TextFormatAlign.CENTER, autoSize:String = TextFieldAutoSize.LEFT, fontSize:int = 26, wordWrap:Boolean = false, textColor:uint = 0x686868, backgroundColor:uint = 0xffffff,shadowColor:uint = 0x000000, isTransparent:Boolean=false , shadowYOffset:int =2 , isItalic:Boolean  = false, lineColor:uint = 0x3e4756/*AppTheme.GREY_DARK*/, solid:uint = 1, ispass:Boolean = false):BitmapData {
			
			buttonTemplate = new Sprite();
			/*var newBmd:BitmapData =	UI.renderTextShadowed(text, width, height, multiline, bold, align, autoSize, fontSize, wordWrap, textColor, backgroundColor,shadowColor, isTransparent , shadowYOffset, isItalic);
			buttonTemplate.addChild(new Bitmap(newBmd));
			buttonTemplate.graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
			buttonTemplate.graphics.drawRect(0, height-5, width, height);
			buttonTemplate.graphics.endFill();
			
			newBmd.draw(buttonTemplate);
			return newBmd;	*/
			var isW:Boolean;
			if (width < 1) width = 1;
			if (height < 1) height = 1;

			isW = (width != 1);

			textfield ||= new TextField();
			textFormat ||= new TextFormat();		
			textFormat.font = "Tahoma";
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.bold = bold;
			textFormat.italic = isItalic;
			textFormat.leading = 0;
			textFormat.color = textColor;
			
			textfield.autoSize = autoSize;
			textfield.multiline = multiline;
			textfield.wordWrap = wordWrap;
			textfield.textColor = textColor;
			textfield.border = false;

			textfield.defaultTextFormat = textFormat;
			if(ispass){
//				textfield.multiline = true;
				textfield.wordWrap = true;

				textfield.displayAsPassword=true;
			}
			textfield.text = text;

			textfield.x = 0;
			textfield.y = 0;

			//textfield.width = textfield.textWidth+4;
			if(autoSize != TextFieldAutoSize.LEFT || ispass){
				textfield.width = width;
			}
			if(autoSize == TextFieldAutoSize.NONE){
				textfield.width = width;
				textfield.height = height;
			}else {
				textfield.height = textfield.textHeight;
			}
			
			if (height == -1) {
				textfield.height = 5;
				textfield.autoSize = autoSize;
			}
			textfield.x = 0; //(width > textfield.width)? (width - textfield.width)*.5 : ( textfield.width- width)*.5;

			var newBmd:BitmapData = new BitmapData(isW? width:textfield.width,textfield.height+solid,isTransparent,backgroundColor);

			newBmd.draw(textfield,textfield.transform.matrix);
			newBmd.scroll(0, shadowYOffset);
			
			textFormat.color = shadowColor;;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = shadowColor;

			buttonTemplate.addChild(textfield);
			buttonTemplate.graphics.beginFill(lineColor);
			buttonTemplate.graphics.drawRect(0, textfield.y+textfield.height,isW? width:textfield.width, textfield.y + textfield.height + solid);
			buttonTemplate.graphics.endFill();
			newBmd.draw(buttonTemplate);
			buttonTemplate.graphics.clear();
			textfield.autoSize = TextFieldAutoSize.LEFT;

			textfield.displayAsPassword = false;
			return newBmd;			
		}

		public static function renderTextShadowed(
													text:String = "", 
													width:int = 100, 
													height:int = 10, 
													multiline:Boolean = true, 
													bold:Boolean = false, 
													align:String =  TextFormatAlign.CENTER,
													autoSize:String = TextFieldAutoSize.LEFT, 
													fontSize:int = 26, 
													wordWrap:Boolean = false, 
													textColor:uint = 0x686868, 
													backgroundColor:uint = 0xffffff,
													shadowColor:uint = 0x000000, 
													isTransparent:Boolean = false , 
													shadowYOffset:int = 2, 
													isItalic:Boolean  = false):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			textfield ||= new TextField();
			textFormat ||= new TextFormat();		
			textFormat.font = "Tahoma";
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.bold = bold;
			textFormat.italic = isItalic;
			textFormat.leading = 0;
			textFormat.color = textColor;
			
			textfield.autoSize = autoSize;
			textfield.multiline = multiline;
			textfield.wordWrap = wordWrap;
			textfield.textColor = textColor;
			textfield.border = false;		
			textfield.defaultTextFormat = textFormat;
			textfield.text = text;
			textfield.x = 0;
			textfield.y = 0;
			
			
			//textfield.width = textfield.textWidth+4;
			if(autoSize != TextFieldAutoSize.LEFT){
				textfield.width = width;
			}
			if(autoSize == TextFieldAutoSize.NONE){
				textfield.width = width;
				textfield.height = height;
			}else {
				textfield.height = textfield.textHeight;
			}
			
			if (height == -1) {
				textfield.height = 5;
				textfield.autoSize = autoSize;
			}
			
			var newBmd:ImageBitmapData = new ImageBitmapData("UI.renderTextShadowed", textfield.width,textfield.height,isTransparent,backgroundColor);
			newBmd.draw(textfield,textfield.transform.matrix);
			newBmd.scroll(0, shadowYOffset);
			
			textFormat.color = shadowColor;
			textfield.defaultTextFormat = textFormat;
	
			textfield.textColor = shadowColor; 			
			newBmd.draw(textfield,textfield.transform.matrix);
			
			textfield.autoSize = TextFieldAutoSize.LEFT;
			
			return newBmd;			
		}	
		
		public static function renderHtmlTextShadowed(
														text:String = "", 
														width:int = 100, 
														height:int = 10, 
														multiline:Boolean = true, 
														bold:Boolean = false, 
														align:String =  TextFormatAlign.CENTER, 
														autoSize:String = TextFieldAutoSize.LEFT, 
														fontSize:int = 26, 
														wordWrap:Boolean = false, 
														textColor:uint = 0x686868, 
														backgroundColor:uint = 0xffffff,
														shadowColor:uint = 0x000000, 
														isTransparent:Boolean = false, 
														shadowYOffset:int = 2 , 
														isItalic:Boolean  = false):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			textfield ||= new TextField();
			textFormat ||= new TextFormat();		
			textFormat.font = "Tahoma";
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.bold = bold;
			textFormat.italic = isItalic;
			textFormat.leading = 0;
			textFormat.color = textColor;
			
			textfield.autoSize = autoSize;
			textfield.multiline = multiline;
			textfield.wordWrap = wordWrap;
			textfield.textColor = textColor;
			textfield.border = false;		
			textfield.defaultTextFormat = textFormat;
			textfield.htmlText = text;
			textfield.x = 0;
			textfield.y = 0;
			
			
			//textfield.width = textfield.textWidth+4;
			if(autoSize != TextFieldAutoSize.LEFT){
				textfield.width = width;
			}
			if(autoSize == TextFieldAutoSize.NONE){
				textfield.width = width;
				textfield.height = height;
			}else {
				textfield.height = textfield.textHeight;
			}
			
			if (height == -1) {
				textfield.height = 5;
				textfield.autoSize = autoSize;
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderHtmlTextShadowed", textfield.width,textfield.height,isTransparent,backgroundColor);
			newBmd.draw(textfield,textfield.transform.matrix);
			newBmd.scroll(0, shadowYOffset);
			textFormat.color = shadowColor;;
			textfield.defaultTextFormat = textFormat;
			textfield.textColor = shadowColor; 		
			newBmd.draw(textfield,textfield.transform.matrix);
		
			textfield.autoSize = TextFieldAutoSize.LEFT;
			
			return newBmd;			
		}	
		
		
		
		public static function renderHtmlText(
												text:String = "", 
												width:int = 100, 
												height:int = 10, 
												multiline:Boolean = true, 
												bold:Boolean = false, 
												align:String =  TextFormatAlign.CENTER, 
												autoSize:String = TextFieldAutoSize.LEFT, 
												fontSize:int = 26, 
												wordWrap:Boolean = false, 
												textColor:uint = 0x686868, 
												backgroundColor:uint = 0xffffff,														
												isTransparent:Boolean = false
											):ImageBitmapData
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
			textfield ||= new TextField();
			textFormat ||= new TextFormat();		
			textFormat.font = "Tahoma";
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.bold = bold;
			textFormat.leading = 0;
			textFormat.color = textColor;
			
			textfield.autoSize = autoSize;
			textfield.multiline = multiline;
			textfield.wordWrap = wordWrap;
			textfield.textColor = textColor;
			textfield.border = false;		
			textfield.defaultTextFormat = textFormat;
			textfield.htmlText = text;
			textfield.x = 0;
			textfield.y = 0;
			
			
			//textfield.width = textfield.textWidth+4;
			if(autoSize != TextFieldAutoSize.LEFT){
				textfield.width = width;
			}
			if(autoSize == TextFieldAutoSize.NONE){
				textfield.width = width;
				textfield.height = height;
			}else {
				textfield.height = textfield.textHeight;
			}
			
			if (height == -1) {
				textfield.height = 5;
				textfield.autoSize = autoSize;
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderHtmlTextShadowed", textfield.width,textfield.height,isTransparent,backgroundColor);
			newBmd.draw(textfield,textfield.transform.matrix);
			textfield.autoSize = TextFieldAutoSize.LEFT;			
			return newBmd;			
		}
		
		
		[Inline]
		static public function scaleToFit(objToScale:DisplayObject, fitWidth:Number, fitHeight:Number):void
		{
			objToScale.transform.matrix.identity();
			objToScale.transform.matrix = new Matrix();
			var scale:Number = getMinScale(objToScale.width, objToScale.height, fitWidth, fitHeight);
			objToScale.scaleX = objToScale.scaleY = scale;
		}
		
		static public function scaleManual(bmdBig:BitmapData, ratio:Number, disposeBigBmd:Boolean = false):ImageBitmapData 
		{
			var bmBig:Bitmap = new Bitmap(bmdBig, PixelSnapping.NEVER, true);
			bmBig.smoothing = true;
			var m:Matrix = reusableMatrix;
			m.identity();
			m.scale(ratio, ratio);
			
			var bmdScaled:ImageBitmapData = new ImageBitmapData("UI.scaleManual", bmdBig.width * ratio, bmdBig.height * ratio, true, 0x000000);
			bmdScaled.drawWithQuality(bmBig, m, null, null, null, true,StageQuality.HIGH);
			
			if(disposeBigBmd){
				bmdBig.dispose();
				bmdBig = null;
			}
			bmBig.bitmapData.dispose();
			bmBig = null;
			m = null;
			
			return bmdScaled;
		}
			
		static public function drawAreaCentered(bmd:ImageBitmapData, width:int, height:int):ImageBitmapData {
			var result:ImageBitmapData = new ImageBitmapData("UI.ChatBackgroundImage", width, height);
			var matrix:Matrix = new Matrix();
			var scale:Number = getMaxScale(bmd.width, bmd.height, width, height);
			matrix.scale(scale, scale);
			
			var translateX:int = width * .5 - bmd.width * scale * .5;
			var translateY:int = height * .5 - bmd.height * scale * .5;
			
			matrix.translate(translateX, translateY);
			result.drawWithQuality(bmd, matrix, null, null, null, true, StageQuality.HIGH);
			return result;
		}
		
		public static function getSnapshot(obj:DisplayObject, quality:String = StageQuality.HIGH, name:String = '', smooth:Boolean = false):ImageBitmapData {
			//TODO - Проверить, чтобы обязательно было имя
			if (obj == null) return null;			
			var bmd:ImageBitmapData = new ImageBitmapData((name == "") ? "UI.Snapshot" : name, obj.width + .5, obj.height + .5, true, 0x000000);
			bmd.drawWithQuality(obj, obj.transform.matrix, obj.transform.colorTransform, null, null, smooth, quality);
			return bmd;
		}
		
		private static var tempBitmap:Bitmap = new Bitmap();
		
		public static function drawInputUnderLine(_color:uint, _width:int, _height:int, _thickness:Number = 1, _transparency:Number = 1):ImageBitmapData
		{
			if (_width < 1) _width = 1;
			if (_height < 1) _height = 1;
			var _gfx:Graphics = reusableShape.graphics;
			_gfx.clear();
			_gfx.beginFill(_color, _transparency);
			_gfx.moveTo(0, 0);
			_gfx.lineTo(_thickness, 0);
			_gfx.lineTo(_thickness, _height-_thickness);
			_gfx.lineTo(_width-_thickness, _height-_thickness);
			_gfx.lineTo(_width-_thickness, 0);
			_gfx.lineTo(_width, 0);
			_gfx.lineTo(_width, _height);
			_gfx.lineTo(0, _height);			
			_gfx.endFill();					
			var bmd:ImageBitmapData = new ImageBitmapData("UI.drawInputUnderLine", _width, _height, true, 0x000000);
			bmd.draw(reusableShape);			
			return bmd;
		}
		
		public static function drawTriangle(gfx:Graphics, sideSize:int = 8):void
		{
			//drawing circle inside the graphics object
			gfx.clear();
			gfx.lineStyle(6, 0x0000FF, 0.5);
			gfx.beginFill(0xFF0000, 0.5);
			gfx.moveTo(0,0);
			gfx.lineTo(sideSize,sideSize);
			gfx.lineTo(0,sideSize);
			gfx.lineTo(0,0);
			gfx.endFill();
		}
		
		public static function drawBitmapSqare(_color:uint, _width:int, _height:int):ImageBitmapData
		{
			var bmd:ImageBitmapData = new ImageBitmapData("UI,drawBitmapSqare", _width, _height, false, _color);
			return bmd;
		}	
		
		public static function drawRoundedSqareBitmap(_color:uint, _width:int, _height:int, _radius:int = 0, _transparency:Number = 1):ImageBitmapData
		{
			if (_width <= 0) _width = 1;
			if (_height <= 1) _height = 1;
			
			if (reusableShape == null)
				reusableShape = new Shape();					
			
			reusableShape.transform.matrix = null;
			reusableShape.scaleX = reusableShape.scaleY = 0;
			reusableShape.x = reusableShape.y = 0;
			//drawSegmentRoundRect(reusableShape.graphics, _color, _width, _height, _radius, _radius);
			drawRoundRect(reusableShape.graphics, _color, _width, _height, _radius, _radius, _radius,_radius);
		
			var bmd:ImageBitmapData = new ImageBitmapData("UI,drawRoundedSqareBitmap", _width, _height, true, 0x000000);
			bmd.drawWithQuality(reusableShape, null, null, null, null, true, StageQuality.HIGH);
			reusableShape.graphics.clear();
			return bmd;
		}
		
		public static function getIconByFrame(frame:int, fitWidth:int=-1, fitHeight:int = -1, customName:String = ""):ImageBitmapData
		{
			if(iconTemplateMC==null){
				iconTemplateMC = new SWFMinifyButton();
			}
			iconTemplateMC.gotoAndStop(frame);			
			if (fitWidth > 0 && fitHeight > 0) {
				iconTemplateMC.scaleX = iconTemplateMC.scaleY = getMinScale(iconTemplateMC.width, iconTemplateMC.height, fitWidth, fitHeight);				
			}
			var resultBMD:ImageBitmapData = getSnapshot(iconTemplateMC, StageQuality.HIGH, "UI.getIconByFrame." + customName);
			iconTemplateMC.scaleX = iconTemplateMC.scaleY = 1;			
			return resultBMD;
		}
		
		public static function getEmptyAvatarBitmapData(fitWidth:int=-1, fitHeight:int=-1):ImageBitmapData
		{
			if (avatarIcon == null) {
				avatarIcon = new SWFEmptyAvatar();
			}
			
			if (fitWidth > 0 && fitHeight > 0) {
				avatarIcon.scaleX = avatarIcon.scaleY = getMinScale(avatarIcon.width, avatarIcon.height, fitWidth, fitHeight);				
			}
			
			var resultBMD:ImageBitmapData = getSnapshot(avatarIcon, StageQuality.HIGH, "UI.getEmptyAvatarBitmapData");	
			avatarIcon.mask = null;
						
			avatarIcon.scaleX = avatarIcon.scaleY = 1;			
			return resultBMD;
		}
		
		public static function getTopBarBitmapData(w:int, h:int, topOffset:int, baseColor:uint, topColor:uint):ImageBitmapData
		{
			var bmd:ImageBitmapData = new ImageBitmapData("UI.getTopBarBitmapData", w, h+topOffset, false, baseColor);
			if (topOffset == 0) {
				reusableRect.x = 0;
				reusableRect.y = 0;
				reusableRect.width = w;
				reusableRect.height = topOffset;
				bmd.fillRect(reusableRect, topColor);
			}
			return bmd;
		}
		
		public static function getTopBarLayeredBitmapData(w:int, h:int, topOffset:int, bottomOffset:int, baseColor:uint, topColor:uint,bottomColor:uint):ImageBitmapData
		{
			var bmd:ImageBitmapData = new ImageBitmapData("UI.getTopBarLayeredBitmapData", w, h+topOffset+bottomOffset, false, baseColor);
			
			if (topOffset != 0) {
				reusableRect.x = 0;
				reusableRect.y = 0;
				reusableRect.width = w;
				reusableRect.height = topOffset;
				bmd.fillRect(reusableRect, topColor);
			}
			
			if (bottomOffset != 0) {
				reusableRect.x = 0;
				reusableRect.y = topOffset+h;
				reusableRect.width = w;
				reusableRect.height = bottomOffset;
				bmd.fillRect(reusableRect, bottomColor);
			}
			
			return bmd;
		} 
		
		//
		// Destroying Utils
		// do not use this methods from inside UI.as because it's inline
		//
		
		[Inline]
		public static function destroy(obj:DisplayObject):void
		{
			if (obj != null) {
				if (obj.parent) {
					obj.parent.removeChild(obj);
				}
				if ('graphics' in obj) {
					(obj['graphics'] as Graphics).clear();
				}
				if (obj is TextField) {
					(obj as TextField).text = "";
				}
				if (obj is Bitmap && (obj as Bitmap).bitmapData!=null) {
					(obj as Bitmap).bitmapData.dispose();
					(obj as Bitmap).bitmapData = null;
				}			
				obj = null;
			}
		}
	
		[Inline]
		public static function safeRemoveChild(obj:DisplayObject):void
		{
			if (obj != null && obj.parent != null) {			
				if (obj.parent.contains(obj)) obj.parent.removeChild(obj);			
			}	
		}
		
		[Inline]
		public static function disposeBMD(bmd:BitmapData):void {
			if (bmd !=null)
				bmd.dispose();
			bmd = null;
		}
		
		//
		//  Size Utils 
		//
		public static function getMinScale(imageWidth:Number, imageHeight:Number, fitWidth:Number, fitHeight:Number):Number
		{
			const sX : Number = fitWidth / imageWidth;
			const sY : Number = fitHeight /imageHeight;	
			const rD : Number = imageWidth / imageHeight;
			const rR : Number = fitWidth / fitHeight;
			return rD >= rR ? sX : sY;
		}
				
		public static function getMaxScale(imageWidth:int, imageHeight:int, fitWidth:Number, fitHeight:Number):Number
		{
			const sX : Number = fitWidth / imageWidth;
			const sY : Number = fitHeight /imageHeight;	
			const rD : Number = imageWidth / imageHeight;
			const rR : Number = fitWidth / fitHeight;
			return rD <= rR ? sX : sY;
		}
		
		public static function fitAndCentrate(obj:DisplayObject, fitWidth:Number, fitHeight:Number):void
		{
			var destScale:Number = getMinScale(obj.width, obj.height, fitWidth, fitHeight);
			 obj.scaleX = obj.scaleY = destScale;
			 obj.x = (fitWidth - obj.width) * .5;
			 obj.y = (fitHeight - obj.height) * .5;
		}

		public static function fillAndCentrate(obj:DisplayObject, fitWidth:Number, fitHeight:Number):void {
			var destScale:Number = getMaxScale(obj.width, obj.height, fitWidth, fitHeight);
			obj.cacheAsBitmap = false;
			obj.width = obj.width * destScale;
			obj.height = obj.height * destScale;
			obj.x = int((fitWidth - obj.width) * .5);
			obj.y = int((fitHeight - obj.height) * .5);
		}
		
		// Payments REUSABLE Icons set
		private static var depositIcon:Sprite;
		private static var internalTransferIcon:Sprite;
		private static var incommingTransferIcon:Sprite;
		private static var outgoingTransferIcon:Sprite;
		private static var feeIcon:Sprite;
		private static var canceledIcon:Sprite;
		private static var withdrawalIcon:Sprite;
		private static var prepaidCardIcon:Sprite;
		private static var pendingTransactionIcon:Sprite;
		private static var transactionFeeIcon:Sprite;
		private static var reverseIcon:Sprite;
		private static var refundCorrectionIcon:Sprite;
		private static var debitIcon:Sprite;
		private static var creditIcon:Sprite;
		private static var merchIcon:Sprite;
		private static var investmentIcon:Sprite;
		   
		// get Icon Asset by TYPE and cache it for reuse until we call to dispose it later
		public static function getIconByType(type:String):Sprite {
			if (type.toLowerCase().indexOf("reverse") == 0) {
				reverseIcon ||= new SWFPay_reverse();
				return reverseIcon;
			}
			if (type.toLowerCase().indexOf("fee") != -1) {
				feeIcon ||= new SWFPay_fee();
				return feeIcon;
			}
			
			var icon:Sprite;
			switch (type.toUpperCase()) {
				case TransferType.DEPOSIT:
					depositIcon ||= new SWFPay_deposit();
					icon = depositIcon;
				break;
				case TransferType.WITHDRAWAL:
					withdrawalIcon ||= new SWFPay_withdrawal();
					icon = withdrawalIcon;
				break;
				case TransferType.TRANSACTION: // pending?
					pendingTransactionIcon ||= new SWFPay_pending();
					icon = pendingTransactionIcon;
				break;
				case TransferType.INTERNAL_TRANSFER:
					internalTransferIcon ||= new SWFPay_int_transfer();
					icon = internalTransferIcon;
				break;
				case TransferType.INCOMING_TRANSFER:
					incommingTransferIcon ||= new SWFPay_incomming();
					icon = incommingTransferIcon;
				break;
				case TransferType.OUTGOING_TRANSFER:
					outgoingTransferIcon ||= new SWFPay_outgoing();
					icon = outgoingTransferIcon;
				break;
				case TransferType.PREPAID_CARD_WITHDRAWAL_CORNER:
				case TransferType.PREPAID_CARD_WITHDRAWAL:
				case TransferType.ORDER_OF_PREPAID_CARD:
					prepaidCardIcon ||= new SWFPayPrepaidCardIcon();
					icon = prepaidCardIcon;
				break;
				case TransferType.REFUND:
				case TransferType.CORRECTION:
					refundCorrectionIcon ||= new SWFPay_refund_correct();
					icon = refundCorrectionIcon;
				break;
				case TransferType.DEBIT:
					debitIcon ||= new SWFPay_debit();
					icon = debitIcon;
				break;
				case TransferType.CREDIT:
					creditIcon ||= new SWFPay_credit();
					icon = creditIcon;
				break;
				case TransferType.MERCHANT_TRANSFER:
					merchIcon ||= new SWFPay_merch();
					icon = merchIcon;
				break;
				
				case TransferType.INVESTMENT:
					investmentIcon ||= new SWFPay_investment();
					icon = investmentIcon;
				break;
				default:
					canceledIcon ||= new Sprite();
					icon = canceledIcon;
			}
			return icon;
		}
		
		private static var tempPoint:Point = new Point();
		private static const CACHED_PI:Number = Math.PI;
		
		// FLAGS ROUNDED  assets
		
		private static var flagEUR:Sprite;
		private static var flagCHF:Sprite;
		private static var flagUSD:Sprite;
		private static var flagGBP:Sprite;
		private static var flagAUD:Sprite;
		private static var flagCAD:Sprite;
		private static var flagPLN:Sprite;
		private static var flagRUB:Sprite;
		private static var flagJPY:Sprite;
		private static var flagCNH:Sprite;
		private static var flagDKK:Sprite;
		private static var flagSEK:Sprite;
		private static var flagNOK:Sprite;
		private static var flagSGD:Sprite;
		private static var flagHKD:Sprite;
		private static var flagMXN:Sprite;
		private static var flagNZD:Sprite;
		private static var flagTRY:Sprite;
		private static var flagZAR:Sprite;
		private static var flagRON:Sprite;
		private static var flagILS:Sprite;
		private static var flagCHZ:Sprite;
		private static var flagHUF:Sprite;
		private static var flagDCO:Sprite;
		private static var flagNONE:Sprite;
		
		public static function getFlagByCurrency(currency:String):Sprite {
			var flag:Sprite;
			switch (currency) {
				case TypeCurrency.EUR:
					flagEUR ||= new SWFFlagEUR();
					flag = flagEUR;
				break;
				case TypeCurrency.CHF:
					flagCHF ||= new SWFFlagCHF();
					flag = flagCHF;
				break;
				case TypeCurrency.USD:
					flagUSD ||= new SWFFlagUSD();
					flag = flagUSD;
				break;			
				case TypeCurrency.GBP:
					flagGBP ||= new SWFFlagGBP();
					flag = flagGBP;
				break;
				case TypeCurrency.AUD:
					flagAUD ||= new SWFFlagAUD();
					flag = flagAUD;
				break;		
				case TypeCurrency.CAD:
					flagCAD ||= new SWFFlagCAD();
					flag = flagCAD;
				break;	
				case TypeCurrency.PLN:
					flagPLN ||= new SWFFlagPLN();
					flag = flagPLN;
				break;
				case TypeCurrency.RUB:
					flagRUB ||= new SWFFlagRUB();
					flag = flagRUB;
				break;	
				case TypeCurrency.JPY:
					flagJPY ||= new SWFFlagJPY();
					flag = flagJPY;
				break;
				case TypeCurrency.CNH:
					flagCNH ||= new SWFFlagCNH();
					flag = flagCNH;
				break;	
				case TypeCurrency.DKK:
					flagDKK ||= new SWFFlagDKK();
					flag = flagDKK;
				break;	
				case TypeCurrency.SEK:
					flagSEK ||= new SWFFlagSEK();
					flag = flagSEK;
				break;	
				case TypeCurrency.NOK:
					flagNOK ||= new SWFFlagNOK();
					flag = flagNOK;
				break;	
				case TypeCurrency.SGD:
					flagSGD ||= new SWFFlagSGD();
					flag = flagSGD;
				break;	
				case TypeCurrency.HKD:
					flagHKD ||= new SWFFlagHKD();
					flag = flagHKD;
				break;
				case TypeCurrency.MXN:
					flagMXN ||= new SWFFlagMXN();
					flag = flagMXN;
				break;
				case TypeCurrency.NZD:
					flagNZD ||= new SWFFlagNZD();
					flag = flagNZD;
				break;
				case TypeCurrency.TRY:
					flagTRY ||= new SWFFlagTRY();
					flag = flagTRY;
				break;
				case TypeCurrency.ZAR:
					flagZAR ||= new SWFFlagZAR();
					flag = flagZAR;
				break;
				case TypeCurrency.RON:
					flagRON ||= new SWFFlagRON();
					flag = flagRON;
				break;
				case TypeCurrency.ILS:
					flagILS ||= new SWFFlagILS();
					flag = flagILS;
				break;				
				case TypeCurrency.CHZ:
				case TypeCurrency.CZK:
					flagCHZ ||= new SWFFlagCZK();
					flag = flagCHZ;
				break;
				case TypeCurrency.HUF:
					flagHUF ||= new SWFFlagHUF();
					flag = flagHUF;
				break;
				case TypeCurrency.DCO:
					flagDCO ||= new SWFInvestmentDCO();
					flag = flagDCO;
				break;
				
				case "EUR+":
				case "CHF+":
				case "USD+":
				case "GBP+":
				case "JPY+":
				case "CNY+":
				case "MXN+":
				case "RUB+":
					flagDCO ||= new SWFInvestmentDCO();
					flag = flagDCO;
				break;
				
				default:
					flagNONE ||= new SWFFlagNONE();
					flag = flagNONE;
			}
			return flag;
		}
		
		private static var stampShape:Shape = new Shape();
		static private var topBarDialogTField:TextField;
		static private var topBarTField:TextField;
		//// Investments Big
		private static var invBTC2:Sprite;
		private static var invXAU2:Sprite;
		private static var invXAG2:Sprite;
		private static var invGAS2:Sprite;
		private static var invOIL2:Sprite;
		private static var invUSA2:Sprite;
		private static var invCHE2:Sprite;
		private static var invGBR2:Sprite;
		private static var invFRA2:Sprite;
		private static var invDEU2:Sprite;
		private static var invJPN2:Sprite;
		private static var invETH2:Sprite;
		
		private static var invTSL:Sprite;
		private static var invNVD:Sprite;
		private static var invNFL:Sprite;
		private static var invMSF:Sprite;
		private static var invLTC:Sprite;
		private static var invGOO:Sprite;
		private static var invFBU:Sprite;
		private static var invAAP:Sprite;
		private static var invAMZ:Sprite;
		private static var invBTC:Sprite;
		private static var invXAU:Sprite;
		private static var invXAG:Sprite;
		private static var invGAS:Sprite;
		private static var invOIL:Sprite;
		private static var invUSA:Sprite;
		private static var invCHE:Sprite;
		private static var invGBR:Sprite;
		private static var invFRA:Sprite;
		private static var invDEU:Sprite;
		private static var invJPN:Sprite;
		private static var invETH:Sprite;
		private static var invDCO:Sprite;
		private static var invBLOCKCHAIN:Sprite;
		private static var invNONE:Sprite;
		static private var inv720:Sprite;
		static private var invAIR:Sprite;
		static private var invBAR:Sprite;
		static private var invBMW:Sprite;
		static private var invBOS:Sprite;
		static private var invMCF:Sprite;
		static private var invRNO:Sprite;
		static private var inv450:Sprite;
		static private var inv129:Sprite;
		static private var invSAE:Sprite;
		static private var inv675:Sprite;
		static private var invDAI:Sprite;
		static private var invNES:Sprite;
		static private var inv070:Sprite;
		static private var invORF:Sprite;
		static private var invCAR:Sprite;
		static private var invADS:Sprite;
		static private var invBPG:SWFInvestmentBPG;
		static private var invUSDT:Sprite;
		
		public static function getInvestIconByInstrument(type:String):Sprite {
			var icon:Sprite;
			switch (type) {
				case "TSL":
					invTSL ||= new SWFInvestmentTSL();
					icon = invTSL;
					break;
				case "NVD":
					invNVD ||= new SWFInvestmentNVD();
					icon = invNVD;
					break;
				case "NFL":
					invNFL ||= new SWFInvestmentNFL();
					icon = invNFL;
					break;
				case "MSF":
					invMSF ||= new SWFInvestmentMSF();
					icon = invMSF;
					break;
				case "LTC":
					invLTC ||= new SWFInvestmentLTC();
					icon = invLTC;
					break;
				case "GOO":
					invGOO ||= new SWFInvestmentGOO();
					icon = invGOO;
					break;
				case "FBU":
					invFBU ||= new SWFInvestmentFBU();
					icon = invFBU;
					break;
				case "AAP":
					invAAP ||= new SWFInvestmentAAP();
					icon = invAAP;
					break;
				case "AMZ":
					invAMZ ||= new SWFInvestmentAMZ();
					icon = invAMZ;
					break;
				case "XAU":
					invXAU ||= new SWFInvestmentXAU();
					icon = invXAU;
					break;
				case "XAG":
					invXAG ||= new SWFInvestmentXAG();
					icon = invXAG;
					break;
				case "OIL":
					invOIL ||= new SWFInvestmentOIL();
					icon = invOIL;
					break;	
				case "GAS":
					invGAS ||= new SWFInvestmentGAS();
					icon = invGAS;
					break;	
				case "CHE":
					invCHE ||= new SWFInvestmentCHE();
					icon = invCHE;
					break;	
				case "BTC":
					invBTC ||= new SWFInvestmentBTC();
					icon = invBTC;
					break;
				case "ETH":
					invETH ||= new SWFInvestmentETH();
					icon = invETH;
					break;	
				case "USA":
					invUSA ||= new SWFInvestmentUSA();
					icon = invUSA;
					break;	
				case "GBR":
					invGBR ||= new SWFInvestmentGBR();
					icon = invGBR;
					break;	
				case "FRA":
					invFRA ||= new SWFInvestmentFRA();
					icon = invFRA;
					break;	
				case "DEU":
					invDEU ||= new SWFInvestmentDEU();
					icon = invDEU;
					break;	
				case "JPN":
					invJPN ||= new SWFInvestmentJPN();
					icon = invJPN;
					break;
				case "DCO":
				case "DUK+":
					invDCO ||= new SWFInvestmentDCO();
					icon = invDCO;
					break;
				case "AIR":
					invAIR ||= new SWFInvestmentAIR();
					icon = invAIR;
					break;
				case "BAR":
					invBAR ||= new SWFInvestmentBAR();
					icon = invBAR;
					break;
				case "BMW":
					invBMW ||= new SWFInvestmentBMW();
					icon = invBMW;
					break;
				case "BOS":
					invBOS ||= new SWFInvestmentBOS();
					icon = invBOS;
					break;
				case "BPG":
					invBPG ||= new SWFInvestmentBPG();
					icon = invBPG;
					break;
				case "CAR":
					invCAR ||= new SWFInvestmentCAR();
					icon = invCAR;
					break;
				case "ORF":
					invORF ||= new SWFInvestmentORF();
					icon = invORF;
					break;
				case "MCF":
					invMCF ||= new SWFInvestmentMCF();
					icon = invMCF;
					break;
				case "ADS":
					invADS ||= new SWFInvestmentADS();
					icon = invADS;
					break;
				case "DAI":
					invDAI ||= new SWFInvestmentDAI();
					icon = invDAI;
					break;
				case "NES":
					invNES ||= new SWFInvestmentNES();
					icon = invNES;
					break;
				case "RNO":
					invRNO ||= new SWFInvestmentRNO();
					icon = invRNO;
					break;
				case "SAE":
					invSAE ||= new SWFInvestmentSAE();
					icon = invSAE;
					break;
				case "129":
					inv129 ||= new SWFInvestment129();
					icon = inv129;
					break;
				case "070":
					inv070 ||= new SWFInvestment070();
					icon = inv070;
					break;
				case "675":
					inv675 ||= new SWFInvestment675();
					icon = inv675;
					break;
				case "450":
					inv450 ||= new SWFInvestment450();
					icon = inv450;
					break;
				case "720":
					inv720 ||= new SWFInvestment720();
					icon = inv720;
					break;
				case TypeCurrency.BLOCKCHAIN:
					invBLOCKCHAIN ||= new Filter_affiliate(); // CHANGE TO BLOCKCHAIN ICON
					icon = invBLOCKCHAIN;
					break;
				case TypeCurrency.USDT:
					invUSDT ||= new SWFInvestmentUSDT();
					icon = invUSDT;
					break;
				default:
					invNONE ||= new SWFFlagNONE();
					icon = invNONE;
			}
			return icon;
		}
		
		//private static var invNONE2:Sprite;
		
		//
		// String Utils
		//
		public static function trimRight(p_string:String):String {
			if (p_string == null) { return ''; }
			return p_string.replace(/\s+$/, '');
		}
		
		public static function trim(__text:String): String {
			var whitespace:Array = [" ","\r", "\n", "\t"];		
			while (__text.length > 0 && whitespace.indexOf(__text.charAt(0)) > -1) {
				__text = __text.substr(1);
			}			
			while (__text.length > 0 && whitespace.indexOf(__text.charAt(__text.length - 1)) > -1) {
				__text = __text.substr(0, __text.length - 1);
			}
			return __text;
		}
		
		public static function trimLeft(p_string:String):String {
			if (p_string == null) { return ''; }
			return p_string.replace(/^\s+/, '');
		}
		
		public static function isEmpty(value : String) : Boolean {
			if (value == null) return true;
			var str : String = value.replace(/^\s+|\s+$/g, '');
			str = str.replace(/\s+/g, ' ');
			return !str.length;
		}
		
		public static function trimFront(str:String, char:String):String {
			char = stringToCharacter(char);
			if (str.charAt(0) == char) {
				str = trimFront(str.substring(1), char);
			}
			return str;
		}
		
		public static function stringToCharacter(str:String):String {
			if (str.length == 1) {
				return str;
			}
			return str.slice(0, 1);
		}
		
		static public function getHorizontalLine(color:Number = AppTheme.GREY_MEDIUM, width:Number = 1):ImageBitmapData {
			return new ImageBitmapData("UI.getHorizontalLine", width, Style.getLineThickness(), false, color);
		}
		
		static public function getVerticalLine(lineThickness:int = 2, color:Number = AppTheme.GREY_MEDIUM):ImageBitmapData {
			return new ImageBitmapData("UI.getVerticalLine", (Config.FINGER_SIZE * 0.01 * lineThickness), 1, false, color);
		}
		
		static public function getColorTexture(color:Number):ImageBitmapData {
			return new ImageBitmapData("UI.getColorTexture", 5, 5, false, color);
		}
		
		static public function renderLetterAvatar(text:String, fontSize:Number, radius:Number, backgroundColor:Number):ImageBitmapData {
			createButtonTemplate();
			
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = fontSize;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.italic = false;
			textFormat.bold = false;
			textfield.autoSize = TextFieldAutoSize.NONE;
			textfield.multiline = false;
			textfield.wordWrap = true;
			textfield.border = false;
			
			textfield.defaultTextFormat = textFormat;
			
			textfield.text = text;
			textfield.width = radius * 2;
			textfield.x = 0;
			textfield.height = textfield.textHeight+4;
			textfield.y = (radius - textfield.height * .5);
			
			//box.graphics.clear();
			//box.graphics.beginFill(backgroundColor);
			//box.graphics.drawCircle(radius, radius, radius);
			//box.graphics.endFill();
			
			drawRoundRectSuperEllipse(box.graphics, 0, 0, radius * 2, radius * 2, radius, backgroundColor);
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderLetterAvatar", radius * 2, radius * 2, true, 0x000000);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			return newBmd;		
		}
		
		static public function renderLetterAvatar2(text:String, fontSize:Number, radius:Number, backgroundColor:Number):ImageBitmapData {
			createButtonTemplate();
			
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = fontSize;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.italic = false;
			textFormat.bold = false;
			textfield.autoSize = TextFieldAutoSize.NONE;
			textfield.multiline = false;
			textfield.wordWrap = true;
			textfield.border = false;
			
			textfield.defaultTextFormat = textFormat;
			
			textfield.text = text;
			textfield.width = radius * 2;
			textfield.x = 0;
			textfield.height = textfield.textHeight+4;
			textfield.y = (radius - textfield.height * .5);
			
			box.graphics.clear();
			box.graphics.beginFill(backgroundColor);
			box.graphics.drawCircle(radius, radius, radius);
			box.graphics.endFill();
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("UI.renderLetterAvatar", radius * 2, radius * 2, true, 0x000000);
			newBmd.drawWithQuality(buttonTemplate,null,null,null,null,false,StageQuality.HIGH);
			box.graphics.clear();
			return newBmd;		
		}
		
		public static function getTopBarShape():Shape {
			var topBarShape:Shape = new Shape();
			if (Config.APPLE_TOP_OFFSET != 0) {
				topBarShape.graphics.beginFill(Style.color(Style.TOP_BAR));
				topBarShape.graphics.drawRect(0, 0, 1, Config.APPLE_TOP_OFFSET);
			}
			topBarShape.graphics.beginFill(Style.color(Style.TOP_BAR));
			topBarShape.graphics.drawRect(0, Config.APPLE_TOP_OFFSET, 1, Config.TOP_BAR_HEIGHT);
			topBarShape.graphics.lineStyle(getLineThickness(), Style.color(Style.COLOR_SEPARATOR_TOP_BAR), 1, false, "none", CapsStyle.SQUARE, JointStyle.MITER);
			topBarShape.graphics.moveTo(0, Config.APPLE_TOP_OFFSET + Config.TOP_BAR_HEIGHT);
			topBarShape.graphics.lineTo(1, Config.APPLE_TOP_OFFSET + Config.TOP_BAR_HEIGHT);
			return topBarShape;
		}
		
		static public function renderTopBarTitle(value:String, maxWidth:int, size:Number, color:Number, bold:Boolean):ImageBitmapData {
			if (value == null)
				return null;
			if (value == "")
				return new ImageBitmapData("TopBarEmpty", 1, 1);
			var tFormat:TextFormat = new TextFormat();
				tFormat.font = "Tahoma";
				tFormat.size = size;
				tFormat.align = TextFormatAlign.LEFT;
				tFormat.color = color;
				tFormat.bold = bold;
			if (topBarTField == null) {
				topBarTField = new TextField();
				topBarTField.visible = false;
				topBarTField.multiline = false;
				topBarTField.wordWrap = false;
			}
			topBarTField.defaultTextFormat = tFormat;
			topBarTField.text = value;
			topBarTField.setTextFormat(tFormat);
			MobileGui.stage.addChild(topBarTField);
			topBarTField.height = topBarTField.textHeight + 4;
			topBarTField.width = topBarTField.textWidth + 4;
			if (topBarTField.width > maxWidth) {
				topBarTField.text = value.substr(0, topBarTField.getCharIndexAtPoint(maxWidth, 2) - 3) + "...";
			}
			MobileGui.stage.removeChild(topBarTField);
			var newBmd:ImageBitmapData = new ImageBitmapData("UI.renderTopBarTitle", topBarTField.width, topBarTField.height);
			newBmd.drawWithQuality(topBarTField, null, null, null, null, true, StageQuality.BEST);
			topBarTField.text = "";
			return newBmd;
		}
		
		static public function renderTopBarDialogTitle(value:String, maxWidth:int):ImageBitmapData {
			if (value == null)
				return null;
			if (value == "")
				return new ImageBitmapData("TopBarEmpty", 1, 1);
			if (topBarDialogTField == null) {
				var tFormat:TextFormat = new TextFormat();
				tFormat.font = "Tahoma";
				tFormat.size = Config.TOP_BAR_DIALOG_FONT_SIZE;
				tFormat.align = TextFormatAlign.LEFT;
				tFormat.color = MainColors.DARK_BLUE;
				topBarDialogTField = new TextField();
				topBarDialogTField.visible = false;
				topBarDialogTField.multiline = false;
				topBarDialogTField.wordWrap = false;
				topBarDialogTField.defaultTextFormat = tFormat;
			}
			topBarDialogTField.text = value;
			MobileGui.stage.addChild(topBarDialogTField);
			topBarDialogTField.height = topBarDialogTField.textHeight + 4;
			topBarDialogTField.width = topBarDialogTField.textWidth + 4;
			if (topBarDialogTField.width > maxWidth) {
				topBarDialogTField.text = value.substr(0, topBarDialogTField.getCharIndexAtPoint(maxWidth, 2) - 3) + "...";
			}
			MobileGui.stage.removeChild(topBarDialogTField);
			var newBmd:ImageBitmapData = new ImageBitmapData("UI.renderTopBarTitle", topBarDialogTField.width, topBarDialogTField.height);
			newBmd.drawWithQuality(topBarDialogTField, null, null, null, null, true, StageQuality.BEST);
			topBarDialogTField.text = "";
			return newBmd;
		}
		
		public static function colorize(obj:DisplayObject, color:Number):DisplayObject {
			if(obj != null && !isNaN(color)) {
				var ct:ColorTransform = new ColorTransform();
				ct.color = color;
				obj.transform.colorTransform = ct;
			}
			return obj;
		}
		
		public static function decolorize(obj:DisplayObject, color:uint):DisplayObject {
			if(obj != null && obj.transform !=null && obj.transform.colorTransform !=null) {
				obj.transform.colorTransform.redMultiplier = 1;
				obj.transform.colorTransform.greenMultiplier = 1;
				obj.transform.colorTransform.blueMultiplier = 1;
				obj.transform.colorTransform.redOffset = 0;
				obj.transform.colorTransform.greenOffset = 0;
				obj.transform.colorTransform.blueOffset = 0;
			}
			return obj;
		}
		
		
		
		////////////////////////////////
		
		public static function renderPlaneWidthLogo(w:int, h:int, bmp:BitmapData, scaleFactor:Number =-1, tx:Number = 0, ty:Number = 0 ):BitmapData {
			var gfx:Graphics = stampShape.graphics;
			gfx.clear();
			if (scaleFactor!=-1){
				gfx.beginBitmapFill(bmp, new Matrix(scaleFactor,0,0, scaleFactor,tx, 0), true, true);
			 }else{
				gfx.beginBitmapFill(bmp);
			}				
			gfx.drawRect(0, 0, w, h);
			var returnBMD:BitmapData = renderAsset(stampShape, w, h, false);
			gfx.clear();
			return returnBMD;			
		}
		
		
		
		public static function drawAssetToRoundRect(instance:DisplayObject, sideSize:int, destroyInstance:Boolean=true, name:String = ""):ImageBitmapData
		{
			var bmd:ImageBitmapData = UI.renderAsset(instance, sideSize, sideSize, destroyInstance,name);
			drawRoundRectSuperEllipse(stampShape.graphics, 0, 0, sideSize, sideSize, sideSize * .5, 0x000000, bmd);			
			var returnBMD:ImageBitmapData = UI.renderAsset(stampShape, sideSize, sideSize, false, name);
			stampShape.graphics.clear();
			bmd.dispose();
			bmd = null;
			return returnBMD;

		}
		

		public static function drawElipseSquare(__target:Graphics, __size:Number, __radius:Number, _color:uint= 0x000000, bmp:BitmapData=null, m:Matrix = null):void {
			var graphics:Graphics = __target;
			graphics.clear();
			if(bmp!=null){
				graphics.beginBitmapFill(bmp, m, false, true);
			}else{
				graphics.beginFill(_color, 1);
			}
			drawSuperEllipseCurve(graphics, __radius, __radius, __radius, __radius, 180, 270, true);
			drawSuperEllipseCurve(graphics, __size - __radius, __radius, __radius, __radius, 270, 360);
			drawSuperEllipseCurve(graphics, __size - __radius, __size - __radius, __radius, __radius, 0, 90);
			drawSuperEllipseCurve(graphics, __radius, __size - __radius, __radius, __radius, 90, 180);
		}
		
		
		
		
		public static function drawRoundRectSuperEllipse(__target:Graphics, __x:Number, __y:Number, __width:Number, __height:Number, __radius:Number, _color:uint= 0x000000, bmp:BitmapData=null, m:Matrix = null):void {
		
			var graphics:Graphics = __target;
			graphics.clear();
			if(bmp!=null){
				graphics.beginBitmapFill(bmp, m, false, true);
			}else{
				graphics.beginFill(_color, 1);
			}
			var __topLeftRadius:Number = __radius;
			var __topRightRadius:Number = __radius;
			var __bottomLeftRadius:Number = __radius;
			var __bottomRightRadius:Number = __radius;
			
			// TL
			if (__topLeftRadius <= 0) {
				graphics.moveTo(__x, __y);
			} else {
				drawSuperEllipseCurve(graphics, __x + __topLeftRadius, __y + __topLeftRadius, __topLeftRadius, __topLeftRadius, 180, 270, true);
			}

			// TR
			if (__topRightRadius <= 0) {
				graphics.lineTo(__x + __width, __y);
			} else {
				drawSuperEllipseCurve(graphics, __x + __width - __topRightRadius, __y + __topRightRadius, __topRightRadius, __topRightRadius, 270, 360);
			}

			// BR
			if (__bottomRightRadius <= 0) {
				graphics.lineTo(__x + __width, __y + __height);
			} else {
				drawSuperEllipseCurve(graphics, __x + __width - __bottomRightRadius, __y + __height - __bottomRightRadius, __bottomRightRadius, __bottomRightRadius, 0, 90);
			}

			// BL
			if (__bottomLeftRadius <= 0) {
				graphics.lineTo(__x, __y + __height);
			} else {
				drawSuperEllipseCurve(graphics, __x + __bottomLeftRadius, __y + __height - __bottomLeftRadius, __bottomLeftRadius, __bottomLeftRadius, 90, 180);
			}
		}
		
		private static function drawSuperEllipseCurve(__target:Graphics, __cx:Number, __cy:Number, __xRadius:Number, __yRadius:Number, __startAngleDegrees:Number, __endAngleDegrees:Number, __moveFirst:Boolean = false):void {
			// Draw a "super ellipse" curve
			// https://en.wikipedia.org/wiki/Superellipse
			const SEGMENT_SIZE:Number = 5; // In degrees.. more = more precise but may be slower if done repeatedly
			// Enforce always min->max
			while (__endAngleDegrees < __startAngleDegrees) __endAngleDegrees += 360;
			var p:Point = tempPoint;
			for (var angleDegrees:Number = __startAngleDegrees; angleDegrees < __endAngleDegrees; angleDegrees += SEGMENT_SIZE) {
				getSuperEllipsePointOnCurve(p,__cx, __cy, angleDegrees, __xRadius, __yRadius);
				if (angleDegrees == __startAngleDegrees && __moveFirst) {
					__target.moveTo(p.x, p.y);
				} else {
					__target.lineTo(p.x, p.y);
				}
			}
			// Last point
			getSuperEllipsePointOnCurve(p,__cx, __cy, __endAngleDegrees, __xRadius, __yRadius);
			__target.lineTo(p.x, p.y);
		
		}
		
		private static function getSuperEllipsePointOnCurve(__point:Point, __cx:Number, __cy:Number, __angleDegrees:Number, __xRadius:Number, __yRadius:Number):void {
			const N:Number = 2.6; // The n of the curve; 4 according to wikipedia, 5 for a stronger corner
			var cn:Number =  2 / N;
			var angle:Number = __angleDegrees / 180 * CACHED_PI;
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			__point.x = Math.pow(Math.abs(ca), cn) * __xRadius * (ca < 0 ? -1 : 1) + __cx;
			__point.y = Math.pow(Math.abs(sa), cn) * __yRadius * (sa < 0 ? -1 : 1) + __cy;
		}
		
		public static function renderAmount(fullpart:String, decimalPart:String, fontSizeL:int, fontSizeS:int):String {
			return "<font size='" + fontSizeL + "'>" + fullpart + "</font>" + 
				   "<font size='" + fontSizeS + "'>" + ((decimalPart.length == 1) ? "0" + decimalPart : decimalPart) + "</font>";
		}
		
		public static function renderCurrencyAdvanced(amount:Number, currency:String, fontSizeL:int, fontSizeS:int):String {
			var amountStr:String = parseFloat(amount.toFixed(CurrencyHelpers.getMaxDecimalCount(currency))) + "";
			var amountParts:Array = amountStr.split(".");
			var res:String = "<font size='" + fontSizeL + "'>" + amountParts[0] + "</font>";
			if (amountParts.length == 2)
				res += "<font size='" + fontSizeS + "'>." + amountParts[1] + "</font>";
			if (currency == "DCO")
				currency = "DUK+";
			res += "<font size='" + fontSizeL + "'> " + CurrencyHelpers.getCurrencyByKey(currency) + "</font>";
			amountStr = null;
			amountParts = null;
			return res;
		}
		
		public static function renderCurrency(fullpart:String, decimalPart:String, currency:String, fontSizeL:int, fontSizeS:int, color:String = null):String {
			var colorExist:Boolean = color != null && color.length > 0 && color.charAt(0) == "#";
			var res:String = "";
			if (fullpart != null && fullpart.length > 0) {
				res = "<font size='" + fontSizeL + "'";
				if (colorExist == true)
					res += " color='" + color + "'";
				res += ">" + fullpart + "</font>";
			}
			
			if (decimalPart != null && decimalPart.length > 0) {
				res += "<font size='" + fontSizeS + "'";
				if (colorExist == true)
					res += " color='" + color + "'";
				res += ">" + decimalPart + "</font>";
			}
			res += "<font size='" + fontSizeL + "'";
			if (colorExist == true)
				res += " color='" + color + "'";
			
			if ((fullpart != null && fullpart.length > 0) || (decimalPart != null && decimalPart.length > 0)) {
				res += "> " + currency + "</font>";
			}
			else
			{
				res += ">" + currency + "</font>";
			}
			
			return res;
		}
		
		public static function getCurrencyTextHTML(fullPart:String, decimalPart:String, fontSizeFullpart:int, fontSizeDecimal:int, fullPartColor:String = "#93a2ae", decimalPartColor:String = "#3b4452"):String {
			return "<font color='" + fullPartColor + "' size='" + fontSizeFullpart + "'>" + fullPart + "</font>" + 
				   "<font color='" + decimalPartColor + "' size='" + fontSizeDecimal + "'>" + decimalPart + "</font>";
		}
		
		static public function createBannedMark(avatarSize:int, text:String):Bitmap 
		{
			var bannedMark:Bitmap = new Bitmap();
			
			
			//!TODO: переместить в UI сделать универсальную отрисовку текста на подложке с настройками;
			
			var textField:TextField = UI.getTextField();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = int(Math.max(avatarSize * .24, Config.FINGER_SIZE * .14));
			textFormat.color = MainColors.WHITE;
			textFormat.font = Config.defaultFontName;
			textFormat.align = TextFormatAlign.LEFT;
			textField.multiline = false;
			textField.wordWrap = false;
			
			textField.text = text;
			textField.setTextFormat(textFormat);
			textField.width = textField.textWidth + 4;
			textField.height = textField.textHeight + 4;
			
			var horizontalPadding:int = Config.FINGER_SIZE * .15;
			var verticalPadding:int = avatarSize * .05;
			
			var back:Shape = new Shape();
			
			textFormat.color = MainColors.WHITE;
			back.graphics.beginFill(AppTheme.RED_MEDIUM);
			
			var widthValue:int = avatarSize * 2.3;
			
			back.graphics.drawRoundRect(0, 0, widthValue, textField.height + verticalPadding * 2, 0, 0);
			back.graphics.endFill();
			
			var bitmapData:ImageBitmapData = new ImageBitmapData("UI.bannedMark", widthValue, textField.height + verticalPadding * 2);
			bitmapData.draw(back);
			var matrix:Matrix = new Matrix();
			matrix.translate(int(widthValue * .5 - textField.width * .5), verticalPadding);
			bitmapData.draw(textField, matrix);
			bannedMark.bitmapData = bitmapData;
			return bannedMark;
		}
		
		static public function getLineThickness():int 
		{
			return Math.max(1, int(Config.FINGER_SIZE * .036));
		}
		
		static public function getCryptoIconClass(instrument:String):Class 
		{
			switch (instrument) {
				case "LTC":
				{
					return SWFInvestmentLTC;
					break;
				}
					
				case "BTC":
				{
					return SWFInvestmentBTC;
					break;
				}
				case "ETH":
				{
					return SWFInvestmentETH;
					break;	
				}
				case "DCO":
				case "DUK+":
				{
					return SWFInvestmentDCO;
					break;
				}
				case "UST":
				{
					return SWFInvestmentUSDT;
					break;
				}
			}
			return null;
		}
	}
}