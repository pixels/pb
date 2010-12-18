package jp.pixels.pb.net {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ConnectionEvent extends GenericEvent {
		
		public static const CONNECTED:String = "CONNECTED";
		public static const ERROR:String = "ERROR";
		public static const RESPONSE:String = "RESPONSE";
		
		public function ConnectionEvent(type:String, info:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, info, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new ConnectionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ConnectionEvent", "info", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}