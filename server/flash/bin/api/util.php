<?php

	function createDirectory($dir) {
		if(!is_dir($dir)) {
			umask(0);
			$rc = mkdir($dir, 0777, true);
		}
	}
	
	function validArray($key, $array, $default) {
	
		if (array_key_exists($key,  $array) && ($array[$key] != "")) {
			return $array[$key];
		}
			
		return $default;
	}
?>
