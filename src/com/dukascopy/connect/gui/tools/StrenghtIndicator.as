package com.dukascopy.connect.gui.tools 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.type.MainColors;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StrenghtIndicator extends Sprite
	{
		private var _width:Number = 100;
		private var _strenghtLevel:int;
		private var _isDisposed:Boolean;
		
		public function StrenghtIndicator() 
		{
			redraw();
		}
		
		public function setWidth(value:Number):void
		{
			_width = value;
			redraw();
		}
		
		public function setStrenghtLevel(value:int):void
		{
			if (value < 0)
			{
				value = 0;
			}
			else if (value > 6)
			{
				value = 6;
			}
			_strenghtLevel = value;
			redraw();
		}
		
		public function dispose():void 
		{
			_isDisposed = true;
			UI.destroy(this);
		}
		
		private function redraw():void 
		{
			if (_isDisposed)
			{
				return;
			}
			var padding:int = Config.FINGER_SIZE * 0.11;
			var itemWidth:int = (_width - padding * 5)/6;
			graphics.clear();
			
			var fillColor:Number = getColor();
			
			for (var i:int = 0; i < 6; i++ )
			{
				graphics.beginFill((i >= _strenghtLevel)?MainColors.WHITE:fillColor, 1);
				graphics.drawRect((itemWidth + padding)*i, 0, itemWidth, int(Config.FINGER_SIZE * 0.05));
				graphics.endFill();
			}
		}
		
		private function getColor():Number 
		{
			switch(_strenghtLevel)
			{
				case 0:
					{
						return MainColors.WHITE;
						break;
					}
				case 1:
					{
						return MainColors.RED;
						break;
					}
				case 2:
					{
						return MainColors.RED;
						break;
					}
				case 3:
					{
						return MainColors.YELLOW;
						break;
					}
				case 4:
					{
						return MainColors.YELLOW;
						break;
					}
				case 5:
					{
						return MainColors.GREEN;
						break;
					}
				case 6:
					{
						return MainColors.GREEN;
						break;
					}
				default:
					{
							
					}
			}
			return MainColors.WHITE;
		}
		
	}

}