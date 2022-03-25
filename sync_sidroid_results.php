<?php
# PHP script load .html files in upload directory and move them to results directory with special syntax. Also backup historical files.
$_path    = './upload';
$_resultPath    = './results';

// Move results to live directory and create data file
$filesForProcessing = getDirContents($_path);
foreach ($filesForProcessing as $key => $file) {
	if (filesize($_path . DIRECTORY_SEPARATOR . $file['basename']) > 2000000) {
		echo "Error: File is too large!";
		rename($_path . DIRECTORY_SEPARATOR . $file['basename'], $_path . DIRECTORY_SEPARATOR . 'error' . DIRECTORY_SEPARATOR . $file['basename']);
		continue;
	}
	$dom = new DOMDocument();
	libxml_use_internal_errors(true);
	$dom->loadHTML(file_get_contents($_path . DIRECTORY_SEPARATOR . $file['basename']));
	libxml_use_internal_errors(false);
	$headings1 = $dom->getElementsByTagName('h1');
	$headings2 = $dom->getElementsByTagName('h2');
	$competitionName = explode(',', $headings1[0]->nodeValue)[0];
	$competitionId = date('Y_m_d_', strtotime($headings2[0]->nodeValue)) . str_replace(' ', '_', $competitionName);
	$competitionInfo = array(
		'id' => $competitionId,
		'name' => $competitionName,
		'date' => date('Y-m-d', strtotime($headings2[0]->nodeValue)),
		'lastUpdate' => date('Y-m-d H:i:s'),
	);
	$head = $dom->getElementsByTagName('head')->item(0);
	$refresh = $dom->createElement('meta');
	$refresh->setAttribute('http-equiv','refresh');
	$refresh->setAttribute('content','10;url=');
	$head->appendChild($refresh);
	file_put_contents($_path . DIRECTORY_SEPARATOR . $file['basename'], $dom->saveHTML(), LOCK_EX);
	file_put_contents($_path . DIRECTORY_SEPARATOR . $competitionId.'.txt', serialize($competitionInfo), FILE_APPEND | LOCK_EX);
	rename($_path . DIRECTORY_SEPARATOR . $file['basename'], $_resultPath . DIRECTORY_SEPARATOR . $competitionId . '.' . $file['extension']);
	rename($_path . DIRECTORY_SEPARATOR . $competitionId.'.txt', $_resultPath . DIRECTORY_SEPARATOR . $competitionId . '.txt');
	chmod($_resultPath . DIRECTORY_SEPARATOR . $competitionId . '.' . $file['extension'], 0775);
	echo $competitionName;		
	
}
// Backup 1 day old results
$liveResultsList = getDirContents($_resultPath, 'txt');
foreach ($liveResultsList as $key => $file) {
	$data = file_get_contents($_resultPath . DIRECTORY_SEPARATOR . $file['basename']);
	$resultsInfo = unserialize($data);
	if (strtotime($resultsInfo['lastUpdate']) + 86400 < time()) {
		rename($_resultPath . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.html', $_resultPath . DIRECTORY_SEPARATOR . 'backup' . DIRECTORY_SEPARATOR . date('Y', strtotime($resultsInfo['lastUpdate'])) . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.html');
		rename($_resultPath . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.txt', $_resultPath . DIRECTORY_SEPARATOR . 'backup' . DIRECTORY_SEPARATOR . date('Y', strtotime($resultsInfo['lastUpdate'])) . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.txt');
		echo "Move to backup";
	}
}



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
								   'basename' => $file_parts["basename"],
								   'extension' => $file_parts["extension"]
								   );
			}
			$index++;
        } 
    }

    return $results;
}

?>