﻿/*
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
	import flash.events.Event;
	
	/**
	 * <p>Leaflipが送出するイベント</p>
	 * 
	 * @author Takeya Kimura
	 * @version 0.3Alpha
	 * @see Leaflip
	 * @see http://www.eqliquid.com/blog/
	 */
	public class LeaflipEvent extends Event
	{
		/**
		 * <p>ページがMOUSE_DOWNされた時のpickイベントオブジェクトの値を定義します。</p>
		 */
		public static const PICK:String = "pick";
		/**
		 * <p>ページがMOUSE_UPされた時のreleaseイベントオブジェクトの値を定義します。</p>
		 */
		public static const RELEASE:String = "release";
		/**
		 * <p>ページが設定された閾値より開かれた時のopenイベントオブジェクトの値を定義します。</p>
		 */
		public static const OPEN:String = "open";
		/**
		 * <p>ページを開くTween処理終了時のopencompleteイベントオブジェクトの値を定義します。</p>
		 */
		public static const OPEN_COMPLETE:String = "opencomplete";
		/**
		 * <p>ページを閉じるTween処理終了時のclosecompleteイベントオブジェクトの値を定義します。</p>
		 */
		public static const CLOSE_COMPLETE:String = "closecomplete";
		
		public function LeaflipEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
		}
		
	}

}