package com.dukascopy.connect.managers.escrow
{
    import com.dukascopy.connect.GD;
    import com.telefision.utils.SimpleLoader;
    import com.telefision.utils.SimpleLoaderResponse;
    import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
    import com.dukascopy.connect.managers.escrow.vo.EscrowOffersRequestVO;
    import com.dukascopy.connect.vo.URLConfigVO;
    import com.dukascopy.connect.data.escrow.EscrowEventType;
    import com.dukascopy.connect.vo.WSPacketVO;
    import com.dukascopy.connect.sys.ws.WSMethodType;
    import com.dukascopy.connect.data.ErrorData;

    public class EscrowOfferManager{

        private var offers:Vector.<EscrowOfferVO>;
        private var loading:Boolean=false;
        private var needReload:Boolean=true;
        private var lastLoadTime:Number=0;
        private var authKey:String="web";

        public function EscrowOfferManager(){

            GD.S_URL_CONFIG_READY.add(function(cfg:URLConfigVO):void{
                SimpleLoader.URL_DEFAULT=cfg.DCCAPI_URL;//"https://loki.telefision.com/master/";    
            })

            GD.S_AUTHORIZED.add(function(data:Object):void{
                authKey=data.authKey
            })


            // DO CLIENT
            GD.S_WS_PACKET_RECEIVED.add(function(packet:WSPacketVO):void{
                parseWSPacket(packet);
            })

            //GD.S_ESCROW_OFFER_CREATE_REQUEST.add(onEscrowOfferCreateRequest,this);

            /**
             * req
             * callback:Function(offers)
             * force:boolean // do reload
             */
            GD.S_ESCROW_OFFERS_REQUEST.add(function(req:EscrowOffersRequestVO=null):void{
                
                if(loading)
                    return;

                // 1 min
                if(lastLoadTime-new Date().getTime()>1000*60*1){
                    trace("Data too old")
                    needReload=true;
                }

                if(req!=null && req.force)
                    needReload=true;

                if(needReload){
                    trace("Do reload")
                    loadOffers()
                    return;
                }


                if(req!=null && req.callback && req.callback is Function && req.callback.length==1)
                    req.callback(offers);

                GD.S_ESCROW_OFFERS_READY.invoke(offers);
            })
        }   


        private function parseWSPacket(packet:WSPacketVO):void{
            
            if (packet.method == WSMethodType.ESCROW_OFFER_ACCEPT){
                onOfferAcceptSuccessEvent(packet.data!=null?packet.data.offer:null);
				return;
			}

			if (packet.method == WSMethodType.ESCROW_OFFER_CREATE_SUCCESS){
				// !TODO: нет такого сигнала?;
				return;
			}

			if (packet.method == WSMethodType.ESCROW_OFFER_CREATE){
				GD.S_OFFER_CREATED.invoke(packet.data.offer);
				return;
			}

			if (packet.method == WSMethodType.ESCROW_OFFER_ACCEPT_ERROR){
				trace("123");
                return;
			}

			if (packet.method == WSMethodType.ESCROW_OFFER_ERROR){

				var errorObject:Object;
                if (packet.data!=null){

                    if("error" in packet.data && packet.data.error != null){
					    errorObject = packet.data.error;
				    }
                
				    if ("method" in packet.data && packet.data.method != null){
					
                        var offerId:String;
                        if ("offer" in packet.data && packet.data.offer != null && "offer_id" in packet.data.offer){
                            offerId = packet.data.offer.offerId;
                        }

                        var errorData:ErrorData=new ErrorData(errorObject, offerId)
                        if (packet.data.method == WSMethodType.ESCROW_OFFER_ACCEPT){
                            onOfferAcceptFailEvent(errorData);
                            GD.S_OFFER_ACCEPT_FAIL.invoke(errorData);
                        }else if (packet.data.method == WSMethodType.ESCROW_OFFER_CREATE){
                            onOfferAcceptFailEvent(errorData)
                            GD.S_OFFER_CREATE_FAIL.invoke(errorData);
                        }
				    }
                }
				return;
			}

			if (packet.method == WSMethodType.ESCROW_OFFER_CANCEL){
				return;
			}
            
        }


        static private function onOfferAcceptSuccessEvent(offerData:Object):void{
			GD.S_STOP_LOAD.invoke();
		}
		
		static private function onOfferCreatedEvent(offerData:Object):void{
			GD.S_STOP_LOAD.invoke();
		}

        static private function onOfferAcceptFailEvent(error:*):void{
			GD.S_STOP_LOAD.invoke();
            GD.S_TOAST.invoke(error);
		}
		
		private function onOfferEvent(escrowEventType:String, offerRawData:Object):void{
			if (escrowEventType == EscrowEventType.CANCEL.value){
				onOfferCanceled(offerRawData);
			}else if (escrowEventType == EscrowEventType.OFFER_CREATED.value){
				onOfferCreated(offerRawData);
			}
		}
		
		private function onOfferCreated(offerRawData:Object):void{
			//var offer:EscrowMessageData = new EscrowMessageData(offerRawData);
		}
		
		private function onOfferCanceled(offerRawData:Object):void{
			//var offer:EscrowMessageData = new EscrowMessageData(offerRawData);
		}


        private function loadOffers(status:String=null,side:String=null):void{
            loading=true;
            needReload=false;
            //e41ae903d332b69f490d604474c7ca633cd8835f // bloom
            //0f211baf3e629a41afbe39d3a275890772f3ab45 // ilya
            var loader:SimpleLoader=new SimpleLoader({
                method:"Cp2p.Offer.Get", 
                key:authKey,//"0f211baf3e629a41afbe39d3a275890772f3ab45",
                status:status,
                side:side
            },function(resp:SimpleLoaderResponse):void{
                
                if(resp.error){
                    trace(resp.error);
                    needReload=true;
                    return;
                }

                if(resp.data==null || !(resp.data is Array)){
                    trace("NO DATA ESCROW OFFER DATA!")
                    needReload=true;
                    return;
                }

                offers=new <EscrowOfferVO>[];
                var l:int=resp.data.length;
                for(var i:int=0;i<l;i++){
                    var eovo:EscrowOfferVO=new EscrowOfferVO(resp.data[i]);
                    offers.push(eovo);
                }
                loading=false;
                lastLoadTime=new Date().getTime();
                GD.S_ESCROW_OFFERS_READY.invoke(offers);
            });
            
        }

        private function onEscrowOfferCreateRequest(escrowOfferVO:*):void{

        }
        
    }
}