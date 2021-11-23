package com.dukascopy.connect.managers.escrow{

    import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.ErrorData;
	import com.dukascopy.connect.data.escrow.EscrowEventType;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.managers.escrow.vo.InstrumentParser;
    import com.dukascopy.connect.sys.Dispatcher;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.ws.WSMethodType;

    import com.dukascopy.connect.vo.EscrowDealVO;
    import com.telefision.utils.maps.EscrowDealMap;
    import com.telefision.utils.SimpleLoader;
    import com.telefision.utils.SimpleLoaderResponse;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
    import com.dukascopy.connect.vo.URLConfigVO;
    import com.dukascopy.connect.managers.escrow.vo.EscrowDealEventSentRequestVO;
    import com.dukascopy.connect.vo.WSPacketVO;
    

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
        private var instrumentDataLifetime:Number=1000*60*1; // 5 min
        private var isInstrumentLoading:Boolean=false;

        // Deals 
        
		
        // Prices
        private var isPriceLoading:Boolean=false;
		public static var instance:EscrowDealManager;

        private var authKey:String="web";
		
        public function EscrowDealManager(){

            GD.S_URL_CONFIG_READY.add(function(cfg:URLConfigVO):void{
                SimpleLoader.URL_DEFAULT=cfg.DCCAPI_URL;//"https://loki.telefision.com/master/";    
            })

             GD.S_AUTHORIZED.add(function(data:Object):void{
                authKey=data.authKey;
                loadDeals();
            })

		           
            // Handle WS packet for deals
            GD.S_WS_PACKET_RECEIVED.add(function(packet:WSPacketVO):void{
                if (packet.method != WSMethodType.ESCROW_EVENT)
                    return;
			
				if (packet.action == "cp2p_deal_created" && packet.data != null && packet.data.event != null && packet.data.event.type == EscrowEventType.CREATED.value){
                    createDeal(packet.data.deal);
                    //S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.CREATED, pack.data.deal);
                    return;
				}
				
				if (packet.action == "cp2p_crypto_accepted" && packet.data != null && packet.data.event != null && packet.data.event.type == EscrowEventType.CRYPTO_ACCEPTED.value){
                    updateDeal(packet.data.deal);
                    //S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.CREATED, pack.data.deal);
                    return;
				}

				if (packet.action == "cp2p_deal_created" && packet.data != null && packet.data.event != null && packet.data.event.type == EscrowEventType.HOLD_MCA.value){
                    holdMCA(packet.data);
					//S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.HOLD_MCA, pack.data.deal);
                    return;
				}
				
				if (packet.action == "cp2p_paid_crypto" && packet.data != null && packet.data.event != null && packet.data.event.type == EscrowEventType.PAID_CRYPTO.value){
                    updateDeal(packet.data.deal);
					//S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.HOLD_MCA, pack.data.deal);
                    return;
				}
				
				if (packet.action == "cp2p_deal_expired" && packet.data != null && packet.data.event != null && packet.data.event.type == EscrowEventType.DEAL_EXPIRED.value){
                    updateDeal(packet.data.deal);
					//S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.HOLD_MCA, pack.data.deal);
                    return;
				}
				
				if (packet.action == "cp2p_deal_failed" && packet.data != null && packet.data.event != null && packet.data.event.type == EscrowEventType.DEAL_FAILED.value){
                    updateDeal(packet.data.deal);
					//S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.HOLD_MCA, pack.data.deal);
                    return;
				}
				
            })

            // Check if escrow manager is created
            GD.S_ESCROW_MANAGER_AVAILABLE.add(function(cb:Function):void{
                cb();
            })

            // Send escrow deal event to dccapi
            GD.S_ESCROW_REQUEST_DEAL_EVENT_SENT.add(function(req:EscrowDealEventSentRequestVO):void{

                new SimpleLoader({
                    method:"Cp2p.Deal.AddEvent",
                    key:authKey,
                    event_type:req.type.value,
                    deal_uid:req.dealUID,
                    data:req.data,
                    notifyWS:req.notifyWS    
                },function(resp:SimpleLoaderResponse):void{
                    trace(resp);
                    //TODO: Check response
                    if(resp.error){
                        GD.S_ESCROW_REQUEST_DEAL_EVENT_SENT_FAIL.invoke(resp.error);
						var errorText:String = ErrorLocalizer.getText(resp.error);
						GD.S_TOAST.invoke(errorText);
                        return;
                    }
                    
                    
                    if(resp.data==null || !("deal_uid" in resp.data)){
                        //TODO: WRONG ANSWER FROM PHP;
                        var deal:EscrowDealVO=escrowDeals.getDeal(resp.data.deal_uid);
                        if(deal==null){
                            deal=new EscrowDealVO(resp.data);
                            escrowDeals.addDeal(resp.data.deal_uid,deal);
                            fireDeals();
                        }else {
                            deal.update(resp.data);
							onDealUpdate();
						}
                    }

                    //{"data":{"deal_uid":"6346558610124544830","side":"SELL","status":"completed","instrument":"DCO","amount":"1.0000000000","mca_ccy":"EUR","price":"2.2800000000","rate":"0.438596","debit_account":"380867781292","crypto_wallet":"0x8deaA0eE98f8482C2D3B93ec57DE678a65759ef9","crypto_user_uid":"I6D5WsWZDLWj","mca_user_uid":"WLDNWrWbWoIxIbWI","chat_uid":"WLDIDRWmDNW5WPWe","msg_id":35653518,"crypto_trn_id":null,"mca_trn_id":"t1R9WOTI","crypto_claim_id":null,"mca_claim_id":null,"percent_price":0,"created_at":1634655861,"updated_at":1634659026,"events":[{"uid":"6346558610168205037","deal_uid":"6346558610124544830","created_at":"2021-10-19 15:04:21","type":"deal_created","data":null,"state":"active","created_by":"WLDNWrWbWoIxIbWI"},{"uid":"6346558832800725474","deal_uid":"6346558610124544830","created_at":"2021-10-19 15:04:43","type":"hold_mca","data":"{\"mca_trn_id\":\"t1R9WOTI\",\"price\":\"2.28\"}","state":"active","created_by":"WLDNWrWbWoIxIbWI"},{"uid":"6346559484383820583","deal_uid":"6346558610124544830","created_at":"2021-10-19 15:05:48","type":"paid_crypto","data":null,"state":"active","created_by":"I6D5WsWZDLWj"},{"uid":"6346590264360429302","deal_uid":"6346558610124544830","created_at":"2021-10-19 15:57:06","type":"crypto_accepted","data":null,"state":"active","created_by":"WLDNWrWbWoIxIbWI"}],"claims":[],"hash":null},"status":{"error":false,"errorMsg":"","respondTime":"8.70"}}

                })
            })
			
            // CREATE ESCROW DEAL
            /*GD.S_ESCROW_DEAL_CREATE_REQUEST.add(function(req:EscrowDealCreateRequest):void{
                var escrowRequest:Object=req.toObject();
                escrowRequest.key=authKey//"e41ae903d332b69f490d604474c7ca633cd8835f";
                escrowRequest.method="Escrow.StartDeal"
                new SimpleLoader(
                    escrowRequest,
                    function(resp:SimpleLoaderResponse):void{
                       trace(resp);
                    }
                );
            },this);*/


            // SEND DEAL EVENT
			
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
		
		private function updateDeal(raw:Object):void 
		{
			if(raw != null && 'deal_uid' in raw && raw.deal_uid != null)
			{
				var deal:EscrowDealVO = escrowDeals.getDeal(raw.deal_uid);
				if(deal != null){
					deal.update(raw);
					onDealUpdate();
				}
				else
				{
					//!TOODO:;
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onDealUpdate():void 
		{
			GD.S_ESCROW_DEALS_UPDATE.invoke(escrowDeals);
		}
		
        /**
         * Got command frow WS, create deal
         * @param data - object from ws
         */
        private function createDeal(raw:Object):void{
			if(raw != null && 'deal_uid' in raw && raw.deal_uid != null)
            {
				var dealVO:EscrowDealVO = escrowDeals.getDeal(raw.deal_uid);
				if (dealVO == null)
				{
					dealVO = new EscrowDealVO(raw);
					escrowDeals.addDeal(raw.deal_uid, dealVO);
					onDealUpdate();
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else
			{
				ApplicationErrors.add();
			}
        }
		
        /**
         * Got command frow WS, change deal status to MCA
         * @param data - object from ws
         */
        private function holdMCA(data:Object):void{
            // GOT PACKET FROW WS
        }


        private function fireDeals():void{
            GD.S_ESCROW_DEALS_LOADED.invoke(escrowDeals);
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

            var loader:SimpleLoader=new SimpleLoader({
                method:"Cp2p.Deal.GetRates",
                key:authKey
            },function(resp:SimpleLoaderResponse):void{
                // Instruments loaded
                isInstrumentLoading = false;
                if (resp.error == true)
                    return;
                parseInstruments(resp.data);
                //loadWallets();
            })
        }
		
		
		
		private function loadWallets():void{
            GD.S_PAY_REQUEST_WALLETS.invoke();
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
				if (instrument != null){
					tmp.push(instrument);
					GD.S_ESCROW_PRICE.invoke(instrument);
				}else{
					ApplicationErrors.add();
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
                key:authKey,//"e41ae903d332b69f490d604474c7ca633cd8835f",
                method:"Cp2p.Deal.GetDeals"
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
                var dealVO:EscrowDealVO=escrowDeals.getDeal(deal.deal_uid);
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