package  com.telefision.utils{
	import com.telefision.sys.signals.Signal;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class Loop {

		static private var isListening:Boolean;
		static private var S_ON_FRAME:Signal = new Signal("Loop.S_ON_FRAME");
		static private var frames:int = 0;
		static private var stage:Stage;
		public static function init(stage:Stage):void {
			Loop.stage = stage;
		}
		
		public static function add(method:Function, source:String = 'unknown'):void {
			if (stage == null) {
				trace("Loop error -> no stage!");
				return;
			}
			S_ON_FRAME.add(method,source);
			if (!isListening){
				stage.addEventListener(Event.ENTER_FRAME, onFrame);
				isListening = true;
			}
		}
		
		public static function remove(method:Function):void {
			S_ON_FRAME.remove(method);
			if (S_ON_FRAME.callBacksCount == 0) {
				removeListener();
			}
		}
		
		static public function showNames():void {
			trace('LOOP - showNames - not implemented');
		}
		
		static private function removeListener():void{
			stage.removeEventListener(Event.ENTER_FRAME, onFrame);
			isListening = false;
		}
		
		static private function onFrame(e:Event):void {
			e.stopImmediatePropagation();
			e.stopPropagation();
			if (S_ON_FRAME.callBacksCount == 0) {
				removeListener();
				return;
			}
			S_ON_FRAME.invoke(/*frames*/);
			frames++;
			if (frames > 1024)
				frames = 0;
		}
		
		static public function get count():int {
			return S_ON_FRAME.callBacksCount;
		}
		
	}
}