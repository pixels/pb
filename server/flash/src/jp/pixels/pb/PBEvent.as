package jp.pixels.pb 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class PBEvent extends Event {
		
		public static const STORE_LOADED:String = "STORE_LOADED";
		public static const PREVIEW_LOADED:String = "PREVIEW_LOADED";
		public static const PREVIEW_LEFT:String = "PREVIEW_LEFT";
		public static const PREVIEW_RECORD_START:String = "PREVIEW_RECORD_START";
		public static const PREVIEW_RECORD_STOP:String = "PREVIEW_RECORD_STOP";
		public static const PREVIEW_PLAY_START:String = "PREVIEW_PLAY_START";
		public static const PREVIEW_PLAY_STOP:String = "PREVIEW_PLAY_STOP";
		public static const PREVIEW_RIGHT:String = "PREVIEW_RIGHT";
		public static const UPLOAD_START_OPEN:String = "UPLOAD_START_OPEN";
		public static const UPLOAD_START_CLOSE:String = "UPLOAD_START_CLOSE";
		public static const UPLOAD_CANCEL_CLOSE:String = "UPLOAD_CANCEL_CLOSE";
		public static const UPLOAD_COMPLETE_CLOSE:String = "UPLOAD_COMPLETE_CLOSE";
		public static const CATALOG_SWAP:String = "CATALOG_SWAP";
		public static const CATALOG_ARROW:String = "CATALOG_ARROW";
		public static const SWAP_FINISHIED:String = "SWAP_FINISHIED";
		public static const REARRANGE_FINISHIED:String = "REARRANGE_FINISHIED";
		public static const UPDATE_VOICE_LIST:String = "UPDATE_VOICE_LIST";
		public static const STOP_PLAYING_VOICE:String = "STOP_PLAYING_VOICE";
		
		private var info_:Object;
		
		public function get info():Object { return info_; }
		
		public function PBEvent(type:String, info:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			info_ = info;
		} 
		
		public override function clone():Event { 
			return new PBEvent(type, info_, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("PBEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}