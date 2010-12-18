package jp.pixels.pb.net {
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Responder;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class SimpleConnection extends Red5NetConnection {
		
		public function SimpleConnection() {
		}
		
		override public function connect(command:String, ...rest):void {
			close();
			
			proxyType = "none"; // "none", "HTTP", "CONNECT", "best"
			addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			super.connect(command, rest);
		}
		
		override public function close():void {
			if (connected) {
				super.close();
			}
			
			if (hasEventListener(NetStatusEvent.NET_STATUS)) {
				removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}
		
		private function onNetStatus(e:NetStatusEvent):void {
			var code:String = e.info["code"];
			switch(code){
				case "NetConnection.Connect.Success":
					dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTED));
					break;
				case "NetConnection.Connect.Failed":
					dispatchEvent(new ConnectionEvent(ConnectionEvent.ERROR, { code:code, text:code } ));
					break;
				case "NetConnection.Connect.Closed":
					//dispatchEvent(new ConnectionEvent(ConnectionEvent.ERROR, { code:code, text:code } ));
					break;
			}
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ERROR, { code:"SecurityError", text:e.text } ));
		}
		
		private function onAsyncError(e:AsyncErrorEvent):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ERROR, { code:"AsyncError", text:e.text } ));
		}
		
		private function onIOError(e:IOErrorEvent):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ERROR, { code:"IOError", text:e.text } ));
		}
		
		
		public function jInvoke(key:String, value:Object=null):void {
			if (!value || (value is String && value == "")) {
				value = { value:null };
			}
			
			call("jInvoke", new Responder(onResFunc, onErrorFunc), key, value );
		}
		
		public function jBroadcast(value:Object):void {
			jInvoke("RequestBroadcast", value);
		}
		
		// 結果が返ってきたときにcallされる
		protected function onResFunc(value:Object):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.RESPONSE, { value:value } ));
		}

		// errorのときにcallされる
		protected function onErrorFunc(result:Object):void {
			trace("[ERROR] SimpleConnection.as onErrorFunc");
		}
	}
}