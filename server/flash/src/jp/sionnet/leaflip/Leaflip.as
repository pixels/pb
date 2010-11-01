/*
 * Leaflip
 * 
 * The MIT License
 * 
 * Copyright (c) <2010> SionDesign (www.sionnet.jp)
 *                      eqLiquid (www.eqliquid.com)
 * 
 * 以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル（以下「ソフトウェア」）
 * の複製を取得するすべての人に対し、ソフトウェアを無制限に扱うことを無償で許可します。
 * これには、ソフトウェアの複製を使用、複写、変更、結合、掲載、頒布、サブライセンス、
 * および/または販売する権利、およびソフトウェアを提供する相手に同じことを許可する権利も
 * 無制限に含まれます。
 * 
 * 上記の著作権表示および本許諾表示を、
 * ソフトウェアのすべての複製または重要な部分に記載するものとします。
 * 
 * ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、
 * 何らの保証もなく提供されます。ここでいう保証とは、商品性、特定の目的への適合性、
 * および権利非侵害についての保証も含みますが、それに限定されるものではありません。
 * 作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、
 * ソフトウェアに起因または関連し、あるいはソフトウェアの使用またはその他の扱いによって生じる
 * 一切の請求、損害、その他の義務について何らの責任も負わないものとします。
 */

