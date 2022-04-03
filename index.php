<?php
header( 'Cache-Control: max-age=0,no-store');
$_path    = './files';
$resultsList = getDirContents($_path, 'txt');
?>

<!DOCTYPE HTML>
<html>
    <head>
		<title>SI-Droid Results</title>
		<meta charset="UTF-8">
		<meta name="description" content="SI-Droid live results page.">
		<meta name="keywords" content="SI, droid, results, výsledky, online, live, ob, orienteering, ol">
		<meta name="author" content="Martin Křivda">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="refresh" content="60">
		<link rel="stylesheet" href="https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css"/>
    </head>
    <body>
		<div class="pa4">
			<div class="overflow-auto">
				<h1 class="f1 lh-title">SI-Droid Live Results</h1>
				<input type="text" id="searchField" onkeyup="searchFunction()" placeholder="Hledej podle názvu události .." class="input-reset ba b--black-20 pa2 mb4 db w-100 mw8" />
				<table class="f6 w-100 mw8" cellspacing="0" id="competitionsTable">
					<thead>
						<tr>
							<th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Datum</th>
							<th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Název</th>
							<th class="fw6 bb b--black-20 tl pb3 pr3 bg-white">Poslední aktualizace</th>
						</tr>
					</thead>
					<tbody class="lh-copy">
						<?php
						foreach ($resultsList as $key => $file) {
							$data = file_get_contents($_path . DIRECTORY_SEPARATOR . $file['basename']);
							$resultsInfo = unserialize($data);
							
							echo "<tr><td class='pv3 pr3 bb b--black-20'>" . $resultsInfo['date'] . "</td><td class='pv3 pr3 bb b--black-20'><a href='./". $_path ."/".$resultsInfo['id']. ".html'>" . htmlspecialchars($resultsInfo['name']) . "</a></td><td class='pv3 pr3 bb b--black-20'>" . htmlspecialchars($resultsInfo['lastUpdate']) . "</td></tr>";
							
							
						}
						?>
					</tbody>
				</table>
			 </div>
		</div>
		
		<script type="text/javascript">
			function searchFunction() {
			  // Declare variables
			  var input, filter, table, tr, td, i, txtValue;
			  input = document.getElementById("searchField");
			  filter = input.value.toUpperCase();
			  table = document.getElementById("competitionsTable");
			  tr = table.getElementsByTagName("tr");

			  // Loop through all table rows, and hide those who don't match the search query
			  for (i = 0; i < tr.length; i++) {
				td = tr[i].getElementsByTagName("td")[1];
				if (td) {
				  txtValue = td.textContent || td.innerText;
				  if (txtValue.toUpperCase().indexOf(filter) > -1) {
					tr[i].style.display = "";
				  } else {
					tr[i].style.display = "none";
				  }
				}
			  }
			}
		</script>

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