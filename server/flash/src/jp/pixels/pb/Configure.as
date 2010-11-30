package jp.pixels.pb 
{
	import flash.text.engine.BreakOpportunity;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Configure {
		public static const DEBUG:Boolean = true;
		
		//public static const BASE_URL:String = "http://pb.yuimaar.com";
		public static const BASE_URL:String = "http://good-pb.com";
		public static const API_UPLOAD_URL:String = BASE_URL + "/api/upload";
		public static const API_DELETE_URL:String = BASE_URL + "/api/delete";
		public static const API_REARRANGE_URL:String = BASE_URL + "/api/rearrange";
		public static const UPLOAD_URL:String = BASE_URL + "/upload";
		
		public static const AREA_W:Number = 1024;
		public static const AREA_H:Number = 768;
		public static const PREVIEW_W:Number = 768;
		public static const PREVIEW_H:Number = 768;
		public static const PAGE_W:Number = 520 / 2;
		public static const PAGE_H:Number = 400;
		public static const CONTROL_W:Number = AREA_W - PREVIEW_W;
		public static const CONTROL_H:Number = PREVIEW_H;
		public static const EXTENSION:String = "jpg"
	}
}