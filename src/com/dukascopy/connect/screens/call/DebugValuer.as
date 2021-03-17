package com.dukascopy.connect.screens.call {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Igro Bloom
	 */
	
	public class DebugValuer extends Sprite {
		
		
		private var valuesTF:TextField = new TextField();
		private var valuesBtn1:Sprite = new Sprite();
		private var valuesBtn2:Sprite = new Sprite();
		private var value:Number = 0;
		private var step:Number = 1;
		
		private var lbl:TextField = new TextField();
		private var min:Number;
		private var max:Number;
		
		public function DebugValuer(label:String, startValue:Number,step:Number,min:Number,max:Number, onValueChanged:Function){
			this.max = max;
			this.min = min;
			value = startValue;
			
			
			this.step = step;
			
				lbl.defaultTextFormat = new TextFormat("Tahoma", 12);
				lbl.text = label;
				lbl.width = 80;
				lbl.height = 20;
				lbl.background = true;
				lbl.selectable = false;
				lbl.textColor = 0xFFFFFF;
				lbl.backgroundColor = 0x0;
			addChild(lbl);
			
			
				valuesBtn1.graphics.beginFill(0xFF0000);
				valuesBtn1.graphics.drawRect(0, 0, 20, 20);
				valuesBtn1.x = lbl.x + lbl.width + 4;
				valuesBtn1.buttonMode = true;
			addChild(valuesBtn1);
				
				valuesTF.x = valuesBtn1.x+valuesBtn1.width+2;
				valuesTF.defaultTextFormat = new TextFormat("Tahoma", 12, null, null, null, null, null, null, TextFormatAlign.CENTER);
				valuesTF.text = value+"";
				valuesTF.width = 40;
				valuesTF.height = 20;
				valuesTF.background = true;
				valuesTF.selectable = false;
				valuesTF.textColor = 0xFFFFFF;
				valuesTF.backgroundColor = 0x0;
				
			addChild(valuesTF);
			
				valuesBtn2.graphics.beginFill(0x00FF00);
				valuesBtn2.graphics.drawRect(0, 0, 20, 20);
				valuesBtn2.x = valuesTF.x + valuesTF.width + 2;
				valuesBtn2.buttonMode = true;
			addChild(valuesBtn2);
			
			
			
				
			valuesBtn1.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				// Decrease
				value -= step;
				if (value <min)
					value =min;
				valuesTF.text = value.toFixed(2) + "";
				onValueChanged(value);
			});	
			valuesBtn2.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				// increase
				value += step;
				if (value > max)
					value = max;
				valuesTF.text = value.toFixed(2)  + "";
				onValueChanged(value);
			});
		}
		
		public function setValue(val:Number):void{
			value = val;
			valuesTF.text = value.toFixed(2)  + "";
		}
		
	}

}