
(: TRANSACTION 1 - CREATE PUBLICATION XML AND STORE IN DATABASE :)

let $SelectionsFile := fn:concat( "Selections_", xdmp:get-session-field("LogInCode", "NONE"), ".xml")
let $PublicationFile := fn:concat( "Publication_", xdmp:get-session-field("LogInCode", "NONE"), ".xml")
let $Operation := xdmp:get-request-field("Operation", "NONE")
return
  if ($Operation = "NONE")
  then
    let $PublishTitle := xdmp:get-request-field("PublishTitle", "NONE")
    let $AllRecipies := fn:doc($SelectionsFile)/SelectedRecipies/Selected/text()
    let $XML :=
      <Publication>
        <Title>{$PublishTitle}</Title>
        <TOC>
        {
          for $OneRecipe in $AllRecipies
          let $RecipeTitle := fn:doc($OneRecipe)/Recipe/RecipeTitle/text()
          return
            <Entry>{$RecipeTitle}</Entry>
        }
        </TOC>
        <Recipies>
        {
          for $OneRecipe in $AllRecipies
          let $Recipe := fn:doc($OneRecipe)/Recipe
          return
            $Recipe
        }
        </Recipies>
      </Publication>
    return
      xdmp:document-insert($PublicationFile, $XML)
  else
    ( )
    
;


(: TRANSACTION 2 - SEND PUBLICATION TO ALFRESCO (to generate PDF and ePUB) :)

import module namespace CONFIG = "http://ixxus.com/ManageConfigs"  at "ManageConfigs.xqy";

let $PublicationFile := fn:concat( "Publication_", xdmp:get-session-field("LogInCode", "NONE"), ".xml")
let $Operation := xdmp:get-request-field("Operation", "NONE")

let $SendXMLURL := CONFIG:GetSendXMLURL()
let $UserName := CONFIG:GetUserName()
let $Password := CONFIG:GetPassword()
let $_ := xdmp:log(fn:concat("SENDING XML TO [",$SendXMLURL,"] with user [",$UserName,"] and password [", $Password,"]"))
return
  if ($Operation = "NONE")
  then  
    let $XML := xdmp:quote( fn:doc($PublicationFile) )
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
  else
    ( )


(: WAIT FOR RESPONSE :)


;


(: TRANSACTION 3 - PRESENT PUBLICATION ON-SCREEN :)

declare namespace LOCAL = "http://LOCAL" ;

declare function LOCAL:PresentParaLoop($ParentNode)
{
  for $Node in $ParentNode/node()
  return
    LOCAL:PresentPara($Node)
};

declare function LOCAL:PresentPara($Node)
{
  typeswitch ($Node)
  
    case element(Bold)
      return
        <b>{LOCAL:PresentParaLoop($Node)}</b>
    case text()
      return
        fn:data($Node)
    default
      return
        LOCAL:PresentParaLoop($Node)
};


xdmp:set-response-content-type("text/html")

,

"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,

let $PublishTitle := xdmp:get-request-field("PublishTitle", "NONE")
return
  <html>
    <head>
      <title>Recipe for {$PublishTitle} </title>
      <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
      <link rel="stylesheet" type="text/css" href="styles.css?refresh{current-dateTime()}" />
      <meta http-equiv='Content-Type' content='text/html;charset=utf-8' />
      <meta http-equiv="Expires" content="-1" />
      <meta http-equiv="Pragma" content="no-cache"/>
      <meta http-equiv="Cache-Control" content="no-cache"/>
      <script type="text/javascript" src="Javascript.js">&#160;</script>
      <script type="text/javascript">function doPrint( ) {{ this.print() }} function doClose( ) {{ this.close() }}</script>
      <script language="JavaScript">      
        function ShowHideNextDiv(obj, text)
        {{
          var sibling;

          if(obj.nextSibling.nodeType==3)
          {{
            sibling=obj.nextSibling.nextSibling;
          }}
          else
          {{
            sibling=obj.nextSibling;
          }}
          if (sibling.style.display=='none')
          {{
            sibling.style.display='block';
            obj.firstChild.firstChild.data='hide ' + text;
          }}
          else
          {{
            sibling.style.display='none';
            obj.firstChild.firstChild.data='show ' + text;
          }}
        }}

      </script>
    </head>

    <body style="background-color:white">
      <div class="BoxLabel" style="text-align:center;font-size:32px">{$PublishTitle}&#160;</div>
      <div style="text-align:center;margin-bottom:50px;margin-top:50px;font-size:16px">
        <a target="_blank" class="PublishPDFLink" href="DownloadPDF.xqy">&#160;&#160;DOWNLOAD PDF&#160;&#160;</a>
        &#160;&#160;&#160;&#160;
        <a target="_blank" class="PublishPDFLink" href="DownloadEPUB.xqy">&#160;&#160;DOWNLOAD ePUB&#160;&#160;</a>
      </div>
    {
      let $SelectionsFile := fn:concat( "Selections_", xdmp:get-session-field("LogInCode", "NONE"), ".xml")
      for $OneRecipe in fn:doc($SelectionsFile)/SelectedRecipies/Selected/text()
      let $Recipe := fn:doc($OneRecipe)/Recipe
      return
        <div style="margin-top:20px">
          <!-- <div style="font-size:24px;margin-top:25px;margin-bottom:16px;text-align:center;color:white;background-color:#E99DE9;">{$Recipe/RecipeTitle/text()}</div> -->
          <div class="RecipeTitle" style="margin-bottom:0px;border-top-style:solid;border-top-width:2px;border-top-color:purple;padding-top:3px">
            <img src="ImageLocator.xqy?image={fn:data($Recipe/RecipePicture/@href)}"/> 
            &#160;&#160; 
            <span style="vertical-align:20px;font-size:27px">{$Recipe/RecipeTitle/text()}</span>
          </div>

          <div class="Para" style="text-align:right;margin-top:0px" onclick="ShowHideNextDiv(this,'- Recipe')">
            <b class="SimulatedLink">show - Recipe</b>
          </div>

          <div style="display:none">
            <div style="margin:10px;padding:5px">
            {
              for $Para in $Recipe/RecipeOverview/Para
              return
                <div style="margin-top:5px">
                {
                  LOCAL:PresentParaLoop($Para)
                }
                </div>
            }
            </div>


            <div style="margin-top:20px;width:510px;padding:5pt;background-color:#F7F7F7">

              <div class="BoxLabel">Ingredients</div>

              <table width="410px">
                <tbody>
                  <col width="200px" />
                  <col width="10px" />
                  <col width="100px" />

                  {
                    for $Ingredient in $Recipe/RecipeIngredients/RecipeIngredient
                    return
                      <tr>

                        <td>
                          <div style="font-size:14px;margin-top:9px;margin-left:4pt">
                            {$Ingredient/IngredientName/text()}
                          </div>
                        </td>
                        <td></td>
                        <td>
                          <div style="font-size:14px;margin-top:9px;margin-left:4pt">
                            {$Ingredient/IngredientQuantity/text()}
                          </div>
                        </td>
                      </tr>        
                   }
                </tbody>
              </table>
            </div>

          <div style="margin-top:20px;width:510px;padding:5pt;background-color:#F0F0F7">

            <div class="BoxLabel">Method</div>
              <ol>
              {
                for $Instruction in $Recipe/RecipeInstructions/RecipeInstruction
                return
                  <li>
                    <div style="font-size:13px;margin-top:5px;">{$Instruction/text()}</div>
                  </li>
              }            
              </ol>
            </div>
          </div>
            

        </div>
    }
    </body>
  </html>
