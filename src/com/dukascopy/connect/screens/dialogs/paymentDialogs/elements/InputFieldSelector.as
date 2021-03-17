package com.dukascopy.connect.screens.dialogs.paymentDialogs.elements 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InputFieldSelector extends InputField
	{
		public var onValueSelectedFunction:Function;
		private var arrow:Sprite;
		
		public function InputFieldSelector() 
		{
			super();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (valueContainer != null)
			{
				UI.destroy(valueContainer);
				valueContainer = null;
			}
		}
		
		override public function activate():void
		{
			super.activate();
			
			PointerManager.addTap(valueContainer, callSelect);
		}
		
		private function callSelect(e:Event = null):void 
		{
			if (onValueSelectedFunction != null)
			{
				onValueSelectedFunction();
			}
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			PointerManager.removeTap(valueContainer, callSelect);
		}
		
		override public function updatePositions():void 
		{
			var tf:TextField = input.getTextField();
			var line:TextLineMetrics = tf.getLineMetrics(0);
			
			input.view.y = int(title.y + title.height - Config.FINGER_SIZE * .1);
			input.width = itemWidth - valueField.width - arrow.width - Config.FINGER_SIZE * .2;
			
			valueContainer.x = int(input.view.x + itemWidth - valueField.width - arrow.width - Config.FINGER_SIZE * .2);
			valueContainer.y = int(input.view.y + tf.y + line.ascent - valueField.height + 2);
			underline.width = itemWidth;
			underline.y = int(input.view.y + input.height - Config.FINGER_SIZE * .10);
			
			underlineValue.x = int(itemWidth - underlineValue.width);
			underlineValue.y = int(underline.y + Config.FINGER_SIZE * .16);
			
			arrow.x = int(valueField.width + Config.FINGER_SIZE * .2);
			arrow.y = int(valueField.y + valueField.height * .5 - arrow.height * .5);
		}
		
		override protected function create():void
		{
			super.create();
			
			arrow = new Sprite();
			valueContainer.addChild(arrow);
			var arrowHeight:Number = Config.FINGER_SIZE*.85 * 0.15;
				var arrowCathetus:Number = Config.FINGER_SIZE*.85 * 0.12;
				arrow.graphics.beginFill(AppTheme.GREY_MEDIUM);
				arrow.graphics.moveTo(0, 0);
				arrow.graphics.lineTo(0 + arrowCathetus, arrowHeight);
				arrow.graphics.lineTo(0 + arrowCathetus * 2, 0);
				arrow.graphics.lineTo(0, 0);
				arrow.graphics.endFill();
			
			right.width = Config.FINGER_SIZE * .1;
		}
	}
}