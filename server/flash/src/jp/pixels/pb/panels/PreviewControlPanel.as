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
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_LEFT));
			btn.x = 0;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new PBEvent(PBEvent.PREVIEW_LEFT)); } );
			controller_.addChild(btn);
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_MIC));
			btn.x = controller_.width / 2 - btn.width / 2 - 32;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_PLAY));
			btn.x = controller_.width / 2 - btn.width / 2 + 32;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			controller_.addChild(btn);
			
			btn = createButton(ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_ARROW_RIGHT));
			btn.x = controller_.width - btn.width;
			btn.y = (controller_.height / 2) - (btn.height / 2);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new PBEvent(PBEvent.PREVIEW_RIGHT)); } );
			controller_.addChild(btn);
		}
		
		private function createController(pageW:Number, pageH:Number):Sprite {
			
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(1, 0xafafaf, 0.5);
			sp.graphics.beginFill(0x0f0f0f, 0.5);
			sp.graphics.drawRect(0, 0, pageW, pageH);
			sp.graphics.endFill();
			
			return sp;
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
	}
}