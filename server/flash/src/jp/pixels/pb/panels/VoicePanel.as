package jp.pixels.pb.panels {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class VoicePanel extends Sprite {
		
		private var w_:Number;
		private var h_:Number;
		private var list_:Object = new Object();
		private var count_:int;
		private var itemSize_:Number;
		private var itemOffsetY_:Number;
		private var mask_:Sprite, body_:Sprite;
		
		public function VoicePanel(w:Number, h:Number, count:int, itemSize:Number, itemOffsetY:Number) {
			w_ = w;
			h_ = h;
			count_ = count;
			itemSize_ = itemSize;
			itemOffsetY_ = itemOffsetY;
			create(w, h);
			
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			l.load(new URLRequest("parts/mic.png"));
		}
		
		public function setScroll(offsetY:Number):void {
			if (body_) {
				body_.y = offsetY;
			}
		}
		
		public function iconVisible(index:int, visible:Boolean):void {
			var bmp:Bitmap = list_[index];
			if (bmp) {
				bmp.visible = visible;
			}
		}
		
		private function create(w:Number, h:Number):void {
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			
			mask_ = new Sprite();
			mask_.graphics.beginFill(0x0000ff, 0);
			mask_.graphics.drawRect(0, 0, w_,  h_);
			mask_.graphics.endFill();
			addChild(mask_);
		}
		
		private function onComplete(e:Event):void {
			var li:LoaderInfo = e.currentTarget as LoaderInfo;
			li.removeEventListener(Event.COMPLETE, onComplete);

			var l:Loader = li.loader;
			var cx:Number = w_ / 2 - l.width / 2;
			var bmp:Bitmap;
			var bd:BitmapData = new BitmapData(l.width, l.height, true, 0xffffffff);
			bd.draw(l);
			var iosY:Number = itemSize_ + itemOffsetY_;
			var coY:Number = itemSize_ / 2 - l.height / 2 + itemOffsetY_;

			body_ = new Sprite();
			body_.graphics.beginFill(0x00ff00, 0);
			body_.graphics.drawRect(0, 0, w_,  iosY * count_ + coY);
			body_.graphics.endFill();
			body_.mask = mask_;
			addChild(body_);
			
			for (var i:int = 0; i < count_; i++) {
				bmp = new Bitmap(bd);
				list_[i] = bmp;
				bmp.x = cx;
				bmp.y = iosY * i + coY;
				body_.addChild(bmp);
			}
		}
	}
}