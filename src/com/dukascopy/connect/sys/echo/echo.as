package com.dukascopy.connect.sys.echo {
	
	import com.dukascopy.connect.Config;
	
	/**
	 * 
	 * @param	target
	 * @param	method
	 * @param	data
	 * @param	line
	 */
	
	public function echo(target:String, method:String, data:*= null, error:Boolean = false, line:int = -1):void {
		//return;
		EchoParser.pewPrew(target, method, data, error, line);
	}
}