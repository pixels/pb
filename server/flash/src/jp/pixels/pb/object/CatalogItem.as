package jp.pixels.pb.object 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import jp.pixels.pb.Util;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class CatalogItem extends Sprite {
		
		public static const MODE_NORMAL:String = "MODE_NORMAL";
		public static const MODE_SELECT:String = "MODE_SELECT";
		public static const MODE_MOVE:String = "MODE_MOVE";
		
		private const TICKNESS:Number = 4;

		private var size_:Number;
		private var image_:Sprite;
		private var mode_:String = "";
		private var index_:int;
		private var ellipse_:Number;
		private var background_:Sprite;
		
		public function get mode():String { return mode_; }
		public function get index():int { return index_; }
		
		public function CatalogItem(size:Number, bitmap:Bitmap, index:int, ellipse:Number=0) {
			size_ = size;
			index_ = index;
			ellipse_ = ellipse;
			
			background_ = new Sprite();
			addChild(background_);
			
			image_ = createImage(size, bitmap);
			image_.x = size / 2 - image_.width / 2;
			image_.y = size / 2 - image_.height / 2;
			image_.mouseEnabled = false;
			image_.mouseChildren = false;
			addChild(image_);
			
			
			setMode(MODE_NORMAL);
		}
		
		public function setIndex(index:int):void {
			index_ = index;
		}

		public function setMode(mode:String):void {
			if (mode_ == mode) {
				return;
			}
			
			mode_ = mode;

			if (mode_ == MODE_NORMAL) {
				image_.visible = true;
				setupRect(background_, size_, 0xbfbfbf, 1, ellipse_);
				setChildIndex(background_, 0);
			}
			else if (mode_ == MODE_SELECT) {
				image_.visible = true;
				setupRect(background_, size_, 0xbfbfdf, 0.5, ellipse_);
				setChildIndex(image_, 0);
			}
			else if (mode_ == MODE_MOVE) {
				image_.visible = false;
				setupRectline(background_, size_, TICKNESS, 0xbfbfbf, ellipse_);
			}
		}
		
		private function createImage(size:Number, bitmap:Bitmap):Sprite {
			var imgSize:Number = size - (TICKNESS * 2);
			var rate:Number = Util.resize(bitmap.width, bitmap.height, imgSize, imgSize);
			var mat:Matrix = new Matrix();
			mat.scale(rate, rate);
			var bd:BitmapData = new BitmapData(bitmap.width * rate, bitmap.height * rate, true, 0x00ffffff);
			bd.draw(bitmap, mat);
			var sp:Sprite = new Sprite();
			sp.graphics.beginBitmapFill(bd);
			sp.graphics.drawRect(0, 0, bd.width, bd.height);
			sp.graphics.endFill();
			
			return sp;
		}
		
		private function setupRect(sp:Sprite, size:Number, color:uint, alpha:Number, ellipse:Number):void {
			sp.graphics.clear();
			sp.graphics.beginFill(color, alpha);
			sp.graphics.drawRoundRect(0, 0, size, size, ellipse);
			sp.graphics.endFill();
		}
		
		private function setupRectline(sp:Sprite, size:Number, tickness:Number, color:uint, ellipse:Number):void {
			var td2:Number = tickness / 2;
			sp.graphics.clear();
			sp.graphics.lineStyle(tickness, color, 1, true);
			sp.graphics.beginFill(0, 0);
			sp.graphics.drawRoundRect(td2, td2, size - tickness, size - tickness, ellipse);
			sp.graphics.endFill();
		}
	}
}