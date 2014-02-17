function openWindow(link)
{
	window.open(link, "NEW", "height=800,width=780,scrollbars=yes,location=no").focus();
}

function navigateWithFormSubmission(page, formId){
	var formToSubmit = document.getElementsByName(formId)[0];
	formToSubmit.action = page;
	formToSubmit.submit();
}