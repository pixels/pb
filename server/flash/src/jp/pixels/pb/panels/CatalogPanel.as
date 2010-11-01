package jp.pixels.pb.panels {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.text.engine.JustificationStyle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import jp.pixels.pb.gui.UIButton;
	import jp.pixels.pb.gui.UISlideBar;
	import jp.pixels.pb.gui.UISwitch;
	import jp.pixels.pb.object.CatalogItem;
	import jp.pixels.pb.PBEvent;
	import jp.pixels.pb.ResourceProvider;
	import jp.pixels.pb.Store;
	import net.kawa.tween.KTJob;
	import net.kawa.tween.KTween;
	
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class CatalogPanel extends Sprite {
		
		private const COVER_FRONT_LABEL:String = "表紙";
		private const COVER_BACK_LABEL:String = "背表紙";
		private const LIST_MARGIN:Number = 8;
		private const SLIDER_W:Number = 24;
		private const BUTTONS_W:Number = 80;
		private const BUTTONS_H:Number = 24;
		private const BUTTONS_MARGIN_TOP:Number = 12;
		private const BUTTONS_MARGIN_SIDE:Number = 0;
		private const BUTTON_AREA_H:Number = 40;
		private const IMAGE_MARGIN_W:Number = 16;
		private const IMAGE_MARGIN_H:Number = 16;
		private const DRAGMODE_NONE:int = 0;
		private const DRAGMODE_DOWN:int = 1;
		private const DRAGMODE_MOVE:int = 2;
		private const CATALOG_ELLIPSE:Number = 16;
		private const CATALOG_SCROLL_RANGE:Number = 24;
		private const CATALOG_SCROLL_SPEED:Number = 2;
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var duretion_:Number = 1;
		private var bind_:int;
		private var count_:int;
		private var back_:Sprite;
		private var slider_:UISlideBar;
		private var catalog_:Sprite;
		private var mask_:Sprite;
		private var trashButton_:UIButton;
		private var uploadButton_:UIButton;
		private var lastY_:Number;
		private var dragMode_:int;
		private var selectedBtn_:CatalogItem;
		private var selectedList_:Object = new Object();
		private var catalogW_:Number;
		private var catalogItemList_:Array = new Array();
		private var catalogItemSize_:Number;
		private var movingRect_:Sprite;
		private var movingPoint_:Point = new Point();
		private var movingIndex_:int;
		private var movingSkip_:Boolean;
		private var scrollLocalY_:Number;
		private var labelList_:Object = new Object();
		
		public function CatalogPanel(areaW:Number, areaH:Number, duretion:Number) {
			
			areaW_ = areaW;
			areaH_ = areaH;
			duretion_ = duretion;
			
			var ellipse:Number = 16;
			
			setupRect(this, areaW_, areaH_, 0x7f7f7f, 1, 0, 0, ellipse);
			
			var backW:Number = areaW_ - (LIST_MARGIN * 2);
			var backH:Number = areaH_ - LIST_MARGIN - BUTTON_AREA_H;
			mask_ = createRect(backW, backH, 0x00ff00, 1, 0, 0x007f00, ellipse);
			
			back_ = createRect(backW, backH, 0xffffff, 1, 0, 0x7f0000, ellipse);
			back_.mask = mask_;
			back_.x = LIST_MARGIN;
			back_.y = LIST_MARGIN;
			back_.addChild(mask_);
			addChild(back_);
			
			catalog_ = new Sprite();
			catalog_.addEventListener(MouseEvent.MOUSE_MOVE, onCatalogMouseMove);
			catalog_.addEventListener(MouseEvent.MOUSE_UP, onCatalogMouseUp);
			back_.addChild(catalog_);
			
			slider_ = new UISlideBar();
			slider_.addEventListener(Event.CHANGE, onSliderChange);
			slider_.setup(SLIDER_W, backH);
			slider_.x = backW - slider_.width;
			back_.addChild(slider_);
			
			trashButton_ = new UIButton(32, BUTTONS_H, ResourceProvider.getImage(ResourceProvider.IMAGE_ICON_TRASH), null);
			trashButton_.addEventListener(MouseEvent.CLICK, onTrashClick);
			trashButton_.x = slider_.x + slider_.width - trashButton_.width / 2 - 2;
			trashButton_.y = BUTTON_AREA_H / 2 - trashButton_.y / 2 + backH - (LIST_MARGIN / 2);
			addChild(trashButton_);
			
			uploadButton_ = new UIButton(BUTTONS_W, BUTTONS_H, null, "更新", 0xffffff, 0x448844, 0x66aa66);
			uploadButton_.addEventListener(MouseEvent.CLICK, onUploadClick);
			uploadButton_.x = (backW + SLIDER_W) / 2 - uploadButton_.width / 2;
			uploadButton_.y = BUTTON_AREA_H / 2 - uploadButton_.y / 2 + backH - (LIST_MARGIN / 2);
			addChild(uploadButton_);
			
			catalogW_ = back_.width - SLIDER_W;
			catalogItemSize_ = (catalogW_ / 2) - IMAGE_MARGIN_W;

			movingRect_ = createRect(catalogItemSize_, catalogItemSize_, 0x000000, 0.5, 0, 0, CATALOG_ELLIPSE);
			movingRect_.mouseEnabled = false;
			movingRect_.visible = false;
			catalog_.addChild(movingRect_);
		}
		
		public function open():void {
			var job:KTJob = KTween.fromTo(this, duretion_, { scaleY:0, y:y }, { scaleY:1, y:lastY_ } );
			job.addEventListener(Event.COMPLETE, onWindowOpenedComplete);
		}
		
		public function close():void {
			lastY_ = y;
			var job:KTJob = KTween.fromTo(this, duretion_, { scaleY:1, y:y }, { scaleY:0, y:(y + height) } );
			job.addEventListener(Event.COMPLETE, onWindowClosedComplete);
		}
		
		public function update(store:Store, bind:int):void {
			count_ = store.count;
			
			cleanup();
			bind_ = bind;
			
			var catalogH:Number = (count_ / 2 + 1) * (catalogItemSize_ + IMAGE_MARGIN_H) + IMAGE_MARGIN_H;
			setupRect(catalog_, catalogW_, catalogH, 0xffffff, 1, 1, 0xaaaaaa);
			
			var i:int;
			var btn:CatalogItem;
			for (i = 0; i < count_; i++ ) {
				btn = new CatalogItem(catalogItemSize_, store.getAtIndex(i), i, CATALOG_ELLIPSE);
				btn.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
				btn.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown);
				btn.addEventListener(MouseEvent.MOUSE_MOVE, onButtonMouseMove);
				btn.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
				var pt:Point = getPointByIndex(i, count_, catalog_.width, btn.width, btn.height, bind_);
				btn.x = pt.x;
				btn.y = pt.y;
				catalog_.addChildAt(btn, 0);
				catalogItemList_[i] = btn;
			}
		}
		
		private function cleanup():void {
			var btn:CatalogItem;
			for each (btn in catalogItemList_) {
				catalog_.removeChild(btn);
			}
			catalogItemList_ = new Array();
		}
		
		private function getPointByIndex(index:int, max:int, frameWidth:Number, contentWidth:Number, contentHeight:Number, bind:int):Point {
			var f:int;
			var pt:Point;
			if (index == 0) {
				return new Point(frameWidth / 2 - contentWidth / 2, IMAGE_MARGIN_H);
			}
			else if (index == (max - 1)) {
				f = max / 2;
				return new Point(frameWidth / 2 - contentWidth / 2, (contentHeight + IMAGE_MARGIN_H) * f + IMAGE_MARGIN_H);
			}
			else {
				f = Math.ceil(index / 2);
				var ox:Number;
				if (bind == 0) {
					ox = (index % 2 == 0) ? -contentWidth : 0;
				}
				else {
					ox = (index % 2 == 1) ? -contentWidth : 0;
				}
				return new Point(frameWidth / 2 + ox, (contentHeight + IMAGE_MARGIN_H) * f + IMAGE_MARGIN_H);
			}
			
			return pt;
		}
		
		private function setupRect(sp:Sprite, areaW:Number, areaH:Number, color:uint, alpha:Number=1, thicness:Number=0, lineColor:uint=0, ellipse:Number=0):void {
			sp.graphics.clear();
			if (thicness != 0) {
				sp.graphics.lineStyle(thicness, lineColor, alpha);
			}
			sp.graphics.beginFill(color, alpha);
			if (ellipse == 0) {
				sp.graphics.drawRect(0, 0, areaW, areaH);
			}
			else {
				sp.graphics.drawRoundRect(0, 0, areaW, areaH, ellipse);
			}
			sp.graphics.endFill();
		}
		
		private function createRect(areaW:Number, areaH:Number, color:uint, alpha:Number=1, thicness:Number=0, lineColor:uint=0, ellipse:Number=0):Sprite {
			var sp:Sprite = new Sprite();
			setupRect(sp, areaW, areaH, color, alpha, thicness, lineColor, ellipse);
			
			return sp;
		}
		
		private function createLabel(text:String):Sprite {
			var tf:TextField = new TextField();
			tf.mouseEnabled = false;
			tf.selectable = false;
			tf.text = text;
			tf.width = tf.textWidth + 4;
			tf.height = tf.textHeight + 8;
			tf.textColor = 0xffffff;
			
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x000000, 0.5);
			sp.graphics.drawRoundRect(0, 0, 48, 24, 8);
			sp.graphics.endFill();
			sp.addChild(tf);
			tf.x = sp.width / 2 - tf.width / 2;
			tf.y = sp.height / 2 - tf.height / 2;
			
			return sp;
		}
		
		private function deployItems(beforeIndex:int, afterIndex:int, bind:int):void {
			var forward:Boolean = afterIndex < beforeIndex;
			var start:int = forward ? afterIndex : beforeIndex;
			var end:int = forward ? beforeIndex : afterIndex;
			var i:int;
			var tmpItem:CatalogItem;
			var pt:Point;
			if (forward) {
				tmpItem = catalogItemList_[end];
				for (i = (end - 1); i >= start; i--) {
					swapItem(i, i + 1, bind);
				}
				pt = getPointByIndex(start, catalogItemList_.length, catalog_.width, catalogItemSize_, catalogItemSize_, bind);
				tmpItem.setIndex(start);
				tmpItem.x = pt.x;
				tmpItem.y = pt.y;
				catalogItemList_[start] = tmpItem;
			}
			else {
				tmpItem = catalogItemList_[start];
				for (i = (start + 1); i <= end ; i++) {
					swapItem(i, i - 1, bind);
				}
				pt = getPointByIndex(end, catalogItemList_.length, catalog_.width, catalogItemSize_, catalogItemSize_, bind);
				tmpItem.setIndex(end);
				tmpItem.x = pt.x;
				tmpItem.y = pt.y;
				catalogItemList_[end] = tmpItem;
			}
		}
		
		private function swapItem(index1:int, index2:int, bind:int):void {
			var item:CatalogItem;
			var next:CatalogItem;
			var pt:Point;
			pt = getPointByIndex(index2, catalogItemList_.length, catalog_.width, catalogItemSize_, catalogItemSize_, bind);
			item = catalogItemList_[index1];
			item.x = pt.x;
			item.y = pt.y;
			item.setIndex(index2);
			next = catalogItemList_[index2];
			catalogItemList_[index2] = item;
			catalogItemList_[index1] = next;
		}
		
		private function setupLabel(item:CatalogItem, localX:Number, localY:Number):void {
			var label:Sprite = labelList_[item.name];
			if (label) {
				var pt:Point;
				pt = item.localToGlobal(new Point(localX, localY));
				pt = catalog_.globalToLocal(pt);
				label.x = pt.x + 16;
				label.y = pt.y;
			}
		}
		
		private function onSliderChange(e:Event):void {
			var slider:UISlideBar = e.currentTarget as UISlideBar;
			var moveLen:Number = catalog_.height - mask_.height;
			if (moveLen < 0) {
				moveLen = 0;
			}
			catalog_.y = -(moveLen * slider.rate);
		}
		
		private function onUploadClick(e:Event):void {
		}
		
		private function onTrashClick(e:Event):void {
			var item:CatalogItem;
			var list:Array = new Array();
			for each (item in selectedList_) {
				list.push(item.index);
			}
			dispatchEvent(new PBEvent(PBEvent.CATALOG_TRASH, { list:list } ));
		}
		
		private function onWindowOpenedComplete(e:Event):void {
			var job:KTJob = e.currentTarget as KTJob;
			job.removeEventListener(Event.COMPLETE, onWindowOpenedComplete);
		}
		
		private function onWindowClosedComplete(e:Event):void {
			var job:KTJob = e.currentTarget as KTJob;
			job.removeEventListener(Event.COMPLETE, onWindowClosedComplete);
		}
		
		private function onButtonMouseOver(e:MouseEvent):void {
			var item:CatalogItem = e.currentTarget as CatalogItem;
			
			var text:String;
			if (item.index == 0) {
				text = COVER_FRONT_LABEL;
			}
			else if (item.index == (count_ - 1)) {
				text = COVER_BACK_LABEL;
			}
			else {
				text = item.index.toString();
			}
			
			var label:Sprite = createLabel(text);
			labelList_[item.name] = label;
			catalog_.addChild(label);
			setupLabel(item, e.localX, e.localY);
		}
		
		private function onButtonMouseDown(e:MouseEvent):void {
			selectedBtn_ = e.currentTarget as CatalogItem;
			movingPoint_ = new Point(e.localX, e.localY);
			movingIndex_ = selectedBtn_.index;
			dragMode_ = DRAGMODE_DOWN;
			
			if (!catalog_.hasEventListener(Event.ENTER_FRAME)) {
				catalog_.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private function onButtonMouseMove(e:MouseEvent):void {
			var item:CatalogItem = e.currentTarget as CatalogItem;
			setupLabel(item, e.localX, e.localY);
			
			if (!selectedBtn_) {
				return;
			}
			if (item.index != selectedBtn_.index) {
				deployItems(selectedBtn_.index, item.index, bind_);
				movingSkip_ = true;
			}
		}
		
		private function onButtonMouseOut(e:MouseEvent):void {
			var item:CatalogItem = e.currentTarget as CatalogItem;
			var label:Sprite = labelList_[item.name];
			if (label) {
				catalog_.removeChild(label);
			}
		}
		
		private function onCatalogMouseMove(e:MouseEvent):void {
			if (selectedBtn_) {
				if (dragMode_ == DRAGMODE_DOWN) {
					dragMode_ = DRAGMODE_MOVE;
					selectedBtn_.setMode(CatalogItem.MODE_MOVE);
					movingRect_.visible = true;
				}
				
				if (movingSkip_) { movingSkip_ = false; } else {
					var lPt:Point = catalog_.globalToLocal(new Point(e.stageX, e.stageY));
					movingRect_.x = lPt.x - movingPoint_.x;
					movingRect_.y = lPt.y - movingPoint_.y;
					
					lPt = slider_.globalToLocal(new Point(e.stageX, e.stageY));
					scrollLocalY_ = lPt.y;
				}
			}
		}
		
		private function onCatalogMouseUp(e:MouseEvent):void {
			if (selectedBtn_) {
				var mode:String = CatalogItem.MODE_NORMAL;
				if (dragMode_ == DRAGMODE_DOWN) {
					if (selectedBtn_.mode == CatalogItem.MODE_NORMAL) {
						mode = CatalogItem.MODE_SELECT;
						selectedList_[selectedBtn_.name] = selectedBtn_;
					}
					else {
						delete selectedList_[selectedBtn_.name];
					}
				}
				var nowIndex:int = selectedBtn_.index;
				selectedBtn_.setMode(mode);
				selectedBtn_ = null;
				movingRect_.visible = false;
				if (movingIndex_ != nowIndex) {
					dispatchEvent(new PBEvent(PBEvent.CATALOG_SWAP, { start:movingIndex_, now:nowIndex } ));
				}
			}
			dragMode_ = DRAGMODE_NONE;
			if (catalog_.hasEventListener(Event.ENTER_FRAME)) {
				catalog_.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private function onEnterFrame(e:Event):void {
			var distance:Number;
			
			// Up
			distance = scrollLocalY_;
			if (distance < CATALOG_SCROLL_RANGE) {
				slider_.setBarY(slider_.barY - CATALOG_SCROLL_SPEED);
			}
			else {
				// Down
				distance = (slider_.height - CATALOG_SCROLL_RANGE) - scrollLocalY_;
				if (distance < CATALOG_SCROLL_RANGE) {
					slider_.setBarY(slider_.barY + CATALOG_SCROLL_SPEED);
				}
			}
		}
	}
}