package com.dukascopy.connect.managers.escrow
{
    import com.dukascopy.connect.GD;

    public class EscrowOfferManager{
        public function EscrowOfferManager(){
            GD.S_ESCROW_OFFER_CREATE_REQUEST.add(onEscrowOfferCreateRequest,this);
            //EscrowMessageData
        }   

        private function onEscrowOfferCreateRequest(escrowOfferVO:*):void{

        }

        protected function rebase(){
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
        }


        // VALIDATE
        public function setChatUID(val:String):EscrowDealCreateRequest{
            this._chatUID=val;
            return this;
        }
        public function setInstrument(val:String):EscrowDealCreateRequest{
            this._instrument=val
            return this;
        }

        public function setPrimAmount(val:Number):EscrowDealCreateRequest{
            this._prim_amount=val
            return this;
        }

        public function setMcaCcy(val:String):EscrowDealCreateRequest{
            this._mca_ccy=val;
            return this;
        }
        
        public function setSecAmount(val:Number):EscrowDealCreateRequest{
            this._sec_amount=val;
            return this;
        }

        public function setSide(val:EscrowDealSide):EscrowDealCreateRequest{
            this._side=val;
            return this;
        }

        public function setMsgID(id:int):EscrowDealCreateRequest{
            _msgID=id;
            return this;
        }
        
        public function toObject():Object{
            return {
                chatUID:_chatUID,
                instrument:_instrument,
                prim_amount:_prim_amount,
                mca_ccy:_mca_ccy,
                sec_amount:_sec_amount,
                side:_side.value,
                msg_id:_msgID
            }
        }

        public function toString():String{
            return JSON.stringify(toObject());
        }
        
    }
}