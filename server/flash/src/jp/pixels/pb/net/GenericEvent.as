package jp.pixels.pb.net {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class GenericEvent extends Event {
		
		public static const LOG:String = "LOG";
		
		private var info_:Object;
		public function get info():Object { return info_; }
		
		public function GenericEvent(type:String, info:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			info_ = info;
		} 
		
		public override function clone():Event { 
			return new GenericEvent(type, info_, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("GenericEvent", "info", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}