package jp.pixels.pb.panels {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import jp.pixels.pb.Configure;
	import jp.pixels.pb.panels.PreviewControlPanel;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.ResourceProvider;
	import jp.pixels.pb.Store;
	import jp.sionnet.leaflip.Bookflip;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class PreviewPanel extends Sprite {
		
		private const LAYER_IMAGE:int = 0;
		private const LAYER_BK:int = 1;
		private const LAYER_BOOK:int = 2;
		private const CONTROLLER_OFFSET_Y:Number = 426;

		private var pageW_:Number = 0;
		private var pageH_:Number = 0;
		private var bind_:int;
		private var bookFlip_:Bookflip;
		private var back_:Sprite;
		private var controller_:PreviewControlPanel;
		private var pageCount_:int;
		private var currentIndex_:int;
		
		public function get currentIndex():int { return currentIndex_; }
		
		public function PreviewPanel(pageW:Number, pageH:Number)  {
			
			pageW_ = pageW;
			pageH_ = pageH;
			pageCount_ = 0;
			currentIndex_ = 0;
			
			graphics.beginFill(Configure.BACK_COLOR);
			graphics.drawRect(0, 0, Configure.PREVIEW_W, Configure.PREVIEW_H);
			graphics.endFill();
			
			var bk:Bitmap = ResourceProvider.getImage(ResourceProvider.IMAGE_BK_IPAD);
			
			var imageBack:Sprite = new Sprite();
			imageBack.graphics.beginFill(0x404040);
			imageBack.graphics.drawRect(0, 0, bk.width - 64, bk.height - 64);
			imageBack.graphics.endFill();
			imageBack.x = 32;
			imageBack.y = 32;
			addChildAt(imageBack, LAYER_IMAGE);
			
			back_ = new Sprite();
			back_.graphics.beginFill(0, 0);
			back_.graphics.drawRect(0, 0, bk.width, bk.height);
			back_.graphics.endFill();
			back_.addChild(bk);
			addChildAt(back_, LAYER_BK);
			
			controller_ = new PreviewControlPanel(Configure.PREVIEW_W - 156, 45);
			controller_.x = Configure.PREVIEW_W / 2 - controller_.width / 2 - 3;
			controller_.y = CONTROLLER_OFFSET_Y;
			controller_.addEventListener(PBEvent.PREVIEW_LEFT, onControllerLeft);
			controller_.addEventListener(PBEvent.PREVIEW_RECORD_START, function(e:PBEvent):void { dispatchEvent(e); } );
			controller_.addEventListener(PBEvent.PREVIEW_RECORD_STOP,  function(e:PBEvent):void { dispatchEvent(e); } );
			controller_.addEventListener(PBEvent.PREVIEW_PLAY_START,  function(e:PBEvent):void { dispatchEvent(e); } );
			controller_.addEventListener(PBEvent.PREVIEW_PLAY_STOP,  function(e:PBEvent):void { dispatchEvent(e); } );
			controller_.addEventListener(PBEvent.PREVIEW_RIGHT, onControllerRight);
			back_.addChild(controller_);
		}
		
		public function initBookFlip(store:Store, bind:int):void {
			if (bookFlip_) {
				back_.removeChild(bookFlip_);
			}
			
			if (store.count == 0) {
				return;
			}
			
			bind_ = bind;
			pageCount_ = store.count;
			
			bookFlip_ = new Bookflip(store.pageW, store.pageH, bind);
			bookFlip_.x = back_.width / 2 - store.pageW;
			bookFlip_.y = back_.height / 2 - store.pageH / 2;
			
			var count:int = store.count;
			var i:int;
			var index:int = 1;
			var contentCount:int = count / 2;
			for (i = 1; i < contentCount; i++) {
				bookFlip_.addPage(index, store.getAtIndex(i * 2 - 1), store.getAtIndex(i * 2 - 0));
				index += 2;
			}
			
			bookFlip_.setCover(store.getAtIndex(0), store.getAtIndex(count - 1));
			bookFlip_.setGradient();
			back_.addChildAt(bookFlip_, 0);
		}

		private function onControllerLeft(e:PBEvent):void {
			if (pageCount_ == 0) {
				return;
			}
			
			if (bind_ == Bookflip.BIND_LEFT) {
				bookFlip_.gotoPrevPage();
				currentIndex_--;
			}
			else {
				bookFlip_.gotoNextPage();
				currentIndex_++;
			}
		}
		
		private function onControllerRight(e:PBEvent):void {
			if (pageCount_ == 0) {
				return;
			}
			
			if (bind_ == Bookflip.BIND_LEFT) {
				bookFlip_.gotoNextPage();
				currentIndex_++;
			}
			else {
				bookFlip_.gotoPrevPage();
				currentIndex_--;
			}
		}
	}
}