package jp.pixels.pb 
{
	import flash.text.engine.BreakOpportunity;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Configure {
		public static const SECRET:String = "h5hDFuw4";
		public static const HOST:String = "good-pb.com";
		//public static const HOST:String = "10.0.1.102";
		public static const BASE_URL:String = "http://" + HOST;
		public static const APP_NAME:String = "myapp";
		public static const API_UPLOAD_URL:String = BASE_URL + "/api/upload";
		public static const API_DELETE_URL:String = BASE_URL + "/api/delete";
		public static const API_SWAP_URL:String = BASE_URL + "/api/swap";
		public static const API_REARRANGE_URL:String = BASE_URL + "/api/rearrange";
		public static const UPLOAD_URL:String = BASE_URL + "/upload";
		public static const VOICE_PREFIX:String = "VOICE_";
		
		
		public static const USE_VOIDE:Boolean = true;
		public static const STANDALONE_TEST:Boolean = false;
		public static const BACK_COLOR:uint = 0xEBEACE;
		public static const AREA_W:Number = 970;
		public static const AREA_H:Number = 560;
		public static const PREVIEW_W:Number = 700;
		public static const PREVIEW_H:Number = 560;
		public static const PAGE_W:Number = 520 / 2;
		public static const PAGE_H:Number = 400;
		public static const CONTROL_W:Number = AREA_W - PREVIEW_W;
		public static const CONTROL_H:Number = PREVIEW_H;
		public static const EXTENSION:String = "png"
	}
}