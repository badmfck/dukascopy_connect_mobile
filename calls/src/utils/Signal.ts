export class Signal<T>{

    static nextID:number=1;
    private name:string|undefined=""; 
    private methods:Map<(data:T)=>void,any>|undefined=new Map(); /* callback, context */
    private delayedAdd:Array<{cb:(data:T)=>void,ctx:any}>|undefined=[];
    private delayedRemove:Array<(data:T)=>void>|undefined=[];
    private delayedContextClear:Array<any>|undefined=[];
    private delayedInvoke:Array<T>|undefined=[];

    private isDisposing=false;
    private isInvoking=false;

    constructor(name?:string){
        this.name=name;
        if(name==null)
            this.name="signal "+(Signal.nextID++);
                else
                    this.name=name;
    }
    
    /**
     * Add callback to signal, callback fill fire, when signal invoking
     * @param callback  any function with proper type of param
     * @param context   this for function call, if exists
     */
    public add(callback:(data:T)=>void,context?:any):((data:T)=>void)|null{
        if(this.isDisposing)
            return null;
        // invoking, adding to temprary
        if(this.isInvoking && this.delayedAdd){
            for(let i of this.delayedAdd){
                if(i.cb===callback)
                    return callback;
            }
            this.delayedAdd.push({cb:callback,ctx:context});
            return callback;
        }

        // allready exitst
        if(this.methods){
            for(let m of this.methods){
                if(m[0]===callback){
                    console.warn("method already exitst");
                    return callback;
                }
            }
            // add method
            this.methods.set(callback,context);
        }
        
        return callback;
    }

    public remove(callback:(data:T)=>void){
        if(this.isDisposing)
            return;
        if(this.isInvoking===true && this.delayedRemove){
            for(let i of this.delayedRemove){
                if(i===callback)
                    return;
            }
            this.delayedRemove.push(callback);
            return;
        }
        if(this.methods)
            this.methods.delete(callback);
    }

    public clearContext(context:any){
        if(this.isInvoking && this.delayedContextClear){
            this.delayedContextClear.push(context);
            return;
        }
        
        if(this.methods){
            for(let i of this.methods){
                if(i[1]===context)
                    this.methods.delete(i[0]);
            }
        }
    }

    public invoke(data:T){
        if(this.isDisposing)
            return;
        if(!this.methods)
            return;
        if(this.isInvoking && this.delayedInvoke){
            this.delayedInvoke.push(data);
            console.warn("Signal already invoking "+this.name);
            return;
        }
        this.isInvoking=true;
        for(let m of this.methods){

            if(m[0]==null){
                // callback is null, remove callback from stock;
                this.methods.delete(m[0]);
                continue;
            }

            if( typeof m[0] != "function"){
                console.error("Can`t invoke method for signal: "+this.name);
                continue;
            }
            // invoking
            try{
                if(m[1]!=null)
                    m[0].call(m[1],data);
                        else
                            m[0].call(m[0],data);
            }catch(e){ console.error(e);}
        }
        this.isInvoking=false;

        if(this.isDisposing){
            this.dispose();
            return;
        }

        if(this.delayedRemove && this.delayedRemove.length>0){
            for(let i of this.delayedRemove)
                this.remove(i);
            this.delayedRemove=[];
        }

        if(this.delayedAdd && this.delayedAdd.length>0){
            for(let i of this.delayedAdd){
                if(i)
                    this.add(i.cb,i.ctx);
            }
            this.delayedAdd=[];
        }

        if(this.delayedContextClear && this.delayedContextClear.length>0){
            for(let i of this.delayedContextClear)
                this.clearContext(i[1]);
            this.delayedContextClear=[];
        }

        if(this.delayedInvoke && this.delayedInvoke.length>0){
            const ivk=this.delayedInvoke.shift();
            if(ivk)
                this.invoke(ivk);
        }


    }
    
    public dispose(){
        if(this.isDisposing)
            return;
        if(this.isInvoking)
            return;
        this.isDisposing=true;

        this.name=undefined;
        if(this.methods)
            this.methods.clear();
        this.methods=undefined;
        this.delayedAdd=undefined;
        this.delayedRemove=undefined;
        this.delayedContextClear=undefined;
    
    }
}