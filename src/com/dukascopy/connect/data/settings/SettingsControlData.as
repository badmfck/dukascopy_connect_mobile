package com.dukascopy.connect.data.settings 
{
	import com.dukascopy.connect.data.SelectorItemData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SettingsControlData 
	{
		private var values:Vector.<SettingsValue>;
		private var selectedType:SettingsValueType;
		public var type:SettingsControlType;
		public var label:String;
		
		public function SettingsControlData(type:SettingsControlType, label:String) 
		{
			this.type = type;
			this.label = label;
		}
		
		public function addValue(value:SettingsValue):void 
		{
			if (values == null)
			{
				values = new Vector.<SettingsValue>();
			}
			values.push(value);
		}
		
		public function select(type:SettingsValueType):Boolean 
		{
			var changed:Boolean = false;
			if (selectedType == null || selectedType.getValue() != type.getValue())
			{
				selectedType = type;
				changed = true;
			}
			return changed;
		}
		
		public function dispose():void
		{
			if (values != null)
			{
				for (var i:int = 0; i < values.length; i++) 
				{
					values[i].dispose();
				}
			}
			values = null;
			type = null;
			label = null;
			selectedType = null;
		}
		
		public function getItems():Array
		{
			var result:Array = new Array();
			if (values != null)
			{
				for (var i:int = 0; i < values.length; i++) 
				{
					result.push(new SelectorItemData(values[i].label, values[i]));
					if (selectedType != null && values[i].type.getValue() == selectedType.getValue())
					{
						(result[result.length - 1] as SelectorItemData).selected = true;
					}
				}
			}
			
			return result;
		}
		
		public function getSelectedLabel():String 
		{
			if (selectedType != null && values != null)
			{
				for (var i:int = 0; i < values.length; i++) 
				{
					if (values[i].type.getValue() == selectedType.getValue())
					{
						return values[i].label;
					}
				}
			}
			return null;
		}
		
		public function getSelectedType():String 
		{
			if (selectedType != null)
			{
				return selectedType.getValue();
			}
			return null;
		}
	}
}