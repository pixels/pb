package jp.pixels.pb.object 
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import jp.pixels.pb.gui.UIButton;
	import jp.pixels.pb.ResourceProvider;
	import net.kawa.tween.KTween;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ArrowButton extends Sprite {
		
		private const LEFT_TEXT:String = "左送り"
		private const RIGHT_TEXT:String = "右送り"
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var button_:UIButton;
		private var left_:Boolean;
		
		public function get left():Boolean { return left_; }
		
		public function ArrowButton(areaW:Number, areaH:Number) {
			
			areaW_ = areaW;
			areaH_ = areaH;
			buttonMode = true;
			mouseChildren = false;
			
			button_ = new UIButton(areaW_, areaH_, ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_LEFT), LEFT_TEXT);
			addChild(button_);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function onClick(e:MouseEvent):void {
			left_ = !left_;
		}
		
		private function onUp(e:MouseEvent):void {
			button_.setImage(ResourceProvider.getImage(left ? ResourceProvider.IMAGE_ICON_ARROW_LEFT : ResourceProvider.IMAGE_ICON_ARROW_RIGHT));
			button_.setText(left ? LEFT_TEXT : RIGHT_TEXT, button_.textColor);
		}
	}
}