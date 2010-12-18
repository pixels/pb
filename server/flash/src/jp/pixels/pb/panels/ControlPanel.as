package jp.pixels.pb.panels {
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import jp.pixels.pb.Configure;
	import jp.pixels.pb.net.ConnectionEvent;
	import jp.pixels.pb.net.Red5Event;
	import jp.pixels.pb.net.SimpleConnection;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.ServerCommunicator;
	import jp.pixels.pb.Store;
	import jp.pixels.pb.Util;
	import jp.sionnet.leaflip.Bookflip;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ControlPanel extends Sprite {
		private const VOICE_SERVER:String = "rtmp://good-pb.com/myapp";
		private const ARROW_MARGIN_BOTTOM:Number = 128;
		private const PANEL_Y:Number = 64;
		private const PANEL_W:Number = 246;
		private const PANEL_H:Number = 426;
		
		private var directory_:String = "pbweb";
		private var store_:Store;
		private var upload_:Sprite;
		private var uploadPanel_:UploadPanel;
		private var catalogPanel_:CatalogPanel2;
		private var pubBtn_:Sprite;
		private var trashButton_:Sprite;
		private var previewPanel_:PreviewPanel;
		private var server_:ServerCommunicator;
		private var conn_:SimpleConnection;
		private var bind_:int = Bookflip.BIND_LEFT;
		
		private var debugTF_:TextField;
		
		public function ControlPanel() {
			
			store_ = new Store(Configure.PAGE_W, Configure.PAGE_H);
			store_.addEventListener(PBEvent.STORE_LOADED, onStoreLoaded);
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, Configure.CONTROL_W, Configure.CONTROL_H);
			graphics.endFill();

			createPreviePanel();
			createControlPanel();
			
			if (Configure.DEBUG) {
				debugTF_ = createDebug(Configure.AREA_W, 20);
				debugTF_.x = 0;
				debugTF_.y = Configure.CONTROL_H - debugTF_.height;
				addChild(debugTF_);
			}
			
			registExternalInterface();
			registNetConnection();
		}
		
		private function createPreviePanel():void {
			var previewW:Number = Configure.PREVIEW_W / 2;
			var previewH:Number = Configure.PREVIEW_H;
			previewPanel_ = new PreviewPanel(previewW, previewH);
			previewPanel_.x = 0;
			previewPanel_.y = 0;
			addChild(previewPanel_);
		}
		
		private function createControlPanel():void {
			var ctrlPanel:Sprite = new Sprite();
			ctrlPanel.graphics.beginFill(Configure.BACK_COLOR);
			ctrlPanel.graphics.drawRect(0, 0, Configure.CONTROL_W, Configure.CONTROL_H);
			ctrlPanel.graphics.endFill();
			ctrlPanel.x = Configure.PREVIEW_W;
			addChild(ctrlPanel);
			
			upload_ = createButton(246, 45, "parts/button_add.png");
			upload_.x = Configure.CONTROL_W - upload_.width;
			upload_.y = 8;
			upload_.addEventListener(MouseEvent.CLICK, onUploadClick);
			ctrlPanel.addChild(upload_);
			
			uploadPanel_ = new UploadPanel(PANEL_W, PANEL_H, 0.5, directory_);
			uploadPanel_.x = Configure.CONTROL_W - uploadPanel_.width;
			uploadPanel_.y = upload_.y + upload_.height + 6;
			uploadPanel_.addEventListener(PBEvent.UPLOAD_START_OPEN, onUploadStartOpen);
			uploadPanel_.addEventListener(PBEvent.UPLOAD_COMPLETE_CLOSE, onUploadCompleteClose);
			ctrlPanel.addChild(uploadPanel_);
			
			catalogPanel_ = new CatalogPanel2(PANEL_W, PANEL_H, 0.5);
			catalogPanel_.x = Configure.CONTROL_W - catalogPanel_.width;
			catalogPanel_.y = uploadPanel_.y;
			catalogPanel_.addEventListener(PBEvent.CATALOG_SWAP, onCatalogSwap);
			catalogPanel_.addEventListener(PBEvent.CATALOG_ARROW, onArrowClick);
			ctrlPanel.addChild(catalogPanel_);
			
			pubBtn_ = createButton(195, 45, "parts/button_publish.png");
			pubBtn_.x = uploadPanel_.x;
			pubBtn_.y = uploadPanel_.y + PANEL_H + 6;
			pubBtn_.addEventListener(MouseEvent.CLICK, onPublishClick);
			ctrlPanel.addChild(pubBtn_);
			
			trashButton_ = createButton(45, 45, "parts/button_trash.png");
			trashButton_.addEventListener(MouseEvent.CLICK, onTrashClick);
			trashButton_.x = pubBtn_.x + pubBtn_.width + 6;
			trashButton_.y = pubBtn_.y;
			ctrlPanel.addChild(trashButton_);
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
		
		private function createButton(w:Number, h:Number, url:String):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0, 0);
			sp.graphics.drawRect(0, 0, w, h);
			sp.graphics.endFill();
			
			var l:Loader = new Loader();
			l.load(new URLRequest(url));
			sp.addChild(l);
			
			return sp;
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
		
		private function registNetConnection():void {
			conn_ = new SimpleConnection();
			conn_.addEventListener(ConnectionEvent.CONNECTED, onConnected);
			conn_.addEventListener(Red5Event.FROM_RED5, onFromRed5);
			conn_.connect(VOICE_SERVER);
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
		
		private function onConnected(e:ConnectionEvent):void {
			trace ("onConnected");
			
			conn_.jInvoke("GetCurrent");
		}
		
		private function onFromRed5(e:Red5Event):void {
			var key:String = e.info["key"];
			var value:Object = e.info["value"];
			
			trace ("onResponse key: " + key + " value: " + value);
		}
		
		private function onStoreLoaded(e:PBEvent):void {
			onArrowClick(new PBEvent(PBEvent.CATALOG_ARROW, { bind:Bookflip.BIND_RIGHT } ));
		}
		
		private function onUploadClick(e:MouseEvent):void {
			uploadPanel_.select(store_.count);
		}
		
		private function onArrowClick(e:PBEvent):void {
			bind_ = e.info["bind"];
			var bind:int = bind_ ? Bookflip.BIND_LEFT : Bookflip.BIND_RIGHT;
			catalogPanel_.update(store_, bind);
			previewPanel_.initBookFlip(store_, bind);
		}
		
		private function onUploadStartOpen(e:PBEvent):void {
			catalogPanel_.close();
		}
		
		private function onUploadCompleteClose(e:PBEvent):void {
			catalogPanel_.open();
			var count:int = e.info["count"];
			if (count > 0) {
				var url:String = Configure.UPLOAD_URL + "/" + directory_;
				store_.setup(url, count, true);
			}
		}
		
		private function onCatalogSwap(e:PBEvent):void {
			store_.deployPages(e.info["start"], e.info["now"]);
			previewPanel_.initBookFlip(store_, (bind_ ? Bookflip.BIND_LEFT : Bookflip.BIND_RIGHT));
		}
		
		private function onPublishClick(e:MouseEvent):void {
			externalInterfaceCall("publish", null);
		}
		
		private function onTrashClick(e:MouseEvent):void {
			var array:Array = catalogPanel_.trash();
			var index:int;
			var rmList:Array = new Array();
			
			for each(index in array) {
				var filename:String = Util.fillZero((index + 1), 4) + "." + Configure.EXTENSION;
				rmList.push(filename);
				store_.removeAtIndex(index);
			}
			var bind:int = bind_ ? Bookflip.BIND_LEFT : Bookflip.BIND_RIGHT;
			catalogPanel_.update(store_, bind);
			previewPanel_.initBookFlip(store_, bind);
			
			server_ = new ServerCommunicator(directory_);
			server_.addEventListener(PBEvent.REARRANGE_FINISHIED, onServerRearrangeFinished);
			server_.rm(rmList);
		}
		
		private function onServerRearrangeFinished(e:PBEvent):void {
			debug ("onServerRearrangeFinished");
		}
	}
}