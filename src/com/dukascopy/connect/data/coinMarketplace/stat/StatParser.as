package com.dukascopy.connect.data.coinMarketplace.stat 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StatParser 
	{
		
		public function StatParser() 
		{
			
		}
		
		public function parse(rawData:String, maxItems:int):Vector.<StatPointData> 
		{
			if (isValid(rawData))
			{
				try
				{
					if (rawData != null)
					{
						var firstPoint:int = rawData.indexOf("[");
						var lastPoint:int = rawData.lastIndexOf("]");
						
						if (firstPoint != -1 && lastPoint != -1)
						{
							rawData = rawData.substr(firstPoint, lastPoint - firstPoint + 1);
							
							var jsonData:Array = JSON.parse(rawData) as Array;
							if (jsonData != null)
							{
								var collection:Vector.<StatPointData> = new Vector.<StatPointData>();
								var point:StatPointData;
								var l:int = jsonData.length;
								
								var pointDataParser:StatPointParser = new StatPointParser();
								
								var addIndex:int = 1;
								if (l > maxItems)
								{
									addIndex = Math.ceil(l/maxItems);
								}
								
								var currentIndex:int = 0;
								var currentPoint:StatPointData;
								var currentTime:Number;
								
								var values:Array = new Array();
								var sum:Number;
								var l2:int;
								
								for (var i:int = 0; i < l; i++) 
								{
									/*if (jsonData[i][1].key < 1551118400000)
									{
										continue;
									}*/
									
									if (currentPoint == null)
									{
										currentPoint = new StatPointData();
										values.length = 0;
										values.push(jsonData[i][1].value);
										currentTime = jsonData[i][1].key;
										
										var date:Date = new Date(currentTime);
										date.setSeconds(0, 0);
										date.setMinutes((Math.floor(date.getMinutes()/10)*10));
										currentTime = date.getTime();
										
										currentPoint.key = currentTime;
									}
									else if (jsonData[i][1].key < currentTime + MarketplaceStatistic.timeGap)	
									{
										values.push(jsonData[i][1].value);
										if (i == l - 1)
										{
											l2 = values.length;
											sum = 0;
											for (var j:int = 0; j < l2; j++) 
											{
												sum += values[j];
											}
											currentPoint.value = sum / l2;
											collection.push(currentPoint);
											currentPoint.index = collection.length - 1;
										}
									}
									else
									{
										var dif:Number = (jsonData[i][1].key - currentTime) / MarketplaceStatistic.timeGap;
										
										currentTime += Math.floor(dif) * MarketplaceStatistic.timeGap;
										
										l2 = values.length;
										sum = 0;
										for (var j2:int = 0; j2 < l2; j2++) 
										{
											sum += values[j2];
										}
										currentPoint.value = sum / l2;
										collection.push(currentPoint);
										currentPoint.index = collection.length - 1;
										
										currentPoint = new StatPointData();
										values.length = 0;
										values.push(jsonData[i][1].value);
									//	currentTime = jsonData[i][1].key;
										currentPoint.key = currentTime;
									}
								}
								return collection;
							}
						}
					}
				}
				catch (e:Error)
				{
					ApplicationErrors.add("StatParser.parse.json");
				}
			}
			else
			{
				ApplicationErrors.add();
			}
			return null;
		}
		
		private function isValid(rawData:Object):Boolean 
		{
			return true;
		}
	}
}