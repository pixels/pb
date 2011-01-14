package jp.pixels.pb.panels 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import jp.pixels.pb.gui.UIButton;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.ResourceProvider;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class PreviewControlPanel extends Sprite {
		private var pageW_:Number;
		private var pageH_:Number;
		private var controller_:Sprite;
		private var leftButton_:Sprite;
		private var rightButton_:Sprite;
		private var micButton_:Sprite;
		private var micStopButton_:Sprite;
		private var playButton_:Sprite;
		private var playStopButton_:Sprite;
		
		public function PreviewControlPanel(pageW:Number, pageH:Number) {
			pageW_ = pageW;
			pageH_ = pageH;
			controller_ = createController(pageW_, pageH_);
			addChild(controller_);
			
			var btn:Sprite;
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_LEFT));
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new PBEvent(PBEvent.PREVIEW_LEFT)); } );
			btn.x = 0;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			leftButton_ = btn;
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_MIC));
			btn.addEventListener(MouseEvent.CLICK, onMicButton);
			btn.x = controller_.width / 2 - btn.width / 2 - 32;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			micButton_ = btn;
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_STOP));
			btn.addEventListener(MouseEvent.CLICK, onMicStopButton);
			btn.x = controller_.width / 2 - btn.width / 2 - 32;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			micStopButton_ = btn;
			micStopButton_.visible = false;
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_PLAY));
			btn.addEventListener(MouseEvent.CLICK, onPlayButton);
			btn.x = controller_.width / 2 - btn.width / 2 + 32;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			playButton_ = btn;
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_STOP));
			btn.addEventListener(MouseEvent.CLICK, onPlayStopButton);
			btn.x = controller_.width / 2 - btn.width / 2 + 32;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			playStopButton_ = btn;
			playStopButton_.visible = false;
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_RIGHT));
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new PBEvent(PBEvent.PREVIEW_RIGHT)); } );
			btn.x = controller_.width - btn.width;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			rightButton_ = btn;
		}
		
		private function createController(pageW:Number, pageH:Number):Sprite {
			
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(1, 0xafafaf, 0.5);
			sp.graphics.beginFill(0x0f0f0f, 0.5);
			sp.graphics.drawRect(0, 0, pageW, pageH);
			sp.graphics.endFill();
			
			return sp;
		}
		
		public function stopPlayingVoice():void {
			visibleControl(true, true, false, true, false, true);
		}
		
		private function createButton(image:Bitmap):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0, 0);
			sp.graphics.drawRect(0, 0, image.width, image.height);
			sp.graphics.endFill();
			sp.buttonMode = true;
			sp.useHandCursor = true;
			sp.addChild(image);
			
			return sp;
		}
		
		private function visibleControl(left:Boolean, mic:Boolean, micStop:Boolean, play:Boolean, playStop:Boolean, right:Boolean):void {
			leftButton_.visible = left;
			micButton_.visible = mic;
			micStopButton_.visible = micStop;
			playButton_.visible = play;
			playStopButton_.visible = playStop;
			rightButton_.visible = right;
		}
		
		private function onMicButton(e:MouseEvent):void {
			visibleControl(false, false, true, false, false, false);
			dispatchEvent(new PBEvent(PBEvent.PREVIEW_RECORD_START));
		}
		
		private function onMicStopButton(e:MouseEvent):void {
			visibleControl(true, true, false, true, false, true);
			dispatchEvent(new PBEvent(PBEvent.PREVIEW_RECORD_STOP));
		}
		
		private function onPlayButton(e:MouseEvent):void {
			visibleControl(false, false, false, false, true, false);
			dispatchEvent(new PBEvent(PBEvent.PREVIEW_PLAY_START));
		}
		
		private function onPlayStopButton(e:MouseEvent):void {
			stopPlayingVoice();
			dispatchEvent(new PBEvent(PBEvent.PREVIEW_PLAY_STOP));
		}
	}
}