package com.dukascopy.connect.managers.escrow{

    import com.dukascopy.connect.GD;
    import com.dukascopy.connect.sys.Dispatcher;
    import com.dukascopy.connect.vo.EscrowDealVO;
    import com.telefision.utils.maps.EscrowDealMap;
    import com.telefision.utils.SimpleLoader;
    import com.telefision.utils.SimpleLoaderResponse;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    

    /**
     * DO NOT TOUCH, CHANGE, OR MODIFY!
     * © igor bloom
     */

    public class EscrowDealManager{

        private var escrowDeals:EscrowDealMap=new EscrowDealMap();
        private var id:String="EscrowDealManager";

        // Instruments
        private var instruments:Vector.<EscrowInstrument>=new Vector.<EscrowInstrument>();
        private var timeInstrumentRequest:Number=0;
        private var instrumentDataLifetime:Number=1000*60*5; // 5 min
        private var isInstrumentLoading:Boolean=false;

        // Prices
        private var isPriceLoading:Boolean=false;


        public function EscrowDealManager(){
            
            SimpleLoader.URL_DEFAULT="https://loki.telefision.com/master/";

            //loadDeals();

            // Check if escrow manager is created
            GD.S_ESCROW_MANAGER_AVAILABLE.add(function(cb:Function):void{
                cb();
            })

            // CREATE ESCROW DEAL
            GD.S_ESCROW_DEAL_CREATE_REQUEST.add(function(req:EscrowDealCreateRequest):void{
                var escrowRequest:Object=req.toObject();
                escrowRequest.key="e41ae903d332b69f490d604474c7ca633cd8835f";
                escrowRequest.method="Escrow.StartDeal"
                new SimpleLoader(
                    escrowRequest,
                    function(resp:SimpleLoaderResponse):void{
                       trace(resp);
                    }
                );
            },this);

            GD.S_ESCROW_DEALS_REQUEST.add(function():void{
                loadDeals();
            })

            // Escrow get instruments, 
            GD.S_ESCROW_INSTRUMENTS_REQUEST.add(function():void{
                if(instruments.length==0 || new Date().getTime()-timeInstrumentRequest>instrumentDataLifetime){
                    loadInstruments();
                    return;
                }
                GD.S_ESCROW_INSTRUMENTS.invoke(instruments);
            })

            GD.S_ESCROW_PRICES_REQUEST.add(function(inst:Vector.<EscrowInstrument>=null):void{
                if(isPriceLoading)
                    return;
                isPriceLoading=true;
                var tmp:Vector.<EscrowInstrument>=inst;
                if(tmp==null)
                    tmp=instruments;
                var arr:Array=[];
                for each(var i:EscrowInstrument in tmp)
                    arr.push(i.code);

                // TODO: SEND TO SERVER, GET RESPONSE, REBUILD INSTRUMENTS

                //FAKE
                var timer:Timer=new Timer(1000,1);
                var dis:Dispatcher=new Dispatcher(timer)
                dis.add(TimerEvent.TIMER_COMPLETE,function(e:TimerEvent):void{
                    dis.clear();
                    var fake:Object={};
                    for each(var code:String in arr)
                        fake[code]=Math.random()*10000;
                    parsePrices(fake)
                })
                
                timer.start();
            })

            // Escrow get offer calculation
        }



        private function loadInstruments():void{
            if(isInstrumentLoading)
                return;
            isInstrumentLoading=true;

            //TODO: get from sever DUMMY ->
            var timer:Timer=new Timer(1000,1);
            var dis:Dispatcher=new Dispatcher(timer);
            dis.add(TimerEvent.TIMER_COMPLETE,function(e:TimerEvent):void{
                dis.clear();
                parseInstruments([
                    {code:"DUK+",precision:2,name:"Dukascoin",wallet:"3849tjknvdknjs094kvjknwv",price:Math.random()*4},
                    {code:"ETH",precision:4,name:"Etherium",wallet:"dsv324fqww232AAAvewevwknjs094kvjknwv",price:Math.random()*100},
                    {code:"BTC",precision:"6",name:"Bitcoin",wallet:"AcAdewf43tgsfwfwewvvjknwv",price:Math.random()*50000},
                    {code:"USDT",precision:3,name:"Tether",wallet:null,price:Math.random()*1000},
                ]);
                isInstrumentLoading=false;
                timeInstrumentRequest=new Date().getTime();
            })
            timer.start();
            // DUMMY <-


        }

        /**
         * Parse response width avaialable instruments from server.
         * @param data - array of objects width name, wallet, price and code
         */
        private function parseInstruments(data:Array):void{
            var tmp:Vector.<EscrowInstrument>=new Vector.<EscrowInstrument>();
            for each(var i:Object in data){
                if("name" in i && "wallet" in i && "price" in i && "code" in i && "precision" in i){
                    var price:Number=0;
                    try{price=parseFloat(i.price);
                    }catch(e:Error){}
                    if(isNaN(price))
                        price=0;
                    var ei:EscrowInstrument=new EscrowInstrument(i.name,i.wallet,i.precision,i.code,price) 
                    tmp.push(ei);
                    if(price>0)
                        GD.S_ESCROW_PRICE.invoke(ei);
                }else{
                    trace("Error, wrong packet! no proper data in escrow instrument");
                }
            }
            if(tmp.length>0){
                instruments=tmp;
                GD.S_ESCROW_INSTRUMENTS.invoke(instruments);
            }
        };

        /**
         * Parse response with prices from server
         * @param data - key-value object where key is instrument code, value is price
         */
        private function parsePrices(data:Object):void{
            var instrumentsWasChanged:Boolean=false;
            for(var key:String in data){
                // get instrument by code
                var ei:EscrowInstrument=getInstrumentByCode(key);
                if(ei==null){
                    trace("Error, Instrument not found: "+key);
                    return;
                }
                if(ei.updatePrice(data[key])){
                    GD.S_ESCROW_PRICE.invoke(ei);
                    instrumentsWasChanged=true;
                }
            }
            if(instrumentsWasChanged)
                GD.S_ESCROW_INSTRUMENTS.invoke(instruments);
        }

        private function getInstrumentByCode(code:String):EscrowInstrument{
            for each(var i:EscrowInstrument in instruments){
                if(i.code==code)
                    return i;
            }
            return null;
        }

       

        /**
         * Load active deals
         */
        private function loadDeals():void{
            //TODO: Server method - load deals, fire callback
            new SimpleLoader({
                key:"e41ae903d332b69f490d604474c7ca633cd8835f",
                method:"Escrow.GetDeals"
            },function(resp:SimpleLoaderResponse):void{
                trace(resp);
            })
        }

        private function onDealsLoaded(data:Object):void{
            
            // DATA MUST BE ARRAY!
            if(data==null || !(data is Array))
                return;

            var l:int=(data as Array).length;

            for(var i:int=0;i<l;i++){
                var deal:Object=data[i];
                if(!('uid' in deal) || deal.uid==null)
                    continue;
                var dealVO:EscrowDealVO=escrowDeals.getDeal(deal.uid);
                if(dealVO==null)
                    dealVO=new EscrowDealVO(deal);
                dealVO.update(deal);
                escrowDeals.addDeal(deal.uid,dealVO);
            }

            GD.S_ESCROW_DEALS_LOADED.invoke(escrowDeals);
        }

    }

}