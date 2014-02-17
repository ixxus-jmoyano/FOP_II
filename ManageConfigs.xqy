module namespace CONFIG = "http://ixxus.com/ManageConfigs" ;


declare variable $IN_FOLDER := "C:/InDesignHub/IDML_IN/";
declare variable $WATCHED_FOLDER := "C:/InDesignHub/IDML_WATCH/";
declare variable $OUT_FOLDER := "C:/InDesignHub/IDML_OUT/";



declare function getUserName()
{
  if (fn:doc("/Config/Settings.xml")/Configs/UserName/text())
  then
    fn:doc("/Config/Settings.xml")/Configs/UserName/text()
  else
    "admin"
};

declare function getPassword()
{
  if (fn:doc("/Config/Settings.xml")/Configs/Password/text())
  then
    fn:doc("/Config/Settings.xml")/Configs/Password/text()
  else
    "admin"
};


declare function getSendXMLURL()
{
  if (fn:doc("/Config/Settings.xml")/Configs/SendXMLURL/text())
  then
    fn:doc("/Config/Settings.xml")/Configs/SendXMLURL/text()
  else
    "http://localhost:8080/alfresco/service/ml/transformations"
};

declare function setData($UserName, $Password, $SendXMLURL)
{
  (:
  let $XML := <Configs>
                <UserName>{$UserName}</UserName>
                <Password>{$Password}</Password>
                <SendXMLURL>{$SendXMLURL}</SendXMLURL>                
                <GetPDFURL>{$GetPDFURL}</GetPDFURL>
                <GetEPUBURL>{$GetEPUBURL}</GetEPUBURL>
              </Configs>
  :)
  let $XML := <Configs>
                <UserName>{$UserName}</UserName>
                <Password>{$Password}</Password>
                <SendXMLURL>{$SendXMLURL}</SendXMLURL>
              </Configs>
  return              
    if (fn:doc("/Config/Settings.xml"))
    then
      xdmp:node-replace(fn:doc("/Config/Settings.xml")/Configs, $XML)
    else
      xdmp:document-insert("/Config/Settings.xml", $XML)
};


