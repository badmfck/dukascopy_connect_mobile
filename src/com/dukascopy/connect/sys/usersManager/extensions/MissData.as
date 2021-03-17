package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MissData 
	{
		static public const CONTROL_EXPAND:String = "controlExpand";
		static public const WINNER:String = "winner";
		static public const CONTROL_BACK:String = "controlBack";
		
		public var daySum:Number;
		public var spent:Number;
		public var rank:int;
		public var isMiss:Boolean;
		public var fxid:int;
		public var user_uid:String;
		public var user:UserVO;
		public var type:String
		
		public var month:int;
		public var year:int;
		
		public function MissData() 
		{
			
		}
		
		public function get name():String
		{
			if (type == CONTROL_EXPAND)
			{
				type = Lang.contestHistory;
			}
			return "";;
		}
		
		public function get avatarURL():String
		{
			if (user != null)
			{
				return user.avatarURL;
			}
			return null;
		}
		
		public function dispose():void
		{
			
		}
	}
}