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
var $j = jQuery.noConflict();

$j(document).ready(function(){
	init_itoggle('ss_server_type_x_0');
	init_itoggle('ss_server_addr_x_0');
	init_itoggle('ss_server_port_x_0');
	init_itoggle('ss_server_key_x_0');
	init_itoggle('ss_server_sni_x_0');
	init_itoggle('ss_method_x_0');
	init_itoggle('ss_protocol_x_0');
	init_itoggle('ss_proto_param_x_0');
	init_itoggle('ss_obfs_x_0');
	init_itoggle('ss_obfs_param_x_0');
});

var m_list = [<% get_nvram_list("ShadowsocksConf", "SssList"); %>];
var mlist_ifield = 4;
if(m_list.length > 0){
	var m_list_ifield = m_list[0].length;
	for (var i = 0; i < m_list.length; i++) {
	m_list[i][mlist_ifield] = i;
	}
}

function initial(){
	show_banner(3);
	show_menu(5,11,2);
	show_footer();
	showMRULESList();
	change_server_type();
}

function change_server_type(){
	var st = document.form.ss_server_type_x_0.value; //0=ss 1=ssr 2=trojan 3=vmess 4=naive
	var md = document.form.ss_method_x_0.value;
	var pl = document.form.ss_protocol_x_0.value;
	var os = document.form.ss_obfs_x_0.value;
	if(st == 0){
		document.form.ss_server_sni_x_0.value = "";
		document.form.ss_protocol_x_0.value = "";
		document.form.ss_proto_param_x_0.value = "";
		if((md != "aes-128-gcm")
		&& (md != "aes-192-gcm")
		&& (md != "aes-256-gcm")
		&& (md != "chacha20-ietf-poly1305")
		&& (md != "xchacha20-ietf-poly1305")
		&& (md != "rc4")
		&& (md != "rc4-md5")
		&& (md != "aes-128-cfb")
		&& (md != "aes-192-cfb")
		&& (md != "aes-256-cfb")
		&& (md != "aes-128-ctr")
		&& (md != "aes-192-ctr")
		&& (md != "aes-256-ctr")
		&& (md != "camellia-128-cfb")
		&& (md != "camellia-192-cfb")
		&& (md != "camellia-256-cfb")
		&& (md != "bf-cfb")
		&& (md != "salsa20")
		&& (md != "chacha20")
		&& (md != "chacha20-ietf")){
			document.form.ss_method_x_0.value = "aes-128-gcm";
		}
		if((os != "none")
		&& (os != "v2ray_plugin_websocket")
		&& (os != "v2ray_plugin_quic")){
			document.form.ss_obfs_x_0.value = "none";
		}
	}else if(st == 1){
		document.form.ss_server_sni_x_0.value = "";
		if((md != "none")
		&& (md != "rc4")
		&& (md != "rc4-md5")
		&& (md != "aes-128-cfb")
		&& (md != "aes-192-cfb")
		&& (md != "aes-256-cfb")
		&& (md != "aes-128-ctr")
		&& (md != "aes-192-ctr")
		&& (md != "aes-256-ctr")
		&& (md != "camellia-128-cfb")
		&& (md != "camellia-192-cfb")
		&& (md != "camellia-256-cfb")
		&& (md != "bf-cfb")
		&& (md != "salsa20")
		&& (md != "chacha20")
		&& (md != "chacha20-ietf")){
			document.form.ss_method_x_0.value = "none";
		}
		if((pl != "origin")
		&& (pl != "auth_sha1")
		&& (pl != "auth_sha1_v2")
		&& (pl != "auth_sha1_v4")
		&& (pl != "auth_aes128_md5")
		&& (pl != "auth_aes128_sha1")
		&& (pl != "auth_chain_a")
		&& (pl != "auth_chain_b")){
			document.form.ss_protocol_x_0.value = "origin";
		}
		if((os != "plain")
		&& (os != "http_simple")
		&& (os != "http_post")
		&& (os != "tls1.2_ticket_auth")){
			document.form.ss_obfs_x_0.value = "plain";
		}
	}else if(st == 2){
		document.form.ss_method_x_0.value = "";
		document.form.ss_protocol_x_0.value = "";
		document.form.ss_proto_param_x_0.value = "";
		document.form.ss_obfs_x_0.value = "";
		document.form.ss_obfs_param_x_0.value = "";
	}else if(st == 3){
		if((md != "chacha20-poly1305")
		&& (md != "aes-128-gcm")
		&& (md != "none")
		&& (md != "zero")){
			document.form.ss_method_x_0.value = "chacha20-poly1305";
		}
		if((pl != "ws")
		&& (pl != "ws_tls")
		&& (pl != "tcp")
		&& (pl != "tcp_tls")){
			document.form.ss_protocol_x_0.value = "ws";
		}
		if((pl == "tcp")
		&& (os != "none")
		&& (os != "http")){
			document.form.ss_obfs_x_0.value = "none";
		}else if(((pl == "kcp") || (pl == "quic"))
		&& (os != "none")
		&& (os != "srtp")
		&& (os != "utp")
		&& (os != "wechat-video")
		&& (os != "dtls")
		&& (os != "wireguard")){
			document.form.ss_obfs_x_0.value = "none";
		}else if((pl != "tcp") && (pl != "kcp") && (pl != "quic")
		&& (os != "none")){
			document.form.ss_obfs_x_0.value = "none";
		}
	}else if(st == 4){
		document.form.ss_server_sni_x_0.value = "";
		document.form.ss_method_x_0.value = "";
		document.form.ss_proto_param_x_0.value = "";
		document.form.ss_obfs_x_0.value = "";
		document.form.ss_obfs_param_x_0.value = "";
		if((pl != "https")
		&& (pl != "quic")){
			document.form.ss_protocol_x_0.value = "https";
		}
	}
	var md = document.form.ss_method_x_0.value;
	var pl = document.form.ss_protocol_x_0.value;
	var os = document.form.ss_obfs_x_0.value;
	showhide_div('row_013_m', ((st != 2) && (st != 4)));
	showhide_div('row_3_m_o_chacha20poly1305', (st == 3));
	showhide_div('row_03_m_o_aes128gcm', ((st == 0) || (st == 3)));
	showhide_div('row_0_m_o_aes192gcm', (st == 0));
	showhide_div('row_0_m_o_aes256gcm', (st == 0));
	showhide_div('row_0_m_o_chacha20ietfpoly1305', (st == 0));
	showhide_div('row_0_m_o_xchacha20ietfpoly1305', (st == 0));
	showhide_div('row_13_m_o_none', ((st == 1) || (st == 3)));
	showhide_div('row_3_m_o_zero', (st == 3));
	showhide_div('row_01_m_o_rc4', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_rc4md5', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_aes128cfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_aes192cfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_aes256cfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_aes128ctr', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_aes192ctr', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_aes256ctr', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_camellia128cfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_camellia192cfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_camellia256cfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_bfcfb', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_salsa20', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_chacha20', ((st == 0) || (st == 1)));
	showhide_div('row_01_m_o_chacha20ietf', ((st == 0) || (st == 1)));
	showhide_div('row_01_mnote', ((st == 0) || (st == 1)));
	showhide_div('row_3_mnote', (st == 3));
	showhide_div('row_134_p', ((st == 1) || (st == 3) || (st == 4)));
	showhide_div('row_1_p_o_origin', (st == 1));
	showhide_div('row_1_p_o_authsha1', (st == 1));
	showhide_div('row_1_p_o_authsha1v2', (st == 1));
	showhide_div('row_1_p_o_authsha1v4', (st == 1));
	showhide_div('row_1_p_o_authaes128md5', (st == 1));
	showhide_div('row_1_p_o_authaes128sha1', (st == 1));
	showhide_div('row_1_p_o_authchaina', (st == 1));
	showhide_div('row_1_p_o_authchainb', (st == 1));
	showhide_div('row_3_p_o_ws', (st == 3));
	showhide_div('row_3_p_o_wstls', (st == 3));
	showhide_div('row_3_p_o_tcp', (st == 3));
	showhide_div('row_3_p_o_tcptls', (st == 3));
	showhide_div('row_4_p_o_https', (st == 4));
	showhide_div('row_4_p_o_quic', (st == 4));
	showhide_div('row_1_pnote', (st == 1));
	showhide_div('row_3_pnote', (st == 3));
	showhide_div('row_4_pnote', (st == 4));
	showhide_div('row_13_pp', ((st == 1) || (st == 3)));
	showhide_div('row_1_ppmenu', (st == 1));
	showhide_div('row_3_ppmenu', (st == 3));
	showhide_div('row_1_ppnote', (st == 1));
	showhide_div('row_3_ppnote', (st == 3));
	showhide_div('row_013_o', ((st != 2) && (st != 4)));
	showhide_div('row_0_omenu', (st == 0));
	showhide_div('row_1_omenu', (st == 1));
	showhide_div('row_3_omenu', (st == 3));
	showhide_div('row_1_o_o_plain', (st == 1));
	showhide_div('row_1_o_o_httpsimple', (st == 1));
	showhide_div('row_1_o_o_httppost', (st == 1));
	showhide_div('row_1_o_o_tls1.2ticketauth', (st == 1));
	showhide_div('row_03_o_o_none', ((st == 0) || (st == 3)));
	showhide_div('row_0_o_o_v2raypluginwebsocket', (st == 0));
	showhide_div('row_0_o_o_v2raypluginquic', (st == 9));
	showhide_div('row_3_o_o_http', ((st == 3) && (pl == "tcp")));
	showhide_div('row_3_o_o_srtp', ((st == 3) && ((pl == "kcp") || (pl == "quic"))));
	showhide_div('row_3_o_o_utp', ((st == 3) && ((pl == "kcp") || (pl == "quic"))));
	showhide_div('row_3_o_o_wechatvideo', ((st == 3) && ((pl == "kcp") || (pl == "quic"))));
	showhide_div('row_3_o_o_dtls', ((st == 3) && ((pl == "kcp") || (pl == "quic"))));
	showhide_div('row_3_o_o_wireguard', ((st == 3) && ((pl == "kcp") || (pl == "quic"))));
	showhide_div('row_0_onote', (st == 0));
	showhide_div('row_1_onote', (st == 1));
	showhide_div('row_3_onote', (st == 3));
	showhide_div('row_013_op', (((st == 0) && (os != "none")) || (st == 1) || (st == 3)));
	showhide_div('row_0_opmenu', ((st == 0) && (os != "none")));
	showhide_div('row_1_opmenu', (st == 1));
	showhide_div('row_3_opmenu', (st == 3));
	showhide_div('row_0_opnote', ((st == 0) && (os != "none")));
	showhide_div('row_1_opnote', (st == 1));
	showhide_div('row_3_opnote', (st == 3));
	showhide_div('row_23_sni', ((st == 2) || ((st == 3) && ((pl == "ws_tls") || (pl == "tcp_tls")))));
}

function applyRule(){
	showLoading();
	document.form.action_mode.value = " Restart ";
	document.form.current_page.value = "/Shadowsocks_nodes.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

function markGroupRULES(o, c, b) {
	document.form.group_id.value = "SssList";
	if(b == " Add "){
		if(document.form.ss_server_num_x_0.value >= c){
			alert("<#JS_itemlimit1#> " + c + " <#JS_itemlimit2#>");
			return false;
		}else if(document.form.ss_server_addr_x_0.value==""){
			alert("<#JS_fieldblank#>");
			document.form.ss_server_addr_x_0.focus();
			document.form.ss_server_addr_x_0.select();
			return false;
		}else if(document.form.ss_server_port_x_0.value==""){
			alert("<#JS_fieldblank#>");
			document.form.ss_server_port_x_0.focus();
			document.form.ss_server_port_x_0.select();
			return false;
		}else{
			for(i=0; i<m_list.length; i++){
				if(document.form.ss_server_addr_x_0.value==m_list[i][1]) {
					if(document.form.ss_server_port_x_0.value==m_list[i][2]) {
						alert('<#JS_duplicate#>' + '(' + m_list[i][1] + ':' + m_list[i][2] + ')');
						document.form.ss_server_addr_x_0.focus();
						document.form.ss_server_addr_x_0.select();
						return false;
					}
				}
			}
		}
	}
	pageChanged = 0;
	document.form.action_mode.value = b;
	document.form.current_page.value = "Shadowsocks_nodes.asp";
	return true;
}

function showMRULESList(){
	var code = '<table width="100%" cellspacing="0" cellpadding="0" class="table table-list">';
	if(m_list.length == 0){
		code +='<tr><td colspan="6" style="text-align: center;"><div class="alert alert-info"><#IPConnection_VSList_Norule#></div></td></tr>';
	}else{
		for(var i = 0, j = 1; i < j, i < m_list.length; i++, j++){
			if(m_list[i][0] == 0){
				ssservertype="SS";
			}else if(m_list[i][0] == 1){
				ssservertype="SSR";
			}else if(m_list[i][0] == 2){
				ssservertype="Trojan";
			}else if(m_list[i][0] == 3){
				ssservertype="VMess";
			}else if(m_list[i][0] == 4){
				ssservertype="Naive";
			}else{
				ssservertype="unknown";
			}
			if(m_list[i][3] == ""){
				ssserverkey="<#menu5_16_Empty#>";
			}else{
				ssserverkey="<#menu5_16_Mask#>";
			}
			code +='<tr id="rowrl' + i + '">';
			code +='<td colspan="1" style="text-align: left; white-space: nowrap;">' + j + '</td>';
			code +='<td colspan="1" style="text-align: left; white-space: nowrap;"><#menu5_16_Type#>&nbsp;' + ssservertype + '</td>';
			code +='<td colspan="1" style="white-space: nowrap;"><#menu5_16_Addr#>&nbsp;' + m_list[i][1] + '</td>';
			code +='<td colspan="1" style="white-space: nowrap;"><#menu5_16_Port#>&nbsp;' + m_list[i][2] + '</td>';
			code +='<td colspan="1" style="text-align: right; white-space: nowrap;"><#menu5_16_keys#>&nbsp;' + ssserverkey + '</td>';
			code +='<td colspan="1" style="text-align: right;"><input type="checkbox" name="SssList_s" value="' + m_list[i][mlist_ifield] + '" onClick="changeBgColorrl(this,' + i + ');" id="check' + m_list[i][mlist_ifield] + '"></td>';
			code +='</tr>';
		}
		code += '<tr>';
		code += '<td colspan="3" style="text-align: left; white-space: nowrap;"><#menu5_16_NumberOfNodes#>&nbsp;' + m_list.length + '</td>'
		code += '<td colspan="3" style="text-align: right; white-space: nowrap;"><#menu5_16_CheckDelete#></td>';
		code += '</tr>'
	}
	code +='</table>';
	$("MRULESList_Block").innerHTML = code;
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
.hidden{
    display: none;
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
	
    <input type="hidden" name="current_page" value="Shadowsocks_nodes.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="ShadowsocksConf;">
    <input type="hidden" name="group_id" value="SssList">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">
    <input type="hidden" name="ss_server_num_x_0" value="<% nvram_get_x("SssList", "ss_server_num_x"); %>" readonly="1" />

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
                                        <tr> <th width="22%"><#menu5_16_AddrAndPort#></th>
                                            <td>
                                                <input type="text" maxlength="48" class="input" size="48" name="ss_server_addr_x_0" style="width: 333px" placeholder="<#menu5_16_ExampleAddr#>" value="<% nvram_get_x("","ss_server_addr_x_0"); %>">
                                            </td>
                                            <td width="22%">
                                                <input type="text" maxlength="6" class="input" size="6" name="ss_server_port_x_0" style="width: 135px" placeholder="<#menu5_16_ExamplePort#>" value="<% nvram_get_x("","ss_server_port_x_0"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_keysAndType#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_server_key_x_0" style="width: 333px" placeholder="<#menu5_16_ExampleID#>" value="<% nvram_get_x("","ss_server_key_x_0"); %>">
                                            </td>
                                            <td width="22%">
                                                <select name="ss_server_type_x_0" class="input" style="width: 145px" onchange="change_server_type();">
                                                    <option value="2" <% nvram_match_x("","ss_server_type_x_0", "2","selected"); %>>Trojan</option>
                                                    <option value="4" <% nvram_match_x("","ss_server_type_x_0", "4","selected"); %>>Naive</option>
                                                    <option value="0" <% nvram_match_x("","ss_server_type_x_0", "0","selected"); %>>SS</option>
                                                    <option value="1" <% nvram_match_x("","ss_server_type_x_0", "1","selected"); %>>SSR</option>
                                                    <option value="3" <% nvram_match_x("","ss_server_type_x_0", "3","selected"); %>>VMess</option>
                                                </select>
                                            </td>
                                        </tr>	

                                        <tr id="row_013_m" style="display:none;"> <th width="22%"><#menu5_16_EncryptionMethod#></th>
                                            <td>
                                                <select name="ss_method_x_0" class="input" style="width: 342px">
                                                    <option id="row_3_m_o_chacha20poly1305" style="display:none;" value="chacha20-poly1305" <% nvram_match_x("","ss_method_x_0", "chacha20-poly1305","selected"); %>>chacha20-poly1305</option> <!--vmess-->
                                                    <option id="row_03_m_o_aes128gcm" style="display:none;" value="aes-128-gcm" <% nvram_match_x("","ss_method_x_0", "aes-128-gcm","selected"); %>>aes-128-gcm</option> <!--ss vmess-->
                                                    <option id="row_0_m_o_aes192gcm" style="display:none;" value="aes-192-gcm" <% nvram_match_x("","ss_method_x_0", "aes-192-gcm","selected"); %>>aes-192-gcm</option> <!--ss-->
                                                    <option id="row_0_m_o_aes256gcm" style="display:none;" value="aes-256-gcm" <% nvram_match_x("","ss_method_x_0", "aes-256-gcm","selected"); %>>aes-256-gcm</option> <!--ss-->
                                                    <option id="row_0_m_o_chacha20ietfpoly1305" style="display:none;" value="chacha20-ietf-poly1305" <% nvram_match_x("","ss_method_x_0", "chacha20-ietf-poly1305","selected"); %>>chacha20-ietf-poly1305</option> <!--ss-->
                                                    <option id="row_0_m_o_xchacha20ietfpoly1305" style="display:none;" value="xchacha20-ietf-poly1305" <% nvram_match_x("","ss_method_x_0", "xchacha20-ietf-poly1305","selected"); %>>xchacha20-ietf-poly1305</option> <!--ss-->
                                                    <option id="row_13_m_o_none" style="display:none;" value="none" <% nvram_match_x("","ss_method_x_0", "none","selected"); %>>none</option> <!--ssr vmess-->
                                                    <option id="row_3_m_o_zero" style="display:none;" value="zero" <% nvram_match_x("","ss_method_x_0", "zero","selected"); %>>zero</option> <!--vmess-->
                                                    <option id="row_01_m_o_rc4" style="display:none;" value="rc4" <% nvram_match_x("","ss_method_x_0", "rc4","selected"); %>>rc4</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_rc4md5" style="display:none;" value="rc4-md5" <% nvram_match_x("","ss_method_x_0", "rc4-md5","selected"); %>>rc4-md5</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_aes128cfb" style="display:none;" value="aes-128-cfb" <% nvram_match_x("","ss_method_x_0", "aes-128-cfb","selected"); %>>aes-128-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_aes192cfb" style="display:none;" value="aes-192-cfb" <% nvram_match_x("","ss_method_x_0", "aes-192-cfb","selected"); %>>aes-192-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_aes256cfb" style="display:none;" value="aes-256-cfb" <% nvram_match_x("","ss_method_x_0", "aes-256-cfb","selected"); %>>aes-256-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_aes128ctr" style="display:none;" value="aes-128-ctr" <% nvram_match_x("","ss_method_x_0", "aes-128-ctr","selected"); %>>aes-128-ctr</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_aes192ctr" style="display:none;" value="aes-192-ctr" <% nvram_match_x("","ss_method_x_0", "aes-192-ctr","selected"); %>>aes-192-ctr</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_aes256ctr" style="display:none;" value="aes-256-ctr" <% nvram_match_x("","ss_method_x_0", "aes-256-ctr","selected"); %>>aes-256-ctr</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_camellia128cfb" style="display:none;" value="camellia-128-cfb" <% nvram_match_x("","ss_method_x_0", "camellia-128-cfb","selected"); %>>camellia-128-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_camellia192cfb" style="display:none;" value="camellia-192-cfb" <% nvram_match_x("","ss_method_x_0", "camellia-192-cfb","selected"); %>>camellia-192-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_camellia256cfb" style="display:none;" value="camellia-256-cfb" <% nvram_match_x("","ss_method_x_0", "camellia-256-cfb","selected"); %>>camellia-256-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_bfcfb" style="display:none;" value="bf-cfb" <% nvram_match_x("","ss_method_x_0", "bf-cfb","selected"); %>>bf-cfb</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_salsa20" style="display:none;" value="salsa20" <% nvram_match_x("","ss_method_x_0", "salsa20","selected"); %>>salsa20</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_chacha20" style="display:none;" value="chacha20" <% nvram_match_x("","ss_method_x_0", "chacha20","selected"); %>>chacha20</option> <!--ss ssr-->
                                                    <option id="row_01_m_o_chacha20ietf" style="display:none;" value="chacha20-ietf" <% nvram_match_x("","ss_method_x_0", "chacha20-ietf","selected"); %>>chacha20-ietf</option> <!--ss ssr-->
                                                </select>
                                            </td>
                                            <td width="22%" id="row_01_mnote" style="display:none;">..method</td> <td width="22%" id="row_3_mnote" style="display:none;">..security</td>
                                        </tr>

                                        <tr id="row_134_p" style="display:none;"> <th width="22%"><#menu5_16_TransferProtocol#></th>
                                            <td>
                                                <select name="ss_protocol_x_0" class="input" style="width: 342px" onchange="change_server_type();">   
                                                    <option id="row_1_p_o_origin" style="display:none;" value="origin" <% nvram_match_x("","ss_protocol_x_0", "origin","selected"); %>>origin</option> <!--ssr-->
                                                    <option id="row_1_p_o_authsha1" style="display:none;" value="auth_sha1" <% nvram_match_x("","ss_protocol_x_0", "auth_sha1","selected"); %>>auth_sha1</option> <!--ssr-->
                                                    <option id="row_1_p_o_authsha1v2" style="display:none;" value="auth_sha1_v2" <% nvram_match_x("","ss_protocol_x_0", "auth_sha1_v2","selected"); %>>auth_sha1_v2</option> <!--ssr-->
                                                    <option id="row_1_p_o_authsha1v4" style="display:none;" value="auth_sha1_v4" <% nvram_match_x("","ss_protocol_x_0", "auth_sha1_v4","selected"); %>>auth_sha1_v4</option> <!--ssr-->
                                                    <option id="row_1_p_o_authaes128md5" style="display:none;" value="auth_aes128_md5" <% nvram_match_x("","ss_protocol_x_0", "auth_aes128_md5","selected"); %>>auth_aes128_md5</option> <!--ssr-->
                                                    <option id="row_1_p_o_authaes128sha1" style="display:none;" value="auth_aes128_sha1" <% nvram_match_x("","ss_protocol_x_0", "auth_aes128_sha1","selected"); %>>auth_aes128_sha1</option> <!--ssr-->
                                                    <option id="row_1_p_o_authchaina" style="display:none;" value="auth_chain_a" <% nvram_match_x("","ss_protocol_x_0", "auth_chain_a","selected"); %>>auth_chain_a</option> <!--ssr-->
                                                    <option id="row_1_p_o_authchainb" style="display:none;" value="auth_chain_b" <% nvram_match_x("","ss_protocol_x_0", "auth_chain_b","selected"); %>>auth_chain_b</option> <!--ssr-->
                                                    <option id="row_3_p_o_ws" style="display:none;" value="ws" <% nvram_match_x("","ss_protocol_x_0", "ws","selected"); %>>ws</option> <!--vmess-->
                                                    <option id="row_3_p_o_wstls" style="display:none;" value="ws_tls" <% nvram_match_x("","ss_protocol_x_0", "ws_tls","selected"); %>>ws+tls</option> <!--vmess-->
                                                    <option id="row_3_p_o_tcp" style="display:none;" value="tcp" <% nvram_match_x("","ss_protocol_x_0", "tcp","selected"); %>>tcp</option> <!--vmess-->
                                                    <option id="row_3_p_o_tcptls" style="display:none;" value="tcp_tls" <% nvram_match_x("","ss_protocol_x_0", "tcp_tls","selected"); %>>tcp+tls</option> <!--vmess-->
                                                    <option id="row_4_p_o_https" style="display:none;" value="https" <% nvram_match_x("","ss_protocol_x_0", "https","selected"); %>>https</option> <!--naive-->
                                                    <option id="row_4_p_o_quic" style="display:none;" value="quic" <% nvram_match_x("","ss_protocol_x_0", "quic","selected"); %>>quic</option> <!--naive-->
                                                </select>
                                            </td>
                                            <td width="22%" id="row_1_pnote" style="display:none;">..protocol</td> <td width="22%" id="row_3_pnote" style="display:none;">..network</td> <td width="22%" id="row_4_pnote" style="display:none;">..proto</td>
                                        </tr>

                                        <tr id="row_13_pp" style="display:none;"> <th width="22%" id="row_1_ppmenu" style="display:none;"><#menu5_16_ProtocolParam#></th> <th width="22%" id="row_3_ppmenu" style="display:none;"><#menu5_16_ProtocolPath#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_proto_param_x_0" style="width: 333px" value="<% nvram_get_x("","ss_proto_param_x_0"); %>">
                                            </td>
                                            <td width="22%" id="row_1_ppnote" style="display:none;">..protocol_param</td> <td width="22%" id="row_3_ppnote" style="display:none;">..path</td>
                                        </tr>

                                        <tr id="row_013_o" style="display:none;"> <th width="22%" id="row_0_omenu" style="display:none;"><#menu5_16_PluginType#></th> <th width="22%" id="row_1_omenu" style="display:none;"><#menu5_16_Obfuscation#></th> <th width="22%" id="row_3_omenu" style="display:none;"><#menu5_16_MasqueradeType#></th>
                                            <td>
                                                <select name="ss_obfs_x_0" class="input" style="width: 342px" onchange="change_server_type();">   
                                                    <option id="row_1_o_o_plain" style="display:none;" value="plain" <% nvram_match_x("","ss_obfs_x_0", "plain","selected"); %>>plain</option> <!--ssr-->
                                                    <option id="row_1_o_o_httpsimple" style="display:none;" value="http_simple" <% nvram_match_x("","ss_obfs_x_0", "http_simple","selected"); %>>http_simple</option> <!--ssr-->
                                                    <option id="row_1_o_o_httppost" style="display:none;" value="http_post" <% nvram_match_x("","ss_obfs_x_0", "http_post","selected"); %>>http_post</option> <!--ssr-->
                                                    <option id="row_1_o_o_tls1.2ticketauth" style="display:none;" value="tls1.2_ticket_auth" <% nvram_match_x("","ss_obfs_x_0", "tls1.2_ticket_auth","selected"); %>>tls1.2_ticket_auth</option> <!--ssr-->
                                                    <option id="row_03_o_o_none" style="display:none;" value="none" <% nvram_match_x("","ss_obfs_x_0", "none","selected"); %>>none</option> <!--ss vmess-->
                                                    <option id="row_0_o_o_v2raypluginwebsocket" style="display:none;" value="v2ray_plugin_websocket" <% nvram_match_x("","ss_obfs_x_0", "v2ray_plugin_websocket","selected"); %>>v2ray_plugin_websocket</option> <!--ss-->
                                                    <option id="row_0_o_o_v2raypluginquic" style="display:none;" value="v2ray_plugin_quic" <% nvram_match_x("","ss_obfs_x_0", "v2ray_plugin_quic","selected"); %>>v2ray_plugin_quic</option> <!--ss-->
                                                    <option id="row_3_o_o_http" style="display:none;" value="http" <% nvram_match_x("","ss_obfs_x_0", "http","selected"); %>>http</option> <!--vmess-->
                                                    <option id="row_3_o_o_srtp" style="display:none;" value="srtp" <% nvram_match_x("","ss_obfs_x_0", "srtp","selected"); %>>srtp</option> <!--vmess-->
                                                    <option id="row_3_o_o_utp" style="display:none;" value="utp" <% nvram_match_x("","ss_obfs_x_0", "utp","selected"); %>>utp</option> <!--vmess-->
                                                    <option id="row_3_o_o_wechatvideo" style="display:none;" value="wechat-video" <% nvram_match_x("","ss_obfs_x_0", "wechat-video","selected"); %>>wechat-video</option> <!--vmess-->
                                                    <option id="row_3_o_o_dtls" style="display:none;" value="dtls" <% nvram_match_x("","ss_obfs_x_0", "dtls","selected"); %>>dtls</option> <!--vmess-->
                                                    <option id="row_3_o_o_wireguard" style="display:none;" value="wireguard" <% nvram_match_x("","ss_obfs_x_0", "wireguard","selected"); %>>wireguard</option> <!--vmess-->
                                                </select>
                                            </td>
                                            <td width="22%" id="row_0_onote" style="display:none;">..plugin</td> <td width="22%" id="row_1_onote" style="display:none;">..obfs</td> <td width="22%" id="row_3_onote" style="display:none;">..type</td>
                                        </tr>

                                        <tr id="row_013_op" style="display:none;"> <th width="22%" id="row_0_opmenu" style="display:none;"><#menu5_16_PluginOptions#></th> <th width="22%" id="row_1_opmenu" style="display:none;"><#menu5_16_ObfuscationParam#></th> <th width="22%" id="row_3_opmenu" style="display:none;"><#menu5_16_MasqueradeDomain#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_obfs_param_x_0" style="width: 333px" value="<% nvram_get_x("","ss_obfs_param_x_0"); %>">
                                            </td>
                                            <td width="22%" id="row_0_opnote" style="display:none;">..opts(opts,args)</td> <td width="22%" id="row_1_opnote" style="display:none;">..obfs_param</td> <td width="22%" id="row_3_opnote" style="display:none;">..Host(host1,host2)</td>
                                        </tr>

                                        <tr id="row_23_sni" style="display:none;"> <th width="22%"><#menu5_16_VerifyHostname#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_server_sni_x_0" style="width: 333px" placeholder="<#menu5_16_ExampleHostname#>" value="<% nvram_get_x("","ss_server_sni_x_0"); %>">
                                            </td>
                                            <td width="22%">..SNI</td>
                                        </tr>

                                        <tr>
                                            <td width="33%">
                                                <center><input type="button" class="btn btn-success" style="width: 145px" onclick="applyRule();" value="<#CTL_finish#>"/></center>
                                            </td>
                                            <td width="34%">
                                                <center><input name="ManualRULESList2" type="submit" class="btn btn-info" style="width: 145px" onclick="return markGroupRULES(this, 64, ' Add ');" value="<#CTL_add#>"/></center>
                                            </td>
                                            <td width="33%">
                                                <center><input name="SssList" type="submit" class="btn btn-danger" style="width: 145px" onclick="return markGroupRULES(this, 64, ' Del ');" value="<#CTL_del#>"/></center>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td colspan="6" style="border-top: 0 none; padding: 0px;">
                                                <div id="MRULESList_Block"></div>
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

</body>
</html>

