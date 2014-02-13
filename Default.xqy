import module namespace OPERATIONS = "http://ixxus.com/operations" at "Operations.xqy";

if (xdmp:get-current-user() = "BAPAS-unknown")
then
  ( )
else
	OPERATIONS:doOperations(xdmp:get-request-field("operation", "NONE"))
,

xdmp:log(fn:concat("Operation performed [",xdmp:get-request-field("operation"),"]"));

import module namespace OPERATIONS = "http://ixxus.com/operations" at "Operations.xqy";

import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";

xdmp:set-response-content-type("text/html"),
<html>
	<head>
		<title>Future of Publishing II</title>
	    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
		<meta http-equiv='Content-Type' content='text/html;charset=utf-8' />
		<meta http-equiv="Expires" content="-1" />
		<meta http-equiv="Pragma" content="no-cache"/>
		<meta http-equiv="Cache-Control" content="no-cache"/>
		<link rel="stylesheet" type="text/css" href="./styles.css"/>
		<script type="text/javascript" src="scripts.js">&#160;</script>
	</head>
	<body>
		<div class="containerDiv">
			<div class="searchDiv">
				<form method="post" name="Search" action="Default.xqy">
				{					
					let $searchTerm := xdmp:get-request-field($CONSTANTS:searchTerm, "")
					let $searchType := xdmp:get-request-field($CONSTANTS:searchType, "all")
						return
						<div class="searchBoxDiv">
							<div id="configDiv">
								<a onClick="javascript:openWindow('Configuration.xqy')" class="link">
									<img src="/Images/config.png" title="Change Configuration"/>
								</a>
							</div>
							<div>
								<h1 class="article title">Find:
									<input type="text" name="searchTerm" value="{$searchTerm}"/>
									<input type="button" class="actionButton" value="Search" onclick="javascript:document.Search.submit()"/>
								</h1>
							</div>
							<div class="searchOptionsDiv">
								<h5>Within:
									<input type="radio" name="{$CONSTANTS:searchType}" value="all" class="radioSearch">{if($searchType = "all") then attribute checked { "yes" } else ()}</input><span class="searchSpan">All</span>
									<input type="radio" name="{$CONSTANTS:searchType}" value="title" class="radioSearch">{if($searchType = "title") then attribute checked { "yes" } else ()}</input><span class="searchSpan">Title</span>
									<input type="radio" name="{$CONSTANTS:searchType}" value="summary" class="radioSearch">{if($searchType = "summary") then attribute checked { "yes" } else ()}</input><span class="searchSpan">Summary</span>
									<input type="radio" name="{$CONSTANTS:searchType}" value="content" class="radioSearch">{if($searchType = "content") then attribute checked { "yes" } else ()}</input><span class="searchSpan">Content</span>
									<input type="radio" name="{$CONSTANTS:searchType}" value="location" class="radioSearch">{if($searchType = "location") then attribute checked { "yes" } else ()}</input><span class="searchSpan">Location</span>
									<input type="radio" name="{$CONSTANTS:searchType}" value="semantics" class="radioSearch">{if($searchType = "semantics") then attribute checked { "yes" } else ()}</input><span class="searchSpan">Semantics</span>
								</h5>
							</div>
						</div>
				}
				</form>
			</div>
			{
			(: Results after performing search :)
			let $searchType := xdmp:get-request-field($CONSTANTS:searchType, "")
			let $searchTerm := xdmp:get-request-field($CONSTANTS:searchTerm, "")
				return
			<div class="resultsDiv">
				<div class="resultsLeftDiv">
					{
					if($searchType = "") then
						<h1>No Search Performed</h1>
					else
						if($searchTerm = "") then
							<h1>No Term in search</h1>
						else
							for $result in if ($searchType = "all")
								then
								 /article[cts:contains(., cts:word-query($searchTerm, "case-insensitive"))]
								else
								if ($searchType = "title")
								then
								 /article[cts:contains(./title, cts:word-query($searchTerm, "case-insensitive"))]
								else
								if ($searchType = "summary")
								then
								 /article[cts:contains(./summary, cts:word-query($searchTerm, "case-insensitive"))]
								else
								if ($searchType = "content")
								then
								 /article[cts:contains(./sections//section/content, cts:word-query($searchTerm, "case-insensitive"))]
								else
								if ($searchType = "location")
								then
								 /article[cts:contains(./title, cts:word-query($searchTerm, "case-insensitive"))]
								else
								if ($searchType = "semantics")
								then
								 /article[cts:contains(./title, cts:word-query($searchTerm, "case-insensitive"))]
								else
									()
								let $uri := MODEL:getArticleUri($result)
								let $article := MODEL:getXMLFromID($uri)
									return
									<div class="resultItemDiv">
										<h1 class="article title">
											{MODEL:getArticleTitle($article)}
										</h1>
										{
										if (fn:string-length(MODEL:getArticleSummary($article)) > 400) then
											<p class="article summary">{fn:concat(fn:substring($article, 0, 400), "...")}</p>
										else
											<p class="article summary">{MODEL:getArticleSummary($article)}</p>
										}						
										<div style="text-align:center">
											<a href="Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:addArticleOp}&amp;{$CONSTANTS:articleUri}={$uri}&amp;{$CONSTANTS:searchType}={$searchType}&amp;{$CONSTANTS:searchTerm}={$searchTerm}">
												<img src="/Images/add_article.png" title="add article" width="50"/>
											</a>
											<a onClick="javascript:ShowArticle('{$uri}')" class="link">
												<img src="/Images/details_article.png" title="click to see full article" width="50"/>
											</a>
										</div>
									</div>
					}	
				</div>				
				<div class="resultsRightDiv">
				{
					let $selection := xdmp:get-session-field($CONSTANTS:selectionsFile, "NONE")
					return
						if($selection != "NONE" and fn:count( $selection/item) !=0 ) then
							<div class="resultItemDiv">
								<h1 class="article title">
									Items Selected
								</h1>
								<h3 class="article title section" style="display:inline;">
									Title:<input type="text" id="{$CONSTANTS:publicationTitle}"/>
									<input type="button" class="actionButton" value="Generate Publication" onclick="javascript:openWindow('Publish.xqy?{$CONSTANTS:publicationTitle}=' + document.getElementById('{$CONSTANTS:publicationTitle}').value)"/>
								</h3>
									{
									for $item in $selection/item
										let $article := MODEL:getXMLFromID($item/text())
										return	
										<div style="overflow:auto;">
											{if($item[@type="section"]) then
													<div class="resultsLeftDiv"><p class="article summary">{MODEL:getArticleTitle($article)}[Section: {MODEL:getArticleSectionTitle($article, $item/@id)}]</p></div>
												else
													<div class="resultsLeftDiv"><p class="article summary">{MODEL:getArticleTitle($article)}</p></div>
											}
											<div class="resultsRightDiv">
											<a href="Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:removeArticleOp}&amp;{$CONSTANTS:articleUri}={$item/text()}&amp;{$CONSTANTS:searchType}={$searchType}&amp;{$CONSTANTS:searchTerm}={$searchTerm}">
												<img src="/Images/remove_article.png" title="remove article" width="50"/>
											</a>
											<a href="Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:upArticleOp}&amp;{$CONSTANTS:articleUri}={$item/text()}&amp;{$CONSTANTS:searchType}={$searchType}&amp;{$CONSTANTS:searchTerm}={$searchTerm}">
												<img src="/Images/up_article.png" title="up article" width="50"/>
											</a>
											<a href="Default.xqy?{$CONSTANTS:paramOperation}={$OPERATIONS:downArticleOp}&amp;{$CONSTANTS:articleUri}={$item/text()}&amp;{$CONSTANTS:searchType}={$searchType}&amp;{$CONSTANTS:searchTerm}={$searchTerm}">
												<img src="/Images/down_article.png" title="down article" width="50"/>
											</a>
											</div>
										</div>
									}
							</div>	
						else
							()
				}		
				</div>
			</div>
		}<!-- From the resultsLeftDiv -->
		</div>
	</body>
</html>