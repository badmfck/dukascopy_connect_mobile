package com.dukascopy.connect.screens.serviceScreen
{

    import com.adobe.crypto.MD5;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.ImagePreviewCrop;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.sys.auth.Auth;

    public class BotReactionManager{

        public function saveLastURL(lastURL:String):void{
			var tempRect:Rectangle = new Rectangle()
			var point:Point = new Point(view.x, view.y);
			point = view.localToGlobal(point);
			tempRect.x = point.x;
			tempRect.y = point.y + closeButton.y + closeButton.height + padding;
			tempRect.width = _width;
			tempRect.height = _height - closeButton.y - closeButton.height - padding;

			lastURL=data.link;

			if(Config.PLATFORM_APPLE){
				wkWebKit=WKWebKit.getInstance();
				wkWebKit.onComplete=function (url:String):void{
					if(url!=data.link)
						fireCallback(true,url);
				}
				wkWebKit.show(tempRect,data.link);
				return;
            }
        }

        private function onPhonesLoaded():void {
			clearUsers();
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = PhonebookManager.getConnectContacts(true, true);
			cData.sort(sortUsers);
			var cDataNew:Array = [];
			var listItemModel:ChatUserlistModel;
			var contactsNum:int = cData.length;
			for (var i:int = 0; i < contactsNum; i++) {
				newDelimiter = String(cData[i].userVO.getDisplayName()).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				listItemModel = new ChatUserlistModel();
				listItemModel.contact = cData[i].userVO;
				listItemModel.status = UserStatusType.UNSELECTED;
				cDataNew.push(listItemModel);
			}
			users = cDataNew;
			list.setData(cDataNew, ListChatUsers);
			cDataNew = null;
			cData = null;
			
			updateListSize();
		}

        private function createTitle():void {
			if (screenData.title != null) {
				title.bitmapData = TextUtils.createTextFieldData(
					screenData.title,
					_width - Config.DIALOG_MARGIN * 4,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.LEFT,
					int(Config.FINGER_SIZE * .42),
					true,
					0x596269,
					0xFFFFFF
				);
			}
		}
    }
}