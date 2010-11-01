package jp.pixels.pb.panels {
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import jp.pixels.pb.Configure;
	import jp.pixels.pb.gui.UIButton;
	import jp.pixels.pb.object.ArrowButton;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.ResourceProvider;
	import jp.pixels.pb.ServerCommunicator;
	import jp.pixels.pb.Store;
	import jp.pixels.pb.Util;
	import jp.sionnet.leaflip.Bookflip;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ControlPanel extends Sprite {
		
		private const ARROW_MARGIN_BOTTOM:Number = 56;
		private const PANEL_Y:Number = 64;
		private const PANEL_W:Number = 240;
		private const PANEL_H:Number = 520;
		
		private var directory_:String = "pbweb";
		private var store_:Store;
		private var upload_:UIButton;
		private var arrow_:ArrowButton;
		private var uploadPanel_:UploadPanel;
		private var catalogPanel_:CatalogPanel;
		private var previewPanel_:PreviewPanel;
		private var server_:ServerCommunicator;
		
		private var debugTF_:TextField;
		
		public function ControlPanel() {
			
			var previewW:Number = Configure.PREVIEW_W / 2;
			var previewH:Number = Configure.PREVIEW_H;
			
			store_ = new Store(Configure.PAGE_W, Configure.PAGE_H);
			store_.addEventListener(PBEvent.STORE_LOADED, onStoreLoaded);
			
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, Configure.CONTROL_W, Configure.CONTROL_H);
			graphics.endFill();
			
			upload_ = new UIButton(128, 32, ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_UPLOAD), "ページを追加");
			upload_.x = Configure.CONTROL_W / 2 - upload_.width / 2;
			upload_.y = 16;
			upload_.addEventListener(MouseEvent.CLICK, onUploadClick);
			addChild(upload_);
			
			arrow_ = new ArrowButton(PANEL_W, 96);
			arrow_.x = (width / 2) - (arrow_.width / 2);
			arrow_.y = height - arrow_.height - ARROW_MARGIN_BOTTOM;
			arrow_.addEventListener(MouseEvent.CLICK, onArrowClick);
			addChild(arrow_);
			
			uploadPanel_ = new UploadPanel(PANEL_W, PANEL_H, 0.5, directory_);
			uploadPanel_.x = (width / 2) - (uploadPanel_.width / 2);
			uploadPanel_.y = PANEL_Y;
			uploadPanel_.addEventListener(PBEvent.UPLOAD_START_OPEN, onUploadStartOpen);
			uploadPanel_.addEventListener(PBEvent.UPLOAD_COMPLETE_CLOSE, onUploadCompleteClose);
			addChild(uploadPanel_);
			
			catalogPanel_ = new CatalogPanel(PANEL_W, PANEL_H, 0.5);
			catalogPanel_.x = (width / 2) - (catalogPanel_.width / 2);
			catalogPanel_.y = PANEL_Y;
			catalogPanel_.addEventListener(PBEvent.CATALOG_SWAP, onCatalogSwap);
			catalogPanel_.addEventListener(PBEvent.CATALOG_TRASH, onCatalogTrash);
			addChild(catalogPanel_);
			
			previewPanel_ = new PreviewPanel(previewW, previewH);
			previewPanel_.x = Configure.CONTROL_W;
			previewPanel_.y = 0;
			previewPanel_.addEventListener(PBEvent.PUBLISH_CLICK, onPublishClick);
			addChild(previewPanel_);
			
			var line:Sprite = createLine(2, previewH - 32);
			line.x = previewPanel_.x + 4;
			line.y = 0;
			addChild(line);
			
			if (Configure.DEBUG) {
				debugTF_ = createDebug(Configure.AREA_W, 20);
				debugTF_.x = 0;
				debugTF_.y = Configure.CONTROL_H - debugTF_.height;
				addChild(debugTF_);
			}
			
			registExternalInterface();
		}
		
		private function createDebug(w:Number, h:Number):TextField {
			var tf:TextField = new TextField();
			tf.mouseEnabled = false;
			tf.selectable = false;
			tf.background = true;
			tf.backgroundColor = 0xffffff;
			tf.textColor
			tf.width = w;
			tf.height = h;
			tf.text = "DEBUG MODE";
			
			return tf;
		}
		
		private function debug(text:String):void {
			if (debugTF_) {
				debugTF_.text = text;
			}
		}
		
		private function createLine(w:Number, h:Number):Sprite {
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0x000000, 0xaaaaaa, 0xaaaaaa, 0x000000];
			var alphas:Array = [1, 1, 1, 1];
			var ratios:Array = [0x00, 0x22, 0xdd, 0xff];
			var mat:Matrix = new Matrix();
			mat.createGradientBox(w, h, Math.PI * 0.5, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;			
			
			var sp:Sprite = new Sprite();
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
			sp.graphics.drawRect(0, 16, w, h);
			sp.graphics.endFill();
			return sp;
		}
		
		private function externalInterfaceCall(key:String, value:Object):void {
			if (ExternalInterface.available) {
				ExternalInterface.call("jsInvoke", { key:key, value:value } );
			}
		}
		
		private function registExternalInterface():void {
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("flInvoke", onCallFromJS);
			}
		}
		
		private function onCallFromJS(e:Object):void {
			
			var key:String = e["key"];
			
			if (Configure.DEBUG) {
				//var val:String = "";
				//for (var vKey:String in e["value"]) {
					//val += " " + vKey + " " + e["value"][vKey];
				//}
				debug("onCallFromJS key: " + key + " value: " + e["value"]);
			}
			
			if (key == "userID") {
				var userID:String = e["value"];
				if (userID && userID != "") {
					directory_ = userID;
					uploadPanel_.setDirectory(directory_);
				}
			}
		}
		
		private function onStoreLoaded(e:PBEvent):void {
			onArrowClick();
		}
		
		private function onUploadClick(e:MouseEvent):void {
			uploadPanel_.select(store_.count);
		}
		
		private function onArrowClick(e:MouseEvent = null):void {
			var bind:int = arrow_.left ? Bookflip.BIND_LEFT : Bookflip.BIND_RIGHT;
			catalogPanel_.update(store_, bind);
			previewPanel_.initBookFlip(store_, bind);
		}
		
		private function onUploadStartOpen(e:PBEvent):void {
			catalogPanel_.close();
		}
		
		private function onUploadCompleteClose(e:PBEvent):void {
			catalogPanel_.open();
			var count:int = e.info["count"];
			var url:String = Configure.UPLOAD_URL + "/" + directory_;
			store_.setup(url, count, true);
		}
		
		private function onCatalogSwap(e:PBEvent):void {
			store_.deployPages(e.info["start"], e.info["now"]);
			previewPanel_.initBookFlip(store_, (arrow_.left ? Bookflip.BIND_LEFT : Bookflip.BIND_RIGHT));
		}
		
		private function onCatalogTrash(e:PBEvent):void {
			var array:Array = e.info["list"];
			var index:int;
			var rmList:Array = new Array();
			
			for each(index in array) {
				var filename:String = Util.fillZero((index + 1), 4) + "." + Configure.EXTENSION;
				rmList.push(filename);
				store_.removeAtIndex(index);
			}
			var bind:int = arrow_.left ? Bookflip.BIND_LEFT : Bookflip.BIND_RIGHT;
			catalogPanel_.update(store_, bind);
			previewPanel_.initBookFlip(store_, bind);
			
			server_ = new ServerCommunicator(directory_);
			server_.addEventListener(PBEvent.REARRANGE_FINISHIED, onServerRearrangeFinished);
			server_.rm(rmList);
		}
		
		private function onPublishClick(e:PBEvent):void {
			externalInterfaceCall("publish", null);
		}
		
		private function onServerRearrangeFinished(e:PBEvent):void {
			debug ("onServerRearrangeFinished");
		}
	}
}