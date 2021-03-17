package com.dukascopy.connect.data.coinMarketplace.stat 
{
	/**
	 * ...
	 * @author Segrey Dobarin
	 */
	public class StatSlice 
	{
		private var indexesShift:int = -1;
		public var type:String;
		public var since:Number;
		public var until:Number;
		public var last:Boolean;
		public var data:Vector.<StatPointData>;
		public var time:Number;
		
		public function StatSlice(data:Vector.<StatPointData>, since:Number, until:Number, last:Boolean, type:String) 
		{
			this.type = type;
			this.data = data;
			this.since = since;
			this.until = until;
			this.last = last;
			
			this.time = (new Date()).getTime();
		}
		
		public function addPoints(points:Vector.<StatPointData>, since:Number, until:Number, last:Boolean):void
		{
			if (this.last == false)
			{
				this.last = last;
			}
			if (this.since > until)
			{
				this.since = since;
				indexesShift = points.length;
				data = points.concat(data);
				updateIndexes();
			}
			else if(this.until < since)
			{
				this.until = until;
				data = data.concat(points);
				updateIndexes();
			}
			else
			{
				//trace("123");
			}
		}
		
		public function getIndexesShift():int 
		{
			var value:int = indexesShift;
			indexesShift = -1;
			return value;
		}
		
		private function updateIndexes():void 
		{
			if (data != null)
			{
				var l:int = data.length;
				for (var i:int = 0; i < l; i++) 
				{
					data[i].index = i;
				}
			}
		}
	}
}