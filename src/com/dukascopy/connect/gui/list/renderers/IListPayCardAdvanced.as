/**
 * Created by aleksei.leschenko on 09.12.2016.
 */
package com.dukascopy.connect.gui.list.renderers {
	public interface IListPayCardAdvanced extends IListRenderer{
		function fillWithData(data:Object, width:int,  highlight:Boolean = false):void;
	}
}
