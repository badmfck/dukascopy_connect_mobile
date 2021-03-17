package com.dukascopy.connect.screens {

import assets.AppIntroBack;
import assets.AppIntrotextDelimiter;

import com.dukascopy.connect.Config;

import com.dukascopy.connect.MobileGui;
import com.dukascopy.connect.data.TextFieldSettings;

import com.dukascopy.connect.gui.components.animation.IntroAnimation1;
import com.dukascopy.connect.gui.components.animation.IntroAnimation2;
import com.dukascopy.connect.gui.components.animation.IntroAnimation3;
import com.dukascopy.connect.gui.lightbox.UI;
import com.dukascopy.connect.gui.menuVideo.BitmapButton;
import com.dukascopy.connect.gui.tools.PageSelector;
import com.dukascopy.connect.screens.base.BaseScreen;
import com.dukascopy.connect.sys.auth.Auth;
import com.dukascopy.connect.sys.chatManager.ChatManager;
import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
import com.dukascopy.connect.utils.TextUtils;
import com.dukascopy.langs.Lang;
import com.greensock.TweenMax;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.display.StageQuality;
import flash.geom.Point;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;


public class VITestScreen extends BaseScreen {

        static public const PAGE_1:String = "page1";
        static public const PAGE_2:String = "page2";
        static public const PAGE_3:String = "page3";

        private var background:Sprite;
        private var skipButton:BitmapButton;
        //private var pageSelector:PageSelector;
        private var locked:Boolean = false;
        private var nextButton:BitmapButton;
        private var sidePadding:Number;
        private var currentPage:String;
        private var page1:Sprite;
        private var page2:Sprite;
        private var page3:Sprite;

        private var title_1:Bitmap;
        private var title_2:Bitmap;
        private var title_3:Bitmap;

        private var text_1:Bitmap;
        private var text_2:Bitmap;
        private var text_3:Bitmap;

        private var image_1:IntroAnimation1;
        private var image_2:IntroAnimation2;
        private var image_3:IntroAnimation3;
        private var currentPageClip:Sprite;
        private var back:AppIntroBack;
        private var delimiter_1:AppIntrotextDelimiter;
        private var delimiter_2:AppIntrotextDelimiter;
        private var delimiter_3:AppIntrotextDelimiter;
        private var startPoint:Point;
        private var page2Created:Boolean;
        private var page3Created:Boolean;

        public function VITestScreen() {

        }

        override public function initScreen(data:Object = null):void {
            if (MobileGui.stage != null){
                MobileGui.stage.quality = StageQuality.HIGH;
            }

            super.initScreen(data);

            _params.doDisposeAfterClose = true;

            background.graphics.beginFill(0xFFFFFF);
            background.graphics.drawRect(0, 0, _width, _height);

            /*var pages:Vector.<String> = new Vector.<String>();
            pages.push(PAGE_1);
            pages.push(PAGE_2);
            pages.push(PAGE_3);
            pageSelector.setData(pages);*/

            sidePadding = Config.FINGER_SIZE;
            var buttonWidth:int = (_width - Config.FINGER_SIZE * 1.5) / 2;

            var textSettings:TextFieldSettings = new TextFieldSettings("SIGN OUT", 0, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
            var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x81CA2E, 0, Config.FINGER_SIZE * .8, NaN, buttonWidth);
            skipButton.setBitmapData(buttonBitmap);

            textSettings = new TextFieldSettings("START", 0xFFFFFF, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
            buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
            nextButton.setBitmapData(buttonBitmap);

            //	createBack();

            skipButton.x = Config.FINGER_SIZE*.5;
            nextButton.x = _width - Config.FINGER_SIZE * .5 - nextButton.width;

            skipButton.y = int(_height - Config.FINGER_SIZE * .5 - skipButton.height - Config.APPLE_BOTTOM_OFFSET);
            nextButton.y = int(_height - Config.FINGER_SIZE * .5 - skipButton.height - Config.APPLE_BOTTOM_OFFSET);

            //pageSelector.y = int(nextButton.y - Config.FINGER_SIZE*.4 - pageSelector.height);
            //pageSelector.x = int(_width * .5 - pageSelector.width * .5);

            createPage1();

            currentPageClip = page1;
            currentPage = PAGE_1;
        }


    private function createPage1():void
    {
        title_1.bitmapData = TextUtils.createTextFieldData(
                "Visual Identification",
                _width - sidePadding * 2,
                10, true,
                TextFormatAlign.CENTER,
                TextFieldAutoSize.LEFT,
                Config.FINGER_SIZE * .44,
                true, 0x97AEC4, 0xFFFFFF, true);

        text_1.bitmapData = TextUtils.createTextFieldData(
                "Proceed with visual identification",
                _width - sidePadding * 2,
                10, true,
                TextFormatAlign.CENTER,
                TextFieldAutoSize.LEFT,
                Config.FINGER_SIZE * .35,
                true, 0x606E7B, 0xFFFFFF, true);

        page1.addChild(text_1);
        text_1.x = int(_width * .5 - text_1.width * .5);


        //	page1.addChild(delimiter_1);
        //	delimiter_1.x = int(_width * .5 - delimiter_1.width * .5);
        //	delimiter_1.y = int(text_1.y - Config.FINGER_SIZE * .5);

        page1.addChild(title_1);
        title_1.x = int(_width * .5 - title_1.width * .5);
        title_1.y = int(_height * .5 + Config.FINGER_SIZE * 0.8);

        text_1.y = int(title_1.y + title_1.height + Config.FINGER_SIZE * .35);

        var imageHeight:int = title_1.y - Config.FINGER_SIZE * .8;

        image_1 = new IntroAnimation1(_width, _height);

        page1.addChild(image_1);
        image_1.x = 0;
        image_1.y = int(_height*.5 - image_1.height);
    }




    override protected function createView():void {
        super.createView();

        background = new Sprite();
        view.addChild(background);

        skipButton = new BitmapButton();
        skipButton.setStandartButtonParams();
        skipButton.setDownScale(1);
        skipButton.setDownColor(0);
        skipButton.tapCallback = signOut;
        skipButton.disposeBitmapOnDestroy = true;
        skipButton.activate();
        view.addChild(skipButton);

        nextButton = new BitmapButton();
        nextButton.setStandartButtonParams();
        nextButton.setDownScale(1);
        nextButton.setDownColor(0);
        nextButton.tapCallback = start;
        nextButton.disposeBitmapOnDestroy = true;
        nextButton.activate();
        view.addChild(nextButton);


        page1 = new Sprite();
        _view.addChild(page1);

        page2 = new Sprite();
        _view.addChild(page2);

        /*page3 = new Sprite();
        _view.addChild(page3);*/

        page1.mouseChildren = false;
        page1.mouseEnabled = false;

/*
        page2.mouseChildren = false;
        page2.mouseEnabled = false;

        page3.mouseChildren = false;
        page3.mouseEnabled = false;
*/
        //	page2.visible = false;
        //	page3.visible = false;


        title_1 = new Bitmap();
  //      title_2 = new Bitmap();
//        title_3 = new Bitmap();

        text_1 = new Bitmap();
  //      text_2 = new Bitmap();
//        text_3 = new Bitmap();

        delimiter_1 = new AppIntrotextDelimiter();
    //    delimiter_2 = new AppIntrotextDelimiter();
  //      delimiter_3 = new AppIntrotextDelimiter();

        UI.scaleToFit(delimiter_1, Config.FINGER_SIZE, Config.FINGER_SIZE);
  //      UI.scaleToFit(delimiter_2, Config.FINGER_SIZE, Config.FINGER_SIZE);
//        UI.scaleToFit(delimiter_3, Config.FINGER_SIZE, Config.FINGER_SIZE);
    }

    private function start():void{
        ChatManager.openChatByPID(133);
    }

    private function signOut():void{
        Auth.clearAuthorization();
    }

    }
}
