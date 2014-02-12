function ShowArticle(articleItem)
{
	openWindow("ArticleDetails.xqy?articleUri=" + articleItem);
}

function openWindow(link)
{
	window.open(link, "NEW", "height=800,width=780,scrollbars=yes,location=no").focus();
}
