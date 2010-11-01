<!doctype html>
<head>
	<meta name="language" content="jp" />
	<meta charset=utf-8 />
	<title>PBWeb list</title>
	<style type="text/css">
		img { width:5%; height:5%; border-style:solid; }
	</style>
</head>
<body>
<?php
	$BASE_DIRECTORY = "../upload";
	if (array_key_exists("directory",  $_GET)) {
		$dir = $BASE_DIRECTORY. "/". $_GET["directory"];
	}
	else {
		$dir = $BASE_DIRECTORY. "/";
	}
	
	if ($tmp = opendir($dir)) {
		while ($file = readdir($tmp)) {
			if ($file != "." && $file != "..") {
				$path = $dir. "/". $file; 
				if (is_dir($path)) {
					echo "<a href='list.php". "?directory=". $file. "'>". $file. "</a>";
				}
				else {
					echo "<img src='". $path. "'></img>". "<br>";
				}
			}
		}
		closedir($dir);
	}
?>
</body>
</html>
