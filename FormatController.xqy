module namespace ELEMENTPROCESS = "http://ixxus.com/elementprocess";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";
import module namespace OPERATIONS = "http://ixxus.com/operations" at "Operations.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

declare function childrenInline ($node)
{
  for $L as node() in $node/node() 
  return 
      loopInline($L)
};


declare function loopInline ($node as node()) 
{
typeswitch ($node)

	case element(sub)
	 return
	   ()

	case element(sup)
	 return
	   ()

	case element(i)
	 return
	   if ($node/node())
	   then
		 <i>{childrenInline($node)}</i>
	   else ( )
	  
	case element(b)
	 return
	   if ($node/node())
	   then
		 <b>{childrenInline($node)}</b>
	   else ( )

	case $x as element(summary)
	return
		<p class="article summary">{childrenInline($node)}</p>
		
	case $x as element(table)
	return
		if($x[@class!="navbox"]) then
			<table>{childrenInline($node)}</table>
		else
			()
	 
	case $x as element(tr)
	return
		if ($node/node())
		then
			<tr>{childrenInline($node)}</tr>
		else
			()
		
	case $x as element(td)
	return
		if ($node/node())
		then
			<td>{childrenInline($node)}</td>
		else
			()
			
	case $x as element(th)
	return
		if ($node/node())
		then
			<th>{childrenInline($node)}</th>
		else
			()
			
	case $x as element(ul)
	return
		if ($node/node())
		then
			<ul>{childrenInline($node)}</ul>
		else
			()
			
	case $x as element(li)
	return
		if ($node/node())
		then
			<li>{childrenInline($node)}</li>
		else
			()
			
	case $x as element(content)
	return
		if ($node/node())
		then
			<p class="article section content">{childrenInline($node)}</p>
		else
		()
		
	case $x as element(title)
	return
		(:Main article title:)
		if ($x/parent::article) then
			<h1 class="article title">{childrenInline($node)}</h1>
		else
		(:Nested section title:)
		let $id := $x/parent::*/@id
		return
			if($x/parent::*/ancestor::section) then
				(
					let $articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
					return
					<h4 class="article title section" id="{$id}">
						{childrenInline($node)}
						<a class="link" href="ArticleDetails.xqy?{$CONSTANTS:articleUri}={$articleUri}&amp;{$CONSTANTS:paramOperation}={$OPERATIONS:addArticleOp}&amp;{$CONSTANTS:articleSection}={$id}#{$id}">
							<img src="/Images/plus.png" width="15" title="Add Section to Publication"/>
						</a>
					</h4>
				)
			(:Section title:)
			else
				let $articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
				return
				<h3 class="article title section" id="{$id}">
					{childrenInline($node)}
						<a class="link" href="ArticleDetails.xqy?{$CONSTANTS:articleUri}={$articleUri}&amp;{$CONSTANTS:paramOperation}={$OPERATIONS:addArticleOp}&amp;{$CONSTANTS:articleSection}={$id}#{$id}">
							<img src="/Images/plus.png" width="15" title="Add Section to Publication"/>
						</a>
				</h3>
			
			
	case $x as element(linkedPages)
	return
	if(fn:count($x/triple)>0) then
		<span>
			<h3 class="article title section">Related Links</h3>
			{childrenInline($node)}
		</span>
	else
		()

	case $x as element(images)
	return
	if(fn:count($x/triple)>0) then
		<span>
			<h3 class="article title section">Related Images</h3>
			{childrenInline($node)}
		</span>
	else
		()

	case $x as element(sem:triple)
	return
		let $link := $x/sem:subject
			return
				if($link/ancestor::triple/parent::images)then
					<img src="ImageLocator.xqy?image={$link/text()}" width="150"/>
				else
				if($link/ancestor::triple/parent::linkedPages) then
					<span>
						<span>{MODEL:getArticleTitle(MODEL:getXMLFromID($link/text()))}</span	>
						<a onClick="javascript:ShowArticle('{$link/text()}')" style="cursor:pointer">
							<img src="/Images/details_article.png" title="click to see full article" width="50"/>
						</a>
					</span>
				else
					()

	case text()
	 return
	   fn:data($node)

	default 
	 return
	   childrenInline($node)
};

declare function createIndex($node as node()){
	<p><b>{$node/ancestor::*}</b></p>
};