package com.dukascopy.connect.managers.escrow{

    import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.escrow.EscrowEventType;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
    import com.dukascopy.connect.sys.Dispatcher;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.ws.WSClient;
    import com.dukascopy.connect.vo.EscrowDealVO;
    import com.telefision.utils.maps.EscrowDealMap;
    import com.telefision.utils.SimpleLoader;
    import com.telefision.utils.SimpleLoaderResponse;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
    

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
		public static var instance:EscrowDealManager;
		
        public function EscrowDealManager(){
            
			Auth.S_NEED_AUTHORIZATION.add(clear);
			
            SimpleLoader.URL_DEFAULT="https://loki.telefision.com/escrow/";
			
            //loadDeals();
			
			WSClient.S_ESCROW_DEAL_EVENT.add(onDealEvent);
			
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
				
				
                GD.S_ESCROW_WALLETS_REQUEST.invoke(function(wallets:Object):void{
                    //!TODO:;
                })
				
					// TODO: SEND TO SERVER, GET RESPONSE, REBUILD INSTRUMENTS
                //FAKE
                var timer:Timer=new Timer(1000,1);
                var dis:Dispatcher=new Dispatcher(timer)
                dis.add(TimerEvent.TIMER_COMPLETE,function(e:TimerEvent):void{
                    dis.clear();
                    var fake:Object={};
                    for each(var code:String in arr)
                        fake[code]={eur:Math.random()*10000,usd:Math.random()*10000,chf:Math.random()*10000}
                    parsePrices(fake)
                })
                
                timer.start();
            })
			
            // Escrow get offer calculation
            // instrument, price, amount
			instance = this;
        }
		
		static private function onDealEvent(escrowEventType:String, dealRawData:Object):void 
		{
			if (escrowEventType == EscrowEventType.CREATED)
			{
				onDealCreated(dealRawData);
			}
			else if (escrowEventType == EscrowEventType.HOLD_MCA)
			{
				
			}
		}
		
		static private function onDealCreated(dealRawData:Object):void 
		{
			var deal:EscrowMessageData = new EscrowMessageData(dealRawData);
			GD.S_ESCROW_DEAL_CREATED.invoke(deal);
		}
		
		private function clear():void 
		{
			instruments = new Vector.<EscrowInstrument>();
			escrowDeals = new EscrowDealMap();
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
				
				if (PaymentsManager.activate() == false)
				{
					onWalletsLoaded();
				}
				else
				{
					PaymentsManager.S_ACCOUNT.add(onWalletsLoaded);
					PaymentsManager.S_BACK.add(onWalletsLoadError);
				}
				
                timeInstrumentRequest=new Date().getTime();
            })
            timer.start();
            // DUMMY <-
        }
		
		private function onWalletsLoadError(code:String = null, message:String = null):void 
		{
			isInstrumentLoading = false;
			
			PaymentsManager.S_ACCOUNT.remove(onWalletsLoaded);
			PaymentsManager.S_BACK.remove(onWalletsLoadError);
			
			GD.S_ESCROW_INSTRUMENTS.invoke(null);
			
			PaymentsManager.deactivate();
		}
		
		private function onWalletsLoaded(data:Array = null, local:Boolean = false):void 
		{
			PaymentsManager.S_ACCOUNT.remove(onWalletsLoaded);
			PaymentsManager.S_BACK.remove(onWalletsLoadError);
			
			var duk_price_eur:Number = Math.random() * 4;;
            var duk_price_usd:Number = duk_price_eur * 1.17;
			
            var eth_price_eur:Number = Math.random() * 100;
            var eth_price_usd:Number = eth_price_eur * 1.17;
			
            var btc_price_eur:Number = Math.random() * 50000;
            var btc_price_usd:Number = btc_price_eur * 1.17;
            
            var usdt_price_eur:Number = Math.random() * 3000;
            var usdt_price_usd:Number = usdt_price_eur * 1.17;
			
			var rawInstruments:Array = [
				{code:"DCO",precision:2,name:"Dukascoin",wallet:null,price:{EUR:duk_price_eur,USD:duk_price_usd}},
				{code:"ETH",precision:4,name:"Etherium",wallet:null,price:{EUR:eth_price_eur,USD:eth_price_usd}},
				{code:"BTC",precision:"6",name:"Bitcoin",wallet:null,price:{EUR:btc_price_eur,USD:btc_price_usd}},
				{code:"UST",precision:3,name:"Tether",wallet:null,price:{EUR:usdt_price_eur,USD:usdt_price_usd}},
			]
			for (var i:int = 0; i < rawInstruments.length; i++) 
			{
				rawInstruments[i].wallet = PayManager.getDCOWallet(rawInstruments[i].code)
			}
			parseInstruments(rawInstruments);
            isInstrumentLoading = false;
			PaymentsManager.deactivate();
		}
		
        /**
         * Parse response width avaialable instruments from server.
         * @param data - array of objects width name, wallet, price and code
         */
        private function parseInstruments(data:Array):void{
            var tmp:Vector.<EscrowInstrument>=new Vector.<EscrowInstrument>();
            for each(var i:Object in data){
                if("name" in i && "wallet" in i && "price" in i && "code" in i && "precision" in i){
                    var ei:EscrowInstrument=new EscrowInstrument(i.name,i.wallet,i.precision,i.code,i.price) 
                    tmp.push(ei);
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
            for(var key:String in data){
                // get instrument by code
                var ei:EscrowInstrument=getInstrumentByCode(key);
                if(ei==null){
                    trace("Error, Instrument not found: "+key);
                    return;
                }
                ei.updatePrice(data[key])
                GD.S_ESCROW_PRICE.invoke(ei);
            }

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
		
		public static function getPrice(instrument:String, currency:String):Number
		{
			var result:Number;
			if (instance != null && instance.instruments != null)
			{
				for (var i:int = 0; i < instance.instruments.length; i++) 
				{
					if (instance.instruments[i].code == instrument)
					{
						if (instance.instruments[i].price != null)
						{
							var price:Vector.<EscrowPrice> = instance.instruments[i].price;
							for (var j:int = 0; j < price.length; j++) 
							{
								if (price[j].name == currency)
								{
									result = price[j].value;
									break;
								}
							}
						}
						break;
					}
				}
			}
			return result;
		}
    }
}