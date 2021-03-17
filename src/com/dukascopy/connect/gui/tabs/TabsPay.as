package com.dukascopy.connect.gui.tabs {
	import assets.IconArrowWhiteRight;

	import com.dukascopy.connect.Config;

	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.greensock.TweenMax;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	/**
	 * @author Aleksei L
	 */
	public class TabsPay extends Tabs implements ITabsPay{
		public var btnTabL:BitmapButton;
		public var btnTabR:BitmapButton;

		private var isMoveAndSelect:Boolean = false;
		private var isStepWidthItem:Boolean = true;

		private var prevX:Number = -1;
		private var _arrawsColor:uint;
		private var _arrawsBGColor:uint;
		private var marginSides:int = 0;
		private var _widthWorkPlace:Number = 0;
		protected var _widthTabPay:int = 320;

		public function TabsPay(itemBgColor:uint = 0xFFFFFF, itemTextColor:uint = 0x00, itemBgAlpha:Number = 1, selectionBgColor:uint = 0xEA3311, tabsItemClass:Class = null, arrawsColor:uint = 0x0, arrawsBGColor:uint = 0x0,margin:int = 0) {
			_arrawsColor = arrawsColor;
			_arrawsBGColor = arrawsBGColor;
			setX(margin);
			super(itemBgColor, itemTextColor, itemBgAlpha, selectionBgColor, tabsItemClass);
		}

		private function setBTNTabActivity(btn:BitmapButton, active:Boolean, show:Boolean):void {
			if (active) {
				btn.activate();
			} else {
				btn.deactivate();
			}
			if (show) {
				btn.show();
			} else {
				btn.hide();
			}
		}

		private function btnHandlerRight():void {
			if (isMoveAndSelect) {
				selectNext();
				checkBTNActive();
			} else {
				moveByStep(false);
				/*TweenMax.delayedCall(.4, function ():void {
				 checkBTNActive2();
				 //updateView();
				 });*/
			}
		}

		private function btnHandlerLeft():void {
			if (isMoveAndSelect) {
				selectPrev();
				checkBTNActive();
			} else {
				moveByStep(true);
				/*TweenMax.delayedCall(.4, function ():void {
				 checkBTNActive2();
				 updateView();
				 });*/
			}
		}

		public function get currentID():String {
			return current != null ? current.id : "";
		}

		private function moveByStep(isToLeft:Boolean):void {
			if (wasTapped)
				return;
			tapper.stop();
			var tX:int;
			if (isStepWidthItem && current != null) {
				var item:ITabsItem;
				var i:int = 0;
				var valueTemp:Number = -1;
				var boxItemsValue:Number = boxItems.x < 0 ? -(boxItems.x) : boxItems.x;
				var posX:Number;
				if (isToLeft) {
					i = 0;
					i = stock.length - 1;

					for (i; i >= 0; i--) {
						item = stock[i];
						posX = item.view.x /*+ btnTabL.width * .14*/;
						if (posX < boxItemsValue) {
							valueTemp = posX;
							break;
						} else if (posX == boxItems.x) {
							valueTemp = posX + item.view.width;
							break;
						}
					}

					if (valueTemp == -1) {
						tX = boxItems.x + item.view.width;
					} else {
						tX = -valueTemp;
					}
				} else {
					if (0 < current.num) {
						tX = stock[current.num - 1].view.x;
					}
					i = 0;
					for (i; i < stock.length; i++) {
						item = stock[i];
						posX = item.view.x;
						if (posX > boxItemsValue) {
							valueTemp = posX;
							break;
						} else if (posX == boxItemsValue) {
							valueTemp = posX + item.view.width;
							break;
						}
					}
					if (valueTemp == -1) {
						tX = boxItems.x - item/*current*/.view.width;
					} else {
						tX = valueTemp < 0 ? valueTemp : -valueTemp;
					}
				}
			} else {
				tX = isToLeft ? boxItems.x + _widthTabPay : boxItems.x - _widthTabPay;
			}

			if (tX >= 0) {
				tX = 0;
			}
			if (tX <= -(boxItems.width - _widthTabPay)) {
				tX = -(boxItems.width - _widthTabPay);
			}
			TweenMax.killTweensOf(boxItems);
			var speed:Number = (/*animate*/true) ? .2 : 0;
			if (boxItems.width > _widthTabPay) {
				wasTapped = true;
				TweenMax.to(boxItems, speed, {
					x: tX, onComplete: function ():void {
						wasTapped = false;
						onMoved();
						checkBTNActive2();
					}
				});
			}
		}

		private function checkBTNActive2():void {
			if (isActive == false /*|| prevX == boxItems.x */ || _isHidenBTN || btnTabL ==null ||btnTabR == null)return;
			prevX = boxItems.x;
			if (boxItems.x > (-btnTabL.width) && boxItems.x <= btnTabL.width * .5) {
				setBTNTabActivity(btnTabL, false, false);
				setBTNTabActivity(btnTabR, true, true);
			} else if (boxItems.x + boxItems.width < _widthTabPay + btnTabR.width) {
				setBTNTabActivity(btnTabR, false, false);
				setBTNTabActivity(btnTabL, true, true);
			} else {
				setBTNTabActivity(btnTabL, true, true);
				setBTNTabActivity(btnTabR, true, true);
			}
		}

		private function checkBTNActive():void {
			if (prevX == boxItems.x || _isHidenBTN)return;
			prevX = boxItems.x;
			if (stock == null)
				return;
			if (current != null && isActive) {
				var l:int = stock.length;
				if (current.num == stock[l - 1].num) {
					setBTNTabActivity(btnTabR, false, false);
					setBTNTabActivity(btnTabL, true, true);
				} else if (current.num == stock[0].num) {
					setBTNTabActivity(btnTabL, false, false);
					setBTNTabActivity(btnTabR, true, true);
				} else {
					setBTNTabActivity(btnTabL, true, true);
					setBTNTabActivity(btnTabR, true, true);
				}
			}
		}

		override public function activate():void {
			tapper.neadMove = boxItems.width>_widthTabPay;
			super.activate();
			prevX = -1;
			if (isMoveAndSelect) {
				checkBTNActive();
			} else {
				checkBTNActive2();
			}
		}

		override public function deactivate():void {
			super.deactivate();
			if(btnTabR != null)
				setBTNTabActivity(btnTabR, false, false);
			if(btnTabL != null)	
				setBTNTabActivity(btnTabL, false, false);
		}

		private function createBTN(isLeft:Boolean):BitmapButton {
			var sp:Sprite = new Sprite();
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [_arrawsBGColor, _arrawsBGColor];
			var alphas:Array;
			var colorInfo:ColorTransform;
			var ratios:Array;
			var matr:Matrix = new Matrix();
			var searchButtonIcon:DisplayObject;
			var itmH:int = height - offsetTop;
			ratios = [0x00, 0xFF];
			alphas = [1, 0.1];
			searchButtonIcon = new IconArrowWhiteRight();
			colorInfo = searchButtonIcon.transform.colorTransform;
			colorInfo.color = _arrawsColor;
			searchButtonIcon.transform.colorTransform = colorInfo;
			matr.createGradientBox(itmH * .14, itmH * .14, 3.14, 0, 0);

			var spreadMethod:String = SpreadMethod.PAD;
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			sp.graphics.drawRect(0, 0, itmH * .6, itmH);
			sp.graphics.endFill();

			UI.scaleToFit(searchButtonIcon, itmH * .3, itmH * .3);
			searchButtonIcon.x = (sp.width - searchButtonIcon.width) * .5;
			searchButtonIcon.y = itmH * .35;

			sp.addChild(searchButtonIcon);
			var btn:BitmapButton = new BitmapButton();
			btn.setStandartButtonParams();
			btn.setDownScale(1);
			btn.cancelOnVerticalMovement = true;
			if (isLeft) {
				sp.scaleX = -1;
				sp.x += sp.width;
			}
			btn.setBitmapData(UI.getSnapshot(sp, StageQuality.HIGH, "TabsPay.tabButton"));
			btn.hide();

			return btn;
		}

		override protected function updateView():void {
			super.updateView();
			isHidenBTN = _widthTabPay > boxItems.width + 2;

			if (_isHidenBTN) {
				if (btnTabR)btnTabR.hide();
				if (btnTabL)btnTabL.hide();
				super.setX(marginSides);
//				tapper.setBounds([_widthTabPay - marginSides * 2, height - offsetTop]);
				boxItems.x = getXBoxItems();
				tapper.setBounds([_widthTabPay - marginSides * 2, height - offsetTop]);
			} else {
				super.setX(0);
				if (isMoveAndSelect) {
					checkBTNActive();
				} else {
					checkBTNActive2();
				}
			}
		}
		override protected function setBoundsTapper():void {
			var itmH:int = _height - offsetTop;
			var arr:Array;
			if(_isHidenBTN){
				arr = [_widthTabPay - marginSides * 2,height/*, height - offsetTop*/];
//				arr.push(_isHidenBTN? height - offsetTop:height);
			}else{
				arr = [_widthTabPay, itmH];
			}
			if(offsetTop > 0){
				if (_isHidenBTN) {
					arr.push(height - offsetTop);
					arr.push(offsetTop);
				}else{
					arr.push(0);
					arr.push(offsetTop);
				}
				tapper.setBounds(arr/*[_widthTabPay, itmH, 0, offsetTop]*/);
			}else{
				tapper.setBounds(arr);
			}
		}

		override protected function checkBoxBounds(scrollStopped:Boolean = false):void {
			if (wasTapped) return;
			if (boxItems.width <= width) {
				boxItems.x = getXBoxItems();
			} else {
				if (scrollStopped) {
					if (boxItems.x + boxItems.width < width)
						TweenMax.to(boxItems, 10, {useFrames: true, x: width - boxItems.width});
					else if (boxItems.x > 0)
						TweenMax.to(boxItems, 10, {useFrames: true, x: 0});
				} else {
					if (boxItems.x > 0) {
						boxItems.x -= boxItems.x * .4;
					} else if (boxItems.x + boxItems.width < width) {
						boxItems.x -= (boxItems.x - (width - boxItems.width)) * .4;
					}
				}
			}
		}

		override protected function getXBoxItems():Number {
			var result:Number ;
			var resultTab:Number ;
			result = (width - boxItems.width ); /*- marginSides*/
			resultTab = (_widthTabPay - boxItems.width ); /*- marginSides*/
			if(_isHidenBTN && resultTab > 0){
				var setW:Number = result;
				if(result < 0){
					result = marginSides;
				}else{
					result = result*.5;
				}
				rebuildItemLR(setW);
			}else{
				result = result * .5;
			}
			return result;
		}

		private function rebuildItemLR(cutWidth:int):void {

			if (stock == null)
				return;
			//check for duplicate

			var itab:ITabsItem;
			var l:int = stock.length;
			if(l==0)return;

			var setW:Number  = cutWidth/l;
			if(setW>0 && setW<=1) return;
			for (var i:int = 0; i < l; i++) {
				itab = stock[i];
				if (itab == null){
					continue;
				}
				itab.cutByLeft(setW);
			}

			super.updateView();
		}

		override public function setWidthAndHeight(w:int, h:int):void {
			_widthTabPay = w;
			widthWorkPlace = w - /*Config.DOUBLE_MARGIN*/ marginSides*2;
			super.setWidthAndHeight(widthWorkPlace/*w*/, h);
//			super.setWidthAndHeight(w, h);
			//Config.DOUBLE_MARGIN
			if (btnTabL == null && btnTabR == null) {
				btnTabL = createBTN(true);
				btnTabL.tapCallback = btnHandlerLeft;
				btnTabR = createBTN(false);
				btnTabR.tapCallback = btnHandlerRight;
				_view.addChild(btnTabL);
				_view.addChild(btnTabR);

			}
			btnTabL.x = 0;
			btnTabR.x = w - btnTabR.width;

			if (_isHidenBTN) {
				boxBg.graphics.clear();
				boxBg.graphics.beginFill(itemBgColor);
				boxBg.graphics.drawRect(0, 0, widthWorkPlace, height);
				boxBg.graphics.endFill();
			}
		}

		override public function select(id:String, animate:Boolean = true, ignoreSide:Boolean = false):void {
			super.select(id, animate, ignoreSide);
			if (animate) {
				TweenMax.delayedCall(.3, delayedCallCheckBTNActive)
			} else {
				delayedCallCheckBTNActive()
			}
		}

		private function delayedCallCheckBTNActive():void {
			if (isMoveAndSelect) {
				checkBTNActive();
			} else {
				checkBTNActive2();
			}
			updateView();
		}

		override public function setX(x:int):void {
			marginSides = x;
		}

		override protected function onCompleteSelect():void {
			wasTapped = false;
			/*if (isMoveAndSelect) {
			 checkBTNActive();
			 } else {
			 checkBTNActive2();
			 }*/
		}

		override protected function onMoved(scrollStopped:Boolean = false):void {
				super.onMoved(scrollStopped);
				if (scrollStopped) {
					checkBTNActive2();
				}
		}

		override public function dispose():void {
			if (btnTabR != null) {
				btnTabR.dispose();
			}
			if (btnTabL != null) {
				btnTabL.dispose();
			}
			TweenMax.killDelayedCallsTo(delayedCallCheckBTNActive)
			super.dispose();
		}

		/*override public function get width():int {
			if(_widthWorkPlace == 0 ){
				return 320;
			}
			return _widthWorkPlace/!* super.width*!/;
		}*/

		public function get indexSelected():int {
			return current != null && current.selection ? current.num : -1;
		}

		public function get isMoved():Boolean {
			return tapper.wasDown;
		}

		public function set isHidenBTN(value:Boolean):void {
			_isHidenBTN = value;
		}

		public function set widthWorkPlace(value:Number):void {
			_widthWorkPlace = value;
		}

		public function get widthWorkPlace():Number {
			return _widthWorkPlace;
		}
	}
}