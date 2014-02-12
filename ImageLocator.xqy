let $imageUri := fn:data(xdmp:get-request-field("image", "NONE"))
return
	if($imageUri = "NONE") then
	()
	else
	(	
		if(fn:ends-with($imageUri, ".jpeg")) 
		then
		(
			xdmp:set-response-content-type("image/jpeg"),
			fn:doc($imageUri)
		)
		else
		if(fn:ends-with($imageUri, ".jpg")) 
		then
		(
			xdmp:set-response-content-type("image/jpeg"),
			fn:doc($imageUri)
		)
		else
		if(fn:ends-with($imageUri, ".gif")) 
		then
		(
			xdmp:set-response-content-type("image/gif"),
			fn:doc($imageUri)
		)
		else
		if(fn:ends-with($imageUri, ".png")) 
		then
		(
			xdmp:set-response-content-type("image/png"),
			fn:doc($imageUri)
		)
		else
		()
	)