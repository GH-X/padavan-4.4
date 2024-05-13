<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_10_3#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>

<% login_state_hook(); %>

function initial(){
	show_banner(1);
	show_menu(5,8,3);
	show_footer();
	load_body();

	if(get_ap_mode())
		showhide_div('row_lost_action', 0);

	poll_mode_changed();
}

function applyRule(){
	if(validForm()){
		showLoading();
		
		document.form.action_mode.value = " Apply ";
		document.form.current_page.value = "/Advanced_InetDetect_Content.asp";
		document.form.next_page.value = "";
		
		document.form.submit();
	}
}

function validForm(){
	if(document.form.di_domain_cn.value == "")
		return false;
	if(document.form.di_domain_gb.value == "")
		return false;
	if(document.form.di_user_agent.value == "")
		return false;
	if(document.form.di_status_code.value == "")
		return false;
	if(document.form.di_page_feature.value == "")
		return false;
	if(!validate_range(document.form.di_timeout, 1, 8))
		return false;

	if (document.form.di_poll_mode.value == "0"){
		var v = document.form.di_timeout.value * 3;
		if(!validate_range(document.form.di_time_done, 60, 600))
			return false;
		if(!validate_range(document.form.di_time_fail, v, 60))
			return false;
		if(!validate_range(document.form.di_found_delay, 0, 3600))
			return false;
		if(!validate_range(document.form.di_lost_delay, 0, 3600))
			return false;
		
		if (document.form.di_lost_action.value == "2" && !get_ap_mode()){
			if(!validate_range(document.form.di_recon_pause, 0, 600))
				return false;
		}
	}

	return true;
}

function poll_mode_changed(){
	var v = (document.form.di_poll_mode.value == "0") ? 1 : 0;
	if (v)
		lost_action_changed();
	showhide_div('tbl_di_events', v);
	showhide_div('row_check_period', v);
}

function lost_action_changed(){
	var v = (document.form.di_lost_action.value == "2" && !get_ap_mode()) ? 1 : 0;
	showhide_div('row_recon_pause', v);
}

