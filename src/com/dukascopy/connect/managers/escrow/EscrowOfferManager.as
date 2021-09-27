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