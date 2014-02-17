module namespace ELEMENTPROCESS = "http://ixxus.com/elementprocess";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";
import module namespace OPERATIONS = "http://ixxus.com/operations" at "Operations.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

declare function childrenInline ($node, $linkDisplay as xs:string)
{
  for $L as node() in $node/node() 
  return 
      loopInline($L, $linkDisplay)
};


declare function loopInline ($node as node(),  $linkDisplay as xs:string) 
{
typeswitch ($node)

	(: Element ignored :)
	case element(sub)
	 return
	   ()

	(: Element ignored :)
	case element(sup)
	 return
	   ()

	case element(i)
	 return
	   if ($node/node())
	   then
		 <i>{childrenInline($node, $linkDisplay)}</i>
	   else ( )
	
	case element(p)
	 return
	   if ($node/node())
	   then
		 <p>{childrenInline($node, $linkDisplay)}</p>
	   else ( )
	  
	case element(b)
	 return
	   if ($node/node())
	   then
		 <b>{childrenInline($node, $linkDisplay)}</b>
	   else ( )
		
	case $x as element(table)
	return
		if($x[@class!="navbox"]) then
			<table>{childrenInline($node, $linkDisplay)}</table>
		else
			()
			
	case $x as element(div)
	return
		if($x[fn:contains(./@class, "thumbinner")]) then
			(: Do something with the images:)
			<div>{childrenInline($node, $linkDisplay)}</div>
		else
			<div>{childrenInline($node, $linkDisplay)}</div>
	 
	case $x as element(tr)
	return
		if ($node/node())
		then
			<tr>{childrenInline($node, $linkDisplay)}</tr>
		else
			()
		
	case $x as element(td)
	return
		if ($node/node())
		then
			<td>{childrenInline($node, $linkDisplay)}</td>
		else
			()
			
	case $x as element(th)
	return
		if ($node/node())
		then
			<th>{childrenInline($node, $linkDisplay)}</th>
		else
			()
			
	case $x as element(ul)
	return
		if ($node/node())
		then
			<ul>{childrenInline($node, $linkDisplay)}</ul>
		else
			()
			
	case $x as element(li)
	return
		if ($node/node())
		then
			<li>{childrenInline($node, $linkDisplay)}</li>
		else
			()
			
						
	case $x as element(img)
	return
		if ($node/node())
		then
			<p><img class="article image" src="ImageLocator.xqy?image={$x/@src}"/></p>
		else
			()
	
	case $x as element(a)
	return
		if ($node/node())
		then
			<a onClick="javascript:navigateWithFormSubmission('ArticleDetails.xqy?{$CONSTANTS:articleUri}={$x/@href}', '{$CONSTANTS:hiddenForm}')" class="link">
				{childrenInline($node, $linkDisplay)}
			</a>
		else
			()
			
	case $x as element(content)
	return
		if ($node/node())
		then
			<p class="article section content">{childrenInline($node, $linkDisplay)}</p>
		else
		()
	
	case $x as element(summary)
	return
		<p class="article summary">{childrenInline($node, $linkDisplay)}</p>
		
	case $x as element(title)
	return
		(:Main article title:)
		
		let $id := $x/parent::*/@id
		return
		if ($x/parent::article) then
			<h1 class="article title" id="{$id}">{childrenInline($node, $linkDisplay)}</h1>
		else
		(:Nested section title:)
			if($x/parent::*/ancestor::section) then
				(
					let $articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
					return
					<h4 class="article title section" id="{$id}">
						{childrenInline($node, $linkDisplay)}
						{
						if($linkDisplay = "Y") then
							<a class="link" href="javascript:navigateWithFormSubmission('ArticleDetails.xqy?{$CONSTANTS:articleUri}={$articleUri}&amp;{$CONSTANTS:paramOperation}={$OPERATIONS:addArticleOp}&amp;{$CONSTANTS:articleSection}={$id}#{$id}', '{$CONSTANTS:hiddenForm}')">
								<img src="/Images/plus.png" width="15" title="Add Section to Publication"/>
							</a>
						else()
						}
					</h4>
				)
			(:Section title:)
			else
				let $articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
				return
				<h3 class="article title section" id="{$id}">
					{childrenInline($node, $linkDisplay)}
						{
						if($linkDisplay = "Y") then
							<a class="link" href="javascript:navigateWithFormSubmission('ArticleDetails.xqy?{$CONSTANTS:articleUri}={$articleUri}&amp;{$CONSTANTS:paramOperation}={$OPERATIONS:addArticleOp}&amp;{$CONSTANTS:articleSection}={$id}#{$id}', '{$CONSTANTS:hiddenForm}')">
								<img src="/Images/plus.png" width="15" title="Add Section to Publication"/>
							</a>
						else()
						}
				</h3>
			
	(: ********************************************************************* :)
	(: ****This part was used to display the triples as links or/images***** :)	
	(: ********************************************************************* :)
	(:
	case $x as element(linkedPages)
	return
	if(fn:count($x/triple)>0) then
		<span>
			<h3 class="article title section">Related Links</h3>
			{childrenInline($node, $linkDisplay)}
		</span>
	else
		()

	case $x as element(images)
	return
	if(fn:count($x/triple)>0) then
		<span>
			<h3 class="article title section">Related Images</h3>
			{childrenInline($node, $linkDisplay)}
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
						<a onClick="javascript:navigateWithFormSubmission('{$link/text()}', '{$CONSTANTS:hiddenForm}')" style="cursor:pointer">
							<img src="/Images/details_article.png" title="click to see full article" width="50"/>
						</a>
					</span>
				else
					()
	:)
	(: ********************************************************************* :)
	(: ********************************************************************* :)
	(: ********************************************************************* :)
	case $x as element(sem:triple)
	return
		()

	case text()
	 return
	   fn:data($node)

	default 
	 return
	   childrenInline($node, $linkDisplay)
};

declare function createIndex($node as node()){
	<p><b>{$node/ancestor::*}</b></p>
};