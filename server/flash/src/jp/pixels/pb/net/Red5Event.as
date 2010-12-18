package jp.pixels.pb.net {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Red5Event extends Event {
		
		public static const FROM_RED5:String = "FROM_RED5";
		
		private var info_:Object;
		
		public function get info():Object { return info_; }
		
		public function Red5Event(type:String, info:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			info_ = info;
		} 
		
		public override function clone():Event { 
			return new Red5Event(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("Red5Event", "info", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}