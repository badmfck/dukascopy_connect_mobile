import { Signal } from "./utils/Signal";

class GD{
    public static S_MY_CAMERA_READY:Signal<MediaStream>=new Signal();
    public static S_REMOTE_STREAM_READY:Signal<MediaStream>=new Signal();

    public static S_CALL_CANCELED:Signal<void>=new Signal();
    public static S_CALL_PLACED:Signal<void>=new Signal();
    public static S_CALL_ACCEPTED:Signal<void>=new Signal();
    public static S_CALL_CONNECTION_CLOSED:Signal<void>=new Signal();
    public static S_CALL_FINISHED:Signal<void>=new Signal();

    public static S_GOT_OFFER:Signal<any>=new Signal();
    public static S_GOT_ANSWER:Signal<any>=new Signal();
    public static S_GOT_CANDIDATE:Signal<any>=new Signal();
    
    public static S_INVOKE_METHOD:Signal<{name:string,data:any}>=new Signal();

    public static S_GUI_PANEL_SHOW:Signal<{id:string|null,onComplete?:()=>void}>=new Signal();

}
export default GD;