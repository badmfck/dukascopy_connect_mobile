package com.dukascopy.connect.sys.callManager {
	import com.dukascopy.connect.sys.echo.echo;
	import com.telefision.utils.Loop;
	import flash.media.AudioPlaybackMode;
	import flash.media.Microphone;
	import flash.media.SoundMixer;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class EchoSuspension {
		
		static private var farSpeaker:int = 0;
		// NOISE CALCULATOR
		static public var noiseMin:int = 0;
		static public var noiseMax:int = 0;
		static public var averageNoiseLevel:int = 0;
		static public var noiseCounter:int = 30;
		static public var noiseCounterMax:int = 30;
		// ECHO REDUCTION
		static private var oldMicLevel:int = 0;
		static public var silenceDelay:int = 0; // counter
		static public var silenceDelayMax:int = 60; // 60 == 1 sec
		static public var silenceLastTimer:int = 60; // 60 == 1 sec
		static public var speechLevel:int = 2; // уровень звука, который я должен превысить 
		static public var silenceLevel:int = 0;
		
		/*static private var ilyaCounterMax:int = 181;
		static private var ilyaArray:Array;
		static private var ilya0:Number;
		static private var ilya1:Number;
		static private var ilya2:Number;*/
		
		static private var fakeNS:NetStream;
		
		public function EchoSuspension() { }
		
		static public function start():void {
			setClient();
			if (CallManager.getCallVO().videoRecognition == true)
				return;
			if (CallManager.getCallVO().farEncMic && CallManager.getCallVO().nearEncMic)
				return;
			else if (!(CallManager.getCallVO().farEncMic && CallManager.getCallVO().nearEncMic))
				Loop.add(onTalkLoop);
			else if (CallManager.getCallVO().nearEncMic)
				Loop.add(sendMyMicLevel);
			else
				Loop.add(onTalkLoop);
			fakeNS = new NetStream(CallManager.getNC());
		}
		
		static private function setClient():void {
			if (CallManager.getIncomeStream()) {
				CallManager.getIncomeStream().client = {
					ml:function(lvl:int):void {
						farSpeaker = lvl;
					},
					// пришел стоп от клиента
					stop:function(val:Boolean):void {
						if (CallManager.getCallVO() != null)
							CallManager.getCallVO().phase = 0;
					}
				};
			}
		}
		
		static public function stop():void {
			Loop.remove(onTalkLoop);
			/*if (ilyaArray != null)
				ilyaArray.length = 0;
			ilyaArray = null;*/
			if (fakeNS != null) {
				try {
					fakeNS.attachAudio(null);
					fakeNS.dispose();
				} catch(e:Error) {
					echo("CallManager", "closeMediaNetwork 1",e.message ,true);
				}
			}
			fakeNS = null;
		}
		
		static public function onTalkLoop():void{
			if (farSpeaker == -1) {
				if (CallManager.getOutgoungStream() == null)
					return;
				if (SoundMixer.audioPlaybackMode != AudioPlaybackMode.MEDIA)
					SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
				if (CallManager.isMicrophoneMuted() == true)
					microphoneActivity(true);
				return;
			}
			if (CallManager.getCallVO().loudspeaker == true){
				// определяем noise
				if (noiseCounter < noiseCounterMax){
					if (CallManager.getMicrophone().activityLevel < noiseMin)
						noiseMin = CallManager.getMicrophone().activityLevel;
					if (CallManager.getMicrophone().activityLevel > noiseMax)
						noiseMax = CallManager.getMicrophone().activityLevel;
					noiseCounter++;
				}else{
					// calc mid level
					averageNoiseLevel = noiseMin;// (noiseMax + noiseMin) / 2;
					noiseCounter = 0;
					noiseMin = 999;
					noiseMax = 0;
				}
				// Тот кто звонит - у него включен динамик, выключен микрофон
				if (CallManager.getCallVO().phase == 0){
					microphoneActivity(false);
					SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
					CallManager.getCallVO().phase = 2;
					CallManager.S_CALLVO_CHANGED.invoke();
				}
				// Тот кому звонят - у него микрофон влкючен, динамик выключен
				if (CallManager.getCallVO().phase == -1){
					microphoneActivity(true);
					SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
					CallManager.getCallVO().phase = 5;
					CallManager.S_CALLVO_CHANGED.invoke();
				}
				// начало программы
				if(CallManager.getCallVO().phase==1){
					if (farSpeaker > speechLevel){
						microphoneActivity(false);
						SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
						silenceDelay = 0;
						CallManager.getCallVO().phase = 2;
						CallManager.S_CALLVO_CHANGED.invoke();
					}
				}
				// Таймер ожидания - уже не нужен
				if (CallManager.getCallVO().phase == 2) {
					/*ilyaArray.push(CallManager.getMicrophone().activityLevel);
					if (ilyaArray.length == 31)
						ilyaArray.shift();
					ilya1 = 0;
					for (var j:int = 0; j < ilyaArray.length; j++)
						ilya1 += ilyaArray[i];
					ilya1 = ilya1 / ilyaArray.length;
					if (ilya0 < ilya1) {
						microphoneActivity(true);
						SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
						CallManager.getCallVO().phase = 5;
						CallManager.S_CALLVO_CHANGED.invoke();
					}*/
					silenceDelay++;
					if (silenceDelay > 0) {
						CallManager.getCallVO().phase = 3;
						silenceDelay = 0;
						CallManager.S_CALLVO_CHANGED.invoke();
					}
				}
				// слушаем динамик
				if (CallManager.getCallVO().phase == 3){
					silenceDelay++;
					// всплекс на динамике
					if (farSpeaker > speechLevel){
						CallManager.getCallVO().phase = 2
						silenceDelay = 0;
						CallManager.S_CALLVO_CHANGED.invoke();
					}
					// секунда прошла, всплеска не было
					if (silenceDelay > silenceLastTimer){
						silenceDelay = 0;
						CallManager.getCallVO().phase = 4;
						CallManager.S_CALLVO_CHANGED.invoke();
					}
				}
				// На динамике была тишина
				if (CallManager.getCallVO().phase == 4){
					microphoneActivity(true);
					SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
					silenceDelay=0
					CallManager.getCallVO().phase = 5;
					CallManager.S_CALLVO_CHANGED.invoke();
				}
				// Тупо ждём N времени чтоб дать человеку возможность сказать
				if (CallManager.getCallVO().phase == 5) {
					/*ilyaArray.push(CallManager.getMicrophone().activityLevel);
					if (ilyaArray.length == ilyaCounterMax)
						ilyaArray.shift();
					ilya0 = 0;
					ilya1 = 0;
					var i:int = ilyaArray.length;
					var c:int = 0;
					while (i > 0) {
						i--;
						ilya0 += ilyaArray[i];
						if (c != 30) {
							c++;
							ilya1 += ilyaArray[i];
						}
					}
					ilya0 = ilya0 / ilyaArray.length;
					ilya1 = ilya1 / c;
					ilya2 = 0;
					var i:int = ilyaArray.length;
					while (i > 0) {
						i--;
						ilya2 += ((ilyaArray[i] - ilya0) * (ilyaArray[i] - ilya0));
					}
					ilya2 = Math.sqrt(1 / 180 * ilya2);*/
					silenceDelay++;
					if (silenceDelay > silenceDelayMax){
						CallManager.getCallVO().phase = 1;
						silenceDelay = 0;
						CallManager.S_CALLVO_CHANGED.invoke();
					}
				}
			}
			sendMyMicLevel();
		}
		
		static private function sendMyMicLevel():void {
			// Передаю свой уровень микрофона, если я говорю
			if (CallManager.getOutgoungStream() != null && CallManager.getMicrophone() && CallManager.isMicrophoneMuted()==false){
				if (oldMicLevel != CallManager.getMicrophone().activityLevel){
					CallManager.getOutgoungStream().send("ml", CallManager.getMicrophone().activityLevel);
					oldMicLevel =CallManager.getMicrophone().activityLevel;
				}
			}
		}
		
		static private function microphoneActivity(activate:Boolean):void{
			if (activate == false) {
				if (fakeNS != null) {
					if (CallManager.getOutgoungStream() != null) {
						/*if (ilyaArray != null)
							ilyaArray.length = 0;
						ilyaArray = null;*/
						CallManager.getOutgoungStream().attachAudio(null);
					}
					fakeNS.attachAudio(CallManager.getMicrophone());
					CallManager.setMicrophoneMuted(true);
					CallManager.getOutgoungStream().send("ml", 0);
				}
				//microphone.gain = 0;
				return;
			}
			
			if (activate==true){
				if (CallManager.getOutgoungStream() != null) {
					CallManager.getOutgoungStream().attachAudio(CallManager.getMicrophone());
					CallManager.setMicrophoneMuted(false);
				}
				//microphone.gain = 50;
				return;
			}
		}
	}
}