package jp.pixels.pb.gui {
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import jp.pixels.pb.Util;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class UIButton extends UIButtonImage {
		
		private var highColor_:uint;
		
		public function get highColor():uint { return highColor_; }

		public function UIButton(areaW:Number, areaH:Number, bitmap:Bitmap, text:String, textColor:uint = 0xffffff, color:uint = 0x666666, highColor:uint = 0x888888) {
			super(areaW, areaH, bitmap, text, textColor, color);
			
			highColor_ = highColor;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			setupBackground(highColor_, areaW_, areaH_);
		}
		
		private function onMouseUp(e:MouseEvent):void {
			setupBackground(color_, areaW_, areaH_);
		}
	}
}