package jp.pixels.pb.object {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import jp.pixels.pb.ResourceProvider;
	import net.kawa.tween.KTween;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Loading extends Sprite {

		private var areaW_:Number;
		private var areaH_:Number;
		private var back_:Sprite;
		private var image_:Sprite;
		private var showing_:Boolean;
		
		public function Loading(areaW:Number, areaH:Number, withShowing:Boolean=false) {
			mouseChildren = false;
			mouseEnabled = false;
			
			areaW_ = areaW;
			areaH_ = areaH;
			
			back_ = createBg(areaW_, areaH_);
			back_.visible = false;
			addChild(back_);
			
			image_ = createImage();
			image_.x = back_.width / 2;
			image_.y = back_.height / 2;
			back_.addChild(image_);
			
			if (withShowing) {
				show();
			}
		}
		
		public function show():void {
			if (showing_) {
				return;
			}
			
			showing_ = true;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			KTween.fromTo(back_, 1, { alpha:0 }, { alpha:1 } );
			back_.visible = true;
		}
		
		public function hidden():void {
			if (!showing_) {
				return;
			}
			
			showing_ = false;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			KTween.fromTo(back_, 1, { alpha:1 }, { alpha:0 } );
			back_.visible = false;
		}
		
		private function createBg(areaW:Number, areaH:Number):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x000000, 1);
			sp.graphics.drawRect(0, 0, areaW, areaH);
			sp.graphics.endFill();
			return sp;
		}
		
		private function createImage():Sprite {
			var image:Bitmap = ResourceProvider.getImage(ResourceProvider.IMAGE_LOAD_CIRCLE);
			image.scaleX = 0.25;
			image.scaleY = 0.25;
			image.x = -image.width / 2;
			image.y = -image.height / 2;
			
			var sp:Sprite = new Sprite();
			sp.addChild(image);

			return sp;
		}
		
		private function onEnterFrame(e:Event):void {
			image_.rotation += 12;
		}
	}
}