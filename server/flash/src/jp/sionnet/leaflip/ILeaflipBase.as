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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Point;
	
	/**
	 * インタラクティブな機能を持たないベースインターフェイス。
	 * 
	 * @author Takeya Kimura
	 * @version 0.3Alpha
	 * @see LeaflipBase
	 * @see http://www.eqliquid.com/blog/
	 */
	public interface ILeaflipBase 
	{
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
		function setOrigin(originX:Number, originY:Number, pickX:Number, pickY:Number):Boolean;
		
		/**
		 * <p>ページをめくります。</p>
		 * <p>setOrigin()で与えられためくり始めるポイントからflipX、flipYで指定された位置までめくります</p>
		 * @param	flipX		めくる座標X
		 * @param	flipY		めくる座標Y
		 */
		function flip(flipX:Number, flipY:Number):void;
		
		/**
		 * <p>ページをめくった時に現れるグラデーション（影）を有効にします。</p>
		 * <p>この影は現在めくっているページに現れるものです。</p>
		 * <p>このメソッドを呼び出すまではグラデーションは表示されません。</p>
		 * @param	color	グラデーションの色
		 * @param	size	グラデーションの幅
		 */
		function setGradient(color:uint = 0x000000, size:Number = 64):void
		
		/**
		 * <p>めくっているページに現れるグラデーションを解除します</p>
		 */
		function removeGradient():void
		
		/**
		 * <p>前面（表）ページのバックグランドへBitmapDataを設定します。</p>
		 * @param	bitmapData		ページの背景にするBitmapData
		 */
		function setBitmapFSPBG(bitmapData:BitmapData):void
		
		/**
		 * <p>背面（裏）ページのバックグランドへBitmapDataを設定します。</p>
		 * @param	bitmapData		ページの背景にするBitmapData
		 */
		function setBitmapBSPBG(bitmapData:BitmapData):void
		
		/**
		 * <p>前面（表）ページのバックグランドBitmapDataを削除します。</p>
		 */
		function removeBitmapFSPBG():void
		
		/**
		 * <p>背面（裏）ページのバックグランドBitmapDataを削除します。</p>
		 */
		function removeBitmapBSPBG():void
		
		/**
		 * <p>前面（表）ページ背景色を削除します。</p>
		 */
		function removeFSPBGColor():void
		
		/**
		 * <p>背面（裏）ページ背景色を削除します。</p>
		 */
		function removeBSPBGColor():void
		
		/**
		 * <p>拘束ポイントをセットします。</p>
		 * <p>ページは拘束ポイントで指定された座標以上に開くことはできません。
		 * Vector配列で複数指定することができます。</p>
		 * <p>座標は必ずページ矩形の中に入るように指定してください。
		 * ページ矩形の外、ページの縁と同一の座標は正しく動作しない恐れがあります。</p>
		 * @param	constrainArray		拘束するPointのVector配列
		 */
		function setConstrain(constrainArray:Vector.<Point>):void;
		
		/**
		 * <p>前面（表）のページのコンテナにaddChildします。</p>
		 * @param	displayObject		追加するDisplayObject
		 */
		function addFSP(child:DisplayObject):void;
		
		/**
		 * <p>前面ページをすべて削除します</p>
		 */
		function removeFSP():void;
		
		/**
		 * 前面ページの上にaddChild
		 * @private
		 * @param	child		追加するDisplayObject
		 */
		function addOnFSP(child:DisplayObject):void;
		
		/**
		 * <p>背面（裏）のページのコンテナにaddChildします。</p>
		 * @param	displayObject		追加するDisplayObject
		 */
		function addBSP(child:DisplayObject):void;
		
		/**
		 * <p>背面ページをすべて削除します</p>
		 */
		function removeBSP():void;
		
		/**
		 * <p>めくった結果現れる領域を、指定したShapeに描画します。</p>
		 * <p>ページが半透明な場合など、
		 * 次のページのmaskプロパティにこのShapeを指定する利用方法があります。</p>
		 * @param	shape
		 */
		function setStripMask(shape:Shape):void;
		
		/**
		 * <p>ページが開かれた面積を比率で返します。</p>
		 * <p>0: 全閉    1: 全開</p>
		 * @return		開かれた面積
		 */
		function getOpenArea():Number;
		
		/**
		 * <p>グラデーションのBitMapDataの削除し、このインスタンスを破棄する準備をします。</p>
		 */
		function dispose():void;
		
		
		//getter,setter
		
		/**
		 * <p>指定されたX座標までページをめくります。
		 * このプロパティに値を設定すると即座にページがめくられます。</p>
		 */
		function set flipX(x:Number):void;
		function get flipX():Number;
		
		/**
		 * <p>指定されたY座標までページをめくります。
		 * このプロパティに値を設定すると即座にページがめくられます。</p>
		 */
		function set flipY(y:Number):void;
		function get flipY():Number
		
		/**
		 * <p>ページをつまんでいる座標Xを返します</p>
		 */
		function get pickPointX():Number;
		
		/**
		 * <p>ページをつまんでいる座標Yを返します</p>
		 */
		function get pickPointY():Number;
		
		/**
		 * <p>このX座標までページをめくろうとしています。</p>
		 */
		function get pickOrderPointX():Number;
		
		/**
		 * <p>このY座標までページをめくろうとしています。</p>
		 */
		function get pickOrderPointY():Number;
		
		/**
		 * <p>前面（表）のページに背景色を指定します。</p>
		 */
		function get bgColorFSP():uint;
		function set bgColorFSP(color:uint):void;
		
		/**
		 * <p>背面（裏）のページに背景色を指定します。</p>
		 */
		function get bgColorBSP():uint;
		function set bgColorBSP(color:uint):void;
		
		/**
		 * <p>前面（表）のページの透明度を指定します。</p>
		 */
		function get bgAlphaFSP():Number;
		function set bgAlphaFSP(FSPAlpha:Number):void;
		
		/**
		 * <p>背面（裏）のページの透明度を指定します。</p>
		 */
		function get bgAlphaBSP():Number;
		function set bgAlphaBSP(BSPAlpha:Number):void;
		
		/**
		 * <p>グラデーションの透明度</p>
		 * <p>影となるグラデーションの不透明度は、
		 * ページの開かれている面積が0.5の時最大になります。</p>
		 * <p>この値はその透明度にかける係数です。</p>
		 * <p>ここでの値はsetGradient、setUnderGradient両方に共通です。</p>
		 */
		function get gradientAlphaRatio():Number
		function set gradientAlphaRatio(value:Number):void
		
	}
	
}