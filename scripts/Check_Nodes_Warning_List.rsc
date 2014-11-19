## editable
:local pingretries 4;
:local pingthres 4;
:local host "192.168.6.200";
:local path "/hipchat/ipalerts.php";
## end of editable section
##
:local NodeList Nodes;
:local NodeWarningList Nodes_Warning;
:local NodeFailList Nodes_Fail;
:local senderName [/system identity get name]; 
:local runtime ([/system clock get time] . " " . [/system clock get date]);
##
:foreach node in=[/ip firewall address-list find list=$NodeWarningList] do={
	:local destinationAddr [/ip firewall address-list get $node address];
	:local destinationName [/ip firewall address-list get $node comment];
	:local pingcount ([/ping $destinationAddr count=$pingretries]);

	:if ($pingcount = 0) do={
		/ip firewall address-list set $node list=$NodeFailList;
## logging section
		:local logText ("FAIL: " . $destinationName . " (" . $destinationAddr . ")");
		:log error ($logText . " " . $runtime);
## http notification
		:do {
			:local status "down";
			:local from "unstable";
			:local params "dst_name=$destinationName&dst_address=$destinationAddr&status=$status&from=$from";
			:local url "http://$host$path\?$params";
			:tool fetch keep-result=no url="$url";} on-error={:log error "Cannot notify via http";};
	} else={
		if ($pingcount = $pingthres) do={
			/ip firewall address-list set $node list=$NodeList;
## logging section
			:local logText ("Stable: " . $destinationName . " (" . $destinationAddr . ")");
			:log info ($logText . " " . $runtime);
## http notification
			:do {
				:local status "up";
				:local from "unstable";
				:local params "dst_name=$destinationName&dst_address=$destinationAddr&status=$status&from=$from";
				:local url "http://$host$path\?$params";
				:tool fetch keep-result=no url="$url";} on-error={:log error "Cannot notify via http";};
		} else={
## logging section
			:local logText ("Partially failed: " . $destinationName . " (" . $destinationAddr . ")");
			:log warning ($logText . " " . $runtime);
## http notification
			:do {
				:local status "unstable";
				:local from "unstable";
				:local params "dst_name=$destinationName&dst_address=$destinationAddr&status=$status&from=$from";
				:local url "http://$host$path\?$params";
				:tool fetch keep-result=no url="$url";} on-error={:log error "Cannot notify via http";};
		}
	}
}