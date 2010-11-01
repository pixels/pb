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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import jp.sionnet.tinytweener.Easing;
	import jp.sionnet.tinytweener.TinyTweener;
	import jp.sionnet.tinytweener.TinyTweenerEvent;
	import jp.sionnet.tinytweener.Tween;
	
	/**
	 * <p>本の体裁に特化したBookFlipクラス。</p>
	 * <p>次へ進むページと前へ戻るページ、2つのBookflipBaseで構成されています。</p>
	 * <p>Leaflipクラスの持つイベントをListen出来ますが、
	 * ページを開いた際はページ更新の前にイベントが送出されます。</p>
	 * @author Takeya Kimura
	 * @version 0.3Alpha
	 * @see BookflipBase
	 * @see http://www.eqliquid.com/blog/
	 */
	public class Bookflip extends Sprite
	{
		public static const BIND_RIGHT:int = 0;
		public static const BIND_LEFT:int = 1;
		private static const DEPTH_UNDERPAGE:int = 1;
		private static const DEPTH_PREVPAGE:int = 0;
		private static const DEPTH_NEXTPAGE:int = 1;
		private static const DEPTH_DEACPAGE:int = 2;
		private static const DEPTH_ACTVPAGE:int = 3;
		
		private var pageWidth:Number;
		private var pageHeight:Number;
		private var bind:int;
		private var reactBorder:Number;
		private var openRatio:Number;
		private var stripMaskFlag:Boolean;
		private var activePage:int;
		private var jumpPage:int;
		private var flipFlag:Boolean;
		private var container:Sprite;
		private var containerActv:Sprite;
		private var containerDeAc:Sprite;
		private var containerPrev:Sprite;
		private var containerNext:Sprite;
		private var containerBGPv:Sprite;
		private var containerBGNx:Sprite;
		private var prevPageMask:Shape;
		private var nextPageMask:Shape;
		private var colorBGPrevP:Shape;
		private var colorBGNextP:Shape;
		private var prevBGBitmap:Bitmap;
		private var nextBGBitmap:Bitmap;
		private var dummyBitmapData:BitmapData;
		private var pagePrev:BookflipBase;
		private var pageNext:BookflipBase;
		
		private var pages:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		private var correctNumPage:int;
		private var bookStructure:XML;
		
		private var flipTween:Tween;
		
		/**
		 * <p>本の大きさ等の他、本の綴じ方向を指定します。</p>
		 * <p>本の体裁を保つために、初期状態でダミーページが
		 * 2ページ存在していることに注意してください。</p>
		 * @param	pageWidth		ページ矩形の幅
		 * @param	pageHeight		ページ矩形の高さ
		 * @param	bind			本の綴じ方向 0: 右綴じ	1:左綴じ
		 * @param	reactBorder		マウスに反応する縁の幅
		 * @param	openRatio		「開かれた」と判断する面積の比率 0:全閉 1:全開
		 */
		public function Bookflip(pageWidth:Number, pageHeight:Number, bind:int = 0, reactBorder:Number = 16, openRatio:Number = 0.5) 
		{
			this.pageWidth = pageWidth;
			this.pageHeight = pageHeight;
			this.bind = bind;
			this.reactBorder = reactBorder;
			this.openRatio = openRatio;
			
			init();
		}
		
		private function init():void
		{
			stripMaskFlag = false;
			flipFlag = false;
			
			//createContainer
			container = new Sprite();
			container.name = "BookflipContainer";
			switch (bind)
			{
				case BIND_RIGHT:
				container.x = pageWidth / 2;
				break;
				
				case BIND_LEFT:
				container.x = -pageWidth / 2;
				break;
				
				default:
				break
			}
			containerActv = new Sprite();
			containerDeAc = new Sprite();
			containerPrev = new Sprite();
			containerNext = new Sprite();
			containerBGPv = new Sprite();
			containerBGNx = new Sprite();
			containerActv.name = "ActivePageContainer";
			containerDeAc.name = "DeActivePageContainer";
			containerPrev.name = "PreviousPageContainer";
			containerNext.name = "NextPageContainer";
			containerBGPv.name = "PrevPageBGContainer";
			containerBGNx.name = "NextPageBGContainer";
			
			//containerMask, BackGround, dummy
			prevPageMask = new Shape();
			nextPageMask = new Shape();
			colorBGPrevP = new Shape();
			colorBGNextP = new Shape();
			dummyBitmapData = new BitmapData(1, 1, true, 0x00000000);
			prevBGBitmap = new Bitmap(dummyBitmapData, PixelSnapping.AUTO, false);
			nextBGBitmap = new Bitmap(dummyBitmapData, PixelSnapping.AUTO, false);
			
			//create&set Leaflip&container
			switch (bind)
			{
				case BIND_RIGHT:
				pagePrev = new BookflipBase(pageWidth, pageHeight, BookflipBase.SIDE_RIGHT, reactBorder, openRatio);
				pageNext = new BookflipBase(pageWidth, pageHeight, BookflipBase.SIDE_LEFT, reactBorder, openRatio);
				pagePrev.x = pageWidth;
				pagePrev.y = 0;
				pageNext.x = 0;
				pageNext.y = 0;
				containerPrev.x = pageWidth;
				containerPrev.y = 0;
				containerNext.x = 0;
				containerNext.y = 0;
				prevPageMask.x = pageWidth;
				prevPageMask.y = 0;
				nextPageMask.x = 0;
				nextPageMask.y = 0;
				break;
				
				case BIND_LEFT:
				pagePrev = new BookflipBase(pageWidth, pageHeight, BookflipBase.SIDE_LEFT, reactBorder, openRatio);
				pageNext = new BookflipBase(pageWidth, pageHeight, BookflipBase.SIDE_RIGHT, reactBorder, openRatio);
				pagePrev.x = 0;
				pagePrev.y = 0;
				pageNext.x = pageWidth;
				pageNext.y = 0;
				containerPrev.x = 0;
				containerPrev.y = 0;
				containerNext.x = pageWidth;
				containerNext.y = 0;
				prevPageMask.x = 0;
				prevPageMask.y = 0;
				nextPageMask.x = pageWidth;
				nextPageMask.y = 0;
				break;
				
				default:
				pagePrev = new BookflipBase(pageWidth, pageHeight, BookflipBase.SIDE_RIGHT, reactBorder, openRatio);
				pageNext = new BookflipBase(pageWidth, pageHeight, BookflipBase.SIDE_LEFT, reactBorder, openRatio);
				pagePrev.x = pageWidth;
				pagePrev.y = 0;
				pageNext.x = 0;
				pageNext.y = 0;
				containerPrev.x = pageWidth;
				containerPrev.y = 0;
				containerNext.x = 0;
				containerNext.y = 0;
				prevPageMask.x = pageWidth;
				prevPageMask.y = 0;
				nextPageMask.x = 0;
				nextPageMask.y = 0;
				break
			}
			
			pagePrev.name = "PreviousPage";
			pageNext.name = "NextPage";
			
			//addChild
			containerBGPv.addChild(colorBGPrevP);
			containerBGPv.addChild(prevBGBitmap);
			containerBGNx.addChild(colorBGNextP);
			containerBGNx.addChild(nextBGBitmap);
			containerPrev.addChild(containerBGPv);
			containerNext.addChild(containerBGNx);
			resetContainerList();
			container.addChild(prevPageMask);
			container.addChild(nextPageMask);
			addChild(container);
			
			//xml
			bookStructure = <book><pages /></book>;
			
			//DummyCoverAdd
			pages.push(new Sprite());
			pages.push(new Sprite());
			correctNumPage = 2;
			bookStructure.pages.appendChild(<page>0</page>);
			bookStructure.pages.appendChild(<page>1</page>);
			bookStructure.pages.*[0].@data = "include";
			bookStructure.pages.*[1].@data = "include";
			
			activePage = 0;
			jumpPage = 0;
			update();
			
			addEventListener(Event.ADDED, thisAddedHandler);
		}
		
		/**
		 * コンテナの表示リストを初期化
		 * アクティブコンテナには常に次のページが入る
		 */
		private function resetContainerList():void
		{
			containerActv.addChild(pageNext);
			containerDeAc.addChild(pagePrev);
			container.addChildAt(containerPrev, DEPTH_PREVPAGE);
			container.addChildAt(containerNext, DEPTH_NEXTPAGE);
			container.addChildAt(containerDeAc, DEPTH_DEACPAGE);
			container.addChildAt(containerActv, DEPTH_ACTVPAGE);
		}
		
		/**
		 * 表示ページ構成を更新
		 * 表示インデックスの大きいものからremoveすること
		 */
		private function update():void
		{
			resetContainerList();
			
			switch(activePage)
			{
				case 0://表1
				containerDeAc.removeChild(pagePrev);
				if (correctNumPage > 2)
				{
					if (containerNext.numChildren > 1) containerNext.removeChildAt(DEPTH_UNDERPAGE);
					containerNext.addChildAt(getPage(2), DEPTH_UNDERPAGE);
				}
				else
				{
					container.removeChildAt(DEPTH_NEXTPAGE);
				}
				container.removeChildAt(DEPTH_PREVPAGE);
				pageNext.removeFSP();
				pageNext.removeBSP();
				pageNext.addFSP(getPage(0));
				pageNext.addBSP(getPage(1));
				break;
				
				
				case correctNumPage - 1://表4
				container.removeChildAt(DEPTH_NEXTPAGE);
				containerActv.removeChild(pageNext);
				if (correctNumPage > 2)
				{
					if (containerPrev.numChildren > 1) containerPrev.removeChildAt(DEPTH_UNDERPAGE);
					containerPrev.addChildAt(getPage(activePage - 2), DEPTH_UNDERPAGE);
				}
				else
				{
					container.removeChildAt(DEPTH_PREVPAGE);
				}
				pagePrev.removeFSP();
				pagePrev.removeBSP();
				pagePrev.addFSP(getPage(correctNumPage - 1));
				pagePrev.addBSP(getPage(correctNumPage - 2));
				break
				
				
				default://中面
				if (activePage > correctNumPage) break;//中面がない
				
				if (activePage + 4 < correctNumPage)
				{
					if (containerNext.numChildren > 1) containerNext.removeChildAt(DEPTH_UNDERPAGE);
					containerNext.addChildAt(getPage(activePage + 3), DEPTH_UNDERPAGE);
				}
				else
				{
					container.removeChildAt(DEPTH_NEXTPAGE);
				}
				
				if (activePage > 2)
				{
					if (containerPrev.numChildren > 1) containerPrev.removeChildAt(DEPTH_UNDERPAGE);
					containerPrev.addChildAt(getPage(activePage - 2), DEPTH_UNDERPAGE);
				}
				else
				{
					container.removeChildAt(DEPTH_PREVPAGE);
				}
				
				pagePrev.removeFSP();
				pagePrev.removeBSP();
				pagePrev.addFSP(getPage(activePage));
				pagePrev.addBSP(getPage(activePage - 1));
				pageNext.removeFSP();
				pageNext.removeBSP();
				pageNext.addFSP(getPage(activePage + 1));
				pageNext.addBSP(getPage(activePage + 2));
				break;
			}
			pagePrev.reset();
			pageNext.reset();
			
			//traceDisplayList(container);
			//trace("====================================================================================\n");
		}
		
		/**
		 * 表示を変えずにページ裏の構成を更新
		 * 表示インデックスの大きいものからremoveすること
		 */
		private function bufferUpdate():void
		{
			resetContainerList();
			
			switch(activePage)
			{
				case 0://現在表1
				containerDeAc.removeChild(pagePrev);
				if (jumpPage != correctNumPage - 1)
				{
					if (containerNext.numChildren > 1) containerNext.removeChildAt(DEPTH_UNDERPAGE);
					containerNext.addChildAt(getPage(jumpPage + 1), DEPTH_UNDERPAGE);
				}
				else
				{
					container.removeChildAt(DEPTH_NEXTPAGE);
				}
				container.removeChildAt(DEPTH_PREVPAGE);
				pageNext.removeBSP();
				pageNext.addBSP(getPage(jumpPage));
				break;
				
				
				case correctNumPage - 1://現在表4
				container.removeChildAt(DEPTH_NEXTPAGE);
				containerActv.removeChild(pageNext);
				if (jumpPage != 0)
				{
					if (containerPrev.numChildren > 1) containerPrev.removeChildAt(DEPTH_UNDERPAGE);
					containerPrev.addChildAt(getPage(jumpPage), DEPTH_UNDERPAGE);
					pagePrev.removeBSP();
					pagePrev.addBSP(getPage(jumpPage + 1));
				}
				else
				{
					container.removeChildAt(DEPTH_PREVPAGE);
					pagePrev.removeBSP();
					pagePrev.addBSP(getPage(jumpPage));
				}
				break
				
				
				default://中面
				if (activePage > correctNumPage) break;//中面がない
				
				if (jumpPage > activePage)//進む場合
				{
					if (jumpPage != correctNumPage - 1)
					{
						if (containerNext.numChildren > 1) containerNext.removeChildAt(DEPTH_UNDERPAGE);
						containerNext.addChildAt(getPage(jumpPage + 1), DEPTH_UNDERPAGE);
					}
					else
					{
						container.removeChildAt(DEPTH_NEXTPAGE);
					}
					
					pageNext.removeBSP();
					pageNext.addBSP(getPage(jumpPage));
				}
				else//戻る場合
				{
					if (jumpPage != 0)
					{
						if (containerPrev.numChildren > 1) containerPrev.removeChildAt(DEPTH_UNDERPAGE);
						containerPrev.addChildAt(getPage(jumpPage), DEPTH_UNDERPAGE);
						pagePrev.removeBSP();
						pagePrev.addBSP(getPage(jumpPage + 1));
					}
					else
					{
						container.removeChildAt(DEPTH_PREVPAGE);
						pagePrev.removeBSP();
						pagePrev.addBSP(getPage(jumpPage));
					}
				}
				break;
			}
			pagePrev.reset();
			pageNext.reset();
			
			//traceDisplayList(container);
			//trace("====================================================================================\n");
		}
		
		/**
		 * 指定されたページを返す。無ければ空のSpriteを返す
		 * @param	pageNumber
		 * @return
		 */
		private function getPage(pageNumber:int):DisplayObject
		{
			var returnPage:DisplayObject;
			try
			{
				returnPage = pages[pageNumber];
			}
			catch (error:RangeError)
			{
				returnPage =  new Sprite();
			}
			
			return returnPage;
		}
		
		/**
		 * <p>表1、表4をそれぞれ指定します。</p>
		 * <p>ページをめくっている最中の追加はできません。</p>
		 * <p>初期状態ではダミーの表紙が設定されています。</p>
		 * @param	cover1		表1
		 * @param	cover4		表4
		 */
		public function setCover(cover1:DisplayObject, cover4:DisplayObject):void
		{
			if (flipFlag) return;
			pages[0] = cover1;
			pages[pages.length - 1] = cover4;
			update();
		}
		
		/**
		 * <p>Bookの指定された位置に見開き2ページ追加します。</p>
		 * <p>指定できるページ番号は1以上、奇数です。</p>
		 * <p>すでにページが存在するページ番号を指定した場合は
		 * それ以降のページが見開きずつ後方へずれます。
		 * 現在のページ数を越えた位置は指定できません。</p>
		 * <p>insertにfalseを渡すことでページを上書きできます。</p>
		 * <p>ページをめくっている最中の追加はできません。</p>
		 * <p>すでに他のページに割り当てているDisplayObjectを
		 * 指定した場合の動作は保障されていません。</p>
		 * @param	pageNumber	ページ番号
		 * @param	page1		前ページ
		 * @param	page2		後ページ
		 * @param	insert		挿入、上書きの指定
		 */
		public function addPage(pageNumber:int, page1:DisplayObject, page2:DisplayObject, insert:Boolean = true):void
		{
			if (flipFlag) return;
			
			if (pageNumber % 2 == 0)
			{
				throw new Error("表1、もしくは偶数ページが指定されました。");
				return;
			}
			if (pageNumber > pages.length)
			{
				throw new Error("現在のページ数を越えた位置は指定できません。");
				return;
			}
			
			var tmp:DisplayObject = pages.pop();//表4移動
			
			if ((pageNumber < pages.length && insert) || (pages.length == 2 && !insert))//insert指定の時ページを後方に1ずらす
			{
				var i:int = pages.length - 2;
				while (i >= pageNumber)
				{
					pages[i + 1] = pages[i - 1];
					pages[i + 2] = pages[i];
					i -= 2;
				}
			}
			pages[pageNumber] = page1;
			pages[pageNumber + 1] = page2;
			pages.push(tmp);
			correctNumPage = pages.length + pages.length % 2;//奇数の場合は強制的に偶数に
			update();
		}
		
		/**
		 * <p>最後のページに2ページを追加します。</p>
		 * <p>ページをめくっている最中の追加はできません。</p>
		 * <p>すでに他のページに割り当てているDisplayObjectを
		 * 指定した場合の動作は保障されていません。</p>
		 * @param	page1	前ページ
		 * @param	page2	後ろページ
		 */
		public function pushPage(page1:DisplayObject, page2:DisplayObject):void
		{
			if (flipFlag) return;
			
			var tmp:DisplayObject = pages.pop();//表4移動
			pages.push(page1);
			pages.push(page2);
			pages.push(tmp);
			correctNumPage = pages.length + pages.length % 2;//奇数の場合は強制的に偶数に
			update();
		}
		
		/**
		 * <p>ページが格納されるVector配列全てを返します。</p>
		 * @return ページが格納されるVector配列
		 */
		public function getPages():Vector.<DisplayObject>
		{
			return pages;
		}
		
		/**
		 * <p>次のページへ進みます。</p>
		 */
		public function gotoNextPage():void
		{
			var pageNumber:int; 
			if (activePage == 0)
			{
				pageNumber = 1;
			}
			else
			{
				pageNumber = activePage + 2
			}
			gotoPageTweener(pageNumber);
		}
		
		/**
		 * <p>前のページへ戻ります。</p>
		 */
		public function gotoPrevPage():void
		{
			var pageNumber:int; 
			if (activePage == 1)
			{
				pageNumber = 0;
			}
			else
			{
				pageNumber = activePage - 2
			}
			gotoPageTweener(pageNumber);
		}
		
		/**
		 * <p>Tweenしながら指定したページに移動します。</p>
		 * <p>ページをめくっている最中か該当ページが無いもしくは現在と同じページの場合はfalseが返ります。</p>
		 * <p>見開きの右ページ、左ページのどちらを指定しても同じ場所が開かれます。</p>
		 * <p>ページを移動した後はBookflipEvent.MOVE_COMPLETEが送出されます。</p>
		 * @param	pageNumber
		 */
		public function gotoPageTweener(pageNumber:int):Boolean
		{
			var tmp:int = pageNumber;
			if (tmp != 0 && tmp % 2 == 0) tmp--;//奇数に
			if (tmp == activePage || tmp > correctNumPage - 1 || tmp < 0|| flipFlag) return false;
			
			flipFlag = true;
			pagePrev.allowFlip = false;
			pageNext.allowFlip = false;
			
			jumpPage = tmp;
			bufferUpdate();
			
			var coverTween:Tween;
			var d:Number = pageWidth / 2;
			var reverse:Number;
			
			switch(bind)
			{
				case BIND_RIGHT:
				reverse = 1;
				break;
				
				case BIND_LEFT:
				reverse = -1;
				break;
				
				default:
				reverse = 1;
				break;
			}
			
			if (jumpPage > activePage)//進む
			{
				if (activePage != 0 && activePage != correctNumPage - 1)//アクティブページを前面に
				{
					containerActv.addChild(pageNext);
					containerDeAc.addChild(pagePrev);
				}
				//containerTween
				if (activePage == 0)//表1
				{
					if (jumpPage == correctNumPage - 1)//表4へ
					{
						coverTween = TinyTweener.tween(container, { x: -d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
					else//中面へ
					{
						coverTween = TinyTweener.tween(container, { x: 0 }, 0.5, Easing.CUBIC_OUT);
					}
				}
				else//中面
				{
					if (jumpPage == correctNumPage - 1)//表4へ
					{
						coverTween = TinyTweener.tween(container, { x: -d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
				}
				//pageTween
				switch (bind)
				{
					case BIND_RIGHT:
					flipTween = TinyTweener.bezier
					(
					pageNext, 
					{ flipX: pageWidth + pageWidth - pageNext.pickPointX, flipY:pageNext.pickPointY }, 
					{ flipX:[ pageNext.pickOrderPointX], flipY:[ pageNext.pickOrderPointY] }, 
					0.5, 
					Easing.CUBIC_OUT
					);
					break;
					
					case BIND_LEFT:
					flipTween = TinyTweener.bezier
					(
					pageNext, 
					{ flipX: -pageNext.pickPointX, flipY:pageNext.pickPointY }, 
					{ flipX:[ -pageNext.pickOrderPointX], flipY:[ pageNext.pickOrderPointY] }, 
					0.5, 
					Easing.CUBIC_OUT
					);
					break;
					
					default:
					flipTween = TinyTweener.bezier
					(
					pageNext, 
					{ flipX: pageWidth + pageWidth - pageNext.pickPointX, flipY:pageNext.pickPointY }, 
					{ flipX:[ pageNext.pickOrderPointX], flipY:[ pageNext.pickOrderPointY] }, 
					0.5, 
					Easing.CUBIC_OUT
					);
					break;
				}
			}
			else//戻る
			{
				if (activePage != 0 && activePage != correctNumPage - 1)//アクティブページを前面に
				{
					containerActv.addChild(pagePrev);
					containerDeAc.addChild(pageNext);
				}
				//containerTween
				if (activePage == correctNumPage - 1)//表4
				{
					if (jumpPage == 0)//表1へ
					{
						coverTween = TinyTweener.tween(container, { x: d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
					else//中面へ
					{
						coverTween = TinyTweener.tween(container, { x: 0 }, 0.5, Easing.CUBIC_OUT);
					}
				}
				else//中面
				{
					if (jumpPage == 0)//表1へ
					{
						coverTween = TinyTweener.tween(container, { x: d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
				}
				//pageTween
				switch (bind)
				{
					case BIND_RIGHT:
					flipTween = TinyTweener.bezier
					(
					pagePrev,  
					{ flipX: -pagePrev.pickPointX, flipY:pagePrev.pickPointY }, 
					{ flipX:[ -pagePrev.pickOrderPointX], flipY:[ pagePrev.pickOrderPointY] },
					0.5, 
					Easing.CUBIC_OUT
					);
					break;
					
					case BIND_LEFT:
					flipTween = TinyTweener.bezier
					(
					pagePrev, 
					{ flipX: pageWidth + pageWidth - pagePrev.pickPointX, flipY:pagePrev.pickPointY }, 
					{ flipX:[ pagePrev.pickOrderPointX], flipY:[ pagePrev.pickOrderPointY] },
					0.5, 
					Easing.CUBIC_OUT
					);
					break;
					
					default:
					flipTween = TinyTweener.bezier
					(
					pagePrev,  
					{ flipX: -pagePrev.pickPointX, flipY:pagePrev.pickPointY }, 
					{ flipX:[ -pagePrev.pickOrderPointX], flipY:[ pagePrev.pickOrderPointY] },
					0.5, 
					Easing.CUBIC_OUT
					);
					break;
				}
			}
			flipTween.addEventListener(TinyTweenerEvent.COMPLETE, jumpCompleteHandler);
			if (coverTween != null) coverTween.play();
			flipTween.play();
			
			return true;
		}
		
		/**
		 * <p>ページを即座に移動します。</p>
		 * <p>ページをめくっている最中か該当ページが無いもしくは現在と同じページの場合はfalseが返ります。</p>
		 * <p>見開きの右ページ、左ページのどちらを指定しても同じ場所が開かれます。</p>
		 * @param	pageNumber
		 */
		public function gotoPage(pageNumber:int):Boolean
		{
			var tmp:int = pageNumber;
			if (tmp != 0 && tmp % 2 == 0) tmp--;//奇数に
			if (tmp == activePage || tmp > correctNumPage - 1 || tmp < 0|| flipFlag) return false;
			
			activePage = tmp;
			update();
			
			switch(bind)
			{
				case BIND_RIGHT:
				if (activePage == 0)
				{
					container.x = pageWidth / 2;
				}
				else
				{
					if (activePage == correctNumPage - 1)
					{
						container.x = -pageWidth / 2;
					}
					else
					{
						container.x = 0;
					}
				}
				break;
				
				case BIND_LEFT:
				if (activePage == 0)
				{
					container.x = -pageWidth / 2;
				}
				else
				{
					if (activePage == correctNumPage - 1)
					{
						container.x = pageWidth / 2;
					}
					else
					{
						container.x = 0;
					}
				}
				break;
				
				default:
				if (activePage == 0)
				{
					container.x = pageWidth / 2;
				}
				else
				{
					if (activePage == correctNumPage - 1)
					{
						container.x = -pageWidth / 2;
					}
					else
					{
						container.x = 0;
					}
				}
				break;
			}
			
			return true;
		}
		
		/**
		 * <p>現在のページ番号を返します</p>
		 * <p>見開きの場合は小さいページ番号が返されます。</p>
		 * @return
		 */
		public function currentPage():int
		{
			return activePage;
		}
		
		/**
		 * <p>全ページ共通の背景画像をBitmapDataで指定します。</p>
		 * <p>ページDisplayObjectは背景の上に置かれるので、
		 * 個別に背景を指定したい場合はページDisplayObjectへ背景を設定します。</p>
		 * @param	bitmapData	背景画像のBitmapData
		 */
		public function setBitmapBG(bitmapData:BitmapData):void
		{
			pageNext.setBitmapFSPBG(bitmapData);
			pageNext.setBitmapBSPBG(bitmapData);
			pagePrev.setBitmapFSPBG(bitmapData);
			pagePrev.setBitmapBSPBG(bitmapData);
			prevBGBitmap.bitmapData = bitmapData;
			nextBGBitmap.bitmapData = bitmapData;
		}
		
		/**
		 * <p>全ページ共通の背景画像を削除します。</p>
		 */
		public function removeBitmapBG():void
		{
			pageNext.removeBitmapFSPBG();
			pageNext.removeBitmapBSPBG();
			pagePrev.removeBitmapFSPBG();
			pagePrev.removeBitmapBSPBG();
			prevBGBitmap.bitmapData = dummyBitmapData;
			nextBGBitmap.bitmapData = dummyBitmapData;
		}
		
		/**
		 * <p>全ページ共通の背景色を削除します。</p>
		 */
		public function removeColorBG():void
		{
			pagePrev.removeFSPBGColor();
			pagePrev.removeBSPBGColor();
			pageNext.removeFSPBGColor();
			pageNext.removeBSPBGColor();
			colorBGPrevP.graphics.clear();
			colorBGNextP.graphics.clear();
		}
		
		/**
		 * <p>ページをめくった時に現れるグラデーション（影）を有効にします。</p>
		 * <p>このメソッドを呼び出すまではグラデーションは表示されません。</p>
		 * @param	color	グラデーションの色
		 * @param	size	グラデーションの幅
		 */
		public function setGradient(color:uint = 0x000000, size:Number = 64):void
		{
			pagePrev.setGradient(color, size);
			pageNext.setGradient(color, size);
		}
		
		/**
		 * <p>グラデーションを解除します</p>
		 */
		public function removeGradient():void
		{
			pagePrev.removeGradient();
			pageNext.removeGradient();
		}
		
		/**
		 * @private
		 * @return
		 */
		public function getXML():XML
		{
			return bookStructure;
		}
		
		/**
		 * アクティブなページを最前面にする
		 * @param	event
		 */
		private function pagePickHandler(event:LeaflipEvent):void
		{
			flipFlag = true;
			pagePrev.allowFlip = false;
			pageNext.allowFlip = false;
			var currentPage:BookflipBase = event.target as BookflipBase;
			//中面ページの時
			if (activePage != 0 && activePage != correctNumPage - 1)
			{
				if (currentPage == pagePrev)
				{
					containerActv.addChild(pagePrev);
					containerDeAc.addChild(pageNext);
				}
				if (currentPage == pageNext)
				{
					containerActv.addChild(pageNext);
					containerDeAc.addChild(pagePrev);
				}
			}
		}
		
		/**
		 * 開かれた結果、表1もしくは表4だった時コンテナをTweenする
		 * @param	event
		 */
		private function pageReleaseHandler(event:LeaflipEvent):void
		{
			var currentPage:BookflipBase = event.target as BookflipBase;
			
			if (currentPage.getOpenArea() < openRatio) return;
			
			var coverTween:Tween;
			var d:Number = pageWidth / 2;
			var reverse:Number;
			
			switch(bind)
			{
				case BIND_RIGHT:
				reverse = 1;
				break;
				
				case BIND_LEFT:
				reverse = -1;
				break;
				
				default:
				reverse = 1;
				break;
			}
			
			if (currentPage == pageNext)
			{
				if (activePage == 0)//表1
				{
					if (activePage + 1 == correctNumPage - 1)//表4へ
					{
						coverTween = TinyTweener.tween(container, { x: -d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
					else//中面へ
					{
						coverTween = TinyTweener.tween(container, { x: 0 }, 0.5, Easing.CUBIC_OUT);
					}
				}
				else//中面
				{
					if (activePage + 2 == correctNumPage - 1)//表4へ
					{
						coverTween = TinyTweener.tween(container, { x: -d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
				}
			}
			else
			{
				if (activePage == correctNumPage - 1)//表4
				{
					if (activePage - 1 == 0)//表1へ
					{
						coverTween = TinyTweener.tween(container, { x: d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
					else//中面へ
					{
						coverTween = TinyTweener.tween(container, { x: 0 }, 0.5, Easing.CUBIC_OUT);
					}
				}
				else//中面
				{
					if (activePage - 1 == 0)//表1へ
					{
						coverTween = TinyTweener.tween(container, { x: d * reverse }, 0.5, Easing.CUBIC_OUT);
					}
				}
			}
			
			if (coverTween != null) coverTween.play();
		}
		
		/**
		 * ページ遷移をする
		 * @param	event
		 */
		private function pageOpenHandler(event:LeaflipEvent):void
		{
			flipFlag = false;
			
			var currentPage:BookflipBase = event.target as BookflipBase;
			
			if (currentPage == pageNext)//進む
			{
				if (activePage == 0)
				{
					activePage++;
				}
				else
				{
					activePage += 2;
				}
			}
			if (currentPage == pagePrev)//戻る
			{
				if (activePage - 2 < 0)
				{
					activePage = 0;
				}
				else
				{
					activePage -= 2;
				}
			}
			
			update();
		}
		
		/**
		 * ページをめくっている最中をあらわすフラグをリセット
		 * @param	event
		 */
		private function pageCloseHandler(event:LeaflipEvent):void
		{
			flipFlag = false;
			pagePrev.allowFlip = true;
			pageNext.allowFlip = true;
		}
		
		/**
		 * ページ移動後の処理
		 * @param	event
		 */
		private function jumpCompleteHandler(event:TinyTweenerEvent):void
		{
			flipFlag = false;
			
			activePage = jumpPage;
			update();
			
			dispatchEvent(new BookflipEvent(BookflipEvent.MOVE_COMPLETE));
		}
		
		/**
		 * 表示リストへ追加
		 * @param	event
		 */
		private function thisAddedHandler(event:Event):void
		{
			removeEventListener(Event.ADDED, thisAddedHandler);
			
			if (!container.hasEventListener(LeaflipEvent.PICK)) container.addEventListener(LeaflipEvent.PICK, pagePickHandler);
			if (!container.hasEventListener(LeaflipEvent.RELEASE)) container.addEventListener(LeaflipEvent.RELEASE, pageReleaseHandler);
			if (!container.hasEventListener(LeaflipEvent.OPEN_COMPLETE)) container.addEventListener(LeaflipEvent.OPEN_COMPLETE, pageOpenHandler);
			if (!container.hasEventListener(LeaflipEvent.CLOSE_COMPLETE)) container.addEventListener(LeaflipEvent.CLOSE_COMPLETE, pageCloseHandler);
		}
		
		/**
		 * <p>現在の総ページ数</p>
		 */
		public function get numPage():int
		{
			return pages.length;
		}
		
		/**
		 * <p>ストリップマスクの有無</p>
		 */
		public function set enableStripMask(value:Boolean):void
		{
			stripMaskFlag = value;
			if (stripMaskFlag)
			{
				pagePrev.setStripMask(prevPageMask);
				pageNext.setStripMask(nextPageMask);
				containerPrev.mask = prevPageMask;
				containerNext.mask = nextPageMask;
			}
			else
			{
				pagePrev.setStripMask(null);
				pageNext.setStripMask(null);
				containerPrev.mask = null;
				containerNext.mask = null;
			}
		}
		public function get enableStripMask():Boolean
		{
			return stripMaskFlag;
		}
		
		/**
		 * <p>全ページ共通の背景色</p>
		 * <p>ページDisplayObjectは背景色の上に置かれるので、
		 * 個別に背景色を指定したい場合はページDisplayObjectへ背景色を設定します。</p>
		 * @param	BGColor
		 */
		public function set bgColor(color:uint):void
		{
			pagePrev.bgColorFSP = color;
			pagePrev.bgColorBSP = color;
			pageNext.bgColorFSP = color;
			pageNext.bgColorBSP = color;
			colorBGPrevP.graphics.beginFill(color);
			colorBGPrevP.graphics.drawRect(0, 0, pageWidth, pageHeight);
			colorBGPrevP.graphics.endFill();
			colorBGNextP.graphics.beginFill(color);
			colorBGNextP.graphics.drawRect(0, 0, pageWidth, pageHeight);
			colorBGNextP.graphics.endFill();
		}
		public function get bgColor():uint
		{
			return pagePrev.bgColorFSP;
		}
		
		/**
		 * <p>全ページ共通背景色の透明度</p>
		 * <p>ページDisplayObjectは背景色の上に置かれるので、
		 * 個別に背景色を指定したい場合はページDisplayObjectへ背景色を設定します。</p>
		 * @param	BGColor
		 */
		public function set bgAlpha(bgAlpha:Number):void
		{
			pagePrev.bgAlphaFSP = bgAlpha;
			pagePrev.bgAlphaBSP = bgAlpha;
			pageNext.bgAlphaFSP = bgAlpha;
			pageNext.bgAlphaBSP = bgAlpha;
			colorBGPrevP.alpha = bgAlpha;
			colorBGNextP.alpha = bgAlpha;
		}
		public function get bgAlpha():Number
		{
			return pagePrev.bgAlphaFSP;
		}
		
		/**
		 * <p>グラデーションの透明度</p>
		 * <p>影となるグラデーションの不透明度は、
		 * ページの開かれている面積が0.5の時最大になります。</p>
		 * <p>この値はその透明度にかける係数です。</p>
		 */
		public function get gradientAlphaRatio():Number
		{
			return pagePrev.gradientAlphaRatio;
		}
		public function set gradientAlphaRatio(value:Number):void
		{
			pagePrev.gradientAlphaRatio = value;
			pageNext.gradientAlphaRatio = value;
		}
		
		/**
		 * @private
		 * @param	container
		 * @param	indentString
		 */
		private function traceDisplayList(container:DisplayObjectContainer, indentString:String = ""):void//表示リストを全部trace
		{ 
			var child:DisplayObject; 
			for (var i:uint=0; i < container.numChildren; i++) 
			{ 
				child = container.getChildAt(i); 
				trace(indentString, child, child.name);  
				if (container.getChildAt(i) is DisplayObjectContainer) 
				{ 
					traceDisplayList(DisplayObjectContainer(child), indentString + "    ") 
				} 
			} 
		}
		
	}

}