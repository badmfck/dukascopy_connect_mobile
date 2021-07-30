package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatMessageVOMethodType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Общий предок чат рендереров, сюда вінесен общий функционал типа цвета бекграунда
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererBase extends Sprite {
		
		protected const minFontSize:int = 9;
		
		static public const smallGap:int = Config.FINGER_SIZE * .06;
		
		static private var COLOR_BG_MINE:uint = Color.GREEN;
		static private var COLOR_BG_MINE_NOT_SENT:uint = 0x97CE9C;
		static private var COLOR_BG_USER:uint = Style.color(Style.MESSAGE_COLOR);
		static protected var COLOR_BG_WHITE:uint = Style.color(Style.MESSAGE_COLOR);
		static protected var COLOR_BG_INFO:uint = 0xFFFFFF;
		static protected var COLOR_BG_ABUSE:uint = Color.RED;
		static protected var COLOR_BG_SATISFIED:uint = 0X0889EC;
		static protected var COLOR_TEXT_MINE:uint = 0xFFFFFF;
		static protected var COLOR_TEXT_USER:uint = Style.color(Style.COLOR_TEXT);
		static protected var COLOR_TEXT_INFO:uint = 0x363D4D;
		static protected var COLOR_TEXT_SELECTOR_TITLE:uint = 0x464E62;
		static protected var COLOR_TEXT_SELECTOR_VALUE:uint = 0xC5D1DB;
		static protected var COLOR_TEXT_SELECTOR_TITLE_SELECTED:uint = 0x7E95A8;
		static protected var COLOR_TEXT_SELECTOR_VALUE_SELECTED:uint = 0x363D4D;
		
		protected var colorText:uint;
		protected var boxBg:Shape;
		private var _forwardView:ChatMessageRendererForwardView;
		protected var ct:ColorTransform = new ColorTransform();
		
		protected var textBoxRadius:int = 5;
		protected var vTextMargin:Number;
		protected var hTextMargin:Number;
		
		public function ChatMessageRendererBase() {
			vTextMargin = Math.ceil(Config.FINGER_SIZE * .13);
			hTextMargin = Math.ceil(Config.FINGER_SIZE * .2);
			textBoxRadius = Math.ceil(Style.size(Style.MESSAGE_RADIUS));
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function dispose():void {
			ct = null;
			UI.destroy(boxBg);
			boxBg = null;
			if (_forwardView != null) {
				if (_forwardView.parent != null)
					_forwardView.parent.removeChild(_forwardView);
				_forwardView.dispose();
			}
			_forwardView = null;
		}
		
		protected function updateBubbleColors(msgVO:ChatMessageVO):void {
			if (msgVO == null)
				return;
			if (msgVO.typeEnum == ChatSystemMsgVO.TYPE_911 || msgVO.typeEnum == ChatSystemMsgVO.TYPE_COMPLAIN) {
				var resColor:int;
				if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_NOT_SATISFY)
					resColor = COLOR_BG_ABUSE;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_SATISFY_USER)
					resColor = COLOR_BG_SATISFIED;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_SATISFY)
					resColor = COLOR_BG_SATISFIED;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_GOT_ANSWER)
					resColor = COLOR_BG_ABUSE;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_COMPLAIN_BLOCK)
					resColor = COLOR_BG_ABUSE;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_COMPLAIN_SPAM)
					resColor = COLOR_BG_ABUSE;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_COMPLAIN_ABUSE)
					resColor = COLOR_BG_ABUSE;
				else if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_COMPLAIN_STOP)
					resColor = COLOR_BG_ABUSE;
				colorText = COLOR_TEXT_MINE;
			} else if (msgVO.isEntryMessage == true) {
				resColor = COLOR_BG_INFO;
				colorText = COLOR_TEXT_INFO;
			} else if (msgVO.userUID == Auth.uid) {
				if (msgVO.id < 0)
					resColor = COLOR_BG_MINE_NOT_SENT;
				else
					resColor = COLOR_BG_MINE;
				colorText = COLOR_TEXT_MINE;
			} else {
				resColor = COLOR_BG_USER;
				colorText = COLOR_TEXT_USER;
			}
			
			if (boxBg != null)
				setColorToDisplayObjectIfRequired(boxBg, ct , resColor);
			updateIsColorTransformChanged(ct,resColor)
		}
		
		protected function initBg(color:int, roundedTop:Boolean = true, roundedBottom:Boolean = true):void {
			var bgSize:int = textBoxRadius * 3;
			if (boxBg == null)
				boxBg = new Shape();
			else
				boxBg.graphics.clear();
			var rTop:int = (roundedTop == true) ? textBoxRadius : 0;
			var rBottom:int = (roundedBottom == true) ? textBoxRadius : 0;
			boxBg.graphics.beginFill(color, 1);
			boxBg.graphics.drawRoundRectComplex(0, 0, bgSize, bgSize, rTop, rTop, rBottom, rBottom);
			boxBg.graphics.endFill();
			boxBg.scale9Grid = new Rectangle(textBoxRadius, textBoxRadius, textBoxRadius, textBoxRadius);
			if (boxBg.parent == null)
				addChild(boxBg);
		}
		
		public function getSmallGap(listItem:ListItem):int {
			return smallGap;
		}
		
		protected function get forwardView():ChatMessageRendererForwardView {
			if (_forwardView == null)
				_forwardView = new ChatMessageRendererForwardView();
			return _forwardView;
		}
		
		protected function get isContainsForwardView():Boolean {
			if (_forwardView == null)
				return false;
			if (!contains(_forwardView))
				return false;
			return true;
		}
		
		protected function removeForwardView():void {
			if (isContainsForwardView)
				removeChild(_forwardView);
		}
		
		protected function updateIsColorTransformChanged(colorTransform:ColorTransform, newColor:int):Boolean {
			if (colorTransform.color == newColor)
				return false;
			colorTransform.color = newColor;
			return true;
		}
		
		protected function setColorToDisplayObjectIfRequired(displayObject:DisplayObject, colorTransform:ColorTransform, newColor:int):void {
			var isColorChanged:Boolean = updateIsColorTransformChanged(colorTransform, newColor);
			if (isColorChanged == false && displayObject.transform.colorTransform == colorTransform)
				return;
			displayObject.transform.colorTransform = colorTransform;
		}
	}
}