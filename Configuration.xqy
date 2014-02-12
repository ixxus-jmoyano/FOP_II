import module namespace OPERATIONS   = "http://ixxus.com/operations"  at "Operations.xqy";
import module namespace CONFIG       = "http://ixxus.com/ManageConfigs"        at "ManageConfigs.xqy";

declare option xdmp:output "method=html";

declare variable $operation := xdmp:get-request-field("Operation", "NONE") ;

if (xdmp:get-current-user() = "BAPAS-unknown")
then
  ( )
else
  OPERATIONS:doOperations($operation)

,

xdmp:log(fn:concat("COMPLETED OPERATION ", $operation))

;


import module namespace CONFIG             = "http://ixxus.com/ManageConfigs"       at "ManageConfigs.xqy";

declare namespace LOCAL = "http://LOCAL" ;


declare variable $_User            := xdmp:get-current-user() ;
declare variable $_UserName        := substring($_User, 7) ;


xdmp:set-response-content-type("text/html")
,


"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,

if (xdmp:get-current-user() = "BAPAS-unknown")
then
  xdmp:redirect-response( "default.xqy" )
else

<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
    <link rel="stylesheet" type="text/css" href="styles.css?refresh{current-dateTime()}" />
    <meta http-equiv='Content-Type' content='text/html;charset=utf-8' />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Pragma" content="no-cache"/>
    <meta http-equiv="Cache-Control" content="no-cache"/>
    <script type="text/javascript" src="Javascript.js">&#160;</script>
  </head>

  <body>
      
      <div class="Panel">
         <div class="PanelHeader">Alfresco Interaction Settings</div>    
         <h3 class="article title section">Enter username and password, and call to return PDF and ePUB</h3>
         <div style="margin-left:20px">
           <div class="Para">             
           {
             let $name := CONFIG:getUserName()
             let $password := CONFIG:getPassword()
             let $sendXMLURL := CONFIG:getSendXMLURL()
             return
               <form name="ChangeCredentials" style="margin:0px;" method="post" action="Configuration.xqy">
                 <input type="hidden" name="Operation" value="ChangeAlfrescoCredentials"/>

                 <h3 class="article title section">
                   Name:
                   <input type="text" size="120" style="font-size:11px;" name="UserName" value="{$name}"></input>
                 </h3>

                 <h3 class="article title section">
                   Password:
                   <input type="text" size="120" style="font-size:11px;" name="Password" value="{$password}"></input>
                 </h3>

                 <h3 class="article title section">
                   URL To Send XML:
                   <input type="text" size="120" style="font-size:11px;" name="SendXMLURL" value="{$sendXMLURL}"></input>
                 </h3>

                 <input type="button" value="Update" class="actionButton" onClick="submit()"/>
               </form>
           }
           </div>            
         </div>
      </div>
  </body>
</html>