package com.dukascopy.connect.gui.chatInput 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public interface IInputPanel 
	{
		function drawSmileButton():void;
		function drawStickerButton():void;
		function removeFocus(e:Event = null):Boolean;
		function onKeyboardRemoved(stickerMenu:int):void;
		function updateView(stickerMenu:int):int;
		function onSmileSelected(smile:Array = null):void;
		function setTFWidth(w:int):void;
		function calcHeight():int;
		function getHeight():Number;
		function activate():void;
		function setWidth(w:int):void;
		function setValue(text:String):void;
		function getText():String;
		function deactivate():void;
		function dispose():void;
		function isFocused():Boolean;
		function clearInput():void;
		function setKeyboardHaight(keyboardHeight:int):void;
		
		function onSoftKeyboardActivatingCallback(callback:Function):void;
		function onSoftKeyboardActivateCallback(callback:Function):void;
		function onSoftKeyboardDeactivateCallback(callback:Function):void;
		function onSentVoicePressedCallback(callback:Function):void;
		function onSmileStickerPressedCallback(callback:Function):void;
		function onAttachPressedCallback(callback:Function):void;
		function updateButtonsOnAttachPressed(stickerMenu:int):void;
		function updateButtonsOnSmileStickerPressed(stickerMenu:int):void;
		function onRemoveFocusCallback(callback:Function):void;
		function onSentPressedCallback(callback:Function):void;
		function onInputChangedCallback(callback:Function):void;
		function show(defaultText:String):void;
		function setY(value:int):void;
		function onPositionChangedCallback(callback:Function):void;
		function getKeyboardHeight():int;
		function hide():void;
		function showBackground():void;
		function hideBackground():void;
		function getStartHeight():int;
		
		function hideStickersButton():void;
		function hideAttachButton():void;
		function disableVoiceRecord():void;
		function setLeftPadding(valu:int):void;
		
		function showAccountButton():void;
		
		function movoToBottom():void;
	}
}