package com.dukascopy.langs
{
    import com.dukascopy.connect.GD;
    import com.dukascopy.dccext.DCCExt;
    import com.dukascopy.dccext.DCCExtCommand;
    import com.dukascopy.dccext.DCCExtMethod;
    import com.dukascopy.connect.Config;

    public class IOSLocalization{
        public function IOSLocalization(){
            GD.S_IOS_LOCALIZATION_UPDATE.add(updateLocalization);
            updateLocalization();
        }

        private function updateLocalization():void{
            if(DCCExt.isContextCreated && Config.PLATFORM_APPLE){
                DCCExt.call(new DCCExtCommand(
                    DCCExtMethod.LOCALIZATION,
                    {
                        n_group:Lang.iosNotificationUnreadGroup,
                        n_private:Lang.iosNotificationUnreadPrivate,
                        n_private_single:Lang.iosNotificationUnreadPrivateSingle
                    }
                ))
            }
        }
    }
}