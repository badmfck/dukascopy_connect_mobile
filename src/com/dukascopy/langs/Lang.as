package com.dukascopy.langs {
	
	import com.dukascopy.connect.sys.echo.echo;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.SystemIdleMode;
	import flash.desktop.SystemTrayIcon;
	import flash.net.dns.SRVRecord;

	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class Lang {
		
		static public var S_LANG_CHANGED:Signal = new Signal("SIGNAL Lang -> S_LANG_CHANGED");
		public static const regExtValue:RegExp = /%@/;
		
		static public var barabanRequest:String = "Delayed queue request";
		
		static public var TEXT_SEARCH_CONTACT:String = "Search contact...";
		static public var TEXT_SEARCH_CHATMATE:String = "Search chatmate...";
		
		static public var CHANGE:String = "CHANGE";
		static public var CANCEL:String = "CANCEL";
		static public var complainAbuse:String = "Complain Abuse";
		static public var acceptedPayment:String = "accepted payment";
		static public var acsessToContactsDenied:String = "Dukascopy Connect has no access to your phonebook and can't display your contacts list \n\n Please go to Settings > Privacy > Contacts and set Dukascopy Connect to ON";
		static public var acsessToPhotosDenied:String = "Dukascopy Connect needs access to your photo library to save images \n\n Please go to Settings > Privacy > Photos and set Dukascopy Connect to ON";
		static public var textActivate:String = "Activate";
		static public var addInvoice:String = "Invoice";
		static public var addPuzzle:String = "Puzzle";
		static public var addPinCode:String = "Add PIN code";
		static public var addToContacts:String = "Add to Contacts";
		static public var addUserToChat:String = "Add users to chat";
		static public var addUsersToChat:String = "Add user(s) to chat";
		static public var addYourDescription:String = "Add your description...";
		static public var alertAuthorisationError:String = "Authorization error";
		static public var alertChangeChatAvatar:String = "Can't change chat avatar";
		static public var alertChangeChatTitle:String = "Can't change chat title";
		static public var alertChangeUserAvatar:String = "Can't change avatar";
		static public var alertConfirmDeleteAvatar:String = "Are you sure you want to delete chat avatar?";
		static public var alertConfirmDeleteQuestion:String = "Are you sure to delete this question?";
		static public var alertConfirmForwardMessage:String = "Are you sure you want to forward message?";
		static public var alertConfirmLeaveConversation:String = "Are you sure you want to delete this chat?";
		static public var alertConfirmNavigateToPaymentRegistration:String = "We now redirect you to a secure Dukascopy page to complete registration in Dukascopy Payments.";
		static public var alertConfirmSetPIN:String = "Do You want to save PIN code for this chat on device";
		static public var alertConformDeleteMessage:String = "Are you sure you want to delete message?";
		static public var alertErrorRemoveUserFromChat:String = "Remove user error";
		static public var alertProvideInternetConnection:String = "Please provide internet connection.";
		static public var alertSendInvitationText:String = "Unfortunately this user has no account in our system yet. Do you want to send invitation for him/her?";
		static public var alreadyAnswering:String = "Already answering";
		static public var textAnswer:String = "Answer";
		static public var applyPIN:String = "Apply PIN";
		static public var areYouSureLogout:String = "Are you sure you want to log out?";
		static public var areYouSureQuitApplication:String = "Are you sure  you want to quit application?";
		static public var areYouSureRemovePin:String = "Are You sure want to remove PIN from this chat?";
		static public var askAnyQuestions:String = "Ask any question, we will find people to answer you.\n\nPlease tap on 'Thank you I`m satisfied' ' button to those who will satisfy you with answer!";
		static public var askNewQuestion:String = "Ask new question";
		static public var askQuestions:String = "Ask your question";
		static public var backgroundImage:String = "Background image";
		static public var backgroundsGallery:String = "Backgrounds gallery";
		static public var bank_transfer:String = "BANK TRANSFER";
		static public var rmb_transfer:String = "RMB Transfer";
		static public var blockUser:String = "Block user";
		static public var blockedUsers:String = "Blocked users";
		static public var cameraError:String = "Camera error";
		static public var cameraNotSupported:String = "Camera not supported";
		static public var textSubmit:String = "SUBMIT";
		static public var cancelledInvoice:String = "cancelled invoice";
		static public var cancelledPayment:String = "cancelled payment";
		static public var cantAddUsersToChat:String = "Can't add user(s) to chat";
		static public var cantRemoveUsersFromGroupChat:String = "You can`t remove users from group chat";
		static public var cardDepositInfoText:String = "We do not charge any fee for funding via payment card, however, the commission of our partner bank in amount of 2% of the amount of transaction made in EUR, USD, GBP, and CHF will apply. If you choose to fund your account in Polish zloty, Australian dollars, Japanese yens, Russian rubles or Canadian dollars, our partner bank will charge a commission of 2.5% of the transaction amount. This commission will be charged based on the amount of your payment. Should you make a payment by the card having other base currency than EUR, USD, GBP, CHF, AUD, CAD, JPY, RUB or PLN, an additional conversion fee may apply";
		static public var pinHasBeenSent:String = "SMS with a pin code has been sent to your mobile phone number. If you did not receive it, please try one more time or let us know at support@dukascopy.bank or support chat.";
		static public var cardHasBeenBlocked:String = "Card has been blocked";
		static public var cardHasBeenIssued:String = "Card has been issued";
		static public var categoryInConnect:String = "In connect";
		static public var changeAvatar:String = "Change avatar";
		static public var chatSettingsScreenTitle:String = "Chat Settings";
		static public var checkNetworkStatus:String = 'Please check your network status';
		static public var chooseLinkToOpen:String = "Choose link to open";
		static public var close:String = "Close";
		static public var communityProfile:String = "Community Profile";
		static public var section911My:String = "My 911 statistics";
		static public var complete:String = "Complete";
		static public var confirm:String = "Confirm";
		static public var confirmMoneyTransfer:String = "Confirm Transfer";
		static public var contactWasAdded:String = " has been added";
		static public var textMessage:String = "Message";
		static public var created:String = "CREATED";
		static public var credit_card:String = "CREDIT CARD";
		static public var cryptedMessage:String = "Crypted message.";
		static public var currency:String = "Currency";
		static public var customerNumber:String = "Customer Number";
		static public var deleteChat:String = "Delete chat";
		static public var deletedMessage:String = "Deleted message.";
		static public var cleanedMessage:String = "Cleaned message.";
		static public var done:String = "Done";
		static public var dpCreateWallet:String = "Create Wallet";
		static public var dpWithdrawal:String = "Withdrawal";
		static public var dukascopyPayments:String = "Payments";
		static public var enterDestinationPhone:String = "Destination phone";
		static public var enterDestinationUser:String = "Destination user";
		static public var editQuestions:String = "Edit your question";
		static public var email:String = "E-mail";
		static public var destinationType:String = "Destination Type";
		static public var enterEmail:String = "Enter your email";
		static public var enterName:String = "Enter name";
		static public var enterPassword:String = "Enter password";
		static public var enterPhoneNumber:String = "Enter phone number";
		static public var enterPinText:String = "Enter security pin code, same as your chat mate.";
		static public var enterQuestion:String = "Enter question";
		static public var errorAnswersLoading:String = "Failed to load answers";
		static public var exists:String = "Already exists";
		static public var fileLoadError:String = "File load error";
		static public var fileLoadedNotificationTitle:String = "File loaded";
		static public var fileSendingError:String = "File sending error, please resend it again.";
		static public var firstName:String = "First Name";
		static public var forgotPassword:String = "Forgot password";
		static public var galleryError:String = "Select from gallery error";
		static public var galleryNotSupported:String = "Gallery not supported";
		static public var holdToRecord:String = "Hold to record";
		static public var howMayIHelpYou:String = "How may I help you?";
		static public var iAgree:String = "I agree";
		static public var information:String = "Information";
		static public var provisionallyBlockedDesc:String = "For security reasons your card has been provisionally blocked by the card issuer. To clarify a suspicious transaction carried out using your card please contact card issuer's customer support service by calling at +41 91 800 41 41.";
		static public var instructionsToEmail:String = "Send instructions to e-mail";
		static public var invitationSmsText_appleWithLink:String = "Hi! I am using Dukascopy Connect application. For more information: ";
		static public var invitationSmsTextq_apple:String = "Hi! I am using Dukascopy Connect application. Download it from Play Market or App Store to join me.";
		static public var isInAnotherCall:String = " is in another call";
		static public var issueNewPrepaidCard:String = "Issue new prepaid card";
		static public var leaveChat:String = "Exit chat";
		static public var loadHistory:String = "LOAD HISTORY";
		static public var loading:String = "Loading";
		static public var logout:String = 'Log out';
		static public var makePhoto:String = "Make Photo";
		static public var minAgo:String = "min ago";
		static public var daysAgo:String = "days ago";
		static public var missedCall:String = "Missed call";
		static public var new_deposit:String = "NEW DEPOSIT";
		static public var no:String = "NO";
		static public var noConnection:String = "No connection";
		static public var noInternetConnection:String = "Server is not reachable. Please try again later.";
		static public var noText:String = "no text";
		static public var off:String = "of";
		static public var textValid:String = "Valid";
		static public var textAvailable:String = "Available";
		static public var openAccount:String = "Open Account";
		static public var openAccountAndGetRewards:String = "Open account - get rewards";
		static public var password:String = "Password";
		static public var passwordMustBeChanged:String = "Password must be changed";
		static public var paymentSupportTitle:String = "Payments help";
		static public var paymentsPassword:String = "Payments password";
		static public var permissionInfo:String = "Please Allow Access";
		static public var photoGallery:String = "Photo Gallery";
		static public var pleaseEnterAmount:String = "Please enter amount";
		static public var pleaseEnterSwift:String = "Please enter BIC/SWIFT Code";
		static public var pleaseEnterPassword:String = "Enter your Bank password";
		static public var resendMessage:String = "Resend message";
		static public var pressRefreshButton:String = "After registration please press refresh button in the top right corner.";
		static public var provideMandatoryInformation:String = "Dear client, now is time to provide some mandatory information in order to continue cooperation with Dukascopy Payments and further improve our services, this shall not take more than 5 minutes";
		static public var purposeOfPayment:String = "Purpose of payment:";
		static public var question:String = "Question";
		static public var textAnswers:String = "Answers";
		static public var questionAuthorAbuseNum:String = "Abuse";
		static public var questionAuthorSpamNum:String = "Spam";
		static public var questionInfoButton:String = "You may get up to 1 DUK+ for proper answer of the question above. Read rules here...";
		static public var questionNotFound:String = "Question loading...";
		static public var questionToManyAnswers:String = "No free slots.";
		static public var questionResolved:String = "Question closed.";
		static public var questionRulesDialogText:String = "Dukascopy 911 is a place where you can ask and answer any questions.\nThe number of questions you can ask is unlimited. Every day Dukascopy will sponsor 3 of your questions.\nThe number of questions you can answer is unlimited.\nThe amount Dukascopy will pay you for serving a single person is limited by 1 sponsored answer. To earn more you have to answer other people.\nDukascopy will pay you based on your Dukascopy 911 rating (0.1 DUK+ if your rating is 1 and 1 DUK+ if your rating is 10) in case your answer is marked as satisfactory. Marking is at the full discretion of the person who asks the question.\nYour Dukascopy 911 rating is based on periodical review of your activity by Dukascopy. Dukascopy will review your account when one or more of following conditions are met a) Your answers have received 50 satisfactory marks (20 for the initial review), b) Dukascopy has sponsored 50 of your questions.\nInitially your rating is set as 5. Based on your contributions, service statistics and input to the development of the service Dukascopy will adjust your rating.\nDuring the review process, the payouts are paused (not processed). Payouts will be completed after the review process is finished and new rating is set.\nYou can leave extra tips for your questions. Extra tips amount is limited by 100 Euro. Dukascopy reserves the right to reduce your rating or disable access to the service if you do not pay extra tips promised by you.\nBy clicking on the information icon, you are able to see information about the other party, block his account, report him for abuse or spam and pay tips.\nYou are able to update your question only before you receive the first answer. You may delete your question any time.\nIn the event of “spamming” or “abuse”, we will monitor your activity and take measures.\nPayouts to Dukascopy Payments account are done during working hours with a reasonable delay (expected within the next business day).\nDukascopy reserves the right to disable payouts as well as temporarily or permanently suspend you from using the 911 service.\n\n";
		static public var questionSatisfied:String = "<u>Thank You! I'm satisfied</u>";
		static public var dukCharts:String = "DUK+ Charts";
		static public var releaseToCancel:String = "Release to cancel";
		static public var questionsResolved:String = "Log";
		static public var refreshAccount:String = "Some error occurred. Please refresh account!";
		static public var releaseToSend:String = "Release to send";
		static public var textRemove:String = "Remove";
		static public var removePinCode:String = "Remove PIN code";
		static public var repostAbuse:String = "Сomplaints & Information";
		static public var requestCall:String = "Request call";
		static public var resendCode:String = "Resend code";
		static public var reset:String = "Resend";
		static public var retryPayment:String = "Retry Payment";
		static public var textRules:String = "Rules";
		static public var saveChanges:String = "Save changes";
		static public var saving:String = "Saving...";
		static public var secondName:String = "Second Name";
		static public var selectCurrency:String = "Select currency";
		static public var selectCardType:String = "Select card type";
		static public var selectDelivery:String = "Select delivery";
		static public var selectFromGallery:String = "Select from Gallery";
		static public var selectPhone:String = "SELECT PHONE";
		static public var selectUsers:String = "Select users:";
		static public var selectUser:String = "Select user:";
		static public var sendMoney:String = "Send Money";
		static public var sendMoneyTo:String = "Send @1 to @2";
		static public var sendInvoice:String = "Send Invoice";
		static public var sendInvoiceTo:String = " send invoice to ";
		static public var sendVoice:String = "Send Voice";
		static public var sendYouInvoice:String = "send you invoice:";
		static public var setLanguage:String = "Set language";
		static public var setPin:String = "Set PIN";
		static public var setSecurityMode:String = "Set security mode";
		static public var settings:String = "Settings";
		static public var textSince:String = "since";
		static public var smsCodeSent:String = "Verification code has been sent to you via SMS";
		static public var somethingWentWrong:String = "Something went wrong.";
		static public var failedToRecognizeMRZ:String = "Failed to recognize MRZ.";
		static public var soundsOnCall:String = "Sounds on call";
		static public var socialOnCall:String = "Social";
		static public var showRating:String = "Show rating";
		static public var soundsOnMessages:String = "Sounds on messages";
		static public var spamButtontext:String = "Complain Spam";
		static public var startChat:String = "Chat";
		static public var startChatWith:String = "Start chat with:";
		static public var startVideoChat:String = "Call to";
		static public var stop:String = "STOP";
		static public var stopChat:String = "Stop this chat";
		static public var success:String = "Success";
		static public var systemMessage:String = "system message";
		static public var sentFile:String = "File sent";
		static public var sentPuzzle:String = "Puzzle sent";
		static public var sentImage:String = "Image sent";
		static public var stikerSent:String = "Sticker sent";
		static public var sentInvoice:String = "Invoice sent";
		static public var sentVoiceMessage:String = "Voice record sent";
		static public var textAccept:String = "Accept";
		static public var textAlert:String = "Alert";
		static public var textAll:String = "All";
		static public var textAmount:String = "Amount";
		static public var textSwift:String = "BIC/SWIFT Code";
		static public var textQuantity:String = "Quantity";
		static public var textBicSwift:String = "BIC/SWIFT Code";
		static public var textCode:String = "Code";
		static public var textAttention:String = "Attention";
		static public var textBalance:String = "Balance";
		static public var textBlocked:String = "Blocked";
		static public var textCall:String = "Call";
		static public var textCalls:String = "Calls";
		static public var textCancel:String = "Cancel";
		static public var textChats:String = "Chats";
		static public var textClose:String = "Close";
		static public var textMenu:String = "Menu";
		static public var textCommission:String = "Commission";
		static public var textConfirm:String = "Confirm";
		static public var textConnect:String = "Connect";
		static public var textContacts:String = "Contacts";
		static public var textCurrency:String = "Currency";
		static public var textFullNameInvoice:String = "Your full name will be visible in the invoice";
		static public var textCardType:String = "Card type";
		static public var textCardDelivery:String = "Delivery";
		static public var textDeliveryStandard:String = "Standard (Up to 4 weeks)";
		static public var textDeliveryExpress:String = "Express (Up to 2 weeks)";
		static public var textAccount:String = "Account";
		static public var textSubAccount:String = "Sub-Account";
		static public var textDelete:String = "Delete";
		static public var textDescription:String = "Description";
		static public var textDesktop:String = "Desktop";
		static public var textEdit:String = "Edit";
		static public var textEmpty:String = "Empty";
		static public var textExit:String = "Exit";
		static public var textFile:String = "File";
		static public var textForward:String = "Forward";
		static public var textFriends:String = "Friends";
		static public var textHelp:String = "Help";
		static public var textIncoming:String = "Incoming";
		static public var textInvite:String = "Invite";
		static public var textInvited:String = "Invited";
		static public var textMine:String = "Mine";
		static public var textMissed:String = "Missed";
		static public var textMobile:String = "Mobile";
		static public var textName:String = "Name";
		static public var textNo:String = "No";
		static public var textNotifications:String = "Notifications";
		static public var textIncognito:String = "Secret";
		static public var textOffline:String = "Offline";
		static public var textOk:String = "Ok";
		static public var textOnline:String = "Online";
		static public var textOpen:String = "Open";
		static public var textOther:String = "Other";
		static public var textOutgoing:String = "Outgoing";
		static public var textOwner:String = "Owner";
		static public var textPay:String = "Pay";
		static public var textPayments:String = "Payments";
		static public var textPhone:String = "Phone";
		static public var textQuit:String = "Quit";
		static public var textRead:String = "Read";
		static public var textSave:String = "Save";
		static public var textSaving:String = "Saving";
		static public var textSeconds:String = "Seconds";
		static public var textBack:String = "Back";
		static public var textVerify:String = "Verify";
		static public var textSent:String = "Sent";
		static public var textSend:String = "Send";
		static public var textSettings:String = "Settings";
		static public var textSomeone:String = "Someone";
		static public var textSuccess:String = "Success";
		static public var textError:String = "Error";
		static public var textSupport:String = "Support";
		static public var textSurname:String = "Surname";
		static public var textToday:String = "Today";
		static public var textUsers:String = "Users";
		static public var textWarning:String = "Warning";
		static public var textWeb:String = "Web";
		static public var textYes:String = "Yes";
		static public var textYesterday:String = "Yesterday";
		static public var textTips:String = "TIPS";
		static public var title_911:String = "911";
		static public var typePhoneNumber:String = "Please type phone number to start chat.";
		static public var unblockButtontext:String = "Unblock user";
		static public var unblockUser:String = "Unblock User";
		static public var unknownName:String = "Unknown Name";
		static public var unknownUser:String = "Unknown user";
		static public var unsupportedOnDevice:String = "Unsupported device";
		static public var userHasDisconnected:String = "has disconnected";
		static public var userHasNoPhoneForPayment:String = "There is no phone number indicated for this user. Would you like to proceed to Dukascopy payments?";
		static public var userInvitedText:String = "You sent invitation to";
		static public var userOffline:String = "User offline";
		static public var usersInChat:String = "Users in chat";
		static public var usersList:String = "Users list";
		static public var verificationCodeVoiceCall:String = "We are calling you on +";
		static public var videoAgreementBank:String = "IMPORTANT\n\nBy clicking the start button above I give my permission to Dukascopy Bank SA to conduct video identification and to perform audio/video recording.";
		static public var videoAgreementEuropa:String = "IMPORTANT\n\nBy clicking the start button above I give my permission to Dukascopy Europe to conduct video identification and to perform audio/video recording.";
		static public var videoAgreementPay:String = "IMPORTANT\n\nBy clicking the start button above I give my permission to Dukascopy Payments to conduct video identification and to perform audio/video recording.";
		static public var videoCallEnded:String = "Video call ended";
		static public var videoCallStarted:String = "Video call started";
		static public var voiceMessage:String = "Voice message";
		static public var web:String = "Web";
		static public var youAcceptedPayment:String = "You accepted payment";
		static public var youAlreadyHaveActiveCall:String = "You already have active call";
		static public var youCanRequestCall:String = "You can request call in ";
		static public var youCancelledInvoice:String = "You cancelled invoice";
		static public var youCancelledPayment:String = "You cancelled payment";
		static public var youDontHaveCalls:String = "You don`t have calls...";
		static public var youSentInvoiceTo:String = "You sent invoice to";
		static public var decrypting:String = "Decrypting";
		static public var textContactsNull:String = "You don`t have contacts...";
		static public var textChatsNull:String = "You don`t have chats...";
		static public var btnSlideshow:String = "SLIDESHOW";
		static public var btnLow:String = "LOW";
		static public var btnMedium:String = "MEDIUM";
		static public var btnHigh:String = "HIGH";
		static public var videoQuality:String = "VIDEO QUALITY";
		static public var useTouchIDPayments:String = "Use TouchID?";
		static public var enterPIN:String = "Enter PIN";
		static public var enterSecurityCode:String = "Enter Security Code";
		static public var repeatSecurityCode:String = "Repeat Security Code";
		static public var startNewChat:String = "Start New Chat";
		static public var typePhone:String = "Type phone";
		static public var textCopy:String = "Copy";
		static public var textVersion:String = "Version ";
		static public var logOut:String = "LOG OUT";
		static public var textChoose:String = "Choose";
		static public var noLabbel:String = "no label";
		static public var alreadyAnswered:String = "already answered";
		//"already answering " + itemData.answersCount + " of " + itemData.answersMaxCount
		static public var alreadyAnsweringText:String = "already answering %@ of %@";
		static public var answeringText:String = "answering %@ of %@";
		static public var openedChat:String = "OPENED CHAT";
		static public var typeMessage:String = "Type message...";
		static public var alertSengMoney:String = "You are not yet registered in Dukascopy Payments. Would you like register now?";
		static public var alertCantOpenPayment:String = "Can`t open payments without internet connection";
		/// using  like this ("month_"+i)
		static public var month_0:String = "January";
		static public var month_1:String = "February";
		static public var month_2:String = "March";
		static public var month_3:String = "April";
		static public var month_4:String = "May";
		static public var month_5:String = "June";
		static public var month_6:String = "July";
		static public var month_7:String = "August";
		static public var month_8:String = "September";
		static public var month_9:String = "October";
		static public var month_10:String = "November";
		static public var month_11:String = "December";
		//
		static public var touchIdPressCansel:String = 'Press "Cancel" to login by using password.';
		static public var touchIdPaymentAuth:String = "payment Auth by phone";
		static public var sendAInvoice:String = "Sent a invoice";
		static public var chatBeenStopped:String = "This chat has been stopped";
		static public var youBeenBlocked:String = "You have been blocked";
		static public var yourActivConsidSpam:String = "Your activity considered as spam";
		static public var yourActivConsidAbuse:String = "Your activity considered as an abuse";
		static public var yourAnswerISNTCorrect:String = "Thank you, but your answer isn't fully correct for me.";
		static public var yourAnswerFullySatisfid:String = "Thank you, I'm fully satisfied by your answer, you will receive up to 1 DUK+ from Dukascopy.";
		static public var yourAnswerFullySatisfidByUser:String = "Thank you, I'm fully satisfied by your answer.";
		static public var yourAnswerAlreadyCorrect:String = "Thank you, but I already got correct answer that fully satisfied me.";
		static public var serverError:String = "Server Error: ";
		static public var textAtention:String = "Atention";
		static public var alertReachedLimit:String = "You have reached limit, you can pay from your account!";
		static public var latestAnswer:String = "Latest Answers";
		static public var answerAreEmpty:String = "Answers are empty.";
		static public var emptyData:String = "Empty data";
		static public var alertUpdateQuestion:String = "You can't update question, it already has an active answers.";
		static public var notNow:String = "not now";
		static public var pendingPayment:String = "Pending Payment";
		static public var uHavePendingPayment:String = " You have pending payments";
		static public var showPayment:String = "show payment";
		static public var registerPaymentSystem:String = ", please register in payment system";
		static public var startChatByPhoneDataNULL:String = 'This contact doesn`t have Dukascopy Connect yet. Would you like to invite +%@ ?';
		static public var inProcess:String = "In process";
		static public var waiting:String = "Waiting";
		static public var chatWasFinished:String = "Chat session was finished";
		static public var sessionWasCanceledByTimeout:String = "Chat session was canceled by timeout";
		static public var pleaseTryLater:String = "Please try later";
		static public var wrongOrDamagedUser:String = "Wrong or damaged user. Please reinstall application and relogin";
		static public var noProfileData:String = " no profile data";
		static public var noAuthKey:String = " no auth key";
		static public var codeProtection:String = "Code Protection:";
		static public var notSet:String = "Not set";
		static public var textEnabled:String = "Enabled";
		static public var textSearch:String = "Search";
		public static var textWrongCode:String = "Please enter 6 digit code first.";
		public static var textType:String = "Type";
		public static var textCodeSecured:String = "Code secured";
		public static var textStatus:String = "Status";
		public static var textDate:String = "Date";
		static public var textChannels:String = "Channels";
		static public var textSelectChannels:String = "Select Channels";
		static public var selectCountry:String = "SELECT COUNTRY";
		static public var selectContact:String = "SELECT CONTACT";
		static public var selectChatmate:String = "SELECT CHATMATE";
		static public var changePassword:String = "Change password";
		static public var emergencyMoreInfoButton:String = "Ask and answer questions!\nGet money! Read rules.";

		static public var alertChatScreenBlock:String = "Are You sure to Block this user?";
		static public var alertChatScreenAbuse:String = "Are You sure, You want to complain abuse?";
		static public var alertChatScreenSpam:String = "Spam report is sent, chat is closed";
		public static var alertWrongCode:String = "Wrong code";

		static public var chatClosed:String = "Chat is closed";
		public static var enterVerifyCode:String = "Enter your 6 digit code...";
		public static var enterYourPhone:String = "Enter your phone";
		public static var emptyLabel:String = "empty label";
		public static var sendBack:String = "Send Back";
		static public var alertServerUnderMaintenance:String = "Server under maintenance, please retry a bit later.";
		
		static public var textAddFriendsFromYourAdressBook:String = "Add friends from your adress book to instantly messaging with them";
		static public var textEasyWayToFindYourFriends:String = "EASY WAY TO FIND YOUR FRIENDS";
		static public var textYouCanChangeYourChoice:String = "You can change your choice in system settings";
		static public var textStayInTouch:String = "STAY IN TOUCH";
		static public var textGetNotified:String = "Get notified of new messages, calls, money transfers";
		static public var rtoNextStep:String="What's now?"
		
		static public var confirmPassword:String = "Confirm password";
		static public var connecting:String = "Connecting...";

		static public var fillAllFields:String = "Please fill in all fields";

		static public var login:String = "Log in";
		static public var registrate:String = "Register";
		static public var passNotMatch:String = "Passwords do not match";

		//// PAYMENTS KEYS
		public static var TEXT_VIRTUAL:String = "virtual";
		public static var TEXT_PLASTIC:String = "plastic";
		public static var TEXT_DEACTIVATED:String = "deactivated";
		public static var TEXT_ALL_STATUSES:String = "All Statuses";
		static public var TEXT_MONEY_TRANSFERED:String = "Money transfered";
		static public var TEXT_EMPTY_RESPOND:String = "Empty respond from server.";
		public static var TEXT_PASS_INVALID:String = "Password is invalid";
		public static var TEXT_BLOCKED_ACCOUNT:String = "Acount is blocked";
		public static var TEXT_ACCOUNT_NOT_APPROVED:String = "Account is not approved yet";
		public static var TEXT_SERVER_CANNT_RESPOND:String = "Server cannot respond";
		public static var TEXT_VERIFY_YOUR_CARD:String = "Verify your card";
		static public var TEXT_HOME:String = "Home";
		static public var TEXT_ADD_DESCRIPTION:String = "Add your description...";
		static public var TEXT_TRANSACTIONS:String = "Transactions:";
		static public var TEXT_WALLET_DETAILS:String = "Wallet Details";
		static public var TEXT_WITHDRAWAL:String = "Withdrawal";
		static public var TEXT_WALLET:String = "wallet";
		static public var TEXT_REPEAT:String = "Repeat";
		static public var TEXT_PENDING:String = "Pending";
		static public var TEXT_COMPLETED:String = "Completed";
		static public var TEXT_CANCELLED:String = "Cancelled";
		static public var TEXT_FOR_ALL_DATES:String = "For All Dates";
		static public var TEXT_DEPOSIT:String = "Deposit";
		static public var TEXT_DEPOSIT_TYPE:String = "Deposit type";
		static public var TEXT_INTERNAL_TRANSFER:String = "Internal transfer";
		static public var TEXT_EXCHANGE:String = "Exchange";
		static public var TEXT_PREPAID_CARD:String = "Prepaid Card"/*"Prepaid Card Withdrawal"*/;
		static public var TEXT_SEARCH_COUNTRY:String = "Search country...";
		static public var TEXT_SELECT_ACCOUNT:String = "Select account";
		static public var TEXT_SELECT_CARD:String = "Select card";
		static public var TXT_SHOW_PASS:String = "Show password characters";
		static public var TEXT_LACALISATION_DESCRIPTION_SC:String = "Transfers protected by code can only be finalised if the recipient enters the code correctly. Sender provides security code to recipient by other means (telephone call, meeting in person, chats, etc)."
		static public var TEXT_WITHDRAWAL_TYPE:String = "Withdrawal Type";
		static public var TEXT_INPUT_SWIFT_TYPE:String = "SWIFT";
		static public var TEXT_PREPAID_CARD_CANNT_ISSUED:String = "Prepaid cards cannot be issued. Supported currencies: EUR,USD,GBP,AUD,CAD";
		static public var TEXT_PREPAID_CARD_NO_ACTIVE:String = "You do not have active prepaid cards. ";
		static public var TEXT_PREPAID_CARD_ISSUED_NEW:String = "Issue New Prepaid Card ";
		static public var TEXT_MY_CARDS:String = "My Cards";
		static public var TEXT_DUKASCOPY_TRADING:String = "Dukascopy Trading Account";
		static public var TEXT_LINKED_CARDS:String = "Linked Cards";
		static public var TEXT_BANK_NEWS:String = "Bank News";
		static public var TEXT_LINKED:String = "Linked";
		static public var TEXT_LINK_CARDS:String = "Link Card";
		static public var TEXT_TOUCH_ID:String = "Touch ID";
		static public var TEXT_FACE_ID:String = "Face ID";
		static public var TEXT_FINGERPRINT:String = "Fingerprint";
		static public var TEXT_3D_SECURE:String = "3D Secure";
		static public var TEXT_DUKASCOPY_CARD:String = "Dukascopy Card";
		static public var TEXT_DUKASCOPY_CARDS:String = "Dukascopy Cards";
		static public var TEXT_DEBIT_ACCOUNT:String = "Debit Account";
		static public var TEXT_CREDIT_ACCOUNT:String = "Credit Account";
		static public var TEXT_DEBIT_WALLET:String = "Debit wallet";
		static public var TEXT_PREPAID_CARD_SELECT:String = "Please select prepaid card";
		static public var TEXT_LINKED_CARD_SELECT:String = "Please select linked card";
		static public var TEXT_ENTER_SWIFT:String = "Enter SWIFT / BIC code";
		static public var TEXT_PLS_VERIFY_YOUR_CARD:String = "Please verify your card.";
		static public var TEXT_CHOOSE_FILL_FIELDS:String = "Choose and fill all fields";
		static public var TEXT_INAVLID_DECIMAL_AMOUNT:String = "Invalid decimal amount for selected currency";
		static public var TEXT_MONEY_TRANSFERRED:String = "Money Transferred";
		static public var TEXT_CARD_HAS_BEEN_ADDED:String = "Your card has been added succesefully.";
		static public var TEXT_PROBLEM_PROCESSING_YOUR_CARD:String = "There was a problem processing your card.";
		static public var TEXT_CARD_PENDING:String = "Card is Pending.";
		static public var TEXT_CARD_REJECTED:String = "Card Rejected.";
		static public var TEXT_YOUR_CARD_REJECTED:String = "Your card has been rejected.";
		static public var TEXT_CARD_CURRENTLY_ADDITIONAL_VERIFICATION:String = "Your card is currently undergoing additional verification by Dukascopy.";
		static public var TEXT_TRANSACTION_SUCCESSFULLY_COMPLETED:String = "Transaction successfully completed.";
		static public var TEXT_CARD_NOT_VERIFIED:String = "Card not verified.";
		static public var TEXT_NO_ACTIVE_YOUR_CARDS:String = "You do not have active cards in %@.";
		static public var TEXT_PREPAID_CARD_CANNT_ISSUED_DINAMIC:String = "Prepaid cards cannot be issued in %@. Supported currencies:\n";
		static public var TEXT_ALERT_VERIFY:String = "1. We will make a small charge to your card.\n2. Check your card statement for the charge or the 5 digit code associated with the charge.\n3. Verify the card by entering charged amount or the 5 digit code. The charge will be refunded to your account.";
		static public var TEXT_EDIT_DESCRIPTION:String = "Edit description";
		static public var TEXT_ENTER_WALLET_NUMBER:String = "Enter wallet number";
		static public var TEXT_ENTER_WALLET_IBAN_NUMBER:String = "Enter IBAN number CH****";
		static public var TEXT_SELECT_CODE_ENTER_PHONE:String = "Select your country code and enter phone number";
		static public var TEXT_DESTINATION_WALLET:String = "Destination wallet";
		static public var TEXT_INVALID_DESTINATION_WALLET_NUMBER:String = "Invalid destination wallet number";
		static public var TEXT_DESTINATION_PHONE_NUMBER:String = "Please enter destination phone number";
		static public var TEXT_COMPOSE_MESSAGE:String = "Compose message";
		static public var TEXT_SEARCH_ICON:String = "Search Icon";
		static public var TEXT_WALLET_NUMBER:String = "Wallet number";
		static public var TEXT_CLIPBOARD:String = "Clipboard";
		static public var TEXT_CARDS:String = "Cards";
		static public var TEXT_SEND_MONEY:String = "SEND MONEY";
		static public var TEXT_CONNECTION_PROBLEM:String = "Connection problem";
		static public var TEXT_KYC_INFORMATION:String = "KYC information is already provided";
		static public var TEXT_PTO_CHECK_PROVIDED:String = "Check provided values and contact our support team";
		static public var TEXT_RTO_FILL_HALF:String = "Please fill half filled form first!";
		static public var TEXT_RTO_FILL_FROM:String = "Please fill form first!";
		static public var TEXT_SELECT_WALLETS_BEFORE_CURRENCY:String = "Please select wallets before currency";
		public static var TEXT_SELECT_TYPE:String = "Select type";
		public static var TEXT_CREATE_CARD:String = "Create Card";
		public static var TEXT_SELECT_STATUS:String = "Select status";
		public static var TEXT_WALLET_CREATED:String = "Wallet has been created";
		public static var TEXT_TERMS_CONDITIONS:String = "Terms & Conditions";
		public static var TEXT_PAY_WITH:String = "Pay with";
		public static var TEXT_CARD_TYPE:String = "Card Type";
		public static var TEXT_HISTORY_VERIFY_ADDRESES:String = "Please verify your address where the card will be sent to:";
		public static var TEXT_HISTORY_CONTACT:String = "If your address has changed, please write to";
		public static var TEXT_HISTORY_CONTACT_EMAIL:String = "support.pay@dukascopy.com";
		public static var TEXT_HISTORY_CONTACT_PART_TWO:String = " for further guidelines";
		public static var TEXT_HISTORY:String = "history";
		public static var TEXT_CARD_TRANSACTIONS:String = "Card Transactions";
		public static var TEXT_NO_TRANSACTIONS:String = "No transactions";
		public static var TEXT_NO_CERRENT_CARDS:String = "No %@ cards";
		public static var TEXT_WITHDRAWAL_FROM_CART:String = "WITHDRAWAL FROM CART";
		public static var TEXT_UNLOAD_CART:String = "UNLOAD CARD";
		public static var TEXT_INVESTMENT:String = "INVESTMENT";
		public static var cardOperation:String = "Card operation";
		public static var TEXT_INVEST:String = "INVEST";
		public static var TEXT_MERCHANT_TRANSFER:String = "Merchant Transfer";
		public static var fundsReceived:String = "Funds received:";
		public static var fundsPL:String = "Profit/Loss:";
		public static var fundsInvested:String = "Funds invested:";

		public static var noCardsPlastic:String = "No Plastic cards";
		public static var noCardsVirtual:String = "No Virtual cards";
		public static var noCardsMYcard:String = "No My Cards";
		public static var noCardsDeactivated:String = "No Deactivated cards";

		public static var TEXT_ISSUE_NEW_CARD:String = "Issue new card";
		public static var TEXT_PHONE_OR_WALLET:String = "Phone or wallet number";
		static public var TEXT_VIRTUAL_CARD:String = "virtual card";
		static public var TEXT_PLASTIC_CARD:String = "plastic card";
		public static var TEXT_ALL_TYPES:String = "All Types";
		public static var TEXT_OUTGOING_TRANSFER:String = "Outgoing Transfer";
		public static var TEXT_INCOMING_TRANSFER:String = "Incoming Transfer";
		public static var TEXT_PREPAID_CARD_ORDER:String = "Prepaid Card Order";
		public static var TEXT_PRESCREEN_PAYMENT:String = "Make it simple & secure with Swiss Bank Group";
		public static var TEXT_SECURITY_CODE:String = "Security code";
		public static var TEXT_CARD_DETAILS_BLOCK:String = "Card reactivation is not possible. You will have to order a new card.";
		public static var TEXT_ENTER_CURR_PASS:String = "Enter current password";
		public static var TEXT_ENTER_NEW_PASS:String = "Enter new password";
		public static var TEXT_REPEAT_NEW_PASS:String = "Repeat new password";
		public static var TEXT_MARKER_1:String = "At least 6 characters";
		public static var TEXT_MARKER_2:String = "At least 4 unique characters";
		public static var TEXT_MARKER_3:String = "Password can't be entirely numeric";

		static public var ALERT_ENTER_REPEAT_SC:String = "Please enter and repeat Security Code";
		static public var ALERT_DONT_MATCH_SC:String = "Codes do not match";
		static public var ALERT_ENTER_SC:String = "Please enter Security Code";
		static public var ALERT_REPEAT_SC:String = "Please repeat Security Code";
		static public var ALERT_FORGOT_PASSWORD:String = "Please use web version of Dukascopy Payments to restore the password or call +371 67 399 001";
		
		static public var ALERT_FORGOT_PASSWORD_EUROPE:String = "Please use web version of Dukascopy Payments to restore the password or call +371 67 399 001";
		static public var ALERT_FORGOT_PASSWORD_SWISS:String = "Please use web version of Dukascopy Payments to restore the password or call +41 227 994 859";
		static public var BANK_PHONE_SWISS:String = "0041227994859";
		static public var BANK_PHONE_EUROPE:String = "0037167399001";
		
		public static var ALERT_ARE_YOU_SURE:String = "Are you sure ?";
		
		public static var ALERT_EXCHANGE_SUCCESS:String = "You have successfully exchanged %@ %@ for %@ %@";
		public static var ALERT_EXCHANGE_PENDING:String = "Your exchange request of %@ %@ has been received.";
		public static var ALERT_CONFIRM_DELETE_CARD:String = "Are you sure you want to delete this card?";
		static public var ALERT_INTERNAL_TRANSFER_INSTRUMENT:String = "This operation requires currency exchange.\nThe current %@ exchange rate is %@ \nYou will be charged %@\n Shown rates are indicative only.";
		public static var ALERT_CREATE_CARD_COMMISSION:String = "Please wait, commission is not loaded yet!";
		public static var ALERT_CREATE_CARD_SELECT_PAY:String = "Please select pay with account";
		public static var wouldYouTryAgain:String = "Would you like to try again?";

		static public var WALLET_DETAILS_UPDATE:String/*walletDetailsUpdate*/ = "Can't change description, please try again later";
		static public var PASS_VERIFICATION_BLOCKED:String = "Password verification is blocked.Too many failed attempts during short period of time. Try again later.";
		static public var pleaseSelectCurrency:String = "Please select currency";
		static public var pleaseSelectCardType:String = "Please select card type";

		static public var BTN_BANK_TRANSFER:String = "Bank transfer";
		static public var BTN_BANK_TRANSFER_LOW_COST:String = "Bank transfer low cost";
		static public var BTN_CURRENCY_CLOUD:String = "Currency cloud";
		static public var BTN_CREATE:String = "Create";
		static public var BTN_REQUEST_CODE:String = "Request code";
		static public var BTN_REPEAT_CODE:String = "Repeat Code";
		static public var BTN_ENTER_CODE:String = "Enter Code";
		static public var BTN_NEXT_STEP:String = "Next step";
		static public var BTN_CONTINUE:String = "CONTINUE";
		static public var BTN_ADD_NEW_CARD:String = "ADD NEW CARD";
		static public var BTN_VERIFY_CARD:String = "Verify Card ...";
		static public var BTN_CARD_DETAILS:String = "Card Details";
		public static var BTN_CHECK_PIN:String = "CHECK PIN";
		public static var BTN_VIEW_TRANSACTIONS:String = "VIEW TRANSACTIONS";

		public static var moreAboutRules:String = "more about rules";
		static public var questionInfoDukascopy:String = 'Does this answer cost up to 1 DUK+?\nIf yes, Dukascopy will pay.';
		static public var questionInfoUser:String = 'Does this answer cost up to 1 DUK+?\nIf yes, You will pay.';
		static public var sending:String = "Sending...";
		static public var forwardMessage:String = "Forward message";
		static public var forwardedMessage:String = "Forwarded message";
		static public var forwardMessageScreenTitle:String = "Forward to:";
		static public var addNewContact:String = "Add new contact";
		static public var contactFound:String = "We found the contact to start a chat:";
		static public var userAlreadyInContacts:String = "This user already in your Contacts";
		static public var nameNotSet:String = "Name not set";
		static public var saveToPhone:String = "Save to phone";
		static public var noName:String = "No name";
		static public var savedToPhone:String = "Saved to phone";
		static public var startChatByPhoneNumber:String = "New chat with phone number";

		//New
		static public var textNone:String = "None";
		static public var aboutChannel:String = "About channel";
		static public var inChat:String = "In chat";
		static public var channelSettings:String = "Channel Settings";
		static public var textBanned:String = "Banned";
		static public var textModerator:String = "Moderator";
		static public var textBan:String = "Ban";
		static public var failedUpdateChannelInfo:String = "Failed to update channel info";
		static public var textModerators:String = "Moderators";
		static public var textMode:String = "Mode";
		static public var providePermission:String = "Please accept permission request";

		static public var selectImage:String = "Select image";
		static public var channelImage:String = "Channel image";
		static public var coverImage:String = "Cover image";
		static public var failedUpdateChannelTitle:String = "Failed to set new channel title";
		static public var textHour:String = "Hour";
		static public var textDay:String = "Day";
		static public var textMonth:String = "Month";
		static public var textPermanent:String = "Permanent";
		static public var wantMakeUserModerator:String = "You want to make that member a moderator?";
		static public var wantKickUser:String = "You want to kick that member from channel?";
		static public var textKick:String = "Kick";
		static public var reasonForBan:String = "Reason for ban";
		static public var wantRemoveUserModerator:String = "Are you sure you want to remove this user from moderators";
		static public var failedAddModerator:String = "Failed to add moderator";
		static public var failedRemoveModerator:String = "Failed to remove moderator";
		static public var removeModerator:String = "Remove moderator";
		
		//NEW NEW
		static public var bannedTill:String = "Banned till: ";
		static public var permanentBan:String = "Permanent ban";
		static public var removeBan:String = "Remove ban";
		static public var textUnban:String = "Unban";
		static public var youPromotedToModerator:String = "You are promoted to become a moderator in the channel";
		static public var youNotLongerModerator:String = "You have lost moderator's privilegies in the channel";
		static public var youKickedFromChannel:String = "You have been removed from channel";
		static public var textReason:String = "Reason:";
		static public var whoBanned:String = "Who banned:";
		static public var textHours:String = "hours";
		static public var textUntil:String = "until";
		static public var failedUserKick:String = "Failed to kick user";
		static public var youBanned:String = "Unfortunately you have been banned in this channel";
		static public var textDetails:String = "Details";
		static public var banDetails:String = "Ban details";
		static public var failedUserBan:String = "Failed to ban user";
		static public var contactNotInList:String = "The contact is not in your contact list.";
		static public var textBlock:String = "Block";
		static public var youUnbanned:String = "You unbanned";
		static public var failedMamageModerator:String = "Failed to manage moderatos";
		static public var VICompletedText:String = "Your video identification was successfully completed. Please contact your account manager with questions concerning the status of your account. With best regards. Support Team";
		static public var doYouWantStartPrivateChat:String = "Start a private chat with this person?";
		static public var startPrivateChat:String = "Start private chat";
		static public var maxChannels:String = "Maximum channels number exceeded";
		static public var questionOneByOne:String = "You can not create two questions one by one.";
		static public var saveImage:String = "Save image";
		static public var openInGallery:String = "Open in gallery";
		static public var newChannel:String = "New channel";
		static public var textProceed:String = "Proceed";
		static public var channelDisclaimer:String = "The channel owner is responsible for respecting the applicable legislation and is obliged to moderate the content.\n\nThe channel should not contain any spam, abusive behaviour, pornography and terrorism related content.\n\nIn case of breach of legislation or rules Dukascopy reserves the right to close the channel or take any other appropriate measures.";
		static public var needPaymentAccount:String = "In order to create a channel you have to be identified or have a Dukascopy Payments account which is equivalent of identification.\n\nDo you want to proceed with Dukascopy Payments Identification?";
		static public var imageOptions:String = "Image options";
		public static var depositRmbTransferDescription:String = "N.B. Deposit from WeChat will not be accepted if this is your first deposit.";
		public static var depositComissionText:String = "We do not apply a fee for funding via a payment card, however, our partner bank charges:\n- 1% for transactions in EUR, GBP and CHF\n- 1.5% for transactions in DKK, NOK, PLN and SEK\n- 2% for transactions in USD\n- 2.3% for transactions in RUB, JPY, CAD and AUD\n\nAdditional conversion fee may apply should your card currency differ from the payment currency.";
		public static var kursCNH_CNY:String = "1 CNH = 1.02 CNY";
		static public var openMessenger:String= "Open messenger";
		static public var freeMessenger:String= "Free Messenger, audio and video calls";
		static public var openPayments:String= "Open payments";
		static public var instantPayments:String= "Instant Payments - great exchange rates!";
		static public var promisedTips:String = "Reward for answer";
		static public var featureNoPaments:String = "Only identified person can use this feature";
		//new payments
		public static var connectionError:String = "Connection error. Please try again";
		
		static public var extraTipsTitle:String = "Extra tips";
		static public var geoTitle:String = "Geolocation";
		static public var extraTipsBody:String = "press to promise extra tips...";
		static public var categoriesTitle:String = "Categories";
		static public var questionType:String = "Question type";
		static public var questionSide:String = "Offer side";
		static public var questionPrice:String = "Price";
		static public var questionCurrency:String = "Currency";
		static public var questionCryptoAmount:String = "Crypto amount";
		static public var languageTitle:String = "Language";
		static public var secretTitle:String = "Secret mode";
		
		static public var needGeoForAnswer:String = "Question maker requests your geolocation. Would you like to share it with him?";
		
		/*PaymentsRTOLimitsScreen*/
		static public var addInfoRequired:String = "Additional information required";
		static public var transfersToOtherClient:String = "Make transfers to other client`s account";
		static public var estimateNumPayMonth:String = "Please estimate the number of payments per month";
		static public var estimateNumPay:String = "Estimate number of payments";
		static public var amountMonthlyTransactions:String = "Please select approximate amount of your monthly transactions";
		static public var monthlyAmmount:String = "Approximate monthly ammount";
		static public var makePaymentsInternet:String = "Make payments for goods/services obtained throught the internet";
		static public var receivePaymentsInternet:String = "Receive payments for goods/services sold throught the internet";
		static public var alreadyHaveUnpaid:String = "To use this service, please pay extra tips already promised by you.";
		static public var text911statistic:String = "911 statistics";
		static public var textBanUser:String = "Ban user";
		static public var textBanForeverUser:String = "Ban user forever";
		static public var textZeroRating:String = "Zero rating";
		
		static public var textAdditionalTips:String = " is promised by the person asking the question to additionally encourage you. You should get this extra amount if you satisfy him/her with your answer or support. The payment of the extra tips is the exclusive responsibility of the person asking the question.\n\nDukascopy does not take any responsibility for the payment of this amount; however, if the promised amount is not paid, it will block the user from accessing the extra tips functionality.\n\nBasic tips up to 1 DUK+ will be paid independently by Dukascopy, in accordance with the rules.";
		static public var textAdditionalCategoiesInfo:String = "To facilitate other people to find your question and answer it propertly, you can choose a category or few of them.";
		static public var textAdditionalLanguagesInfo:String = "To facilitate other people to find your question and answer it propertly, you can choose a language or few of them.";
		static public var textAdditionalTipsInfo:String = "To encourage people to answer, you may promise extra tips. The amount you have promised will be shown next to your question. You should pay extra tips and it is your exclusive responsibility. If you do not pay for the promised extra tips, this service will be automatically void for you in the future until you complete the promised extra tips payment.";
		static public var textAdditionalSideInfo:String = "To encourage people to answer, you may promise extra tips. The amount you have promised will be shown next to your question. You should pay extra tips and it is your exclusive responsibility. If you do not pay for the promised extra tips, this service will be automatically void for you in the future until you complete the promised extra tips payment.";
		static public var textAdditionalCryptoAmountInfo:String = "To encourage people to answer, you may promise extra tips. The amount you have promised will be shown next to your question. You should pay extra tips and it is your exclusive responsibility. If you do not pay for the promised extra tips, this service will be automatically void for you in the future until you complete the promised extra tips payment.";
		static public var textAdditionalCurrencyInfo:String = "To encourage people to answer, you may promise extra tips. The amount you have promised will be shown next to your question. You should pay extra tips and it is your exclusive responsibility. If you do not pay for the promised extra tips, this service will be automatically void for you in the future until you complete the promised extra tips payment.";
		/*UserQuestionsStatScreen*/
		static public var rewardRightAnswer:String = "Reward per right answer";
		static public var inPendingStatus:String = "In pending status";
		static public var textQuestions:String = "Questions";
		static public var rightAnswers:String = "Right answers";
		static public var totalEarnings:String = "Total earnings";
		static public var textSpam:String = "Spam";

		static public var noReason:String = "No reason";
		public static var textOf:String = "Of";
		public static var textResetDate:String = "Reset date";
		public static var showPassword:String = "Show password";
		public static var maxValueDecsription:String = "Value cannot be more than %@";
		public static var btnTryAgain:String = "try again";
		public static var alertPasswordSuccessfully:String = "Password has been changed successfully.";
		public static var limitsWithoutSettings:String = "Below you can adjust your transaction and/or daily limit for One Click Payments.";
		public static var transactionLimitsMax:String = "Transaction Limits (max. 30 EUR)";
		public static var dailyLimitMax:String = "Daily Limit (max. 150 EUR)";		
		public static var transactionLimitsMaxSwiss:String = "Transaction Limits (max. 100 EUR)";
		public static var dailyLimitMaxSwiss:String = "Daily Limit (max. 500 EUR)";		
		public static var oneClickPaymentsDesc:String = 'Client agrees to issue orders to the simplified payments available through Dukascopy Connect 911 application by using a mobile device and clicking "Send Money". One Click Payments limit is 30 EUR per transaction and 150 EUR per day, which is also set by default as maximum limits by Dukascopy Payments. Client has the right to set own limits, within the maximum limits set by Dukascopy Payments and in accordance with the procedures of Dukascopy Payments.\nAdditionally to the simplified payments functionality, One Click Payments offers a possibility to check balances of e-wallets.\nClient is obliged to protect a mobile device with a passcode as well as to take all necessary measures not to disclose it to any third party.\nClient is obliged to notify Dukascopy Payments immediately if the mobile device was lost or stolen. Dukascopy Payments should cancel these terms and conditions for security reasons without compensating possible damage or loss and block an access to One Click Payments upon receipt of such a notification.\nClient acknowledges and accepts the risk that if a mobile device is not protected by a passcode and / or the mobile device comes into possession of a third party, a third party can get data available in a mobile device and perform One Click Payments.\nClient is responsible for all damages and losses incurred in connection with unauthorized transactions carried out by a third party using client’s mobile device until Dukascopy Payments receives the above mentioned notification.\nBy accepting these terms and conditions a client agrees not to apply articles 66, 85, 86, 87(1), 87(2) of the Payment Services and Electronic Money Law.\nClient has the right at any time to cancel One Click Payments functionality by going to Payments mobile application settings and disabling One Click Payments.\nGeneral Terms & Conditions of Dukascopy Payments as well as Fees & Limits are integral parts of these terms and conditions.\nClient confirms that he has understood the content of these terms and conditions and accepts them by clicking “I agree”.';
		public static var oneClickPaymentsDescSWISS:String = 'Client agrees to issue orders to the simplified payments available through Dukascopy Connect 911 application by using a mobile device and clicking "Send Money". One Click Payments limit is 30 EUR per transaction and 150 EUR per day, which is also set by default as maximum limits by Dukascopy Payments. Client has the right to set own limits, within the maximum limits set by Dukascopy Payments and in accordance with the procedures of Dukascopy Payments.\nAdditionally to the simplified payments functionality, One Click Payments offers a possibility to check balances of e-wallets.\nClient is obliged to protect a mobile device with a passcode as well as to take all necessary measures not to disclose it to any third party.\nClient is obliged to notify Dukascopy Payments immediately if the mobile device was lost or stolen. Dukascopy Payments should cancel these terms and conditions for security reasons without compensating possible damage or loss and block an access to One Click Payments upon receipt of such a notification.\nClient acknowledges and accepts the risk that if a mobile device is not protected by a passcode and / or the mobile device comes into possession of a third party, a third party can get data available in a mobile device and perform One Click Payments.\nClient is responsible for all damages and losses incurred in connection with unauthorized transactions carried out by a third party using client’s mobile device until Dukascopy Payments receives the above mentioned notification.\nBy accepting these terms and conditions a client agrees not to apply articles 66, 85, 86, 87(1), 87(2) of the Payment Services and Electronic Money Law.\nClient has the right at any time to cancel One Click Payments functionality by going to Payments mobile application settings and disabling One Click Payments.\nGeneral Terms & Conditions of Dukascopy Payments as well as Fees & Limits are integral parts of these terms and conditions.\nClient confirms that he has understood the content of these terms and conditions and accepts them by clicking “I agree”.';
		public static var oneClickPaymentsDescEUROPE:String = 'Client agrees to issue orders to the simplified payments available through Dukascopy Connect 911 application by using a mobile device and clicking "Send Money". One Click Payments limit is 30 EUR per transaction and 150 EUR per day, which is also set by default as maximum limits by Dukascopy Payments. Client has the right to set own limits, within the maximum limits set by Dukascopy Payments and in accordance with the procedures of Dukascopy Payments.\nAdditionally to the simplified payments functionality, One Click Payments offers a possibility to check balances of e-wallets.\nClient is obliged to protect a mobile device with a passcode as well as to take all necessary measures not to disclose it to any third party.\nClient is obliged to notify Dukascopy Payments immediately if the mobile device was lost or stolen. Dukascopy Payments should cancel these terms and conditions for security reasons without compensating possible damage or loss and block an access to One Click Payments upon receipt of such a notification.\nClient acknowledges and accepts the risk that if a mobile device is not protected by a passcode and / or the mobile device comes into possession of a third party, a third party can get data available in a mobile device and perform One Click Payments.\nClient is responsible for all damages and losses incurred in connection with unauthorized transactions carried out by a third party using client’s mobile device until Dukascopy Payments receives the above mentioned notification.\nBy accepting these terms and conditions a client agrees not to apply articles 66, 85, 86, 87(1), 87(2) of the Payment Services and Electronic Money Law.\nClient has the right at any time to cancel One Click Payments functionality by going to Payments mobile application settings and disabling One Click Payments.\nGeneral Terms & Conditions of Dukascopy Payments as well as Fees & Limits are integral parts of these terms and conditions.\nClient confirms that he has understood the content of these terms and conditions and accepts them by clicking “I agree”.';
		
		public static var IDENTIFICATION_LIMIT_DEPOSITS:String = "Global Limit for Deposit";
		public static var IDENTIFICATION_LIMIT_WITHDRAWALS:String = "Global Limit for Withdrawal";
		public static var INCOMING_LIMIT_AMOUNT_1M:String = "Incoming Limit for Current Month";
		public static var OUTGOING_LIMIT_AMOUNT_1M:String = "Outgoing Limit for Current Month";
		public static var TOTAL_EQUITY_USD:String = "Limit on Summary Balance of Account";
		public static var DUKAPAY_INCOMING_LIMIT_AMOUNT_Q:String = "Incoming Limit for Current Quarter";
		
		public static var TOTAL_EQUITY_USD_BOT:String = "Size of max balance";
		public static var DUKAPAY_INCOMING_LIMIT_AMOUNT_Q_BOT:String = "Your incoming quarter limit";
		public static var bestMarketPrice:String = "Current best market price";
		
		public static var textAddress:String = "Address";
		public static var textFaq:String = "FAQ";
		static public var verificationLimits:String = "Verification & Limits";
		static public var security:String = "Security";
		static public var signWithTouchID:String = "Sign in with Touch ID";
		static public var signWithFaceID:String = "Sign in with Face ID";
		static public var aboutUs:String = "About us";
		static public var termsAndConditions:String = "Terms and Conditions";
		static public var myAccount:String = "My Account";
		static public var personalDetails:String = "Personal Details";

		public static var oneClickPayments:String = "One Click Payments";
		public static var pleaseEnterPasswordTouchID:String = "Please enter password to enable Touch ID";
		static public var processingInvoiceTitle:String= "Processing Invoice";
		static public var moneyTransferedTitle:String = "Money transfered";
		static public var invoicePaidText:String = "Invoice has been paid";
		static public var activateCardText:String =  "Activate card";
		static public var activateButtonText:String=  "Activate";
		static public var rietumuActivationText:String = "Please enter 4-digit activation code <br>(digits 9-12 on your card)";
		static public var cornerActivationText:String = "Enter 4-digit activation code (digits 9-12 on the card) to activate the card.<br>6-digit card PIN will be sent to your mobile phone via SMS shortly after card activation.";
		static public var transactionsButtonText:String = "TRANSACTIONS";
		static public var topUpCardButtonText:String = "TOP UP CARD";
		static public var blockCardButtonText:String = "BLOCK CARD";
		static public var unblockCardButtonText:String = "UNBLOCK CARD";
		static public var sendPinButtonText:String = "SEND PIN";
		static public var unblockCardDialogText:String = "Do you want to have your card unblocked?";
		static public var sendPinDialogText:String = "Are you sure you want to send pin ?";
		static public var unblockButtonTextShort:String = "UNBLOCK";
		static public var deleteCardButtonText:String = "DELETE CARD";
		static public var verifyButtonText:String = "VERIFY";
		static public var categoryDatingDisclaimer:String = "Dating category contains private and/or confidential information of its users. Any transfer of data obtained in Dating category to the third parties is strictly prohibited and violates data protection laws. Non-compliance with data protection laws may lead to possible sanctions and litigation. Dukascopy reserves a right to restrict access to Dukascopy Connect 911 for users that transfer private and/or confidential information to the third parties, to charge a fine of 100 CHF and to request a compensation of any possible losses.\n\nIf you select the Secret Mode, be informed that the following information will be collected from your Dukascopy Payments account details and be visible to other users:\nyour date of birth;\nyour gender.\nThis information will be disclosed to other users for the purpose of avoiding fake accounts.\n\nBY CONTINUING AND SELECTING SECRET MODE YOU EXPLICITLY ALLOW THE USE OF ABOVE MENTIONED DATA, YOU EXPRESSLY WAIVE THE BENEFIT OF BANKING SECRECY AND DATA PROTECTION AND  YOU RELEASE DUKASCOPY FROM ANY LIABILITY IN THAT RESPECT.";
		static public var textConnectionError:String = "Connection Error";
		static public var textShowStatistic:String = "Show statistics";
		static public var textIncognitoTips:String = 'You have to leave extra tips to enable "Secret mode".';
		static public var textGeoTips:String = 'You have to leave extra tips to enable "Geolocation".';
		static public var textGeo:String = 'Geolocation';
		static public var textTypePublicTips:String = 'You have to leave extra tips to enable "Public type".';
		static public var questionYouAreBanned:String = "You are banned in 911";
		static public var limitQuestionExists:String = "Limit is exceeded. Satisfy previous questions";
		static public var textAbout:String = "About";
		static public var invalidInputData:String = "Invalid input data";
		static public var wrongPhoneNumber:String = "Wrong phone number";
		static public var phoneNotFound:String = "Phone not found";
		static public var notAuthorized:String = "You not authorized";
		
		//new
		static public var needPaymentsToCreateChannel:String = "Only user with DCPayments account can start channel.";
		static public var alertConfirmCloseChannel:String = "Are you sure you want to delete this channel?";
		static public var closeChannel:String = "Close channel";
		static public var errorRemoveChannel:String = "";
		static public var errorUserNotFound:String = "Error: user not found";
		static public var errorChannelNotFound:String = "Error: channel not found";
		static public var errorYouHaveNoAccess:String = "You have no access";
		static public var enterChannelTitle:String = "Enter channel title";
		static public var pleaseSelectCategoryChannel:String = "Please select a category your channel";
		static public var errorUnubscribeChannel:String = "Subscribe error";
		static public var channelUnsubscribeSuccess:String = "You unsubscribed from the channel";
		static public var channelSubscribeSuccess:String = "You subscribed to the channel";
		static public var pleaseSelectLanguageChannel:String = "Please select a language your channel";
		static public var pleaseEnterName:String = "Please enter your name";
		static public var questionAlreadyClosed:String = "Question already closed";
		
		static public var openProfile:String = "Open profile";
		static public var updatingConversations:String = "Updating conversations...";
		static public var updatingQuestions:String = "Updating questions...";
		static public var addExtraTips:String = "Add extra tips";
		static public var addCategories:String = "Add categories";
		static public var addLanguages:String = "Add languages";
		static public var pressToChange:String = "press to change...";
		static public var selectCategories:String = "Select categories";
		static public var addNewChannel:String = "Add new channel";
		static public var answerGetRewards:String = "Answer Questions - Get Rewards";
		static public var verifyCode:String = "Verify code";
		static public var removeUser:String = "Remove user";
		static public var alertConfirmRemoveUser:String = "Remove this user from chat?";
		static public var userRemoved:String = "Removed";
		static public var textAdded:String = "added";
		static public var toThisChat:String = "to this chat";
		static public var addedUserToChat:String = "added user to chat";
		
		static public var grantAccess:String = "Grant Access";
		static public var voicePermission:String = "To send a voice, you must provide permission to Microphone";
		static public var sendPhotoToFriends:String = "Send photo to friends";
		static public var startSendPhoto:String = "Start Sending Photos";
		static public var startSendVoice:String = "Start Sending Voice Messages";
		static public var photoPermission:String = "To send an image, you must provide permission to Photos";
		static public var voicePermissionDenied:String = "In iPhone settings, tap Dukascopy and turn on Microphone";
		static public var sendVoiceToFriends:String = "Send voice messages to friends";
		static public var photoPermissionDenied:String = "In iPhone settings, tap Dukascopy and turn on Photos";
		static public var openSettings:String = "Open Settings";
		static public var removedUsed:String = "removed user";
		static public var removedUser:String = "removed user";
		static public var textRemoved:String = "removed";
		static public var fromThisChat:String = "from this chat";

		static public var doNotShowAgain:String = "Do not show again";
		static public var textSatisfied:String = "Are you satisfied?";
		
		static public var youHaveRequestedSMS:String = "You have requested sms code just few moments ago. Please wait several minutes before you request a new one.";
		static public var callsLimitReached:String = "Todays calls limit reached";
		static public var wrongCode:String = "Wrong code or device";
		static public var selectYourCountryCode:String = "Select your country code";
		
		public static var textMessageIsTooLong:String = "The message is too long, max symbols count is ";
		public static var textCurrentMessageLength:String = " , current message lenght is ";
		static public var enterCode:String = "Enter code";
		//errors from server
		static public var accessDenied:String = "Access denied.";
		static public var antispamRobot:String = "Antispam robot.";
		static public var authKeyExpired:String = "Auth key expired.";
		static public var authKeyIsCompromised:String = "Auth key is compromised.";
		static public var badInputParameters:String = "Bad input parameters.";
		static public var canNotFindWritePath:String = "Can not find write path.";
		static public var cDATADamaged:String = "CDATA damaged.";
		static public var chunkNotUploaded:String = "Chunk not uploaded, file not exist.";
		static public var codeExpired:String = "Code expired.";
		static public var companyMemberNoCreate:String = "Company member can`t create chat with company.";
		static public var databaseError:String = "Database error.";
		static public var dbErrorDueGuestCreation:String = "Database error due guest creation.";
		static public var duplicateIDforOtherUsers:String = "Duplicate cID for other users.";
		static public var fileHasBeenBroken:String = "File has been broken.";
		static public var fxcommAuthError:String = "Fxcomm auth error.";
		static public var fxcommFormatWasChanged:String = "Fxcomm response format was changed.";
		static public var fXCommGalleryFail:String = "FXComm gallery fail.";
		static public var fxcommResponseIsInvalid:String = "Fxcomm response is invalid.";
		static public var invalidBase64Data:String = "Invalid base64 data.";
		static public var invalidUTF8Symbols:String = "Invalid UTF8 symbols.";
		static public var ldapAuthError:String = "Ldap auth error.";
		static public var ldapWrongRespond:String = "Ldap wrong respond.";
		static public var maxPeriodSearchExceeded:String = "Max period for search with given criteria exceeded.";
		static public var membersIsEmpty:String = "Members is empty.";
		static public var mustBeLoggedIn:String = "Must be logged in.";
		static public var mySQLError:String = "MySQL Error.";
		static public var nameCanNotBeEmpty:String = "Name can not be an empty but not longer 16 symbols.";
		static public var needAuthorization:String = "Need authorization.";
		static public var needFullAuthorization:String = "Need full nonguest authorization.";
		static public var needToBeInside:String = "Need to be inside Dukascopy.";
		static public var needToByAuthorized:String = "Bank authorization needed";
		static public var noAccess:String = "No access.";
		static public var noAddFxcommUser:String = "Can`t add fxcomm user.";
		static public var noCallRecord:String = "No call record.";
		static public var noChangeAvatar:String = "Can not change avatar of non-group conversation.";
		static public var noChat:String = "No chat.";
		static public var noChatFound:String = "No chat found.";
		static public var noChatUidProvided:String = "No chat uid provided.";
		static public var noCompanyFound:String = "No company found.";
		static public var noCompanySecurityKey:String = "No company security key.";
		static public var noCompanyUser:String = "No company user.";
		static public var noCreateCode:String = "Can`t create code. Please try again.";
		static public var noDirectCall:String = "No direct call.";
		static public var noDirectoryToStore:String = "No directory to store or unreadable.";
		static public var noExternalIpsInConfig:String = "No external ips in config.";
		static public var noFileInStorage:String = "No file in storage.";
		static public var noFxcommUser:String = "No fxcomm user.";
		static public var noGetCompanySecurityKey:String = "Can`t get company security key.";
		static public var noGivenCriteria:String = "No given criteria.";
		static public var noLeavePrivateChat:String = "Can`t leave private chat.";
		static public var noMethod:String = "No method.";
		static public var noRemoveOwnerFromChat:String = "Can`t remove owner from chat.";
		static public var noSecurityKey:String = "No security key.";
		static public var noStartChatWithAnonym:String = "Can`t start chat with anonym. Please provide at least guest id, or check key.";
		static public var notAllowed:String = "Not allowed.";
		static public var notEmptyGroup:String = "Not empty Group.";
		static public var nothingToDecrement:String = "Nothing to decrement.";
		static public var nothingToUpdate:String = "Nothing to update.";
		static public var noThumbInStorage:String = "No thumb in storage.";
		static public var notValidInputData:String = "Not valid input data.";
		static public var noUser:String = "No user.";
		static public var noUserCheckKey:String = "No user. Check key.";
		static public var noUsersToAdd:String = "No users to add.";
		static public var noUserUidProvied:String = "No user uid provied.";
		static public var numberAndDataNoNULL:String = "Number and data can`t be NULL at the same time.";
		static public var numberMustContainOnly:String = "Number must contain only a number.";
		static public var onlyOwnerCanRemoveUsers:String = "Only owner can remove users.";
		static public var otherError:String = "Other error.";
		static public var phoneBannedFromVoiceCalls:String = "Phone banned from Voice Calls.";
		static public var requestCodeViaSmsFirst:String = "Request code via sms first.";
		static public var RMSError:String = "RMS error.";
		static public var someDatabaseError:String = "Some Database error.";
		static public var storageError:String = "Storage error.";
		static public var teamMembersIsEmpty:String = "Team members is empty.";
		static public var todaysCallsLimit:String = "Todays calls limit reached.";
		static public var todaysCallsLimitIP:String = "Todays calls limit reached to this ip.";
		static public var unauthorizedAccess:String = "Unauthorized access.";
		static public var userAlreadyBlocked:String = "User already blocked.";
		static public var userAlreadyExistsUID:String = "User already exists with differenet user uid.";
		static public var userNotExists:String = "User(s) not exists.";
		static public var userNotInChat:String = "User not in chat.";
		static public var userOrIPAlreadyBanned:String = "User or IP already banned.";
		static public var usersToMatch:String = "Users to match.";
		static public var userUnknown:String = "User unknown.";
		static public var userWasBannedInChatRoom:String = "User was banned in chat room.";
		static public var wrongChatType:String = "Wrong chat type.";
		static public var wrongCodeOrDevice:String = "Wrong code or device.";
		static public var wrongCompanyMember:String = "Wrong Company Member.";
		static public var wrongCompanySecurityKey:String = "Wrong company security key.";
		static public var wrongData:String = "Wrong data.";
		static public var wrongEntryPoint:String = "Wrong entry point.";
		static public var wrongFileInputData:String = "Wrong file input data.";
		static public var wrongFxcommRespond:String = "Wrong fxcomm respond.";
		static public var wrongGroupID:String = "Wrong group ID.";
		static public var wrongInputData:String = "Wrong input data.";
		static public var wrongInputParameters:String = "Wrong input parameters.";
		static public var wrongNetwork:String = "Wrong network.";
		static public var wrongParams:String = "Wrong params.";
		static public var wrongPayerHash:String = "Wrong payer hash.";
		static public var wrongPayerToken:String = "Wrong payer token.";
		static public var wrongPayerTokenResponse:String = "Wrong payer token response.";
		static public var wrongRequestSign:String = "Wrong request sign.";
		static public var wrongStickerID:String = "Wrong sticker ID.";
		static public var wrongSupporterUID:String = "Wrong supporter UID.";
		static public var wrongTraderApi:String = "Wrong trader api.";
		static public var wrongTraderHash:String = "Wrong trader hash.";
		static public var wrongTraderToken:String = "Wrong trader token.";
		static public var wrongTraderTokenResponse:String = "Wrong trader token response.";
		static public var wrongUsername:String = "Wrong username.";
		static public var wrongUserParamsInStorage:String = "Wrong user params in storage.";
		static public var unknownError:String = "Unknown error";
		static public var needAuthorized:String = "Need to be authorized";
		static public var registeredInPayments:String = "You should be registered in payments";
		static public var inviteAlreadyStored:String = "This invite is already stored";
		static public var alreadyInvited:String = "User has been already invited";
		static public var deviceAlreadyInList:String = "This device is already in invited list";
		static public var unknownPromoCode:String = "Unknown promo code";
		static public var alreadyInPayments:String = "User has been already registered in payments";
		static public var featureNotAvailable:String = "The feature you are trying to use is unavailable.";
		
		static public var invoiceDialogWarningTitle:String = "Send money?";
		static public var invoiceDialogWarningText1:String = "Are you sure you want to <font color='#cd3f43'><b>pay invoice?</b></font>\n";
		static public var invoiceDialogWarningText2:String = "<font color='#cd3f43'><b>You will be charged: %@ %@ </b></font>";
		static public var yesPayText:String = "Yes, pay";
		static public var cardNotVerified:String = "Card is not verified";

		
		
		
		static public var youAreBanned:String = "You are banned.";
		static public var youHaveNoCompany:String = "You have no company.";
		static public var yourTodaysCallsLimit:String = "Your todays calls limit reached.";
		static public var dating911:String = "911 Dating";
		static public var textRegister:String = "Register";
		static public var needRegister:String = "In order to use Dating you need to register";
		static public var firstQuestion911:String = "Привет, я тут впервые что у вас тут?;Всем привет! Как пользоваться этим приложением?;Расскажите мне о Dukascopy 911!;Как работает это приложение?;Есть еще новенькие?; Добрый день я совсем новый человек помогите мне понять как работает 911?";
		//static public var firstQuestion911:String = "Hello! I am new user. Can you help me?; Tell me more about Dukascopy 911!; How does this application work?; It's my first time here! Can you help me?";
		static public var sentYouMessage:String = " sent you a message";
		static public var sentGroupMessage:String = " sent a message to the group chat";
		static public var questionHasUnpaid:String = "You have unpaid extra tips. Please pay before creating new questions with tips.";
		static public var textOn:String = "On";
		static public var textOff:String = "Off";
		static public var skip:String = "Skip";
		static public var sendGift:String = "Send gift";
		static public var youWerePraisedAndSendGift:String = "You were praised and sent a gift of %@ %@";
		static public var youPraiseUserWith:String = "You praise %@ with %@ from your account in Dukascopy Payment";
		static public var youPraisedUserWith:String = "You praised %@ with %@ from your account in Dukascopy Payment";
		static public var youPraiseUserWith2:String = "You praise %@ with %@ from your account in Dukascopy Payment2";
		static public var chooseAccount:String = "Choose an account to continue";
		static public var textNext:String = "Next";
		static public var walletToCharge:String = "Account to charge";
		static public var giftSent:String = "Gift sent";
		static public var userSentYouPraiseWith:String = "%@ sent you praise with %@";
		static public var commisionWillBe:String = "Commision will be";
		static public var theGiftWasSent:String = "The gift was sent. Thank you!";
		static public var textInfo:String = "Info";
		static public var takeGiftInPayments:String = "Open Payments";
		static public var giftsTitleStep1:String = "A good way to express your feeling";
		static public var giftsTextStep1:String = "If you are grateful to your chatter for something, or want to express special gratitude. You can send a money gift to your chatter.";
		static public var giftsTitleStep2:String = "Greeting card";
		static public var giftsTextStep2:String = "The chatter receives a colorful postcard with your photo and congratulations.";
		static public var giftsTitleStep3:String = "Good mood";
		static public var giftsTextStep3:String = "Get to know about your appreciation. And she will receive a cash gift in Dukascopy payments";
		static public var praiseNow:String = "Praise now!";
		static public var addComment:String = "Add comment";
		static public var notebookName:String = "Me";
		static public var yourComment:String = "Your comment";
		static public var moneyTransfer:String = "Money transfer";
		static public var wrongTimeOnDevice:String = "Wrong date/time on device";
		static public var textReference:String = "Reference";
		static public var textFee:String = "Fee";
		static public var textFrom:String = "From";
		static public var textTo:String = "To";
		static public var textCreated:String = "Created";
		static public var textUpdated:String = "Updated";
		static public var textQueNotSatisfied:String = "Not satisfied";
		static public var textQueSatisfied:String = "Satisfied";
		static public var textQueGotAnswer:String = "Got answer";
		static public var epPaymentsFirstMessage:String = "Hello,\nYou can find information about payment services here https://www.dukascopy.com/pay \nIf you have any additional, questions please ask in this chat.";
		static public var sentVideo:String = "Video sent";
		static public var sendTo:String = "Send to %@";
		static public var chooseMediaFile:String = "Choose media file";
		static public var textImages:String = "Images";
		static public var textVideos:String = "Videos";
		static public var textCamera:String = "Camera";
		static public var makeVideo:String = "Video";
		
		static public var txtPrivacyDC:String = "By requesting code you acknowledge that you read, understood and agreed to the [U]Terms of Use of Dukascopy Connect and its Privacy Policy[U].";
		static public var textClosed:String = "Closed";
		static public var sendAgain:String = "Send again";
		static public var shereOnDukascopy:String = "Share  on Dukascopy";
		static public var enableCameraAccess:String = "Enable access so you can start taking photos and videos.";
		static public var cameraEnabled:String = "Camera Access Enabled";
		static public var micEnambled:String = "Microphone Access Enabled";
		static public var micAccess:String = "Enable Microphone Access";
		static public var cameraAccess:String = "Enable Camera Access";
		static public var videoSaveSuccess:String = "Video saved!";
		static public var videoSaveFail:String = "Error during video saving";
		static public var textSaved:String = "Saved";
		static public var buyImageDialogTitle:String = "Buying Image";
		static public var BUY:String = "Buy";
		static public var puzzleImage:String = "Puzzle Image";
		static public var imageIsLocked:String = "Image is locked";
		static public var imageIsLockedBody:String = "Do you want to pay %@ %@ to unlock the image?";
		static public var videoSaving:String = "Saving video...";
		static public var textPuzzle:String = "Puzzle";
		static public var questionNotEnoughMoney:String = "Not enough money.";
		static public var questionWrongTipAmount:String = "Wrong tip amount.";
		static public var textAdditionalTypeInfo:String = "In Private questions you will have conversation privately. In public question multiple people will answer simultaneously.";
		static public var textAdditionalGeoInfo:String = "When user will answer your question user will be asked to share location with you.";
		static public var textSelectType:String = "Select type";
		static public var textSelectSide:String = "Select side";
		static public var textQuestionTypePublic:String = "Public";
		static public var textQuestionTypePrivate:String = "Private";
		static public var textQuestionSideBuy:String = "Buy";
		static public var textQuestionSideSell:String = "Sell";
		static public var textAdditionalTypeInfoDesc:String = "Press to select <B>private</B> or <B>public</B>";
		static public var theMoneyWasSent:String = "Money was transfered";
		static public var failedToLoadCommission:String ="Some error occurred while loading commission";
		static public var clickToPlay:String="CLICK TO PLAY GAME";
		static public var boughtYourPuzzle:String="Bought your puzzle";
		static public var boughtAPuzzle:String="Bought a puzzle";

		static public var swissPaymentsTitle:String = "Dukascopy Bank";
		static public var europePaymentsTitle:String = "Payments";
		static public var europeBankTitle:String = "Dukascopy Payments SIA";
		static public var europeBankSubtitle:String = "European Licensed 100% subsidary of Dukascopy Bank";
		static public var swissBankTitle:String = "Dukascopy BANK SA";
		static public var swissBankSubtitle:String = "Swiss Bank regulated by FINMA";
		static public var errorDuringLogin:String="Error while logging in, please try again";
		static public var loginToSwissButton:String= "Login to Swiss Bank";
		static public var openSwissAccountButton:String = "Open Swiss Bank account";
		static public var loginToEuropeButton:String = "Login to Payments account";
		static public var openEuropeAccountButton:String = "Open Payments account";
		static public var rememberMyChoice:String = "Remember my choice";
		
		static public var wrongPaymentsTimestampDialogTitle:String = "Wrong time settings";
		static public var wrongPaymentsTimestampDialogBody:String = "Check your time and location settings";
		static public var wrongPaymentsTimestampButton:String = "Repeat authorization";
		

		static public var noAswersYet:String = "no answers yet";
		static public var asked:String = "Asked";
		static public var messages:String = "messages";
		static public var topLikes:String = "Top likes";
		static public var rewardForAnswers:String = "Reward for answers %@ to %@";
		static public var publicQuestionWinnerText:String = "%@ побеждает в этом конкурсе!\n\n Он(а) получает гравный приз %@. Спасибо всем остальным участникам.";
		static public var readRules:String = "Read rules";
		static public var questionInfoShortText:String = "You may get up to 1 DUK+ for proper answer of the question";
		static public var textPaid:String = "Paid";
		static public var showResults:String = "Show results";
		static public var selectWinner:String = "Tap to select a winner";
		static public var sortBy:String = "Sort by";
		static public var textReward:String = "Reward";
		static public var openAnswer:String = "Open answer";
		static public var publicQuestionIntroText:String = "You will get %@ for proper answer of the question";
		static public var questionNoMoreExist:String = "Question no more exist";
		static public var cantWriteInChat:String = "You can't write to that chat";
		static public var receivedGifyFrom:String = "received gift from";
		static public var controlPanel:String = "Control Panel";
		static public var textQuestionTypePublics:String = "Public";
		static public var enterInviteCode:String = "Please enter your referral code to get a prize";
		static public var referralProgram:String = "Referral Program";
		static public var sendYourReferralCode:String = "Send your referral code to a friends and get 5 $ for a new user to your bank account";
		static public var tapToCopy:String = "Tap to copy to clipboard";
		static public var copied:String = "Copied!";
		static public var invitePromocodeMessage:String = "I invite you to try Dukascopy Connect! Use this promo code %@ and receive 5$!\nfollow this link: https://www.dukascopy.bank/swiss/connect/#referral";
		static public var totalSentInvites:String = "Total sent invites";
		static public var totalAttractedFriends:String = "Total attracted friends";
		static public var enterReferralCode:String = "Enter referral code";
		static public var referralCodeAccepted:String = "Referral code accepted!";
		static public var seeAllFriends:String = "See all friends";
		static public var invites:String = "Invites";
		static public var referralProgramAgreement:String = '<b>TERMS & CONDITIONS OF THE CRAZY 911 REFERRAL PROGRAM </b>("Program")<br>Grow the CRAZY 911 Community and get rewarded!<br>Receive EUR 5 for each new person you introduce to the CRAZY 911 Community and each new member you refer also receives EUR 5.<br>The participation in the Program is free of charge but is subject to conditions.<br><b>What do you acknowledge and agree when checking the "I accept" box below?</b><br> You accept that:<li>the present Terms & Conditions ("T&C") which govern the Program may be changed at any time without prior notice. You accept that the T&C published at <font color="#0000ff">www.crazy911.com</font> are the unique T&C which are binding on you. Any new version of T&C published on <font color="#0000ff">www.crazy911.com</font> immediately replaces and supersedes all previous ones.</li><li>the Program may be suspended or discontinued at any time, without prior notice;</li><li>the moderator(s) of the CRAZY 911 community ("Community") have entire freedom, without having to provide explanations, to refuse, suspend or discontinue your participation in the Program, to adjust, cancel the payment of Gifts and methods used for paying such Gifts, in particular but not only if they reasonably determine that (a) T&C were breached or circumvented or (b) that any other form of abuse was committed in relation to the Program/T&C or (c) if the spirit of the Program which is to increase the use of CRAZY 911 as social media and source of fun, was violated or (d) that the Participant hampered (voluntarily or not) the success of the Program or (d) harmed the reputation of third parties associated with the Program;</li><li>conditions are imposed and may be changed without prior notice for (a) being accepted in the Program and/or (b) for receiving Gifts as referrer or as referred new member of the Community. Those conditions are published on <font color="#0000ff">www.crazy911.com</font>. In case those conditions are not met, there is no right for receiving any payment of Gift, without any possible recourse against the legal entities and natural persons associated with the Program;</li><li> Gifts are payable only via an account at the institution affiliated to the Program.</li><li> Gifts are paid only to referred new members of the Community, existing members of the Community are not eligible for any Gifts;</li><li> Gifts are paid only upon fulfillment of all conditions in T&C and those published at <font color="#0000ff">www.crazy911.com</font>;</li><li> not more than one Gift may be paid to each referred natural person qualified for to the Program. In case referred persons make multiple registrations in the Community, only one registration will be counted for the purpose of the Program;</li><li> each Gift is paid upon provision of a valid promotional code ("Code") generated and sent to a Participant of the Program without further verifications. Any claim that a wrong Code has been communicated for payment of Gift(s) will neither be considered nor investigated. Payments of Gifts are irrevocable unless moderators apply their rights as per section (iii) above;</li><li> you shall not publicly (including on the Internet) criticize or otherwise offend other Participants of the Program;</li><li> you are responsible for handling any possible tax consequence of Gifts you receive;</li><li> these T&C do not constitute an agent agreement pursuant to articles 418a and followings of Swiss Code of Obligations those application are expressly excluded;</li><li> legal entities and natural persons organizing the Program do not accept any responsibility or liability for any violation of rights, breach of legislation or other regulation that you may commit in relation to the Program. It is your sole responsibility of complying with all legislation applicable to you;</li><li> there is no confidentiality offered to you regarding your activity as Participant of the Program. This means in particular but not exclusively that (a) in case of any disclosure (whether by you or by third parties) via media (including on the Internet) regarding a dispute involving you and the Program, moderators of the Program will be free to comment on such disclosure and provide via concerned media any information useful for understanding their position about the disclosed issue/dispute and (b) you allow the use for advertising purposes of all personal data, pictures and videos you input in CRAZY 911, without restriction. In this respect you accept to receive communications from the organisers of the Program;</li><li> any dispute involving you and the Program shall be settled amicably, in good faith and in a constructive manner. You expressly renounce to any threat or blackmail vis-à-vis any natural person or legal entity associated with the Program. Failure to comply may result in partial or full revocation of Gifts paid to you before.;</li><li> the Program is governed by Swiss Law. Swiss courts are competent in case of legal actions.</li><br>You understand and accept that it is strictly prohibited to add to the Community by:<li> using or disseminating logos or other intellectual property that is not yours (except CRAZY 911 and Dukascopy Connect 911 name and logo) or which mimic logos or other intellectual property of third parties;</li><li> harassing or spamming people: no unsolicited emails and no post mails to people not known to you personally are permitted;</li><li> cold calls: no unsolicited calls to people not known to you personally are permitted;</li><li> acting or pretending to be acting on behalf of any third party including legal entities or natural persons that may be associated with the organization of the Program. You can only act in your own name and represent yourself in the Program;</li><li> publicly (including on the Internet) promoting or referring to legal entities or services subject to regulation, prohibitions such as but not limited to financial institutions, casinos, financial services, gambling, lotteries, etc, whether these legal entities or activities are connected with CRAZY 911, with the Program or not;</li><li> collaborating with any organizations or natural persons involved in illicit, criminal, terrorist or otherwise offensive activities;</li><li> promising illegal or offensive acts by you or by third parties;</li><li> increasing or promising to increase (directly or via third parties) the Gift paid to new Community members referred by you or by other Participants of the Program;</li><li> receive payments or advantages other than the Gift you may receive for each new Community member referred by you;</li><li> sharing the Gift you receive for each new member you refer with third parties;</li><li> allowing third parties to disseminate your Code;</li><li> allowing third parties to use your Code other than for obtaining a Gift in their capacity as new members attracted by you into the Community. Each Code shall remain strictly personal;</li><li> pretending to have any kind of exclusivity or using any other misleading or false statements.</li><br>You confirm that:<li> you decided to take part in the Program upon your own initiative, without any solicitation or pressure and that you will bear entirely and solely any and all liability for possible expenses and damages you may incur in the context of your participation in the Program. You will not hold any third party liable or responsible for such expenses and damage.</li><li> you will refer only natural persons above 18 years old having legal capacity or legal entities.</li><li> you have read, understood the T&C and unconditionally accepted to comply with them.</li>';
		static public var referralProgramHelpURL:String = "https://www.dukascopy.bank/swiss/connect/";
		static public var textAllUsersOffline:String = "All users offline";
		static public var putInJail:String = "Put in jail";
		static public var keepMeIncognito:String = "Keep me incognito";
		static public var days:String = "days";
		static public var totalPrice:String = "Total price";
		static public var onlyFriendsAllowed:String = "Only friends are welcome. To chat with me, we must be friends, find me on fx community first.";
		static public var banDuration:String = "Ban duration";
		
		static public var banReason1:String = "Нарушение правил 911";
		static public var banReason2:String = "Личная неприязнь";
		static public var banReason3:String = "Достал";
		static public var banReason4:String = "Нет сил терпеть персону";
		static public var banReason5:String = "Неадекват";
		static public var banReason6:String = "Угрожает";
		static public var banReason7:String = "Оскорбляет";
		static public var banReason8:String = "Ненавижу";
		static public var banReason9:String = "Надоел";
		static public var banReason10:String = "Не платит по обязательствам";
		static public var banReason11:String = "Спаммер";
		static public var banReason12:String = "Позорит комьюнити";
		static public var banReason13:String = "Не скажу за что";
		static public var banReason14:String = "Беспредельщик";
		static public var banReason15:String = "Хамское поведение";
		static public var banReason16:String = "По приколу";
		static public var banReason17:String = "Because I love you";
		static public var banReason18:String = "Just filrt";
		
		static public var needContactsPermissionToAddContact:String = "Please provide access to your contacts";
		static public var youSentExtraTips:String = "You sent extra tips";
		static public var youEeceivedExtraTips:String = "You received extra tips";
		static public var openInInstagram:String = "Open in Instagram";
		static public var promoteToModerator:String = "Promote to moderator";
		static public var sendMessageFail:String = "Message not sent, please try again later";
		static public var banBy:String = "by";
		static public var getOutOfJail:String = "Get out of jail";
		static public var banEndsIn:String = "Ban will expire in";
		static public var textMinutes:String = "Minutes";
		static public var banRemovalPrice:String = "Cost of ban removal";
		static public var buyBanProtection:String = "Buy ban protection";
		static public var userJailed:String = "User jailed";
		static public var banRemoved:String = "Ban removed";
		static public var protectionDescription:String = "Protection description";
		static public var textWeek:String = "week";
		static public var textWeeks:String = "weeks";
		static public var protectionDuration:String = "Protection";
		static public var protectionAdded:String = "Protection added";
		static public var banProtection:String = "Ban protection";
		static public var paidBanProtectionIsOver:String = "Ban protection is over";
		static public var paidBanProtectionWillBeValidFor:String = "Ban protection will be valid for";
		static public var youWereBanned:String = "You were banned";
		static public var youWereUnbanned:String = "You were unbanned";
		static public var addBotToChat:String = "Add bot";
		static public var addBot:String = "Add bot";
		static public var botAdded:String = "Bot added";
		
		static public var appIntroTitle_1:String = "Mobile Banking";
		static public var appIntroText_1:String = "Full access to your Swiss Bank account";
		
		static public var appIntroTitle_2:String = "Messenger";
		static public var appIntroText_2:String = "A secure, encrypted messenger with an instant money transfer feature";
		
		static public var appIntroTitle_3:String = "Social";
		static public var appIntroText_3:String = "Meet new friends, create challenges, earn money, have fun!";
		static public var appIntroStart:String = "Get started!";
		
		static public var myBans:String = "My Bans";
		static public var banActiveStatus:String = "Jail active";
		static public var banOverStatus:String = "Jail over";
		static public var textTill:String = "till";
		static public var jail:String = "Jail";
		static public var bannedForDays_1:String = "забанен(а) на 1 день";
		static public var bannedForDays_2_4:String = "забанен(а) на %@ дня";
		static public var bannedForDays_5_7:String = "забанен(а) на %@ дней";
		static public var later:String="Later";
		static public var startVideoIdentification:String="Start";
		static public var videoIdentificationDescription:String="You need to perform video identification to complete your registration. Please prepare your passport or ID card and press start button if you want to do video identification now.";
		static public var videoIdentificationTitle:String = "ID Verification";

		static public var inJail:String = "In Jail";
		static public var jailOver:String = "Jail Over";
		static public var talkWithABankBot:String = "Talk with a Bank Bot";
		static public var bankBot:String = "Bank's Bot";

		static public var cameraRollPermissionRequest:String="No access to camera roll";
		static public var cameraRollPermissionAvatarExplain:String="To use image as avatar from camera roll, please open Settings and provide permission.";
		
		static public var cameraPermissionRequest:String="No access to camera";
		static public var cameraPermissionAvatarExplain:String="To take photos as avatar, please open Settings and provide permission.";
		
		static public var refCodesText:Object = {};
		static public var lottoText:Object = {};
		static public var viText:Object = {
			VI_ID_verification: "ID verification",
			VI_start: "Start",
			VI_more: "More",
			VI_disclaimer: "Disclaimer",
			VI_make_selfie: "Make selfie",
			VI_make_MRZ: "Make MRZ",
			VI_read_more: "Read more"
		};
		
		static public var channelDescs:Object = {
			WgWwW2WDWZWdW8We: "Terms of use for Connect 911:<min/>\n\n1) Avatar or nickname must not be associated with Dukascopy;\n2) Advertising is prohibited;\n3) It is forbidden to write your referral code anywhere in Connect 911 (in the nickname, on the avatar, in questions and answers or public/private chats);\n4) The use of swear words is forbidden;\n5) Your rating will be lowered for questions containing only stickers or emoticons;\n6) Interchange (answer for answer) in Connect 911 is not allowed.\n\nNew users should not trust people who want to help withdraw or exchange money, as they may turn out to be scammers, and as a result you could lose your funds.\n\nNever give anyone the code received in SMS. With this code a <font color='#CC3333'>SCAMMER</font> will be able to use your Connect 911 account, as well as a bank account, if you have enabled \"One Click Payments\".\n\nDO NOT give your card number to anyone. A <font color='#CC3333'>SCAMMER</font> can take advantage of this and withdraw your funds from the card.\n\nDO NOT tell your personal information, such as password, to anyone. Please note that Dukascopy Support team members will never ask for your account password in any way."
		};
		
		static public var otherAccTypes:Object = {
			"01": "Standard current",
			"02": "Forex/CFD",
			"04": "LP PAMM",
			"05": "Managed",
			"22": "MT4",
			"41": "Binary"
		};
		
		static public var rdStatuses:Object = {
			"canceled": "Canceled",
			"closed": "Closed",
			"active": "Active"
		};
		
		static public var investmentsTitles:Object = {
			"XAU": "Gold",
			"XAG": "Silver",
			"GAS": "Natural Gas",
			"OIL": "Brent Oil",
			"USA": "USA 30 Index",
			"CHE": "Swiss 20 Index",
			"GBR": "UK 100 Index",
			"FRA": "France 40 Index",
			"DEU": "Germany 30 Index",
			"JPN": "Japan 225 Index",
			"BTC": "Bitcoin",
			"ETH": "Ethereum",
			"AMZ": "Amazon",
			"FBU": "Facebook (Class A)",
			"MSF": "Microsoft",
			"GOO": "Alphabet (Class A)",
			"NFL": "Netflix",
			"TSL": "Tesla",
			"AAP": "Apple",
			"NVD": "Nvidia",
			"US5": "USA 500 Index",
			"UST": "USA 100 Index",
			"LTC": "Litecoin"
		};
		
		static public var cryptoTitles:Object = {
			"BTC": "Bitcoin",
			"ETH": "Ethereum",
			"LTC": "Litecoin",
			"USDT": "Tether",
			"DCO": "Dukascoin"
		};
		
		static public var investmentsCurrency:Object = {
			"coins": "coins",
			"contracts": "contracts",
			"shares": "shares",
			"barrel": "barrel",
			"ounce": "ounce"
		};
		
		static public var jailImmunity:String = "Jail Protection";
		static public var underProtection:String = "Under protection";
		static public var defaultViWelcomeText:String="Thank you for completing the account opening request with Dukascopy Bank!\nThe last step to your personal Swiss bank account is a simple video call with a bank's employee. This will take around 5 minutes. We will ask you several questions regarding your application form and take the photos of you and your document.\nPlease note that you must have a valid document - passport or identity card with machine readable zone (MRZ).\nWhen you are ready to pass video identification or if you have questions, please write a message to this chat.";
		static public var waitingForVideoID:String="Waiting for ID Verification";
		static public var paymentsDialogDesc:String = "Open Mobile Current account to unlock more features!";
		static public var banProtectionSetBy:String = "Set by";
		static public var buyBanProtectionButtonSmall:String = "Buy";
		static public var textAt:String = "at";
		static public var textMore:String = "more";
		static public var textHide:String = "Hide";
		
		static public var standartSupportTitle:String="Support";
		static public var chatWithBankTitle:String="Chat with bank";
		static public var chatWithBankEUTitle:String="Chat with Dukascopy EU";
		static public var chatWithPayEUTitle:String="Chat with Dukascopy Payments";
		static public var vididSupportTitle:String="ID Verification";
		static public var vididEUSupportTitle:String="ID Verification (EU)";
		static public var mcaSupportTitle:String="MCA Support";
		static public var fxSupportTitle:String="Bank Support";
		static public var NOTARY_STATE_TEXT:String = "Notary verification";
		
		/** road map **/
		static public var MY_ACCOUNT_TITLE:String = "My account opening";
		static public var FILL_REG_FORM:String = "Fill registration form";
		static public var FILL_VID_REG:String = "Complete ID Verification";
		static public var APPROVE_ACCOUNT:String = "Approve account";
		static public var CHAT_WITH_BANK:String = "CHAT WITH BANK";
		static public var PENDING_BALANCE:String = "PENDING BALANCE";
		static public var MY_ACC_WAITING:String = "WAITING: TAP TO START";
		static public var MY_ACC_COMPLETED:String = "COMPLETED";
		static public var MY_ACC_FAILED:String = "FAILED";
		static public var BALANCE_CURRENCY_NAME:String =  "EUR";
		static public var BALANCE_DUK_CURRENCY_NAME:String =  "DUK+";
		static public var textOrdered:String = "Ordered";
		static public var allowAdvertising:String = "Allow advertising";
		static public var PRESS_TO_START:String = "PRESS TO START";
		
		static public var from:String = "From...";
		static public var to:String = "To...";
		static public var searchChannels:String = "Search channels...";
		static public var agree:String = "Agree";
		static public var decline:String = "Decline";
		static public var paidChannel:String = "Paid channel";
		static public var paidChannelDescription:String = "I would also like to add a big thanks to everyone involved in sorting all this out as I also struggled originally with audio related ANRs. Big thanks to the Adobe guys as well and another big thanks to Distriqt for offering great ANE's.";
		static public var day:String = "day";
		static public var week:String = "week";
		static public var mounth:String = "month";
		static public var selectDuration:String = "Select duration";
		static public var accessToThisChannelFor:String = "Subscription to this channel for";
		static public var subscribe:String = "Subscribe";
		static public var open:String = "Open";
		static public var youSubscribedToTheThannel:String = "Вы подписались на канал, до окончания подписки осталось: ";
		static public var mySubscriptions:String = "My Subscriptions";
		static public var session:String = "Session";
		static public var once:String = "Once";
		static public var free:String = "Free";
		static public var myPaidChats:String = "My paid chats";
		static public var subscriptionToChannel:String = "Subscription to channel";
		static public var channelSubscribers:String = "Channel subscribers";
		static public var allAccounts:String = "MCA accounts";
		static public var textTotalCash:String = "Total cash";
		static public var textTotalInvestments:String = "Total investments";
		static public var textTotalAccounts:String = "Total accounts";
		static public var textTotalCards:String = "Total cards";
		static public var allOtherAccounts:String = "Other Dukascopy accounts";
		static public var allSavingsAccounts:String = "Saving accounts";
		static public var noTransactionsYet:String = "No transactions yet";
		static public var showMoreCurrencies:String = "Show more currencies";
		static public var commodity:String = "Commodity";
		static public var commodity_oil:String = "Oil";
		static public var commodity_gold:String = "Gold";
		static public var commodity_BTC:String = "BTC";
		static public var commodity_gas:String = "Gas";
		static public var selectCommodity:String = "Commodity";
		static public var payFrom:String = "Pay from";
		
		public static var statusInvestmentComplete:String = " You have successfully exchanged %@ %@ to %@ %@";
		public static var statusInvestmentPending:String = "Investment Transfer %@ has been accepted but still in executing state.";
		
		public static var textInvestmentDetails:String = "Investment details";
		public static var textInvestmentQuantity:String = "Investment quantity:";
		public static var textInvestmentAmount:String = "Investment amount:";
		public static var textCurrentInvestmentAmount:String = "Current investment value:";
		public static var textAveragePurchasePrice:String = "Average purchase price:";
		public static var textCurrentProfitAndLoss:String = "Current profit & loss:";
		static public var textInvestmentTransfered:String = "Investment transfered";
		static public var initialInvestmentPortfolio:String ="Initial investment portfolio value:";
		static public var currentInvestmentPortfolio:String ="Current investment portfolio value:";
		static public var noInvestmentsText:String = "You haven't got any investments";
		static public var selectInvestmentReferenceCurrency:String = "You need to select currency for investments";
		static public var selectReferenceCurrencyButton:String = "Select reference currency";
		static public var investmentAsset:String = "Investment asset";
		static public var purchaseOfAsset:String= "Purchase of asset";
		static public var saleOfAsset:String =  "Sale of Asset";
		static public var noAccountWithReferenceCurrency:String =  "No account with reference currency ";
		static public var loadingCommission:String = "Loading commisiion ...";
		static public var spotRate:String= "Spot rate ";
		static public var commissionText:String = "Spot rate %@ , markup %@\n\nShown rates are indicative only\n";
		static public var indicativeRates:String = "shown rates are indicative only";
		static public var investmentReferenceCurrency:String = "Investment Reference Currency:";
		static public var selectReferenceCurrency:String = "Select Reference Currency";
		static public var purchaseOfAssetBtn:String = "PURCHASE OF ASSET";
		static public var saleOfAssetBtn:String = "SALE OF ASSET";
		static public var sendAssetBtn:String = "SEND ASSETSS";

		static public var currentValue:String = "Current value: ";
		static public var sendAssetTitle:String = "Send Asset";
		static public var investmentsDisclaimerText:String ="All operations with investment instruments have to be conducted in one reference currency, which is chosen before making the first investment. All further operations related to investments (purchase, sale, dividends and custody charge) will be made only in that currency. Reference currency may be changed only when all active assets are sold.\nDukascopy does not quote OTC market prices for Bitcoin spot contracts during the weekends and thus reserves a right to adjust the spot price of your Bitcoin contract executed during the weekends for the amount of spread (difference between bid and ask price) to prevent malicious use of Dukascopy services with the purpose to gain unfair advantage of Bitcoin exchange operations." ;
		static public var unsupportedAndroidVersion:String = "Unsupported Android version";
		static public var fromAccount:String = "From account";
		static public var pay:String = "Pay";
		static public var withdraw:String = "Withdrawal";
		static public var toCard:String = "To card";
		
		static public var botInDevelopmentMode:String = "This operation in development";
		static public var sell:String = "Sell";
		static public var toAccount:String = "To account";
		static public var textGet:String = "Get";
		static public var fromCard:String = "From card";
		static public var youHave:String = "You have";
		static public var noCardsInCurrency:String = "You do not have any active cards in selected currency";
		
		static public var turnOn:String = "Turn on";
		static public var geolocationTitle:String = "I`m here";
		static public var geolocationDescription:String = "In order to see other users please share your geo location first. This feature is avaiable only for identified users.";
		static public var kilometers:String = "km";
		static public var meters:String = "m";
		static public var usersNear:String = "Users near me";
		static public var identifiedUserDescription:String = "To become indetified user, please open bank account first.";
		static public var sendLocation:String = "Send location";
		static public var needGeopositionPermissions:String = "Please provide access to geo location service";
		static public var noUsersWithGeolocation:String = "No one shares geoposition at this time. Please come back later.";
		static public var useAll:String = "Use all";
		static public var ago:String = "ago";
		static public var turnOnGeolocation:String = "Please turn on geolocation";
		static public var now:String = "now";
		
		/*static public var noEvents:String = "No events";
		static public var events:String = "Events";
		static public var promoEventTitle:String = "Просто нажми на кнопку и выигрывай %@";
		static public var promoEventText3:String = "Выигрыш будет переведён на твой	счёт в Dukascopy Bank";
		static public var promoEvent:String = "Промо акция!";
		static public var promoJoin:String = "Участвовать!";
		static public var youAlreadyInEvent:String = "Ты уже принимаешь участие в розыгрыше";
		static public var waitForResult:String = "Ожидай результат";
		static public var usersInEventRegistered:String = "Всего зарегистрировано участников";
		static public var youWin:String = "Поздравляем, выигрыш твой!";
		static public var checkYourAccount:String = "Проверь свой счет в Dukascopy Bank";
		static public var openAccountToGet:String = "Для получения денег открой счёт!";
		static public var youLose:String = "К сожалению сегодня ты не выиграл";
		static public var buttonJoin:String = "Принять участие";
		static public var tryAgain:String = "Попробуй ещё!";
		static public var promoEventTitleIphone:String = "Просто нажми на кнопку и выигрывай iPhone X";
		
		static public var promoEvent_type_money_text_1:String = "Участвовать могут все";
		static public var promoEvent_type_money_text_2:String = "Розыгрыш осуществляется каждый день в XX:XX";
		static public var promoEvent_type_money_text_3:String = "Выигрыш будет переведён на твой счёт в Dukascopy Bank";
		
		static public var promoEvent_type_prize_text_1:String = "Участвовать могут пользователи которые открыли счёт в Dukascopy Bank"
		static public var promoEvent_type_prize_text_2:String = "Розыгрыш осуществляется каждый месяц XX числа"
		static public var promoEvent_type_prize_text_3:String = "С победителем свяжутся по телефону"
		static public var iphoneX:String = "smartphone";
		static public var textLottery:String = "Lo";
		static public var weWillCallYou:String = "Мы свяжемся с тобой для уточнения деталей вручения приза";
		static public var newEventSoon:String = "Новый конкурс уже скоро!";
		static public var user:String = "User";
		static public var discuss:String = "Discuss";*/
		
		
		
		
		
		static public var noEvents:String = "No events";
		static public var events:String = "Events";
		static public var promoEventTitle:String = "Jump in and get %@";
		static public var promoEventText3:String = "Your loyalty bonus will be transferred to your account in Dukascopy Bank";
		static public var promoEvent:String = "Promotion event";
		static public var promoJoin:String = "Participate!";
		static public var youAlreadyInEvent:String = "You are already participating";
		static public var waitForResult:String = "Wait for result";
		static public var usersInEventRegistered:String = "Total registered users";
		static public var youWin:String = "You win!";
		static public var checkYourAccount:String = "Check your account in Dukascopy Bank";
		static public var openAccountToGet:String = "In order to receive your loyalty bonus please open account in Dukascopy Bank";
		static public var youLose:String = "You lost";
		static public var buttonJoin:String = "Participate";
		static public var tryAgain:String = "Try again";
		static public var promoEventTitleIphone:String = "Qualify yourselves and get top smartphone";
		
		static public var promoEvent_type_money_text_1:String = "Everyone can participate";
		static public var promoEvent_type_money_text_2:String = "The bonus will be assigned daily at 15:01 GMT";
		static public var promoEvent_type_money_text_3:String = "Your loyalty bonus will be transferred to your account in Dukascopy Bank";
		
		static public var promoEvent_type_prize_text_1:String = "You can qualify yourselves only if you have an account with Dukascopy Bank"
		static public var promoEvent_type_prize_text_2:String = "The bonus will be assigned in the end of the month"
		static public var promoEvent_type_prize_text_3:String = "Chosen person will be contacted directly"
		static public var iphoneX:String = "smartphone";
		static public var textLottery:String = "Loyalty Bonuses";
		static public var weWillCallYou:String = "We will contact you directly";
		static public var newEventSoon:String = "New event soon!";
		static public var user:String = "User";
		static public var discuss:String = "Discuss"; 

		
		static public var linkNewCard:String = "Link new card";
		
		static public var currency_AUD : String = "Australian dollar";
		static public var currency_CAD : String = "Canadian dollar";
		static public var currency_CHF : String = "Swiss franc";
		static public var currency_CZK : String = "Czech koruna";
		static public var currency_DKK : String = "Danish krone";
		static public var currency_EUR : String = "European euro";
		static public var currency_GBP : String = "Pound sterling";
		static public var currency_HKD : String = "Hong Kong dollar";
		static public var currency_HUF : String = "Hungarian forint";
		static public var currency_ILS : String = "Israeli new shekel";
		static public var currency_JPY : String = "Japanese yen";
		static public var currency_MXN : String = "Mexican peso";
		static public var currency_NOK : String = "Norwegian krone";
		static public var currency_NZD : String = "New Zealand dollar";
		static public var currency_PLN : String = "Polish zloty";
		static public var currency_RUB : String = "Russian ruble";
		static public var currency_SEK : String = "Swedish krona";
		static public var currency_SGD : String = "Singapore dollar";
		static public var currency_TRY : String = "Turkish lira";
		static public var currency_USD : String = "United States dollar";
		static public var currency_ZAR : String = "South African rand";
		static public var currency_CNH : String = "Chinese yuan";
		static public var currency_RON : String = "Romanian leu";
		static public var currency_DCO : String = "Dukascoin";
		
		static public var approveTerms:String="Approve terms";
		static public var approveChannel:String = "Approve channel";
		static public var moveToSpam:String = "Move to spam";
		static public var spamChannelsNotification:String = "Please be aware that content in SPAM section is not moderated. Would you like to proceed?";
		static public var transferMoneyToPhoneNumber:String = "Transfer money to phone number";
		static public var calls:String = "Calls";
		static public var win:String = "Win!";
		static public var me:String = "Me";
		static public var bots:String = "Bots";
		static public var pressToStartVerification:String = "PRESS TO START ID VERIFICATION";
		static public var letsDoVerificationLater:String = "LET'S DO VERIFICATION LATER";
		static public var botMenuText:String = "Show menu";
		static public var uses:String = "uses";
		static public var yourName:String = "Your name";
		static public var textContinue:String = "Continue";
		static public var enterYourNameToCreateAccount:String = "Please enter your name to set up Dukascopy account";
		static public var wrongPromoCode:String = "Wrong code";
		static public var youInJail:String = "You are in jail";
		static public var youcantParticiparteInEventJailed:String = "To participate in event you need to get out of jail";
		
		static public var youInBan:String = "You are banned";
		static public var youcantParticiparteInEventBanned:String = "To participate in event you need to be unbanned";
		static public var openBankAccount:String = "Open Bank account";
		static public var noBankAccount:String = "No Bank account";
		static public var noCallsAvailable:String = "No calls available";
		static public var toPerfomACall:String = "To perfom a call, you need to create a chat with person first.";
		static public var youcantParticiparteInEventNoBankAccount:String = "To participate in event you must have Bank account";
		static public var banned:String = "Banned";
		static public var permanentBaned:String = "Permanent ban";
		static public var positionDocumentInFrame:String = "Please take your passport or ID card and scan MRZ (machine readable zone)";
		static public var subscribers:String = "Subscribers";
		static public var scanDocumentDescription:String = "Please, take a photo of your document before we can start";
		static public var example:String = "Example";
		static public var readyToCall:String = "Ready";
		static public var photoUploadSuccess:String = "Photo uploaded, press 'Ready' to begin";
		static public var reshootPhoto:String = "Reshoot photo";
		static public var botsGroupActive:String = "Active";
		static public var botsGroupMy:String = "My bots";
		static public var botsGroupBank:String = "Dukascopy";
		static public var botsGroupOther:String = "Under construction";
		
		static public var readyForIDVerification:String = "I`m ready for ID verification";
		static public var letsDoItLater:String = "Let`s do verification later";
		
		static public var showMeMainMenu:String = "Show me main menu";
		static public var showMeInvestmentMenu:String = "Show me investments menu";
		static public var showMeCurrentTransactionMenu:String = "Show me current transaction menu";
		static public var transferMoneyTo:String = "Transfer money to";
		static public var startVideoStream:String = "Начать трансляцию";
		static public var stopVideoStream:String = "Завершить трансляцию";
		static public var youStreaming:String = "Вы ведёте трансляцию";
		static public var cameraPermission:String = "To send an image, you must provide permissions to Camera";
		
		static public var promoEventsRulesDialogText:String = "Daily contest. You may take part in the Daily contest and win 10 € (hereinafter – the Daily Prize) even if you don’t have a Dukascopy Swiss bank account. Every day the Daily Prize winner is selected randomly among those who participated in Daily contest.  We will credit Daily Prize to your Dukascopy Swiss bank account or froze it until you open account. In addition, we aware you that  Apple Inc. does not involve, participate, sponsor or otherwise endorse into any contest within Dukascopy Connect.\n\nMonthly contest. If you have Dukascopy Swiss bank account you may take part in the Monthly contest and win the Monthly Prize. Every month the Monthly Prize winner is selected randomly among those who participated in the Monthly contest. If you do not have Dukascopy Swiss bank account you will be asked to open it before participating in the Monthly contest. Dukascopy may ship Monthly Prize to you but is not obliged to do it.\n";
		static public var sendByCart:String = "card operation";
		static public var inviteYourFriend:String = "Invite your friend";
		static public var expectedIncome:String = "Expected income";
		static public var friendsEnteredYourCode:String = "Friends which entered your code";
		static public var remind:String = "Remind";
		static public var remindUserRegister:String = "Do not forget to open an account to get 5 EUR";
		static public var questionExpired:String = "Question expired";
		static public var expiredQuestionDescription:String = "Unfortunately your question has expired.";
		static public var buyQuestionProlong:String = "Prolong for 3 days by paying 1 EUR";
		static public var prolong:String = "Prolong";
		static public var questionProlongSuccess:String = "Your question has been prolonged for 3 days!";
		static public var questionProlonged:String = "Question prolonged";
		static public var sendFlower:String = "Send a flower";
		static public var rtoTitle:String = "Open web view";
		static public var setFlowerDuration:String = "Gift duration";
		static public var flowers:String = "Flower";
		static public var makeSelfie:String = "Сделайте селфи";
		static public var documentPhoto:String = "Сфотографируйте документ";
		static public var idCardMrz:String = "Сосканируйте MRZ";
		static public var youWantToStopVI:String = "Вы хотите завершить видеоидентификацию?";
		static public var selectFlower:String = "Select flower to send";
		static public var flowerSent:String = "Flower sent";
		static public var flowerBy:String = "Flower from";
		static public var fromText:String = "from";
		static public var sendMoneyInfoSwiss:String = "Please note that Send Money option transfers funds between Swiss Payments Accounts only";
		static public var sendMoneyInfoEurope:String = "Please note that Send Money option transfers funds between European Payments Accounts only";
		static public var selectCity:String = "Choose city";
		static public var find:String = "Find";
		static public var yourLocation:String = "Your location";
		static public var begin:String = "Begin";
		static public var accountOpening:String = "Account opening";// Oткрытие счёта";
		static public var scanMrzDescription:String = "Please take your passport or ID card and scan MRZ (machine readable zone)";//"Для начала возьмите паспорт и наведите камеру на MRZ (машинно-читаемая зона внизу документа)";
		static public var needPaymentsAccount:String = "Please open bank account first";
		static public var mrzScanAlreadyStarted:String = "Document scanning already started";
		static public var mrzScanInitFailed:String = "Document scanning init error, please contact support";
		static public var mrzScanNeedPermission:String = "Please provide camera permission to scan document";
		static public var mrzScanNoDocumentFound :String= "No document found, plese try again";
		static public var mrzScanCritError:String = "Document scanning critical error, please contact support";
		
		static public var cityGeneva:String = "Geneva";
		static public var cityRiga:String = "Riga";
		static public var cityKiev:String = "Kiev";
		static public var cityMoscow:String = "Moscow";
		static public var citySaintPetersburg:String = "Saint Petersburg";
		static public var cityHongKong:String = "Hong Kong";
		static public var cityShanghai:String = "Shanghai";
		static public var cityKualaLumpur:String = "Kuala Lumpur";
		static public var cityTokyo:String = "Tokyo";
		static public var cityDubai:String = "Dubai";
		
		/*static public var notaryTitle:String = "Регистрация аккаунта по почте происходит в 3 этапа";
		static public var notaryStep1:String = "Заверить копию пасспорта у нотариуса";
		static public var notaryStep2:String = "Отправить заверенную копию пасспорта по почтовому адресу:";
		static public var notaryStep3:String = "Получить 2 EUR";
		static public var officeDefaultAddress:String = "";
		
		static public var address_kiev:String = "Degtiarivska str. 27-T letter A, 04119, Kiev, Ukraine";
		static public var address_moscow:String = "2 M. Cherkaskiy per., 109012, Moscow, Russia";
		static public var address_geneva:String = "ICC, Route de Pré-Bois 20, CH-1215 Geneva 15, Switzerland";*/
		
		static public var notEnoughAssets:String = "Not enough assets on selected account";
		static public var winnerConfirm:String = "Choose a winner";
		
		
		static public var NOTARY_EXPLAIN:String = "";/* "Для завершения открытия счёта осталась пара шагов:<BR><BR>" +
												  "Заверить копию паспорта у нотариуса.<BR><BR>"+
												  "Отправить заверенную копию паспорта и лист с ФИО (Фамилия Имя Отчество) и номером телефона<BR><BR>"+
												   "по ниже указанному адресу:<BR><BR>%addr%<BR><BR>"+
												   "После успешного открытия счёта получить компенсацию плюс 3 eur к ожидаемым вознаграждениям.";*/
		
		static public var NOTARY_EXPLAIN_TITLE:String = "Для завершения открытия счёта осталась пара шагов:";
		static public var NOTARY_EXPLAIN_STEP_1:String = "Заверить копию паспорта у нотариуса.";
		static public var NOTARY_EXPLAIN_STEP_2:String = "Вложить в конверт заверенную копию паспорта."
		static public var NOTARY_EXPLAIN_STEP_3:String = "Отправить конверт по ниже указанному адресу:<BR><BR>%addr%";
		static public var NOTARY_EXPLAIN_STEP_4:String = "После успешного открытия счёта получить компенсацию плюс 3 eur к ожидаемым вознаграждениям.";
		 
		static public var ADDR_MOSCOW:String = "Dukascopy Bank SA<BR>М. Черкасский пер., 2<BR>"+
			"Москва, Россия, 109012";
	
		static public var ADDR_KIEV:String = "Dukascopy Bank SA<BR>Ул. Дегтяревская, 27-Т<BR>"+
			"Киев, Украина, 04119";
			
		static public var ADDR_GENEVE:String = "Dukascopy Bank SA<BR>ICC, Route de Pré-Bois 20,<BR>"+
			"CH-1215 Geneva 15, Switzerland";
		
		static public var monday_short:String = "Mo";
		static public var tuesday_short:String = "Tu";
		static public var wednesday_short:String = "We";
		static public var thursday_short:String = "Th";
		static public var friday_short:String = "Fr";
		static public var saturday_short:String = "Sa";
		static public var sunday_short:String = "Su";
		static public var hoursShort:String = "h.";
		static public var minutesShort:String = "m.";
		
		static public var monday:String = "Monday";
		static public var tuesday:String = "Tuesday";
		static public var wednesday:String = "Wednesday";
		static public var thursday:String = "Thursday";
		static public var friday:String = "Friday";
		static public var saturday:String = "Saturday";
		static public var sunday:String = "Sunday";
		static public var VIScheduleDescription:String = "Please be avaiable in selected time. Dukascopy Connect must be activated, also please provide good internet connection. <br/><br/>Our specialist will contact you in given time to start ID verification. <br/><br/>If you don't appear in the chat after 5 minutes your appointment will be lost.";
		static public var chooseVerificationDay:String = "Please choose day and time for ID verification";
		static public var verificationTime:String = "Choosen time for ID verification";
		static public var cancelAppointment:String = "Cancel appointment";
		static public var appointmentTime:String = "Your appointment time for ID verification:";
		static public var makeAppointment:String = "Make an appointment";
		
		static public var promoEvent_type_money200_text_1:String = "Участвовать могут пользователи, которые открыли счёт в Dukascopy Bank и пригласили 3 друзей с открытым счётом";
		static public var promoEvent_type_money200_text_2:String = "Розыгрыш осуществляется 1 раз в 2 недели";
		static public var promoEvent_type_money200_text_3:String = "Победитель получает деньги сразу на счёт";
		
		static public var promoEvent_type_money100_text_1:String = "Участвовать могут пользователи, которые открыли счёт в Dukascopy Bank";
		static public var promoEvent_type_money100_text_2:String = "Розыгрыш осуществляется каждую неделю";
		static public var promoEvent_type_money100_text_3:String = "Победитель получает деньги сразу на счёт";
		
		static public var promoEvent_type_money5_text_1:String = "Участвовать могут пользователи, которые установили аватар";
		static public var promoEvent_type_money5_text_2:String = "Розыгрыш осуществляется каждый день";
		static public var promoEvent_type_money5_text_3:String = "Победитель получает деньги сразу на счёт";
		
		static public var youcantParticiparteInEventNeedAccountAndFriends:String = "Для участия необходимо открыть счёт в Dukascopy Bank и пригласить 3 друзей";
		
		static public var inviteFriends:String = "Invite Friends";
		static public var accountOpened:String = "Счёт открыт";
		static public var paidQuestionAward:String = "911 paid question award";
		static public var create:String = "Create";
		static public var newSellCoinLot:String = "Create new lot";
		static public var pricePerCoin:String = "Price per coin";
		static public var executeFullOrder:String = "Execute only full order";
		static public var expirationTime:String = "Expiration time";
		static public var privateOrder:String = "Private order";
		static public var selectDate:String = "Select date";
		static public var selectDateFirst:String = "Select date first";
		static public var selectTime:String = "Select time";
		static public var dukascoinMarketplace:String = "Dukascoin Marketplace";
		static public var payWithCard:String = "Pay with card";
		static public var makeACardPayment:String = "Make a card payment";
		static public var addBid:String = "+ BID";
		static public var addAsk:String = "+ ASK";
		static public var bid:String = "Bid";
		static public var ask:String = "Ask";
		static public var fillOrKill:String = "Fill or kill";
		static public var goodTill:String = "Good till";
		static public var transferCoinsToPhoneNumber:String = "Transfer coins to phone number";
		static public var transferCoins:String = "Transfer coins";
		static public var transferCoinsTo:String = "Transfer coins to";
		static public var rewardsDeposit:String = "Reward deposit";
		static public var rewardsDepositOptions:String = "Reward deposit options";
		static public var DCO:String = "DUK+";
		static public var rewardsDepositMinAmount:String = "Minimum amount is %@ DUK+";
		static public var rewardsDepositMaxAmount:String = "Maximum amount is %@ DUK+";
		static public var clear:String = "Clear";
		static public var avaliable:String = "Avaliable";
		static public var expirationDate:String = "Expiration date";
		static public var estimatedExpirationDate:String = "Estimated expiration date";
		static public var depositReward:String = "Deposit reward";
		static public var goodTillCancel:String = "Good till cancel";
		static public var publicOffer:String = "Public offer";
		static public var preview:String = "Preview";
		static public var lotForSale:String = "Add “SELL” Lot";
		static public var lotForBuy:String = "Add “BUY” Lot";
		static public var paymentAmount:String = "Payment amount";
		static public var youWillGet:String = "You will get";
		static public var quantityToBuy:String = "Quantity to buy";
		static public var quantityForSale:String = "Quantity for sale";
		static public var restartForApply:String = "You must restart to apply these changes.";
		static public var priceForCoin:String = "Price for coin";
		static public var dukacoinsToBuy:String = "Dukascoins to buy";
		static public var amountToPay:String = "Amount to pay";
		static public var amountToGet:String = "Amount to get";
		static public var coinsToSell:String = "Coins to sell";
		static public var amountToBuy:String = "Amount to buy";
		static public var maximum:String = "max.";
		static public var transactionComplete:String = "Transaction complete";
		static public var bought:String = "Bought";
		static public var sold:String = "Sold";
		static public var cost:String = "Cost";
		static public var youReceived:String = "Received"; // You received
		static public var coinsDeposit:String = "DUK+ deposit from blockchain";
		static public var investFromBC:String = "Invest from blockchain";
		static public var coinsWithdrawal:String = "DUK+ withdrawal to blockchain";
		static public var deliveryToBC:String = "Delivery to blockchain";
		static public var deliveryToBCAddress:String = "Blockchain address for delivery";
		static public var deliveryToBCAddressNeeded:String = "In order to get access to external blockchain operations you need to register a blockchain address that will be used for withdrawal operations.";
		static public var senderWalletAddress:String = "My blockchain wallet address";
		static public var of:String = "of";
		static public var amountToSell:String = "Amount to sell";
		static public var avaliableLots:String = "Avaliable lots";
		static public var averagePrice:String = "Average price";
		static public var bestPrice:String = "Best price";
		static public var worstPrice:String = "Worst price";
		static public var limitWorstPrice:String = "Limit worst price";
		static public var totalEstimatedEarn:String = "Total estimated income";
		static public var totalEstimatedCost:String = "Total estimated cost";
		static public var vididWelcomeMSG:String = "Last step towards your personal MCA account is video identification. Please, prepare your document (valid passport or ID card) and press START button when you are ready to proceed.";
		static public var txHash:String = "Transaction ID";
		static public var alreadySold:String = "Already sold";
		static public var alreadyBought:String = "Already bought";
		static public var failed:String = "failed";
		static public var succesfullyBought:String = "Successfully bought";
		static public var succesfullySold:String = "Successfully sold";
		static public var videoidentificationLateDescription:String = "Sorry you have missed your appointment for video identification. Would you like to reschedule it?";
		static public var needMoreReferrals:String = "You need to invite more friends that will open the account";
		static public var amountAvaliable:String = "Amount avaliable";
		static public var fiatReward:String = "Fiat Reward";
		static public var rewardFiatDescription:String = "The standard Fiat Deposit Reward rate for a one-year deposit is expected to be equal to EUR 0,5 for each Dukascoin allocated in accordance with the terms and conditions of the Fiat Reward deposit program.";
		static public var rewardCoinDescription:String = "Please note that if you close the deposit before expiration date you will pay 5% penalty and reward will be revoked.";
		static public var reward:String = "Reward";
		static public var enterAmount:String = "Enter amount";
		static public var youCantYourOrder:String = "You can`t process with your own orders";
		static public var amount:String = "Amount";
		static public var mine:String = "Mine";
		static public var buyAtMarketPrice:String = "Buy at market price";
		static public var sellAtMarketPrice:String = "Sell at market price";
		static public var avaliableSoon:String = "Available soon";
		static public var minimum:String = "minimum";
		static public var askSide:String = "ASK SIDE";
		static public var bidSide:String = "BID SIDE";
		static public var myOrders:String = "My orders";
		static public var all:String = "All";
		static public var alertConformDeleteOrder:String = "Are you sure to remove this order?";
		static public var skipTheQueue:String = "Skip the queue!";
		static public var willWait:String = "Will wait";
		static public var ohNo:String = "Oh no!";
		static public var getFastTrack:String = "To get fast track";
		static public var getFastTrackButton:String = "Get fast track";
		static public var fastTrackDescription:String = "To verify if you are eligible for <b>fast track</b> we will check if the balance of your payment/credit card exeeds 10 EUR.";
		static public var queueLengthDescription:String = "There are <font color='#FA0A01'>too many</font> people in line.<br>You may wait more than <font color='#FA0A01'>60</font> min!";
		static public var largeOrderWarning:String = "The total sum of trade is larger than 100 EUR. Do you want to proceed?";
		static public var waitingForIdVerification:String = "Waiting for ID verification?";
		static public var fastTrackInEnglish:String = "Attention!<br>Fast Track is avaliable only in english!";
		static public var fastTrack:String = "Fast track";
		static public var fastTrackTransaction:String = "Your transaction in progress";
		static public var fastTrackInProgress:String = "Your transaction is currently in progress, please wait.";
		static public var needAvatar:String = "To participate in the event you need to upload your photo";
		static public var avatarNeeded:String = "Avatar needed";
		static public var uploadPhoto:String = "Upload photo";
		static public var coinСommission:String = "comission: 1%";
		static public var noFreeSlots:String = "All available places occupied, please choose another date";
		static public var badPriceSellDescription:String = "Are you sure to sell for %@ EUR per coin? Best price for this moment is %@";
		static public var badPriceBuyDescription:String = "Are you sure to buy for %@ EUR per coin? Best price for this moment is %@";
		static public var FOK:String = "FOK";
		static public var scan:String = "Scan";
		static public var congrats:String = "Congrats!";
		static public var fastTrackSuccess:String = "Now you have access to fast track at any moment.";
		static public var used:String = "Used:";
		static public var startChatWithConsultant:String = "Start chat with consultant...";
		static public var holder:String = "Holder:";
		static public var validThru:String = "Valid thru:";
		static public var textValidThru:String = "Valid thru";
		static public var CVV:String = "CVV:";
		static public var fastTrackProposal:String = "Tired of waiting? Get fast track";
		static public var transfer:String = "Transfer";
		static public var underageFasttrackTitle:String = "Due to limited resources, the bank is not able to serve you in a general manner.";
		static public var underageFasttrackDescription:String = "To proceed further, the bank will reserve 25 euro from your card and deposit these funds to your account upon its approval. After a successful 25 euro reservation, you will be directed to the next account opening step.";
		static public var underageFasttrackDescription1:String = "The next step of your account opening is an initial deposit of %@. To proceed, please enter your card details. The bank will reserve %@ from your card and deposit these funds to your account upon it's approval.";
		static public var cantCancelAppointment:String = "Appointment will start in less than 24h, You can`t cancel it.";
		static public var badPriceDescription:String = "Attention! This is not best price. Best price for this moment is %@";
		static public var itMayTake:String = "MRZ recognition might take up to 1 minute.";
		static public var phazeError:String = "Phaze error, please contact support";
		static public var addDescription:String = "Add description";
		static public var paidChannelCost:String = "Оплата за первый месяц 1 DUK+ будет списана с Вашего кошелька:";
		static public var comissionCoins:String = "Commission charge may wary. Minimum is 0.01 EUR. Maximum is 0.02 EUR for every 1 DUK+ sold.";
		static public var bankTutorialTitleStep1:String = "CHOOSE BANKING OPERATIONS";
		static public var bankTutorialHeaderStep1:String = "YOUR BANK ACCOUNT";
		static public var bankTutorialItemsStep1:String = "Top Up Account,Order Card,Cheap Currency Exchange,Payments,Dukascoins,Investments";
		static public var bankTutorialTitleStep2:String = "BANK ACCOUNT SUMMARY AND HISTORY";
		static public var bankTutorialHeaderStep2:String = "YOUR BANK ACCOUNT";
		static public var bankTutorialItemsStep2:String;
		static public var bankTutorialTitleStep3:String = "BUY/SELL DUKASCOINS";
		static public var bankTutorialHeaderStep3:String = "YOUR BANK ACCOUNT";
		static public var bankTutorialItemsStep3:String;
		static public var bankTutorialHeaderStep4:String = "YOUR BANK ACCOUNT";
		static public var bankTutorialTitleStep4:String;
		static public var bankTutorialItemsStep4:String = "Order VISA card,Plastic and virtual,Apple Pay/Samsung Pay";
		static public var videoIdentification:String = "Видеоидентификация";
		static public var enterAmountCurrency:String = "Enter amount and currency";
		static public var sellNotes:String = "Sell Dukascash";
		static public var buyNotes:String = "Buy Dukascash";
		static public var cryptoWallet:String = "Enter wallet:";
		static public var sellNotesDescription:String = "Описание условий продажи криптовалюты";
		static public var buyNotesDescription:String = "Описание условий покупки криптовалюты";
		static public var pastFromClipboard:String = "Paste from clipboard";
		static public var restorePasswordDescription:String = "Для восстановления пароля, впишите e-mail, который вы указали при регистрации. На него прийдёт код, который необходимо будет ввести в соответствующее поле";
		
		static public var dukasnotesBuyRequest:String = "Я хочу купить %@ %@";
		static public var dukasnotesSellRequest:String = "Я хочу продать %@ %@";
		static public var notesBCNotEnough:String = "On your blockchain wallet not enough Dukaschash.";
		static public var paymentsEnterPassTitle:String = "Your Bank Account";
		static public var restorePassword:String = "Restore password";
		static public var paymentsEnterPassDescription:String = "You must enter a password to continue";
		static public var enterCodeFromSMS:String = "Please enter code from SMS";
		static public var emailNotValid:String = "Email not valid";
		static public var codeVerificationFailed:String = "Email code verification failed";
		static public var enterCodeFromEmail:String = "Verification code sent to the %@";
		static public var tempPassSentToEmail:String = "A temporary password has been sent to the %@";
		
		static public var fcBalance:String = "Balance";
		static public var fcBalanceNew:String = "Your current average balance in %@";
		static public var fcCurrentBalanceNew:String = "Your current balance in %@";
		static public var fcAnnualReturn:String = "Annual return";
		static public var fcAnnualReturnNew:String = "Estimated Fat Catz ANNUALIZED return for %@";
		static public var fcAnnualReturnNewFC:String = "Estimated ANNUALIZED return for %@";
		static public var fcNeedToHave:String = "Need to have";
		static public var fcNeedToHaveMonthly:String = "Average monthly balance required:";
		static public var fcClientCode:String = "Your code of client in Fat Catz public register:";
		static public var fcNeedToAdd:String = "Need to add";
		static public var fcNeedToAddNew:String = "Additional coins required to participate in %@ (updated daily)";
		static public var fcExpectedIncome:String = "Expected income";
		static public var fcExpectedIncomeNew:String = "Your expected reward in %@";
		static public var pass6chars:String = "Password has to be minimum 6 chars";
		static public var passDifferent:String = "New password must be different from current";
		static public var emptyFields:String = "Fill all fields";
		
		static public var tStatCoinTotal:String = "Total";
		static public var tStatTradesBuy:String = "Buy trades";
		static public var tStatTradesSell:String = "Sell trades";
		static public var tStatTotalBuy:String = "Total bought";
		static public var tStatTotalBuyActive:String = "Total BUY amount";
		static public var tStatTotalSell:String = "Total sold";
		static public var tStatTotalSellActive:String = "Total SELL amount";
		static public var tStatCoinAvgPriceBuy:String = "Average buy price";
		static public var tStatCoinAvgPriceSell:String = "Average sell price";
		
		static public var noConnectionBot:String = "Связь потеряна, проверьте соединение и попробуйте снова";
		static public var photoPassportReady:String = "Фото документа готово";
		static public var photoSelfieReady:String = "Селфи готово";
		static public var photoGologramReady:String = "Фото голограмм готово";
		static public var viInitialMessage:String = "Вы готовы пройти видеоидентификацию?";
		static public var invoiceDescription:String = "Are you sure you want to send money to this user?";
		static public var enterDepositAmount:String = "How much coins you want to deposit?";
		static public var depositDurationText:String = "Duration";
		static public var depositRewardText:String = "Reward";
		static public var cantStartChatWithoutBankAccount:String = "You do not have enought loyalty points to perfom this actions.";
		static public var registerBlockchainAddress:String = "Registration of a blockchain withdrawal address";
		static public var registerBlockchainAddressDescription:String = "Please indicate your wallet address (based on Ethereum blockchain and supporting ERC20 tokens) that you want to be used as destination for all external Dukascoin withdrawals made from your account with Dukascopy:";
		static public var selectedBlockchainAddress:String = "My blockchain withdrawal wallet";
		static public var blockchainAddressNeeded:String = "In order to get access to external blockchain operations with Dukascoins (DUK+) you need to register a blockchain address that will be used for withdrawal operations.";
		static public var changeWallet:String = "Change";
		static public var addAddress:String = "Register";
		static public var myBlockcheinAddress:String = "My blockchain withdrawal address";
		static public var myBlockcheinAddress1:String = "Reminder: the blockchain withdrawal address you previously registered is:";
		static public var myBlockcheinAddress2:String = "This address will be used as a destination for all blockchain transfers of ETH made from your account with Dukascopy, including cases when an identified deposit has not been accepted and has to be returned.";
		static public var pleaseChooseBetterPrice:String = "Please choose better price";
		static public var suspiciousChat:String = "Suspicious chat";
		static public var suspiciousChatDescription:String = "Suspicious chat ?";
		static public var report:String = "Report";
		static public var repostSent:String = "Thank you";
		static public var userWarning:String = "%@ user(s) have already complained about this user.";
		static public var newChatWarning:String = "Be careful, do not share your login code or Bank Account password with anyone.";


		static public var notEnoughtLoyaltyPoints:String="You do not have enough loyalty points";
		static public var cantStartChatWithoutLoyaltyPoints:String = "You can't start chat with unknown person without having necessary amount of loyalty points (stars)";
		static public var cantStartCallWithoutLoyaltyPoints:String="You can't start call without having necessary amount of loyalty points (stars)";

		static public var enablePaidChat:String = "Enable paid chat mode";

		static public var addPhoto:String = "Add photo";
		static public var addTitle:String = "Add title";
		static public var addChatCost:String = "Set chat cost";
		static public var pleaseAddTitle:String = "Please fill title";
		static public var existingPaidChatsDescription:String = "paid chat enabled";
		static public var disablePaidChat:String = "Disable";
		static public var pleaseSetChatCost:String = "Please enter amount";
		static public var unsuccessChats:String = "Chats";
		static public var chooseRDVariant:String = "Please choose one of possible variants";

        static public var paidChat:String = "Paid chat transfer";

        static public var paidChatsDescription:String = "Шпиндель является основным узлом любого токарного станка. Шпиндель зажимает заготовку и вращается вместе с ней, при этом режущий инструмент перемещается в двух независимых координатах – параллельно и поперёк оси вращения заготовки. Чем мощнее конструкция шпинделя и его приводной двигатель, тем выше производительность токарного станка по скорости снятия металло-стружки с заготовки и тем более массивные детали он способен обрабатывать.";
        static public var paidChatPayDescription:String = "Оплата за доступ к чату в размере %@ будет списана с вашего счёта и переведена собеседнику";
        static public var paidChatDisclamer:String = "Дукаскопи банк не имеет отношения к данной транзакции и не несёт за неё ответственность";
		static public var unsuccessPaidChatDescription:String = "Описание попыток отрыть платный чат";

        static public var duplicateDocument:String = "Мы не можем провести обработку документа второй раз";
        static public var loginByFingerprint:String = "Use touch sensor at login?";
        static public var fingerprintTouch:String = "Please touch sensor";
        static public var official:String = "Official";

		static public var pleaseUpdateVersion:String="Please update application";

		static public var didntReceiveCode:String = "I did not receive the code";
		static public var changePhoneNumber:String = "Change phone number";
		static public var textBonusChannel:String = "Bonus Channel";

		static public var fingerprintError_tooManyAttempts:String = "Too many attempts. Fingerprint sensor disabled";
		static public var fingerprintError_hardwareUnavaliable:String = "The hardware is unavailable. Try again later";
		static public var fingerprintError_unableProcess:String = "The sensor was unable to process the current image";
		static public var fingerprintError_timeout:String = "Timeout error";
		static public var fingerprintError_noSpace:String = "Not enough storage remaining to complete the operation";
		static public var fingerprintError_sensorUnavaliable:String = "The fingerprint sensor is unavailable";
		static public var fingerprintError_systemError:String = "The provided fingerprint id was incorrect";
		static public var currentCommission:String = "Current commission";
		static public var BUY_noTranslate:String = "BUY";
		static public var SELL_noTranslate:String = "SELL";
		
		static public var iAgreeCreateOrder:String = "I agree to sell";
		static public var iDontAgree:String = "I don’t agree";
		static public var coinCommistionM1:String = "Attention: Low liquidity fee of 0.2 EUR per sold coin is additionally applied to every sell trade with a price of 1 EUR per coin or less. By finishing this sell trade, you agree to pay @1 EUR of the additional fee.";
		static public var coinCommistionM1New:String = "Attention: Low liquidity fee of 0.2 EUR per sold coin is additionally applied to every sell trade with a price of @2 EUR per coin or less. By finishing this sell trade, you agree to pay @1 EUR of the additional fee.";
		static public var coinCommistionM2New:String = "Attention: Low liquidity fee of %@1 EUR per sold coin is additionally applied to every sell trade with a price of %@2 EUR per coin or less. By finishing this sell trade, you agree to pay %@3 of the additional fee.";
		
		static public var coinTrade:String = "Coin trade";
		static public var calculation:String = "calculation...";
		static public var enterProtectionCode:String = "Enter protection code";
		static public var codeProtected:String = "Code protected";
		static public var textCVV:String = "CVV";
		static public var enterCVV:String = "Enter CVV";
		static public var duringAllTime:String = "During all time";
		static public var compliance:String = "Compliance";
		static public var downloading:String = "Downloading...";
		static public var selectPreset:String = "Select preset";
		static public var saveTransactionTemplate:String = "Save template";
		static public var enterTemplateName:String = "Enter template name";
		static public var moneyTransferToPhone:String = "перевод на номер телефона";
		static public var moneyTransferToContact:String = "перевод контакту";
		static public var unansweredCall:String = "Unanswered call";
		static public var dontAskAgain:String = "Don't ask again";
		static public var pendingTransactions:String = "Pending transactions";
		static public var expire:String = "expire";
		
		static public var rateSupportbot:String = "Have you received an answer to your question?";
		static public var errorDepositSmallAmount:String = "Amount should not be less than 5 DUK+";
		static public var reachedIncomingLimit:String = "You have reached incoming limit.";
		static public var toBeCredited:String = "To be credited";
		static public var useFaceId:String = "Use Face Id?";
		static public var newMessage_1:String = "новое сообщение";
		static public var newMessage_2:String = "новых сообщения";
		static public var newMessage_5:String = "новых сообщений";
		static public var youPendingBalance:String = "Your pending balance";
		static public var startChatWithBankConsultant:String = "Start chat with Bank consultant";
		static public var roadmap_initialDeposit:String = "Initial deposit";
		static public var roadmap_fillRegistrationForm:String = "Fill registration form";
		static public var roadmap_documentScan:String = "Scan document";
		static public var roadmap_selectCard:String = "Select card";
		static public var roadmap_pressToStart:String = "Press to start";
		static public var roadmap_waiting:String = "Waiting";
		static public var roadmap_identityVerification:String = "Identity Verification";
		static public var roadmap_approveAccount:String = "Approve account";
		static public var roadmap_failed:String = "Failed";
		static public var roadmap_completed:String = "Completed";
		static public var miss:String = "Miss";
		static public var missRulesTitle:String = "Become Miss Dukascopy and win money every month!";
		static public var missRulesDialogText:String = "Miss Dukascopy is a beauty contest held by Dukascopy Bank since 2013. Raymond Weil, Patara Geneve, Escada, Leonard Paris, Aubade, Benoit de Gorski and many other renowned brands have been among its sponsors and partners. In 2020 the contest have become even more social than ever. You can become our Miss Dukascopy 2020 by being an active user of 911 application. Chat with people, send and receive money and gifts from other users and win bonus points! The main criteria of a winner is the amount of points she receives for getting Flowers in the app. How to win? 1. Go to miss.dukascopy.com(если можно, ссылкой), submit your application and 5 photos. 2. Wait for your application to be approved. 3. Receive flowers from other users as a gift in 911 app. 4. Win the title of Miss Month, money prize and a chance to become Miss Dukascopy 2020! What money prize do you get? You get back the money spent by users on all flowers in the application this month. 1st place: 5/20 of all DUK+ spent on flowers this month 2d place: 4/20 of all DUK+ 3d place: 3/20 of all DUK+ 4th place: 2/20 of all DUK+ 5th place: 1/20 of all DUK+ 5 more DUK+ are reserved for Miss Dukascopy 2020 every month. The girl who receives the biggest amount of flowers in the year gets this title and money prize. Good luck!";
		static public var selectCardDescription:String = "The next step of your account opening at Dukascopy Bank is to order a MasterCard or VISA virtual card.<br/><br/>Please select a type and currency of your new virtual card";
		static public var selectCard:String = "Select card";
		static public var allUsers:String = "All users";
		static public var contestHistory:String = "Contest history";
		static public var backToContest:String = "Back to Miss";
		static public var selectCardCurrency:String = "Select currency of the card";
		static public var cardChargeAmount:String = "Card charge amount";
		static public var cardStatement:String = "Card statement";
		static public var accountStatement:String = "Account statement";
		static public var select:String = "Select";
		static public var mcaOpenRestricted:String = "It is not possible to open an MCA account for you at the moment. Please contact Support team representative for details";
		static public var initialDepositDescription:String = "The next step of your account opening is an initial deposit of %@.<br/>To proceed, please enter your card details. The Bank will withdraw %@ from your card and deposit these funds to your account upon its approval.";
		static public var initialDeposit:String = "Initial deposit";
		static public var payInvoice:String = "Send money by invoice";
		static public var linkCard:String = "Link card";
		static public var selectedCurrencyIs:String = "Selected currency is";
		static public var textExpires:String = "Expires";
		static public var textFiatReward:String = "Fiat reward";
		static public var textCoinReward:String = "Coin reward";
		static public var textTime:String = "Time";
		static public var cardAlreadyOrdered:String = "Card with this currency already ordered";
		static public var myDevices:String = "My devices";
		static public var sendYourFeedback:String = "Send your feedback";
		static public var plastic:String = "Plastic";
		static public var virtual:String = "Virtual";
		static public var textBinary:String = "Binary";
		static public var textManaged:String = "Managed";
		static public var textStandardCurrent:String = "Standard current";
		static public var textFundedByETH:String = "Funded by ETH";
		static public var textFundedByBTC:String = "Funded by BTC";
		static public var textFundedByDUK:String = "Funded by DUK+";
		
		static public var textFeedbackDesc:String = "Have you received an answer to your question?";
		static public var textFeedbackDesc1:String = "Send Your feedback";
		static public var textFeedbackYes:String = "Yes";
		static public var textFeedbackNo:String = "No";
		static public var textFeedbackSend:String = "Send";
		static public var textFeedbackCancel:String = "Cancel";
		static public var confirmSendMoney:String = "I want to send money to this user";
		static public var sendMoneyConfirm:String = "Are you sure you want to send money to this user? <font color='#cd3f43'><b>%@ will be charged from your card</b></font> in favor of your counterparty";
		static public var okSend:String = "Yes, send";
		static public var sendMoneyQuestion:String = "Send money?";
		static public var sendMoneyErrorNoAccount:String = "You cannot send money to users who do not have a Dukascopy bank account";
		static public var fingerprintLogin:String = "Fingerprint login";
		static public var useFingerprint:String = "Use fingerprint";
		static public var numberCopied:String = "Number copied";
		static public var IBANCopied:String = "IBAN copied";
		
		static public var resetDate1Jan:String = "1st January";
		static public var resetDate1Apr:String = "1st April";
		static public var resetDate1Jul:String = "1st July";
		static public var resetDate1Oct:String = "1st October";
		
		static public var cantSendVoiceToSupport:String = "You can't send voice message to support chat";
		
		static public var commisssionWaiting:String = "Commission is being calculated, please wait...";
		
		static public var PURPOSE_OF_MONEY_TRANSFER_TO_RELATIVES:String = "Transfer to relatives";
		static public var PURPOSE_OF_MONEY_TRANSFER_TO_FRIENDS:String = "Transfer to friends";
		static public var PURPOSE_OF_MONEY_TRANSFER_FOR_GOODS:String = "Payment for goods / services";
		static public var PURPOSE_OF_MONEY_TRANSFER_OTHER:String = "Other";
		static public var SPECIFY_PURPOSE_OF_MONEY_TRANSFER_TITLE:String = "Please specify the purpose of money transfer";
		static public var referralCode:String = "Referral code";
		static public var wrongPassword:String = "Wrong password";
		static public var passwordVerificationLocked:String = "Password verification is locked. Try again later.";
		static public var currentPasswordWrong:String = "Current Password is wrong";
		static public var passwordNotMeetComplexity:String = "New password does not meet complexity requirements";
		
		static public var increaseLimits:String = "Increase limits";
		static public var share:String = "share";
		static public var coin:String = "coin";
		static public var selectCardDelivery:String = "Select card delivery method";
		static public var cardDeliveryExpress:String = "Express (up to 2 weeks)";
		static public var cardDeliveryStandard:String = "Standard (up to 4 weeks)";
		static public var upsCardDeliveryDescription:String = "We advise Express (UPS) delivery if your address is outside Europe";
		
		static public var filter_moneyWithdraw:String = "Money Withdraw";
		static public var filter_exchange:String = "Exchange";
		static public var filter_incomingTransfer:String = "Incoming transfer";
		static public var filter_outgoingTransfer:String = "Outgoing transfer";
		static public var filter_deposit:String = "Deposit";
		static public var filter_orderCard:String = "Order of prepaid card";
		static public var filter_investment:String = "Investment";
		static public var filter_coinTrade:String = "Coin trade";
		static public var filter_termDeposit:String = "Term Deposit";
		static public var filter_fees:String = "Fees";
		static public var filter_transferAffiliate:String = "Transfer (Affiliate Account)";
		static public var filter_tradeAffiliate:String = "Trade (Affiliate Account)";
		static public var filter_completed:String = "Completed";
		static public var filter_pending:String = "Pending";
		static public var filter_cancelled:String = "Cancelled";
		static public var selectCommissionAccount:String = "To charge commission for delivery from:";
		static public var filter_date:String = "Date";
		static public var filter_account:String = "Account";
		static public var filter_status:String = "Status";
		static public var filter_type:String = "Type";
		static public var testReset:String = "Reset";
		
		static public var passwordProtected:String = "Protected by code";
		
		static public var streetAddress:String = "Street address";
		static public var city:String = "City";
		static public var postalCode:String = "Postal code ZIP";
		static public var country:String = "Country";
		static public var deliveryChangeReason:String = "Delivery address change reason";
		static public var reason_temporary_address:String = "This is a temporary address where I am in business trip / vacation / studying, etc.";
		static public var reason_new_address:String = "This is my new primary residence address";
		static public var reason_secondary_address:String = "This is my secondary residence address where I spend less than 6 months a year";
		static public var reason_trusted_address:String = "This is the address of a trusted/close person and my residence address is unchanged";
		static public var reason_work_addresses:String = "This is one of my work addresses";
		static public var investmentDeliveryLink:String = "Find more information on the <font color='#5DC269'><a href='https://www.dukascopy.bank/swiss/faq/?getloc=faq13c13'>investment delivery procedure</a></font>";
		static public var deliverAll:String = "Deliver all";
		static public var enlargeText:String = "Enlarge text (double tap)";
		static public var reduceText:String = "Reduce text";
		static public var requestMoney:String = "Request money";
		static public var requestMoneyDesc:String = "Send the link to the contact to request money";
		static public var shereLinkLifeTime:String = "Link will be active for 7 days";
		static public var textShare:String = "Share";
		static public var privacySettings:String = "Privacy Settings";
		static public var privacy_whoCanCreateChats:String = "Who can create private chats with me";
		static public var privacy_whoCanAddToChats:String = "Who can add me to chats";
		static public var privacy_whoCanCallMe:String = "Who can call me";
		static public var privacy_whoCanFindMe:String = "Who can find me";
		static public var privacy_noOne:String = "No one";
		static public var privacy_verified:String = "Users verified by the bank";
		static public var privacy_all:String = "All";
		static public var exchangeCredit:String = "Credit account";
		static public var exchangeDebit:String = "Debit account";
		static public var saveToGallery:String = "Save image";
		static public var fromMultiAccount:String = "From Multi-currency account";
		static public var toSavingAccount:String = "To Saving account";
		static public var toTradingAccount:String = "To Trading account";
		static public var fromTradingAccount:String = "From Trading account";
		static public var fromSavingAccount:String = "From Saving account";
		static public var toMultiAccount:String = "To Multi-currency account";
		static public var savings:String = "Savings";
		static public var noCoinsAccount:String = "You do not have Dukascoins account. Please create it before buy some features.";
		static public var youCalledUser:String = "You called %@";
		static public var userCalledYou:String = "%@ called you";
		static public var userDidnotAnswer:String = "%@ did not answer";
		static public var youMessedCall:String = "You missed a call";
		
		static public var coinBuyLowPriceWarning:String = "Please be informed that sellers are reluctant to make deals at %@1 EUR/DUK+ or lower due to Low liquidity fee of %@2 EUR per DUK+ they pay. Consider placing your buy order at %@3 EUR/DUK+ or higher to increase your chances to acquire Dukascoins.";
		static public var confirmMyOrder:String = "Confirm my order";
		static public var firstTransactionFee:String = "First transaction fee";
		static public var lowLiquidityFee:String = "Low liquidity fee";
		static public var commissionFee:String = "Commission fee";
		static public var totalComissionFee:String = "Total fee";
		static public var launchPlatform:String = "Launch platform";
		
		static public var roadmap_solvencyCheck:String = "Solvency Check";
		static public var selectVerificationMethod:String = "Select one of the following verification methods";
		static public var verificationMethods:String = "Verification methods";

		static public var iosNotificationUnreadPrivate:String="You have %i unread messages from %@";
		static public var iosNotificationUnreadGroup:String="You have %i unread messages in group chats";
		
		
		static public var solvency_card_deposit:String = "Card deposit";
		//deprecated
	//	static public var solvency_card_deposit_description:String = "Deposit 30 EUR from your card";
		
		static public var solvency_crypto_deposit:String = "Crypto deposit";
		//deprecated
	//	static public var solvency_crypto_deposit_description:String = "Deposit amount in crptocurrency equal to 30 EUR";
		
		static public var solvency_ask_friend:String = "Ask your friend";
		//deprecated
	//	static public var solvency_ask_friend_description:String = "You can ask your friends to send you 30 EUR";
		
		
		
		static public var toVerifyCryptodepositYouNeed:String = "To verify with a cryptocurrency deposit you need to";
		
		static public var openAccountZBX:String = "Open an account with ZBX.";
		//deprecated
	//	static public var depositeOnZBXAccount:String = "Deposit the equivalent of 30 EUR or more in any cryptocurrency to you ZBX account.";
		static public var grandPermissionToZBXAccount:String = "Grant a permission to Dukascopy Bank to check the balance of your account in ZBX.";
		static public var verifyWithCtyptoDeposit:String = "Verify with Crypto Deposit";
		static public var askAFriend:String = "Ask a friend";
		//deprecated
	//	static public var askFriendDescription:String = "You can ask a friend to send you 30 EUR directly in the chat. After you receive the requested amount, you will be automatically redirected to the next step. Click on the button bellow to see which of your contacts already has a Multi-Currency account with Dukascopy.";
		static public var solvencyVerificatoinSuccess:String = "Solvency verification has been successfully completed";
		static public var solvencyVerificatoinFail:String = "Solvency verification cannot be completed. Make sure you have an active account with ZBX or that the balance is sufficient to pass solvency check";
		static public var zbxRequestTryLater:String = "You have already request a balance few moments ago, please try again later";
		static public var minimumLotAmount:String = "Lot amount cannot be less than minimal euro value (%@ €)";
		static public var roadmap_change:String = "Change";
		
		static public var textTotal:String = "Total";
		static public var textReserved:String = "Reserved";
		static public var textFree:String = "Free";
		static public var textDukascoin:String = "Dukascoin";
		static public var textEuro:String = "Euro";
		static public var textOrders:String = "orders";
		static public var callFromVidid:String = "Call from Dukascopy Bank";
		static public var videoidentificationStart:String = "Video Identification started";
		static public var videoidentificationFail:String = "Video Identification fail";
		static public var videoidentificationComplete:String = "Video Identification completed";
		
		static public var textInBank:String = "In Bank";
		static public var textInBlockchain:String = "In Blockchain";
		static public var textBlockedForStaking:String = "Blocked for staking:";
		static public var textBlockchainInfoURL:String = "https://etherscan.io/address/";
		static public var cardDeliveryDescriptionExpress:String = "The card will be delivered to you by the UPS courier. Please note that depending on the destination country the delivery can take up to two weeks.";
		static public var cardDeliveryDescriptionStandard:String = "The card will be delivered to you via a registered letter by the Swiss Post without tracking number. Please note that due to the pandemic restrictions shipments may be processed with delays.";
		static public var maintenanceWork:String = "Maintenance work in progress";
		static public var openWebApplication:String = "Go to Web Application";
		static public var maintenanceWorkDescription:String = "Service will back online soon. Meanwhile, you can access your MCA account from the Web application.";
		
		static public var account_mca:String = "MCA";
		static public var account_trade_ch:String = "Swiss Trading";
		static public var account_eu:String = "EU Trading";
		static public var trading_ch_opening_reminder:String = "Trading account opening is in progress, tap to proceed";
		static public var trading_eu_opening_reminder:String = "Trading account opening is in progress, tap to proceed";
		static public var startChatWithBankConsultantEU:String = "Start chat with Dukascopy EU";
		static public var startChatWithBankConsultantCH:String = "Start chat with Dukascopy CH";
		static public var tradingAccountInEU:String = "TRADING ACCOUNT IN EU";
		static public var tradingAccountInSwiss:String = "TRADING ACCOUNT IN SWISS BANK";
		
		static public var cardIssueNotAvailable:String = "You have reached the maximum number of cards that can be ordered.";
		static public var attachDocument:String = "Document";
		static public var uploading:String = "Uploading...";
		static public var uploads:String = "upload(s)";
		
		//deprecated
	//	static public var zbxAbout:String = "You need to register on ZBX.one and top up your ZBX account in the amount of 30 EUR.\nAfter that, you need to return to the Dukascopy Connect 911 application and continue your registration with Dukascopy Bank by clicking on the 'Proceed' button.\nDukascopy will check if your ZBX account has 30 EUR (or equivalent) and if this verification is successful, you will proceed to the next step.";
		static public var changed:String = "changed";
		static public var saveChangesQuestion:String = "Save changes?";
		static public var accountInfoUpdated:String = "You application for personal information update has been filed successfully";
		static public var updateInfoTimeout:String = "You may file a request for personal information update only once per day";
		
		static public var increaseLimits_typeRegular:String = "To recieve regular income";
		static public var increaseLimits_typeAccumulated:String = "To transfer wealth / savings";
		static public var increaseLimits_amountAccumulated:String = "Enter the amount you want to transfer";
		static public var increaseLimits_amountRegular:String = "Monthly income";
		static public var increaseLimits_title:String = "Increase Limits";
		static public var increaseLimits_purpose:String = "Please specify to do you want to increase your limits to transfer to account the income that you receive on a regular basis or you want to transfer an accumulated wealth, savings?";
		static public var increaseLimits_recommendSavingsAccount:String = "To transfer the funds you have indicated the Bank recommends you to open Savings account. This type of account represents a vault designed for storing previously accumulated wealth worth %@ and more. The funds can be kept in any of the 23 currencies offered by the Bank in exchange of custody fee charged on an annual basis. Savings account has a direct link with Multi-Currency Account which can continued to be used as sort of wallet for daily expenditures. Do you want to file application for Savings account opening?";
		static public var request:String = "Request";
		static public var increaseLimits_equityLimitIncrease:String = "To transfer the funds the Equity Limit should be increased. This limit defines the maximum amount of funds that can be kept on your account at a time.";
		static public var increaseLimits_quarterlyLimitIncrease:String = "For this purpose please file a request for the Incoming Quarterly Limit increase up to: %@";
		static public var increaseLimits_quarterlySuccess:String = "Your request to increase incoming quarterly limit has been submitted successfully. Please check your email for futher instrunctions.";
		static public var increaseLimits_equitySuccess:String = "Your request to increase Equity limit has been submitted successfully. Please check your email for futher instrunctions.";
		
		static public var recepient:String = "Recepient";
		static public var accountBeingApproved:String = "Your account is being approved";
		static public var referralBonusDetails:String = "Referrer gets 5 DUK+ of referral bonus for each referred MCA client in case referred account reaches 100 USD of incoming turnover limit. Any deposit is considered as incoming turnover.<br/><br/>2.5 DUK+ of commission is charged for every new referral starting of sixth referred account.<br/><br/>For more details please check the <font color='#5DC269'><a href='https://www.dukascoin.com/?lang=en&cat=inf&page=dukascoins-fees-and-limits'>Fees&Limits page</a></font>.";
		static public var сonditions:String = "Сonditions";
		static public var pleaseEnterPasswordFaceID:String = "Please enter password to enable Face ID";
		static public var quarterLimitDescription:String = "Defines the maximum amount of your regular income that can be deposited into your Multi-Currency Account within a quarter.";
		static public var totalLimitDescription:String = "Defines the maximum amount of funds that can be kept on your account at a time.";
		static public var friendInvoiceComment:String = "Initial deposit for my account opening";
		//deprecated
	//	static public var friendInvoiceConfirm:String = "Are you sure you want to request 30 EUR from this contact for your account opening";
		static public var askFriendInvoice:String = "Send invoice";
		static public var pleaseConfirm:String = "Please confirm";
		static public var startSupportChat:String = "Chat with support";
		static public var suportChat:String = "Support chat";
		static public var supportStartMessage:String = "To help us assist you better, please provide some information before we begin the chat";
		static public var enterYourName:String = "Enter your name:";
		static public var enterYourEmail:String = "Enter your email:";
		static public var howCanWeHelpYou:String = "Hello, how can we help you?";
		static public var selectContacts:String = "Select contacts";
		static public var max:String = "Max";
		static public var monthlyFee:String = "Monthly fee";
		static public var imageCorrupted:String = "The image is deleted or corrupted";
		static public var reply:String = "Reply";
		static public var addressbookPermisionRequired:String = "Permission required";
		static public var provideAccessToContacts:String = "Please provide access to your contact list";
		static public var tradingAccOpeningWait:String = "You have sent a request earlier today. Our representative will contact you shortly. Kindly wait";
		
		static public var wireDepositDescription:String = "The next step of your account opening is an initial deposit of %@.<br/>To proceed, please make a wire transfer of %@ indicating your phone number in the transfer description. The Bank will deposit these funds to your account upon its approval.";
		static public var solvency_wire_deposit:String = "Wire transfer";
		static public var solvency_wire_deposit_description:String = "Deposit %@ by wire transfer";
		
		static public var solvency_card_deposit_description_2:String = "Deposit %@ from your card";
		static public var solvency_crypto_deposit_description_2:String = "Deposit amount in crptocurrency equal to %@";
		static public var solvency_ask_friend_description_2:String = "You can ask your friends to send you %@";
		static public var askFriendDescription_2:String = "You can ask a friend to send you %@ directly in the chat. After you receive the requested amount, you will be automatically redirected to the next step. Click on the button bellow to see which of your contacts already has a Multi-Currency account with Dukascopy.";
		static public var depositeOnZBXAccount_2:String = "Deposit the equivalent of %@ or more in any cryptocurrency to you ZBX account.";
		static public var friendInvoiceConfirm_2:String = "Are you sure you want to request %@ from this contact for your account opening";
		static public var zbxAbout_2:String = "You need to register on ZBX.one and top up your ZBX account in the amount of %@.\nAfter that, you need to return to the Dukascopy Connect 911 application and continue your registration with Dukascopy Bank by clicking on the 'Proceed' button.\nDukascopy will check if your ZBX account has %@ (or equivalent) and if this verification is successful, you will proceed to the next step.";
		static public var roadmap_wireDeposit:String = "Wire transfer";
		static public var makeOffer:String = "Make offer";
		static public var escrow:String = "Crypto/Cash";
		static public var wireTransfer:String = "Wire transfer";
		
		static public var wantSellCrypto:String = "I WANT TO SELL CRYPTO";
		static public var wantBuyCrypto:String = "I WANT TO BUY CRYPTO";
		static public var escrow_description:String = "You can use Dukascopy Bank as intermediary to secure exchange of cryptocurrency versus fiat and vice versa.";
		static public var escrow_about_service_url:String = "https://dukascopy.com";
		static public var aboutService:String = "About service";
		static public var openMcaAccount:String = "OPEN MCA ACCOUNT";
		static public var register_mca_description:String = "For getting access to the service, register a Multi-currency account that will be used for payments processing.";
		static public var create_buy_offer:String = "Create Buy offer";
		static public var create_sell_offer:String = "Create Sell offer";
		static public var crypto:String = "Crypto";
		static public var linkage_required:String = "Linkage required";
		static public var deviation_from_market:String = "% deviation from the market price";
		static public var fixed_price:String = "Fixed price";
		static public var declare_blockchain:String = "For getting access to external blockchain operations, you need to declare your wallet address in this blockchain <font color='#CD3F43'>(read more)</font>";
		static public var declare_blockchain_description_url:String = "http://google.com";
		static public var indicative_price:String = "Indicative price:";
		static public var current_price:String = "Current price";
		static public var below:String = "Below";
		static public var above:String = "Above";
		static public var to_pay_for_crypto:String = "To pay for crypto";
		static public var refundable_fee:String = "Refundable fee (%@)%";
		static public var amount_to_be_debited:String = "Amount to be debited";
		
		static public var to_get_for_crypto:String = "To get for crypto";
		static public var commission_crypto:String = "Your commission (%@)%";
		static public var amount_to_be_credited:String = "Amount to be credited";
		static public var current_price_of_instrument:String = "Current price of 1 %@";
		static public var send_offer:String = "SEND OFFER";
		static public var my_blockchain_address:String = "My blockchain address";
		static public var escrow_terms_link:String = "http://google.com";
		static public var escrow_terms_accept:String = "I have read and accepted <font color='#CD3F43'>Terms&Conditions</font> <font color='#CD3F43'>🡭</font>";
		static public var need_accept_terms:String = "Please accept Terms&Conditions";
		static public var you_sent_buy_offer:String = "You sent a Buy offer!";
		static public var you_sent_sell_offer:String = "Your sell offer has been sent!";
		static public var sent_buy_offer_description:String = "Please note that %@1 were blocked  on your MCA account.<br/><br/>%@2 has %@3 minutes to accept your offer. If it is not accepted within %@4 minutes, the offer is canceled automatically and the fiat funds on your account get unblocked.<br/><br/>Until the offer is confirmed by the %@5, you can cancel it at any moment, without penalties.";
		static public var sent_sell_offer_description:String = "%@1 has %@2 minutes to accept your offer. Once it is accepted you will have %@3 minutes to send the crypto. Please get prepared in advance.<br/><br/>If it is not accepted within %@4 minutes, the offer is canceled automatically.<br/><br/>Until the offer is confirmed by the %@5, you can cancel it at any moment, without penalties.";
		static public var ok_understood:String = "OK, I UNDERSTOOD";
		static public var escrow_offer_message:String = "P2P offer";
		static public var escrow_buy_offer:String = "BUY offer";
		static public var escrow_sell_offer:String = "SELL offer";
		static public var price_per_coin:String = "%@ per coin";
		static public var sec:String = "sec";
		static public var min:String = " min";
		static public var offer_expired:String = "Offer expired";
		static public var left:String = "left";
		static public var buy_offer_awaiting_acceptance:String = "BUY offer is awaiting acceptance";
		static public var sell_offer_awaiting_acceptance:String = "SELL offer is awaiting acceptance";
		static public var buy_offer_description:String = "If it is not accepted within %@1 minutes, the offer is canceled automatically and the fiat funds on your account get unblocked. Until the offer is confirmed by the %@2, you can cancel it at any moment, without penalties.";
		static public var sell_offer_description:String = "Once the offer is accepted, you will have %@ minutes to send the crypto to the indicated wallet address of the buyer. Please get prepared in advance.";
		static public var escrow_send_obligation_penalty:String = "Failure to fulfill the sending obligation will incur penalties. See Terms & Conditions for details";
		static public var escrow_send_obligation_penalty_url:String = "http://google.com";
		static public var offer_buy_expired_details:String = "Offer was not accepted by the counterparty and expired. The funds reserved for this transaction were unblocked.";
		static public var offer_sell_expired_details:String = "Offer was not accepted by the counterparty and expired. You may create a new offer now.";
		static public var cancel_offer:String = "CANCEL OFFER";
		static public var amount_blocked:String = "Amount blocked";
		static public var amount_unblocked:String = "Amount unblocked";
		static public var amount_of_transaction:String = "Amount of transaction";
		static public var time_left:String = "%@ left";
		static public var chatmate:String = "chatmate";
		static public var accept_offer:String = "ACCEPT OFFER";
		static public var reject_offer:String = "REJECT OFFER";
		static public var sell_offer_accept_description:String = "After accepting the offer, you will have %@ minutes to send the crypto to the buyer's wallet.";
		static public var buy_offer_accept_description:String = "If it is not accepted within %@ minutes, the offer is canceled automatically. Once the offer is accepted, the fiat funds will be debited from your account.";
		static public var credit_to:String = "Credit to";
		static public var pay_from_account:String = "Pay from account";
		static public var please_select_credit_account:String = "Please select account to be credited";
		static public var offer_accepted_by_seller:String = "Offer is accepted by the Seller";
		static public var offer_accepted_by_buyer:String = "Offer is accepted by the Buyer";
		static public var offer_was_cancelled:String = "Offer was cancelled";
		static public var offer_was_rejected:String = "Offer was rejected";
		static public var you_accepted_sell_offer:String = "You accepted the SELL offer";
		static public var send_crypto:String = "You now have %@1 minutes to send %@2 to the blockchain wallet of the buyer:";
		static public var type_transaction_id:String = "Right after sending the funds type the resulting transaction ID below and then please press the \"I have sent crypto\" button";
		static public var i_have_sent_ctypto:String = "I HAVE SENT THE CRYPTO";
		static public var buyers_wallet:String = "Buyer's wallet";
		static public var transaction_id:String = "Transaction ID";
		static public var operation_completed:String = "The operation has been successfully completed.";
		static public var escrow_deal_completed_sell:String = "The fiat funds have been credited to your account, the %@% commission has been charged.";
		static public var escrow_deal_completed_buy:String = "The refundable fee has been returned to your account.<br/>The fiat funds have been sent to the crypto Seller.";
		static public var here_transaction_id:String = "Here is the transaction ID:";
		static public var investigation_fee_description:String = "Please note that the refundable fee (%@%) will become non-refundable if you neither confirm the receipt of crypto nor request an investigation during 24 hours";
		static public var crypro_sent_by_seller:String = "Crypto sent by Seller";
		static public var seller_sent_crypto:String = "The Seller has sent the crypto to your blockchain wallet.";
		static public var check_transaction:String = "Check the transaction and confirm reception";
		static public var i_have_received_ctypto:String = "I HAVE RECEIVED THE CRYPTO";
		static public var sending_crypto_not_executed:String = "Sending of the crypto is not executed.";
		static public var you_failed_confirm_transfer:String = "You failed to confirm the transfer and to provide the transaction ID during %@1 minutes. This will incur a penalty charge of %@2% from the amount of the failed transaction.";
		static public var seller_failed_confirm_transfer:String = "The Seller failed to confirm the sending of crypto and providing the transaction ID. The fiat funds reserved for this transaction have been unblocked";
		static public var escrow_penalty:String = "Penalty (%@1%)";
		static public var waiting_for_crypto:String = "Waiting for the crypto to be sent by the Seller";
		static public var waiting_for_crypto_description:String = "The Seller now has %@ minutes to send you the crypto and provide the transaction ID. You will receive a notification once this is done.";
		
		static public var escrow_report_1:String = "The reported transaction ID does not exist";
		static public var escrow_report_2:String = "The destination address of the transaction is wrong";
		static public var escrow_report_3:String = "The currency of the transaction is wrong";
		static public var escrow_report_4:String = "The amount of the transaction is wrong";
		static public var escrow_report_5:String = "The transaction is correct, but is taking too long to be accepted by the blockchain and the Buyer anticipates that he/she will not be able to confirm crypto acceptance within the 24 hours limit, as required by the rules";
		static public var escrow_report_6:String = "Other";
		static public var escrow_text_instruments:String = "Crypto";
		static public var escrow_text_offers:String = "Offers";
		static public var escrow_text_deals:String = "Deals";
		static public var please_select_reason:String = "todo";
		static public var indicate_issue_type:String = "Indicate issue type";
		static public var escrow_report:String = "REPORT";
		static public var escrow_report_sent:String = "The transaction has been suspended and forwarded to manual investigation by Dukascopy Support. Dukascopy Bank will contact you if any explanation is required.";
		static public var investigation_alert:String = "Please note that Dukascopy Bank may charge USD 50 of investigation fee if the report proves to be fake.";
		
		static public var increaseLimitRequestFalse:String = "You may file a request for limits increase only twice per day";
		static public var updateInfoRequestFalse:String = "You may file a request for personal information update only twice per day";
		static public var continueRegistration:String = "Continue registration";
		static public var moneyTransferTimeoutError:String = "The server was not able to respond during 30 seconds. Please go back to My account and check the actual status of the operation.";
		static public var launchJForex:String = "Launch JForex App";
		static public var launchJForexWeb:String = "Launch JForex Web";
		static public var launchMT4:String = "Launch MT4 App";
		static public var launchBinaryTrader:String = "Launch Binary Trader App";
		static public var launchCurrentAccount:String = "Current account";
		static public var cardOrderDelivery:String = "Card order and delivery";
		static public var noFundedAccounts:String = "You have no funded accounts";
		static public var escrow_to_sell:String = "I SELL";
		static public var escrow_to_buy:String = "I BUY";
		static public var please_select_debit_account:String = "Please select account to be debited";
		static public var escrow_deal_message:String = "P2P deal";
		static public var deal_expired:String = "Deal expired";
		static public var escrow_enter_transaction_id:String = "Please enter transaction id";
		static public var escrow_request_investigation:String = "Request investigation";
		static public var escrow_you_buy:String = "You Buy";
		static public var escrow_price:String = "Price";
		static public var escrow_autocancel_description:String = "Note that the offer may be automatically cancelled if there is not enough funds on your account to pay for the crypto purchase.";
		static public var draft:String = "Draft: ";
		static public var payments_error_amount_too_small:String = "Amount is too small 1";
		static public var groupChat:String = "Group chat";
		static public var escrow_target_price_per_coin:String = "Target price per Coin";
		
		static public var addTender:String = "Add your tender";
		static public var tenderStartText1:String = "Create your ad you intend to publish, indicating the required details.\nOnce someonce reacts to your ad, switch to the one-to-one chat with the counterparty, agree on the ultimate conditions of the future deal and initiate a binding offer through a dedicated form right from the chat.";
		static public var tenderSide:String = "I would like to";
		static public var tenderTypeOperation:String = "Choose operation type";
		static public var tenderCrypto:String = "Crypto";
		static public var tenderSelectCrypto:String = "Select crypto";
		static public var tenderCryptoAmount:String = "Crypto amount";
		static public var tenderAmount:String = "Amount";
		static public var tenderCurrency:String = "Currency";
		static public var tenderChooseCurrency:String = "Choose currency";
		static public var tenderTargetPrice:String = "Target price per Coin";
		static public var tenderInputPrice:String = "Input price";
		static public var tenderSideBuy:String = "Buy";
		static public var tenderSideSell:String = "Sell";
		static public var escrow_hold:String = "P2P";
		static public var tenderPricePercent:String = "from market price";
		static public var history:String = "History";
		static public var ads:String = "Ads";
		static public var escrow_title:String = "911 Crypto P2P";
		static public var escrow_rules:String = "Rules";
		static public var escrow_already_participate:String = "Already participate %@ of %@";
		static public var escrow_offer_closed:String = "Closed";
		static public var escrow_your_ad_created:String = "Your ad has been successfully created";
		static public var escrow_ad_intro_message:String = "I would like to %@1 %@2 at %@3 per coin.";
		static public var escrow_ad_intro_message_percent:String = "I would like to %@1 %@2 at %@3 per coin. (%@4 %@5 the market price)";
		static public var escrow_ad_intro_message_percent_nan:String = "I would like to %@1 %@2 at --- per coin. (%@4 %@5 the market price)";
		static public var escrow_ad_intro_message_at_market_price:String = "I would like to %@1 %@2 at market price";
		
		static public var escrowAdsIntroMsg:String = "I would like to %@1 %@2 at %@3 per coin.";
		static public var escrowAdsIntroMsgMarketPrice:String = "I would like to %@1 %@2 at market price";
		static public var escrowAdsIntroMsgPercentAdd:String = " (%@4% %@5 the market price)";
		static public var escrowAdsIntroMsgMarketPriceAdd:String = " (%@3 per coin)";
		
		static public var escrow_buy:String = "Buy";
		static public var escrow_sell:String = "Sell";
		static public var make_offer:String = "MAKE OFFER";
		static public var editEscrowAd:String = "Edit your ad";
		static public var escrow_chat:String = "CHAT";
		static public var escrow_chats:String = "CHATS";
		static public var waiting_for_money_hold:String = "Waiting for money hold by the Buyer";
		static public var escrow_from_market_price:String = "from market price";
		static public var escrow_seller_sent_crypto_transaction:String = "Seller sent crypto tranaction ID";
		static public var escrow_waiting_receipt_confirm:String = "Waiting for receipt confirmation by the Buyer";
		static public var escrow_deal_completed:String = "Deal successfully completed";

		static public var noRights:String="You don't have rights to perfom this action";
		static public var deal_created:String = "Deal created";
		static public var escrow_account_not_found:String = "Account not found";
		static public var escrow_offer_type_not_set:String = "Offer type not set";
		static public var escrow_not_enougth_money:String = "Insufficient funds on the selected account ";
		static public var escrow_cant_load_account_limits:String = "Can't load account limits";
		static public var escrow_credit_amount_not_in_limits:String = "You have reached your account limit(s). Please consider increasing it or decrease the amount of your offer";
		static public var escrow_check_transaction:String = "Please carefully check the transaction before your confirmation";
		static public var escrow_copy_transaction:String = "Copy transaction";
		static public var escrow_at_market_price:String = "At market price";
		static public var date:String = "Date";
		static public var filter_price:String = "Price";
		static public var filter_amount:String = "Amount";
		static public var escrow_filter_title:String = "New filter";
		static public var blackList:String = "Black list";
		static public var buy_ads:String = "BUY ads";
		static public var sell_ads:String = "SELL ads";
		static public var escrow_no_active_ads_placeholder:String = 'There are no active ads so far. Press "+" sign in the right upper corner to create your Crypto P2P ad.';
		static public var escrow_blockchain_address_needed:String = "In order to get access to external blockchain operations with %@ you need to register a blockchain address that will be used for withdrawal operations.";
		static public var escrow_create_your_ad:String = "Create your ad";
		static public var escrow_amount_exceeds:String = "The amount of your offer exceeds the amount of the ad. Please note that it can be equal or less than the amount of the ad.";
		static public var waiting_for_receipt_confirmation:String = "You have succesfully provided the transaction ID that now has to be checked and confirmed by your counterparty during 24 hours.";
		static public var waiting_for_receipt_confirmation_status:String = "Waiting for receipt confirmation by the Buyer";
		static public var escrow_fill_application_form:String = "Please fill in the application form";
		static public var escrow_debit_from_account:String = "Debit from account";
		static public var escrow_offer_was_rejected:String = "Offer was rejected";
		static public var escrow_offer_rejected:String = "Offer was rejected by the counterparty.\nThe funds were unblocked.";
		static public var instrument:String = "Instrument";
		static public var crypto_terms_link:String = "google.com";
		static public var crypto_terms:String = "The use of the deposit function is possible only upon accepting the <font color='#CD3F43'>Crypto Terms & conditions</font>";
		static public var escrow_tap_deal_form:String = "Tap to see deal form";
		static public var tapToUpenForm:String = "Tap to open deal form";
		static public var escrow_deals:String = "Deals";
		static public var escrow_offers:String = "Offers";
		static public var buy_sell_ads:String = "BUY/SELL";
		static public var escrow_hide_blocked:String = "Hide blocked users";
		static public var escrow_hide_noobs:String = "Hide noobs";
		static public var excrow_exclude_country:String = "Exclude Country";
		static public var escrow_excluded_countries:String = "Excluded countries";
		static public var escrow_countries_excluded:String = "Countries excluded";
		static public var escrow_provide_crypto_wallet:String = "Please provide crypto address";
		static public var escrow_price_zero_error:String = "price should be non zero";
		static public var escrow_offer_status_created:String = "Сreated";
		static public var escrow_offer_status_accepted:String = "Accepted";
		static public var escrow_offer_status_cancelled:String = "Cancelled";
		static public var escrow_offer_status_expired:String = "Expired";
		static public var escrow_offer_status_rejected:String = "Rejected";
		static public var escrow_deal_status_created:String = "Created";
		static public var escrow_deal_status_completed:String = "Completed";
		static public var escrow_deal_status_mca_hold:String = "MCA hold";
		static public var escrow_deal_status_expired:String = "expired";
		static public var escrow_deal_status_paid_crypto:String = "paid crypto";
		static public var below_market_price:String = "Below market price";
		static public var above_market_price:String = "Above market price";
		static public var under_investigation:String = "Under investigation";
		static public var escrow_deal_status_claimed:String = "Under investigation";
		static public var escrow_under_investigation:String = "Manual investigation was requested by your counterparty.\n\nThe transaction has been suspended. Dukascopy Bank will contact you if any explanation is required.";
		static public var escrow_sell_offer_rejected_self_side:String = "Offer was rejected by you.\nYou may create a new offer now.";
		static public var escrow_sell_offer_rejected_counterparty_side:String = "Offer was rejected by the counterparty.\nYou may create a new offer now.";
		static public var escrow_buy_offer_rejected_self_side:String = "Offer was rejected by you.\nThe funds were unblocked.";
		static public var escrow_buy_offer_rejected_counterparty_side:String = "Offer was rejected by the counterparty.\nThe funds were unblocked.";
		static public var error_remove_ads_has_answers:String = "You cannot remove this ad since it contains incomplete deal(s)";
		static public var escrow_deal_created_status:String = "The deal has been created but the funds have not been charged yet from the Buy-side account. If you believe the operation takes more time than reasonably required, please let us know in Support chat.";
		
		static public var offer_sell_expired_details_buyer_side:String = "Offer was not accepted by you and expired.\nYou may create a new offer now.";
		static public var offer_sell_expired_details_seller_side:String = "Offer was not accepted by the counterparty and expired.\nYou may create a new offer now.";
		static public var offer_buy_expired_details_buyer_side:String = "Offer was not accepted by the counterparty and expired.\nThe funds reserved for this transaction were unblocked.";
		static public var offer_buy_expired_details_seller_side:String = "Offer was not accepted by you and expired.\nYou may create a new offer now.";
		static public var error_cant_start_deal_active_deals:String = "The new deal cannot be initiated before the previous deal between both of you is completed";
		
		static public function updateKeys(keys:Object):void {
			for (var n:String in keys) {
				if (n.indexOf("REFERAL_") == 0) {
					refCodesText[n.toUpperCase()] = keys[n];
					continue;
				}
				if (n.indexOf("VI_") == 0) {
					viText[n.toUpperCase()] = keys[n];
					continue;
				}
				if (n.indexOf("LOTTO_") == 0) {
					lottoText[n.toUpperCase()] = keys[n];
					continue;
				}
				if (n.indexOf("CHANNEL_DESC_") == 0) {
					channelDescs[n.substr(13)] = keys[n];
					continue;
				}
				if (n.indexOf("textOtherAccType") == 0) {
					otherAccTypes[n.substr(16)] = keys[n];
					continue;
				}
				if (n.indexOf("investmentsCurrency") == 0) {
					investmentsCurrency[n.substr(19).toLocaleLowerCase()] = keys[n];
					continue;
				}
				if (n.indexOf("investmentsTitles") == 0) {
					investmentsTitles[n.substr(17).toUpperCase()] = keys[n];
					continue;
				}
				if (n.indexOf("rdStatuses") == 0) {
					rdStatuses[n.substr(10).toLocaleLowerCase()] = keys[n];
					continue;
				}
				try {
					if (keys[n] != null)
						Lang[n] = keys[n];
				} catch (err:Error) {
					echo("Lang", "installLanguage", "Can`t add  text to Lang file, the key: " + n + ' are missed');
				}
			}
		}
		
		static public function getMonthTitleByIndex(val:int):String {
			if (val > 11)
				return "";
			return Lang["month_" + val];
		}
	}
}