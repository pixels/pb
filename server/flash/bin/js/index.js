/**
 * @author Yusuke Kikkawa
 */
var swfctrl = swfctrl || {

	ref_ : null,

	init : function() {
		var flashvars = {
		};
		var params = {
			menu: "false",
			scale: "noScale",
			allowFullscreen: "true",
			allowScriptAccess: "always",
			bgcolor: "#FFFFFF"
		};
		var attributes = {
			id:"swf"
		};
		swfobject.embedSWF("as3PictureBooks.swf", "contentID", "970", "560", "10.0.0", "expressInstall.swf", flashvars, params, attributes, swfctrl.onFLState);
	},
	
	onFLState : function(e) {
		if(e.success) {
			ref_ = e.ref;
		}
	}
}

$(function() {
	swfctrl.init();
});

function jsInvoke(e) {
	alert("key: " + e.key + " value: " + e.value + " \nパブリッシュボタンが押されました。");
}

function onUserIDClick() {
	var userID = $("#userIDID").val();
	ref_.flInvoke({"key":"userID", "value":userID});
}
