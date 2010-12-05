package jp.pixels.pb 
{
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Yusuke Kikkawa
	 */
	public class ResourceProvider {
		public static const IMAGE_ICON_ARROW_LEFT:String = "IMAGE_ICON_ARROW_LEFT";
		public static const IMAGE_ICON_ARROW_RIGHT:String = "IMAGE_ICON_ARROW_RIGHT";
		public static const IMAGE_ICON_MIC:String = "IMAGE_ICON_MIC";
		public static const IMAGE_ICON_PLAY:String = "IMAGE_ICON_PLAY";
		public static const IMAGE_BK_IPAD:String = "IMAGE_BK_IPAD";
		public static const IMAGE_LOAD_CIRCLE:String = "IMAGE_LOAD_CIRCLE";
		
		[Embed("../../../../res/image/icon/prev_left.png")]
		private static const ImageArrowLeft:Class;
		[Embed("../../../../res/image/icon/prev_right.png")]
		private static const ImageArrowRight:Class;
		[Embed("../../../../res/image/icon/prev_mic.png")]
		private static const ImageMic:Class;
		[Embed("../../../../res/image/icon/prev_play.png")]
		private static const ImagePlay:Class;
		[Embed("../../../../res/image/bk/bk.png")]
		private static const ImageIPad:Class;
		[Embed("../../../../res/image/load/circle.png")]
		private static const ImageLoadCircle:Class;

		public function ResourceProvider() {
			
		}
		
		public static function getImage(type:String):Bitmap {
			if (type == IMAGE_ICON_ARROW_LEFT) {
				return new ImageArrowLeft();
			}
			else if (type == IMAGE_ICON_ARROW_RIGHT) {
				return new ImageArrowRight();
			}
			else if (type == IMAGE_ICON_MIC) {
				return new ImageMic();
			}
			else if (type == IMAGE_ICON_PLAY) {
				return new ImagePlay();
			}
			else if (type == IMAGE_BK_IPAD) {
				return new ImageIPad();
			}
			else if (type == IMAGE_LOAD_CIRCLE) {
				return new ImageLoadCircle();
			}
			
			return null;
		}
	}
}