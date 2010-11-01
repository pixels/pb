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
		public static const PREVIEW_RIGHT:String = "PREVIEW_RIGHT";
		public static const UPLOAD_START_OPEN:String = "UPLOAD_START_OPEN";
		public static const UPLOAD_COMPLETE_OPEN:String = "UPLOAD_COMPLETE_OPEN";
		public static const UPLOAD_START_CLOSE:String = "UPLOAD_START_CLOSE";
		public static const UPLOAD_COMPLETE_CLOSE:String = "UPLOAD_COMPLETE_CLOSE";
		public static const CATALOG_SWAP:String = "CATALOG_SWAP";
		public static const CATALOG_TRASH:String = "CATALOG_TRASH";
		public static const PUBLISH_CLICK:String = "PUBLISH_CLICK";
		public static const REARRANGE_FINISHIED:String = "REARRANGE_FINISHIED";
		
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