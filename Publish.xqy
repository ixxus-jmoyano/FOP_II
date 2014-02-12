import module namespace mem = "http://xqdev.com/in-mem-update" at "in-mem-update.xqy";
import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

(: TRANSACTION 1 - CREATE PUBLICATION XML :)

let $selectionsFile := xdmp:get-session-field($CONSTANTS:selectionsFile, "NONE")
let $publishTitle := xdmp:get-request-field("PublishTitle", "NONE")
let $xml :=
      <Publication>
        <Title>{$publishTitle}</Title>
        <TOC>
        {
          for $articleUri in $selectionsFile/item/text()
			  let $article := MODEL:getXMLFromID($articleUri)
			  return
				<Entry>{MODEL:getArticleTitle($article)}</Entry>
        }
        </TOC>
        <Articles>
        {
          for $articleUri in $selectionsFile/item/text()
		  let $article := MODEL:getXMLFromID($articleUri)
          return
            $article/article
        }
        </Articles>
      </Publication>
let $_ := xdmp:set-session-field($CONSTANTS:publicationFile, $xml)    
	return
		()
;


(: TRANSACTION 2 - SEND PUBLICATION TO ALFRESCO (to generate PDF and ePUB) :)
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";
import module namespace CONFIG = "http://ixxus.com/ManageConfigs"  at "ManageConfigs.xqy";

let $publicationFile := xdmp:get-session-field($CONSTANTS:publicationFile, "NONE")
let $operation := xdmp:get-request-field("operation", "NONE")

let $SendXMLURL := CONFIG:getSendXMLURL()
let $UserName := CONFIG:getUserName()
let $Password := CONFIG:getPassword()
let $_ := xdmp:log(fn:concat("SENDING XML TO [",$SendXMLURL,"] with user [",$UserName,"] and password [", $Password,"]"))
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
      let $PrefixURL := fn:concat( fn:substring-before($SendXMLURL, "alfresco/"), "alfresco/")
      let $Results := $Response/result
      let $_ := xdmp:log( fn:concat("GENERARING PDF URL FROM [" , xdmp:quote($Results)  , "] w") )
      let $PDF_ID := fn:concat($PrefixURL, fn:data($Results/transformation[type="application/pdf"]/url/text()))
      let $EPUB_ID := fn:concat($PrefixURL, fn:data($Results/transformation[type="application/epub+zip"]/url/text()))
      let $SavePathToPDF := xdmp:set-session-field("PDF_ID", $PDF_ID)
      let $SavePathToEPUB := xdmp:set-session-field("EPUB_ID", $EPUB_ID)
      return
        ( )
    )
	}catch($error){
		xdmp:log( fn:concat("ERROR: ", xdmp:quote($error) ) )
	}
  else
    ( )
(: WAIT FOR RESPONSE :)
;

import module 	namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";

import module namespace ELEMENTPROCESS = "http://ixxus.com/elementprocess" at "FormatController.xqy";

xdmp:set-response-content-type("text/html")
,
let $publicationFile := xdmp:get-session-field($CONSTANTS:publicationFile, "NONE")
return
  <html>
    <head>
	      <title>{$publicationFile/Title}</title>
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
		<h1 class="article title">{$publicationFile/Title}</h1>
		{
		for $article in $publicationFile/Articles 
			return
			<div class="articleModelDiv">
				{ELEMENTPROCESS:childrenInline($article)}
			</div>
		}
	</body>
</html>
