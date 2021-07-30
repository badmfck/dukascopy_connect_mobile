package com.dukascopy.connect.sys.contextActions {
	
	import assets.BlockUserIcon;
	import assets.ContectDeleteIcon;
	import assets.ContextCallIcon;
	import assets.KickIcon;
	import assets.ModeratorIcon;
	import assets.ModeretorRemoveIcon;
	import assets.ReplyIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.renderers.ChannelBannedUserListRenderer;
	import com.dukascopy.connect.gui.list.renderers.ChannelUserListRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListChatItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListQuestionRenderer;
	import com.dukascopy.connect.gui.list.renderers.TransactionTemplateRenderer;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ContextCollectionBuilder {
		
		public function ContextCollectionBuilder() { }
		
		public static function getContextActions(itemClass:Class, itemData:Object):Vector.<ContextAction> {
			var actions:Vector.<ContextAction> = new Vector.<ContextAction>();
			switch (itemClass) {
				case ListConversation: {
					if (itemData == null)
						break;
					if (itemData is ChatVO) {
						if ((itemData as ChatVO).type == ChatRoomType.PRIVATE) {
							var user:ChatUserVO = UsersManager.getInterlocutor(itemData as ChatVO);
							if (user && user.uid != Config.NOTEBOOK_USER_UID && NetworkManager.isConnected)
							{
								actions.push(new ContextAction(HitZoneType.CALL, Lang.textCall, Style.color(Style.COLOR_SEPARATOR), ContextCallIcon ));
							}
							if (NetworkManager.isConnected == true)
							{
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
							}
						} else if ((itemData as ChatVO).type == ChatRoomType.GROUP && NetworkManager.isConnected == true) {
							actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
						} else if ((itemData as ChatVO).type == ChatRoomType.QUESTION && NetworkManager.isConnected == true) {
							actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
						} else if ((itemData as ChatVO).type == ChatRoomType.COMPANY) {
							
						} else if ((itemData as ChatVO).type == ChatRoomType.CHANNEL) {
							if (Config.isAdmin()){
								actions.push(new ContextAction(HitZoneType.OPEN_PROFILE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), IconContactsS ));
								if (NetworkManager.isConnected == true)
								{
									actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
								}
							}
						}
					}
					break;
				}
				case ListQuestionRenderer: {
					if (itemData == null)
						break;
					if (itemData is QuestionVO) {
						if ((itemData as QuestionVO).uid == null)
							break;
						if ((itemData as QuestionVO).isMine()) {
							if (itemData.isRemoving == true)
								break;
							if (itemData.status == QuestionsManager.QUESTION_STATUS_CREATED || itemData.status == QuestionsManager.QUESTION_STATUS_EDITED)
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
							else if (isNaN((itemData as QuestionVO).tipsAmount) == true && NetworkManager.isConnected == true)
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
							else if (itemData.isPaid == true && NetworkManager.isConnected == true)
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
						} else if (Config.isAdmin() == true && NetworkManager.isConnected == true)
							actions.push(new ContextAction(HitZoneType.DELETE_ADMIN, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
					}
					break;
				}
				case ListEscrowRenderer: {
					if (itemData == null)
						break;
					if (itemData is QuestionVO) {
						if ((itemData as QuestionVO).uid == null)
							break;
						if ((itemData as QuestionVO).isMine()) {
							if (itemData.isRemoving == true)
								break;
							if (itemData.status == QuestionsManager.QUESTION_STATUS_CREATED || itemData.status == QuestionsManager.QUESTION_STATUS_EDITED)
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
							else if (NetworkManager.isConnected == true)
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
							else if (itemData.isPaid == true && NetworkManager.isConnected == true)
								actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
						} else if (Config.isAdmin() == true && NetworkManager.isConnected == true)
							actions.push(new ContextAction(HitZoneType.DELETE_ADMIN, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon));
					}
					break;
				}
				case ListChatUsers: {
					if (itemData == null)
						break;
					if (itemData is ChatUserlistModel) {
						var chatModel:ChatVO = ChatManager.getChatByUID((itemData as ChatUserlistModel).chatUid);
						if (chatModel != null && chatModel.isOwner(Auth.uid) && NetworkManager.isConnected == true)
							actions.push(new ContextAction(HitZoneType.DELETE, Lang.removeUser.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
					}
					break;
				}
				case TransactionTemplateRenderer: {
					if (itemData == null)
						break;
					actions.push(new ContextAction(HitZoneType.DELETE, Lang.textDelete.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
					break;
				}
				case ChannelUserListRenderer: {
					if (itemData == null)
						break;
					if ((itemData is ChatUserVO)) {
						if ((itemData as ChatUserVO).uid != Auth.uid) {
							if ((itemData as ChatUserVO).isChatOwner()) {
								
							} else if ((itemData as ChatUserVO).isChatModerator() || (itemData as ChatUserVO).userVO != null && (itemData as ChatUserVO).userVO.type == UserType.BOT) {
								if ((itemData as ChatUserVO).userVO != null && (itemData as ChatUserVO).userVO.type == UserType.BOT) {
									actions.push(new ContextAction(HitZoneType.DELETE, Lang.textRemove.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), BlockUserIcon ));
								}
								else {
									actions.push(new ContextAction(HitZoneType.MODERATOR_REMOVE, Lang.textModerator.toUpperCase(), 0x93A2AE, ModeretorRemoveIcon ));
								}
							} else {
								if (!(itemData as ChatUserVO).banned) {
									actions.push(new ContextAction(HitZoneType.MODERATOR, Lang.textModerator.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ModeratorIcon ));
									actions.push(new ContextAction(HitZoneType.KICK, Lang.textKick.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ContectDeleteIcon ));
									actions.push(new ContextAction(HitZoneType.BAN, Lang.textBan.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), KickIcon ));
								}
							}
						}
					}
					break;
				}
				case ChannelBannedUserListRenderer: {
					if (itemData == null)
						break;
					if ((itemData is ChatUserVO) && (itemData as ChatUserVO).banned)
						actions.push(new ContextAction(HitZoneType.UNBAN, Lang.removeBan.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), KickIcon ));
					break;
				}
				case ListChatItem: {
					if (itemData == null)
						break;
					if ((itemData is ChatMessageVO))
						actions.push(new ContextAction(HitZoneType.REPLY, Lang.reply.toUpperCase(), Style.color(Style.COLOR_SEPARATOR), ReplyIcon, ContextAction.TYPE_SWIPE ));
					break;
				}
			}
			return actions;
		}
	}
}