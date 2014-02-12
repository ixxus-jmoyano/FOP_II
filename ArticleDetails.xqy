import module 	namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";

import module namespace MODEL = "http://ixxus.com/articlemodel" at "ArticleModel.xqy";

import module namespace ELEMENTPROCESS = "http://ixxus.com/elementprocess" at "FormatController.xqy";

xdmp:set-response-content-type("text/html")
,
let $articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
let $article := MODEL:getXMLFromID($articleUri)
return
  <html>
    <head>
	      <title>{MODEL:getArticleTitle($article)}</title>
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
			{ELEMENTPROCESS:childrenInline($article)}
		</div>
	</body>
</html>