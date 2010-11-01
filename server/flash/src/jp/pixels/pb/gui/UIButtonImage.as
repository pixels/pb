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
	public class UIButtonImage extends Sprite {
		private var MARGIN_W:Number = 8;
		private var ICON_MARGIN:Number = 2;
		
		protected var areaW_:Number;
		protected var areaH_:Number;
		protected var text_:String;
		protected var textColor_:uint;
		protected var color_:uint;
		protected var icon_:Sprite;
		protected var textTF_:TextField;
		
		public function get textColor():uint { return textColor_; }
		public function get color():uint { return color_; }

		public function UIButtonImage(areaW:Number, areaH:Number, bitmap:Bitmap, text:String, textColor:uint=0xffffff, color:uint=0x666666) {
			
			buttonMode = true;
			useHandCursor = true;
			
			areaW_ = areaW;
			areaH_ = areaH;
			text_ = text;
			textColor_ = textColor;
			color_ = color;
			
			setupBackground(color_, areaW_, areaH_);
			setup(bitmap, text, textColor);
		}
		
		private function setup(bitmap:Bitmap, text:String, textColor:uint):void {
			setImage(bitmap);
			setText(text, textColor);
		}
		
		public function setImage(bitmap:Bitmap):void {
			if (icon_) {
				removeChild(icon_);
				icon_ = null;
			}
			
			if (bitmap) {
				icon_ = createIcon(bitmap, areaW_, areaH_ - (ICON_MARGIN * 2));
				icon_.y = height / 2 - icon_.height / 2;
				icon_.x = MARGIN_W;
				addChild(icon_);
			}
			else {
				setText(text_, textColor_);
			}
		}
		
		public function setText(text:String, textColor:uint):void {
			if (textTF_) {
				removeChild(textTF_);
				textTF_ = null;
			}
			
			if (!text) {
				text = "";
			}
			
			textTF_ = createTextField(text, textColor);
			if (icon_) {
				var textAreaW:Number = areaW_ - (areaH_ + (MARGIN_W * 2));
				textTF_.x = textAreaW - textTF_.textWidth / 2;
			}
			else {
				textTF_.x = areaW_ / 2 - textTF_.textWidth / 2;
			}
			textTF_.y = height / 2 - textTF_.textHeight / 2 - 2;
			addChild(textTF_);
		}

		protected function setupBackground(color:uint, areaW:Number, areaH:Number):void {
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xffffff, color, color, 0xffffff];
			var alphas:Array = [1, 1, 1, 1];
			var ratios:Array = [0x00, 0x66, 0xcc, 0xff];
			var mat:Matrix = new Matrix();
			mat.createGradientBox(areaW, areaH, Math.PI * 0.5, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;			
			
			graphics.clear();
			graphics.lineStyle(2, color);
			graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
			graphics.drawRoundRect(1, 1, areaW - 2, areaH - 2, (areaH / 4));
			graphics.endFill();
		}
		
		private function createIcon(bitmap:Bitmap, areaW:Number, areaH:Number):Sprite {
			var rate:Number = Util.resize(bitmap.width, bitmap.height, areaH, areaH);
			var sp:Sprite = new Sprite();
			if (rate < 1) {
				sp.scaleX = rate;
				sp.scaleY = rate;
			}
			sp.addChild(bitmap);
			return sp;
		}
		
		private function createTextField(text:String, textColor:uint):TextField {
			
			var format:TextFormat = new TextFormat();
			format.bold = true;
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = format;
			tf.text = text;
			tf.width = tf.textWidth + 8;
			tf.height = tf.textHeight + 4;
			tf.mouseEnabled = false;
			tf.selectable = false;
			tf.textColor = textColor;
			
			return tf;
		}
	}
}