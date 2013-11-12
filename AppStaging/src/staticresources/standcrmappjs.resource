$j = jQuery.noConflict();

$j(document).ready(function() {
	if (navigator.appName == 'Microsoft Internet Explorer') {
		$j('#standcrmapp').addClass('ie');
	}
	$j('<div class="preload"></div>').appendTo('#standcrmapp');
});