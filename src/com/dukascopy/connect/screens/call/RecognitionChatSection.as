package com.dukascopy.connect.screens.call 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.screens.chat.video.ChatMessagePanel;
	import com.greensock.TweenMax;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RecognitionChatSection extends VideoRecognitionScreenSmall
	{
		private var startPosition:int;
		public var hided:Boolean;
		
		public function RecognitionChatSection() 
		{
			
		}
		
		public function hangup():void
		{
			onBtnHangup();
		}
		
		public function setPosition(position:int):void 
		{
			startPosition = position;
			view.y = startPosition;
		}
		
		public function activate():void 
		{
			
		}
		
		public function setProgressIndicator(indicator:IProgressIndicator):void 
		{
			stateProgress = indicator;
		}
		
		public function show(duration:Number):void 
		{
			view.y = startPosition - Config.FINGER_SIZE;
			view.alpha = 0;
			TweenMax.to(view, duration, {alpha:1, y:startPosition});
			view.visible = true;
		}
		
		private function makeInvisible():void 
		{
			view.visible = false;
		}
		
		public function hide():void 
		{
			TweenMax.to(view, 0.3, {alpha:0, y:startPosition - Config.FINGER_SIZE, onComplete:makeInvisible});
			hided = true;
		}
		
		public function onShown():void 
		{
			hided = false;
		}
	}
}