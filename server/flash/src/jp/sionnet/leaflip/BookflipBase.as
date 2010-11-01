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
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import jp.sionnet.leaflip.Leaflip;
	import jp.sionnet.tinytweener.Easing;
	import jp.sionnet.tinytweener.TinyTweener;
	import jp.sionnet.tinytweener.TinyTweenerEvent;
	import jp.sionnet.tinytweener.Tween;
	
	/**
	 * <p>本の体裁に特化したBookFlipのベースクラス。</p>
	 * @author Takeya Kimura
	 * @version 0.3Alpha
	 * @see Leaflip
	 * @see http://www.eqliquid.com/blog/
	 */
	public class BookflipBase extends Leaflip
	{
		public static const SIDE_RIGHT:int = 0;
		public static const SIDE_LEFT:int = 1;
		private static const DIS_THRESHOLD:Number = 0.1;
		
		private var bookSide:int;
		
		/**
		 * <p>見開きの状態で、右側もしくは左側のページを指定します。</p>
		 * @param	pageWidth		ページ矩形の幅
		 * @param	pageHeight		ページ矩形の高さ
		 * @param	bookSide			BookflipBase.SIDE_RIGHT: 右側	BookflipBase.SIDE_LEFT: 左側
		 * @param	reactBorder		マウスに反応する縁の幅
		 * @param	openRatio		「開かれた」と判断する面積の比率 0:全閉 1:全開
		 */
		public function BookflipBase(pageWidth:int, pageHeight:int, bookSide:int, reactBorder:int = 16, openRatio:Number = 0.5) 
		{
			super(pageWidth, pageHeight, reactBorder, openRatio);
			
			this.bookSide = bookSide;
			
			init();
		}
		
		/**
		 * 初期化続き
		 */
		private function init():void 
		{
			//setConstrain
			var constrainArray:Vector.<Point> = new Vector.<Point>();
			switch (bookSide)
			{
				case SIDE_RIGHT:
				constrainArray.push(new Point(DIS_THRESHOLD, DIS_THRESHOLD));
				constrainArray.push(new Point(DIS_THRESHOLD, pageHeight - DIS_THRESHOLD));
				break;
				
				case SIDE_LEFT:
				constrainArray.push(new Point(pageWidth - DIS_THRESHOLD, DIS_THRESHOLD));
				constrainArray.push(new Point(pageWidth - DIS_THRESHOLD, pageHeight - DIS_THRESHOLD));
				break;
				
				default:
				constrainArray.push(new Point(DIS_THRESHOLD, DIS_THRESHOLD));
				constrainArray.push(new Point(DIS_THRESHOLD, pageHeight - DIS_THRESHOLD));
				break;
			}
			
			super.setConstrain(constrainArray);
		}
		
		/**
		 * リセットの中間処理
		 */
		override protected function resetMidProcess():void 
		{
			switch (bookSide)
			{
				case SIDE_RIGHT:
				setOrigin( pageWidth, pageHeight, pageWidth - reactBorder, pageHeight - reactBorder);
				flip(pickPoint.x, pickPoint.y);
				break;
				
				case SIDE_LEFT:
				setOrigin( 0, pageHeight, reactBorder, pageHeight - reactBorder);
				flip(pickPoint.x, pickPoint.y);
				break;
				
				default:
				break;
			}
		}
		
		/**
		 * 左右どちらかによってページをめくり可能な位置を変える
		 * @param	index
		 * @param	mousex
		 * @param	mousey
		 * @return
		 */
		override protected function setOriginSwitcher(index:int, mousex:Number, mousey:Number):Boolean 
		{
			var findPickPoint:Boolean;
			
			switch (bookSide)
			{
				case SIDE_RIGHT:
				switch (index)
				{
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
					
					case DIR_NONE:
					findPickPoint = false;
					break;
					
					default:
					findPickPoint = false;
					break;
				}
				break;
				
				case SIDE_LEFT:
				switch (index)
				{
					case DIR_RB:
					findPickPoint = setOrigin( 0, 0, reactBorder, reactBorder);
					break;
					
					case DIR_B:
					findPickPoint = setOrigin(mousex, 0, mousex, reactBorder);
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
				break;
				
				default:
				switch (index)
				{
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
					
					case DIR_NONE:
					findPickPoint = false;
					break;
					
					default:
					findPickPoint = false;
					break;
				}
				break;
			}
			
			return findPickPoint;
		}
		
		/**
		 * 左右どちらかによってマウスカーソルが変更される位置を変える
		 * @param	index	マウスオーバー位置のインデックス
		 */
		override protected function mouseCursorSwitcher(index:int):void 
		{
			switch (bookSide)
			{
				case SIDE_RIGHT:
				switch (index)
				{
					case DIR_B:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_LB:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_L:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_LT:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_T:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_NONE:
					Mouse.cursor = MouseCursor.AUTO;
					break;
					
					default:
					Mouse.cursor = MouseCursor.AUTO;
					break;
				}
				break;
				
				case SIDE_LEFT:
				switch (index)
				{
					case DIR_RB:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_B:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_T:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_RT:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_R:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_NONE:
					Mouse.cursor = MouseCursor.AUTO;
					break;
					
					default:
					Mouse.cursor = MouseCursor.AUTO;
					break;
				}
				break;
				
				default:
				switch (index)
				{
					case DIR_B:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_LB:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_L:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_LT:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_T:
					Mouse.cursor = MouseCursor.HAND;
					break;
					
					case DIR_NONE:
					Mouse.cursor = MouseCursor.AUTO;
					break;
					
					default:
					Mouse.cursor = MouseCursor.AUTO;
					break;
				}
				break;
			}
		}
		
		/**
		 * ページを開く
		 * 左右どちらかにより、flipX、flipYを変化させる
		 */
		override protected function pageOpen():void 
		{
			allowFlip = false;
			
			switch (bookSide)
			{
				case SIDE_RIGHT:
				flipTween = TinyTweener.bezier
				(
				this, 
				{ flipX: -pickPoint.x, flipY:pickPoint.y }, 
				{ flipX:[ -pickOrderPoint.x], flipY:[ pickOrderPoint.y] }, 
				0.5, 
				Easing.CUBIC_OUT
				);
				break;
				
				case SIDE_LEFT:
				flipTween = TinyTweener.bezier
				(
				this, 
				{ flipX: pageWidth + pageWidth - pickPoint.x, flipY:pickPoint.y }, 
				{ flipX:[ pageWidth + pageWidth - pickOrderPoint.x], flipY:[ pickOrderPoint.y] }, 
				0.5, 
				Easing.CUBIC_OUT
				);
				break;
				
				default:
				flipTween = TinyTweener.bezier
				(
				this, 
				{ flipX: -pickPoint.x, flipY:pickPoint.y }, 
				{ flipX:[ -pickOrderPoint.x], flipY:[ pickOrderPoint.y] }, 
				0.5, 
				Easing.CUBIC_OUT
				);
				break;
			}
			flipTween.addEventListener(TinyTweenerEvent.COMPLETE, openCompleteHandler);
			flipTween.play();
		}
		
		/**
		 * 動作を復帰
		 * @param	event
		 */
		//override protected function openCompleteHandler(event:TinyTweenerEvent):void 
		//{
			//super.openCompleteHandler(event);
			//super.revert();
		//}
		
		/**
		 * <p>このクラスでは拘束ポイントの設定はできません。</p>
		 * @throws	拘束ポイントの設定を行うとEroorがthrowされます
		 * @param	constrainArray
		 */
		override public function setConstrain(constrainArray:Vector.<Point>):void 
		{
			throw new Error("このクラスの拘束ポイントは固定で、変更できません");
		}
		
	}

}