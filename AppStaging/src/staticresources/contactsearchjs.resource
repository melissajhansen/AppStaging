function blurAll() {
	$j('input').blur();
}
function CheckSearchFields()
{
	if ($j('input[id*=txtFirstName]').val() == 'First Name' 
		&& $j('input[id*=txtLastName]').val() == 'Last Name' 
		&& $j('input[id*=txtCity]').val() == 'City' 
		&& $j('select[id*=lstState]').val() == '' 
		&& $j('input[id*=txtEmail]').val() == 'Email' 
		&& $j('input[id*=txtPhone]').val() == 'Phone' 
		&& $j('input[id*=txtZip]').val() == 'Zip')
	{
		alert("Please enter at least one field to search contacts.");
		$j('input[id*=hdnSearch]').val('false');
		return false;
	}
	$j('input[id*=hdnSearch]').val('true');
	return true;
}
function Change(objText, event)
{
	if (event.type == "focus")
	{
		objText.style.color = "black";
		if (objText.id.indexOf("txtFirstName") != -1 && objText.value == 'First Name')
			objText.value = '';
		else if (objText.id.indexOf("txtLastName") != -1 && objText.value == 'Last Name')
			objText.value = '';
		else if (objText.id.indexOf("txtCity") != -1 && objText.value == 'City')
			objText.value = '';
		else if (objText.id.indexOf("txtEmail") != -1 && objText.value == 'Email')
			objText.value = '';
		else if (objText.id.indexOf("txtPhone") != -1 && objText.value == 'Phone')
			objText.value = '';
		else if (objText.id.indexOf("txtZip") != -1 && objText.value == 'Zip')
			objText.value = '';
	}
	else if (event.type == "blur")
	{
		if (objText.id.indexOf("txtFirstName") != -1)
		{
			if (objText.value == 'First Name')
			{
				objText.style.color = 'grey';
			}
			else if (objText.value == '')
			{
				objText.style.color = 'grey';
				objText.value = 'First Name';
			}
		}
		else if (objText.id.indexOf("txtLastName") != -1)
		{
			if (objText.value == 'Last Name')
			{
				objText.style.color = 'grey';
			}
			else if (objText.value == '')
			{
				objText.style.color = 'grey';
				objText.value = 'Last Name';
			}
		}
		else if (objText.id.indexOf("txtCity") != -1)
		{
			if (objText.value == 'City')
			{
				objText.style.color = 'grey';
			}
			else if (objText.value == '')
			{
				objText.style.color = 'grey';
				objText.value = 'City';
			}
		}
		else if (objText.id.indexOf("lstState") != -1)
		{
			if (objText.value == '')
			{
				objText.style.color = 'grey';
			}
		}
		else if (objText.id.indexOf("txtEmail") != -1)
		{
			if (objText.value == 'Email')
			{
				objText.style.color = 'grey';
			}
			else if (objText.value == '')
			{
				objText.style.color = 'grey';
				objText.value = 'Email';
			}
		}
		else if (objText.id.indexOf("txtPhone") != -1)
		{
			if (objText.value == 'Phone')
			{
				objText.style.color = 'grey';
			}
			else if (objText.value == '')
			{
				objText.style.color = 'grey';
				objText.value = 'Phone';
			}
		}
		if (objText.id.indexOf("txtZip") != -1)
		{
			if (objText.value == 'Zip')
			{
				objText.style.color = 'grey';
			}
			else if (objText.value == '')
			{
				objText.style.color = 'grey';
				objText.value = 'Zip';
			}
		}
	}
}
function DisplayContacts(event)
{
	if (window.event && window.event.keyCode == 13 || event.which == 13)
	{
		GetContacts();
		return false;
	}
	else
	{
		return true;
	}
}

function contactSearchSubmit() {
	var searchButton = $j('a.button.search');
	
	$j(searchButton).addClass('loading');
	if (CheckSearchFields()) {
		return true;
	} else {
		$j(searchButton).removeClass('loading');
		return false;
	}
}

$j(document).ready(function() {
	var form = $j('form[id*=find_a_contact]');
	/*var advancedSearchLink = $j('a#advanced-search-link');
	
	advancedSearchLink.click(function() {
		if (form.hasClass('advanced')) {
			form.removeClass('advanced');
			$j('#advanced-search input').val('').blur();
			$j('input[id*=txtFirstName]').val('').blur();
			$j(this).html('Advanced Search');
		} else {
			form.addClass('advanced');
			$j(this).html('Simple Search');
		}
		return false;
	});*/
	
	// If the form is already filled out:
	if ($j('input[id*=txtFirstName]').val() != 'First Name' 
		|| $j('input[id*=txtCity]').val() != 'City' 
		|| $j('select[id*=lstState]').val() != '' 
		|| $j('input[id*=txtEmail]').val() != 'Email' 
		|| $j('input[id*=txtPhone]').val() != 'Phone' 
		|| $j('input[id*=txtZip]').val() != 'Zip')
	{
		advancedSearchLink.click();
	}
	
	$j('input').blur();
	window.setTimeout(blurAll, 800);
});