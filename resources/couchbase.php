<h1>Testing Couchbase Connectivity</h1>

<?php 
	$cb = new Couchbase("CB:8091", "", "", "default");
	$cb->set('a', 'hello world');
	$cb->set('b', 'have a nice day');
	$cb->set('c', json_encode(['testing','an','array','stored as JSON']));
	$cb->set('d', json_encode(['objects'=>'are real', 'reality'=>'check']));
	$cb->set('e', 1234);
	echo "<pre>";
	var_dump($cb->get('a'));
	var_dump($cb->get('b'));
	echo "";
	var_dump($cb->get('c'));
	var_dump($cb->get('d'));
	var_dump($cb->get('e'));
	echo "</pre>";
?>
	
<p>
	You should see the output of the Couchbase tests that were done. To see the five attributes go to the Couchbase
	admin screen and look at the "default" bucket documents.
</p>
