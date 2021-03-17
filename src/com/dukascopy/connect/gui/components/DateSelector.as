package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.filter.FilterData;
	import com.dukascopy.connect.screens.dialogs.calendar.DatePicker;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.type.FinanceFilterType;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DateSelector extends Sprite implements IFilterView
	{
		private var selector:DatePicker;
		private var componentWidth:int;
		private var filtersData:Vector.<FilterData>;
		private var onChanged:Function;
		private var oneDayTime:Number = 23*60*60 + 59*60 + 59;
		
		public function DateSelector(onChanged:Function) 
		{
			this.onChanged = onChanged;
			
			selector = new DatePicker();
			selector.onSelect = onDateSelect;
			selector.allowAllDates(true);
			selector.rangeSelection = true;
			addChild(selector);
		}
		
		private function onDateSelect():void 
		{
			if (selector != null && filtersData != null && filtersData.length > 1)
			{
				filtersData[0].selected = true;
				filtersData[1].selected = true;
				
				var endDayTimestamp:Number;
				
				filtersData[0].type = new FinanceFilterType(getTimestamp(selector.getDateFrom()));
				if (selector.getDateUntil() != null)
				{
					endDayTimestamp = Number(getTimestamp(selector.getDateUntil())) + oneDayTime;
					filtersData[1].type = new FinanceFilterType(endDayTimestamp.toString());
				}
				else
				{
					endDayTimestamp = Number(filtersData[0].type.type) + oneDayTime;
					filtersData[1].type = new FinanceFilterType(endDayTimestamp.toString());
				}
				
				if (onChanged != null)
				{
					onChanged();
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function getTimestamp(date:Date):String 
		{
			return (date.time / 1000).toString();
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function setData(filtersData:Vector.<FilterData>):void 
		{
			this.filtersData = filtersData;
			if (selector != null && filtersData != null && filtersData.length > 1)
			{
				if (filtersData[0].selected == false)
				{
					filtersData[0].type = new FinanceFilterType(null);
				}
				if (filtersData[1].selected == false)
				{
					filtersData[1].type = new FinanceFilterType(null);
				}
				selector.setRange(getDate(filtersData[0].type.type), getDate(filtersData[1].type.type));
			}
		}
		
		private function getDate(timestamp:String):Date 
		{
			if (timestamp == null)
			{
				return null;
			}
			return new Date(Number(timestamp) * 1000);
		}
		
		public function setWidth(value:int):void 
		{
			componentWidth = int(value - Config.FINGER_SIZE * .8);
			selector.draw(componentWidth);
			selector.x = value * .5 - selector.getWidth() * .5;
		}
		
		public function activate():void 
		{
			selector.activate();
		}
		
		public function deactivate():void 
		{
			selector.deactivate();
		}
		
		public function update():void 
		{
			selector.updateBounds();
		}
		
		public function getHeight():int 
		{
			return height + Config.FINGER_SIZE * .7;
		}
		
		public function redraw():Boolean 
		{
			setData(filtersData);
			selector.draw(componentWidth);
			return true;
		}
		
		public function dispose():void 
		{
			onChanged = null;
			filtersData = null;
			if (selector != null)
			{
				selector.dispose();
				selector = null;
			}
		}
	}
}