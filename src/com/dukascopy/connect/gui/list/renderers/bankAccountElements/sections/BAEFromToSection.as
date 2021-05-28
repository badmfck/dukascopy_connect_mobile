package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAEFromToSection extends BankAccountElementSectionBase {
		
		private var leftTextColor:uint;
		private var rightTextColor:uint;
		
		private var textFormat:TextFormat;
		
		private var leftTextField:TextField;
		private var rightTextField:TextField;
		private var avatar:Sprite;
		
		private var avatarSize:int;
		
		private const V_PADDING:int = Config.FINGER_SIZE * .1;
		private const H_PADDING:int = Config.FINGER_SIZE * .25;
		private const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .26;
		
		public function BAEFromToSection() {
			super();
			
			textFormat = new TextFormat();
			textFormat.font = "Tahoma";
			textFormat.size = FONT_SIZE_NORMAL;
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.italic = false;
			textFormat.bold = false;
			
			avatar = new Sprite();
			avatar.y = int(CORNER_RADIUS_DOUBLE * .2);
			
			leftTextField = new TextField();
			leftTextField.x = BIRD_SIZE + H_PADDING;
			leftTextField.defaultTextFormat = textFormat;
			leftTextField.multiline = false;
			leftTextField.wordWrap = false;
			leftTextField.text = "|";
			leftTextField.y = int((CORNER_RADIUS_DOUBLE - leftTextField.textHeight - 4) * .5);
			leftTextField.text = "";
			addChild(leftTextField);
			
			rightTextField = new TextField();
			rightTextField.defaultTextFormat = textFormat;
			rightTextField.multiline = false;
			rightTextField.wordWrap = false;
			rightTextField.y = leftTextField.y
			addChild(rightTextField);
			
			avatarSize = CORNER_RADIUS_DOUBLE * .3;
		}
		
		override public function setWidth(w:int):void {
			super.setWidth(w);
		}
		
		override public function setData(data:Object, field:String = null):Boolean {
			if ("fromTo" in data == true && data.fromTo == true)
				this.data = data;
			return data.fromTo;
		}
		
		override public function fillData(li:ListItem):void {
			isFirst = false;
			isLast = false;
			
			setColorScheme();
			renderContent(li);
			
			bottomCornerY = contentHeight- CORNER_RADIUS;
			trueHeight = contentHeight;
		}
		
		private function renderContent(li:ListItem):void {
			avatar.graphics.clear();
			if (data.mine == true) {
				leftTextField.text = "To:";
				if ("user" in data == false || data.user == null) {
					if ("phone" in data == true) {
						rightTextField.text = data.phone;
					} else if ("login" in data == true) {
						rightTextField.text = data.login;
					} else if (data.acc == "DCO" && data.userAccNumber == BankManager.rewardAccount) {
						rightTextField.text = "Reward Deposit";
					} else {
						rightTextField.text = "N/A";
						//!TODO: костыль, необходимо более чёткое понимание типа транзакции в пользу банка;
						if (data.desc != null && data.desc == Lang.paidQuestionAward) {
							rightTextField.text = "Dukascopy";
						}
					}
				} else {
					rightTextField.text = data.user.getDisplayName();
					if (avatar.parent == null)
						addChild(avatar);
					var avatarIBMD:ImageBitmapData = li.getLoadedImage("userAvatar");
					if (avatarIBMD != null) {
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarIBMD, ImageManager.SCALE_PORPORTIONAL);
					} else {
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, UI.getEmptyAvatarBitmapData(), ImageManager.SCALE_PORPORTIONAL);
					}
				}
			} else {
				leftTextField.text = "From:";
				if ("user" in data == false || data.user == null) {
					if ("phone" in data == true) {
						rightTextField.text = data.phone;
					} else if ("login" in data == true) {
						rightTextField.text = data.login;
					} else {
						rightTextField.text = "N/A";
					}
				} else
					rightTextField.text = data.user.getDisplayName();
				if (avatar.parent != null)
					avatar.parent.removeChild(avatar);
			}
			
			leftTextField.width = leftTextField.textWidth + 4;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.textColor = leftTextColor;
			
			var maxWidth:int = trueWidth - (leftTextField.x + leftTextField.width) - Config.DOUBLE_MARGIN - BIRD_SIZE;
			if (avatar.parent != null)
				maxWidth -= avatarSize * 2 + Config.MARGIN;
			
			rightTextField.width = maxWidth;
			if (rightTextField.textWidth + 4 < maxWidth)
				rightTextField.width = rightTextField.textWidth + 4;
			rightTextField.height = rightTextField.textHeight + 4;
			rightTextField.textColor = rightTextColor;
			rightTextField.x = trueWidth - rightTextField.width - BIRD_SIZE - Config.MARGIN;
			
			avatar.x = rightTextField.x - avatarSize * 2 - Config.MARGIN;
			
			contentHeight = CORNER_RADIUS_DOUBLE;
		}
		
		override protected function setColorScheme():void {
			leftTextColor = COLOR_GRAY_LIGHT;
			if ("user" in data == false || data.user == null) {
				if (data.acc == "DCO" && data.userAccNumber == BankManager.rewardAccount) {
					bgColor = COLOR_WHITE;
					lineColor = COLOR_BLACK;
					lineAlpha = LINE_OPACITY_1;
					rightTextColor = COLOR_BLACK;
				} else {
					bgColor = COLOR_GRAY_DARK;
					lineColor = COLOR_WHITE;
					lineAlpha = LINE_OPACITY_2;
					rightTextColor = COLOR_WHITE;
				}
				return;
			}
			bgColor = COLOR_WHITE;
			lineColor = COLOR_BLACK;
			lineAlpha = LINE_OPACITY_1;
			rightTextColor = COLOR_BLACK;
		}
		
		override public function dispose():void {
			textFormat = null;
			UI.destroy(avatar);
			avatar = null;
			UI.destroy(leftTextField);
			leftTextField = null;
			UI.destroy(rightTextField);
			rightTextField = null;
			UI.destroy(this);
			super.dispose();
		}
		
		override public function getTextLineY():int {
			return rightTextField.y + rightTextField.getLineMetrics(0).ascent + 2;
		}
	}
}