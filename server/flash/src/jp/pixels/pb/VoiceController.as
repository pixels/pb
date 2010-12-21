package jp.pixels.pb {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import jp.pixels.pb.net.ConnectionEvent;
	import jp.pixels.pb.net.NetStreamCall;
	import jp.pixels.pb.net.Red5Event;
	import jp.pixels.pb.net.SimpleConnection;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class VoiceController extends EventDispatcher {
		private const PATH:String = "room1/room2/myroom";
		private const VOICE_SERVER:String = "rtmp://" + Configure.HOST  + "/" + Configure.APP_NAME + "/" + PATH;
		private const MODE_NONE:String = "MODE_NONE";
		private const MODE_RECORD:String = "MODE_RECORD";
		private const MODE_PLAY:String = "MODE_PLAY";
		
		private var conn_:SimpleConnection;
		private var stream_:NetStream;
		private var microphone_:Microphone;
		private var mode_:String = MODE_NONE;
		private var filename_:String;
		private var soundChannel_:SoundChannel;
		
		public function VoiceController() {
			setupNetConnection();
		}
		
		public function record(pageNum:Number):Boolean {
			if (mode_ != MODE_NONE) {
				return false;
			}
			
			if (!microphone_) {
				if (!(microphone_ = createMirophone())) {
					return false;
				}
			}
			
			setPage(pageNum);
			mode_ = MODE_RECORD;
			
			conn_.jInvoke("Remove", { path:PATH, filename:filename_ } );
			return true;
		}
		
		public function stopRecording():void {
			if (mode_ != MODE_RECORD) {
				return;
			}
			
			stream_.attachAudio(null);
			stream_.close();
			conn_.jInvoke("Convert", { path:PATH, filename:filename_ } );
			mode_ = MODE_NONE;
		}
		
		public function play(pageNum:Number):Boolean {
			if (mode_ != MODE_NONE) {
				return false;
			}
			
			setPage(pageNum);
			
			var url:String = "http://" + Configure.HOST + ":5080/" + Configure.APP_NAME + "/streams/" + PATH + "/" + filename_ + ".mp3";
			var rnd:String = "r=" + Math.round(Math.random() * 1000);
			var sound:Sound = new Sound(new URLRequest(url + "?" + rnd));
			sound.addEventListener(IOErrorEvent.IO_ERROR, onIOPlayError);
			soundChannel_ = sound.play();
			soundChannel_.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			mode_ = MODE_PLAY;
			return true;
		}
		
		public function stopPlaying():void {
			if (soundChannel_) {
				soundChannel_.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				soundChannel_.stop();
				soundChannel_ = null;
			}
			mode_ = MODE_NONE;
		}
		
		private function createMirophone():Microphone {
			if (!Microphone.isSupported || Microphone.names.length == 0) {
				return null;
			}
			
			var mic:Microphone = Microphone.getMicrophone();
			mic.gain = 100; // 0 - 100
			//mic.codec = SoundCodec.SPEEX;
			//mic.encodeQuality = 10;
			//mic.framesPerPacket = 10;
			mic.rate = 44;
			//mic.setLoopBack(false);
			mic.setUseEchoSuppression(true);
			
			return mic;
		}
		
		private function setupNetConnection():void {
			conn_ = new SimpleConnection();
			conn_.addEventListener(ConnectionEvent.CONNECTED, onConnected);
			conn_.addEventListener(Red5Event.FROM_RED5, onFromRed5);
			conn_.connect(VOICE_SERVER);
		}
		
		private function setPage(pageNum:int):void {
			filename_ = Configure.VOICE_PREFIX + pageNum;
		}
		
		private function setupCameraStream():void {  
			stream_ = new NetStream(conn_);
			stream_.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);  
			stream_.client = new NetStreamCall();  
		}
		
		private function startReroding():void {
			stream_.pause();
			stream_.attachAudio(microphone_);
			stream_.publish(filename_, "record");
		}
		
		private function onSoundComplete(e:Event):void {
			stopPlaying();
		}
		
		private function onIOPlayError(e:IOErrorEvent):void {
			stopPlaying();
		}
		
		private function onConnected(e:ConnectionEvent):void {
			setupCameraStream();
		}
		
		private function onFromRed5(e:Red5Event):void {
			var key:String = e.info["key"];
			var value:Object = e.info["value"];
			
			trace ("onResponse key: " + key + " value: " + value);
			if (e.info["key"] == "ReplyRemove") {
				startReroding();
			}
		}

		/**
		 * NetStream Only
		 * @param	e NetStatusEvent
		 */
		private function onNetStatus(e:NetStatusEvent):void {
			var code:String = e.info["code"];
			trace ("onNetStatus code: " + code);
		}
	}
}