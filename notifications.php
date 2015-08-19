#!/usr/local/bin/php -q

<?php	
//params
$subject = $argv[1];
$description = $argv[2];
$build = $argv[3];
$cc = $argv[4];
$attach = $argv[5];
$userid = $argv[6];


if ($argc<2) {
  echo "
usage: $prog <subject> <description> [<cc> [<filename> [userid]]]
where: subject     = one line of text.
       description = one or more lines of text, may have embedded URLs.
	   build	   = The name of the build that was ran.
       cc          = optional list of space separated email addresses.
       attach    = optional file name including full path for attachment.
       userid      = optional CM Unix user login id.
";
  exit;
}


//Check if next args are null
if (is_null($cc) || is_null($attach) || is_null($userid) ){
//initialize to empty strings

if (is_null($cc)){
$cc="";}
else if (is_null($attach)){
$attach = "No attachment";
}
else if (is_null($userid)){
$userid="";
}

exit;
}


//Emails
$from_email = 'ds.ehelp.api@cdk.com';
$to_email = 'division.support@cdk.com';


$message = "
Last name = Admin 
First Name = WSP 
User ID = por_wspadmin 
Email address = DS_PORWSPAdmin@adp.com 
Work OrgUnit = POR 
Source=Email
Type of Case = Request 
Number affected = Individual 
Level of Impact = Little impact, workaround available 
Category = R&D Applications 
Sub Category = RPS (Unix/CoRa Release Production) 
Sub Set = Other 
Severity = Medium 
Assignees = POR__bRPS \n
Build Request for $build

";

// Build the start of header including message.
$uniq=md5(uniqid(time()));
$header="From: $from_email
Cc: $cc
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"".$uniq."\"
This is a multi-part message in MIME format.
--".$uniq."
Content-type:text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

".$message."
";

// Build attachment into header if there is an attachment.
if (trim($attach)!='') {
  if (!file_exists($attach)) {
    echo "File: $attach does not exist, submission aborted!\n";
    exit;
  }

  # Determine path and filename from attachment parameter.
  $filepart=pathinfo($attach);
  $filename=$filepart['basename'];
  $filesize=filesize($attach);

  # Read attachment.
  $handle=fopen($attach,"r");
  $content=fread($handle,$filesize);
  fclose($handle);

  # Encode attachment.
  $content=chunk_split(base64_encode($content));

  # Append attachment to header.
  $header.="
--".$uniq."
Content-Type: application/octet-stream; name=\"".$filename."\"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"".$filename."\"

".$content."
";
}

	mail($to_email, $subject, '', $header);
	
	
?>