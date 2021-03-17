package com.dukascopy.connect.sys.pool{
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	public interface IPoolItem {
		function set inUse(val:Boolean):void;
		function get inUse():Boolean;
	}
	
}