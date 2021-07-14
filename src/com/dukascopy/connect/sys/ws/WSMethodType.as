package com.dukascopy.connect.sys.ws 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WSMethodType 
	{
		static public const CHAT_TITLE_CHANGE:String = "topicChange";
		static public const CHAT_AVATAR_CHANGE:String = "avatarChange";
		
		static public const BH_METHOD_CHANNEL_MODERATOR_ADDED:String = "ch_mod_add";
		static public const BH_METHOD_CHANNEL_YOU_MODERATOR:String = "ch_you_mod";
		static public const BH_METHOD_CHANNEL_MODERATOR_REMOVED:String = "ch_mod_rem";
		static public const BH_METHOD_CHANNEL_YOU_NOT_MODERATOR:String = "ch_you_not_mod";
		static public const BH_METHOD_CHANNEL_BACKGROUND_CHANGED:String = "ch_back_ch";
		static public const BH_METHOD_CHANNEL_AVATAR_CHANGED:String = "ch_ava_ch";
		static public const BH_METHOD_CHANNEL_TITLE_CHANGED:String = "ch_title_ch";
		
		static public const ADD_TO_COMPANY_CHAT:String = "addToCompanyChat";
		
		static public const CHAT_USER_KICK:String = "chatUserKick";
		static public const CHAT_USER_BAN:String = "chatUserBan";
		static public const CHAT_USER_UNBAN:String = "chatUserUnban";
		static public const CHAT_USER_KICK_RESPONSE:String = "userKick";
		static public const CHAT_USER_UNBAN_RESPONSE:String = "userUnban";
		static public const CHAT_USER_BAN_RESPONSE:String = "userBan";
		static public const CHAT_CHANGE_MODE_RESPONSE:String = "setMode";
		static public const CHAT_MODERATOR_SET:String = "chatSetModerator";
		static public const CHAT_MODE_SET:String = "chatSetMode";
		static public const CHAT_MODERATOR_SET_RESPONSE:String = "chatModerator";
		static public const MY_STATUS:String = "myStatus";
		static public const CHAT_MESSAGE_REACTION:String = "msgReaction";
		
		static public const QUESTION_CREATED:String = "questionCreated";
		static public const QUESTION_UPDATED:String = "questionUpdated";
		static public const QUESTION_CLOSED:String = "questionClosed";
		
		static public const CHAT_USER_WRITING:String = "userWriting";
		
		static public const PUZZLE_PAID:String = "puzzlePaid";
		
		static public const SET_PHASE:String = "set_phase";
		
		static public const CHANNEL_CREATED:String = "channelCreated";
		static public const CHANNEL_CLOSED:String = "channelClosed";
		static public const PAID_BAN_UNBANNED:String = "paidUnban";
		static public const PAID_BAN_BANNED:String = "paidBan";
		static public const LOCATION_UPDATE:String = "locationUpdate";
		
		static public const MODERATOR_PAID_BAN_UNBANNED:String = "ban911";
		static public const MODERATOR_PAID_BAN_BANNED:String = "unban911";
		static public const MAIN_BAN:String = "ban";
		static public const GET_IDENTIFICATION_QUEUE_LENGTH:String = "getQueueTotal";
		static public const ESCROW_OFFER_ACCEPT:String = "escrowOfferAccept";
		static public const ESCROW_OFFER_CANCEL:String = "escrowOfferCancel";
		
		public function WSMethodType() 
		{
			
		}
	}
}