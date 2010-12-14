package jp.pixels.pb.panels {
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
		private const SCROLL_SPEED:Number = 4;
		private const SCROLL_BUTTON_WIDTH:Number = 230;
		private const SCROLL_BUTTON_HIEGHT:Number = 20;
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var duretion_:Number = 1;
		private var lastY_:Number;
		private var title_:Sprite;
		private var content_:Sprite;
		private var arrow_:ArrowButton;
		private var catalog_:UICatalog;
		private var voice_:VoicePanel;
		private var catalogVector_:Number;
		
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
			
			content_ = createContent(232, 340);
			content_.x = areaW / 2 - content_.width / 2;
			content_.y = title_.y + title_.height + 8;
			addChild(content_);
			var scrollBtn:Sprite;
			scrollBtn = createScrollButton(SCROLL_BUTTON_WIDTH, SCROLL_BUTTON_HIEGHT, true);
			scrollBtn.addEventListener(MouseEvent.MOUSE_OVER, onCatalogScrollUpMouseOver);
			scrollBtn.addEventListener(MouseEvent.MOUSE_OUT, onCatalogScrollUpMouseOut);
			scrollBtn.x = content_.width / 2 - scrollBtn.width / 2;
			scrollBtn.y = 1;
			content_.addChild(scrollBtn);
			
			scrollBtn = createScrollButton(SCROLL_BUTTON_WIDTH, SCROLL_BUTTON_HIEGHT, false);
			scrollBtn.addEventListener(MouseEvent.MOUSE_OVER, onCatalogScrollDownMouseOver);
			scrollBtn.addEventListener(MouseEvent.MOUSE_OUT, onCatalogScrollUpMouseOut);
			scrollBtn.x = content_.width / 2 - scrollBtn.width / 2;
			scrollBtn.y = content_.height - scrollBtn.height - 1;
			content_.addChild(scrollBtn);
			
			arrow_ = new ArrowButton();
			arrow_.addEventListener(MouseEvent.CLICK, onArrowClick);
			arrow_.x = areaW / 2 - arrow_.width / 2;
			arrow_.y = areaH - arrow_.height - thicknessd2;
			addChild(arrow_);
		}
		
		public function update(store:Store, bind:int):void {
			if (voice_) {
				content_.removeChild(voice_);
			}
			if (catalog_) {
				content_.removeChild(catalog_);
			}
			
			var lines:int = (store.count / 2 + 1);
			var bodyH:Number = content_.height - (SCROLL_BUTTON_HIEGHT * 2) - 4;
			var bodyY:Number = SCROLL_BUTTON_HIEGHT + 2;
			
			catalog_ = new UICatalog(180, bodyH);
			catalog_.update(store, bind);
			catalog_.x = 1;
			catalog_.y = bodyY;
			content_.addChild(catalog_);
			
			voice_ = new VoicePanel(48, bodyH, lines, catalog_.itemSize, UICatalog.IMAGE_MARGIN_H);
			voice_.x = content_.width - voice_.width - 1;
			voice_.y = bodyY;
			content_.addChild(voice_);

			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
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
		
		private function createContent(w:Number, h:Number):Sprite {
			var thickness:Number = 1;
			var thicknessd2:Number = thickness / 2;
			var ellipse:Number = 8;
			
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(thickness, 0x000000);
			sp.graphics.beginFill(0xffffff);
			sp.graphics.drawRoundRect(thicknessd2, thicknessd2, w - thickness, h - thickness, ellipse);
			sp.graphics.endFill();
			
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0xffffff);
			mask.graphics.drawRoundRect(thicknessd2, thicknessd2, w - thickness, h - thickness, ellipse);
			mask.graphics.endFill();
			sp.mask = mask;
			sp.addChild(mask);

			return sp;
		}
		
		private function createScrollButton(w:Number, h:Number, up:Boolean):Sprite {
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xffffff, 0xcfcfcf];
			var alphas:Array = [1, 1];
			var ratios:Array = [0x00, 0xFF];
			var mat:Matrix = new Matrix();
			mat.createGradientBox(w, h, Math.PI * 0.5, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;

			var thickness:Number = 1;
			var thicknessd2:Number = thickness / 2;
			var ellipse:Number = 8;
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(thickness, 0xcfcfcf);
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
			sp.graphics.drawRoundRect(thicknessd2, thicknessd2, w - thickness, h - thickness, ellipse);
			sp.graphics.endFill();
			
			var pt:Point = new Point(w / 2, h / 2);
			sp.graphics.beginFill(0x999999);
			if (up) {
				sp.graphics.moveTo(pt.x + 6, pt.y + 6);
				sp.graphics.lineTo(pt.x, pt.y - 6);
				sp.graphics.lineTo(pt.x - 6, pt.y + 6);
			}
			else {
				sp.graphics.moveTo(pt.x - 6, pt.y - 6);
				sp.graphics.lineTo(pt.x, pt.y + 6);
				sp.graphics.lineTo(pt.x + 6, pt.y - 6);
			}
			sp.graphics.endFill();
			
			
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
		
		private function onEnterFrame(e:Event):void {
			if (catalog_) {
				catalog_.setScroll(catalog_.offsetY + catalogVector_);
				voice_.setScroll(catalog_.offsetY);
			}
		}
		
		private function onCatalogScrollUpMouseOver(e:MouseEvent):void {
			catalogVector_ = SCROLL_SPEED;
		}
		
		private function onCatalogScrollDownMouseOver(e:MouseEvent):void {
			catalogVector_ = -SCROLL_SPEED;
		}
		
		private function onCatalogScrollUpMouseOut(e:MouseEvent):void {
			catalogVector_ = 0;
		}
	}
}