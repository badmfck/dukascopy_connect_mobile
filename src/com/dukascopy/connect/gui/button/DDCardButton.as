package com.dukascopy.connect.gui.button {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayAccount;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class DDCardButton extends BitmapButton{
		
		private var generatedBitmap:ImageBitmapData;
		
		//private var value:String = "Choose...";
		
		private var box:Sprite;
		protected var tf:TextField;
		protected var tfRight:TextField;
		
		static private var arrowHeight:int;
		static private var arrowCathetus:int;
		
		private var w:int = 0;
		private var h:int = 0;
		
		protected var data:Object;
		private var defaultLabel:String = "";// Issue New Prepaid card";
		private var fullAccountNumber:String;
		private var shortAccountNumber:String;
		private var isLinkedCard:Boolean;
		
		public function DDCardButton(callBack:Function,data:Object=null/*, defaultLabel:String = ""*/){
			super();
			updateDefaultLabel();
			
			this.data = data;
			
			setStandartButtonParams();	
			
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			tapCallback = callBack;	
			
			box = new Sprite();
				tf = UIFactory.createTextField();
				tfRight = UIFactory.createTextField();
				tfRight.autoSize = TextFieldAutoSize.RIGHT;		
				tfRight.defaultTextFormat.align = TextFormatAlign.RIGHT;
				//tfRight.border = true;
			box.addChild(tf);
			box.addChild(tfRight);
			
		}
		
		public function updateDefaultLabel():void {
			/*if(defaultLabel == ""){
				defaultLabel = Lang.textChoose+"...";
			}
			else{
				this.defaultLabel = defaultLabel;
			}*/
			defaultLabel = Lang.textChoose+"...";
			setSize(w, h);
		}
		
		public function setSize(w:int, h:int):void {
			if (w < 1 || h < 1)
				return;
				
			this.w = w;
			this.h = h;
				
			if (generatedBitmap != null) {
				if (generatedBitmap.height != h || generatedBitmap.width != w) {
					generatedBitmap.dispose();
					generatedBitmap = null;
				}
			}
				
			if (generatedBitmap == null){
				generatedBitmap = new ImageBitmapData("DDCardButton.generatedBitmap", w, h, true, 0);
			}else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);	
			}
			
			var lineThickness:int = int(Math.max(1, Config.FINGER_SIZE * .03));
			box.graphics.clear();
			box.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND), 1);
			box.graphics.drawRect(1, 1, w, h);
			box.graphics.lineStyle(lineThickness, Style.color(Style.CONTROL_INACTIVE));
			box.graphics.moveTo(0, h - lineThickness / 2);
			box.graphics.lineTo(w, h - lineThickness / 2);
			box.graphics.lineStyle();
			
			// arrow
			var xOffset:int = w;
			arrowHeight = h * 0.15;
			arrowCathetus = h * 0.12;
			box.graphics.beginFill(Style.color(Style.COLOR_TEXT));
			box.graphics.moveTo(xOffset,int((h - arrowHeight) * .5));
			box.graphics.lineTo(xOffset - arrowCathetus, int((h + arrowHeight) * .5));
			box.graphics.lineTo(xOffset - arrowCathetus * 2, int((h - arrowHeight) * .5));
			box.graphics.lineTo(xOffset, int((h - arrowHeight) * .5));
			box.graphics.endFill();
		
			// Render Based on data 
			tf.x = (w - xOffset);
			
			if (data == null) {
				tfRight.text = "";
				// render default label
				tf.text = defaultLabel;
				tf.width = xOffset - arrowHeight * 2 - (w - xOffset) * 2;
				tf.y = (h - tf.height) * .5;	
				generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);		
			}
			
			if (data is String) {
				tfRight.text = "";
				// render single text line 	
				tf.text = data as String;				
				tf.width = xOffset - arrowHeight * 2 - (w - xOffset) * 2;
				tf.y = (h - tf.height) * .5;
				generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);		
			}
			
			if (data is Object) {
				var baseSize:Number = Config.FINGER_SIZE * 0.3;
				var captionSize:Number = Config.FINGER_SIZE * 0.25;
					
				if (data.number != null && data.number == 0) {
					tf.text = Lang.issueNewPrepaidCard;//"Issue new prepaid card";
					tfRight.htmlText = "";
				} else {
					var balance:String = data.available || "";
					if (Number(data.available) == 0)
					{
						balance = "0";
					}
					var dotIndex:int = balance.indexOf(".");
					var balanceLeft:String = "";
					var balanceRight:String = "";
					if(dotIndex!=-1){
						var rightPartLength:int  = balance.length - dotIndex;
						 balanceLeft = balance.substring(0, dotIndex);
						 balanceRight = balance.substr(dotIndex, rightPartLength);
					}else{
						balanceLeft = balance;
						balanceRight = "";
					}
					
					var accountNumber:String = (data.masked != null) ? data.masked : data.number;
					fullAccountNumber = accountNumber;
					shortAccountNumber = accountNumber;
					if(accountNumber!=null && accountNumber.length>=16){
						var first:String = accountNumber.substr(0, 4);
						var second:String = accountNumber.substr(4, 4);
						var third:String = accountNumber.substr(8, 4);
						var fourth:String = accountNumber.substr(12, 4);
						fullAccountNumber = first +" " + second + " " + third + " " + fourth;
						shortAccountNumber = ".... " + fourth;
					}
					
					var currency:String;
					isLinkedCard;//If its MyCard
					if("currency" in data){
						isLinkedCard = false;
						currency = data.currency || "";
					}else{
						if ("ccy" in data && data.ccy != null)
						{
							currency = data.ccy;
						}
						else
						{
							currency = "";
						}
						isLinkedCard = true;
					}
					
					//tf.text = formatedAccountNumber;
					
					tfRight.htmlText = "<font color='#000' size='" + baseSize+ "'>" +balanceLeft + "</font>" +"<font color='#000' size='" + captionSize+ "'>" +balanceRight + "</font>"+
					"  "+ currency;
					//tfRight.width = this.w * .4;
					tfRight.x = this.w -(tfRight.width) - Config.DOUBLE_MARGIN;
					tfRight.y = (h - tfRight.height) * .5;
					
					setAccountNumberText();
				}
				
				generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);	
			}
			
			setBitmapData(generatedBitmap);
		}
		
		protected function setAccountNumberText():void 
		{
			tf.text = isLinkedCard ? fullAccountNumber :shortAccountNumber;
		}
		
		override public function dispose():void
		{
			UI.safeRemoveChild(tf);
			UI.safeRemoveChild(tfRight);
			tf = null;
			tfRight = null;			
			if (box != null) {
				box.graphics.clear();			
				box = null;
			}
			this.data = null;
			if (generatedBitmap != null) {
				generatedBitmap.dispose();
				generatedBitmap = null;				
			}
			
			super.dispose();
		}
		
		// value could be object 
		public function setValue(data:Object = null):void {
			this.data = data;			
			setSize(w, h);
		}
		
		public function getValue():Object {
			return this.data;	
		}
		
		public function getMasked():String 
		{
			return tf.text;
		}	
	}
}