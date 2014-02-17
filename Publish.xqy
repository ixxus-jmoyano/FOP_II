import module namespace mem = "http://xqdev.com/in-mem-update" at "in-mem-update.xqy";
import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

(: TRANSACTION 1 - CREATE PUBLICATION XML :)

let $selectionsFile := xdmp:get-session-field($CONSTANTS:selectionsFile, "NONE")
let $publishTitle := xdmp:get-request-field($CONSTANTS:publicationTitle, "NONE")
let $log := xdmp:log(fn:concat("PUBLISH ARTICLE TITLE",$publishTitle))
let $xml :=
      <Publication>
        <title>{$publishTitle}</title>
        <h1>Index of Chapters</h1>
		<ul>
        {
          for $articleItem in $selectionsFile/item
			  let $article := MODEL:getXMLFromID($articleItem/text())
			  return
				  if($articleItem/@type="article") then
									<li>{MODEL:getArticleTitle($article)}</li>
								else
									<li>{MODEL:getArticleTitle($article)} ({MODEL:getArticleSectionTitle($article, $articleItem/@id)})</li>
        }
        </ul>
        <Articles>
        {
			for $item in $selectionsFile/item
				let $xml := MODEL:getXMLFromID($item/text())
				let $article := if($item/@type="article") then
									($xml)
								else
									let $section := MODEL:getArticleSection($xml, $item/@id)
									let $result := <articles><article type="article" id="{$item/@id}">
														<title>{MODEL:getArticleTitle($xml)} ({MODEL:getArticleSectionTitle($xml, $item/@id)})</title>
														<summary>{$section/content}</summary>
														{$section/sections}
													</article></articles>
									return
										$result
				return
					$article/article
        }
        </Articles>
      </Publication>
	let $save := xdmp:set-session-field($CONSTANTS:publicationFile, $xml)    
	return
		()
;


(: TRANSACTION 2 - SEND PUBLICATION TO ALFRESCO (to generate PDF and ePUB) :)
(:import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";
import module namespace CONFIG = "http://ixxus.com/ManageConfigs"  at "ManageConfigs.xqy";

let $publicationFile := xdmp:get-session-field($CONSTANTS:publicationFile, "NONE")
let $operation := xdmp:get-request-field("operation", "NONE")

let $SendXMLURL := CONFIG:getSendXMLURL()
let $UserName := CONFIG:getUserName()
let $Password := CONFIG:getPassword()
let $log := xdmp:log(fn:concat("SENDING XML TO [",$SendXMLURL,"] with user [",$UserName,"] and password [", $Password,"]"))
return
  if ($operation = "NONE")
  then
	try{
    let $XML := xdmp:quote( fn:doc($publicationFile) )
    let $Response :=
      xdmp:http-post($SendXMLURL,
                      <options xmlns="xdmp:http">
                        <authentication method="basic">
                          <username>{$UserName}</username>
                          <password>{$Password}</password>
                        </authentication>
                        <data>{$XML}</data>
                      </options>
                    )
    return
    (
      xdmp:log( fn:concat("RESPONSE: ", xdmp:quote($Response) ) )
    ,
      let $prefixURL := fn:concat( fn:substring-before($SendXMLURL, "alfresco/"), "alfresco/")
      let $results := $Response/result
      let $log := xdmp:log( fn:concat("GENERARING PDF URL FROM [" , xdmp:quote($results)  , "] w") )
      let $pdfId := fn:concat($prefixURL, fn:data($results/transformation[type="application/pdf"]/url/text()))
      let $epubId := fn:concat($prefixURL, fn:data($results/transformation[type="application/epub+zip"]/url/text()))
      let $savePathToPDF := xdmp:set-session-field("PDF_ID", $pdfId)
      let $savePathToEPUB := xdmp:set-session-field("EPUB_ID", $epubId)
	  return
        ( )
    )
	}catch($error){
		let $log := xdmp:log( fn:concat("ERROR: ", xdmp:quote($error/error:message) ) )
		return
			()
	}
  else
    ( )
;:)

import module 	namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";

import module namespace ELEMENTPROCESS = "http://ixxus.com/elementprocess" at "FormatController.xqy";

xdmp:set-response-content-type("text/html")
,
let $publicationFile := xdmp:get-session-field($CONSTANTS:publicationFile, <NONE/>)
return
  <html>
    <head>
	      <title>Publication Sample</title>
		  <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
		  <link rel="stylesheet" type="text/css" href="styles.css?refresh{current-dateTime()}" />
		  <meta http-equiv='Content-Type' content='text/html;charset=utf-8' />
		  <meta http-equiv="Expires" content="-1" />
		  <meta http-equiv="Pragma" content="no-cache"/>
		  <meta http-equiv="Cache-Control" content="no-cache"/>
		  <script type="text/javascript" src="scripts.js">&#160;</script>
		  <script type="text/javascript">function doPrint( ) {{ this.print() }} function doClose( ) {{ this.close() }}</script>
	</head>
	<body>
		<div class="articleModelDiv">
			{
			if($publicationFile/title/text()) then 
				<h1 class="article title">{$publicationFile/title/text()}</h1>
			else 
				<h1 class="article title">Publication File</h1>
			}
			<h3 class="article title section">Index of Chapters</h3>
			<p class="article summary">	
				<ul>
				{
				  for $ul in $publicationFile/ul
					  return
						$ul
				}
				</ul>
			</p>
			{
				for $article in $publicationFile/Articles 
					return
					<div class="articleModelDiv">
						{ELEMENTPROCESS:childrenInline($article, "N")}
					</div>
			}
		</div>
	</body>
</html>
