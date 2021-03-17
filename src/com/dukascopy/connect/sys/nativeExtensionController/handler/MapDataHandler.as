package com.dukascopy.connect.sys.nativeExtensionController.handler 
{
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class MapDataHandler implements IDataHandler
	{
		
		public function MapDataHandler() 
		{
			
		}
		
		
		/* INTERFACE com.dukascopy.connect.sys.nativeExtensionController.handler.IDataHandler */
		
		public function handle(object:String):void 
		{
			if (object != null)
			{
				var args:Object;
				try
				{
					args = JSON.parse(object);
				}
				catch (e:Error)
				{
					
				}
				
				if (args != null && args.hasOwnProperty("method"))
				{
					switch (args.method)
					{
						case "MY_GEOLOCATION": 
						{
							var position:Object;
							try
							{
								position = JSON.parse(args.value);
								NativeExtensionController.S_LOCATION.invoke(new Location(position.lat, position.lon));
							}
							catch (e:Error)
							{
								
							}
							break;
						}
					}
				}
			}
		}
	}
}