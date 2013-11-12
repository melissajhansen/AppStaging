function attachSelectEvents() {
	// Paragraph containers around the <select>s
	var stateP = $j('p#choose-state');
	var chapterP = $j('p#choose-chapter');
	var teamP = $j('p#choose-team');
	
	// <select> tags
	var stateSelect = $j('select.state-select');
	var chapterSelect = $j('select.chapter-select');
	var teamSelect = $j('select.team-select');
	
	// Buttons
	var viewMembersButton = $j('a[id*=cmdViewMembers]');
	
	// Attach select change events
	stateSelect.change(function() {
		if ($j(this).val() != '') {
			chapterP.removeClass('disabled');
			// Loading data is slow. Visualforce clears attached events from selects. Must try to reattach the event after delay.
			// Bad programming. Can't find a callback for the Visualforce rerender.
			window.setTimeout(attachSelectEvents, 1500);
			window.setTimeout(attachSelectEvents, 3000);
		} else {
			viewMembersButton.addClass('disabled');
			chapterP.addClass('disabled');
			teamP.addClass('disabled');
		}
	});
	chapterSelect.change(function() {
		if ($j(this).val() != '') {
			viewMembersButton.removeClass('disabled');
			teamP.removeClass('disabled');
			// Loading data is slow. Visualforce clears attached events from selects. Must try to reattach the event after delay.
			// Bad programming. Can't find a callback for the Visualforce rerender.
			window.setTimeout(attachSelectEvents, 1500);
			window.setTimeout(attachSelectEvents, 3000);
		} else {
			viewMembersButton.addClass('disabled');
			teamP.addClass('disabled');
		}
	});
	
	// Enable or disable the View Members button
	if (stateSelect.val() == '' || chapterSelect.val() == '') {
		viewMembersButton.addClass('disabled');
	} else {
		viewMembersButton.removeClass('disabled');
	}
}
function enablePrintAndDownloadButtons() {
	var printButton = $j('a[id*=cmdPrint]');
	var downloadButton = $j('a[id*=cmdDownload]');
	
	printButton.removeClass('disabled');
	downloadButton.removeClass('disabled');
}

// TODO: merge these functions into one generic function
// Will need to make sure it's correctly passing in the click event
function viewMembersSubmit() {
	// Makes sure the button isn't disabled
	var viewMembersButton = $j('a[id*=cmdViewMembers]');
	
	if (viewMembersButton.hasClass('disabled')) {
		return false;
	} else {
		viewMembersButton.addClass('loading');
		return true;
	}
}
function printSubmit() {
	// Makes sure the button isn't disabled
	var printButton = $j('a[id*=cmdPrint]');
	
	if (printButton.hasClass('disabled')) {
		return false;
	} else {
		printButton.addClass('loading');
		window.setTimeout(function() {printButton.removeClass('loading');}, 1000);
		return true;
	}
}
function downloadSubmit() {
	// Makes sure the button isn't disabled
	var downloadButton = $j('a[id*=cmdDownload]');
	
	if (downloadButton.hasClass('disabled')) {
		return false;
	} else {
		downloadButton.addClass('loading');
		window.setTimeout(function() {downloadButton.removeClass('loading');}, 1000);
		return true;
	}
}

function addNotes() {
	$j("<div id='member-lists-note' class='note'></div><div id='contact-search-note' class='note'></div>").appendTo('#standcrmapp');
}

$j(document).ready(function() {
	// Paragraph containers around the <select>s
	var stateP = $j('p#choose-state');
	var chapterP = $j('p#choose-chapter');
	var teamP = $j('p#choose-team');
	
	// <select> tags
	var stateSelect = $j('select.state-select');
	var chapterSelect = $j('select.chapter-select');
	var teamSelect = $j('select.team-select');
	
	// Buttons
	var viewMembersButton = $j('a[id*=cmdViewMembers]');
	
	addNotes();
	
	// Hide currently-irrelevant options
	if (stateSelect.val() == '') {
		chapterP.addClass('disabled');
	} else {
		chapterP.removeClass('disabled');
	}
	if (chapterSelect.val() == '') {
		teamP.addClass('disabled');
	} else {
		teamP.removeClass('disabled');
	}
	
	// Attach select change events
	attachSelectEvents();
	if (stateSelect.val() == '' || chapterSelect.val() == '') {
		viewMembersButton.addClass('disabled');
	}
	
	// Enable print and download buttons
	window.setTimeout(enablePrintAndDownloadButtons, 1500);
});