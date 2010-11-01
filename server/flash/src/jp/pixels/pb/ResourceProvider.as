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
		public static const IMAGE_ICON_UPLOAD:String = "IMAGE_ICON_UPLOAD";
		public static const IMAGE_ICON_TRASH:String = "IMAGE_ICON_TRASH";
		public static const IMAGE_BK_IPAD:String = "IMAGE_BK_IPAD";
		public static const IMAGE_LOAD_CIRCLE:String = "IMAGE_LOAD_CIRCLE";
		
		[Embed("../../../../../resource/image/icon/arrow-left.png")]
		private static const ImageArrowLeft:Class;
		[Embed("../../../../../resource/image/icon/arrow-right.png")]
		private static const ImageArrowRight:Class;
		[Embed("../../../../../resource/image/icon/upload.png")]
		private static const ImageUpload:Class;
		[Embed("../../../../../resource/image/icon/trash.png")]
		private static const ImageTrash:Class;
		[Embed("../../../../../resource/image/bk/ipad.png")]
		private static const ImageIPad:Class;
		[Embed("../../../../../resource/image/load/circle.png")]
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
			else if (type == IMAGE_ICON_UPLOAD) {
				return new ImageUpload();
			}
			else if (type == IMAGE_ICON_TRASH) {
				return new ImageTrash();
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