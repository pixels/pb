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
		private const MODE_NONE:String = "MODE_NONE";
		private const MODE_RECORD:String = "MODE_RECORD";
		private const MODE_PLAY:String = "MODE_PLAY";
		
		private var directory_:String;
		private var conn_:SimpleConnection;
		private var stream_:NetStream;
		private var microphone_:Microphone;
		private var mode_:String = MODE_NONE;
		private var filename_:String;
		private var soundChannel_:SoundChannel;
		
		public function VoiceController(directory:String) {
			directory_ = directory;
			setupNetConnection(directory_);
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
			
			filename_ = createFilename(pageNum);
			mode_ = MODE_RECORD;
			
			conn_.jInvoke("Remove", { directory:directory_, filename:filename_, only:false } );
			return true;
		}
		
		public function stopRecording():void {
			if (mode_ != MODE_RECORD) {
				return;
			}
			
			stream_.attachAudio(null);
			stream_.close();
			conn_.jInvoke("Convert", { directory:directory_, filename:filename_ } );
			mode_ = MODE_NONE;
		}
		
		public function play(pageNum:Number):Boolean {
			if (mode_ != MODE_NONE) {
				return false;
			}
			
			filename_ = createFilename(pageNum);
			
			var url:String = "http://" + Configure.HOST + ":5080/" + Configure.APP_NAME + "/streams/" + directory_ + "/" + filename_ + ".mp3";
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
		
		public function remove(pageNum:int):void {
			filename_ = createFilename(pageNum);
			conn_.jInvoke("Remove", { directory:directory_, filename:filename_, only:true } );
		}
		
		private function getFiles():void {
			conn_.jInvoke("GetFiles", { directory:directory_ } );
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
		
		private function setupNetConnection(directory:String):void {
			var server:String = "rtmp://" + Configure.HOST  + "/" + Configure.APP_NAME + "/" + directory;
			conn_ = new SimpleConnection();
			conn_.addEventListener(ConnectionEvent.CONNECTED, onConnected);
			conn_.addEventListener(Red5Event.FROM_RED5, onFromRed5);
			conn_.connect(server);
		}
		
		private function createFilename(pageNum:int):String {
			return Configure.VOICE_PREFIX + pageNum;
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
			getFiles();
			setupCameraStream();
		}
		
		private function onFromRed5(e:Red5Event):void {
			var key:String = e.info["key"];
			var value:Object = e.info["value"];
			
			trace ("onResponse key: " + key + " value: " + value);
			if (key == "ReplyRemove") {
				if (value) {
					// Remove Only
				}
				else {
					startReroding();
				}
			}
			else if (key == "ReplyGetFiles") {
				var a:Array = new Array();
				if (value is Array) {
					for each(var v:String in value) {
						if (v.lastIndexOf(".mp3") != -1) {
							v = v.replace(Configure.VOICE_PREFIX, "").replace(".mp3", "");
							a.push(int(v));
						}
					}
				}
				dispatchEvent(new PBEvent(PBEvent.UPDATE_VOICE_LIST, { list:a } ));
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