<?php
	require_once ("util.php");
	
	define ("WORKING_DIRECTORY", "../upload/");
	define ("AS_PARAM_NAME", "Filedata");
	
	$directory = WORKING_DIRECTORY;
	if ($_POST["directory"] != "") {
		$directory = WORKING_DIRECTORY. $_POST["directory"]. "/";
	}
	$filename = $_FILES[AS_PARAM_NAME]["name"];
	if ($_POST["filename"] != "") {
		$filename = $_POST["filename"];
	}
	$tmp_name = $_FILES[AS_PARAM_NAME]["tmp_name"];
	
	createDirectory($directory);
	
	/*
	echo "name: ".      $_FILES[AS_PARAM_NAME]["name"]. "<br>";
	echo "type: ".      $_FILES[AS_PARAM_NAME]["type"]. "<br>";
	echo "size: ".      $_FILES[AS_PARAM_NAME]["size"]. "<br>";
	echo "tmp_name: ".  $_FILES[AS_PARAM_NAME]["tmp_name"]. "<br>";
	echo "error: ".     $_FILES[AS_PARAM_NAME]["error"]. "<br>";
	echo "directory: ". $directory. " tmp_name: ". $tmp_name. " filename: ". $filename. "<br>";
	*/

	$result= "status=ng";
	if (is_uploaded_file($tmp_name)) {
		$path = $directory. $filename;
		if (move_uploaded_file($tmp_name, $path)) {
			chmod($path, 0644);
			$result = "status=ok";
		}
	}
	
	echo $result;
?>
