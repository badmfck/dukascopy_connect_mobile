package com.dukascopy.connect.sys 
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Utils 
	{
		
		public function Utils() 
		{
			
		}
		
		public static function isSubclassOf(type:Class, superClass:Class): Boolean
		{
			if (type == superClass)
			{
				return true;
			}
			if (superClass == Object)
			{
				return true;
			}
			try
			{
				for (
					var c:Class = type;
					c != Object;
					c = Class(getDefinitionByName(getQualifiedSuperclassName(c)))
				)
				{
					if (c == superClass)
					{
						return true;
					}
				}
			}
			catch(e:Error)
			{
			}
		 
			return false;
		}
	}
}