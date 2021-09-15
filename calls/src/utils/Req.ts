export class Req<T,K>{
    private name:string="";
    static nextID:number=0;
    constructor (name?:string){
        if(name==null)
            name="Request "+(Req.nextID++);
        this.name=name;
    }
    
    private worker:((data:T,callback:(value:K)=>void)=>void)|null=null
    invoke(data:T):Promise<K>{
        const executor=(resolve:(value:K)=>void,reject:(reason?:any)=>void)=>{
            if(this.worker){
                this.worker(data,resolve);
                return;
            }
            console.error(`${this.name} -> Worker no regisered yet`);
        }
        return new Promise<K>(executor);
    }
    set listener(value:((data:T,callback:(value:K)=>void)=>void)|null){ this.worker=value; }
}