package jp.pixels.pb  {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Store extends EventDispatcher {
		private var maxPageW_:Number = 0;
		private var maxPageH_:Number = 0;
		private var pageW_:Number = 0;
		private var pageH_:Number = 0;
		private var dict_:Object = new Object();
		private var list_:Array = new Array();
		private var url_:String;
		private var pageCount_:int;
		private var oddCount_:int;
		private var uploadIndexOffset_:int;
		private var usingDummy_:Bitmap;
		
		public function get count():int { return list_.length; }
		public function get pageW():Number { return pageW_; }
		public function get pageH():Number { return pageH_; }

		public function Store(maxPageW:Number, maxPageH:Number) {
			maxPageW_ = maxPageW;
			maxPageH_ = maxPageH;
		}
		
		public function setup(url:String, pageCount:int, addMode:Boolean):void {
			url_ = url;
			pageCount_ = pageCount;
			oddCount_ = pageCount;
			
			if (!addMode) {
				cleanup();
			}
			
			uploadIndexOffset_ = list_.length;
			request(url_, 1 + uploadIndexOffset_);
		}
		
		public function request(url:String, page:int):void {
			var reqURL:String = url + "/" + Util.fillZero(page, 4) + "." + Configure.EXTENSION + "?" + Util.rParam();
			//trace ("request reqURL: " + reqURL);

			var req:URLRequest = new URLRequest(reqURL);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load(req, new LoaderContext());
		}
		
		public function deployPages(beforeIndex:int, afterIndex:int):void {
			var forward:Boolean = afterIndex < beforeIndex;
			var start:int = forward ? afterIndex : beforeIndex;
			var end:int = forward ? beforeIndex : afterIndex;
			var i:int;
			var tmpItem:Bitmap;
			if (forward) {
				tmpItem = list_[end];
				for (i = (end - 1); i >= start; i--) {
					swapItem(i, i + 1);
				}
				list_[start] = tmpItem;
			}
			else {
				tmpItem = list_[start];
				for (i = (start + 1); i <= end ; i++) {
					swapItem(i, i - 1);
				}
				list_[end] = tmpItem;
			}
		}
		
		public function getAtIndex(index:int):Bitmap {
			return list_[index];
		}
		
		public function removeAtIndex(index:int):void {
			var item:Bitmap = list_[index];
			if (item) {
				delete dict_[item.name];
				var i:int;
				for (i = index; i < (list_.length - 1); i++) {
					list_[i] = list_[i + 1];
				}

				delete list_[(list_.length - 1)];
				list_.length--;
			}
			
			if (list_.length % 2 == 1) {
				if (usingDummy_) {
					removeDummyPage();
				}
				else {
					addDummyPage();
				}
			}
		}
		
		private function swapItem(index1:int, index2:int):void {
			var item:Bitmap;
			var next:Bitmap;
			item = list_[index1];
			next = list_[index2];
			list_[index2] = item;
			list_[index1] = next;
		}
		
		private function cleanup():void {
			var bitmap:Bitmap;
			for each(bitmap in dict_) {
				bitmap.bitmapData.dispose();
				bitmap.bitmapData = null;
			}

			dict_ = new Object();
			list_ = new Array();
		}
		
		private function removeDummyPage():void {
			var item:Bitmap = list_[(list_.length - 1)];
			delete dict_[item.name];
			delete list_[(list_.length - 1)];
			list_.length--;
			usingDummy_ = null;
		}
		
		private function addDummyPage():void {
			var bd:BitmapData = new BitmapData(pageW_, pageH_, false, 0xff888888);
			usingDummy_ = new Bitmap(bd);
			dict_[usingDummy_.name] = usingDummy_;
			list_.push(usingDummy_);
			trace ("[WARN] PreviewPanel.as addDummyPage");
		}
		
		private function onLoaderComplete(e:Event):void {
			var li:LoaderInfo = e.target as LoaderInfo;
			li.removeEventListener(Event.COMPLETE, onLoaderComplete);
			
			var loader:Loader = li.loader;
			var rate:Number = Util.resize(loader.width, loader.height, maxPageW_, maxPageH_);
			var tmpW:Number = loader.width * rate;
			var tmpH:Number = loader.height * rate;
			if (pageW_ < tmpW) {
				pageW_ = tmpW;
			}
			if (pageH_ < tmpH) {
				pageH_ = tmpH;
			}

			var mat:Matrix = new Matrix();
			mat.scale(rate, rate);
			var bd:BitmapData = new BitmapData(pageW_, pageH_, true, 0x00ffffff);
			bd.draw(loader, mat);
			
			var bitmap:Bitmap = new Bitmap(bd);
			dict_[bitmap.name] = bitmap;
			list_.push(bitmap);
			
			oddCount_--;
			if (oddCount_ > 0) {
				var next:int = pageCount_ - (oddCount_ - 1) + uploadIndexOffset_;
				request(url_, next);
			}
			else {
				if (pageCount_ % 2 == 1) {
					addDummyPage();
				}
				trace ("all loaded!!");
				dispatchEvent(new PBEvent(PBEvent.STORE_LOADED));
			}
		}
	}
}