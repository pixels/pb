package jp.pixels.pb.object 
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import jp.pixels.pb.gui.UIButton;
	import jp.pixels.pb.ResourceProvider;
	import net.kawa.tween.KTween;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ArrowButton extends Sprite {
		
		private var left_:Boolean = false;
		private var l_:Loader;
		private var r_:Loader;
		
		public function get left():Boolean { return left_; }
		
		public function ArrowButton() {
			
			buttonMode = true;
			mouseChildren = false;
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 228, 35);
			graphics.endFill();
			
			l_ = new Loader();
			l_.load(new URLRequest("parts/direction_left.png"));
			l_.visible = false;
			addChild(l_);
			
			r_ = new Loader();
			r_.load(new URLRequest("parts/direction_right.png"));
			r_.visible = true;
			addChild(r_);
			
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			left_ = !left_;
			if (left_) {
				l_.visible = true;
				r_.visible = false;
			}
			else {
				l_.visible = false;
				r_.visible = true;
			}
		}
	}
}