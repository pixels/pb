package jp.pixels.pb 
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.IHash;
	import com.hurlant.util.Hex;
	import flash.utils.ByteArray;
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
		
		public static function makeMD5(text:String = ""):String {
			if (text == "") {
				var date:Date = new Date();
				text = Math.random().toString() + date.toString();
			}
			
			// Plane to Binary
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeMultiByte(text, "utf-8");
	
			// Make hash algorithm
			var md5Algo:IHash;
			md5Algo = Crypto.getHash("md5");
			
			var hashBinary:ByteArray;
			hashBinary = md5Algo.hash(byteArray);
			
			// Binary to Plane
			var md5:String;
			md5 = Hex.fromArray(hashBinary);
			
			return md5;
		}
		
		public static function dateToUnixTime(d:Date):int {
			return d.getTime() / 1000;
		}
		
		public static function authToken(url:String, secret:String, path:String):String {
			var hextime:String = Util.dateToUnixTime(new Date()).toString(16);
			var token:String = makeMD5(secret + path + hextime);
			return url + "/" + token + "/" + hextime + path;
		}
	}
}