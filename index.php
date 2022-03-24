<?php
$_path    = './results';
$resultsList = getDirContents($_path, 'txt');
?>

<!DOCTYPE HTML>
<html>
    <head>
    <title>Si-Droid Results</title>
    <meta charset="UTF-8">
    </head>
    <body>
		<h1>Si-Droid Live Results</h1>
		<table>
			<thead>
				<th>Datum</th>
				<th>Název</th>
				<th>Poslední aktualizace</th>
			</thead>
			<tbody>
				<?php
				foreach ($resultsList as $key => $file) {
					$data = file_get_contents($_path . DIRECTORY_SEPARATOR . $file['basename']);
					$resultsInfo = unserialize($data);
					
					echo "<td>" . $resultsInfo['date'] . "</td><td><a href='./results/".$resultsInfo['id']. ".html'>" . $resultsInfo['name'] . "</a></td><td>" . $resultsInfo['lastUpdate'] . "</td>";
					
					
				}
				?>
			</tbody>
		</table>
    </body>
</html>


<?php
function getDirContents($dir, $fileType = 'html', &$results = array()) {
    $files = scandir($dir);
    $index = 1;
	foreach ($files as $key => $value) {
        $path = realpath($dir . DIRECTORY_SEPARATOR . $value);
        if (!is_dir($path)) {
			$file_parts = pathinfo($path);
			if ($file_parts["extension"] === $fileType) {
				$results[] = array('path' => $path,
								   'filename' => $file_parts["filename"],
								   'basename' => $file_parts["basename"]
								   );
			}
			$index++;
        } 
    }

    return $results;
}
?>