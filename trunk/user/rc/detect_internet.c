/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <stdio.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <time.h>
#include <stdlib.h>
#include <sys/time.h>

#include "rc.h"
#include <gpioutils.h>

#define DI_STATUS_INIT	3
#define DI_PID_FILE	"/var/run/detect_internet.pid"

static long                  di_statestarttime = 0;
static unsigned long         di_timeout_max;
static int                   di_poll_mode;
static int                   di_notify_mode;
static int                   notify_delaytimeset = 0;
static volatile sig_atomic_t notify_changed = 0;
static volatile sig_atomic_t link_internet = DI_STATUS_INIT;
static volatile sig_atomic_t link_previous = DI_STATUS_INIT;
static volatile sig_atomic_t di_webui_open = 0;
static struct   itimerval    di_itv;

static void
di_alarmtimer(unsigned long sec)
{
	di_itv.it_value.tv_sec  = sec;
	di_itv.it_value.tv_usec = 0;
	di_itv.it_interval = di_itv.it_value;
	setitimer(ITIMER_REAL, &di_itv, NULL);
}

static int
di_run_script(void)
{
	if (set_led_wan(3, 3, 0) == link_internet) {
		const char *di_script_1 = SCRIPT_DETECTINTERNET_A;
		const char *di_script_2 = SCRIPT_DETECTINTERNET_B;
		const char *di_script_3 = SCRIPT_DETECTINTERNET_C;
		const char *di_script_4 = SCRIPT_DETECTINTERNET_D;
		link_internet = DI_STATUS_INIT;
		if (check_if_file_exist(di_script_1) && check_if_file_exist(di_script_2) &&
		    check_if_file_exist(di_script_3) && check_if_file_exist(di_script_4)) {
			pid_t di_script_1_status;
			pid_t di_script_2_status;
			pid_t di_script_3_status;
			pid_t di_script_4_status;
			di_script_1_status = system(di_script_1);
			di_script_2_status = system(di_script_2);
			di_script_3_status = system(di_script_3);
			di_script_4_status = system(di_script_4);
			if (di_script_1_status != -1 && WIFEXITED(di_script_1_status) &&
			    di_script_2_status != -1 && WIFEXITED(di_script_2_status) &&
			    di_script_3_status != -1 && WIFEXITED(di_script_3_status) &&
			    di_script_4_status != -1 && WIFEXITED(di_script_4_status)) {
				if (WEXITSTATUS(di_script_2_status) == 0 || WEXITSTATUS(di_script_4_status) == 0) {
					link_internet = 2;
				} else if (WEXITSTATUS(di_script_1_status) == 0 || WEXITSTATUS(di_script_3_status) == 0) {
					link_internet = 1;
				} else {
					link_internet = 0;
				}
			} else {
				logmessage("detect_internet", "detect_internet_script run error");
			}
		} else {
			logmessage("detect_internet", "detect_internet_script not found");
		}
		
		if (set_led_wan(link_internet, 3, 0) != link_internet)
			link_internet = DI_STATUS_INIT;
	} else {
		link_internet = nvram_get_int("link_internet");
	}

	return link_internet;
}

