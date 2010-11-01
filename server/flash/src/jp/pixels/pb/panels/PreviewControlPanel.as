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
		
		public function PreviewControlPanel(pageW:Number, pageH:Number) {
			pageW_ = pageW;
			pageH_ = pageH;
			controller_ = createController(pageW_, pageH_);
			addChild(controller_);
			
			var btn:Sprite;
			btn = createButton(true);
			btn.x = 0;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new PBEvent(PBEvent.PREVIEW_LEFT)); } );
			controller_.addChild(btn);
			
			btn = createButton(false);
			btn.x = controller_.width - btn.width;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new PBEvent(PBEvent.PREVIEW_RIGHT)); } );
			controller_.addChild(btn);
			
			var pubBtn:UIButton = new UIButton(480, 48, null, "パブリッシュ");
			pubBtn.x = controller_.width / 2 - pubBtn.width / 2;
			pubBtn.y = controller_.height / 2 - pubBtn.height / 2;
			pubBtn.addEventListener(MouseEvent.CLICK, onPubButtonClick);
			controller_.addChild(pubBtn);
		}
		
		private function createController(pageW:Number, pageH:Number):Sprite {
			
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x888888, 0.5);
			sp.graphics.drawRoundRect(0, 0, pageW, 64, 8);
			sp.graphics.endFill();
			
			return sp;
		}
		
		private function createButton(left:Boolean):Sprite {
			var image:Bitmap;
			if (left) {
				image = ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_LEFT);
			}
			else {
				image = ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_RIGHT);
			}
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0, 0);
			sp.graphics.drawRect(0, 0, image.width, image.height);
			sp.graphics.endFill();
			sp.buttonMode = true;
			sp.useHandCursor = true;
			sp.addChild(image);
			
			return sp;
		}
		
		private function onPubButtonClick(e:MouseEvent):void {
			dispatchEvent(new PBEvent(PBEvent.PUBLISH_CLICK, null, true));
		}
	}
}