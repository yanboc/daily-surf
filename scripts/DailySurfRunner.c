#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static const char *repo = "/Users/apple/Documents/projects/daily-surf";

static int valid_date(const char *value) {
    if (strlen(value) != 8) return 0;
    for (int i = 0; i < 8; i++) if (!isdigit((unsigned char)value[i])) return 0;
    return 1;
}

static int fail(const char *message, int code) {
    fprintf(stderr, "DailySurfRunner: %s\n", message);
    return code;
}

int main(int argc, char **argv) {
    if (argc < 2 || (strcmp(argv[1], "daily") != 0 && strcmp(argv[1], "mail") != 0)) {
        return fail("usage: DailySurfRunner <daily|mail> [--date YYYYMMDD] [--review]", 64);
    }
    if (strcmp(argv[1], "mail") == 0 && argc != 2) {
        return fail("mail does not accept additional arguments", 64);
    }

    if (strcmp(argv[1], "daily") == 0) {
        for (int i = 2; i < argc; i++) {
            if (strcmp(argv[i], "--review") == 0) continue;
            if (strcmp(argv[i], "--date") == 0 && i + 1 < argc && valid_date(argv[i + 1])) {
                i++;
                continue;
            }
            return fail("unsupported or invalid daily argument", 64);
        }
    }

    char script[512];
    snprintf(script, sizeof(script), "%s/scripts/%s", repo,
             strcmp(argv[1], "daily") == 0 ? "run_daily.sh" : "send_mail.sh");
    if (access(script, R_OK) != 0) {
        return fail("cannot read project script; enable Full Disk Access for DailySurfRunner.app", 77);
    }

    char *exec_args[16] = {0};
    exec_args[0] = "/bin/bash";
    exec_args[1] = script;
    for (int i = 2; i < argc && i < 15; i++) exec_args[i] = argv[i];
    execv("/bin/bash", exec_args);
    fprintf(stderr, "DailySurfRunner: exec failed: %s\n", strerror(errno));
    return 71;
}