static void
di_run_detect(unsigned long period_set)
{
	unsigned long period_next = di_itv.it_value.tv_sec;

	if (di_run_script() != link_internet)
		link_internet = nvram_get_int("link_internet");

	if (di_poll_mode == 0) {
		long notify_stateduration;
		long notify_delaytimestart;
		int  notify_delaytimeuse;
		int  notify_linkinternet = link_internet;
		int  notify_linkprevious = link_previous;
		int  timeout_max = nvram_safe_get_int("di_timeout", 2, 1, 8) * 3;
		di_timeout_max = (unsigned long)timeout_max;
		
		if (notify_delaytimeset == 0)
			notify_delaytimestart = uptime();
		notify_delaytimeuse = (int)uptime() - notify_delaytimestart;
		
		if (di_notify_mode == 0 && link_internet == 2)
			notify_linkinternet = 1;
		if (di_notify_mode == 0 && link_previous == 2)
			notify_linkprevious = 1;
		
		if (notify_changed == 1 && link_internet != DI_STATUS_INIT && notify_delaytimeuse >= notify_delaytimeset) {
			if ((di_notify_mode == 0 && notify_linkinternet != notify_linkprevious) ||
			    (di_notify_mode == 1 && link_internet != link_previous)) {
				notify_stateduration = uptime() - di_statestarttime;
				di_statestarttime = uptime();
				notify_on_internet_state_changed(notify_linkinternet, notify_linkprevious, notify_stateduration);
				link_previous = link_internet;
			}
			notify_changed = 0;
			notify_delaytimeset = 0;
		}
		
		if (link_internet == 0 && notify_delaytimeuse >= notify_delaytimeset) {
			if (link_internet != link_previous) {
				notify_changed = 1;
				notify_delaytimestart = uptime();
				notify_delaytimeset = nvram_safe_get_int("di_lost_delay", 0, 0, 3600);
				period_next = di_timeout_max;
			} else {
				period_next = (unsigned long)nvram_safe_get_int("di_time_fail", timeout_max, timeout_max, 60);
			}
		} else if (di_notify_mode == 0 && notify_delaytimeuse >= notify_delaytimeset &&
		          (link_internet == 1 || link_internet == 2)) {
			if (link_internet != link_previous &&
			   (link_previous == 0 || link_previous == DI_STATUS_INIT)) {
				notify_changed = 1;
				notify_delaytimestart = uptime();
				notify_delaytimeset = nvram_safe_get_int("di_found_delay", 0, 0, 3600);
				period_next = di_timeout_max;
			} else {
				period_next = (unsigned long)nvram_safe_get_int("di_time_done", 300, 60, 600);
			}
		} else if (di_notify_mode == 1 && link_internet == 1 && notify_delaytimeuse >= notify_delaytimeset) {
			if (link_internet != link_previous) {
				notify_changed = 1;
				notify_delaytimestart = uptime();
				notify_delaytimeset = nvram_safe_get_int("di_found_delay", 0, 0, 3600);
				period_next = di_timeout_max;
			} else {
				period_next = (unsigned long)nvram_safe_get_int("di_time_done", 300, 60, 600);
			}
		} else if (di_notify_mode == 1 && link_internet == 2 && notify_delaytimeuse >= notify_delaytimeset) {
			if (link_internet != link_previous) {
				notify_changed = 1;
				notify_delaytimestart = uptime();
				notify_delaytimeset = nvram_safe_get_int("di_found_delay", 0, 0, 3600);
				period_next = di_timeout_max;
			} else {
				period_next = (unsigned long)nvram_safe_get_int("di_time_done", 300, 60, 600);
			}
		} else {
			period_next = di_timeout_max;
		}
	}

	if (di_poll_mode == 1)
		link_previous = link_internet;

	if (period_set >= 1)
		period_next = period_set;

	if (di_itv.it_value.tv_sec != period_next)
		di_alarmtimer(period_next);
}

static void
di_on_timer(void)
{
	if (di_webui_open >= 1)
		--di_webui_open;

	if (di_webui_open <= 0)
		di_run_detect(0);
}

static void
di_on_sighup(void)
{
	di_notify_mode = nvram_safe_get_int("di_notify_mode", 0, 0, 1);
	di_poll_mode = nvram_safe_get_int("di_poll_mode", 0, 0, 1);
	di_webui_open = 60;
	di_run_detect(1);
}

static void
di_on_sigusr1(void)
{
	unsigned long delay_time;
	di_notify_mode = nvram_safe_get_int("di_notify_mode", 0, 0, 1);
	di_poll_mode = nvram_safe_get_int("di_poll_mode", 0, 0, 1);

	di_timeout_max = (unsigned long)nvram_safe_get_int("di_timeout", 2, 1, 8) * 3;
	delay_time = (unsigned long)nvram_get_int("di_notify_delay");
	if (delay_time < di_timeout_max)
		delay_time = di_timeout_max;

	if (di_webui_open >= 1)
		delay_time = 1;

	di_alarmtimer(delay_time);
}

