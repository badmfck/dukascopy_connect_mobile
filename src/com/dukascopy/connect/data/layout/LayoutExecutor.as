package com.dukascopy.connect.data.layout 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LayoutExecutor
	{
		
		public function LayoutExecutor() 
		{
			
		}
		
		public static function execute(items:Vector.<Sprite>, layout:LayoutType, layoutWidth:int):void
		{
			var position:int = 0;
			
			if (layout == LayoutType.vertical)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].y = position;
					position += items[i].height + gap;
				}
			}
			else if (layout == LayoutType.horizontal)
			{
				var gap:int = Config.FINGER_SIZE * .2;
				
				var lineIndex:int = 0;
				var linePosition:int = 0;
				
				var lines:Vector.<Vector.<Sprite>> = new Vector.<Vector.<Sprite>>();
				
				for (var j:int = 0; j < items.length; j++) 
				{
					if (lines.length < lineIndex + 1)
					{
						linePosition = 0;
						lines.push(new Vector.<Sprite>());
					}
					if (linePosition + items[j].width > layoutWidth && lines[lineIndex].length > 0)
					{
						lineIndex ++;
						linePosition = 0;
						if (lines.length < lineIndex + 1)
						{
							lines.push(new Vector.<Sprite>());
						}
					}
					lines[lineIndex].push(items[j]);
					linePosition += items[j].width + gap;
				}
				
				var realLineGap:int;
				var itemsWidth:int;
				var verticalPosition:int = 0;
				var lineHeight:int;
				for (var k:int = 0; k < lines.length; k++) 
				{
					lineHeight = 0;
					itemsWidth = 0;
					linePosition = 0;
					for (var l:int = 0; l < lines[k].length; l++) 
					{
						itemsWidth += lines[k][l].width;
					}
					if (lines[k].length > 1)
					{
						realLineGap = (layoutWidth - itemsWidth) / (lines[k].length - 1);
					}
					for (var m:int = 0; m < lines[k].length; m++) 
					{
						lineHeight = Math.max(lineHeight, lines[k][m].height);
						lines[k][m].x = linePosition;
						lines[k][m].y = verticalPosition;
						linePosition += lines[k][m].width + realLineGap;
					}
					verticalPosition += lineHeight;
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
	}
}