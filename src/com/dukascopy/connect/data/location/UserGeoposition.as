package com.dukascopy.connect.data.location 
{
	import com.dukascopy.connect.sys.geolocation.GeolocationManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class UserGeoposition 
	{
		public var disposed:Boolean;
		public var ctime:Number;
		public var location:Location;
		public var uid:String;
		public var userVO:UserVO;
		public var distance:Number;
		
		public function UserGeoposition(rawData:Object) 
		{
			if (rawData != null)
			{
				parse(rawData);
			}
		}
		
		public function dispose():void 
		{
			if (userVO != null)
			{
				UsersManager.removeUser(userVO);
				userVO = null;
			}
			disposed = true;
			location = null;
		}
		
		public function update(userGeoposition:UserGeoposition):void 
		{
			if (!disposed && userGeoposition != null && userGeoposition.disposed == false)
			{
				if (location.latitude != userGeoposition.location.latitude || location.longitude != userGeoposition.location.longitude)
				{
					location.latitude = userGeoposition.location.latitude;
					location.longitude = userGeoposition.location.longitude;
					
					GeolocationManager.updateDistance(this);
				}
				
				ctime = userGeoposition.ctime;
			}
		}
		
		private function parse(rawData:Object):void 
		{
			if ("ctime" in rawData)
			{
				ctime = rawData.ctime;
			}
			
			location = new Location(0, 0);
			if ("lat" in rawData)
			{
				location.latitude = rawData.lat;
			}
			if ("lng" in rawData)
			{
				location.longitude = rawData.lng;
			}
			if ("uid" in rawData)
			{
				uid = rawData.uid;
			}
		}
		
		public function get avatarURL():String
		{
			if (userVO != null)
			{
				return userVO.getAvatarURL();
			}
			return null;
		}
	}
}