package jp.sionnet.leaflip 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import jp.sionnet.tinytweener.Easing;
	import jp.sionnet.tinytweener.TinyTweener;
	import jp.sionnet.tinytweener.TinyTweenerEvent;
	import jp.sionnet.tinytweener.Tween;
	
	/**
	 * <p>マウス操作でページをめくる、閉じるなどの機能を持ちます。</p>
	 * <p>十分なデバッグが行われていない為、
	 * ページ内にインタラクティブなものを入れる場合は注意してください。</p>
	 * <p>めくったページを離した後の動作はopenRatioによって閉じる、または開く動作を行います。</p>
	 * 
	 * @author Takeya Kimura
	 * @version 0.3Alpha
	 * @see ILeaflip
	 * @see LeaflipBase
	 * @see http://www.eqliquid.com/blog/
	 */
	public class Leaflip extends LeaflipBase implements ILeaflip
	{
		internal static const DIR_RB:int = 0;//めくる方向右下
		internal static const DIR_B:int = 1;//下
		internal static const DIR_LB:int = 2;//左下
		internal static const DIR_L:int = 3;//左
		internal static const DIR_LT:int = 4;//左上
		internal static const DIR_T:int = 5;//上
		internal static const DIR_RT:int = 6;//右上
		internal static const DIR_R:int = 7;//右
		internal static const DIR_NONE:int = 8;//なし
		
		protected var reactBorder:Number;
		protected var openRatio:Number;
		protected var pageHitArea:Sprite;
		protected var reactArea:Vector.<Rectangle> = new Vector.<Rectangle>();
		protected var openFlag:Boolean;
		protected var forceOpenFlag:Boolean;
		protected var forceOpenSW:Boolean;
		protected var pickFlag:Boolean;
		protected var flipFlag:Boolean;
		protected var flipTween:Tween;
		protected var alphaBackup:Number;
		
		/**
		 * <p>ページ矩形の幅と高さを与えてページを作成します。</p>
		 * <p>マウスに反応する領域はreactBorderで指定します。
		 * reactBorderのデフォルトの値16はページ矩形の縁から
		 * 16ピクセルの幅がマウスに反応するエリアになります。</p>
		 * <p>openRatioはLeaflipEvent.OPENイベントが発生する閾値です。</p>
		 * <p>openRatioのデフォルトの値0.5は、
		 * ページ矩形の半分の面積が開かれた場合イベントが発生します。
		 * この値を1以上にするとイベントは決して発生しません。</p>
		 * @param	pageWidth		ページ矩形の幅
		 * @param	pageHeight		ページ矩形の高さ
		 * @param	reactBorder		マウスに反応する縁の幅
		 * @param	openRatio		「開かれた」と判断する面積の比率 0:全閉 1:全開
		 */
		public function Leaflip(pageWidth:Number, pageHeight:Number, reactBorder:Number = 16, openRatio:Number = 0.5)
		{
			super(pageWidth, pageHeight);
			
			this.reactBorder = reactBorder;
			this.openRatio = openRatio;
			
			init();
		}
		
		private function init():void
		{
			//createHitArea
			pageHitArea = new Sprite();
			pageHitArea.name = "HitArea";
			pageHitArea.mouseEnabled = false;
			pageHitArea.visible = false;
			pageHitArea.graphics.beginFill(0x000000);
			pageHitArea.graphics.drawRect(0, 0, pageWidth, pageHeight);
			pageHitArea.graphics.endFill();
			this.hitArea = pageHitArea;
			addChild(pageHitArea);
			
			//createReactArea
			reactArea[DIR_RB] = new Rectangle(0, 0, reactBorder, reactBorder);
			reactArea[DIR_B] = new Rectangle(reactBorder, 0, pageWidth - reactBorder * 2, reactBorder);
			reactArea[DIR_LB] = new Rectangle(reactBorder + (pageWidth - reactBorder * 2), 0, reactBorder, reactBorder);
			reactArea[DIR_L] = new Rectangle(reactBorder + (pageWidth - reactBorder * 2), reactBorder, reactBorder, pageHeight - reactBorder * 2);
			reactArea[DIR_LT] = new Rectangle(reactBorder + (pageWidth - reactBorder * 2), reactBorder + (pageHeight - reactBorder * 2), reactBorder, reactBorder);
			reactArea[DIR_T] = new Rectangle(reactBorder, reactBorder + (pageHeight - reactBorder * 2), pageWidth - reactBorder * 2, reactBorder);
			reactArea[DIR_RT] = new Rectangle(0, reactBorder + (pageHeight - reactBorder * 2), reactBorder, reactBorder);
			reactArea[DIR_R] = new Rectangle(0, reactBorder, reactBorder, pageHeight - reactBorder * 2);
			reactArea[DIR_NONE] = new Rectangle(0, 0, pageWidth, pageHeight);
			
			openFlag = false;
			forceOpenFlag = false;
			forceOpenSW = false;
			pickFlag = true;
			flipFlag = false;
			alphaBackup = this.alpha;
			
			addEventListener(Event.ADDED, thisAddedHandler);
		}
		
		/**
		 * <p>ページの座標、イベント、allowFlipを初期化します。
		 * allowFlipがfalseに設定された場合でも初期状態のtrue（めくることができる）
		 * になってしまうので注意。</p>
		 * <p>めくっている最中の場合は無視されます。</p>
		 */
		public function reset():void
		{
			//TODO: マスクの影響で見えないがBSPの座標がリセットされてない模様
			if (flipFlag) return;
			openFlag = false;
			forceOpenFlag = false;
			pickFlag = true;
			flipFlag = false;
			this.alpha = alphaBackup;
			
			resetMidProcess();
			
			//イベント開始
			if (!hasEventListener(MouseEvent.MOUSE_DOWN)) addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
			if (!hasEventListener(MouseEvent.MOUSE_MOVE)) addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			if (!hasEventListener(MouseEvent.MOUSE_OUT)) addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false);
		}
		
		protected function resetMidProcess():void
		{
			//ダミー
			setOrigin( 0, pageHeight, reactBorder, pageHeight - reactBorder);
			flip(pickPoint.x, pickPoint.y);
		}
		
		/**
		 * <p>グラデーションのBitmapDataやイベントを削除し、インスタンスを破棄する準備をします。</p>
		 * <p>めくっている最中の場合は無視されます。</p>
		 */
		override public function dispose():void 
		{
			if (flipFlag) return;
			super.dispose();
			if (hasEventListener(MouseEvent.MOUSE_DOWN)) removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
			if (hasEventListener(MouseEvent.MOUSE_MOVE)) removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			if (hasEventListener(MouseEvent.MOUSE_OUT)) removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false);
		}
		
		/**
		 * <p>ページをめくります。</p>
		 * <p>setOrigin()で与えられためくり始めるポイントからflipX、flipYで指定された位置までめくります</p>
		 * @param	flipX		めくる座標X
		 * @param	flipY		めくる座標Y
		 */
		override public function flip(flipX:Number, flipY:Number):void 
		{
			super.flip(flipX, flipY);
			
			//閾値を超えて開かれたらイベントを送出
			if (getOpenArea() >= openRatio)
			{
				forceOpenFlag = true;
				if (!openFlag) 
				{
					openFlag = true;
					dispatchEvent(new LeaflipEvent(LeaflipEvent.OPEN));
				}
			}
			else
			{
				openFlag = false;
			}
		}
		
		/**
		 * Mouse Down Handler
		 * @param	event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			//event.stopPropagation();
			
			if (!pickFlag) return;
			
			var mx:Number = mouseX;
			var my:Number = mouseY;
			
			//ページがめくれない位置をクリックした場合はなにもしない
			if (!setOriginSwitcher(checkReactArea(mx, my), mx, my)) return;
			
			flipFlag = true;
			Mouse.cursor = MouseCursor.AUTO;
			
			flip(mx, my);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler, false);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler, false);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false);
			
			dispatchEvent(new LeaflipEvent(LeaflipEvent.PICK));
		}
		
		/**
		 * クリックした位置によってページをめくる位置、方向をセット
		 * @param	index	クリックした位置のインデックス
		 * @param	mousex	クリックした位置の座標X
		 * @param	mousey	クリックした位置の座標Y
		 * @return	めくる位置が見つからなければfalseが返る
		 */
		protected function setOriginSwitcher(index:int, mousex:Number, mousey:Number):Boolean
		{
			var findPickPoint:Boolean;
			
			switch (index)
			{
				case DIR_RB:
				findPickPoint = setOrigin( 0, 0, reactBorder, reactBorder);
				break;
				
				case DIR_B:
				findPickPoint = setOrigin(mousex, 0, mousex, reactBorder);
				break;
				
				case DIR_LB:
				findPickPoint = setOrigin(pageWidth, 0, pageWidth - reactBorder, reactBorder);
				break;
				
				case DIR_L:
				findPickPoint = setOrigin(pageWidth, mousey, pageWidth - reactBorder, mousey);
				break;
				
				case DIR_LT:
				findPickPoint = setOrigin(pageWidth, pageHeight, pageWidth -reactBorder, pageHeight - reactBorder);
				break;
				
				case DIR_T:
				findPickPoint = setOrigin(mousex, pageHeight, mousex, pageHeight - reactBorder);
				break;
				
				case DIR_RT:
				findPickPoint = setOrigin(0, pageHeight, reactBorder, pageHeight - reactBorder);
				break;
				
				case DIR_R:
				findPickPoint = setOrigin(0, mousey, reactBorder, mousey);
				break;
				
				case DIR_NONE:
				findPickPoint = false;
				break;
				
				default:
				findPickPoint = false;
				break;
			}
			
			return findPickPoint;
		}
		
		/**
		 * Stage Move Handler
		 * @param	event
		 */
		private function stageMoveHandler(event:MouseEvent):void
		{
			flip(mouseX, mouseY);
			
			event.updateAfterEvent();
		}
		
		/**
		 * Mouse Move Handler
		 * @param	event
		 */
		private function mouseMoveHandler(event:MouseEvent):void
		{
			if (!pickFlag) return;
			
			var mx:int = mouseX;
			var my:int = mouseY;
			
			mouseCursorSwitcher(checkReactArea(mx, my));
		}
		
		/**
		 * マウスオーバーした位置によってカーソルを変える
		 * @param	index	マウスオーバー位置のインデックス
		 */
		protected function mouseCursorSwitcher(index:int):void
		{
			if (index < DIR_NONE)
			{
				Mouse.cursor = MouseCursor.HAND;
			}
			else
			{
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
		
		/**
		 * Mouse Up Handler
		 * @param	event
		 */
		private function stageUpHandler(event:MouseEvent):void
		{
			if (stage != null)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler, false);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler, false);
			}
			//閾値チェック
			if (getOpenArea() >= openRatio || (forceOpenFlag && forceOpenSW))
			{
				pageOpen();
			}
			else
			{
				pageClose();
			}
			
			dispatchEvent(new LeaflipEvent(LeaflipEvent.RELEASE));
		}
		
		/**
		 * ページを開く
		 */
		protected function pageOpen():void
		{
			allowFlip = false;
			
			var mx:int = mouseX;
			var my:int = mouseY;
			var dPoint:Point = new Point(mx, my).subtract(new Point(pickPointX, pickPointY));
			dPoint.normalize(Math.sqrt(pageWidth * pageWidth + pageHeight * pageHeight));
			if (numConstrain > 0)
			{
				flipTween = TinyTweener.tween(this, { flipX:mx + dPoint.x, flipY:my + dPoint.y }, 0.5, Easing.CUBIC_IN);
			}
			else//拘束ポイントがなければページを非表示（透明）にする
			{
				flipTween = TinyTweener.tween(this, { flipX:mx + dPoint.x, flipY:my + dPoint.y , alpha:0 }, 0.5, Easing.CUBIC_IN);
			}
			flipTween.addEventListener(TinyTweenerEvent.COMPLETE, openCompleteHandler);
			flipTween.play();
		}
		
		/**
		 * ページを閉じる
		 */
		protected function pageClose():void
		{
			allowFlip = false;
			
			flipTween = TinyTweener.bezier
			(
			this, 
			{ flipX:pickPointX, flipY:pickPointY }, 
			{ flipX:[pickOrderPointX], flipY:[pickOrderPointY] }, 
			0.5, 
			Easing.CUBIC_OUT
			);
			flipTween.addEventListener(TinyTweenerEvent.COMPLETE, closeCompleteHandler);
			flipTween.play();
		}
		
		/**
		 * ページを開き終わった後の処理
		 * @param	event
		 */
		protected function openCompleteHandler(event:TinyTweenerEvent):void
		{
			flipFlag = false;
			
			flipTween.removeEventListener(TinyTweenerEvent.COMPLETE, openCompleteHandler);
			dispatchEvent(new LeaflipEvent(LeaflipEvent.OPEN_COMPLETE));
		}
		
		/**
		 * ページを閉じ終わった後の処理
		 * @param	event
		 */
		protected function closeCompleteHandler(event:TinyTweenerEvent):void
		{
			flipFlag = false;
			
			flipTween.removeEventListener(TinyTweenerEvent.COMPLETE, closeCompleteHandler);
			
			revert();
			
			dispatchEvent(new LeaflipEvent(LeaflipEvent.CLOSE_COMPLETE));
		}
		
		protected function revert():void
		{
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false);
			
			allowFlip = true;
		}
		
		/**
		 * Mouse Out Handler
		 * @param	event
		 */
		private function mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		/**
		 * 表示リストに追加
		 * @param	event
		 */
		private function thisAddedHandler(event:Event):void
		{
			removeEventListener(Event.ADDED, thisAddedHandler);
			
			reset();
		}
		
		/**
		 * マウスに反応するエリアをチェック
		 * @param	mousex
		 * @param	mousey
		 */
		protected function checkReactArea(mousex:Number, mousey:Number):int
		{
			var i:int;
			reactArea.some(checkReact);
			return i;
			
			function checkReact(item:Rectangle, index:int, vector:Vector.<Rectangle>):Boolean
			{
				if (item.contains(mousex, mousey))
				{
					i = index;
					return true;
				}
				else
				{
					i = DIR_NONE;
					return false;
				}
			}
		}
		
		/**
		 * <p>このプロパティにfalseをセットするとページめくりできなくなります。</p>
		 * <p>トゥイーン中など一時的にマウスに反応させたくない時にはfalseにしてください。</p>
		 */
		public function get allowFlip():Boolean
		{
			return pickFlag;
		}
		
		public function set allowFlip(boolean:Boolean):void
		{
			pickFlag = boolean;
		}
		
		/**
		 * <p>trueをセットすると開いた面積が閾値を超えた場合
		 * これを強制的に開きます。</p>
		 */
		public function get forceOpen():Boolean
		{
			return forceOpenSW;
		}
		public function set forceOpen(value:Boolean):void
		{
			forceOpenSW = value;
		}
		
	}

}