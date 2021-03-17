package com.telefision.sys.signals {
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public interface ISignal {
		function add(method:Function):Function;
		function remove(method:Function):void;
		function invoke(...rest):void;
		function disable(val:Boolean):void;
	}
	
}