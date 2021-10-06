package com.dukascopy.connect.managers.escrow{

    import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.escrow.EscrowEventType;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.managers.escrow.vo.InstrumentParser;
    import com.dukascopy.connect.sys.Dispatcher;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
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

        private var authKey:String="web";
		
        public function EscrowDealManager(){

            SimpleLoader.URL_DEFAULT="https://loki.telefision.com/master/";
			
            //loadDeals();
			
			WSClient.S_ESCROW_DEAL_EVENT.add(onDealEvent);
			WSClient.S_ESCROW_OFFER_EVENT.add(onOfferEvent);

            GD.S_AUTHORIZED.add(function(data:Object):void{
                authKey=data.authKey;
            })

            // Check if escrow manager is created
            GD.S_ESCROW_MANAGER_AVAILABLE.add(function(cb:Function):void{
                cb();
            })
			
            // CREATE ESCROW DEAL
            GD.S_ESCROW_DEAL_CREATE_REQUEST.add(function(req:EscrowDealCreateRequest):void{
                var escrowRequest:Object=req.toObject();
                escrowRequest.key=authKey//"e41ae903d332b69f490d604474c7ca633cd8835f";
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
		
		static private function onOfferEvent(escrowEventType:String, offerRawData:Object):void 
		{
			if (escrowEventType == EscrowEventType.CANCEL)
			{
				onOfferCanceled(offerRawData);
			}
			else if (escrowEventType == EscrowEventType.OFFER_CREATED)
			{
				onOfferCreated(offerRawData);
			}
		}
		
		static private function onOfferCreated(offerRawData:Object):void 
		{
			var offer:EscrowMessageData = new EscrowMessageData(offerRawData);
		}
		
		static private function onOfferCanceled(offerRawData:Object):void 
		{
			var offer:EscrowMessageData = new EscrowMessageData(offerRawData);
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
			
			PHP.p2p_getRates(onInstrumentsLoaded);
			
            //TODO: get from sever DUMMY ->
           /* var timer:Timer=new Timer(1000,1);
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
            timer.start();*/
            // DUMMY <-
        }
		
		private function onInstrumentsLoaded(respond:PHPRespond):void 
		{
			if (respond.error == true)
			{
				isInstrumentLoading = false;
				//!TODO:;
			}
			else
			{
				parseInstruments(respond.data);
				loadWallets();
			}
			
			respond.dispose();
		}
		
		private function loadWallets():void 
		{
			if (PaymentsManager.activate() == false)
			{
				onWalletsLoaded();
			}
			else
			{
				PaymentsManager.S_ACCOUNT.add(onWalletsLoaded);
				PaymentsManager.S_BACK.add(onWalletsLoadError);
			}
		}
		
		private function onWalletsLoadError(code:String = null, message:String = null):void 
		{
			isInstrumentLoading = false;
			
			PaymentsManager.S_ACCOUNT.remove(onWalletsLoaded);
			PaymentsManager.S_BACK.remove(onWalletsLoadError);
			
			isInstrumentLoading = false;
			GD.S_ESCROW_INSTRUMENTS.invoke(null);
			
			PaymentsManager.deactivate();
		}
		
		private function onWalletsLoaded(data:Array = null, local:Boolean = false):void 
		{
			PaymentsManager.S_ACCOUNT.remove(onWalletsLoaded);
			PaymentsManager.S_BACK.remove(onWalletsLoadError);
			
			for (var i:int = 0; i < instruments.length; i++) 
			{
				instruments[i].wallet = PayManager.getDCOWallet(instruments[i].code)
			}
			
            isInstrumentLoading = false;
			PaymentsManager.deactivate();
			
			GD.S_ESCROW_INSTRUMENTS.invoke(instruments);
		}
		
        /**
         * Parse response width avaialable instruments from server.
         * @param data - array of objects width name, wallet, price and code
         */
        private function parseInstruments(instrumentsRaw:Object):void{
            var tmp:Vector.<EscrowInstrument> = new Vector.<EscrowInstrument>();
			var instrument:EscrowInstrument;
			var parser:InstrumentParser = new InstrumentParser();
            for each(var instrumentRawData:Object in instrumentsRaw){
				instrument = parser.parse(instrumentRawData);
				if (instrument != null)
				{
					tmp.push(instrument);
					GD.S_ESCROW_PRICE.invoke(instrument);
				}
				else
				{
					ApplicationErrors.add();
				}
            }
            if(tmp.length>0){
                instruments=tmp;
            //    GD.S_ESCROW_INSTRUMENTS.invoke(instruments);
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
                key:authKey,//"e41ae903d332b69f490d604474c7ca633cd8835f",
                method:"Cp2p.getDeals"
            },function(resp:SimpleLoaderResponse):void{
                if(resp.error){
                    GD.S_ESCROW_DEALS_LOADED_ERROR.invoke(resp.error);
                    return;
                }
                onDealsLoaded(resp.data);
            })
        }
		
        private function onDealsLoaded(data:Object):void{
            
            // DATA MUST BE ARRAY!
            if(data==null || !(data is Array)){
                if(!(data is Array))
                    GD.S_ESCROW_DEALS_LOADED_ERROR.invoke("Wrong data format");
                return;
            }
			
            var l:int=(data as Array).length;
			
            for(var i:int=0;i<l;i++){
                var deal:Object=data[i];
                if(!('deal_uid' in deal) || deal.deal_uid == null)
                    continue;
                var dealVO:EscrowDealVO=escrowDeals.getDeal(deal.uid);
                if(dealVO==null)
                    dealVO=new EscrowDealVO(deal);
                dealVO.update(deal);
                escrowDeals.addDeal(deal.deal_uid, dealVO);
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