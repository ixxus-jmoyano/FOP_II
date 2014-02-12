module namespace MODEL = "http://ixxus.com/articlemodel";

declare function getXMLFromID($id){
	<WRAPPER>{fn:doc($id)}</WRAPPER>
};

declare function getArticleSummary($xml){
	$xml/article/summary
};	

declare function getArticleTitle($xml){
	fn:data($xml/article/title)
};	

declare function getArticleUri($xml){	
	fn:base-uri($xml)
};	