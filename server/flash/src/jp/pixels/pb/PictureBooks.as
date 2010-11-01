package jp.pixels.pb
{
	import flash.display.Sprite;
	import flash.events.Event;
	import jp.pixels.pb.panels.ControlPanel;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class PictureBooks extends Sprite {
		
		private var control_:ControlPanel;
		
		public function PictureBooks():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			control_ = new ControlPanel();
			control_.x = 0;
			control_.y = 0;
			addChild(control_);
		}
	}
}
