package com.dukascopy.connect.managers.escrow.test
{
    import com.dukascopy.connect.GD;
    import flash.utils.Timer;
    import com.dukascopy.connect.sys.Dispatcher;
    import flash.events.TimerEvent;
    import com.dukascopy.connect.managers.escrow.EscrowInstrument;

    public class EscrowTest{
        
        public function EscrowTest(){
            var managers:int=0;
            //1. check for escrow manager availability
            GD.S_ESCROW_MANAGER_AVAILABLE.invoke(function():void{
                managers++;
            });
            var timer:Timer=new Timer(100,1);
            var disp:Dispatcher=new Dispatcher(timer);
            disp.add(TimerEvent.TIMER_COMPLETE,function(e:TimerEvent):void{
                disp.clear();
                if(managers==0){
                    trace("TEST.available - FAIL, NO EscrowManager instance found");
                    return;
                }
                if(managers!=1){
                    trace("TEST.available - FAIL, More than 1 EscrowManager instance found");
                    return;
                }
                trace("TEST.available - SUCCESS Escrow Manager avaiable");
                testInstruments();
            })
            timer.start();
        }

       private function testInstruments():void{
            trace("TEST.instruments - START")
            GD.S_ESCROW_INSTRUMENTS.add(function(instruments:Vector.<EscrowInstrument>):void{
                if(instruments==null){
                    trace("TEST.Instruments - FAIL, no instruments!")
                    return;
                }
                if(instruments.length==0){
                    trace("TEST.instruments - Instruments list is empty");
                    return;
                }
                for each(var i:EscrowInstrument in instruments){
                    trace("TEST.instrument: \t"+i);
                }
                trace("TEST.Instruments - COMPLETE")
                GD.S_ESCROW_INSTRUMENTS.clearID("escrowTests")
                testPrices(instruments);
            },this,"escrowTests");
            GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
        }

        private function testPrices(instruments:Vector.<EscrowInstrument>):void{
            trace("TEST.prices - START")
            var arr:Vector.<EscrowInstrument>=new Vector.<EscrowInstrument>();
            arr.push(instruments[0]);
            if(instruments.length>1)
                arr.push(instruments[1]);
            var changed:int=0;
            GD.S_ESCROW_PRICE.add(function(instrument:EscrowInstrument):void{
                trace('TEST.prices - changes: '+instrument)
                changed++;
                if(changed==arr.length){
                    trace('TEST.prices - COMPLETE')
                    GD.S_ESCROW_PRICE.clearID("escrowTests")
                }
            },this,"escrowTests")
            GD.S_ESCROW_PRICES_REQUEST.invoke(arr)
        }

    }
}