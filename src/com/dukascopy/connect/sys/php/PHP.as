package com.dukascopy.connect.sys.php {

	
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.SHA256;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.ResponseResolver;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.data.paidChat.PaidChatData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.Base64Modified;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.CallsHistoryItemVO;
	import com.hurlant.util.Base64;
	import com.telefision.sys.etc.Print_r;
	import com.telefision.sys.signals.Signal;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.NetworkInterface;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import gibberishAES.AESCrypter;


	/**
	* @author Igor Bloom
	*/

	public class PHP {
		
		static public var methodsWithoutKey:Array = ["config.get", "auth.serverTime", "geo.locate", "auth.requestCode", "auth.checkCode", "sms.verificationCall", "company.startChat", "auth.guest", "chat.hGetMessages", "files.addImage"];
		
		static public var core:String = null;
		static public const S_ERROR:Signal = new Signal("PHP.S_ERROR");
		static public const S_COMPLETE:Signal = new Signal("PHP.S_COMPLETE");
		static public const NETWORK_ERROR:String = "io";
		static private var init:Boolean;
		
		static private var apiVersion:String = null;
		
		static public function call_statVI(action:String, txt:String = "", callback:Function = null, sUID:String = "unknown"):void {
			var userUID:String = Auth.uid;
			if (userUID == null)
				userUID = "WlDyDOWaDZWxWm";
			if (Config.isTest())
				action = "test_" + action;


			if (Config.PLATFORM_ANDROID == true && apiVersion == null) {
				try {
					apiVersion = NativeExtensionController.getVersion()+"";
				} catch (exception:Error) {
					apiVersion = "unknown";
				}
			}

			var ccode:int = Auth.countryCode;
			if (ccode == 7 && Auth.phone.toString().substr(0,2) == "77")
				ccode = 77;
			var data:Object = {
				sUID:sUID,
				sEmail:"unknown",
				UIN:"unknown",
				cUID:userUID,
				cPhone:Auth.phone,
				type:"client",
				platform:Config.PLATFORM + "," + apiVersion,
				action:action,
				version:Config.VERSION,
				data:txt,
				country:ccode
			};
			call("",callback,data,Config.URL_VI_STAT,true,"POST",false,true);
		}

		static public function call_regDev():void {
			var data:Object = {
				key:Auth.key,
				udid:Auth.devID,
				device:Capabilities.manufacturer+", "+Capabilities.os+", "+Capabilities.version,
				platform:Config.PLATFORM_APPLE?"ios":"android",
				country:Auth.countryISO
			};
			call("",null,data,Config.URL_DEV_STAT,true,"POST",false,true);
		}
		
		static public function out_getWSSHost(callBack:Function):void {
			call('out.getWSS', callBack);
		}
		
		static public function form_getFormData(callBack:Function, formID:String, chatUID:String):void {
			//call('form.getFullTestData', callBack,{formID:formID, chatUID:chatUID},null, true);
			call('form.getFullBuildData', callBack,{formID:formID, chatUID:chatUID, c:true});
		}
		
		static public function call_getConfig(callBack:Function):void {
			call('config.get', callBack);
		}
		
		static public function call_getMRZDataByPhone(phone:String=null):void{
			call('profile.getDataByPhone', null, {phone:phone});
		}
		
		static public function call_setMRZDataByPhone(data:String):void{
			call('profile.setDataByPhone', null, {data:data});
		}
		
		static public function call_addRD(callBack:Function, transactionID:String, amount:Number, ts:Number, type:String, reward:String, raw:String = null):void {
			call('deposit.save', callBack, {
				transactionID: transactionID,
				depositAmount: amount,
				expired: ts,
				type: type,
				raw: raw,
				rewardAmount: reward,
				ver: 2
			});
		}
		
		static public function call_getRD(callBack:Function):void {
			call('deposit.getMy', callBack);
		}
		
		
		/**
		 * Get token for open rto
		 * @param	callBack
		 * @param	userUIDS
		 * @param	createChatOnly
		 */
		static public function call_stsGet(callBack:Function, promoCode:String, notaryFlow:Boolean,coolPhone:Boolean,birthDate:String,documentID:String,documentType:String,expired:String,nationality:String):void {
			call('sts.get', callBack,{params:{nationality:nationality,promocode:promoCode,expired:expired,documentID:documentID,documentType:documentType,birthDate:birthDate,coolphone:(coolPhone)?1:0,notaryflow:(notaryFlow)?1:0,version:Config.VERSION,platform:Config.PLATFORM}});
		}
		
		static public function chat_start(callBack:Function, userUIDS:Array, createChatOnly:Boolean = false, caller:String = ""):void {
			if (userUIDS != null && userUIDS.length > 0 && userUIDS[0] != null && (userUIDS[0] as String).indexOf("+") != -1)
			{
				MobileGui.addReport(caller);
				ApplicationErrors.add();
			}
			
			var requestData:Object = new Object();
			requestData.userUIDS = userUIDS;
			if (userUIDS != null && userUIDS.length == 1)
			{
				if (Shop.getPendingTransaction(userUIDS[0]) != null)
				{
					requestData.trx = Shop.getPendingTransaction(userUIDS[0]);
				}
			}
			
			call('chat.start', callBack, requestData, null, false, "POST", true, false, { usetUIDs:userUIDS, createLocal:true, createChatOnly:createChatOnly } );
		}
		
		static public function call_chatCreateFX(callBack:Function, fxid:uint):void {
			call("chat.fxstart", callBack, { fxid:fxid } );
		}
		
		public static function chat_getLatest(callBack:Function,hash:String, ignore:String = null, firstTime:Boolean = false):void {
			call('chat.hLatest', callBack, { sort:"msg", hash:hash, ignore:ignore, limit:(firstTime == true) ? ChatManager.getFirstChatsCount() : 50 }, null, false, "POST", true, false, { firstTime:firstTime } );
		}
		
		static public function chat_getMessages(callBack:Function, chatUID:String, hash:String, lastID:int = 0, chatType:String = null, firstTime:Boolean = true):void {
			var obj:Object = { chatUID:chatUID };
			if (hash == null)
				obj.hash = '-1';
			else
				obj.hash = hash;

			if (lastID != 0)
				obj.banan = "-" + lastID;
			else
				obj.banan = 0;
			
			obj.stat = true;
			if (lastID == 0)
				obj.limit = (firstTime == true) ? ChatManager.getFirstMsgsCount() : 50;
			if (chatType)
				obj.tp = chatType;
			trace(UI.tracedObj(obj));
			call('chat.hGetMessages', callBack, obj, null, false, "POST", true, false, { firstTime:firstTime } );
		}
		
		static public function countryGroup_getMy(callBack:Function):void {
			call('countryGroup.getCountryGroup', callBack);
		}
		
		static public function admin911_changeRating(callBack:Function, userUID:String):void {
			call('admin911.changeRating', callBack, { uUID:userUID, rating:-1 } );
		}
		
		static public function admin911_ban(callBack:Function, userUID:String, reason:String):void {
			call('admin911.ban', callBack, { uUID:userUID, reason:reason } );
		}
		
		static public function admin911_banForever(callBack:Function, userUID:String, reason:String):void {
			call('ban.byUser', callBack, { uid:userUID, reason:reason } );
		}
		
		static public function chat_get(callBack:Function, chatUID:String, fullKey:Boolean = true, updateUnreaded:Boolean = true, reason:String = ""):void {
			if (chatUID == null || chatUID == "")
			{
				ApplicationErrors.add();
				var error:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, false, "chat_get with empty chatUID: " + reason);
				var e:UncaughtErrorEvent = new UncaughtErrorEvent(UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, error);
				Main.onGlobalError(e);
				return;
			}
			call('chat.get', callBack, { chatUID:chatUID, fullKey:fullKey,updateUnreaded:updateUnreaded, ver:1 } );
		}
		
		static public function auth_getCurrentUser(callBack:Function, hash:String = null):void{
			call('auth.getCurrentUser', function(r:PHPRespond):void {
				if (r.error == false)
					updateShadowProfile(r.data);
				callBack(r);
			}, {hash:hash} );
		}
		
		static public function updateShadowProfile(userData:Object):void {
			if (("profile" in userData) && ("type" in userData.profile) && userData.profile.type == "shadow") {
				if (("fxcomm" in userData.profile) && userData.profile.fxcomm != null) {
					var resultName:String;
					if ("name" in userData.profile.fxcomm && userData.profile.fxcomm.name != null) {
						try {
							var recievedBytesName:ByteArray = Base64Modified.decode(userData.profile.fxcomm.name);
							recievedBytesName.position = 0;
							resultName = recievedBytesName.readUTFBytes(recievedBytesName.length);
						}
						catch (e:Error) {
							echo("PHP", "auth_getCurrentUser.profile.get", "Can`t parse base64: " + e.message+", " + userData.profile.fxcomm.name,true);
							resultName = userData.profile.name;
						}
					}
					var resultSurname:String;
					if ("surname" in userData.profile.fxcomm && userData.profile.fxcomm.surname != null) {
						try {
							var recievedBytesSurName:ByteArray = Base64Modified.decode(userData.profile.fxcomm.surname);
							recievedBytesSurName.position = 0;
							resultSurname = recievedBytesSurName.readUTFBytes(recievedBytesSurName.length);
						} catch (e:Error) {
							echo("PHP", "auth_getCurrentUser.profile.get", "Can`t parse base64: " + e.message+", " + userData.profile.fxcomm.surname,true);
							resultSurname = userData.profile.surname;
						}	
					}
					if (resultName == TextUtils.NULL) {
						resultName = "";
					}
					if (resultSurname == TextUtils.NULL) {
						resultSurname = "";
					}
					userData.profile.fxcomm.firstname = resultName;
					userData.profile.fxcomm.lastname = resultSurname;
				} else {
					userData.profile.fxcomm = new Object();
					userData.profile.fxcomm.avatar = null;
					userData.profile.fxcomm.avatar_large = null;
					userData.profile.fxcomm.firstname = userData.profile.name;
					userData.profile.fxcomm.lastname = "";
				}
			}
		}
		
		static public function stickers_get(callBack:Function, hash:String = null):void {
			call('stickers.getList', callBack, { hash:hash } );
		}
		
		static public function getCompanyMemberProfile(callBack:Function, uid:String, hash:String = null):void {
			call('company.getCompanyMemberData', callBack, { mUID:uid, hash:hash } );
		}
		
		static public function auth_requestCode(callBack:Function, phone:String, devID:String, additionalData:Object = null):void {
			var data:Object = {phone:phone, devID:devID,/*Capabilities.isDebugger,*/ lng:Capabilities.languages[0] };
		//	data.debug=0;
			/*if (Config.SERVER_NAME.toLocaleLowerCase().indexOf("pre") !=-1)
				data.ver = 3;*/
			call('auth.requestCode', callBack, data, null, false, "POST", true, false, additionalData);
		}
		
		static public function auth_requestCall(callBack:Function, phone:String, devID:String):void {
			call('sms.verificationCall', callBack, { phone:phone, devID:devID/*Capabilities.isDebugger*/, lng:Capabilities.languages[0], ver:2 } );
		}
		
		static public function auth_sendCode(callBack:Function, phone:String, devID:String, code:String, version:String, deviceName:String, additionalData:Object = null):void {
			call('auth.checkCode',  function(r:PHPRespond):void {
				if (r.error) {
					callBack(r);
					return;
				}
				if ("authKey" in r.data && r.data.authKey != "web")
					Auth.not_recomendet_setAuth(r.data.authKey);
				updateShadowProfile(r.data);
				callBack(r);
			}, { buildVer:Config.VERSION, phone:phone, devID:devID, code:code, appVersion:version, deviceName:deviceName, ver:1 }, null, false, "POST", true, false, additionalData);
		}
		
		static public function set_token(callBack:Function, token:String):void {
			call('auth.setToken', callBack, { token:token } );
		}
		
		static public function contacts_get(callBack:Function, hash:String = null):void {
			call('contacts.get', callBack, { hash:hash, ver:2 });
		}
		
		static public function findating_get(callBack:Function, hash:String = null):void {
			call('findating.get', callBack, { hash:hash } );
		}
		
		static public function phonebook_sync(callBack:Function, phones:Array, hash:String, devID:String):void {
			if (!hash)
				hash = "0";
			call("phonebook.sync", callBack, { phones:phones, hash:hash, devID:devID, ver:1 }, null, false, 'POST');
		}
		
		static public function phonebook_invite(callBack:Function, phone:String):void {
			call("phonebook.invite", callBack, { phone:phone, ver:1 } );
		}
		
		/**
		 * Get Company
		 * @param	callBack
		 * @param	id - String - company uid, by default: Dukascopy Company
		 */
		static public function company_getEPs(callBack:Function, hash:String, id:String = '08A29C35B3'):void {
			call('company.get', callBack, { companyID:id, hash:hash } );
		}
		
		static public function company_get(callBack:Function, hash:String):void {
			call('company.get', callBack, { hash:hash } );
		}

		static public function langhash_get(callBack:Function, hash:String):void {
			callLang('outTool.getLHashes', callBack, { hash:hash }, null, false, URLRequestMethod.GET );
		}

		static public function company_members(callBack:Function, hash:String):void {
			return;
			var obj:Object = new Object();
			if (Auth.companyID != null){
				obj.companyID = Auth.companyID;
			}
			obj.hash = hash;
			call('company.members', callBack, obj);
		}

		static public function company_startChat(callBack:Function, epID:int):void {
			//ts - to get created in timestamp;
			call('company.startChat', callBack, { epID:epID,ignoreMember:true, ts:true} );
		}
		
		static public function company_startChat_guest(callBack:Function, guestUID:String, epID:int):void {
			//ts - to get created in timestamp;
			call('company.startChat', callBack, { epID:epID, guestUID:guestUID, ts:false} );
		}
		
		static public function requestGuestAuth(callBack:Function):void {
			call('auth.guest', callBack);
		}
		
		static public function call_openSupportChat(callBack:Function, epID:int):void {
			var obj:Object = { };
			obj.epID = epID;
			if (Auth.type == "guest")
				obj.guestUID = Auth.uid;
			call('company.startChat', callBack, obj);
		}
		
		
		static public function chat_updateUnreadedMessages(chatUID:String):void {
			call("chat.updateUnreaded", null, { chatUID:chatUID } );
		}
		
		static public function search_all(callBack:Function, value:String):void {
			call("search.all", callBack, { part:value, ver:1 } );
		}
		
		static public function search_channel(callBack:Function, value:String):void {
			call("irc.getByCodename", callBack, { code:value });
		}
		
		static public function search_category(callBack:Function, value:String):void {
			call("question.getCategories", callBack, { search:value });
		}
		
		static public function file_chunkUpload(callBack:Function, data:ByteArray, fileName:String, 
												fileIndex:int, chunkSize:int, totalSize:int, position:int, 
												chatUID:String, type:String, crypted:Boolean = false, 
												imageUID:String = null, isVideoProtocol:Boolean = false):void {
			var phpFormData:PHPFormData = new PHPFormData();
			if (isVideoProtocol == true) {
				phpFormData.addParam("method", "files.uploadVideoChunk");
			} else {
				phpFormData.addParam("method", "files.uploadChunk");
			}
			phpFormData.addParam("key", Auth.key); 
			phpFormData.addParam("position", position+"");
			phpFormData.addParam("totalSize", totalSize+"");
			phpFormData.addParam("chatUID", chatUID);
			phpFormData.addParam("type", type);
			phpFormData.addParam("fileIndex", fileIndex+"");
			phpFormData.addParam("fileName", fileName);
			if (isVideoProtocol == false) {
				phpFormData.addParam("ver", "1");
			}
			if (imageUID) {
				phpFormData.addParam("rUID", imageUID);
			}
			var cryptedString:String;
			if (crypted) {
				cryptedString = "true"
			} else {
				cryptedString = "false"
			}
			phpFormData.addParam("crypted", cryptedString);
			phpFormData.addParam("chunkSize", chunkSize+"");
			phpFormData.addParam("fileName", fileName);
			phpFormData.addFile("chunk", 'chunk.data', data, function():void {
				phpFormData.send(Config.URL_PHP_CORE_SERVER_FILE, callBack);
			});
		}
		
		static public function auth_getUserByPhone(callBack:Function, value:String):void {
			call('auth.getUserByPhone', callBack, { phone:value } );
		}
		
		static public function auth_logout(callBack:Function):void {
			call('auth.logout', callBack, { } );
		}
		
		static public function call_reportAdd(callBack:Function, message:String, stock:String,lastError:String):void {
			if (Auth.key == "web")
				return;
			var uid:String = "unknown uid";
			if (Auth.uid != null)
				uid = Auth.uid;
			var phone:String = "unknown phone";
			if (Auth.phone > 0)
				phone = Auth.phone + "";
			call('report.add', callBack, { key:"web", method:"report.add", message:message,stock:stock,serverString:Capabilities.serverString,appVersion:Config.PLATFORM_TYPE,uid:uid,phone:phone,lastError:lastError}, Config.URL_PHP_LOG_SERVER);
		}
		
		static public function call_gelLocation(callBack:Function):void {
			call('geo.locate', callBack, { } );
		}
		
		public static function block_user(callBack:Function, userUID:String):void {
			call("block.set", callBack, {uid: userUID } );
		}
		
		public static function unblock_user(callBack:Function, userUID:String):void {
			call("block.release", callBack, {uid: userUID});
		}
		
		static public function call_chatRemove(chatUID:String, userUID:String, callBack:Function, additionalData:Object):void {
			call("chat.remove", callBack, { chatUID: chatUID, userUID:userUID }, null, false, "POST", true, false, additionalData);
		}
		
		static public function addUsersToChat(chatUID:String, users:Array, callBack:Function, requestID:String):void {
			call("chat.add", callBack, { chatUID: chatUID, userUIDs:users }, null, false, "POST", true, false, { requestID:requestID, users:users } );
		}
		
		static public function changeChatTitle(uid:String, value:String, callBack:Function, additionalData:Object):void {
			call("chat.topic", callBack, { chatUID: uid, topic:value }, null, false, "POST", true, false, additionalData);
		}
		
		static public function changeChatAvatar(uid:String, image:String, callBack:Function):void {
			call("chat.setAvatar", callBack, {chatUID: uid, img:image}, null, false, null, false);
		}
		
		static public function changeUserAvatar(image:String, callBack:Function):void {
			call("profile.saveAvatar", callBack, {img: image}, null, false, null, false);
		}
		
		static public function profile_getFXGallery(fxID:int, callBack:Function):void {
			call("profile.getFXGallery", callBack, {fxid: fxID}, null, false, null);
		}
		
		static public function saveProfile(avatarId:String, firstName:String, lastName:String, callBack:Function, dataType:String):void {
			if (!firstName) {
				firstName = "";
			}
			if (!lastName) {
				lastName = "";
			}
			var data:Object = new Object();
			if (dataType == Auth.AVATAR) {
				data.avatar = avatarId;
				if (Auth.type == UserType.USER) {
					data.name = Base64.encode(firstName);
					data.surname = Base64.encode(lastName);
				}
			}
			else if (dataType == Auth.NAME) {
				data.name = Base64.encode(firstName);
				data.surname = Base64.encode(lastName);
			}
			call("profile.set", callBack, {data:JSON.stringify(data)});
		}
		
		static public function getUserByPhone(phone:String, callBack:Function, full:Boolean = false):void {
			var data:Object = new Object();
			data.phone = phone;
			data.ver = 1;
			if (full)
				data.full = true; // to obtain full user profile;
			call("profile.getUserByPhone", callBack, data, null, false, "POST", true, false, { phone:phone } );
		}
		
		static public function calls_get(callBack:Function, hash:String):void {
			call("call.getAll", callBack, { hash:hash } );
		}
		
		static public function sendNewCallInfo(callModel:CallsHistoryItemVO, callBack:Function):void {
			var data:Object = new Object();
			data.cID = callModel.id;
			data.toUID = callModel.userUID;
			data.t = "placed";
			if (callModel.pid > 0) {
				var additionalData:Object = new Object();
				additionalData.pid = callModel.pid;
				additionalData.pidTitle = callModel.title;
				
				data.data = AESCrypter.enc(JSON.stringify(additionalData), Auth.uid);
			}
			call("call.set", callBack, data);
		}
		
		static public function updateCallInfo(callId:String, callStatus:String, callBack:Function):void {
			var data:Object = new Object();
			data.cID = callId;
			data.t = callStatus;
			call("call.upd", callBack, data);
		}
		
		static public function markCallsSeen(callBack:Function):void {
			call("call.viewed", callBack, { } );
		}
		
		static public function question_get(callBack:Function, hash:String = null, quid:String = null, categories:String = null, limit:int = 50):void {
			call("question.get", callBack, { hash:hash, qUID:quid, categories:categories, ver:6, limit:limit }, null, false, "POST", true, false, { quid:quid, limit:limit } );
		}
		
		static public function question_getOne(callBack:Function, quid:String = null):void {
			call("question.get", callBack, { qUID:quid, ver:6 }, null, false, "POST", true, false, { quid:quid } );
		}
		
		static public function question_prolong(callBack:Function, quid:String, trx:String):void {
			call("question.registerFreshener", callBack, { quid:quid, trx:trx } );
		}
		
		static public function question_isPaid(callBack:Function, quid:String = null):void {
			call("question.isPaid", callBack, { qUID:quid } );
		}
		
		static public function question_reserve_tips(callBack:Function, tipsAmount:Number, tipsCurrency:String, questionType:String):void {
			var data:Object = { };
			if (isNaN(tipsAmount) == false) {
				data.tipsAmount = tipsAmount;
				data.tipsCurrency = tipsCurrency;
				data.type = questionType;
			}
			call("question.reserveTipsForSuspend", callBack, data);
		}
		
		static public function question_create(
			callBack:Function,
			text:String,
			tipsAmount:Number,
			tipsCurrency:String,
			categories:String,
			incognito:Boolean = false,
			type:String = QuestionsManager.QUESTION_TYPE_PRIVATE,
			lat:Number = NaN,
			lon:Number = NaN,
			reservedQuestionId:String = null,
			price:String = ""):void {
				var data:Object = { };
				data.text = text;
				data.ver = 4;
				if (isNaN(tipsAmount) == false) {
					data.tipsAmount = tipsAmount;
					data.tipsCurrency = (tipsCurrency == "DUK+") ? "DCO" : tipsCurrency;
				}
				data.type = type;
				data.price = price;
				if (categories != null)
					data.categories = categories;
				if (incognito == true)
					data.anonymous = true;
				if (isNaN(lat) == false && isNaN(lon) == false) {
					data.latt = lat;
					data.long = lon;
				}
				if (reservedQuestionId != null)
					data.preOrder = reservedQuestionId;
				call("question.create", callBack, data);
		}
		
		static public function question_edit(callBack:Function, quid:String, text:String, tipsAmount:Number, tipsCurrency:String, categories:String, incognito:Boolean = false):void {
			var data:Object = { };
			data.qUID = quid;
			if (text != null)
				data.text = text;
			if (isNaN(tipsAmount) == false) {
				data.tipsAmount = tipsAmount;
				data.tipsCurrency = (tipsCurrency == "DUK+") ? "DCO" : tipsCurrency;
			}
			if (categories != null)
				data.categories = categories;
			if (incognito == true)
				data.anonymous = true;
			call("question.edit", callBack, data);
		}
		
		static public function question_answer(callBack:Function, questionUID:String):void {
			call("question.answer", callBack, { qUID:questionUID }, null, false, "POST",true, false, { quid:questionUID } );
		}
		
		static public function question_answers(callBack:Function, questionUID:String, hash:String):void {
			call("question.getAnswers", callBack, { qUID:questionUID, hash:hash }, null, false, 'POST', true, false, { qUID:questionUID } );
		}
		
		static public function question_top_reactions(callBack:Function, chatUID:String):void {
			call("irc.getTopReactions", callBack, { chatUID:chatUID }, null, false, 'POST', true, false, { chatUID:chatUID } );
		}
		
		static public function question_closeAnswer(callBack:Function, status:String, uid:String, additionalData:Object):void {
			var data:Object = {
				chatUID:uid,
				status:status
			}
			if (additionalData != null && "notPayable" in additionalData == true && additionalData.notPayable != null)
				data.pay_off = additionalData.notPayable;
			call("question.closeAnswer", callBack, data, null, false, "POST", true, false, additionalData);
		}
		
		static public function question_closePublicAnswer(callBack:Function, status:String, questionUID:String, winnerUID:String, additionalData:Object):void {
			call("question.closePublicAnswer", callBack, { qUID:questionUID, userUID:winnerUID, status:status }, null, false, "POST", true, false, additionalData);
		}
		
		static public function question_close(callBack:Function, uid:String):void {
			call("question.close", callBack, { qUID:uid }, null, false, "POST", true, false, { qUID:uid } );
		}
		
		static public function question_closeByAdmin(callBack:Function, uid:String):void {
			call("admin911.removeQuestion", callBack, { qUID:uid }, null, false, "POST", true, false, { qUID:uid } );
		}
		
		static public function question_getStatMy(callBack:Function, hash:String):void {
			call("question.getUserStat", callBack, { hash:hash } );
		}
		
		static public function question_getStatUser(callBack:Function, userUID:String, hash:String):void {
			call("question.getUserStat", callBack, { uid:userUID, hash:hash }, null, false, "POST", true, false, { userUID:userUID } );
		}
		
		static public function complain_complain(callBack:Function, type:String, data:String, reason:String, info:String, callBackBool:Function = null):void {
			call("complain.add", callBack, { type:type, data:data, reason:reason, info:info }, null, false, "POST", true, false, callBackBool);
		}
		
		static public function chat_startOffline(callBack:Function, userUID:String, securityKey:String):void {
			call("chat.startOffline", callBack, { userUID:userUID, sKey:securityKey } );
		}
		
		static public function gift_setItem(callBack:Function, userUID:String, code:int, days:int, reason:String, incognito:Boolean, info:String):void {
			call("gift.setItem", callBack, { uid:userUID, code:code, days:days, reason:reason, incognito:incognito, info:info } );
		}
		
		static public function channelStart(callBack:Function, title:String = null, mode:String = null, settingsValues:Object = null):void {
			var data:Object = new Object();
			if (title != null)
				data.topic = title;
			if (mode != null)
				data.type = mode;
			if (settingsValues != null)
				data.settings = settingsValues;
			call("irc.start", callBack, data)
		}
		
		static public function enableChannel(callBack:Function, uid:String, days:int, amount:Number):void {
			call("ircPayRoutine.enable", callBack, { days:days, uid:uid, amount:amount } );
		}
		
		static public function channelGet(callBack:Function, hash:String):void {
			call("irc.channels", callBack, { my:false, hash:hash } );
		}
		
		static public function call_irc_trash(callBack:Function, hash:String):void {
			call("irc.trash", callBack, { hash:hash } );
		}
		
		static public function channelsSearch(callBack:Function, searchString:String):void {
			call("irc.searchByName", callBack, { part:searchString, key:Auth.key } );
		}
		
		static public function addDocument(callBack:Function, chatUID:String, data:ByteArray, title:String):void {
			var phpFormData:PHPFormData = new PHPFormData();
			phpFormData.addParam("method", "files.addDoc");
			phpFormData.addParam("key", Auth.key); 
			phpFormData.addParam("title", title); 
			phpFormData.addParam("chatUID", chatUID);
			phpFormData.addFile("doc", 'doc', data, function():void {
				phpFormData.send(Config.URL_PHP_CORE_SERVER_FILE, callBack);
			});
		}
		
		static public function addUserToMemo(callBack:Function, uid:String, userName:String = "", info:String = ""):void {
			var name:String;
			if (userName && userName != "")
				name = Base64.encode(userName);
			call("memobook.addContact", callBack, { uid:uid, name:name, info:info, c:true } );
		}
		
		static public function irc_updateSetting(callBack:Function, chatUID:String, settingsType:String, value:String, additionalData:Object = null):void {
			call("irc.updateSetting", callBack, { cuid:chatUID, k:settingsType, val:value }, null, false, "POST", true, false, additionalData);
		}
		
		static public function irc_setAvatar(callBack:Function, channelUID:String, imageString:String):void {
			call("irc.setAvatar", callBack, {chatUID:channelUID, img:imageString});
		}
		
		static public function files_savePublicImage(callBack:Function, imageString:String, thumbString:String):void {
			call("files.savePublicImage", callBack, {key:Auth.key, method:"files.savePublicImage", img:imageString, thumb:thumbString}, Config.URL_PHP_CORE_SERVER_FILE, false, 'POST', false);
		}
		
		static public function call_mrzUpload(callBack:Function, imageString:String):void {
			call("mrz.upload", callBack, { image:imageString }, null, false, "POST", false);
		}
		
		static public function irc_changeTopic(callBack:Function, channelUID:String, value:String, responseResolver:ResponseResolver):void {
			call("irc.topic", callBack, {chatUID:channelUID, topic:value, b64:true}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function irc_addModerator(callBack:Function, channelUID:String, userUID:String, responseResolver:ResponseResolver):void {
			call("irc.addOP", callBack, {chatUID:channelUID, uid:userUID, remove:false}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function irc_removeModerator(callBack:Function, channelUID:String, userUID:String, responseResolver:ResponseResolver):void {
			call("irc.addOP", callBack, {chatUID:channelUID, uid:userUID, remove:true}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function irc_getBans(callBack:Function, channelUID:String, responseResolver:ResponseResolver):void {
			call("irc.getBans", callBack, {chatUID:channelUID, ver:1}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function irc_getSettings(callBack:Function, channelUID:String, responseResolver:ResponseResolver):void {
			call("irc.getSettings", callBack, {uid:channelUID}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function call_ping(callBack:Function):void {
			call("auth.serverTime", callBack);
		}
		
		static public function call_getToads(callBack:Function):void {
			call("profile.latestToads", callBack);
		}
		
		static public function info_saveLog(callBack:Function, product:String, act:String, data:String, platform:String):void {
			call("info.saveLog", callBack, { product:product, act:act, data:data, platform:platform, atime:int(new Date().getTime() / 1000) } );
		}
		
		static public function irc_remove(callBack:Function, channelUID:Object, responseResolver:ResponseResolver):void {
			call("irc.close", callBack, {uid:channelUID}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function irc_subscribe(callBack:Function, channelUID:Object, responseResolver:ResponseResolver):void {
			call("irc.signChannel", callBack, {cuid:channelUID}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function irc_unsubscribe(callBack:Function, channelUID:Object, responseResolver:ResponseResolver):void {
			call("irc.exitChannel", callBack, {cuid:channelUID}, null, false, "POST", true, false, responseResolver);
		}
		
		static public function question_createFirst911(currentLang:String, questionText:String):void {
			call("question.createFirst911", onFirstQuestionSent, { language:currentLang, text:questionText } );
		}
		
		static public function auth_showRating(callback:Function, value:Boolean, onSaved:Function):void {
			call("profile.setShowRating", callback, { val:value }, null, false, "POST", true, false, { callback:onSaved } );
		}
		
		static public function call_eraseFile(thumbUID:String):void {
			call("files.erase", null, { uid:thumbUID }, Config.URL_PHP_CORE_SERVER_FILE, false, 'POST', false );
		}
		
		static public function user_getByUID(callback:Function, userUID:String, hash:String):void {
			call("profile.getByUID", callback, { userUID:userUID, hash:null }, null, false, "POST", true, false, { userUID:userUID } );
		}
		
		static public function user_getByUIDs(callback:Function, userUIDsWithHashes:Array):void {
			call("profile.getByUIDs", callback, { users:userUIDsWithHashes }, null, false, "POST", true, false, { users:userUIDsWithHashes } );
		}
		
		static private function onFirstQuestionSent(r:PHPRespond):void {
			QuestionsManager.onQuestionCreated(r);
		}
		
		static public function referral_enterCode(callback:Function, code:String, deviceID:String):void {
			call("referral.saveInvite", callback, { code:code, devID:deviceID });
		}
		
		static public function referral_getReferralProgramData(callback:Function):void 
		{
			call("referral.getInvites", callback);
		}
		
		static public function referral_getCode(callback:Function):void 
		{
			call("referral.getCode", callback);
		}
		
		static public function referral_getInvite(callback:Function):void 
		{
			call("referral.getInvite", callback);
		}
		
		static private function callLang(method:String, callBack:Function=null, data:Object=null,  url:String = null, rawRespond:Boolean = false, requestMethod:String = 'POST', crypt:Boolean = true,noAuthKey:Boolean=false):void {
			if (url == null) {
				url = Config.URL_LANG;
				if (data == null)
					data = { };
				data.method = method;
				data.key = "web";
			}
			var php:IDataLoader = getLoader();
			php.load(url, callBack, data, URLRequestMethod.POST, null, rawRespond, crypt);
		}
		
		static public function loadPaidBanConfig(callback:Function):void {
			call("paidBan.getPrice", callback);
		}
		
		static public function loadFlowersConfig(callback:Function):void {
			call("gift.getPrice", callback);
		}
		
		static public function loadBalance(callback:Function, curr:String = null, ignoreCache:Boolean = false):void {
			var reqData:Object = new Object();
			reqData.curr = curr;
			reqData.ignoreCache = ignoreCache;
			call("pp.balance", callback, reqData);
		}
		
		static public function requestPaidUserBan(callback:Function, userUID:String, days:int, reason:String, incognito:Boolean):void 
		{
			call("paidBan.setBan", callback, { uid:userUID, days:days, reason:reason, incognito:incognito });
		}
		
		static public function requestFinishUserBan(callback:Function, banID:int, transactionID:String):void 
		{
			call("paidBan.registerSetBanPaid", callback, { id:banID, trid:transactionID});
		}
		
		static public function getFullBanData(callback:Function, banID:int):void 
		{
			call("paidBan.getBanByID", callback, { id:banID }, null, false, "POST", true, false, { banId:banID } );
		}
		
		static public function requestUnban(callback:Function, userUID:String, reason:String):void 
		{
			call("paidBan.removeBan", callback, { uid:userUID, reason:reason });
		}
		
		static public function requestFinishUserUnban(callback:Function, unbanRequestID:int, transactionID:String):void 
		{
			call("paidBan.registerRemoveBanPaid", callback, { id:unbanRequestID, trid:transactionID });
		}
		
		static public function requestBanProtection(callback:Function, userUID:String, weeks:int):void 
		{
			call("paidBan.setProtection", callback, { uid:userUID, days:weeks });
		}
		
		static public function requestFinishBanProtection(callback:Function, protectionRequestId:int, transactionID:String):void 
		{
			call("paidBan.registerSetProtectionPaid", callback, { id:protectionRequestId, trid:transactionID });
		}
		
		static public function requestBuyProduct(callback:Function, chatUID:String, count:int, totalPrice:Number, currency:String):void 
		{
			call("chatAccess.registerOrder", callback, { cuid:chatUID, cnt:count, amount:totalPrice, curr:currency});
		}
		
		static public function registerBuyProduct(callback:Function, requestID:Number, transactionID:String):void 
		{
			call("chatAccess.registerPayment", callback, { id:requestID, trx:transactionID });
		}
		
		static public function bots_get(callBack:Function, hash:String = null):void {
			call('contacts.botList', callBack, { hash:hash, ver:2 });
		}
		
		static public function addBotToChannel(channelID:String, botID:String, callBack:Function, requestID:String):void {
			call("irc.signBotToChannel", callBack, { cuid: channelID, botUID:botID, action:"sign" }, null, false, "POST", true, false, { requestID:requestID, botUID:botID, channelID:channelID } );
		}
		
		static public function removeBotFromChannel(channelID:String, botID:String, callBack:Function, requestID:String = null):void {
			call("irc.signBotToChannel", callBack, { cuid: channelID, botUID:botID, action:"delete" }, null, false, "POST", true, false, { requestID:requestID } );
		}
		
		static public function paidBan_getBan(callBack:Function):void {
			call('paidBan.getBan', callBack, { });
		}
		
		static public function paidBan_getTopBans(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('paidBan.getTopBans', callBack, { limit:50, hash:hash }, null, false, 'POST', true, false);
		}
		
		static public function gift_getCurrentGifts(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('gift.getCurrentGifts', callBack, { limit:50, hash:hash }, null, false, 'POST', true, false);
		}
		
		static public function gift_topGifted(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('gift.topGifted', callBack, { limit:10, hash:hash }, null, false, 'POST', true, false);
		}
		
		static public function miss_getActualRound(callBack:Function, hash:String, limit:int = 50, onlyMiss:int = 0):void {
			if (hash == null) {
				hash = "123";
			}
			var request:Object = new Object();
			request.limit = limit;
			if (onlyMiss == 0) {
				request.onlyMiss = onlyMiss;
			}
			request.timestamp = (new Date()).time;
			call('MissDCRating.GetActualRound', callBack, request, null, false, 'POST', true, false);
		}
		
		static public function miss_getReview(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('MissDCRating.GetReview', callBack, { limit:5, hash:hash }, null, false, 'POST', true, false);
		}
		
		static public function getMyOrders(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('chatAccess.bought', callBack, { active:true } );
		}
		
		static public function getMyProducts(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('chatAccess.myProducts', callBack, { active:true });
		}
		
		static public function getProductBuyers(callBack:Function, productId:Number):void {
			call('chatAccess.sold', callBack, { id:productId }, null, false, 'POST', true, false, {productId:productId});
		}
		
		static public function paidBan_getActiveProtections(callBack:Function, hash:String):void {
			if (hash == null) {
				hash = "123";
			}
			call('paidBan.getActiveProtections', callBack, { limit:Config.JAIL_SECTION_PROTECTIONS_NUM, hash:hash });
		}
		
		static public function files_forwardImage(callBack:Function, imageID:String, key:String, chatUID:String, messageData:Object):void {
			call('files.forwardImage', callBack, {key:Auth.key, method:'files.forwardImage', uid:imageID, sk:key, targetChat:chatUID}, 
					Config.URL_PHP_CORE_SERVER_FILE, false, "POST", true, false, { targetChat:chatUID, messageData:messageData } );
		}
				
		static public function api_yiPhase(phase:String, type:String = null, callback:Function = null):void{
			var data:Object = { uid: Auth.uid, code: phase};
			if (type != null)
				data.type = type;
				
			
			call('api.viPhase',callback,data);
		}
		
		static public function call_geo_saveCurrent(callBack:Function, location:Location):void{
			call('geo.saveCurrent', callBack, { lat:location.latitude, lng:location.longitude });
		}
		
		static public function call_geo_neighbours(callBack:Function):void 
		{
			call('geo.neighbours', callBack);
		}
		
		static public function call_lotto_getActive(callBack:Function):void 
		{
			call('lotto.getActive', callBack, {ver:1});
		}
		
		static public function call_lotto_checkAccess(callBack:Function, id:String):void 
		{
			call('lotto.checkSpecialAccess', callBack, {type:2}, null, false, 'POST', true, false, {id:id});
		}
		
		static public function call_inspectIRC(callBack:Function, channelUID:String, status:String):void 
		{
			call('admin.inspectIRC', callBack, {chatUID:channelUID, act:status}, null, false, "POST", true, false, {channelUID:channelUID, status:status});
		}
		
		static public function call_lotto_addMe(eventId:String, callBack:Function):void 
		{
			call('lotto.addMe', callBack, {lottoId:eventId}, null, false, 'POST', true, false, {id:eventId});
		}
		
		static public function call_lotto_getWinners(callBack:Function):void 
		{
			call('lotto.getWinners', callBack);
		}
		
		static public function bot_getByUID(callBack:Function, uid:String):void {
			call('bot.getByUid', callBack, { uid: uid } );
		}
		
		static public function api_readyForVIDID(callBack:Function,pid:int):void {
			call('api.readyForVIDID', callBack, { pid:pid } );
		}
		
		static public function call_barabanGetDay(callBack:Function, startDate:Date):void {
			var start:String = DateUtils.getTimeString(startDate);
			call('', callBack, { start:start, method:"baraban.getDay", key:Auth.key }, Config.URL_PHP_CORE_SERVER, false, 'POST', true, false, {date:startDate});
		}
		
		static public function call_barabanCheckRange(callBack:Function, startDate:Date, days:int, showFirst:Boolean):void {
			var start:String = DateUtils.getTimeString(startDate);
			call('', callBack, { start:start, days:days, showFirst:showFirst, method:"baraban.checkRange", key:Auth.key }, Config.URL_PHP_CORE_SERVER);
		}
		
		static public function call_barabanCheckMyBook(callBack:Function):void {
			call('', callBack, { method:"baraban.checkMyBook", key:Auth.key }, Config.URL_PHP_CORE_SERVER);
		}
		
		static public function call_barabanBook(callBack:Function, date:Date):void {
			var start:String = DateUtils.getTimeString(date);
			call('', callBack, { method:"baraban.book", key:Auth.key, dateTime:start }, Config.URL_PHP_CORE_SERVER);
		}
		
		static public function call_barabanRelease(callBack:Function, id:String):void {
			call('', callBack, { method:"baraban.release", key:Auth.key, id:id }, Config.URL_PHP_CORE_SERVER);
		}
		
		static public function getWSSHost(callBack:Function):void {
			call('', callBack);
		}
		
		static public function call_loyaltyCheck(callBack:Function):void 
		{
			call('loyalty.check', callBack, {} );
		}
		
		static public function userAccess_check(callBack:Function, userUID:String):void {
			call("userAccess.check", callBack, {uid:userUID});
		}
		
		static public function userAccess_stat(callBack:Function):void {
			call("userAccess.stat", callBack);
		}
		
		static public function userAccess_apply(callBack:Function, data:PaidChatData):void {
			
			var currency:String = "";
			var cost:Number = 0;
			var request:Object;
			
			if (data != null)
			{
				request = new Object()
				if (data.photo != null)
				{
					request.photo = data.photo;
				}
				if (data.title != null)
				{
					request.title = data.title;
				}
				if (data.description != null)
				{
					request.description = data.description;
				}
				if (data.photo != null)
				{
					request.photo = data.photo;
				}
				currency = data.currency;
				cost = data.cost;
			}
			
			call("userAccess.apply", callBack, {curr:currency, amount:cost, info:request});
		}
		
		static public function call_loyaltyRegister(callBack:Function, service:String = null):void 
		{
			var data:Object = new Object();
			data.type = "gold";
			data.currency = "EUR";
			data.amount = Config.FAST_TRACK_COST;
			if (service != null)
			{
				data.service = service;
			}
			call('loyalty.register', callBack, data);
		}
		
		static public function pay_issueCardStore(callBack:Function, currency:String, system:String, type:String, deliveryMethod:String):void 
		{
			call('PayGW.IssueCardSave', callBack, {cardCurrency:currency, paymentSystem:system, cardType:type, shipmentType:deliveryMethod});
		}
		
		static public function pay_issueCardGet(callBack:Function):void 
		{
			call('PayGW.IssueCardGet', callBack);
		}
		
		static public function mrz_hash(callBack:Function, mrzHash:String, link:String):void 
		{
			call('mrz.hash', callBack, {s:mrzHash}, null, false, 'POST', true, false, {link:link});
		}
		
		static public function getCardComission(callBack:Function, system:String, currency:String, cardType:String, deliveryMethod:String):void 
		{
			call('PayGW.CornerCardCommission', callBack, {cardCurrency:currency, cardType:cardType, paymentSystem:system, shipmentType:deliveryMethod});
		}
		
		static public function call_checkForCryptoCashAmount(callBack:Function, tca:String, wa:String):void {
			var url:String = "https://api.etherscan.io/api?module=account&action=tokenbalance";
			url += "&contractaddress=" + tca;
			url += "&address=" + wa;
			url += "&tag=latest"
			call(null, callBack, { }, url, true, "POST", false);
		}
		
		static public function user_messagesFromOpponent(callBack:Function, uid:String):void {
			call('User.MessagesFromOpponent', callBack, { user:uid } );
		}
		
		static public function get_countryDeposite(callback:Function, countryCode:int):void {
			call("", callback, { method:"" }, "http://ws.telefision.com/country?code=" + countryCode, false, "GET", false);
		}
		
		static public function getRegistrationSteps(callback:Function, type:String = null):void {
			call("PhaseConfig.GetSteps", callback, null, null, false, 'POST', true, false, {type:type});
		}
		
		static public function getDevices(callback:Function):void 
		{
			call("device.myList", callback);
		}
		
		static public function user_saveExtraData(callBack:Function, param:String, value:String):void 
		{
			call('User.SetExtraData', callBack, { name:param, value:value } );
		}
		
		static public function call_getChatFilters(callBack:Function):void 
		{
			call('User.GetChatFilters', callBack);
		}
		
		static public function call_selectSolvencyMethod(callBack:Function, code:String):void 
		{
			call('User.SelectSolvencyMethod', callBack, {code:code});
		}
		
		static public function call_checkZbx(callBack:Function):void 
		{
			call('User.CheckZbx', callBack);
		}
		
		static public function call_setChatFilters(callBack:Function, values:Object):void 
		{
			var data:Object = new Object();
			data.filters = values;
			call('User.SetChatFilters', callBack, data);
		}
		
		static public function payThirdParty(callBack:Function, uid:String, currency:String, amount:Number, comment:String, showRecipientName:Boolean = true):void 
		{
			var data:Object = new Object();
			data.userTo = uid;
			data.currency = currency;
			data.amount = amount;
			data.description = comment;
			if (showRecipientName == false)
			{
				data.showRecipientName = false;
			}
			call('Pay.PayThirdParty', callBack, data );
		}
		
		static public function filesAddImage(chatUID:String, image:String, thumb:String, title:String, callBack:Function):void
		{
			var data:Object = new Object();
			data.key = "web";
			data.chatUID = chatUID;
			data.image = image;
			data.thumb = thumb;
			data.title = title;
			data.b64 = true;
			data.method = "files.addImage";
			data.crypted = false;
			
			call('files.addImage', callBack, data, Config.URL_PHP_CORE_SERVER_FILE);
		}
		
		static public function escrow_requestInvestigation(callBack:Function = null, data:Object = null):void 
		{
			call('escrow.claim', callBack, data);
		}
		
		static public function escrow_addEvent(callBack:Function = null, data:Object = null):void 
		{
			call('escrow.addEvent', callBack, data);
		}
		
		static private function call(method:String, callBack:Function = null, data:Object = null,  url:String = null, rawRespond:Boolean = false, requestMethod:String = 'POST', crypt:Boolean = true, noAuthKey:Boolean = false, additionalData:Object = null):void {
			
			if (Auth.key == "web" && methodsWithoutKey.indexOf(method) == -1 && rawRespond == false) {
				
				if (callBack != null) {
					var phpRespond:PHPRespond = new PHPRespond();
					phpRespond.setData(true, "Wrong data");
					callBack(phpRespond);
				}
				
				return;
			}
			if (init == false) {
				core = Config.URL_PHP_CORE_SERVER;
				init = true;
			}
			if (url == null) {
				url = core;
				if (data == null)
					data = { };
				data.method = method;
				data.key = Auth.key;
				if (noAuthKey == true)
					data.key = 'web';
			}
			var php:IDataLoader = getLoader();


			var txt:String="\nDCCAPI --------"+php.getID()+"\n";
			txt+"\tURL: "+url;
			for(var i:String in data) {
				var val:String=data[i];
				if(val==null)
					val="null";
				if(val.length>80)
					val=val.substr(0,80)+"... +("+val.length+")";
				txt += "\n\t" + i + ": " + val;
			}
			txt+="\n---------------";

			echo("PHP","call",txt);

			php.setAdditionalData(additionalData);
			php.load(url, callBack, data, (requestMethod != null && requestMethod == "GET") ? URLRequestMethod.GET : URLRequestMethod.POST, null, rawRespond, crypt);
		}
		
		static private function getLoader():IDataLoader {
			var phpLoader:IDataLoader;
			phpLoader = new PHPLoader();
			return phpLoader;
		}
	}
}