function done_validating(action){
	refreshpage();
}
</script>
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
    <input type="hidden" name="current_page" value="Advanced_InetDetect_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="General;">
    <input type="hidden" name="group_id" value="">
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
                            <h2 class="box_head round_top"><#menu5_10#> - <#menu5_10_3#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;"><#InetCheck_desc#></div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th width="50%"><#InetCheckMode#></th>
                                            <td>
                                                <select name="di_poll_mode" class="input" style="width: 324px;" onchange="poll_mode_changed();">
                                                    <option value="0" <% nvram_match_x("", "di_poll_mode", "0", "selected"); %>><#InetCheckModeItem0#> (*)</option>
                                                    <option value="1" <% nvram_match_x("", "di_poll_mode", "1", "selected"); %>><#InetCheckModeItem1#></option>
                                                </select>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#InetCheckHosts#></th>
                                        </tr>
                                        <tr>
                                            <th width="50%"><#InetCheckHostDomain#>&nbsp;(<#InternetNation#>):</th>
                                            <td>
                                                <input type="text" maxlength="43" class="input" size="15" name="di_domain_cn" style="width: 314px" placeholder="https://www.taobao.com/" value="<% nvram_get_x("","di_domain_cn"); %>"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><#InetCheckHostDomain#>&nbsp;(<#InternetGlobal#>):</th>
                                            <td>
                                                <input type="text" maxlength="43" class="input" size="15" name="di_domain_gb" style="width: 314px" placeholder="https://www.google.com/" value="<% nvram_get_x("","di_domain_gb"); %>"/>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#InetCheckPoll#>
                                                <a href="javascript:spoiler_toggle('spoiler_user_agent')"><#InetCheckUserAgent#></a>
                                                <a href="javascript:spoiler_toggle('spoiler_return_code')"><#InetCheckStatusCode#>&nbsp;<#InetCheckPageFeature#></a>
                                            </th>
                                        </tr>
                                        <tr id="spoiler_user_agent" style="display:none;">
                                            <td colspan="2" style="text-align: center;">
                                                <input type="text" maxlength="90" class="input" size="15" name="di_user_agent" style="width: 656px" placeholder="Mozilla/5.0 (X11; Linux; rv:74.0) Gecko/20100101 Firefox/74.0" value="<% nvram_get_x("","di_user_agent"); %>"/>
                                            </td>
                                        </tr>
                                        <tr id="spoiler_return_code" style="display:none;">
                                            <td width="50%">
                                                <input type="text" maxlength="43" class="input" size="15" name="di_status_code" style="width: 314px;" placeholder="HTTP/1.1 200 OK" value="<% nvram_get_x("", "di_status_code"); %>"/>
                                            </td>
                                            <td>
                                                <input type="text" maxlength="43" class="input" size="15" name="di_page_feature" style="width: 314px;" placeholder="<!DOCTYPE html>" value="<% nvram_get_x("", "di_page_feature"); %>"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><#InetCheckTimeout#></th>
                                            <td>
                                                <input type="text" maxlength="1" class="input" size="15" name="di_timeout" placeholder="2" value="<% nvram_get_x("", "di_timeout"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[1..8]</span>
                                            </td>
                                        </tr>
                                        <tr id="row_check_period">
                                            <th><#InetCheckPeriod#></th>
                                            <td>
                                                <input type="text" maxlength="3" class="input" size="15" style="width: 94px;" name="di_time_done" placeholder="300" value="<% nvram_get_x("", "di_time_done"); %>" onkeypress="return is_number(this,event);"/>&nbsp;/
                                                <input type="text" maxlength="2" class="input" size="15" style="width: 94px;" name="di_time_fail" placeholder="6" value="<% nvram_get_x("", "di_time_fail"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[60..600/6..60]</span>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table" id="tbl_di_events">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#InetCheckEvents#></th>
                                        </tr>
                                        <tr>
                                            <th width="50%"><#InetCheckFoundLost#></th>
                                            <td>
                                                <input type="text" maxlength="1" class="input" size="15" style="width: 94px;" name="di_found_delay" placeholder="1" value="<% nvram_get_x("", "di_found_delay"); %>" onkeypress="return is_number(this,event);"/>&nbsp;/
                                                <input type="text" maxlength="2" class="input" size="15" style="width: 94px;" name="di_lost_delay" placeholder="10" value="<% nvram_get_x("", "di_lost_delay"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[0..3600]</span>
                                            </td>
                                        </tr>
                                        <tr id="row_lost_action">
                                            <th><#InetCheckLostAction#></th>
                                            <td>
                                                <select name="di_lost_action" class="input" style="width: 324px;" onchange="lost_action_changed();">
                                                    <option value="0" <% nvram_match_x("", "di_lost_action", "0", "selected"); %>><#InetCheckLostItem0#></option>
                                                    <option value="1" <% nvram_match_x("", "di_lost_action", "1", "selected"); %>><#InetCheckLostItem1#></option>
                                                    <option value="2" <% nvram_match_x("", "di_lost_action", "2", "selected"); %>><#InetCheckLostItem2#></option>
                                                    <option value="3" <% nvram_match_x("", "di_lost_action", "3", "selected"); %>><#InetCheckLostItem3#></option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_recon_pause" style="display:none;">
                                            <th><#InetCheckReconPause#></th>
                                            <td>
                                                <input type="text" maxlength="3" class="input" size="15" name="di_recon_pause" placeholder="0" value="<% nvram_get_x("", "di_recon_pause"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[0..600]</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a href="javascript:spoiler_toggle('inet_state_script')"><span><#RunInetState#></span></a></th>
                                            <td>
                                                <select name="di_notify_mode" class="input" style="width: 324px;">
                                                    <option value="0" <% nvram_match_x("", "di_notify_mode", "0", "selected"); %>><#InetCheckNotifyItem0#> (*)</option>
                                                    <option value="1" <% nvram_match_x("", "di_notify_mode", "1", "selected"); %>><#InetCheckNotifyItem1#></option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="inet_state_script" style="display:none;">
                                            <td colspan="2" style="padding-bottom: 0px; border-top: 0 none;">
                                                <div>
                                                    <textarea rows="16" wrap="off" spellcheck="false" maxlength="8192" class="span12" name="scripts.inet_state_script.sh" style="resize:none; font-family:'Courier New', Courier, mono; font-size:12px;"><% nvram_dump("scripts.inet_state_script.sh",""); %></textarea>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td style="border: 0 none;">
                                                <center><input type="button" class="btn btn-primary" style="width: 219px" onclick="applyRule();" value="<#CTL_apply#>"/></center>
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
