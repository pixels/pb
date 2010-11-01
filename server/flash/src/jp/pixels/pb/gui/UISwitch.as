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
	public class UISwitch extends UIButtonImage {
		
		private var highColor_:uint;
		private var selected_:Boolean;
		
		public function get highColor():uint { return highColor_; }

		public function UISwitch(areaW:Number, areaH:Number, bitmap:Bitmap, text:String, textColor:uint = 0xffffff, color:uint = 0x666666, highColor:uint = 0x888888) {
			super(areaW, areaH, bitmap, text, textColor, color);
			
			highColor_ = highColor;
			
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			selected_ = !selected_;
			setupBackground(selected_ ? highColor_ : color_, areaW_, areaH_);
		}
	}
}