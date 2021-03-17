package com.dukascopy.connect.gui.list.renderers {
	
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ListContact extends Sprite implements IListRenderer {
		
		protected var avatarSize:int;
		protected var format1:TextFormat = new TextFormat("Tahoma");
		
		protected var fxnme:TextField;
		protected var nme:TextField;
		protected var avatar:Shape;
		protected var avatarEmpty:Shape;
		protected var toadIcon:Sprite;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		
		protected var nmeY1:int;
		protected var nmeY2:int;
		protected var fxnmeY:int;
		
		public function ListContact(){
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
				bg.graphics.beginFill(0, .10);
				bg.graphics.drawRect(0, 9, 10, 1);
				bg.scale9Grid = new Rectangle(1, 1, 8, 5);
			addChild(bg);
			bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(0x00a8ff,.2);
				bgHighlight.graphics.drawRect(0, 0, 10, 10);
				bgHighlight.graphics.endFill();
				bgHighlight.graphics.beginFill(0, .10);
				bgHighlight.graphics.drawRect(0, 9, 10, 1);
				bgHighlight.scale9Grid = new Rectangle(1, 1, 8, 5);
				bgHighlight.visible = false;
			addChild(bgHighlight);
				avatarSize = Config.FINGER_SIZE * .46;
				avatarEmpty = new Shape();
				//avatarEmpty.graphics.beginFill(0xDDDDDD);
				//avatarEmpty.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				//avatarEmpty.graphics.lineStyle(Config.FINGER_SIZE * .05, 0xFFFFFF);
				//avatarEmpty.graphics.moveTo(0, 0);
				//avatarEmpty.graphics.lineTo(avatarEmpty.width, avatarEmpty.height);
				
				UI.drawElipseSquare(avatarEmpty.graphics, avatarSize*2,avatarSize,0xDDDDDD);		
						
				avatarEmpty.x = Config.MARGIN * 2.5;
				avatarEmpty.y = Config.FINGER_SIZE * .15;
			addChild(avatarEmpty);
				avatar = new Shape();
				avatar.x = avatarEmpty.x;
				avatar.y = avatarEmpty.y;
			addChild(avatar);
			
			var scale:Number = avatarSize * 2 / 100;
				toadIcon = new SWFFrog();
				toadIcon.scaleX = scale;
				toadIcon.scaleY = scale;
				toadIcon.x = avatar.x + avatarSize;
				toadIcon.y = avatar.y + avatarSize;
			addChild(toadIcon);
			
				nme = new TextField();
				format1.size = Config.FINGER_SIZE * .28;
				nme.defaultTextFormat = format1;
				nme.text = "Pp";
				nme.height = nme.textHeight + 4;
				nme.text = "";
				nme.x = avatar.x + avatarSize * 2 + Config.MARGIN * 2;
				nmeY1 = Config.FINGER_SIZE * .5 - nme.height * .5;
				nmeY2 = Config.FINGER_SIZE * .55 - nme.height;
				nme.wordWrap = false;
				nme.multiline = false;
			addChild(nme);
				fxnme = new TextField();
				format1.size = Config.FINGER_SIZE * .2;
				fxnme.defaultTextFormat = format1;
				fxnme.text = "Pp";
				fxnme.height = fxnme.textHeight + 4;
				fxnme.text = "";
				fxnme.x = avatar.x + avatarSize * 2 + Config.MARGIN * 2;
				fxnmeY = Config.FINGER_SIZE * .55;
				fxnme.wordWrap = false;
				fxnme.multiline = false;
			addChild(fxnme);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return Config.FINGER_SIZE;
		}
		
		public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = width;
			bg.height = height;
			
			var newWidth:int = width - nme.x - Config.MARGIN;
			
			nme.width = newWidth;
			nme.y = nmeY1;
			nme.text = data.data.name;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = !highlight;
			bgHighlight.visible = highlight;
			
			fxnme.visible = false;
			if (data.data.name != data.data.fxName) {
				fxnme.visible = true;
				fxnme.width = newWidth;
				fxnme.textColor = AppTheme.RED_MEDIUM/*0xEE4131*/;
				fxnme.text = data.data.fxName;
				fxnme.y = fxnmeY;
				nme.y = nmeY2;
			}
			
			avatar.visible = false;
			avatarEmpty.visible = false;
			
			var avatarImage:ImageBitmapData = data.getLoadedImage("avatarURL");
			if (avatarImage != null && avatarImage.isDisposed == false) {
				avatar.visible = true;
				avatar.graphics.clear();
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
			} else {
				avatarEmpty.visible = true;
			}
			
			toadIcon.visible = false;
			if (UsersManager.checkForToad(data.data.userUID) == true)
				toadIcon.visible = true;
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			format1 = null;
			if (fxnme != null)
				fxnme.text = "";
			fxnme = null;
			if (nme != null)
				nme.text = "";
			nme = null;
			if (avatar != null)
				avatar.graphics.clear();
			avatar = null;
			if (avatarEmpty != null)
				avatarEmpty.graphics.clear();
			avatarEmpty = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (bgHighlight != null)
				bgHighlight.graphics.clear();
			bgHighlight = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}