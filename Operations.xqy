module namespace OPERATIONS = "http://ixxus.com/operations";
import module namespace mem = "http://xqdev.com/in-mem-update" at "in-mem-update.xqy";
import module namespace CONSTANTS = "http://ixxus.com/constants" at "Constants.xqy";
import module namespace CONFIG = "http://ixxus.com/ManageConfigs" at "ManageConfigs.xqy";


(: Operation Add Article to the composed Article :)
declare variable $addArticleOp as xs:string := "addArticle";

(: Operation Remove Article to the composed Article :)
declare variable $removeArticleOp as xs:string := "removeArticle";

(: Operation change the position of the article by giving it a higher position :)
declare variable $upArticleOp as xs:string := "upArticle";

(: Operation change the position of the article by giving it a lower position :)
declare variable $downArticleOp as xs:string := "downArticle";

(: Operation change Alfresco Credentials :)
declare variable $changeCredentials as xs:string := "ChangeAlfrescoCredentials";


declare function doOperations($operation)
{	
	let $generatedDocument := xdmp:get-session-field($CONSTANTS:composedArticle, "NONE")
	let $CONSTANTS:articleUri := xdmp:get-request-field($CONSTANTS:articleUri, "NONE")
	let $log := xdmp:log(fn:concat("Operation: [",$operation,"] Article Uri [",$CONSTANTS:articleUri,"], generatedDocument[",$generatedDocument, "]"))
	return 
		if($operation = $addArticleOp) then 
			(		
			if($generatedDocument = "NONE") then
					xdmp:set-session-field($CONSTANTS:composedArticle, <sessionwrapper><item>{$CONSTANTS:articleUri}</item></sessionwrapper>) 	
				else
					if(cts:contains($generatedDocument/item, $CONSTANTS:articleUri)) then
						xdmp:log(fn:concat("The article ", $CONSTANTS:articleUri, " has already been added"))
					else
						let $insert :=  mem:node-insert-child( $generatedDocument, <item>{$CONSTANTS:articleUri}</item>)
						let $log := xdmp:log(fn:concat("Document Generated [",$insert,"]"))
						let $save := xdmp:set-session-field($CONSTANTS:composedArticle, $insert) 		
						return
							()
			)
		else
		if($operation = $removeArticleOp) then 
			(
			if(cts:contains($generatedDocument/item, $CONSTANTS:articleUri)) then
				(
				let $save := xdmp:set-session-field($CONSTANTS:composedArticle, mem:node-delete($generatedDocument/item[text()=$CONSTANTS:articleUri])) 
					return
					()
				)
			else
				()
			)
		else
		if($operation = $upArticleOp) then 
			(
			let $node := $generatedDocument/item[text()=$CONSTANTS:articleUri]
			let $upperNode := $node/preceding-sibling::item[1]
			return
				if($upperNode) then
					let $generatedDocument := mem:node-delete($node)
					let $upperNode := $generatedDocument/item[text()=fn:data($upperNode)]
					let $generatedDocument := mem:node-insert-before($upperNode, $node)
					let $save := xdmp:set-session-field($CONSTANTS:composedArticle, $generatedDocument) 		
					return
						()
				else
					()
			)
		else
		if($operation = $downArticleOp) then 
			(
			let $node := $generatedDocument/item[text()=$CONSTANTS:articleUri]
			let $nextNode := $node/following-sibling::item[1]
			return
				if($nextNode) then
					let $generatedDocument := mem:node-delete($node)
					let $nextNode := $generatedDocument/item[text()=fn:data($nextNode)]
					let $generatedDocument := mem:node-insert-after($nextNode, $node)
					let $save := xdmp:set-session-field($CONSTANTS:composedArticle, $generatedDocument) 		
					return
						()
				else
					()
			)
		else
		 if ($operation=$changeCredentials) then
			CONFIG:setData(xdmp:get-request-field("UserName"), 
						   xdmp:get-request-field("Password"),
						   xdmp:get-request-field("SendXMLURL"))
		  else
		  ()
};