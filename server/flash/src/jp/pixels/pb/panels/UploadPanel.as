package jp.pixels.pb.panels {
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.engine.JustificationStyle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import jp.pixels.pb.Configure;
	import jp.pixels.pb.gui.UIButton;
	import jp.pixels.pb.gui.UISlideBar;
	import jp.pixels.pb.object.Loading;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.Util;
	import net.kawa.tween.KTJob;
	import net.kawa.tween.KTween;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class UploadPanel extends Sprite {
		
		private const LIST_MARGIN:Number = 8;
		private const SLIDER_W:Number = 18;
		private const BUTTONS_W:Number = 80;
		private const BUTTONS_H:Number = 24;
		private const BUTTONS_MARGIN_TOP:Number = 12;
		private const BUTTONS_MARGIN_SIDE:Number = 0;
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var directory_:String;
		private var fileReferenceList_:FileReferenceList;
		private var waitingList_:Object = new Object();
		private var uploadIndexOffset_:int;
		private var maxCount_:int;
		private var waitingCount_:int;
		private var duretion_:Number = 1;
		private var opend_:Boolean;
		private var back_:Sprite;
		private var loading_:Loading;
		private var slider_:UISlideBar;
		private var listTF_:TextField;
		private var cancelButton_:UIButton;
		private var uploadButton_:UIButton;
		
		public function UploadPanel(areaW:Number, areaH:Number, duretion:Number, directory:String) {
			
			areaW_ = areaW;
			areaH_ = areaH;
			duretion_ = duretion;
			setDirectory(directory);
			
			setupBackground(areaW_, areaH_);
			
			back_ = createBackground(areaW_ - (LIST_MARGIN * 2), areaH_ - LIST_MARGIN -  40);
			back_.x = LIST_MARGIN;
			back_.y = LIST_MARGIN;
			addChild(back_);
			
			listTF_ = createList(back_.width - SLIDER_W, back_.height - 2);
			listTF_.x = 1;
			listTF_.y = 1;
			back_.addChild(listTF_);
			
			slider_ = new UISlideBar();
			slider_.addEventListener(Event.CHANGE, onSliderChange);
			slider_.setup(SLIDER_W, back_.height);
			slider_.x = back_.width - slider_.width;
			back_.addChild(slider_);
			
			loading_ = new Loading(back_.width, back_.height);
			back_.addChild(loading_);
			
			cancelButton_ = new UIButton(BUTTONS_W, BUTTONS_H, null, "キャンセル", 0xffffff, 0x884444, 0xaa6666);
			cancelButton_.addEventListener(MouseEvent.CLICK, onCancelClick);
			cancelButton_.x = back_.x + BUTTONS_MARGIN_SIDE;
			cancelButton_.y = listTF_.y + back_.height + BUTTONS_MARGIN_TOP;
			addChild(cancelButton_);
			
			uploadButton_ = new UIButton(BUTTONS_W, BUTTONS_H, null, "追加", 0xffffff, 0x448844, 0x66aa66);
			uploadButton_.addEventListener(MouseEvent.CLICK, onUploadClick);
			uploadButton_.x = back_.width - uploadButton_.width - BUTTONS_MARGIN_SIDE;
			uploadButton_.y = listTF_.y + back_.height + BUTTONS_MARGIN_TOP;
			addChild(uploadButton_);
			
			scaleY = 0;
		}
		
		public function setDirectory(directory:String):void {
			directory_ = directory;
		}
		
		public function select(uploadIndexOffset:int=0):Boolean {
			if (opend_) {
				return false;
			}
			
			uploadIndexOffset_ = uploadIndexOffset;
			
			if (!fileReferenceList_) {
				fileReferenceList_ = new FileReferenceList();
				fileReferenceList_.addEventListener(Event.SELECT, onSelect);
			}
			fileReferenceList_.browse();
			
			return true;
		}
		
		private function upload():void {
			maxCount_ = fileReferenceList_.fileList.length;
			if (maxCount_ == 0) {
				close();
			}
			else {
				loading_.show();
				waitingCount_ = maxCount_;
				nextUpload();
			}
		}
		
		private function nextUpload():Boolean {
			var index:int = waitingCount_ - 1;
			if (index >= 0) {
				var fr:FileReference = fileReferenceList_.fileList[index];
				var val:URLVariables = new URLVariables();
				val["directory"] = directory_;
				val["filename"] = Util.fillZero(waitingCount_ + uploadIndexOffset_, 4) + "." + Configure.EXTENSION;
				
				var req:URLRequest = new URLRequest(Configure.API_UPLOAD_URL);
				req.method = URLRequestMethod.POST;
				req.data = val;
				
				fr.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteDataOrError);
				fr.addEventListener(IOErrorEvent.IO_ERROR, onUploadCompleteDataOrError);
				fr.upload(req);
				return true;
			}
			
			return false;
		}
		
		private function cancel():void {
			close();
		}
		
		private function close():void {
			loading_.hidden();
			clearList(listTF_);
			var job:KTJob = KTween.fromTo(this, duretion_, { scaleY:1 }, { scaleY:0 } );
			job.addEventListener(Event.COMPLETE, onWindowClosedComplete);
			dispatchEvent(new PBEvent(PBEvent.UPLOAD_START_CLOSE));
		}
		
		private function setupBackground(areaW:Number, areaH:Number):void {
			graphics.beginFill(0x888888);
			graphics.drawRoundRect(0, 0, areaW, areaH, 16);
			graphics.endFill();
		}
		
		private function createBackground(areaW:Number, areaH:Number):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(2, 0x888888);
			sp.graphics.beginFill(0xdddddd);
			sp.graphics.drawRect(0, 0, areaW, areaH);
			sp.graphics.endFill();
			
			return sp;
		}
		
		private function createList(areaW:Number, areaH:Number):TextField {
			var format:TextFormat = new TextFormat();
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = format;
			tf.width = areaW;
			tf.height = areaH;
			tf.multiline = true;
			tf.background = true;
			tf.backgroundColor = 0xffffff;
			tf.selectable = false;
			tf.scrollRect = new Rectangle(0, 0, areaW, areaH);
			
			return tf;
		}
		
		private function addLine(tf:TextField, text:String):void {
			tf.htmlText += text + "<br>";
		}
		
		private function clearList(tf:TextField):void {
			tf.htmlText = "";
		}
		
		private function onSliderChange(e:Event):void {
			var slider:UISlideBar = e.currentTarget as UISlideBar;
			listTF_.scrollV = int((listTF_.maxScrollV + 1) * slider.rate);
		}
		
		private function onCancelClick(e:Event):void {
			cancel();
		}
		
		private function onUploadClick(e:Event):void {
			upload();
		}
		
		private function onSelect(e:Event):void {
			opend_ = true;
			var job:KTJob = KTween.fromTo(this, duretion_, { scaleY:0 }, { scaleY:1 } );
			job.addEventListener(Event.COMPLETE, onWindowOpenedComplete);
			dispatchEvent(new PBEvent(PBEvent.UPLOAD_START_OPEN));
		}
		
		private function onUploadCompleteDataOrError(e:Event):void {
			if (e is IOErrorEvent) {
				log(this, (e as IOErrorEvent).text);
			}
			
			//trace("onUploadCompleteData data: " + e.data);
			var fr:FileReference = e.currentTarget as FileReference;
			fr.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteDataOrError);
			delete waitingList_[fr.name];
			waitingCount_--;
			if (!nextUpload()) {
				close();
			}
		}
		
		private function onWindowOpenedComplete(e:Event):void {
			var job:KTJob = e.currentTarget as KTJob;
			job.removeEventListener(Event.COMPLETE, onWindowOpenedComplete);
			dispatchEvent(new PBEvent(PBEvent.UPLOAD_COMPLETE_OPEN));
			
			clearList(listTF_);
			var frl:FileReferenceList = fileReferenceList_;
			var fr:FileReference;
			for each (fr in frl.fileList) {
				addLine(listTF_, fr.name);
			}
		}
		
		private function onWindowClosedComplete(e:Event):void {
			var job:KTJob = e.currentTarget as KTJob;
			job.removeEventListener(Event.COMPLETE, onWindowClosedComplete);
			dispatchEvent(new PBEvent(PBEvent.UPLOAD_COMPLETE_CLOSE, { count:maxCount_ } ));
			opend_ = false;
		}
	}
}