static void
di_on_sigusr2(void)
{
	di_notify_mode = nvram_safe_get_int("di_notify_mode", 0, 0, 1);
	di_poll_mode = nvram_safe_get_int("di_poll_mode", 0, 0, 1);
	di_run_detect(1);
}

static void
catch_sig_detect_internet(int sig)
{
	switch (sig)
	{
	case SIGALRM:
		di_on_timer();
		break;
	case SIGHUP:
		di_on_sighup();
		break;
	case SIGUSR1:
		di_on_sigusr1();
		break;
	case SIGUSR2:
		di_on_sigusr2();
		break;
	case SIGTERM:
		di_alarmtimer(0);
		remove(DI_PID_FILE);
		exit(0);
		break;
	}
}

void
stop_detect_internet(void)
{
	remove(DI_PID_FILE);
	doSystem("killall %s %s", "-q", "detect_internet");
}

int
start_detect_internet(int autorun_time)
{
	char arun[16];
	char *di_argv[] = {
		"/sbin/detect_internet",
		NULL,		/* -a X */
		NULL
	};

	stop_detect_internet();

	snprintf(arun, sizeof(arun), "-a %u", autorun_time);
	di_argv[1] = arun;

	return _eval(di_argv, NULL, 0, NULL);
}

void
notify_run_detect_internet(int delay_time)
{
	nvram_set_int_temp("di_notify_delay", delay_time);

	if (check_if_file_exist(DI_PID_FILE))
		kill_pidfile_s(DI_PID_FILE, SIGUSR1);
}

void
notify_runfast_detect_internet(void)
{
	if (check_if_file_exist(DI_PID_FILE))
		kill_pidfile_s(DI_PID_FILE, SIGUSR2);
}

int
detect_internet_main(int argc, char *argv[])
{
	FILE *fp;
	pid_t pid;
	int c, auto_run_time = 6;
	struct sigaction sa;
	unsigned long delay_time;

	// usage : detect_internet -a X
	if(argc) {
		while ((c = getopt(argc, argv, "a:")) != -1) {
			switch (c) {
				case 'a':
					auto_run_time = atoi(optarg);
				break;
			}
		}
	}

	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = catch_sig_detect_internet;
	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGALRM);
	sigaddset(&sa.sa_mask, SIGHUP);
	sigaddset(&sa.sa_mask, SIGUSR1);
	//sigaddset(&sa.sa_mask, SIGUSR2);
	sigaction(SIGALRM, &sa, NULL);
	sigaction(SIGHUP, &sa, NULL);
	sigaction(SIGUSR1, &sa, NULL);
	sigaction(SIGUSR2, &sa, NULL);
	sigaction(SIGTERM, &sa, NULL);

	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = SIG_IGN;
	sigemptyset(&sa.sa_mask);
	sigaction(SIGPIPE, &sa, NULL);

	if (daemon(0, 0) < 0) {
		perror("daemon");
		exit(errno);
	}

	if (check_if_file_exist(DI_PID_FILE))
		exit(errno);

	pid = getpid();

	/* never invoke oom killer */
	oom_score_adjust(pid, OOM_SCORE_ADJ_MIN);

	/* write pid */
	if ((fp = fopen(DI_PID_FILE, "w")) != NULL) {
		fprintf(fp, "%d", pid);
		fclose(fp);
	}

	if (di_statestarttime == 0)
		di_statestarttime = uptime();

	di_notify_mode = nvram_safe_get_int("di_notify_mode", 0, 0, 1);
	di_poll_mode = nvram_safe_get_int("di_poll_mode", 0, 0, 1);

	di_timeout_max = (unsigned long)nvram_safe_get_int("di_timeout", 2, 1, 8) * 3;
	delay_time = (unsigned long)auto_run_time;
	if (delay_time < di_timeout_max)
		delay_time = di_timeout_max;

	auto_run_time = (int)delay_time;
	nvram_set_int_temp("di_notify_delay", auto_run_time);

	di_alarmtimer(delay_time);

	while (1) {
		pause();
	}

	return 0;
}

