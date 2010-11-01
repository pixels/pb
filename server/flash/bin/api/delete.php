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
	
	$result= "status=ng";
	$path = $directory. $filename;
	if (file_exists($path)) {
		if (unlink($path)) {
		  $result = "status=ok";
		}
	}
	
	echo $result;
?>
