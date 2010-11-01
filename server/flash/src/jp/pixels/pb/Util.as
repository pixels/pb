package jp.pixels.pb 
{
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class Util {
		public static function resize(oW:Number, oH:Number, rW:Number, rH:Number):Number {
			
			var rateX:Number = rW / oW;
			var rateY:Number = rH / oH;
			
			return (rateX < rateY ? rateX : rateY);
		}
		
		public static function fillZero(number:int, figure:int):String {
			return ("00000000" + number.toString()).substr(-figure);
		}
		
		public static function rParam(max:int=1000):String {
			return "r=" + Math.round((Math.random() * max));
		}
		
		public static function filenameWithoutExtension(path:String):String {
			var pos:int = path.lastIndexOf("/");
			path = path.slice(pos + 1);
			pos = path.lastIndexOf(".");
			return path.slice(0, pos);
		}
	}
}