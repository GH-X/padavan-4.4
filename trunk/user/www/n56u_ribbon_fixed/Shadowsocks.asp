<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_16#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>

<script>
<% shadowsocks_status(); %>
<% rules_count(); %>

var $j = jQuery.noConflict();

$j(document).ready(function(){
	init_itoggle('ss_enable');
	init_itoggle('ss_type');
	init_itoggle('ss_mode');
	init_itoggle('ss_udp');
	init_itoggle('ss_local_port');
	init_itoggle('ss_mtu');
	init_itoggle('ss_timeout');
	init_itoggle('ss_watchcat_autorec');
	init_itoggle('ss_update_chnroute');
	init_itoggle('chnroute_url');
	init_itoggle('ss_custom_chnroute');
	init_itoggle('ss_update_gfwlist');
	init_itoggle('gfwlist_url');
	init_itoggle('ss_custom_gfwlist');
	init_itoggle('ss_dns_local_port');
	init_itoggle('ss_dns_remote_server');
	init_itoggle('dns_forwarder_enable');
	init_itoggle('ss-tunnel_enable');
	init_itoggle('ss-tunnel_mtu');
});

function initial(){
	show_banner(3);
	show_menu(5,11,1);
	show_footer();
	change_ss_mode();
	fill_ss_status(shadowsocks_status());
	fill_ss_tunnel_status(shadowsocks_tunnel_status());
	fill_ss_forwarder_status(dnsforwarder_status());
	$("chnroute_count").innerHTML = '<#menu5_16_4#>&nbsp;&nbsp;' + chnroute_count() ;
	$("gfwlist_count").innerHTML = '<#menu5_16_4#>&nbsp;&nbsp;' + gfwlist_count() ;
}

function change_ss_mode(){
	var v = document.form.ss_mode.value; //0=global 1=chnroute 2=gfwlist
	showhide_div('row_diversion_rate', (v == 2));
}

