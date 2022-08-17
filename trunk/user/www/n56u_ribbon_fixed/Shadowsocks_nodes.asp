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
	init_itoggle('ss_server_num_x_0');
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
  if (document.form.ss_server_num_x_0.value >= c){
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
  if(m_list.length == 0)
  code +='<tr><td colspan="6" style="text-align: center;"><div class="alert alert-info"><#IPConnection_VSList_Norule#></div></td></tr>';
  else{
  for(var i = 0; i < m_list.length; i++){
  if(m_list[i][0] == 0)
  ssservertype="SS";
  else if(m_list[i][0] == 1){
  ssservertype="SSR";
  }else{
  ssservertype="Trojan";
  }
  if(m_list[i][3] == "")
  ssserverkey="<#menu5_16_26#>";
  else{
  ssserverkey="<#menu5_16_27#>";
  }
  code +='<tr id="rowrl' + i + '">';
  code +='<td colspan="1" style="text-align: left; white-space: nowrap;"><#menu5_16_28#>&nbsp;' + ssservertype + '</td>';
  code +='<td colspan="2" style="white-space: nowrap;"><#menu5_16_29#>&nbsp;' + m_list[i][1] + '</td>';
  code +='<td colspan="1" style="white-space: nowrap;"><#menu5_16_30#>&nbsp;' + m_list[i][2] + '</td>';
  code +='<td colspan="1" style="white-space: nowrap;"><#menu5_16_31#>&nbsp;' + ssserverkey + '</td>';
  code +='<td colspan="1" style="text-align: right;"><input type="checkbox" name="SssList_s" value="' + m_list[i][mlist_ifield] + '" onClick="changeBgColorrl(this,' + i + ');" id="check' + m_list[i][mlist_ifield] + '"></td>';
  code +='</tr>';
  }
  code += '<tr>';
  code += '<td colspan="3" style="text-align: left; white-space: nowrap;"><#menu5_16_32#>&nbsp;' + m_list.length + '</td>'
  code += '<td colspan="3" style="text-align: right; white-space: nowrap;"><#menu5_16_33#></td>';
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
                                        <tr> <th width="22%"><#menu5_16_34#></th>
                                            <td>
                                                <input type="text" maxlength="48" class="input" size="48" name="ss_server_addr_x_0" style="width: 333px" placeholder="<#menu5_16_35#>" value="<% nvram_get_x("","ss_server_addr_x_0"); %>">
                                            </td>
                                            <td width="22%">
                                                <input type="text" maxlength="6" class="input" size="6" name="ss_server_port_x_0" style="width: 135px" placeholder="<#menu5_16_36#>" value="<% nvram_get_x("","ss_server_port_x_0"); %>">
                                            </td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_37#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_server_key_x_0" style="width: 333px" placeholder="<#menu5_16_38#>" value="<% nvram_get_x("","ss_server_key_x_0"); %>">
                                            </td>
                                            <td width="22%">
                                                <select name="ss_server_type_x_0" class="input" style="width: 145px">
                                                    <option value="0" <% nvram_match_x("","ss_server_type_x_0", "0","selected"); %>>SS</option>
                                                    <option value="1" <% nvram_match_x("","ss_server_type_x_0", "1","selected"); %>>SSR</option>
                                                    <option value="2" <% nvram_match_x("","ss_server_type_x_0", "2","selected"); %>>Trojan</option>
                                                </select>
                                            </td>
                                        </tr>	

                                        <tr> <th width="22%"><#menu5_16_39#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_server_sni_x_0" style="width: 333px" placeholder="<#menu5_16_40#>" value="<% nvram_get_x("","ss_server_sni_x_0"); %>">
                                            </td>
                                            <td width="22%">..Trojan</td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_41#></th>
                                            <td>
                                                <select name="ss_method_x_0" class="input" style="width: 342px">
                                                    <option value="none" <% nvram_match_x("","ss_method_x_0", "0","selected"); %>>none (ssr only)</option>
                                                    <option value="rc4" <% nvram_match_x("","ss_method_x_0", "rc4","selected"); %>>rc4</option>
                                                    <option value="rc4-md5" <% nvram_match_x("","ss_method_x_0", "rc4-md5","selected"); %>>rc4-md5</option>
                                                    <option value="aes-128-cfb" <% nvram_match_x("","ss_method_x_0", "aes-128-cfb","selected"); %>>aes-128-cfb</option>
                                                    <option value="aes-192-cfb" <% nvram_match_x("","ss_method_x_0", "aes-192-cfb","selected"); %>>aes-192-cfb</option>
                                                    <option value="aes-256-cfb" <% nvram_match_x("","ss_method_x_0", "aes-256-cfb","selected"); %>>aes-256-cfb</option>
                                                    <option value="aes-128-ctr" <% nvram_match_x("","ss_method_x_0", "aes-128-ctr","selected"); %>>aes-128-ctr</option>
                                                    <option value="aes-192-ctr" <% nvram_match_x("","ss_method_x_0", "aes-192-ctr","selected"); %>>aes-192-ctr</option>
                                                    <option value="aes-256-ctr" <% nvram_match_x("","ss_method_x_0", "aes-256-ctr","selected"); %>>aes-256-ctr</option>
                                                    <option value="camellia-128-cfb" <% nvram_match_x("","ss_method_x_0", "camellia-128-cfb","selected"); %>>camellia-128-cfb</option>
                                                    <option value="camellia-192-cfb" <% nvram_match_x("","ss_method_x_0", "camellia-192-cfb","selected"); %>>camellia-192-cfb</option>
                                                    <option value="camellia-256-cfb" <% nvram_match_x("","ss_method_x_0", "camellia-256-cfb","selected"); %>>camellia-256-cfb</option>
                                                    <option value="bf-cfb" <% nvram_match_x("","ss_method_x_0", "bf-cfb","selected"); %>>bf-cfb</option>
                                                    <option value="salsa20" <% nvram_match_x("","ss_method_x_0", "salsa20","selected"); %>>salsa20</option>
                                                    <option value="chacha20" <% nvram_match_x("","ss_method_x_0", "chacha20","selected"); %>>chacha20</option>
                                                    <option value="chacha20-ietf" <% nvram_match_x("","ss_method_x_0", "chacha20-ietf","selected"); %>>chacha20-ietf</option>
                                                    <option value="aes-128-gcm" <% nvram_match_x("","ss_method_x_0", "aes-128-gcm","selected"); %>>aes-128-gcm (ss only)</option>
                                                    <option value="aes-192-gcm" <% nvram_match_x("","ss_method_x_0", "aes-192-gcm","selected"); %>>aes-192-gcm (ss only)</option>
                                                    <option value="aes-256-gcm" <% nvram_match_x("","ss_method_x_0", "aes-256-gcm","selected"); %>>aes-256-gcm (ss only)</option>
                                                    <option value="chacha20-ietf-poly1305" <% nvram_match_x("","ss_method_x_0", "chacha20-ietf-poly1305","selected"); %>>chacha20-ietf-poly1305 (ss only)</option>
                                                    <option value="xchacha20-ietf-poly1305" <% nvram_match_x("","ss_method_x_0", "xchacha20-ietf-poly1305","selected"); %>>xchacha20-ietf-poly1305 (ss only)</option>
                                                </select>
                                            </td>
                                            <td width="22%">..SS/SSR</td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_42#></th>
                                            <td>
                                                <select name="ss_protocol_x_0" class="input" style="width: 342px">   
                                                    <option value="origin" <% nvram_match_x("","ss_protocol_x_0", "0","selected"); %>>origin</option>
                                                    <option value="auth_sha1" <% nvram_match_x("","ss_protocol_x_0", "auth_sha1","selected"); %>>auth_sha1</option>
                                                    <option value="auth_sha1_v2" <% nvram_match_x("","ss_protocol_x_0", "auth_sha1_v2","selected"); %>>auth_sha1_v2</option>
                                                    <option value="auth_sha1_v4" <% nvram_match_x("","ss_protocol_x_0", "auth_sha1_v4","selected"); %>>auth_sha1_v4</option>
                                                    <option value="auth_aes128_md5" <% nvram_match_x("","ss_protocol_x_0", "auth_aes128_md5","selected"); %>>auth_aes128_md5</option>
                                                    <option value="auth_aes128_sha1" <% nvram_match_x("","ss_protocol_x_0", "auth_aes128_sha1","selected"); %>>auth_aes128_sha1</option>
                                                    <option value="auth_chain_a" <% nvram_match_x("","ss_protocol_x_0", "auth_chain_a","selected"); %>>auth_chain_a</option>
                                                    <option value="auth_chain_b" <% nvram_match_x("","ss_protocol_x_0", "auth_chain_b","selected"); %>>auth_chain_b</option>
                                                </select>
                                            </td>
                                            <td width="22%">..SSR</td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_43#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_proto_param_x_0" style="width: 333px" value="<% nvram_get_x("","ss_proto_param_x_0"); %>">
                                            </td>
                                            <td width="22%">..SS/SSR</td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_44#></th>
                                            <td>
                                                <select name="ss_obfs_x_0" class="input" style="width: 342px">   
                                                    <option value="plain" <% nvram_match_x("","ss_obfs_x_0", "0","selected"); %>>plain</option>
                                                    <option value="http_simple" <% nvram_match_x("","ss_obfs_x_0", "http_simple","selected"); %>>http_simple (ssr only)</option>
                                                    <option value="http_post" <% nvram_match_x("","ss_obfs_x_0", "http_post","selected"); %>>http_post (ssr only)</option>
                                                    <option value="tls1.2_ticket_auth" <% nvram_match_x("","ss_obfs_x_0", "tls1.2_ticket_auth","selected"); %>>tls1.2_ticket_auth (ssr only)</option>
                                                    <option value="v2ray_plugin_websocket" <% nvram_match_x("","ss_obfs_x_0", "v2ray_plugin_websocket","selected"); %>>v2ray_plugin_websocket (ss only)</option>
                                                    <option value="v2ray_plugin_quic" <% nvram_match_x("","ss_obfs_x_0", "v2ray_plugin_quic","selected"); %>>v2ray_plugin_quic (ss only)</option>
                                                </select>
                                            </td>
                                            <td width="22%">..SS/SSR</td>
                                        </tr>

                                        <tr> <th width="22%"><#menu5_16_45#></th>
                                            <td>
                                                <input type="text" maxlength="64" class="input" size="64" name="ss_obfs_param_x_0" style="width: 333px" value="<% nvram_get_x("","ss_obfs_param_x_0"); %>">
                                            </td>
                                            <td width="22%">..SS/SSR</td>
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
