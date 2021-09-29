package com.dukascopy.connect.managers.escrow
{
    import com.dukascopy.connect.GD;
    import com.telefision.utils.SimpleLoader;
    import com.telefision.utils.SimpleLoaderResponse;
    import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;

    public class EscrowOfferManager{

        private var offers:Vector.<EscrowOfferVO>;
        private var loading:Boolean=false;
        private var needReload:Boolean=true;

        public function EscrowOfferManager(){
            //GD.S_ESCROW_OFFER_CREATE_REQUEST.add(onEscrowOfferCreateRequest,this);

            GD.S_ESCROW_OFFERS_REQUEST.add(function(cb:Function=null):void{
                
                if(loading)
                    return;

                if(needReload){
                    loadOffers()
                    return;
                }

                if(cb && cb is Function && cb.length==1)
                    cb(offers);

                GD.S_ESCROW_OFFERS_READY.invoke(offers);
            })
        }   

        /*status из таблицы
side 'BOTH', 'BUY', 'SELL' +null
ccy 'both', 'crypto', 'mca' +null*/

/*status
'awaiting','offer_created','created','accepted','canceled','rejected','outdated'
state
'awaiting','check_mca','invalid','confirmed'*/

        private function loadOffers():void{
            loading=true;
            needReload=false;
            var url:String="https://loki.telefision.com/master/";
            //e41ae903d332b69f490d604474c7ca633cd8835f // bloom
            //0f211baf3e629a41afbe39d3a275890772f3ab45 // ilya
            var loader:SimpleLoader=new SimpleLoader({
                method:"Cp2p.Offer.Get",
                key:"0f211baf3e629a41afbe39d3a275890772f3ab45"

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
                GD.S_ESCROW_OFFERS_READY.invoke(offers);
            },url);
            
        }

        private function onEscrowOfferCreateRequest(escrowOfferVO:*):void{

        }
        
    }
}