function applyRule(){
	showLoading();
	document.form.action_mode.value = " Restart ";
	document.form.current_page.value = "/Shadowsocks.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

function submitInternet(v){
	showLoading();
	document.Shadowsocks_action.action = "/Shadowsocks_action.asp";
	document.Shadowsocks_action.connect_action.value = v;
	document.Shadowsocks_action.submit();
}

function fill_ss_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("ss_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

function fill_ss_tunnel_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("ss_tunnel_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

function fill_ss_forwarder_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("dnsforwarder_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}
</script>

<style>
.nav-tabs > li > a {
    padding-right: 6px;
    padding-left: 6px;
}
.spanb{
    overflow:hidden;
　　text-overflow:ellipsis;
　　white-space:nowrap;
}
</style>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
	
    <input type="hidden" name="current_page" value="Shadowsocks.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="ShadowsocksConf;">
    <input type="hidden" name="group_id" value="SssList">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top"><#menu5_16#> - <#menu5_16_0#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <table width="100%" cellpadding="0" cellspacing="0" class="table">
                                        <tr> <th width="50%"><#menu5_16_5#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="ss_enable_on_of">
                                                        <input type="checkbox" id="ss_enable_fake" <% nvram_match_x("", "ss_enable", "1", "value=1 checked"); %><% nvram_match_x("", "ss_enable", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="ss_enable" id="ss_enable_1" <% nvram_match_x("", "ss_enable", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="ss_enable" id="ss_enable_0" <% nvram_match_x("", "ss_enable", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%" style="border-top: 0 none;"><#running_status#></th>
                                            <td style="border-top: 0 none;" id="ss_status"></td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_6#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="ss_watchcat_autorec_on_of">
                                                        <input type="checkbox" id="ss_watchcat_autorec_fake" <% nvram_match_x("", "ss_watchcat_autorec", "1", "value=1 checked"); %><% nvram_match_x("", "ss_watchcat_autorec", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="ss_watchcat_autorec" id="ss_watchcat_autorec_1" <% nvram_match_x("", "ss_watchcat_autorec", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="ss_watchcat_autorec" id="ss_watchcat_autorec_0" <% nvram_match_x("", "ss_watchcat_autorec", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%" style="border-top: 0 none;"><#InetControl#></th>
                                            <td style="border-top: 0 none;">
                                                <input type="button" id="btn_connect_1" class="btn btn-info" value="<#Connect#>" onclick="submitInternet('Reconnect');">
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_7#></th>
                                            <td>
                                                <select name="ss_type" class="input" style="width: 145px">
                                                    <option value="9" <% nvram_match_x("","ss_type", "9", "selected"); %>><#APChnAuto#></option>
                                                    <option value="2" <% nvram_match_x("","ss_type", "2", "selected"); %>>Trojan</option>
                                                    <option value="0" <% nvram_match_x("","ss_type", "0", "selected"); %>>SS</option>
                                                    <option value="1" <% nvram_match_x("","ss_type", "1", "selected"); %>>SSR</option>
                                                    <option value="3" <% nvram_match_x("","ss_type", "3", "selected"); %>>VMess</option>
                                                </select>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_8#></th>
                                            <td>
                                                <select name="ss_mode" class="input" style="width: 145px" onchange="change_ss_mode();">
                                                    <option value="0" <% nvram_match_x("","ss_mode", "0", "selected"); %>><#menu5_16_9#></option>
                                                    <option value="1" <% nvram_match_x("","ss_mode", "1", "selected"); %>><#menu5_16_10#></option>
                                                    <option value="2" <% nvram_match_x("","ss_mode", "2", "selected"); %>><#menu5_16_11#></option>
                                                </select>
                                            </td>
                                        </tr>

                                        <tr id="row_diversion_rate" style="display:none;"> <th width="50%" style="border-top: 0 none;"><#menu5_16_110#></th>
                                            <td style="border-top: 0 none;">
                                                <select name="diversion_rate" class="input" style="width: 145px">
                                                    <option value="2" <% nvram_match_x("","diversion_rate", "2", "selected"); %>><#menu5_16_112#></option>
                                                    <option value="1" <% nvram_match_x("","diversion_rate", "1", "selected"); %>><#menu5_16_111#></option>
                                                </select>
                                            </td>
                                        </tr>

                                        <tr> <th colspan="2" style="background-color: #E3E3E3;"><#menu5_16_12#></th> </tr>

                                        <tr> <th width="50%"><#menu5_16_13#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                <div id="dns_forwarder_enable_on_of">
                                                    <input type="checkbox" id="dns_forwarder_enable_fake" <% nvram_match_x("", "dns_forwarder_enable", "1", "value=1 checked"); %><% nvram_match_x("", "dns_forwarder_enable", "0", "value=0"); %>>
                                                </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="dns_forwarder_enable" id="dns_forwarder_enable_1" <% nvram_match_x("", "dns_forwarder_enable", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="dns_forwarder_enable" id="dns_forwarder_enable_0" <% nvram_match_x("", "dns_forwarder_enable", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%" style="border-top: 0 none;"><#running_status#></th>
                                            <td style="border-top: 0 none;" id="dnsforwarder_status"></td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_14#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="ss-tunnel_enable_on_of">
                                                        <input type="checkbox" id="ss-tunnel_enable_fake" <% nvram_match_x("", "ss-tunnel_enable", "1", "value=1 checked"); %><% nvram_match_x("", "ss-tunnel_enable", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="ss-tunnel_enable" id="ss-tunnel_enable_1" <% nvram_match_x("", "ss-tunnel_enable", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="ss-tunnel_enable" id="ss-tunnel_enable_0" <% nvram_match_x("", "ss-tunnel_enable", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%" style="border-top: 0 none;"><#running_status#></th>
                                            <td style="border-top: 0 none;" id="ss_tunnel_status"></td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_15#></th>
                                            <td>
                                                <input type="text" maxlength="32" class="input" size="32" name="ss_dns_remote_server" style="width: 217px" value="<% nvram_get_x("","ss_dns_remote_server"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th colspan="2" style="background-color: #E3E3E3;"><#menu5_16_16#></th> </tr>

                                        <tr> <th width="50%"><a href="javascript:spoiler_toggle('spoiler_chnroute_url')"><#menu5_16_17#></a></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="ss_update_chnroute_on_of">
                                                        <input type="checkbox" id="ss_update_chnroute_fake" <% nvram_match_x("", "ss_update_chnroute", "1", "value=1 checked"); %><% nvram_match_x("", "ss_update_chnroute", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="ss_update_chnroute" id="ss_update_chnroute_1" <% nvram_match_x("", "ss_update_chnroute", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="ss_update_chnroute" id="ss_update_chnroute_0" <% nvram_match_x("", "ss_update_chnroute", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr id="spoiler_chnroute_url" style="display:none;">
                                            <td colspan="2" style="text-align: center; border-top: 0 none;">
                                                <div>
                                                    <input type="text" maxlength="90" class="input" size="90" name="chnroute_url" style="width: 654px" placeholder="<#menu5_16_17A#>" value="<% nvram_get_x("","chnroute_url"); %>">
                                                </div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th width="50%" style="border-top: 0 none;"><a href="javascript:spoiler_toggle('spoiler_custom_chnroute')"><#menu5_16_10#></a>&nbsp;&nbsp;&nbsp;&nbsp;<span class="label label-info" style="padding: 5px 5px 5px 5px;" id="chnroute_count"></span></th>
                                            <td style="border-top: 0 none;">
                                                <input type="button" id="btn_connect_2" class="btn btn-info" value="<#menu5_16_18#>" onclick="submitInternet('Update_chnroute');">
                                            </td>
                                        </tr>

                                        <tr id="spoiler_custom_chnroute" style="display:none;">
                                            <td colspan="2" style="text-align: center; border-top: 0 none;">
                                                <div>
                                                    <input type="text" maxlength="90" class="input" size="90" name="ss_custom_chnroute" style="width: 654px" placeholder="<#menu5_16_10A#>" value="<% nvram_get_x("","ss_custom_chnroute"); %>">
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><a href="javascript:spoiler_toggle('spoiler_gfwlist_url')"><#menu5_16_17#></a></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="ss_update_gfwlist_on_of">
                                                        <input type="checkbox" id="ss_update_gfwlist_fake" <% nvram_match_x("", "ss_update_gfwlist", "1", "value=1 checked"); %><% nvram_match_x("", "ss_update_gfwlist", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="ss_update_gfwlist" id="ss_update_gfwlist_1" <% nvram_match_x("", "ss_update_gfwlist", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="ss_update_gfwlist" id="ss_update_gfwlist_0" <% nvram_match_x("", "ss_update_gfwlist", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr id="spoiler_gfwlist_url" style="display:none;">
                                            <td colspan="2" style="text-align: center; border-top: 0 none;">
                                                <div>
                                                    <input type="text" maxlength="90" class="input" size="90" name="gfwlist_url" style="width: 654px" placeholder="<#menu5_16_17B#>" value="<% nvram_get_x("","gfwlist_url"); %>">
                                                </div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th width="50%" style="border-top: 0 none;"><a href="javascript:spoiler_toggle('spoiler_custom_gfwlist')"><#menu5_16_11#></a>&nbsp;&nbsp;&nbsp;&nbsp;<span class="label label-info" style="padding: 5px 5px 5px 5px;" id="gfwlist_count"></span></th>
                                            <td style="border-top: 0 none;">
                                                <input type="button" id="btn_connect_3" class="btn btn-info" value="<#menu5_16_18#>" onclick="submitInternet('Update_gfwlist');">
                                            </td>
                                        </tr>

                                        <tr id="spoiler_custom_gfwlist" style="display:none;">
                                            <td colspan="2" style="text-align: center; border-top: 0 none;">
                                                <div>
                                                    <input type="text" maxlength="90" class="input" size="90" name="ss_custom_gfwlist" style="width: 654px" placeholder="<#menu5_16_11A#>" value="<% nvram_get_x("","ss_custom_gfwlist"); %>">
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th colspan="2" style="background-color: #E3E3E3;"><#menu5_16_19#></th> </tr>

                                        <tr> <th width="50%"><#menu5_16_20#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="ss_udp_on_of">
                                                        <input type="checkbox" id="ss_udp_fake" <% nvram_match_x("", "ss_udp", "1", "value=1 checked"); %><% nvram_match_x("", "ss_udp", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="ss_udp" id="ss_udp_1" <% nvram_match_x("", "ss_udp", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="ss_udp" id="ss_udp_0" <% nvram_match_x("", "ss_udp", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_21#></th>
                                            <td>
                                                <input type="text" maxlength="6" class="input" size="6" name="ss_local_port" style="width: 83px" value="<% nvram_get_x("", "ss_local_port"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_22#></th>
                                            <td>
                                                <input type="text" maxlength="6" class="input" size="6" name="ss_dns_local_port" style="width: 83px" value="<% nvram_get_x("", "ss_dns_local_port"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_23#></th>
                                            <td>
                                                <input type="text" maxlength="6" class="input" size="6" name="ss_mtu" style="width: 83px" value="<% nvram_get_x("", "ss_mtu"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_24#></th>
                                            <td>
                                                <input type="text" maxlength="6" class="input" size="6" name="ss-tunnel_mtu" style="width: 83px" value="<% nvram_get_x("", "ss-tunnel_mtu"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th width="50%"><#menu5_16_25#></th>
                                            <td>
                                                <input type="text" maxlength="6" class="input" size="6" name="ss_timeout" style="width: 83px" value="<% nvram_get_x("","ss_timeout"); %>">
                                            </td>
                                        </tr>

                                        <tr>
                                            <td colspan="2">
                                                <center><input class="btn btn-primary" style="width: 217px" type="button" value="<#CTL_apply#>" onclick="submitInternet('subRestart');applyRule();" /></center>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
<div id="footer"></div>
</div>

<form method="post" name="Shadowsocks_action" action="">
    <input type="hidden" name="connect_action" value="">
</form>


</body>
</html>

