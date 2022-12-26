<?php
# PHP script load .html files in upload directory and move them to results directory with special syntax. Also backup historical files.
header( 'Cache-Control: max-age=0,no-store');
$_path    = './upload';
$_resultPath    = './files';
$_fileType = array('html', 'htm', 'xml');
$splitsVersion = array('Mezičasy', 'Splits');

class MySimpleXMLElement extends SimpleXMLElement
{
    public function addProcessingInstruction($target, $data = NULL) {
        $node   = dom_import_simplexml($this);
        $pi     = $node->ownerDocument->createProcessingInstruction($target, $data);
        $result = $node->insertBefore($pi, $node->childNodes->item(0));
        return $this;
    }
}

// Move results to live directory and create data file
$filesForProcessing = getDirContents($_path, $_fileType);
foreach ($filesForProcessing as $key => $file) {
	if (filesize($_path . DIRECTORY_SEPARATOR . $file['basename']) > 2000000) {
		echo "Error: File is too large!";
		rename($_path . DIRECTORY_SEPARATOR . $file['basename'], $_path . DIRECTORY_SEPARATOR . 'error' . DIRECTORY_SEPARATOR . $file['basename']);
		continue;
	}
	if($file['extension'] === 'html' || $file['extension'] === 'htm') {
		$dom = new DOMDocument();
		libxml_use_internal_errors(true);
		$dom->loadHTML(file_get_contents($_path . DIRECTORY_SEPARATOR . $file['basename']));
		libxml_use_internal_errors(false);
		$headings1 = $dom->getElementsByTagName('h1');
		$headings2 = $dom->getElementsByTagName('h2');
		$competitionName = explode(',', $headings1[0]->nodeValue);
		$splits = in_array($competitionName[1], $splitsVersion) ? true : false;
		$competitionName = $competitionName[0];
		$competitionId = date('Y_m_d_', strtotime($headings2[0]->nodeValue)) . str_replace(' ', '_', sanitize(htmlspecialchars($competitionName)));
		$competitionInfo = array(
			'id' => $competitionId,
			'name' => $competitionName,
			'date' => date('Y-m-d', strtotime($headings2[0]->nodeValue)),
			'splits' => $splits,
			'extension' => $file['extension'],
			'lastUpdate' => date('Y-m-d H:i:s'),
		);
		$head = $dom->getElementsByTagName('head')->item(0);
		$metaElementList = $dom->getElementsByTagName('meta');
		$refreshNode = false;
		foreach ($metaElementList as $element) {
			if($element->getAttribute('http-equiv') === 'refresh') {
				$refreshNode = true;
			}
		}
		if(!$refreshNode) {
			$refresh = $dom->createElement('meta');
			$refresh->setAttribute('http-equiv','refresh');
			$refresh->setAttribute('content','60;url=');
			$head->appendChild($refresh);
		}
		$cacheControl = $dom->createElement('meta');
		$cacheControl->setAttribute('http-equiv','Cache-Control');
		$cacheControl->setAttribute('content','no-cache, no-store, must-revalidate');
		$head->appendChild($cacheControl);
		
		$pragma = $dom->createElement('meta');
		$pragma->setAttribute('http-equiv','Pragma');
		$pragma->setAttribute('content','no-cache');
		$head->appendChild($pragma);
		
		$expires = $dom->createElement('meta');
		$expires->setAttribute('http-equiv','Expires');
		$expires->setAttribute('content','0');
		$head->appendChild($expires);
		file_put_contents($_path . DIRECTORY_SEPARATOR . $file['basename'], $dom->saveHTML(), LOCK_EX);
	} else if($file['extension'] === 'xml') {
 		$xml = simplexml_load_string(file_get_contents($_path . DIRECTORY_SEPARATOR . $file['basename']), 'MySimpleXMLElement');
		$competitionName = (string) $xml->Event->Name;
		$competitionDate = (string) $xml->Event->StartTime->Date;
		// Read the XML file into a string
		$xmlString = file_get_contents($_path . DIRECTORY_SEPARATOR . $file['basename']);
		$xmlHeader = preg_split('#\r?\n#', ltrim($xmlString), 2)[0];
		$xmlContent = preg_split('#\r?\n#', ltrim($xmlString), 2)[1];
		// Add the XML stylesheet header at the beginning of the string
		$xmlString = $xmlHeader . "\n<?xml-stylesheet type='text/xsl' href='../xsl/simple_results_iofv3.xsl'?>\n" . $xmlContent; 
		$competitionId = date('Y_m_d_', strtotime($competitionDate)) . str_replace(' ', '_', sanitize(htmlspecialchars($competitionName)));
		$competitionInfo = array(
			'id' => $competitionId,
			'name' => $competitionName,
			'date' => date('Y-m-d', strtotime($competitionDate)),
			'extension' => $file['extension'],
			'lastUpdate' => date('Y-m-d H:i:s'),
		);
		// Write the modified string back to the XML file
		file_put_contents($_path . DIRECTORY_SEPARATOR . $file['basename'], $xmlString, LOCK_EX);
	}
	file_put_contents($_path . DIRECTORY_SEPARATOR . $competitionId.'.txt', serialize($competitionInfo), FILE_APPEND | LOCK_EX);
	rename($_path . DIRECTORY_SEPARATOR . $file['basename'], $_resultPath . DIRECTORY_SEPARATOR . $competitionId . '.' . $file['extension']);
	rename($_path . DIRECTORY_SEPARATOR . $competitionId.'.txt', $_resultPath . DIRECTORY_SEPARATOR . $competitionId . '.txt');
	chmod($_resultPath . DIRECTORY_SEPARATOR . $competitionId . '.' . $file['extension'], 0775);
	echo $competitionName;		
	
}
// Backup 1 day old results
$liveResultsList = getDirContents($_resultPath, array('txt'));
foreach ($liveResultsList as $key => $file) {
	$data = file_get_contents($_resultPath . DIRECTORY_SEPARATOR . $file['basename']);
	$resultsInfo = unserialize($data);
	if (strtotime($resultsInfo['lastUpdate']) + 86400 < time()) {
		rename($_resultPath . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.' . $resultsInfo['extension'], $_resultPath . DIRECTORY_SEPARATOR . 'backup' . DIRECTORY_SEPARATOR . date('Y', strtotime($resultsInfo['lastUpdate'])) . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.' . $resultsInfo['extension']);
		rename($_resultPath . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.txt', $_resultPath . DIRECTORY_SEPARATOR . 'backup' . DIRECTORY_SEPARATOR . date('Y', strtotime($resultsInfo['lastUpdate'])) . DIRECTORY_SEPARATOR . $resultsInfo['id'] . '.txt');
		echo "Move to backup";
	}
}



function getDirContents($dir, $fileType = array('html'), &$results = array()) {
    $files = scandir($dir);
    $index = 1;
	foreach ($files as $key => $value) {
        $path = realpath($dir . DIRECTORY_SEPARATOR . $value);
        if (!is_dir($path)) {
			$file_parts = pathinfo($path);
			if (in_array($file_parts["extension"], $fileType, true)) {
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

function sanitize($string, $force_lowercase = true, $anal = false, $trunc = 100) {
	$strip = array("~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "=", "+", "[", "{", "]",
				   "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;",
				   "—", "–", ",", "<", ".", ">", "/", "?");
	$clean = trim(str_replace($strip, "", strip_tags($string)));
	$clean = preg_replace('/\s+/', "-", $clean);
	$clean = ($anal ? preg_replace("/[^a-zA-Z0-9]/", "", $clean) : $clean);
	$clean = ($trunc ? substr($clean, 0, $trunc) : $clean);
	return ($force_lowercase) ?
		(function_exists('mb_strtolower')) ?
			mb_strtolower($clean, 'UTF-8') :
			strtolower($clean) :
		$clean;
}

?>