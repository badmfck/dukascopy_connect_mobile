package com.dukascopy.connect.vo.chat 
{
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import flash.xml.XMLNode;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ReplayMessageVO 
	{
		public var target:int = -1;
		public var author:String = "";
		public var text:String;
		public var message:String = "";
		
		public function ReplayMessageVO(value:String) 
		{
			if (value != null && value.indexOf(ChatSystemMsgVO.REPLAY_START_BOUND) == 0 && value.indexOf(ChatSystemMsgVO.REPLAY_END_BOUND) != -1);
			{
			//	"{quote quote-type=\" \" author=\"Sergey Dobarin\" dt=\"05.04.2021 - 13:44:26\"}ewqewcewcewcew{quote}\n123123"
				text = value.substring(value.indexOf(ChatSystemMsgVO.REPLAY_END_BOUND) + ChatSystemMsgVO.REPLAY_END_BOUND.length + 1);
				value = value.substring(0, value.indexOf(ChatSystemMsgVO.REPLAY_END_BOUND) + ChatSystemMsgVO.REPLAY_END_BOUND.length);
				
				value = value.replace(ChatSystemMsgVO.REPLAY_START_BOUND, ChatSystemMsgVO.REPLAY_START_BOUND_FIXED);
				value = value.replace(ChatSystemMsgVO.REPLAY_END_BOUND, ChatSystemMsgVO.REPLAY_END_BOUND_FIXED);
				value = value.substr(0, value.indexOf("}")) + ">" + value.substr(value.indexOf("}") + 1);
				value = value.replace(/"/g, "'");
				try
				{
					var raw:XML = new XML(value);
					author = raw.attribute("author").toString();
					message = raw.toString();
					if (raw.attribute("target"))
					{
						target = parseInt(raw.attribute("target"));
					}
				}
				catch (e:Error)
				{
					
				}
			}
		}
	}
}