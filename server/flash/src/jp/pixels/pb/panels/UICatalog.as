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
	import jp.pixels.pb.object.ArrowButton;
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
	public class UICatalog extends Sprite {
		
		public static const IMAGE_MARGIN_W:Number = 16;
		public static const IMAGE_MARGIN_H:Number = 16;
		private const COVER_FRONT_LABEL:String = "表紙";
		private const COVER_BACK_LABEL:String = "背表紙";
		private const LIST_MARGIN:Number = 8;
		private const SLIDER_W:Number = 24;
		private const BUTTONS_W:Number = 80;
		private const BUTTONS_H:Number = 24;
		private const BUTTONS_MARGIN_TOP:Number = 12;
		private const BUTTONS_MARGIN_SIDE:Number = 0;
		private const BUTTON_AREA_H:Number = 40;
		private const DRAGMODE_NONE:int = 0;
		private const DRAGMODE_DOWN:int = 1;
		private const DRAGMODE_MOVE:int = 2;
		private const CATALOG_ELLIPSE:Number = 16;
		private const CATALOG_SCROLL_RANGE:Number = 24;
		private const CATALOG_SCROLL_SPEED:Number = 2;
		
		private var areaW_:Number;
		private var areaH_:Number;
		private var bind_:int;
		private var count_:int;
		private var catalog_:Sprite;
		private var mask_:Sprite;
		private var dragMode_:int;
		private var selectedBtn_:CatalogItem;
		private var selectedList_:Object = new Object();
		private var itemList_:Array = new Array();
		private var itemSize_:Number;
		private var movingRect_:Sprite;
		private var movingPoint_:Point = new Point();
		private var movingIndex_:int;
		private var movingSkip_:Boolean;
		private var labelList_:Object = new Object();
		private var offsetY_:Number = 0;
		
		public function get offsetY():Number { return offsetY_; }
		public function get itemSize():Number { return itemSize_; }
		
		public function UICatalog(areaW:Number, areaH:Number) {
			
			areaW_ = areaW;
			areaH_ = areaH;
			
			const ellipse:Number = 16;
			setupRect(this, areaW_, areaH_, 0xff0000, 1);
			
			mask_ = createRect(areaW_, areaH_, 0x00ff00, 1);
			addChild(mask_);
			
			catalog_ = new Sprite();
			catalog_.addEventListener(MouseEvent.MOUSE_MOVE, onCatalogMouseMove);
			catalog_.addEventListener(MouseEvent.MOUSE_UP, onCatalogMouseUp);
			catalog_.mask = mask_;
			addChild(catalog_);
			
			itemSize_ = (areaW_ / 2) - IMAGE_MARGIN_W;

			movingRect_ = createRect(itemSize_, itemSize_, 0x000000, 0.5, 0, 0, CATALOG_ELLIPSE);
			movingRect_.mouseEnabled = false;
			movingRect_.visible = false;
			catalog_.addChild(movingRect_);
		}
		
		public function update(store:Store, bind:int):void {
			cleanup();
			
			count_ = store.count;
			bind_ = bind;
			
			var catalogH:Number = (count_ / 2 + 1) * (itemSize_ + IMAGE_MARGIN_H) + IMAGE_MARGIN_H;
			if (catalogH < areaH_) {
				catalogH = areaH_;
			}
			setupRect(catalog_, areaW_, catalogH, 0xffffff, 1, 0, 0x0000ff);
			
			var i:int;
			var btn:CatalogItem;
			for (i = 0; i < count_; i++ ) {
				btn = new CatalogItem(itemSize_, store.getAtIndex(i), i, CATALOG_ELLIPSE);
				btn.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
				btn.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown);
				btn.addEventListener(MouseEvent.MOUSE_MOVE, onButtonMouseMove);
				btn.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
				var pt:Point = getPointByIndex(i, count_, catalog_.width, btn.width, btn.height, bind_);
				btn.x = pt.x;
				btn.y = pt.y;
				catalog_.addChildAt(btn, 0);
				itemList_[i] = btn;
			}
		}
		
		public function trash():Array {
			var item:CatalogItem;
			var list:Array = new Array();
			for each (item in selectedList_) {
				list.push(item.index);
			}
			
			return list;
		}
		
		public function setScroll(offsetY:Number):void {
			offsetY_ = offsetY;
			
			var range:Number = catalog_.height - areaH_;
			if (range < 0) {
				range = 0;
			}
			
			if (offsetY_ < -range) {
				offsetY_ = -range;
			}
			else if (offsetY_ > 0) {
				offsetY_ = 0;
			}
			catalog_.y = offsetY_;
		}
		
		private function cleanup():void {
			var btn:CatalogItem;
			for each (btn in itemList_) {
				catalog_.removeChild(btn);
			}
			itemList_ = new Array();
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
				tmpItem = itemList_[end];
				for (i = (end - 1); i >= start; i--) {
					swapItem(i, i + 1, bind);
				}
				pt = getPointByIndex(start, itemList_.length, catalog_.width, itemSize_, itemSize_, bind);
				tmpItem.setIndex(start);
				tmpItem.x = pt.x;
				tmpItem.y = pt.y;
				itemList_[start] = tmpItem;
			}
			else {
				tmpItem = itemList_[start];
				for (i = (start + 1); i <= end ; i++) {
					swapItem(i, i - 1, bind);
				}
				pt = getPointByIndex(end, itemList_.length, catalog_.width, itemSize_, itemSize_, bind);
				tmpItem.setIndex(end);
				tmpItem.x = pt.x;
				tmpItem.y = pt.y;
				itemList_[end] = tmpItem;
			}
		}
		
		private function swapItem(index1:int, index2:int, bind:int):void {
			var item:CatalogItem;
			var next:CatalogItem;
			var pt:Point;
			pt = getPointByIndex(index2, itemList_.length, catalog_.width, itemSize_, itemSize_, bind);
			item = itemList_[index1];
			item.x = pt.x;
			item.y = pt.y;
			item.setIndex(index2);
			next = itemList_[index2];
			itemList_[index2] = item;
			itemList_[index1] = next;
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
					dispatchEvent(new PBEvent(PBEvent.CATALOG_SWAP, { start:movingIndex_, now:nowIndex }, true ));
				}
			}
			dragMode_ = DRAGMODE_NONE;
		}
	}
}