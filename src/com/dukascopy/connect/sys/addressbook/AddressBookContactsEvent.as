package com.dukascopy.connect.sys.addressbook {

import flash.events.Event ;

	public class AddressBookContactsEvent extends flash.events.Event
	{
		public var contactsData : Object ;
		public var isLastPacket : Boolean ;
		
		public function AddressBookContactsEvent(contactsData:Object, isLastPacket:Boolean = false)
		{
			super(Addressbook.CONTACTS_UPDATED) ;
			this.contactsData=contactsData ;
			this.isLastPacket = isLastPacket ;
		}
	}
}