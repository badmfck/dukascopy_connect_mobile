package com.dukascopy.connect.gui.tabs {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;

	/**
	 * ...
	 * @author ...
	 */
	public class TabsItemNew extends TabsItem implements ITabsItem {

		public function TabsItemNew(name:String, id:String, num:int, icon:ImageBitmapData = null, bg:ImageBitmapData = null, clr:uint = 0xFFFFFF, bgAlpha:Number = 1, textColor:uint = 0, doSelection:Boolean = true) {
			super(name, id, num, icon, bg, clr, bgAlpha, textColor, doSelection);
		}

		/*override protected function getWidthTF():Number{
		 	//	return tf.textWidth + 4 + margin * 2;
		 return tf.textWidth + 4+ margin/!* 2*!/;
		 }*/
		override protected function getWidthTF():Number{

			return tf.textWidth + 4 + (margin + shiftMargin) ;
//			return tf.textWidth /*+ 4*/ + margin /* 2*/;
		}

		override protected function getMargin():Number {
			var result:Number =(margin + shiftMargin) * .5;
			return result >= 0 ? int(result) : 0;
		}

		override public function cutByLeft(cutWidth:Number):void {
			if(shiftMargin==0)
			{
				shiftMargin = cutWidth;
			}
			rebuild(Config.FINGER_SIZE);
		}
	}
}