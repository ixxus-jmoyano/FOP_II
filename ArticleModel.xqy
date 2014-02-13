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

declare function getArticleSectionTitle($xml, $id){
	fn:data($xml/article//section[@id=$id]/child::*[1])
};	

declare function getArticleSection($xml, $id){
	$xml/article//section[@id=$id]
};	

declare function getArticleUri($xml){	
	fn:base-uri($xml)
};	

declare function getArticleId($xml){	
	$xml/article/@id
};	