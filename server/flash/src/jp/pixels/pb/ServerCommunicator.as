package jp.pixels.pb {
	import flash.accessibility.AccessibilityProperties;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ServerCommunicator extends EventDispatcher {
		
		private const STATUS_NONE:String = "STATUS_NONE";
		private const STATUS_ADDING:String = "STATUS_ADDING";
		private const STATUS_REMOVING:String = "STATUS_REMOVING";
		private const STATUS_SWAP:String = "STATUS_SWAP";
		private const STATUS_REARRANGE:String = "STATUS_REARRANGE";
		private const STATUS_PUBLISH:String = "STATUS_PUBLISH";
		
		private var queue_:Array = new Array();
		private var status_:String = STATUS_NONE;
		private var encID_:String;
		
		public function get encID():String { return encID_; }
		public function set encID(value:String):void { encID_ = value; }
		
		public function ServerCommunicator(encID:String) {
			encID_ = encID;
		}
		
		public function add():void {
			
		}
		
		public function rm(list:Array):void {
			var url:String;
			for each (url in list) {
				queue_.push(url);
			}
			
			if (status_ == STATUS_NONE) {
				if (queue_.length == 0) {
					notification(PBEvent.REARRANGE_FINISHIED);
				}
				else {
					execute(STATUS_REMOVING);
				}
			}
		}
		
		public function swap(srcIndex:int, destIndex:int):void {
			execute(STATUS_SWAP, { src_index:srcIndex, dest_index:destIndex } );
		}
		
		public function publish(direction:int, title:String, text:String, author:String, pagecount:int, actor:String, audio_title:String, audio_text:String):void {
			execute(STATUS_PUBLISH, { direction:direction, title:title, text:text, author:author, pagecount:pagecount, actor:actor, audio_title:audio_title, audio_text:audio_text } );
		}
		
		private function execute(request:String, params:Object=null):void {
			status_ = request;
			
			var val:URLVariables = new URLVariables();
			var req:URLRequest = new URLRequest();
			var l:URLLoader;
			
			if (status_ == STATUS_ADDING) {
				
			}
			else if (status_ == STATUS_REMOVING) {
				val["directory"] = encID_;
				val["filename"] = queue_[queue_.length - 1];

				req.url = Configure.API_DELETE_URL;
				l = new URLLoader();
				l.addEventListener(Event.COMPLETE, onDeleteCompleteData);
			}
			else if (status_ == STATUS_SWAP) {
				val["directory"] = encID_;
				//val["src_index"] = params["src_index"];
				//val["dest_index"] = params["dest_index"];
				
				req.url = Configure.API_SWAP_URL;
				
				log("STAUS_SWAP", val["directory"], val["src_index"], val["dest_index"], req.url);
				
				l = new URLLoader();
				l.addEventListener(Event.COMPLETE, onSwapCompleteData);
			}
			else if (status_ == STATUS_REARRANGE) {
				val["directory"] = encID_;
				val["start_index"] = 1;
				val["figure"] = 4;
				val["extension"] = Configure.EXTENSION;
				
				req.url = Configure.API_REARRANGE_URL;
				l = new URLLoader();
				l.addEventListener(Event.COMPLETE, onRearrangeCompleteData);
			}
			else if (status_ == STATUS_PUBLISH) {
				req.url = Configure.API_PUBLISH_URL;
				l = new URLLoader();
				l.addEventListener(Event.COMPLETE, onRearrangeCompleteData);
			}
			
			for (var key:String in params) {
				val[key] = params[key];
			}
			
			trace(this, "status: " + status_, "val: " + val);
			
			if (req && l) {
				req.method = URLRequestMethod.POST;
				req.data = val;
				l.load(req);
			}
		}
		
		private function notification(type:String, info:Object=null):void {
			dispatchEvent(new PBEvent(type, info));
		}
		
		private function onDeleteCompleteData(e:Event):void {
			var l:URLLoader = e.currentTarget as URLLoader;
			l.removeEventListener(Event.COMPLETE, onDeleteCompleteData);
			
			queue_.length--;
			if (queue_.length == 0) {
				execute(STATUS_REARRANGE);
			}
			else {
				execute(status_);
			}
		}
		
		private function onSwapCompleteData(e:Event):void {
			var l:URLLoader = e.currentTarget as URLLoader;
			l.removeEventListener(Event.COMPLETE, onSwapCompleteData);
			notification(PBEvent.SWAP_FINISHIED);
		}
		
		private function onRearrangeCompleteData(e:Event):void {
			var l:URLLoader = e.currentTarget as URLLoader;
			l.removeEventListener(Event.COMPLETE, onRearrangeCompleteData);
			notification(PBEvent.REARRANGE_FINISHIED);
		}
	}
}