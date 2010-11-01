<?php
	require_once ("util.php");
	
	define ("WORKING_DIRECTORY", "../upload/");
	define ("START_INDEX", 1);
	define ("FIGURE", "4");
	define ("EXTENSION", ".jpg");

	$directory = WORKING_DIRECTORY;
	if (array_key_exists("directory",  $_POST)) {
		$directory = WORKING_DIRECTORY. $_POST["directory"];
	}
	$start_index = intval(validArray("start_index", $_POST, START_INDEX));
	$figure = validArray("figure", $_POST, FIGURE);
	$extension = validArray("extension", $_POST, EXTENSION);
	
	$result= "status=ng";
	$index = START_INDEX;
	if ($tmp = opendir($directory)) {
		while ($file = readdir($tmp)) {
			if ($file != "." && $file != "..") {
				$path = $directory. "/". $file;
				$rename = $directory. "/". sprintf("%0". $figure. "d", $index++). ".". $extension;
				if (file_exists($path)) {
					rename($path, $rename);
				}
			}
		}
		closedir($directory);
		$result = "status=ok";
	}
	
	echo $result;
?>
