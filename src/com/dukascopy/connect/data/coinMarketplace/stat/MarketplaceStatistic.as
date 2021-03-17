package com.dukascopy.connect.data.coinMarketplace.stat 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MarketplaceStatistic 
	{
		static private var queue:Vector.<StatRequest>;
		static private var currentRequest:StatRequest;
		static private var slices:Dictionary;
		static private var maxStatLength:int = 30000;
		static public var timeGap:Number = 1000 * 60 * 10;
		
		static public var S_DATA_UPDATE:Signal = new Signal('MarketplaceStatistic.S_DATA_UPDATE');
		
		public function MarketplaceStatistic() 
		{
			
		}
		
		public static function update(type:String, before:Boolean = false, after:Boolean = false):void
		{
			if (slices != null && slices[type] != null && slices[type] is StatSlice)
			{
				if (before == false && after == false)
				{
					S_DATA_UPDATE.invoke((slices[type] as StatSlice), false);
				}
				else if (before == false && (slices[type] as StatSlice).last == true)
				{
					S_DATA_UPDATE.invoke((slices[type] as StatSlice), false);
				}
				else
				{
					loadData(type, before, after);
				}
			}
			else
			{
				loadData(type, before, after);
			}
		}
		
		static private function loadData(type:String, before:Boolean, after:Boolean):void 
		{
			var since:Number;
			var until:Number;
			var date:Date;
			
			var request:StatRequest;
			if (before == true)
			{
				if (after == false && slices != null && slices[type] != null && (slices[type] as StatSlice).since < 1551225600000)
				{
					S_DATA_UPDATE.invoke(null, false);
				}
				else if (slices != null && slices[type] != null)
				{
					
					var sliceStartTime:Number = (slices[type] as StatSlice).since;
					date = new Date(sliceStartTime - 1000);
					until = date.getTime();
					date.setUTCDate(1);
					if (date.getUTCMonth() == 0)
					{
						date.setUTCMonth(11);
						date.setUTCFullYear(date.getUTCFullYear() - 1);
					}
					else
					{
						date.setUTCMonth(date.getUTCMonth() - 1);
					}
					date.setUTCHours(0);
					date.setUTCMinutes(0);
					date.setUTCSeconds(0);
					date.setUTCMilliseconds(0);
					since = date.getTime();
					
					request = new StatRequest(getRequest(type, since, until), type);
					request.last = false;
					request.since = since;
					request.until = until;
					addRequest(request);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			if (after == true)
			{
			//	request = new StatRequest(getRequest(type, before, after), type);
			//	addRequest(request);
			}
			if (before == false && after == false)
			{
				if (before == false && after == false)
				{
					date = new Date();
					until = date.getTime();
					date.setUTCDate(1);
					if (date.getUTCMonth() == 0)
					{
						date.setUTCMonth(11);
						date.setUTCFullYear(date.getUTCFullYear() - 1);
					}
					else
					{
						date.setUTCMonth(date.getUTCMonth() - 1);
					}
					date.setUTCHours(0);
					date.setUTCMinutes(0);
					date.setUTCSeconds(0);
					date.setUTCMilliseconds(0);
					since = date.getTime();
				}
				
				request = new StatRequest(getRequest(type, since, until), type);
				request.last = true;
				request.since = since;
				request.until = until;
				addRequest(request);
			}
		}
		
		private static function addRequest(request:StatRequest):void 
		{
			if (queue == null)
			{
				queue = new Vector.<StatRequest>();
			}
			queue.push(request);
			
			if (currentRequest == null)
			{
				processNext();
			}
		}
		
		private static function processNext():void 
		{
			if (queue.length > 0)
			{
				currentRequest = queue.shift();
				currentRequest.COMPLETE.add(onRequestComplete);
				currentRequest.execute();
			}
		}
		
		static private function getRequest(type:String, since:Number, until:Number):URLRequest 
		{
			var url:String = "https://freeserv.dukascopy.com/2.0/";
			
			var request:URLRequest = new URLRequest(url);
			var header:URLRequestHeader = new URLRequestHeader("Referer", "https://www.dukascoin.com/?cat=inf&page=chart");
			request.requestHeaders = [header];
			request.method = URLRequestMethod.GET;
			
			var urlVar:URLVariables = new URLVariables();
			urlVar.path = "dukascoins/data";
			urlVar.side = type;
		//	urlVar.jsonp = "_callbacks____1jsohilu6";
			
			urlVar.since = since;
			urlVar.until = until;
			request.data = urlVar;
			
			return request;
		}
		
		private static function onRequestComplete(success:Boolean, rawData:String, type:String, since:Number, until:Number, last:Boolean):void 
		{
			if (success == true)
			{
				if (rawData != null)
				{
					var parser:StatParser = new StatParser();
					var newData:Vector.<StatPointData> = parser.parse(rawData, maxStatLength);
					
				//	newData = newData.slice(3, 20);
					if (newData != null)
					{
						if (newData.length > 0)
						{
							var slice:StatSlice = addSlice(type, newData, since, until, last);
							S_DATA_UPDATE.invoke(slice, true);
						}
						else
						{
							S_DATA_UPDATE.invoke(null, false);
						}
					}
					else
					{
						ToastMessage.display(Lang.serverError);
						S_DATA_UPDATE.invoke(null, false);
					}
				}
			}
			else
			{
				ToastMessage.display(Lang.serverError);
				S_DATA_UPDATE.invoke(null);
			}
			
			if (currentRequest != null)
			{
				currentRequest.dispose();
				currentRequest = null;
			}
			
			processNext();
		}
		
		static private function addSlice(type:String, newData:Vector.<StatPointData>, since:Number, until:Number, last:Boolean):StatSlice 
		{
			if (slices == null)
			{
				slices = new Dictionary();
			}
			if (slices[type] != null)
			{
				if (newData.length > 0)
				{
					slices[type].addPoints(newData, since, until, last);
				}
			}
			else
			{
				slices[type] = new StatSlice(newData, since, until, last, type);
			}
			return slices[type];
		}
	}
}