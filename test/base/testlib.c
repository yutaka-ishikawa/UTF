#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <stdlib.h>
#include <stdarg.h>
#include <utf.h>
#include <utf_debug.h>
#include <utf_timer.h>

extern int	myprintf(const char *fmt, ...);

int	nnp, nprocs, myrank;
pid_t	mypid;
int	vflag, dflag, mflag, sflag, Mflag, pflag, wflag;
int	iteration;
size_t	length, mlength;

#include <pmix.h>
static  pmix_proc_t		pmix_proc[1];

void
test_init(int argc, char **argv)
{
    int		opt;

    mypid = getpid();

    while ((opt = getopt(argc, argv, "d:vi:l:m:s:L:M:pwD")) != -1) {
	switch (opt) {
	case 'd': /* debug */
	    dflag = atoi(optarg);
	    myprintf("dflag(0x%x)\n", dflag);
	    utf_dflag = dflag;
	    break;
	case 'v': /* verbose */
	    vflag = 1;
	    break;
	case 'i': /* iteration */
	    iteration = atoi(optarg);
	    break;
	case 'l': /* length */
	    length = atoi(optarg);
	    break;
	case 'L': /* max length */
	    mlength = atoi(optarg);
	    break;
	case 'm':
	    mflag = atoi(optarg);
	    break;
	case 'M':
	    Mflag = atoi(optarg);
	    break;
	case 's':
	    sflag = 1;
	case 'p':
	    pflag = 1;
	    break;
	case 'w':
	    wflag = 1;
	    break;
	case 'D':
	    /* handled by utf */
	    break;
	}
    }
    optind = 0; /* reset getopt() library */
    //PMIx_Init(pmix_proc, NULL, 0);
    //PMIx_Finalize(NULL, 0);
    utf_init(argc, argv, &myrank, &nprocs, &nnp);
    //utf_printf("%s: myrank = %d\n", __func__, myrank);
}

void
mytmrinit()
{
    utf_tmr_start();
}

#define YI_TMR_EVT_MAX	30
#define YI_TMR_COUNT_MAX	1000
#define YI_TMR_SYM_LEN	20
static struct utf_timer	yi_timer[YI_TMR_EVT_MAX];
static double	yi_tmax[YI_TMR_EVT_MAX];
static double	yi_tmin[YI_TMR_EVT_MAX];
static uint64_t	yi_cnt[YI_TMR_EVT_MAX];
static char	yi_fname[128];

void
mytmrfinalize(char *pname)
{
    char	fnbuf[1024];
    char    *cp1 = getenv("TOFULOG_DIR");
    char    *cp2 = getenv("PJM_JOBID");
    FILE	*fp;
    int	evt, cnt, tot;

    tot = utf_tmr_stop(YI_TMR_EVT_MAX, yi_timer, yi_tmax, yi_tmin, yi_cnt);
    if (tot < 0) {
	fprintf(stderr, "F-MPICH has not been compiled with -DUTF_TIMER\n");
	return;
    }
    fnbuf[0] = 0;
    //show_compile_options(NULL, fnbuf, 1024);
    if (cp1) {
	if (cp2) {
	    snprintf(yi_fname, 128, "%s/%s-timing%s-%s-%d.txt", cp1, pname, fnbuf, cp2, myrank);
	} else {
	    snprintf(yi_fname, 128, "%s/%s-timing%s-%d.txt", cp1, pname, fnbuf, myrank);
	}
    } else {
	if (cp2) {
	    snprintf(yi_fname, 128, "%s-timing%s-%s-%d.txt", pname, fnbuf, cp2, myrank);
	} else {
	    snprintf(yi_fname, 128, "%s-timing%s-%d.txt", pname, fnbuf, myrank);
	}
    }
    if ((fp = fopen(yi_fname, "w")) == NULL) {
	fprintf(stderr, "Cannot open the file : %s\n", yi_fname);
	fp = stdout;
    }
    fprintf(fp, "Event,Max(usec),Min(usec),Count\n");
    for (evt = 0; evt < tot; evt++) {
	fprintf(fp, "%s:%6.3f,%6.3f,%ld\n", yi_timer[evt].sym, yi_tmax[evt], yi_tmin[evt], yi_cnt[evt]);
    }
    for (evt = 0; evt < tot; evt++) {
	fprintf(fp, "%s (%d entries),", yi_timer[evt].sym, yi_timer[evt].ncnt);
    }
    fprintf(fp, "\n");
    for (cnt = 0; cnt < YI_TMR_COUNT_MAX; cnt++) {
	for (evt = 0; evt < tot; evt++) {
	    if (cnt < yi_timer[evt].ncnt) {
		fprintf(fp, "%6.3f,", yi_timer[evt].tm[cnt]);
	    } else {
		fprintf(fp, ",");
	    }
	}
	fprintf(fp, "\n");
    }
    fprintf(fp, "#######################\n");
    if (fp != stdout) fclose(fp);
}
