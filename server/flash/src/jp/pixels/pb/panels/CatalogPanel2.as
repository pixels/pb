package jp.pixels.pb.panels {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import jp.pixels.pb.object.ArrowButton;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.Store;
	import net.kawa.tween.KTJob;
	import net.kawa.tween.KTween;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class CatalogPanel2 extends Sprite {
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var duretion_:Number = 1;
		private var lastY_:Number;
		private var title_:Sprite;
		private var arrow_:ArrowButton;
		
		public function CatalogPanel2(areaW:Number, areaH:Number, duretion:Number) {
			
			areaW_ = areaW;
			areaH_ = areaH;
			duretion_ = duretion;

			const thickness:Number = 8;
			const thicknessd2:Number = thickness / 2;
			const ellipse:Number = 16;
			graphics.beginFill(0xea5415);
			graphics.drawRoundRect(0, 0, areaW, areaH, ellipse);
			graphics.endFill();
			graphics.beginFill(0xffffff);
			graphics.drawRoundRect(thicknessd2, thicknessd2, areaW - thickness, areaH - thickness, ellipse);
			graphics.endFill();
			
			title_ = createButton(211, 25, "parts/text00.png");
			title_.x = 4 + thicknessd2;
			title_.y = 4 + thicknessd2;
			addChild(title_);
			
			arrow_ = new ArrowButton();
			arrow_.addEventListener(MouseEvent.CLICK, onArrowClick);
			arrow_.x = areaW / 2 - arrow_.width / 2;
			arrow_.y = areaH - arrow_.height - thicknessd2;
			addChild(arrow_);
		}
		
		public function update(store:Store, bind:int):void {
			
		}
		
		public function open():void {
			var job:KTJob = KTween.fromTo(this, duretion_, { scaleY:0, y:y }, { scaleY:1, y:lastY_ } );
			job.addEventListener(Event.COMPLETE, onWindowOpenedComplete);
		}
		
		public function close():void {
			lastY_ = y;
			var job:KTJob = KTween.fromTo(this, duretion_, { scaleY:1, y:y }, { scaleY:0, y:(y + height) } );
			job.addEventListener(Event.COMPLETE, onWindowClosedComplete);
		}
		
		public function trash():Array {
			return null;
		}
		
		private function setupRect(sp:Sprite, areaW:Number, areaH:Number, color:uint, alpha:Number=1, thicness:Number=0, lineColor:uint=0, ellipse:Number=0):void {
			sp.graphics.clear();
			if (thicness != 0) {
				sp.graphics.lineStyle(thicness, lineColor, alpha);
			}
			sp.graphics.beginFill(color, alpha);
			if (ellipse == 0) {
				sp.graphics.drawRect(0, 0, areaW, areaH);
			}
			else {
				sp.graphics.drawRoundRect(0, 0, areaW, areaH, ellipse);
			}
			sp.graphics.endFill();
		}
		
		private function createRect(areaW:Number, areaH:Number, color:uint, alpha:Number=1, thicness:Number=0, lineColor:uint=0, ellipse:Number=0):Sprite {
			var sp:Sprite = new Sprite();
			setupRect(sp, areaW, areaH, color, alpha, thicness, lineColor, ellipse);
			
			return sp;
		}
		
		private function createButton(w:Number, h:Number, url:String):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0, 0);
			sp.graphics.drawRect(0, 0, w, h);
			sp.graphics.endFill();
			
			var l:Loader = new Loader();
			l.load(new URLRequest(url));
			sp.addChild(l);
			
			return sp;
		}
		
		private function onWindowOpenedComplete(e:Event):void {
			var job:KTJob = e.currentTarget as KTJob;
			job.removeEventListener(Event.COMPLETE, onWindowOpenedComplete);
		}
		
		private function onWindowClosedComplete(e:Event):void {
			var job:KTJob = e.currentTarget as KTJob;
			job.removeEventListener(Event.COMPLETE, onWindowClosedComplete);
		}
		
		private function onArrowClick(e:MouseEvent):void {
			dispatchEvent(new PBEvent(PBEvent.CATALOG_ARROW, { bind:arrow_.left } ));
		}
	}
}