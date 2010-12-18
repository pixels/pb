package jp.pixels.pb.net {
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class NetStreamCall {
		public function onMetaData(info:Object):void {  
			trace("NetStreamCall.as metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);  
		}

		public function onCuePoint(info:Object):void {  
			trace("NetStreamCall.as cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);  
		}

		public function onPlayStatus(info:Object):void {  
			trace("NetStreamCall.as onPlayStatus call");  
		} 
	}
}