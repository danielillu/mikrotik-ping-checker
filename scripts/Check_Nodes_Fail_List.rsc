## editable
:local maildestination user_a@domain1.com; 
:local maildestination2 user_b@domain2.com;
:local pingretries 4;
:local pingthres 4;
## end of editable section
##
:local NodeList Nodes;
:local NodeWarningList Nodes_Warning;
:local NodeFailList Nodes_Fail;
:local senderName [/system identity get name]; 
:local runtime ([/system clock get time] . " " . [/system clock get date]);
##
:foreach node in=[/ip firewall address-list find list=$NodeFailList] do={
	:local destinationAddr [/ip firewall address-list get $node address];
	:local destinationName [/ip firewall address-list get $node comment];
	:local pingcount ([/ping $destinationAddr count=$pingretries]);

	:if ($pingcount = $pingthres) do={
		/ip firewall address-list set $node list=$NodeList;
## logging section
		:local logText ("WORKING: " . $destinationName . " (" . $destinationAddr . ")");
		:log error ($logText . " " . $runtime);
## send mail section
		:local mailsubject ("WORKING: " . $destinationName . " (" . $destinationAddr . ")");
		:local mailtext ("S'ha reestablert la comunicació amb: \r\n\t" . $destinationName . " " . $destinationAddr \
		. "\r\nA les " . $runtime . "\r\n\r\n" \
		. $senderName . "\r\n \
		Network Monitor");
		/tool e-mail send to=$maildestination subject=$mailsubject body=$mailtext start-tls=yes;
		/tool e-mail send to=$maildestination2 subject=$mailsubject body=$mailtext start-tls=yes;
	}
}