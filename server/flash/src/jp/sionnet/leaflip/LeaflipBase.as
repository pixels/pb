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
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * <p>インタラクティブな機能を持たないILeaflipBaseの実装</p>
	 * 
	 * @author Takeya Kimura
	 * @version 0.3Alpha
	 * @see ILeaflipBase
	 * @see http://www.eqliquid.com/blog/
	 */
	public class LeaflipBase extends Sprite implements ILeaflipBase
	{
		private static const GRADIENT_LENGTH:Number = 1638.4;
		private static const DEFAULT_GRADIENTSIZE:int = 64;
		private static const DEFAULT_GRADIENTALPHARATIO:Number = 0.6;
		private static const DEFAULT_GRADIENTBLURRATIO:Number = 3;
		private static const DEFAULT_GRADIENTUARATIO:Number = 0.5;
		
		protected var pageWidth:Number;
		protected var pageHeight:Number;
		protected var pickOrderPoint:Point;
		protected var pickPoint:Point;
		
		private var faceVertices:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
		private var edges:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
		private var numEdge:int;
		private var orderPoint:Point;
		private var distPoint:Point;
		private var originPoint:Point;
		private var creaseStart:Point;
		private var creaseVect:Point;
		private var findStartPoint:Point;
		private var findStartVect:Point;
		private var constrain:Vector.<Point> = new Vector.<Point>();
		
		private var containerFSP:Sprite;
		private var containerBSP:Sprite;
		private var pageFS:Sprite;
		private var pageBS:Sprite;
		private var colorFSPBG:Shape;
		private var colorBSPBG:Shape;
		private var bitmapFSPBG:Bitmap;
		private var bitmapBSPBG:Bitmap;
		private var dummyBitmapData:BitmapData;
		private var containerFSPBG:Sprite;
		private var containerBSPBG:Sprite;
		private var containerGFSP:Sprite;
		private var containerGBSP:Sprite;
		private var containerGMFSP:Sprite;
		private var containerGMBSP:Sprite;
		private var containerUG:Sprite;
		private var containerUGNxt:Sprite;
		private var containerUGMNxt:Sprite;
		private var containerOnFSP:Sprite;
		private var pageHitArea:Sprite;
		private var maskFSP:Shape;
		private var maskBSP:Shape;
		private var maskGradientFSP:Shape;
		private var maskGradientBSP:Shape;
		private var maskGradientNxt:Shape;
		private var gradientBitmapFSP:Bitmap;
		private var gradientBitmapBSP:Bitmap;
		private var gradientBitmapNxt:Bitmap;
		private var gradientBitmapDataFSP:BitmapData;
		private var gradientBitmapDataBSP:BitmapData;
		private var gradientBitmapDataNxt:BitmapData;
		private var gradientUBlurBitmapData:BitmapData;
		private var gradientUBlurBitmap:Bitmap;
		private var vertMaskFSP:Vector.<Point> = new Vector.<Point>();
		private var vertMaskBSP:Vector.<Point> = new Vector.<Point>();
		private var noCreaseFlag:Boolean;
		private var distZeroFlag:Boolean;
		private var constrainFlag:Boolean;
		private var gradientFlag:Boolean;
		private var openArea:Number;
		private var colorFSP:uint;
		private var colorBSP:uint;
		private var gradColor:uint;
		private var gradAlphaRatio:Number;
		private var gradSize:Number;
		private var stripMask:Shape;
		protected var numConstrain:int;
		
		/**
		 * <p>ページ矩形の幅と高さを与えてページを作成します。</p>
		 * @param	pageWidth		ページ矩形の幅
		 * @param	pageHeight		ページ矩形の高さ
		 */
		public function LeaflipBase(pageWidth:Number, pageHeight:Number) 
		{
			this.pageWidth = pageWidth;
			this.pageHeight = pageHeight;
			
			init();
		}
		
		/**
		 * 初期化
		 */
		private function init():void
		{
			//createVertices
			faceVertices[0] = new Vector.<int>();
			faceVertices[1] = new Vector.<int>();
			faceVertices[2] = new Vector.<int>();
			faceVertices[3] = new Vector.<int>();
			faceVertices[4] = new Vector.<int>();
			faceVertices[0][0] = 0;
			faceVertices[0][1] = 0;
			faceVertices[1][0] = pageWidth;
			faceVertices[1][1] = 0;
			faceVertices[2][0] = pageWidth
			faceVertices[2][1] = pageHeight;
			faceVertices[3][0] = 0
			faceVertices[3][1] = pageHeight;
			faceVertices[4][0] = 0;
			faceVertices[4][1] = 0;
			
			//createSurface
			//edges[0]: startPoint
			//edges[1]: Vector
			for (var i:int = 0; i < faceVertices.length - 1; i++)
			{
				edges[i] = new Vector.<Point>();
				edges[i][0] = new Point(faceVertices[i][0], faceVertices[i][1]);
				edges[i][1] = new Point(faceVertices[i + 1][0] - faceVertices[i][0], faceVertices[i + 1][1] - faceVertices[i][1]);
			}
			numEdge = edges.length;
			
			creaseStart = new Point();
			creaseVect = new Point();
			noCreaseFlag = true;
			distZeroFlag = true;
			constrainFlag = false;
			gradientFlag = false;
			originPoint = new Point();
			pickOrderPoint = new Point();
			pickPoint = new Point();
			orderPoint = new Point();
			distPoint = new Point();
			openArea = 0;
			gradColor = 0x000000;
			gradAlphaRatio = DEFAULT_GRADIENTALPHARATIO;
			gradSize = DEFAULT_GRADIENTSIZE;
			
			//createDisplayObject
			containerFSP = new Sprite();
			containerFSP.name = "containerFSP";
			containerBSP = new Sprite();
			containerBSP.name = "containerBSP";
			colorFSPBG = new Shape();
			colorBSPBG = new Shape();
			dummyBitmapData = new BitmapData(1, 1, true, 0x00000000);
			bitmapFSPBG = new Bitmap(dummyBitmapData, PixelSnapping.AUTO, false);
			bitmapBSPBG = new Bitmap(dummyBitmapData, PixelSnapping.AUTO, false);
			containerFSPBG = new Sprite();
			containerFSPBG.mouseEnabled = false;
			containerFSPBG.name = "containerFSPBG";
			containerBSPBG = new Sprite();
			containerBSPBG.mouseEnabled = false;
			containerBSPBG.name = "containerBSPBG";
			containerFSPBG.addChild(colorFSPBG);
			containerBSPBG.addChild(colorBSPBG);
			containerFSPBG.addChild(bitmapFSPBG);
			containerBSPBG.addChild(bitmapBSPBG);
			containerFSP.addChild(containerFSPBG);
			containerBSP.addChild(containerBSPBG);
			pageFS = new Sprite();
			pageFS.name = "FrontsidePage";
			pageBS = new Sprite();
			pageBS.name = "BackSidePage";
			containerFSP.addChild(pageFS);
			containerBSP.addChild(pageBS);
			maskFSP = new Shape();
			maskBSP = new Shape();
			containerFSP.addChild(maskFSP);
			containerBSP.addChild(maskBSP);
			containerFSP.mask = maskFSP;
			containerBSP.mask = maskBSP;
			containerOnFSP = new Sprite();
			containerOnFSP.name = "containerOnFSP";
			
			//createGradientContainer
			maskGradientFSP = new Shape();
			maskGradientBSP = new Shape();
			containerGFSP = new Sprite();
			containerGFSP.mouseEnabled = false;
			containerGFSP.name = "containerGFSP";
			containerGBSP = new Sprite();
			containerGBSP.mouseEnabled = false;
			containerGBSP.name = "containerGBSP";
			containerGMFSP = new Sprite();
			containerGMFSP.mouseEnabled = false;
			containerGMFSP.name = "containerGMFSP";
			containerGMBSP = new Sprite();
			containerGMBSP.mouseEnabled = false;
			containerGMBSP.name = "containerGMBSP";
			//createUnderGradientContainer
			maskGradientNxt = new Shape();
			containerUG = new Sprite();
			containerUG.mouseEnabled = false;
			containerUG.blendMode = BlendMode.LAYER;
			containerUG.name = "containerUG";
			containerUGNxt = new Sprite();
			containerUGNxt.mouseEnabled = false;
			containerUGNxt.name = "containerUGNxt";
			containerUGMNxt = new Sprite();
			containerUGMNxt.mouseEnabled = false;
			containerUGMNxt.name = "containerUGMNxt";
			
			//addChild
			containerUG.addChild(containerUGNxt);
			containerUG.addChild(containerUGMNxt);
			addChild(containerUG);
			addChild(containerFSP);
			addChild(containerGFSP);
			addChild(containerOnFSP);
			addChild(containerBSP);
			addChild(containerGBSP);
			addChild(containerGMFSP);
			addChild(containerGMBSP);
			
			drawMask(vertMaskFSP, vertMaskBSP);
		}
		
		/**
		 * <p>ページをめくり始めるポイントを指定します。</p>
		 * <p>Point(pickX, pickY)からPoint(originX, originY)への線分とページの縁との交点がめくり始めるポイントになります。
		 * pickX、pickYは通常クリックされた座標などを与えます。
		 * ページのorigin位置をつまみpick方向へめくる、と考えてください。</p>
		 * <p>originX、originYはページ矩形の外（またはページ矩形上）、pickX、pickYはページ矩形内部の座標であること。</p>
		 * @param	originX		基準座標X
		 * @param	originY		基準座標Y
		 * @param	pickX		めくる座標X
		 * @param	pickY		めくる座標Y
		 * @return	与えられた線分がページ縁と交わらない場合falseが返る
		 */
		public function setOrigin(originX:Number, originY:Number, pickX:Number, pickY:Number):Boolean
		{
			originPoint.x = originX;
			originPoint.y = originY;
			pickOrderPoint.x = pickX;
			pickOrderPoint.y = pickY;
			var dirVectInv:Point = originPoint.subtract(pickOrderPoint);
			dirVectInv.normalize(1);
			var crossingArray:Array = [];
			var pickPointArray:Vector.<Array> = new Vector.<Array>();
			for (var i:int = 0; i < numEdge; i++)
			{
				crossingArray = findCrossing(pickOrderPoint, dirVectInv, edges[i][0], edges[i][1]);
				if (crossingArray[0] && crossingArray[1] && crossingArray[2] > 0)//線分内で交差且つ前で交差したもの
				{
					pickPointArray.push(crossingArray);
				}
				else
				{
					if (crossingArray[4] == 0)//上記判定からもれても、交点がedgeの根元と同一の場合は許可
					{
						pickPointArray.push(crossingArray);
					}
				}
			}
			if (pickPointArray.length == 0)
			{
				//trace("pickPointがみつからない");
				return false;
			}
			if (pickPointArray.length > 1)//2つ以上の線分と交差するなら
			{
				var j:int = pickPointArray.length - 1;
				var tmp:Array;
				for (j; j > 0; j--)//一番距離が短いものを配列の1番目に
				{
					if (Math.abs(pickPointArray[j][2]) < Math.abs(pickPointArray[j - 1][2]))
					{
						tmp = pickPointArray[j];
						pickPointArray[j] = pickPointArray[j - 1];
						pickPointArray[j - 1] = tmp;
					}
				}
			}
			
			pickPoint = pickPointArray[0][3];
			findStartPoint = pickPointArray[0][7];
			findStartVect = pickPointArray[0][8];
			orderPoint = pickPoint.clone();
			
			//ページ座標初期化
			pageBS.x = -pageWidth + pickPoint.x;
			pageBS.y = -pickPoint.y;
			containerBSPBG.x = -pageWidth + pickPoint.x;
			containerBSPBG.y = -pickPoint.y;
			maskBSP.x = -pageWidth + pickPoint.x;
			maskBSP.y = -pickPoint.y;
			maskGradientBSP.x = -pageWidth + pickPoint.x;
			maskGradientBSP.y = -pickPoint.y;
			vertMaskFSP = new Vector.<Point>();
			vertMaskBSP = new Vector.<Point>();
			
			return true;
		}
		
		/**
		 * <p>ページをめくります。</p>
		 * <p>setOrigin()で与えられためくり始めるポイントからflipX、flipYで指定された位置までめくります</p>
		 * @param	flipX		めくる座標X
		 * @param	flipY		めくる座標Y
		 */
		public function flip(flipX:Number, flipY:Number):void
		{
			orderPoint.x = flipX;
			orderPoint.y = flipY;
			
			//init
			var angleBP:Number;
			var gradientAlpha:Number;
			var gradientUAlpha:Number;
			var directionVect:Point = orderPoint.subtract(pickPoint);
			var centerPoint:Point = Point.interpolate(pickPoint, pickPoint.add(directionVect), 0.5);
			directionVect.normalize(1);
			var directionNormal:Point = new Point( -directionVect.y, directionVect.x);
			directionNormal.normalize(1);
			var c2cNormal:Point;
			noCreaseFlag = true;
			openArea = 0;
			
			if (directionVect.x == 0 && directionVect.y == 0)//めくり量なし
			{
				distZeroFlag = true;
				
				vertMaskFSP = new Vector.<Point>();
				vertMaskBSP = new Vector.<Point>();
				drawMask(vertMaskFSP, vertMaskBSP);
				containerBSP.x = distPoint.x;
				containerBSP.y = distPoint.y;
				angleBP = Math.atan2(directionNormal.y, directionNormal.x);
				containerBSP.rotation = angleBP * 2 * 180 / Math.PI + 180;
				
				containerGFSP.x = centerPoint.x;
				containerGFSP.y = centerPoint.y;
				containerGBSP.x = centerPoint.x;
				containerGBSP.y = centerPoint.y;
				containerGMBSP.x = distPoint.x;
				containerGMBSP.y = distPoint.y;
				containerUGNxt.x = centerPoint.x;
				containerUGNxt.y = centerPoint.y;
				containerGFSP.rotation = angleBP * 180 / Math.PI + 90;
				containerGBSP.rotation = angleBP * 180 / Math.PI + 90;
				containerGMBSP.rotation = angleBP * 2 * 180 / Math.PI + 180;
				containerUGNxt.rotation = angleBP * 180 / Math.PI + 90;
				
				//gradientのアルファ
				gradientAlpha = 0;
				gradientUAlpha = 0;
				containerGFSP.alpha = gradientAlpha * gradAlphaRatio;
				containerGBSP.alpha = gradientAlpha * gradAlphaRatio;
				containerUGNxt.alpha = gradientUAlpha * gradAlphaRatio;
			}
			else
			{
				distZeroFlag = false;
				
				//init
				var crossingArray:Array = [];
				var orderCArray:Vector.<Point> = new Vector.<Point>();
				var orderCStart:Point = new Point();
				var orderCVect:Point = new Point();
				var invertFlag:Boolean = false;
				
				findOrderCrease();
				
				//ConstrainCheck
				if (constrain.length > 0)
				{
					var offsetVectArray:Vector.<Array> = new Vector.<Array>();
					var offsetValue:Number;
					var tmpVect:Point;
					
					var i:int;
					for (i = 0; i < numConstrain; i++)
					{
						crossingArray = findCrossing(constrain[i], directionVect, orderCStart, orderCVect);
						if (crossingArray[0] && crossingArray[2] > 0)
						{
							offsetVectArray.push(crossingArray);
						}
					}
					var l:int = offsetVectArray.length - 1;
					var tmpArray:Array = [];
					for (i = 0; i < l; i++)//一番大きいもの（内側で一番距離があるもの）を一番下に
					{
						if (offsetVectArray[i][2] > offsetVectArray[i + 1][2])
						{
							tmpArray = offsetVectArray[i + 1];
							offsetVectArray[i + 1] = offsetVectArray[i];
							offsetVectArray[i] = tmpArray;
						}
					}
					
					if (offsetVectArray.length > 0)
					{
						offsetValue = offsetVectArray[offsetVectArray.length - 1][2];
						
						centerPoint.offset(directionVect.x * -offsetValue, directionVect.y * -offsetValue);
						orderCStart.offset(directionVect.x * -offsetValue, directionVect.y * -offsetValue);
						
						c2cNormal = Point(offsetVectArray[offsetVectArray.length - 1][5]).subtract(centerPoint);
						c2cNormal = new Point( -c2cNormal.y, c2cNormal.x);
						tmpVect = new Point(pageWidth / 2, pageHeight / 2).subtract(centerPoint);
						
						if ((c2cNormal.x * tmpVect.x) + (c2cNormal.y * tmpVect.y) < 0)//折り目のノーマルを常にページの内側に
						{
							c2cNormal.x = -c2cNormal.x;
							c2cNormal.y = -c2cNormal.y;
						}
						
						tmpVect = orderPoint.subtract(centerPoint);
						if ((c2cNormal.x * tmpVect.x) + (c2cNormal.y * tmpVect.y) > 0)
						{
							constrainFlag = true;
						}
						else
						{
							constrainFlag = false;
						}
					}
				}
				
				
				tmpVect = centerPoint.subtract(pickPoint);
				tmpVect.x = tmpVect.x * 2;
				tmpVect.y = tmpVect.y * 2;
				distPoint = pickPoint.add(tmpVect);
				
				vertMaskFSP = new Vector.<Point>();
				vertMaskBSP = new Vector.<Point>();
				var maskTmp:Vector.<Point> = new Vector.<Point>();
				var creaseArray:Vector.<Point> = new Vector.<Point>();
				
				findCrease();
				
				//constrainされた結果頂点が反転された場合
				if (invertFlag)
				{
					maskTmp = vertMaskBSP;
					vertMaskBSP = vertMaskFSP;
					vertMaskFSP = maskTmp;
				}
				
				drawMask(vertMaskFSP, vertMaskBSP);
				containerBSP.x = distPoint.x;
				containerBSP.y = distPoint.y;
				angleBP = Math.atan2(directionNormal.y, directionNormal.x);
				containerBSP.rotation = angleBP * 2 * 180 / Math.PI + 180;
				
				containerGFSP.x = centerPoint.x;
				containerGFSP.y = centerPoint.y;
				containerGBSP.x = centerPoint.x;
				containerGBSP.y = centerPoint.y;
				containerGMBSP.x = distPoint.x;
				containerGMBSP.y = distPoint.y;
				containerUGNxt.x = centerPoint.x;
				containerUGNxt.y = centerPoint.y;
				containerGFSP.rotation = angleBP * 180 / Math.PI + 90;
				containerGBSP.rotation = angleBP * 180 / Math.PI + 90;
				containerGMBSP.rotation = angleBP * 2 * 180 / Math.PI + 180;
				containerUGNxt.rotation = angleBP * 180 / Math.PI + 90;
				
				//gradientのアルファ
				gradientAlpha = (0.5 - (Math.abs(0.5 - getOpenArea()))) / 0.5;
				gradientUAlpha = (1 - getOpenArea()) * DEFAULT_GRADIENTUARATIO;
				containerGFSP.alpha = gradientAlpha * gradAlphaRatio;
				containerGBSP.alpha = gradientAlpha * gradAlphaRatio;
				containerUGNxt.alpha = gradientUAlpha * gradAlphaRatio;
				
			}
			
			//折り目検出
			function findOrderCrease():void
			{
				for (var i:int = 0; i < numEdge; i++)
				{
					crossingArray = findCrossing(centerPoint, directionNormal, edges[i][0], edges[i][1]);
					if (crossingArray[0]) orderCArray.push(crossingArray[3]);
				}
				
				tmpVect = orderCArray[0].subtract(orderCArray[1]);
				
				var rad:Number = Math.atan2(tmpVect.y, tmpVect.x);
				var tmpMtrx:Matrix = new Matrix();
				tmpMtrx.rotate(rad);
				tmpMtrx.invert();
				
				//一旦x軸に揃えて並べ替える
				var j:int = 0;
				var l:int = orderCArray.length;
				for (j; j < l; j++)
				{
					orderCArray[j] = tmpMtrx.transformPoint(orderCArray[j]);
				}
				var tmpPoint:Point;
				j = orderCArray.length - 1;
				for (j; j > 0; j--)//小さいものを一番目に
				{
					if (orderCArray[j].x < orderCArray[j - 1].x)
					{
						tmpPoint = orderCArray[j - 1];
						orderCArray[j - 1] = orderCArray[j];
						orderCArray[j] = tmpPoint;
					}
				}
				j = 1;
				for (j; j < l - 1; j++)//一番大きいものを最後に
				{
					if (orderCArray[j].x > orderCArray[j + 1].x)
					{
						tmpPoint = orderCArray[j + 1];
						orderCArray[j + 1] = orderCArray[j];
						orderCArray[j] = tmpPoint;
					}
				}
				j = 0;
				tmpMtrx.invert();
				for (j; j < l; j++)
				{
					orderCArray[j] = tmpMtrx.transformPoint(orderCArray[j]);
				}
				orderCStart = orderCArray[0];
				orderCVect = orderCArray[orderCArray.length - 1].subtract(orderCArray[0]);
				
				if ((orderCVect.x * directionNormal.x) + (orderCVect.y * directionNormal.y) < 0)//directionNormalにあわせる
				{
					orderCStart = orderCStart.add(orderCVect);
					orderCVect.x = -orderCVect.x;
					orderCVect.y = -orderCVect.y;
				}
			}
			
			//ページ矩形内の折り目検出、面積計算
			//TODO: 面積計算の正確性をチェック
			function findCrease():void
			{
				var creaseStartFlag:Boolean = false;
				var creaseEndFlag:Boolean = false;
				var nextFindPoint:Point = findStartPoint;
				var nextFindVect:Point = findStartVect;
				var ax:Number;
				var ay:Number;
				
				for (var i:int = 0; i < numEdge; i++)
				{
					crossingArray = findCrossing(centerPoint, directionNormal, nextFindPoint, nextFindVect);
					
					if (crossingArray[1])//線分内もしくは根元と同一座標なら
					{
						creaseArray.push(crossingArray[3]);
						if (creaseStartFlag)
						{
							creaseEndFlag = true;
						}
						else
						{
							creaseStartFlag = true;
						}
						vertMaskFSP.push(crossingArray[3]);
						vertMaskBSP.push(crossingArray[3]);
					}
					findedge:for (var j:int = 0; j < numEdge; j++)//次の縁
					{
						crossingArray = findCrossing(nextFindPoint, nextFindVect, edges[j][0], edges[j][1]);
						if (crossingArray[0] && crossingArray[2] > 0)//前方で交差したもの
						{
							if (creaseStartFlag && !creaseEndFlag) vertMaskFSP.push(crossingArray[3]);
							if (creaseEndFlag) vertMaskBSP.push(crossingArray[3]);
							if (!creaseStartFlag && !creaseEndFlag) vertMaskBSP.push(crossingArray[3]);
							nextFindPoint = crossingArray[7];
							nextFindVect = crossingArray[8];
							break findedge;
						}
					}
				}
				
				if (creaseArray.length < 2)//折り目がない
				{
					noCreaseFlag = true;
					creaseStart = new Point();
					creaseVect = new Point();
					if (distZeroFlag || constrainFlag)
					{
						openArea = 0;
					}
					else
					{
						openArea = pageWidth * pageHeight;
					}
				}
				else
				{
					noCreaseFlag = false;
					creaseStart = creaseArray[0];
					creaseVect = creaseArray[1].subtract(creaseStart);
					
					if ((creaseVect.x * directionNormal.x) + (creaseVect.y * directionNormal.y) < 0)//頂点が反転
					{
						invertFlag = true;
						
						creaseStart = creaseStart.add(creaseVect);
						creaseVect.x = -creaseVect.x;
						creaseVect.y = -creaseVect.y;
						
						//めくられたを面積を計算
						if (constrainFlag)
						{
							if (vertMaskFSP.length == 3)
							{
								ax = Point.distance(vertMaskFSP[0], vertMaskFSP[1]);
								ay = Point.distance(vertMaskFSP[1], vertMaskFSP[2]);
								openArea = ax * ay / 2;
							}
							if (vertMaskFSP.length == 4)
							{
								ax = Point.distance(vertMaskFSP[1], vertMaskFSP[2]);
								ay = Point.distance(vertMaskFSP[2], vertMaskFSP[3]) + Point.distance(vertMaskFSP[0], vertMaskFSP[1]);
								openArea = ax * ay / 2;
							}
						}
						else
						{
							if (vertMaskFSP.length == 3)
							{
								ax = Point.distance(vertMaskFSP[0], vertMaskFSP[1]);
								ay = Point.distance(vertMaskFSP[1], vertMaskFSP[2]);
								openArea = ax * ay / 2;
							}
							if (vertMaskFSP.length == 4)
							{
								ax = Point.distance(vertMaskFSP[1], vertMaskFSP[2]);
								ay = Point.distance(vertMaskFSP[0], vertMaskFSP[1]) + Point.distance(vertMaskFSP[2], vertMaskFSP[3]);
								openArea = ax * ay / 2;
							}
							if (vertMaskFSP.length == 5)
							{
								ax = Point.distance(vertMaskBSP[0], vertMaskBSP[2]);
								ay = Point.distance(vertMaskBSP[1], vertMaskBSP[2]);
								openArea = pageWidth * pageHeight - ax * ay / 2;
							}
						}
					}
					else
					{
						invertFlag = false;
						
						//めくられたを面積を計算
						if (vertMaskBSP.length == 3)
						{
							ax = Point.distance(vertMaskBSP[1], vertMaskBSP[2]);
							ay = Point.distance(vertMaskBSP[2], vertMaskBSP[0]);
							openArea = ax * ay / 2;
						}
						if (vertMaskBSP.length == 4)
						{
							if (vertMaskBSP[0].equals(creaseStart))
							{
								ax = Point.distance(vertMaskBSP[2], vertMaskBSP[3]);
								ay = Point.distance(vertMaskBSP[0], vertMaskBSP[3]) + Point.distance(vertMaskBSP[1], vertMaskBSP[2]);
								openArea = ax * ay / 2;
							}
							else
							{
								ax = Point.distance(vertMaskBSP[0], vertMaskBSP[3]);
								ay = Point.distance(vertMaskBSP[0], vertMaskBSP[1]) + Point.distance(vertMaskBSP[2], vertMaskBSP[3]);
								openArea = ax * ay / 2;
							}
						}
						if (vertMaskBSP.length == 5)
						{
							ax = Point.distance(vertMaskFSP[0], vertMaskFSP[1]);
							ay = Point.distance(vertMaskFSP[1], vertMaskFSP[2]);
							openArea = pageWidth * pageHeight - ax * ay / 2;
						}
					}
					
					//trace(openArea);
				}
			}
		}
		
		
		
		/**
		 * 線分の交差を調べる
		 * @param	sourcePoint		対象ベクトル1開始座標
		 * @param	sourceVect		対象ベクトル1
		 * @param	targetPoint		対象ベクトル2開始座標
		 * @param	targetVect		対象ベクトル2
		 * @return		結果配列
		 * 				[0]: true:交差あり false:交差なし
		 * 				[1]: true:線分内 false:線分外
		 * 				[2]: 対象ベクトル1開始座標と交点の距離（マイナスの値は後ろ）
		 * 				[3]: 交差座標
		 * 				[4]: 交点と対象ベクトル2開始座標の距離
		 * 				[5]: 対象ベクトル1開始座標
		 * 				[6]: 対象ベクトル1
		 * 				[7]: 対象ベクトル2開始座標
		 * 				[8]: 対象ベクトル2
		 */
		private function findCrossing(sourcePoint:Point, sourceVect:Point, targetPoint:Point, targetVect:Point):Array
		{
			var crossingPoint:Point;
			var returnArray:Array = [8];
			returnArray[5] = sourcePoint;
			returnArray[6] = sourceVect;
			returnArray[7] = targetPoint;
			returnArray[8] = targetVect;
			var targetNormal:Point = new Point( -targetVect.y, targetVect.x);
			targetNormal.normalize(1);
			var innerVect:Point = sourcePoint.subtract(targetPoint);
			innerVect.normalize(1);
			var innerProduct:Number = (innerVect.x * targetNormal.x) + (innerVect.y * targetNormal.y);
			var d:Number = -(targetPoint.x * targetNormal.x + targetPoint.y * targetNormal.y);
			var t:Number = -(targetNormal.x * sourcePoint.x + targetNormal.y * sourcePoint.y + d) / (targetNormal.x * sourceVect.x + targetNormal.y * sourceVect.y);
			
			if (!t || t == Infinity || t == -Infinity || t == 0)//tが無効ならいったんfalse
			{
				returnArray[0] = false;
			}
			else//tが有効なら方向、交点をセット
			{
				returnArray[0] = true;
				returnArray[2] = t;
				crossingPoint = new Point(sourcePoint.x + sourceVect.x * t, sourcePoint.y + sourceVect.y * t);
				returnArray[3] = crossingPoint;
			}
			
			if (innerProduct == 0 || sourcePoint.equals(targetPoint))//二つの開始座標が一致、sourcePointがtargetVect上なら有効（SP-TPのベクトルがTVNormalと90度）
			{
				returnArray[0] = true;
				returnArray[2] = 0;
				crossingPoint = sourcePoint;
				returnArray[3] = crossingPoint;
			}
			
			if (returnArray[0])
			{
				returnArray[4] = Point.distance(crossingPoint, targetPoint);
				var stVect:Point = crossingPoint.subtract(targetPoint);
				var etVect:Point = crossingPoint.subtract(targetPoint.add(targetVect));
				if ((stVect.x * etVect.x) + (stVect.y * etVect.y) < 0)//線分の外判定であっても距離が0なら線分内とみなす
				{
					if (crossingPoint.equals(targetPoint.add(targetVect)))//ただし、交差点がtargetVectの行き先なら線分外
					{
						returnArray[1] = false;
					}
					else
					{
						returnArray[1] = true;
					}
				}
				else
				{
					returnArray[1] = false;
				}
			}
			
			return returnArray;
		}
		
		/**
		 * マスク描画
		 * @param	vertArrayFSP	表ページのマスクの頂点配列
		 * @param	vertArrayBSP	裏ページのマスクの頂点配列
		 */
		private function drawMask(vertArrayFSP:Vector.<Point>, vertArrayBSP:Vector.<Point>):void
		{
			var l:int;
			var i:int;
			
			if (!noCreaseFlag)//折り目あり
			{
				l = vertArrayFSP.length
				maskFSP.graphics.clear();
				maskFSP.graphics.beginFill(0x000000);
				maskFSP.graphics.moveTo(vertArrayFSP[0].x, vertArrayFSP[0].y);
				for (i = 1; i < l; i++)
				{
					maskFSP.graphics.lineTo(vertArrayFSP[i].x, vertArrayFSP[i].y);
				}
				maskFSP.graphics.endFill();
				
				l = vertArrayBSP.length
				maskBSP.graphics.clear();
				maskBSP.graphics.beginFill(0x000000);
				maskBSP.graphics.moveTo(pageWidth - vertArrayBSP[0].x, vertArrayBSP[0].y);
				for (i = 1; i < l; i++)
				{
					maskBSP.graphics.lineTo(pageWidth - vertArrayBSP[i].x, vertArrayBSP[i].y);
				}
				maskBSP.graphics.endFill();
				
				if (gradientFlag)
				{
					l = vertArrayFSP.length
					maskGradientFSP.graphics.clear();
					maskGradientFSP.graphics.beginFill(0x000000);
					maskGradientFSP.graphics.moveTo(vertArrayFSP[0].x, vertArrayFSP[0].y);
					for (i = 1; i < l; i++)
					{
						maskGradientFSP.graphics.lineTo(vertArrayFSP[i].x, vertArrayFSP[i].y);
					}
					maskGradientFSP.graphics.endFill();
					
					l = vertArrayBSP.length
					maskGradientBSP.graphics.clear();
					maskGradientBSP.graphics.beginFill(0x000000);
					maskGradientBSP.graphics.moveTo(pageWidth - vertArrayBSP[0].x, vertArrayBSP[0].y);
					for (i = 1; i < l; i++)
					{
						maskGradientBSP.graphics.lineTo(pageWidth - vertArrayBSP[i].x, vertArrayBSP[i].y);
					}
					maskGradientBSP.graphics.endFill();
					
					l = vertArrayBSP.length
					maskGradientNxt.graphics.clear();
					maskGradientNxt.graphics.beginFill(0x000000);
					maskGradientNxt.graphics.moveTo(vertArrayBSP[0].x, vertArrayBSP[0].y);
					for (i = 1; i < l; i++)
					{
						maskGradientNxt.graphics.lineTo(vertArrayBSP[i].x, vertArrayBSP[i].y);
					}
					maskGradientNxt.graphics.endFill();
				}
				
				if (stripMask != null)
				{
					l = vertArrayBSP.length
					stripMask.graphics.clear();
					stripMask.graphics.beginFill(0x000000);
					stripMask.graphics.moveTo(vertArrayBSP[0].x, vertArrayBSP[0].y);
					for (i = 1; i < l; i++)
					{
						stripMask.graphics.lineTo(vertArrayBSP[i].x, vertArrayBSP[i].y);
					}
					stripMask.graphics.endFill();
				}
			}
			else//折り目なし
			{
				if (distZeroFlag || constrainFlag)//全閉
				{
					maskFSP.graphics.clear();
					maskFSP.graphics.beginFill(0x000000);
					maskFSP.graphics.drawRect(0, 0, pageWidth, pageHeight);
					maskFSP.graphics.endFill();
					maskBSP.graphics.clear();
					
					if (gradientFlag)
					{
						maskGradientFSP.graphics.clear();
						maskGradientFSP.graphics.beginFill(0x000000);
						maskGradientFSP.graphics.drawRect(0, 0, pageWidth, pageHeight);
						maskGradientFSP.graphics.endFill();
						maskGradientBSP.graphics.clear();
						maskGradientNxt.graphics.clear();
					}
					
					if (stripMask != null)
					{
						stripMask.graphics.clear();
					}
				}
				else//全開
				{
					maskFSP.graphics.clear();
					maskGradientFSP.graphics.clear();
					maskBSP.graphics.clear();
					maskBSP.graphics.beginFill(0x000000);
					maskBSP.graphics.drawRect(0, 0, pageWidth, pageHeight);
					maskBSP.graphics.endFill();
					
					if (gradientFlag)
					{
						maskGradientBSP.graphics.clear();
						maskGradientBSP.graphics.beginFill(0x000000);
						maskGradientBSP.graphics.drawRect(0, 0, pageWidth, pageHeight);
						maskGradientBSP.graphics.endFill();
						maskGradientNxt.graphics.clear();
						maskGradientNxt.graphics.beginFill(0x000000);
						maskGradientNxt.graphics.drawRect(0, 0, pageWidth, pageHeight);
						maskGradientNxt.graphics.endFill();
					}
					
					if (stripMask != null)
					{
						stripMask.graphics.clear();
						stripMask.graphics.beginFill(0x000000);
						stripMask.graphics.drawRect(0, 0, pageWidth, pageHeight);
						stripMask.graphics.endFill();
					}
				}
			}
		}
		
		/**
		 * 影のグラデーションを描画
		 */
		private function createGradientBitmap():void
		{
			var gradientFSPColor:Array;
			var gradientFSPAlpha:Array;
			var gradientFSPRatio:Array;
			var gradientFSPMTX:Matrix;
			var gradientBSPColor:Array;
			var gradientBSPAlpha:Array;
			var gradientBSPRatio:Array;
			var gradientBSPMTX:Matrix;
			var gradientNxtColor:Array;
			var gradientNxtAlpha:Array;
			var gradientNxtRatio:Array;
			var gradientNxtMTX:Matrix;
			
			var gradientFSP:Shape = new Shape();
			var gradientBSP:Shape = new Shape();
			var gradientNxt:Shape = new Shape();
			
			var gradientSY:Number = Math.sqrt(pageWidth * pageWidth + pageHeight * pageHeight);
			
			gradientFSPColor = [gradColor, gradColor, gradColor];
			gradientFSPAlpha = [0.0, 1.0, 0.0];
			gradientFSPRatio = [0, 128, 255];
			gradientFSPMTX = new Matrix();
			gradientFSPMTX.identity();
			gradientFSPMTX.scale(1 / GRADIENT_LENGTH * gradSize, 1 / GRADIENT_LENGTH * gradSize);
			gradientFSPMTX.translate(gradSize / 2, 0);
			gradientFSP.graphics.beginGradientFill
			(
			GradientType.LINEAR,
			gradientFSPColor,
			gradientFSPAlpha,
			gradientFSPRatio,
			gradientFSPMTX
			);
			gradientFSP.graphics.drawRect(0, 0, gradSize, gradSize);
			gradientFSP.graphics.endFill();
			gradientBitmapDataFSP = new BitmapData(gradSize, gradSize, true, 0x00000000);
			gradientBitmapDataFSP.draw(gradientFSP, null, null, null, null, true);
			gradientBitmapFSP = new Bitmap(gradientBitmapDataFSP, PixelSnapping.AUTO, true);
			gradientBitmapFSP.scaleX = 2;
			gradientBitmapFSP.scaleY = gradientSY * 2 / gradSize;
			gradientBitmapFSP.x = -gradSize;
			gradientBitmapFSP.y = -gradientSY;
			
			gradientBSPColor = [gradColor, gradColor, gradColor, gradColor, gradColor];
			gradientBSPAlpha = [0.0, 0.75, 0.0, 0.75, 0.0];
			gradientBSPRatio = [0, 96, 128, 160, 255];
			gradientBSPMTX = new Matrix();
			gradientBSPMTX.identity();
			gradientBSPMTX.scale(1 / GRADIENT_LENGTH * gradSize, 1 / GRADIENT_LENGTH * gradSize);
			gradientBSPMTX.translate(gradSize / 2, 0);
			gradientBSP.graphics.beginGradientFill
			(
			GradientType.LINEAR,
			gradientBSPColor,
			gradientBSPAlpha,
			gradientBSPRatio,
			gradientBSPMTX
			);
			gradientBSP.graphics.drawRect(0, 0, gradSize, gradSize);
			gradientBSP.graphics.endFill();
			gradientBitmapDataBSP = new BitmapData(gradSize, gradSize, true, 0x00000000);
			gradientBitmapDataBSP.draw(gradientBSP, null, null, null, null, true);
			gradientBitmapBSP = new Bitmap(gradientBitmapDataBSP, PixelSnapping.AUTO, true);
			gradientBitmapBSP.scaleY = gradientSY * 2 / gradSize;
			gradientBitmapBSP.x = -gradSize / 2;
			gradientBitmapBSP.y = -gradientSY;
			
			gradientNxtColor = [gradColor, gradColor, gradColor];
			gradientNxtAlpha = [0.0, 1.0, 0.0];
			gradientNxtRatio = [0, 128, 255];
			gradientNxtMTX = new Matrix();
			gradientNxtMTX.identity();
			gradientNxtMTX.scale(1 / GRADIENT_LENGTH * gradSize, 1 / GRADIENT_LENGTH * gradSize);
			gradientNxtMTX.translate(gradSize / 2, 0);
			gradientNxt.graphics.beginGradientFill
			(
			GradientType.LINEAR,
			gradientNxtColor,
			gradientNxtAlpha,
			gradientNxtRatio,
			gradientNxtMTX
			);
			gradientNxt.graphics.drawRect(0, 0, gradSize, gradSize);
			gradientNxt.graphics.endFill();
			gradientBitmapDataNxt = new BitmapData(gradSize, gradSize, true, 0x00000000);
			gradientBitmapDataNxt.draw(gradientNxt, null, null, null, null, true);
			gradientBitmapNxt = new Bitmap(gradientBitmapDataNxt, PixelSnapping.AUTO, true);
			gradientBitmapNxt.scaleX = 2;
			gradientBitmapNxt.scaleY = gradientSY * 2 / gradSize;
			gradientBitmapNxt.x = -gradSize;
			gradientBitmapNxt.y = -gradientSY;
			
			gradientUBlurBitmapData = new BitmapData(pageWidth, pageHeight, true, 0xFFFFFFFF);
			var filter:GlowFilter = new GlowFilter
			(
			0xFFFFFF, 
			1, 
			gradSize / DEFAULT_GRADIENTBLURRATIO, 
			gradSize / DEFAULT_GRADIENTBLURRATIO, 
			2, 
			5, 
			true, 
			true
			);
			gradientUBlurBitmapData.applyFilter
			(
			gradientUBlurBitmapData, 
			new Rectangle(0, 0, pageWidth, pageHeight), 
			new Point(0, 0), 
			filter
			);
			gradientUBlurBitmap = new Bitmap(gradientUBlurBitmapData, PixelSnapping.AUTO, true);
			gradientUBlurBitmap.blendMode = BlendMode.ERASE;
		}
		
		/**
		 * <p>ページをめくった時に現れるグラデーション（影）を有効にします。</p>
		 * <p>この影は現在めくっているページに現れるものです。</p>
		 * <p>このメソッドを呼び出すまではグラデーションは表示されません。</p>
		 * @param	color	グラデーションの色
		 * @param	size	グラデーションの幅
		 */
		public function setGradient(color:uint = 0x000000, size:Number = 64):void
		{
			gradColor = color;
			gradSize = size;
			createGradientBitmap();
			
			if (!gradientFlag)
			{
				containerGFSP.addChild(gradientBitmapFSP);
				containerGFSP.mask = maskGradientFSP;
				containerGBSP.addChild(gradientBitmapBSP);
				containerGBSP.mask = maskGradientBSP;
				containerGMFSP.addChild(maskGradientFSP);
				containerGMBSP.addChild(maskGradientBSP);
				containerUGNxt.addChild(gradientBitmapNxt);
				containerUG.addChild(gradientUBlurBitmap);
				containerUGNxt.mask = maskGradientNxt;
				containerUGMNxt.addChild(maskGradientNxt);
			}
			
			gradientFlag = true;
		}
		
		/**
		 * <p>めくっているページに現れるグラデーションを解除します</p>
		 */
		public function removeGradient():void
		{
			if (gradientFlag)
			{
				gradientBitmapDataFSP.dispose();
				gradientBitmapDataBSP.dispose();
				gradientBitmapDataNxt.dispose();
				containerGFSP.removeChild(gradientBitmapFSP);
				containerGFSP.mask = null;
				containerGBSP.removeChild(gradientBitmapBSP);
				containerGBSP.mask = null;
				containerGMFSP.removeChild(maskGradientFSP);
				containerGMBSP.removeChild(maskGradientBSP);
				containerUGNxt.removeChild(gradientBitmapNxt);
				containerUGNxt.mask = null;
				containerUGMNxt.removeChild(maskGradientNxt);
			}
			gradientFlag = false;
		}
		
		/**
		 * <p>前面（表）ページのバックグランドへBitmapDataを設定します。</p>
		 * @param	bitmapData		ページの背景にするBitmapData
		 */
		public function setBitmapFSPBG(bitmapData:BitmapData):void
		{
			bitmapFSPBG.bitmapData = bitmapData;
		}
		
		/**
		 * <p>背面（裏）ページのバックグランドへBitmapDataを設定します。</p>
		 * @param	bitmapData		ページの背景にするBitmapData
		 */
		public function setBitmapBSPBG(bitmapData:BitmapData):void
		{
			bitmapBSPBG.bitmapData = bitmapData;
		}
		
		/**
		 * <p>前面（表）ページのバックグランドBitmapDataを削除します。</p>
		 */
		public function removeBitmapFSPBG():void
		{
			bitmapFSPBG.bitmapData = dummyBitmapData;
		}
		
		/**
		 * <p>背面（裏）ページのバックグランドBitmapDataを削除します。</p>
		 */
		public function removeBitmapBSPBG():void
		{
			bitmapBSPBG.bitmapData = dummyBitmapData;
		}
		
		/**
		 * <p>前面（表）ページ背景色を削除します。</p>
		 */
		public function removeFSPBGColor():void
		{
			colorFSPBG.graphics.clear();
		}
		
		/**
		 * <p>背面（裏）ページ背景色を削除します。</p>
		 */
		public function removeBSPBGColor():void
		{
			colorBSPBG.graphics.clear();
		}
		
		/**
		 * <p>拘束ポイントをセットします。</p>
		 * <p>ページは拘束ポイントで指定された座標以上に開くことはできません。
		 * Vector配列で複数指定することができます。</p>
		 * <p>座標は必ずページ矩形の中に入るように指定してください。
		 * ページ矩形の外、ページの縁と同一の座標は正しく動作しない恐れがあります。</p>
		 * @param	constrainArray		拘束するPointのVector配列
		 */
		public function setConstrain(constrainArray:Vector.<Point>):void
		{
			constrain = constrainArray;
			numConstrain = constrain.length;
		}
		
		/**
		 * <p>前面（表）のページのコンテナにaddChildします。</p>
		 * @param	displayObject		追加するDisplayObject
		 */
		public function addFSP(child:DisplayObject):void
		{
			pageFS.addChild(child);
		}
		
		/**
		 * <p>前面ページをすべて削除します</p>
		 */
		public function removeFSP():void
		{
			while (pageFS.numChildren > 0)
			{
				pageFS.removeChildAt(0);
			}
		}
		
		/**
		 * 前面ページの上にaddChild
		 * @private
		 * @param	child		追加するDisplayObject
		 */
		public function addOnFSP(child:DisplayObject):void
		{
			containerOnFSP.addChild(child);
		}
		
		/**
		 * <p>背面（裏）のページのコンテナにaddChildします。</p>
		 * @param	displayObject		追加するDisplayObject
		 */
		public function addBSP(child:DisplayObject):void
		{
			pageBS.addChild(child);
		}
		
		/**
		 * <p>背面ページをすべて削除します</p>
		 */
		public function removeBSP():void
		{
			while (pageBS.numChildren > 0)
			{
				pageBS.removeChildAt(0);
			}
		}
		
		/**
		 * <p>めくった結果現れる領域を、指定したShapeに描画します。</p>
		 * <p>ページが半透明な場合など、
		 * 次のページのmaskプロパティにこのShapeを指定する利用方法があります。</p>
		 * <p>解除にはnullを指定します。</p>
		 * @param	shape
		 */
		public function setStripMask(shape:Shape):void
		{
			stripMask = shape;
		}
		
		/**
		 * <p>ページが開かれた面積を比率で返します。</p>
		 * <p>0: 全閉    1: 全開</p>
		 * @return		開かれた面積
		 */
		public function getOpenArea():Number
		{
			return openArea / (pageWidth * pageHeight);
		}
		
		/**
		 * <p>このインスタンスを破棄する準備をします。</p>
		 */
		public function dispose():void
		{
		}
		
		
		//getter,setter
		
		/**
		 * <p>指定されたX座標までページをめくります。</p>
		 */
		public function set flipX(x:Number):void
		{
			orderPoint.x = x;
			flip(orderPoint.x, orderPoint.y);
		}
		public function get flipX():Number
		{
			return orderPoint.x;
		}
		
		/**
		 * <p>指定されたY座標までページをめくります。</p>
		 */
		public function set flipY(y:Number):void
		{
			orderPoint.y = y;
			flip(orderPoint.x, orderPoint.y);
		}
		public function get flipY():Number
		{
			return orderPoint.y;
		}
		
		/**
		 * <p>ページをつまんでいる座標X</p>
		 */
		public function get pickPointX():Number
		{
			return pickPoint.x;
		}
		
		/**
		 * <p>ページをつまんでいる座標Y</p>
		 */
		public function get pickPointY():Number
		{
			return pickPoint.y;
		}
		
		/**
		 * <p>setOrigin()で指定された、めくり方向の基準座標X</p>
		 */
		public function get pickOrderPointX():Number
		{
			return pickOrderPoint.x;
		}
		
		/**
		 * <p>setOrigin()で指定された、めくり方向の基準座標Y</p>
		 */
		public function get pickOrderPointY():Number
		{
			return pickOrderPoint.y;
		}
		
		/**
		 * <p>前面（表）ページの背景色</p>
		 */
		public function get bgColorFSP():uint
		{
			return colorFSP;
		}
		public function set bgColorFSP(color:uint):void
		{
			colorFSP = color;
			colorFSPBG.graphics.beginFill(color, 1);
			colorFSPBG.graphics.drawRect(0, 0, pageWidth, pageHeight);
			colorFSPBG.graphics.endFill();
		}
		
		/**
		 * <p>背面（裏）ページの背景色</p>
		 */
		public function get bgColorBSP():uint
		{
			return colorBSP;
		}
		public function set bgColorBSP(color:uint):void
		{
			colorBSP = color;
			colorBSPBG.graphics.beginFill(color, 1);
			colorBSPBG.graphics.drawRect(0, 0, pageWidth, pageHeight);
			colorBSPBG.graphics.endFill();
		}
		
		/**
		 * <p>前面（表）ページ背景色の透明度</p>
		 */
		public function get bgAlphaFSP():Number
		{
			return colorFSPBG.alpha;
		}
		public function set bgAlphaFSP(value:Number):void
		{
			colorFSPBG.alpha = value;
		}
		
		/**
		 * <p>背面（裏）ページ背景色の透明度</p>
		 */
		public function get bgAlphaBSP():Number
		{
			return colorBSPBG.alpha;
		}
		public function set bgAlphaBSP(value:Number):void
		{
			colorBSPBG.alpha = value;
		}
		
		/**
		 * <p>グラデーションの透明度</p>
		 * <p>影となるグラデーションの不透明度は、
		 * ページの開かれている面積が0.5の時最大になります。</p>
		 * <p>この値はその透明度にかける係数です。</p>
		 * <p>ここでの値はsetGradient、setUnderGradient両方に共通です。</p>
		 */
		public function get gradientAlphaRatio():Number
		{
			return gradAlphaRatio;
		}
		public function set gradientAlphaRatio(value:Number):void
		{
			gradAlphaRatio = value;
		}
		
		
		//デバッグ用
		
		private function drawArrow(sprite:Sprite, sPoint:Point, ePoint:Point, color:uint, clear:Boolean):void
		{
			var vect:Point = new Point();
			vect.x = sPoint.x - ePoint.x;
			vect.y = sPoint.y - ePoint.y;
			var rad:Number = Math.atan2(vect.y, vect.x);
			if (clear) sprite.graphics.clear();
			sprite.graphics.lineStyle(1, color);
			sprite.graphics.moveTo(sPoint.x, sPoint.y);
			sprite.graphics.lineTo(ePoint.x, ePoint.y);
			sprite.graphics.moveTo(ePoint.x, ePoint.y);
			sprite.graphics.lineTo(Math.cos(rad - Math.PI / 6) * 6 + ePoint.x, Math.sin(rad - Math.PI / 6) * 6 + ePoint.y);
			sprite.graphics.moveTo(ePoint.x, ePoint.y);
			sprite.graphics.lineTo(Math.cos(rad + Math.PI / 6) * 6 + ePoint.x, Math.sin(rad + Math.PI / 6) * 6 + ePoint.y);			
		}
		
		private function drawDot(sprite:Sprite, point:Point, color:uint, radius:Number, clear:Boolean):void
		{
			if (clear) sprite.graphics.clear();
			sprite.graphics.beginFill(color);
			sprite.graphics.drawCircle(point.x, point.y, radius);
			sprite.graphics.endFill();
		}
		
		private function drawPorygon(sprite:Sprite, array:Vector.<Point>, color:uint, alpha:Number, clear:Boolean):void
		{
			if (clear) sprite.graphics.clear();
			var l:int = array.length;
			if (l == 0) return
			sprite.graphics.beginFill(color, alpha);
			sprite.graphics.moveTo(array[0].x, array[0].y);
			for (var i:int = 1; i < l; i++)
			{
				sprite.graphics.lineTo(array[i].x, array[i].y);
			}
			sprite.graphics.endFill();
		}
		
		private function tracer():void
		{
			trace("distPoint: " + distPoint);
			trace("openArea: " + getOpenArea());
			trace("distZeroFlag: " + distZeroFlag);
			trace("noCreaseFlag: " + noCreaseFlag);
			//trace(" : ");
			trace("=====================\n");
		}
		
	}
	
}