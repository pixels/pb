/*
 * TinyTweener
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

package jp.sionnet.tinytweener 
{
	/**
	 * BezierTweenクラス。直接このクラスからインスタンスを作成することはありません。
	 * @author Takeya Kimura
	 * @author TakeyaKimura
	 * @version 0.2
	 * @see http://www.eqliquid.com/blog/
	 */
	public class BezierTween extends Tween
	{
		internal var controlPoint:Object;
		
		/**
		 * @param	target			ターゲットオブジェクト
		 * @param	targetValue		ターゲットプロパティと値
		 * @param	controlPoint	コントロールポイント
		 * @param	duration		Tweenの秒数
		 * @param	easing			イージングの種類
		 */
		public function BezierTween(target:Object, targetValue:Object, controlPoint:Object, duration:Number, easing:String) 
		{
			super(target, targetValue, duration, easing);
			this.controlPoint = controlPoint;
		}
		
		/**
		 * Easing Linear
		 * @param	t		現在の時間
		 * @param	b		開始時の値
		 * @param	c		目的の値までの差
		 * @param	d		イージング時間
		 * @param	p		プロパティの名前
		 * @return	現在の値
		 */
		override public function easeNone(t:Number, b:Number, c:Number, d:Number, p:String = null):Number 
		{
			var controlArray:Array = [];
			controlArray[0] = b;
			controlArray = controlArray.concat(controlPoint[p]);
			controlArray.push(targetValue[p]);
			
			return bezier(controlArray, t / d);
		}
		
		/**
		 * Easing easeInCubic
		 * @param	t		現在の時間
		 * @param	b		開始時の値
		 * @param	c		目的の値までの差
		 * @param	d		イージング時間
		 * @param	p		プロパティの名前
		 * @return	現在の値
		 */
		override public function easeInCubic(t:Number, b:Number, c:Number, d:Number, p:String = null):Number 
		{
			var controlArray:Array = [];
			controlArray[0] = b;
			controlArray = controlArray.concat(controlPoint[p]);
			controlArray.push(targetValue[p]);
			
			return bezier(controlArray, (t /= d) * t * t);
		}
		
		/**
		 * Easing easeOutCubic
		 * @param	t		現在の時間
		 * @param	b		開始時の値
		 * @param	c		目的の値までの差
		 * @param	d		イージング時間
		 * @param	p		プロパティの名前
		 * @return	現在の値
		 */
		override public function easeOutCubic(t:Number, b:Number, c:Number, d:Number, p:String = null):Number 
		{
			var controlArray:Array = [];
			controlArray[0] = b;
			controlArray = controlArray.concat(controlPoint[p]);
			controlArray.push(targetValue[p]);
			
			return bezier(controlArray, ((t = t / d - 1) * t * t + 1));
		}
		
		//dの時の値を返す
		private function bezier( controlArray:Array, d:Number ):Number
		{
			var correct:Number = 0;
			var l:int = controlArray.length;
			for (var i:int = 0; i < l; i++) 
			{
				var control:Number = controlArray[i];
				var t:Number = 1.0;
				var a:int = l - 1;
				var b:int = i;
				var c:int = a - b;
				
				while (a > 1)
				{
					t *= a;
					a--;
					if (b > 1)
					{
						t /= b;
						b--;
					}
					if (c > 1)
					{
						t /= c;
						c--;
					}
				}
				
				t *= Math.pow(d, i) * Math.pow(1 - d, (l - 1) - i);
				correct += control * t;
			}
			return correct;
		}
	}

}