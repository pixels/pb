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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * Tweenを管理するクラス。直接このインスタンスを使用することはありません。
	 * @author Takeya Kimura
	 * @version 0.2
	 * @see http://www.eqliquid.com/blog/
	 */
	public class Controller extends Sprite
	{
		private var tweens:Vector.<Tween> = new Vector.<Tween>;
		
		public function Controller() 
		{
		}
		
		/**
		 * TweenをTweenリストに追加し、必要であればEvent.ENTER_FRAMEのハンドリングを開始。
		 * @param	tween	Tweenインスタンス
		 */
		public function addTween(tween:Tween):void
		{
			tweens.push(tween);
			if (!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			var i:int;
			var l:int = tweens.length;
			var tween:Tween;
			var currentTime:Number = getTimer();
			var cct:Number;
			var endTweens:Vector.<Tween> = new Vector.<Tween>();
			
			//終わったものをリストから削除してマーク
			for (i = 0; i < l; i++)
			{
				tween = tweens[i];
				cct = currentTime - tween.startTime + tween.offsetTime;
				if (tween.stopFlag || cct >= tween.duration)
				{
					endTweens.push(tween);
					tweens.splice(i, 1);
					i--;
					l--;
				}
			}
			
			l = tweens.length;
			
			//correct
			for (i = 0; i < l; i++)
			{
				tween = tweens[i];
				if (tween.playFlag)//play()されてなければなにもしない
				{
					cct = currentTime - tween.startTime + tween.offsetTime;
					if (cct > tween.duration) cct = tween.duration;
					//新しい値をプロパティにセット
					for (var propertyName:String in tween.diffValue)
					{
						tween.target[propertyName] = tween.ease(cct, tween.startValue[propertyName],tween.diffValue[propertyName], tween.duration, propertyName);
					}
				}
			}
			
			//全てのTweenが無ければコントローラーを破棄
			if (l == 0)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				TinyTweener.disposeController();
			}
			
			//dispatchEvent
			for (i = 0; i < endTweens.length; i++)
			{
				endTweens[i].dispatchEvent(new TinyTweenerEvent(TinyTweenerEvent.COMPLETE));
			}
			
		}
		
	}

}