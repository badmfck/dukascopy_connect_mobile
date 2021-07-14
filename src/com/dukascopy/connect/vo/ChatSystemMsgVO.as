package com.dukascopy.connect.vo {
	
	import assets.Gift_1;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.RateBotData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.gui.puzzle.Puzzle;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.type.FileFormat;
	import com.dukascopy.connect.vo.chat.CallMessageVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.chat.FileMessageVO;
	import com.dukascopy.connect.vo.chat.MoneyTransferMessageVO;
	import com.dukascopy.connect.vo.chat.NewsMessageVO;
	import com.dukascopy.connect.vo.chat.ReplayMessageVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.chat.PuzzleMessageVO;
	import com.dukascopy.connect.vo.chat.VideoMessageVO;
	import com.dukascopy.connect.vo.chat.VoiceMessageVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class ChatSystemMsgVO {
		
		public static const TYPE_FILE:String = "file";
		public static const TYPE_NOTICE:String = "notice";
		public static const TYPE_CONTACT:String = "contact";
		static public const TYPE_STICKER:String = "sticker";
		static public const TYPE_MESSAGE:String = "typeMessage";
		static public const TYPE_SYSTEM:String = "system";
		static public const TYPE_INVOICE:String = "invoice";
		static public const TYPE_VOICE:String = "voice";
		static public const TYPE_FORWARDED:String = "forwarded";
		static public const TYPE_911:String = "911";
		static public const TYPE_COMPLAIN:String = "Complain";
		static public const TYPE_LOCAL_QUESTION:String = "localQuestion";
		static public const TYPE_TEXT:String = "text";
		static public const TYPE_GIFT:String = "gift";
		static public const TYPE_CHAT_SYSTEM:String = "chatSystem";
		static public const TYPE_MONEY:String = "money";
		static public const TYPE_CALL:String = "typeCall";
		static public const TYPE_VI:String = "VI";
		
		public static const FILETYPE_IMG:String = "img";
		public static const FILETYPE_IMG_CRYPTED:String = "cimg";
		public static const FILETYPE_PUZZLE_CRYPTED:String = "cimgPuzzle";
		public static const FILETYPE_VIDEO:String = "video";
		public static const FILETYPE_FILE:String = "file";
		
		public static const METHOD_FILE_START_SEND:String = 'fileStartSend';
		public static const METHOD_FILE_SENDING:String = 'fileSending';
		public static const METHOD_FILE_SENDED:String = 'fileSended';
		public static const METHOD_FILE_ERROR:String = 'fileError';
		
		public static const METHOD_CONTACT:String = "contactSended";
		
		static public const METHOD_STICKER:String = "stickerSended";
		
		static public const METHOD_CAMERA_ON:String = "cameraon";
		static public const METHOD_CAMERA_OFF:String = "cameraoff";
		
		static public const METHOD_911_NOT_SATISFY:String = "notSatisfy";
		static public const METHOD_911_SATISFY_USER:String = "satisfyUser";
		static public const METHOD_911_SATISFY:String = "satisfy";
		static public const METHOD_911_GOT_ANSWER:String = "gotAnswer";
		static public const METHOD_911_GEO:String = "geo";
		
		static public const METHOD_COMPLAIN_BLOCK:String = "block";
		static public const METHOD_COMPLAIN_SPAM:String = "spam";
		static public const METHOD_COMPLAIN_ABUSE:String = "abuse";
		static public const METHOD_COMPLAIN_STOP:String = "stop";
		
		static public const METHOD_LOCAL_EXTRA_TIPS:String = "extraTips";
		static public const METHOD_LOCAL_SECRET:String = "secret";
		static public const METHOD_LOCAL_TYPE:String = "type";
		static public const METHOD_LOCAL_GEO:String = "Geolocation";
		static public const METHOD_LOCAL_LANGUAGES:String = "languages";
		
		static public const METHOD_USER_ADD:String = "userAdd";
		static public const METHOD_USER_REMOVE:String = "userRemove";
		
		static public const METHOD_MONEY_TRANSFER:String = "moneyTransfer";
		static public const METHOD_TIPS_PAID:String = "methodTipsPaid";
		static public const METHOD_GIFT_IN_GROUP_CHAT:String = "methodGiftInGroupChat";
		
		static public const METHOD_NEWS:String = "news";
		static public const METHOD_BOT_MENU:String = "botMenu";
		static public const METHOD_BOT_COMMAND:String = "botCommand";
		static public const DUKASNOTES_REQUEST:String = "dukasnotesRequest";
		static public const FILETYPE_GENERAL:String = "filetypeGeneral";
		static public const METHOD_CALL:String = "methodCall";
		static public const METHOD_CALL_VIDID:String = "methodCallVidid";
		static public const METHOD_VI_FAIL:String = "VIFail";
		static public const METHOD_VI_START:String = "VIStart";
		static public const METHOD_VI_COMPLETE:String = "VIComplete";
		
		static public const REPLAY_START_BOUND:String = "{quote ";
		static public const REPLAY_END_BOUND:String = "{quote}";
		static public const REPLAY_END_BOUND_FIXED:String = "</quote>";
		static public const REPLAY_START_BOUND_FIXED:String = "<quote ";
		static public const TYPE_REPLY:String = "typeReply";
		static public const TYPE_LINK_PREVIEW:String = "typeLinkPreview";
		static public const TYPE_ESCROW_OFFER:String = "typeEscrowOffer";
		static public const TYPE_ESCROW_DEAL:String = "typeEscrowDeal";
		
		private var _type:String;
		private var _method:String;
		private var _title:String;
		private var _text:String;
		private var _textSmall:String;
		
		private var _fileType:String;
		private var _imageURL:String;
		private var _imageThumbURL:String;
		private var _imageHeight:int = 320;
		private var _imageWidth:int = 320;
		private var _avatarURL:String;
		private var _mobileNr:String;
		private var _fxID:uint;
		private var _originalImageHeight:int;
		private var _originalImageWidth:int;
		private var _uid:String;
		private var _stickerURL:String;
		private var _stikerId:int;
		private var _stikerVersion:int;
		private var _fileID:String;
		private var _currency:String;
		private var _amount:Number;
		private var _geolocation:Location;
		
		private var _additionalData:Object;
		
		private var _botMenu:Object;
		private var _rateBot:Object;
		private var _links:Array;
		private var _imageUID:String;
		private static var failStickers:Array;
		private var _rateBotMessage:Boolean = false;
		private var _rateBotWebView:RateBotData;
		
		public var rateBotMessage:Boolean;
		public var replayMessage:ReplayMessageVO;
		
		public function ChatSystemMsgVO(data:Object = null, chatUid:String = null, messageId:Number = NaN) {
			if (data)
				update(data, chatUid, messageId);
		}
		
		public function update(data:Object, chatUid:String, messageId:Number = NaN):void {
			if (data == null) {
				dispose();
				return;
			}
			if ("type" in data && data.type != null)
				_type = data.type;
			if ("method" in data && data.method != null)
				_method = data.method;
			if ("title" in data && data.title != null)
				_title = data.title;
			if ("fileType" in data && data.fileType != null)
				_fileType = data.fileType;
			var tmp:Array;
			if (_type != null) {
				if (_type == TYPE_VI) {
					if (_method == METHOD_VI_FAIL) {
						_type = TYPE_CHAT_SYSTEM;
						_method = METHOD_CALL_VIDID;
						_additionalData = new CallMessageVO();
						(_additionalData as CallMessageVO).vidid = true;
						(_additionalData as CallMessageVO).vididType = CallMessageVO.VIDID_FAIL;
					}
					if (_method == METHOD_VI_START) {
						_type = TYPE_CHAT_SYSTEM;
						_method = METHOD_CALL_VIDID;
						_additionalData = new CallMessageVO();
						(_additionalData as CallMessageVO).vidid = true;
						(_additionalData as CallMessageVO).vididType = CallMessageVO.VIDID_START;
					}
					if (_method == METHOD_VI_COMPLETE) {
						_type = TYPE_CHAT_SYSTEM;
						_method = METHOD_CALL_VIDID;
						_additionalData = new CallMessageVO();
						(_additionalData as CallMessageVO).vidid = true;
						(_additionalData as CallMessageVO).vididType = CallMessageVO.VIDID_COMLETE;
					}
				}
				else if (_type == "credentials") {
					if (_method == "VI") {
						_title = Lang.readyForIDVerification;
					}
					if (_method == "VI_LATER") {
						_title = Lang.letsDoItLater;
					}
				} else if (_type == TYPE_SYSTEM) {
					if (_method != null) {
						_title = _method;
						if (_title.toLowerCase().indexOf(METHOD_CAMERA_ON) != -1)
							_title = Lang.videoCallStarted;
						if (_title.toLowerCase().indexOf(METHOD_CAMERA_OFF) != -1)
							_title = Lang.videoCallEnded;
					}
				} else if (_type == TYPE_VOICE) {
					_additionalData = new VoiceMessageVO(data.additionalData);
					_title = Lang.sentVoiceMessage;
				} else if (_type == TYPE_INVOICE) {
					_additionalData = ChatMessageInvoiceData.createFromObject(data);
					_title = Lang.sentInvoice;
				} else if (_type == TYPE_FILE) {
					_title = Lang.sentFile;
					if (_fileType != null) {
						if (_method != null && 
							(_method == METHOD_FILE_SENDED || _method == METHOD_FILE_SENDING || _method == METHOD_FILE_START_SEND)) {
							if (_fileType == FILETYPE_IMG || _fileType == FILETYPE_IMG_CRYPTED) {
								if (data.additionalData != null) {
									tmp = data.additionalData.split(',');
									if (tmp[0] != null && tmp[0] != "") {
										_imageURL = Config.URL_PHP_CORE_SERVER_FILE + '?method=files.get&key=' + Auth.key +'&uid=' + tmp[0];
										_imageThumbURL = _imageURL +'&thumb=true';
									}
									_originalImageWidth = tmp[1];
									_originalImageHeight = tmp[2];
									_imageUID = tmp[0];
									if (_imageHeight < 1)
										_imageHeight = 320;
									tmp = null;
								}
							}else if (_fileType == FILETYPE_PUZZLE_CRYPTED) {
								_title = Lang.sentFile;
								// check 
								if (data.additionalData != null) {
									tmp = data.additionalData.split(',');
									_fileID = tmp[0];
									if (tmp[0] != null && tmp[0] != "") {
										_imageURL = Config.URL_PHP_CORE_SERVER_FILE + '?method=files.get&key=' + Auth.key +'&uid=' + tmp[0];
										_imageThumbURL = _imageURL +'&thumb=true';
									}
									
									_originalImageWidth = tmp[1];
									_originalImageHeight = tmp[2];
									if (_imageHeight < 1)
										_imageHeight = 320;
									tmp = null;
									
									var puzzleData:PuzzleMessageVO;
									if ("puzzleData" in data && data.puzzleData != null)
										puzzleData = new PuzzleMessageVO(data.puzzleData);
									if (puzzleData != null)
										_additionalData = puzzleData;
								}
								
								
							} else if(_fileType == FILETYPE_VIDEO) {
								if (data.additionalData != null) {
									if (data.additionalData != null && data.additionalData != "")
									{
										_imageThumbURL = Config.URL_PHP_CORE_SERVER_FILE + '?method=files.get&key=' + Auth.key +'&uid=' + data.additionalData +'&thumb=true';
									}
									
									var videoData:VideoMessageVO;
									if ("videoData" in data && data.videoData != null)
										videoData = new VideoMessageVO(data.additionalData as String, data.videoData);
									if (videoData != null) {
										_additionalData = videoData;
										_originalImageWidth = videoData.thumbWidth;
										_originalImageHeight = videoData.thumbHeight;
										if (_imageHeight < 1)
											_imageHeight = 320;
									} else {
										_originalImageWidth = 320;
										_imageHeight = 320;
									}
									
									//check for broken video upload process;
									if (fileType == ChatSystemMsgVO.FILETYPE_VIDEO && videoVO != null && videoVO.loaded == false && !isNaN(messageId) && VideoUploader.existUploaderWithId(messageId) == false)
										_additionalData.rejected = true;
								}
							} else {
								if (data.additionalData != null && data.title != null) {
									var fileFormat:String = getFileFormat(data.title);
									if(fileFormat != null && fileFormat.toLowerCase() == FileFormat.MP4)
									{
										_fileType = FILETYPE_VIDEO;
										var videoDataFromFile:VideoMessageVO = new VideoMessageVO(null, null);
										videoDataFromFile.thumbUID = data.additionalData;
										videoDataFromFile.loaded = true;
										videoDataFromFile.size = data.size;
										videoDataFromFile.title = data.title;
										
										_additionalData = videoDataFromFile;
										_originalImageWidth = 320;
										_originalImageHeight = 320;
									}
									else
									{
										_fileType = FILETYPE_GENERAL;
										_additionalData = new FileMessageVO(data);
									}
								}
							}
						}
					}
				} else if (_type == TYPE_STICKER) {
					_title = Lang.stikerSent;
					if (data.additionalData != null) {
						tmp = data.additionalData.split(',');
						_stikerId = int(tmp[0]);
						if (Config.PLATFORM_APPLE == true && SocialManager.available == false)
							_stikerId = filterStickers(_stikerId);
						_stikerVersion = int(tmp[1]);
						_stickerURL = StickerManager.getSticker(_stikerId, _stikerVersion);
						tmp = null;
					}
				} else if (_type == ChatSystemMsgVO.TYPE_FORWARDED) {
					_additionalData = new ChatMessageVO(data.additionalData);
				} else if (_type == ChatSystemMsgVO.TYPE_MONEY) {
					_title = Lang.moneyTransfer;
					if ("additionalData" in data && data.additionalData != null) {
						_additionalData = new MoneyTransferMessageVO(data.additionalData);
					}
				}
				else if (_type == ChatSystemMsgVO.TYPE_CHAT_SYSTEM) {
					if (_method != null) {
						if (_method == ChatSystemMsgVO.METHOD_USER_ADD) {
							_additionalData = data.additionalData;
						} else if (_method == ChatSystemMsgVO.METHOD_USER_REMOVE) {
							_additionalData = data.additionalData;
						} else if (_method == ChatSystemMsgVO.METHOD_TIPS_PAID) {
							try {
								_additionalData = new GiftData(data.additionalData, chatUid);
								if ("user" in data.additionalData && data.additionalData.user != null) {
									var user:UserVO = UsersManager.getUserByChatUserObject(data.additionalData.user);
									user.incUseCounter();
									(_additionalData as GiftData).user = user;
								}
							}
							catch (e:Error) {
								//!TODO: wrong JSON data format, array needed
							}
						} else if (_method == ChatSystemMsgVO.METHOD_GIFT_IN_GROUP_CHAT) {
							if (data.additionalData != null && "senderUID" in data.additionalData && "toUID" in data.additionalData &&
								"senderName" in data.additionalData && "toUsername" in data.additionalData){
								var senderName:String;
								var recieverName:String;
								var userVO:UserVO;
								userVO = UsersManager.getFullUserData(data.additionalData.senderUID, false);
								if (userVO != null)
									senderName = userVO.getDisplayName();
								else
									senderName = data.additionalData.senderName;
								userVO = UsersManager.getFullUserData(data.additionalData.toUID, false);
								if (userVO != null)
									recieverName = userVO.getDisplayName();
								else
									recieverName = data.additionalData.toUsername;
								_additionalData = recieverName + " " + Lang.receivedGifyFrom + " " + senderName;
							} else
								_additionalData = Lang.giftSent;
						} else if (_method == METHOD_NEWS){
							_additionalData = new NewsMessageVO(data);
						} else if (_method == METHOD_CALL){
							_additionalData = new CallMessageVO(data.additionalData);
						} else if (_method == METHOD_CALL_VIDID){
							_additionalData = new CallMessageVO(data.additionalData);
							(_additionalData as CallMessageVO).vidid = true;
							(_additionalData as CallMessageVO).vididType = CallMessageVO.VIDID_CALL;
						}else if (_method == ChatSystemMsgVO.METHOD_BOT_MENU) {
							var menuObject:Object;
							try {
								menuObject = JSON.parse(data.additionalData);
							} catch (err:Error) {
								return;
							}
							if ("rateBot2" in menuObject == true) {
								_rateBotMessage = true;
								_rateBot = menuObject.rateBot2;
							}
							if ("rateBot3" in menuObject == true) {
								_rateBotWebView = new RateBotData(menuObject.rateBot3);
							}
							_botMenu = menuObject.menu;
							if (_botMenu != null) {
								if ("links" in _botMenu == true)
									_links = _botMenu.links;
								if ("titleMain" in _botMenu)
									_title = _botMenu.titleMain;
								if ("title" in _botMenu)
									_text = _botMenu.title;
							}
						}
					}
				} else if (_type == TYPE_GIFT) {
					_title = Lang.giftSent;
					if (data.additionalData != null) {
						_additionalData = new GiftData(data.additionalData, chatUid);
					}
				} else if (_type == TYPE_911) {
					if (_method == METHOD_911_GEO) {
						if ("additionalData" in data == true && data.additionalData != null) {
							tmp = data.additionalData.split(",");
							_geolocation = new Location(tmp[0], tmp[1]);
						}
					}
				} else if (_type == TYPE_ESCROW_OFFER) {
					_additionalData = new EscrowMessageData(data);
					_title = Lang.escrow_offer_message;
				} else if (_type == TYPE_ESCROW_DEAL) {
					_type = TYPE_ESCROW_OFFER;
					_additionalData = new EscrowMessageData(data);
					_title = Lang.escrow_deal_message;
				}
				
				
				if (_method != null && _method == METHOD_CONTACT) {
					//!TODO: replace title from locale
					if (data.additionalData != null) {
						tmp = data.additionalData.split(",");
						_uid = tmp[0];
						_mobileNr = tmp[1];
						_fxID = uint(tmp[2]);
						_avatarURL = tmp[3];
					}
				}
			}
			if (_avatarURL != null)
				_avatarURL = _avatarURL.replace("http://www.dukascopy.com", "https://www.dukascopy.com");
		}
		
		private function filterStickers(stikerId:int):int 
		{
			if (failStickers == null)
			{
				failStickers = [30, 96, 97, 36, 144, 10, 12, 9, 8, 7, 3, 1, 15, 5, 6, 16, 4, 14, 2,  13, 19, 142, 37, 18, 143, 26, 77, 89, 90, 87, 107, 94, 91, 104, 105, 101, 103, 93, 88, 99, 100, 109, 209, 200, 192, 199, 177, 178, 125, 111, 126, 127, 130, 133, 162, 160, 102];
			}
			var l:int = failStickers.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (stikerId == failStickers[i])
				{
					return 170;
				}
			}
			return stikerId;
		}
		
		static public function getFileFormat(fileName:String):String {
			if (fileName != null) {
				var fileTypeArray:Array = fileName.split(".");
				if (fileTypeArray != null && fileTypeArray.length > 0) {
					return fileTypeArray[fileTypeArray.length - 1];
				}
			}
			return "";
		}
		
		public function get phone():String { return _mobileNr; }
		public function get fxcommID():uint { return _fxID; }
		public function get title():String { return _title; }
		public function get method():String { return _method; }
		public function get type():String { return _type; }
		
		public function set type(value:String):void 
		{
			_type = value;
		}
		public function get fileType():String { return _fileType; }
		public function get imageHeight():int { return _imageHeight; }
		public function get imageWidth():int { return _imageWidth; }
		public function get originalImageWidth():int { return _originalImageWidth; }
		public function get originalImageHeight():int { return _originalImageHeight; }
		public function get uid():String { return _uid; }

		public function get avatarURL():String { return _avatarURL; }
		public function get stickerURL():String { return _stickerURL; }
		public function get stikerId():int { return _stikerId; }
		public function get stikerVersion():int  { return _stikerVersion; }
		public function get imageURL():String { return _imageURL; }
		public function get imageThumbURL():String  { return _imageThumbURL; }
		public function get voiceVO():VoiceMessageVO { return _additionalData as VoiceMessageVO; }
		public function get invoiceVO():ChatMessageInvoiceData { return _additionalData as ChatMessageInvoiceData; }
		public function get forwardVO():ChatMessageVO { return _additionalData as ChatMessageVO; }
		public function get giftVO():GiftData { return _additionalData as GiftData; }
		public function get videoVO():VideoMessageVO { return _additionalData as VideoMessageVO; }
		public function get puzzleVO():PuzzleMessageVO { return _additionalData as PuzzleMessageVO; }
		public function get moneyTransferVO():MoneyTransferMessageVO { return _additionalData as MoneyTransferMessageVO; }
		public function get newsVO():NewsMessageVO { return _additionalData as NewsMessageVO; }
		public function get fileVO():FileMessageVO { return _additionalData as FileMessageVO; }
		public function get callVO():CallMessageVO { return _additionalData as CallMessageVO; }
		public function get escrow():EscrowMessageData { return _additionalData as EscrowMessageData; }
		
		public function set originalImageHeight(value:int):void{
			_originalImageHeight = value;
		}
		
		public function dispose():void {
			_type = null;
			_method = null;
			_title = null;
			_text = null;
			_botMenu = null;
			_rateBot = null;
			_fileType = null;
			_imageURL = null;
			_imageThumbURL = null;
			_imageHeight = 0;
			_imageWidth = 0;
			_avatarURL = null;
			_mobileNr = null;
			_fxID = 0;
			_originalImageHeight = 0;
			_originalImageWidth = 0;
			_uid = null;
			_stickerURL = null;
			_stikerId = 0;
			_stikerVersion = 0;
			
			if (_additionalData != null && "dispose" in _additionalData)
				_additionalData.dispose();
			_additionalData = null;
		}
		
		public function setLocationString(val:String):void {
			_text = val;
		}
		
		public function get text():String {
			if (_text != null)
				return _text;
			if (_type == TYPE_REPLY && replayMessage != null && replayMessage.text != null) {
				return replayMessage.text;
			}
			if (_type == TYPE_911) {
				if (_method == METHOD_911_NOT_SATISFY)
					_text = Lang.yourAnswerISNTCorrect;
				else if (_method == METHOD_911_SATISFY_USER)
					_text = Lang.yourAnswerFullySatisfidByUser;
				else if (_method == METHOD_911_SATISFY)
					_text = Lang.yourAnswerFullySatisfid;
				else if (_method == METHOD_911_GOT_ANSWER)
					_text = Lang.yourAnswerAlreadyCorrect;
				else
					_text = _title;
			} else if (_type == TYPE_COMPLAIN) {
				if (_method == METHOD_COMPLAIN_BLOCK)
					_text = Lang.youBeenBlocked;
				if (_method == METHOD_COMPLAIN_SPAM)
					_text = Lang.yourActivConsidSpam;
				if (_method == METHOD_COMPLAIN_ABUSE)
					_text = Lang.yourActivConsidAbuse;
				if (_method == METHOD_COMPLAIN_STOP)
					_text = Lang.chatBeenStopped;
			} else if (_type == TYPE_VOICE) {
				_text = Lang.sentVoiceMessage;
			} else if (_type == TYPE_SYSTEM) {
				if (_method == METHOD_CAMERA_ON)
					_text = Lang.videoCallStarted;
				else if (_method == METHOD_CAMERA_OFF)
					_text = Lang.videoCallEnded;
				else
					_text = method;
			} else if (_type == TYPE_FILE) {
				if (_fileType == FILETYPE_PUZZLE_CRYPTED) {
					_text = Lang.sentPuzzle;
				} else if (_fileType == FILETYPE_IMG || _fileType == FILETYPE_IMG_CRYPTED) {
					if (_method == METHOD_FILE_SENDED)
						_text = Lang.sentImage;
				} else if (_fileType == FILETYPE_VIDEO) {
					if (_method == METHOD_FILE_SENDED || _method == METHOD_FILE_SENDING || _method == METHOD_FILE_START_SEND)
						_text = Lang.sentVideo;
				} else
					_text = Lang.sentFile;
			} else if (_type == ChatSystemMsgVO.TYPE_STICKER)
				_text = Lang.stikerSent;
			else if (_type == ChatSystemMsgVO.TYPE_FORWARDED)
				_text = Lang.forwardedMessage;
			else if (_method == METHOD_GIFT_IN_GROUP_CHAT)
				_text = _additionalData as String;
			else if (_method == METHOD_BOT_MENU) {
				if (_botMenu != null) {
					if (_botMenu is String) {
						_text = _botMenu as String;
						_botMenu = null;
					} else if ("title" in _botMenu && _botMenu.title != null && _botMenu.title is String) {
						_text = _botMenu.title;
					} else
						_text = _title;
				} else
					_text = _title;
			} else
				_text = _title;
			return _text;
		}
		
		public function get textSmall():String {
			if (_textSmall != null)
				return _textSmall;
			if (_type == TYPE_911) {
				if (_method == METHOD_911_NOT_SATISFY)
					_textSmall = Lang.textQueNotSatisfied;
				else if (_method == METHOD_911_SATISFY_USER)
					_textSmall = Lang.textQueSatisfied;
				else if (_method == METHOD_911_SATISFY)
					_textSmall = Lang.textQueSatisfied;
				else if (_method == METHOD_911_GOT_ANSWER)
					_textSmall = Lang.textQueGotAnswer;
			} else if (_type == TYPE_COMPLAIN) {
				if (_method == METHOD_COMPLAIN_BLOCK)
					_textSmall = Lang.youBeenBlocked;
				if (_method == METHOD_COMPLAIN_SPAM)
					_textSmall = Lang.yourActivConsidSpam;
				if (_method == METHOD_COMPLAIN_ABUSE)
					_textSmall = Lang.yourActivConsidAbuse;
				if (_method == METHOD_COMPLAIN_STOP)
					_textSmall = Lang.chatBeenStopped;
			} else if (_type == TYPE_VOICE) {
				_textSmall = Lang.sentVoiceMessage;
			} else if (_type == TYPE_SYSTEM) {
				if (_method == METHOD_CAMERA_ON)
					_textSmall = Lang.videoCallStarted;
				else if (_method == METHOD_CAMERA_OFF)
					_textSmall = Lang.videoCallEnded;
				else
					_textSmall = method;
			} else if (_type == TYPE_FILE) {
				if (_fileType == FILETYPE_PUZZLE_CRYPTED) {
					_textSmall = Lang.sentPuzzle;
				} else if (_fileType == FILETYPE_IMG || _fileType == FILETYPE_IMG_CRYPTED) {
					if (_method == METHOD_FILE_SENDED)
						_textSmall = Lang.sentImage;
				} else if (_fileType == FILETYPE_VIDEO) {
					if (_method == METHOD_FILE_SENDED || _method == METHOD_FILE_SENDING || _method == METHOD_FILE_START_SEND)
						_textSmall = Lang.sentVideo;
				} else
					_textSmall = Lang.sentFile;
			} else if (_type == ChatSystemMsgVO.TYPE_STICKER)
				_textSmall = Lang.stikerSent;
			else if (_type == ChatSystemMsgVO.TYPE_FORWARDED)
				_textSmall = Lang.forwardedMessage;
			else if (_type == ChatSystemMsgVO.TYPE_CHAT_SYSTEM && callVO != null)
				_textSmall = callVO.textSmall;
			else if (_method == METHOD_GIFT_IN_GROUP_CHAT)
				_text = Lang.giftSent;
			else
				_textSmall = _title;
			return _textSmall;
		}
		
		public function get fileID():String { return _fileID; }		
		public function get botMenu():Object {return _botMenu; }
		public function get links():Array {return _links; }
		public function get rateBot():Object {return _rateBot; }
		public function get rateBotWebView():RateBotData {return _rateBotWebView; }
		public function get imageUID():String {	return _imageUID; }
		public function get geolocation():Location { return _geolocation; }
	}
}