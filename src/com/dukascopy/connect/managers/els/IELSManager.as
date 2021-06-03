package com.dukascopy.connect.managers.els {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public interface IELSManager {
		
		function remove(name:String):void;
		function save(name:String, value:String):void;
		function load(name:String):String;
		
	}
}