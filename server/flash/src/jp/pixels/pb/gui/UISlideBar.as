package jp.pixels.pb.gui {
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class UISlideBar extends Sprite {
		
		private var BAR_H:Number = 32;
		private var BAR_HD2:Number = BAR_H / 2;
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var base_:Sprite;
		private var bar_:Sprite;
		private var rate_:Number;
		
		public function get rate():Number { return rate_; }
		public function get barY():Number { return bar_.y; }
		
		public function UISlideBar()  {
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		public function setup(areaW:Number, areaH:Number):void {
			
			areaW_ = areaW;
			areaH_ = areaH;
			
			graphics.clear();
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, areaW, areaH);
			graphics.endFill();
			
			if (base_) {
				removeChild(base_);
			}
			base_ = createBase(areaW, areaH);
			addChild(base_);
			
			if (bar_) {
				removeChild(bar_);
			}
			bar_ = new Sprite();
			bar_ = createBar(0, -BAR_HD2, width, BAR_H, 8);
			bar_.y = BAR_HD2;
			addChild(bar_);
		}
		
		public function setBarY(barY:Number):void {
			calcAndNotificate(barY);
		}
		
		private function createBase(areaW:Number, areaH:Number):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0xcccccc);
			sp.graphics.drawRect(0, 0, areaW, areaH);
			sp.graphics.endFill();
			return sp;
		}
		
		private function createBar(ox:Number, oy:Number, areaW:Number, areaH:Number, ellipse:Number=0):Sprite {
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0x7f7f7f, 0x1f1f1f, 0x7f7f7f];
			var alphas:Array = [1, 1, 1];
			var ratios:Array = [0x00, 0x88, 0xFF];
			var mat:Matrix = new Matrix();
			mat.createGradientBox(areaW, areaH, 0, ox, oy);
			var spreadMethod:String = SpreadMethod.PAD;
			
			var sp:Sprite = new Sprite();
			sp.mouseChildren = false;
			sp.mouseEnabled = false;
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
			sp.graphics.drawRoundRect(ox, oy, areaW, areaH, ellipse);
			sp.graphics.endFill();
			return sp;
		}
		
		private function calcAndNotificate(localY:Number):void {
			bar_.y = localY;
			if (bar_.y < BAR_HD2) {
				bar_.y = BAR_HD2;
			}
			if (bar_.y > (areaH_  - bar_.height + BAR_HD2)) {
				bar_.y = (areaH_  - bar_.height + BAR_HD2);
			}
			
			rate_ = (bar_.y - BAR_HD2) / (areaH_ - BAR_H);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onMouseDown(e:MouseEvent):void {
			calcAndNotificate(e.localY);
		}
		
		private function onMouseMove(e:MouseEvent):void {
			if (e.buttonDown) {
				calcAndNotificate(e.localY);
			}
		}
	}
}