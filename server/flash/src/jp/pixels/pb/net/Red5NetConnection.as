package jp.pixels.pb.net {
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Red5NetConnection extends NetConnection {
		
		// Serverからcallされる
		public function flInvoke(value:Object):void {
			dispatchEvent(new Red5Event(Red5Event.FROM_RED5, value));
		}
	}
}