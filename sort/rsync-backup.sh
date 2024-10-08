
#!/bin/bash

echo -e "\e[32m" # Set the text color to green
cat << "EOF"
  __________   __           _____        __________                __                 
  \______   \_/  |_________/ ____\______ \______   \_____    ____ |  | ____ ________  
   |    |  _/\   __\_  __ \   __\/  ___/  |    |  _/\__  \ _/ ___\|  |/ /  |  \____ \ 
   |    |   \ |  |  |  | \/|  |  \___ \   |    |   \ / __ \\  \___|    <|  |  /  |_> >
   |______  / |__|  |__|   |__| /____  >  |______  /(____  /\___  >__|_ \____/|   __/ 
          \/                         \/          \/      \/     \/     \/     |__|    
EOF
echo -e "\e[0m" # Reset the text color to default

# Prompt the user for the variables
read -p "Enter the backup directory (e.g., /mnt/Images): " BACKUP_DIR
read -p "Enter the source directory (e.g., /Nas): " SOURCE_DIR
read -p "Enter the path to the log file (e.g., /path/to/log/file.log): " LOG_FILE
read -p "Enter your email address (e.g., your_email@example.com): " EMAIL

# Functions
error_exit() {
    echo "Error: $1"
    echo "Backup failed at $(date)" >> $LOG_FILE
    echo "Error: $1" >> $LOG_FILE
    exit 1
}

# Start logging
echo "Backup started at $(date)" >> $LOG_FILE

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    error_exit "Source directory $SOURCE_DIR does not exist."
fi

# Check if backup directory exists, if not create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || error_exit "Failed to create backup directory $BACKUP_DIR."
fi

# Backup
tar -czf "$BACKUP_DIR/backup_$(date +%Y%m%d%H%M%S).tar.gz" "$SOURCE_DIR" >> $LOG_FILE 2>&1

# Verify backup
if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)" >> $LOG_FILE
    echo "Backup for $(date) was successful" | mail -s "Backup Status" $EMAIL
else
    echo "Backup failed at $(date)" >> $LOG_FILE
    echo "Backup for $(date) failed" | mail -s "Backup Status" $EMAIL
    exit 1
fi

# Backup rotation
cd $BACKUP_DIR
ls -t | sed -e '1,5d' | xargs -d '\n' rm -f --

# End logging
echo "Backup process ended at $(date)" >> $LOG_FILE

# Send email notification (assuming mail is set up)
echo "Backup completed successfully at $(date)" | mail -s "Backup Notification" $EMAIL




# BASICS -----------------------------------------------------------------------
# extended globbing is needed for arg parsing and source/filter expressions
shopt -s extglob

# disable file globbing so things like * can be used for regexps
set -f

# basic info set at init(), not considered configuration
export script_name script_dir script_title script_version sudo


# CONFIGURATION ----------------------------------------------------------------
# these are "basic configuration", tune them at init()
export -a config_locations config_suffixes rsyncflags_progress

# defaults below can be overridden by external config and (in some cases) by
# command line options

# config file to use: full/relative path or just the name, in the latter case
# the file will be searched for as specified in the config_* arrays above
# command line overrides: -c
export config=''

# path to a btrfs subvolume (NOT a root volume), for snapshot storage
# will be created automatically if it doesn't exist
export destination=''

# (single line) file globs with paths to back up
export -a sources=()

# (multiline) rsync include / exclude patterns, indexed by entry in $sources
export -A filters=()

# retention policy: min snapshots to keep per level (>= 0) before rotation
export -A retention=( [leafs]=15 [days]=30 [weeks]=24 [months]=12 [years]=5 )

# what to do when a snapshot is marked for rotation by the retention checks
# so far only "test" and "remove" are implemented
export rotate_handler=remove

# first day of the week, used in the weekly retention checks
# case insensitive: can be 1/monday or 7/sunday
export weekstart=sunday

# prefix for commands in dryrun mode
# command line overrides: -d (sets to 'msg')
export dryrun=''

# recommended rsync flags, tune as needed (-q sets $rsyncflags_verbose to '')
export rsyncflags='-aHAXER --numeric-ids --inplace --no-whole-file --delete-delay --force --human-readable'

# flags for verbose mode in commands
# command line overrides: -q (unsets)
export flags_verbose='-v'
export rsyncflags_verbose='-vv'

# default index for $rsyncflags_progress
# command line overrides: -p[n], -q (unsets)
export rsync_progress=1

# character used for header lines
export header_char='~'


# I/O --------------------------------------------------------------------------
msg() {
    (( $# )) && {
        echo -e "$@" >&2
        return
    }

    cat >&2
}

error() {
    msg "$@"
    exit 1
}

header() {
    local tmp="${@}" length=80
    local header=$(printf "%0$(( length - ${#tmp} ))d")
    msg "\n$@ ${header//?/${header_char}}\n"
}

confirm() {
    local expect="$1"
    shift
    msg $@
    read
    [[ "$REPLY" =~ $expect ]]
}

cond() {
    local expr="$1" txt="$2"
    shift 2

    if { expr "$expr" > /dev/null ;}; then
        echo -ne "$txt"
    else
        echo -ne "$@"
    fi
}


# SNAPSHOT HELPERS -------------------------------------------------------------

# filter '/' in yyyy/mm/dd/hhmmmss lines to ' ', --tag n appends tag at EOL
# tag must be an integer, it will likely be used in the future to encode
# rotation level / misc info using bit maps
tokenize_path() {
    local tag=$(( $(expr "$1" == '--tag') ? ${2:-1} : 0 ))
    (( tag )) && sed -re "s|^$destination/(.*)$|\1 $tag|" -e 's|/| |g' \
              || sed -re "s|^$destination/(.*)$|\1|" -e 's|/| |g'
}

# filter tokenize_path-style input, tagging lines along per $retention policy
# with --all it outputs everything, instead of only tagged lines
check_retention() {
    local rest y m d hms cd=0 cw lw=0 weekfmt cm=0 cy=0 tag=0 all=$(expr "$1" == '--all')

    case "${weekstart,,}" in
        @(1|monday)) weekfmt='%Y%V';;
        @(7|sunday)) weekfmt='%Y%U';;
        *) error "Invalid setting for \$weekstart: '$weekstart'. Aborting" ;;
    esac

    msg "Policy: keep the last ${retention[leafs]} leafs, ${retention[days]} days, ${retention[weeks]} weeks, ${retention[months]} months and ${retention[years]} years\n"

    while read y m d hms tag; do
        # check retention over the leaf counter (always changes)
        (( tag = retention[leafs]-- < 1 ))

        # check retention when the day has changed
        (( 10#$cd != 10#$d && (cd = 10#$d, tag &= retention[days]-- < 1) ))

        # check week retention when it changes
        cw=$(date -d "$y/$m/$d" +"$weekfmt")
        (( $lw != $cw && (lw = cw, tag &= retention[weeks]-- < 1) ))

        # check month and year retention when they change
        (( 10#$cm != 10#$m && (cm = 10#$m, tag &= retention[months]-- < 1) ))
        (( 10#$cy != 10#$y && (cy = 10#$y, tag &= retention[years]-- < 1) ))

        (( tag || all )) && echo $y $m $d $hms $tag
    done
}


# ROTATION HANDLERS ------------------------------------------------------------
rotate_test() {
    local y m d hms tag tagged=0
    while read y m d hms tag; do
        (( tag && ++tagged ))
        msg "$destination/$y/$m/$d/$hms$(cond $tag '' ' not') tagged"
    done

    msg "$tagged snapshot$(cond "$tagged != 1" s) tagged for rotation"
}

rotate_remove() {
    local y m d hms tag tagged=0
    while read y m d hms tag; do
        (( tag && ++tagged )) && {
            $dryrun $sudo btrfs subvolume delete "$destination/$y/$m/$d/$hms"

            # clean empty subtree
            # FIXME: output will be inaccurate in dry mode as we can't remove parents
            for dir in "$destination/"{$y/$m/$d,$y/$m,$y}; do
                [[ -z "$(ls -A "$dir")" ]] && $dryrun rmdir $flags_verbose "$dir"
            done
        }
    done

    msg "$tagged snapshot$(cond "$tagged != 1" s) removed"
}

rotate_archive() {
    msg "$FUNCNAME: not implemented yet"
}

rotate_move() {
    msg "$FUNCNAME: not implemented yet"
}

rotate_btrfs_send() {
    msg "$FUNCNAME: not implemented yet"
}


# USER COMMANDS ----------------------------------------------------------------
cmd_help() {
    msg <<EOF
Usage: $script_name -h | --help
       $script_name [COMMAND|OPTION]...

  -h, --help                  show this help

Commands can be specified multiple times:
  snap                        take a snapshot
  rotate                      apply retention policy on old snapshots
  test <n>                    test retention policy, simulating n random snapshots
  find <regex>                find snapshots whose path matches the regular expression
  remove <regex>              remove snapshots whose path matches the regular expression
  showcfg                     show the current configuration file
  editcfg                     edit the current configuration file (needs \$EDITOR)
  dumpcfg                     show the actual configuration values in use

Options can be specified multiple times, newer options override earlier ones:
  -c <file>, --config=<file>  configuration file to use
  -d, --dry-run               dry-run mode - only show what commands would be issued
  -p[n], --progress[=<n>]     choose rsync progress indicator:
                                  n=0: don't show progress
                                  n=1: use "--progress" for per-file progress (default)
                                  n=2: use "--info=progress2" for overall progress
                                  n=3: use "--info=progress2 --no-inc-recursive"
  -q, --quiet                 be less verbose (also sets -p0)
  -y, --yes                   automatically accept confirmations (be careful!)

EOF
    exit 0
}

cmd_snap() {
    header 'Taking snapshot'

    local serial="$(date +%Y/%m/%d/%H%M%S)" base="$destination$($sudo btrfs subvolume list -o --sort=ogen "$destination" 2>/dev/null | sed -nr '$s@.*/(([^/]+(/|$)){4})@/\1@p')"

    [[ "$base" == "$destination/$serial" ]] && error "Refusing to create a new snapshot with serial $serial"

    # create the destination btrfs subvolume if it doesn't exist
    [[ ! -d "$destination" ]] && {
        $dryrun btrfs subvolume create "$base"

        # if running under sudo, ensure the underlying user has access to it
        [[ -n "$SUDO_USER" ]] && (( ! $EUID )) && $dryrun $sudo chown $flags_verbose "$SUDO_USER":"$group" "$destination"
    }

    # create yy/mm/dd subtree for the new hhmmss leaf
    $dryrun mkdir $flags_verbose -p "$destination/${serial%/*}"

    if [[ "$base" == "$destination" ]]; then
        # first snapshot: the leaf is a standard subvolume
        $dryrun btrfs subvolume create "$destination/$serial"
    else
        # otherwise it is a new snapshot based on the last one
        $dryrun btrfs subvolume snapshot "$base" "$destination/$serial"
    fi

    # if running under sudo, ensure the underlying user has access to the leaf
    [[ -n "$SUDO_USER" ]] && (( ! $EUID )) && {
        local y m d hms group="$(getent group $SUDO_GID | cut -d: -f1)"

        IFS='/' read y m d hms <<< "$serial"
        for dir in "$destination/"{$serial,$y/$m/$d,$y/$m,$y}; do
            $dryrun $sudo chown $flags_verbose "$SUDO_USER":"$group" "$dir"
        done
    }

    # update the new snapshot
    local -a rsyncfilters=()
    for source in "${sources[@]}"; do
        msg "\nBacking up $source ..."
        readarray -t rsyncfilters< <(sed '/^$/d' <<< "${filters["$source"]}")
        $dryrun rsync $rsyncflags $rsyncflags_verbose ${rsyncflags_progress[${rsync_progress:-0}]} --filter="-/s $destination" "${rsyncfilters[@]/#/--filter=}" "$source" "$destination/$serial/"
    done
}

cmd_find() {
    if [[ "$1" == '--no-header' ]]; then shift
    else header 'Finding snapshots'
    fi

    local regex="$@"
    local -a found

    [[ -d "$destination" ]] || error "Destination directory does not exist: \"$destination\""
    cd "$destination"

    readarray -t found< <(find . -maxdepth 4 -mindepth 4 -type d | sed -r "s|^\.(.*)|$destination\1|" | sort -dr | grep "$regex")

    msg <<< "${#found[@]} snapshot$(cond "${#found[@]} != 1" s) found"

    # stdout
    for line in ${!found[@]}; do
        echo "${found[$line]}"
    done
}

cmd_rotate() {
    header "Applying retention policy (\"$rotate_handler\" rotation handler)"

    cmd_find --no-header '.*' | tokenize_path | check_retention | rotate_${rotate_handler}
}

cmd_remove() {
    header 'Removing snapshots'

    local snaps
    readarray -t snaps< <(cmd_find --no-header "$@")

    (( ${#snaps[@]} )) && {
        (( assume_yes )) || {
            printf '%s\n' "${snaps[@]}"

            confirm 'yes|y' "\nRemove $(cond "${#snaps[@]} > 1" them it)? Enter \"y\" or \"yes\" to confirm: " || unset snaps
            msg ''
        }
    }

    printf '%s\n' "${snaps[@]}" | tokenize_path --tag | rotate_remove
}

cmd_test() {
    header 'Testing retention policy'

    local -A results
    local count=${1:-0} new leapfeb yr=1.3 y m d h mi
    local daysmonth=( 31 28 31 30 31 30 31 31 30 31 30 31 )

    # year range: ensure retention years are > 0 and factor by $yr
    yr=$(LC_NUMERIC="en_US.UTF-8" printf "%.0f" $(bc <<< "(${retention[years]} + 1) * $yr"))

    while (( count )); do
        (( y = RANDOM % (yr + 1) + $(date +%Y) - yr, m = RANDOM % 12 + 1 ))
        (( leapfeb = ! (y % 4 || ! y % 100 && y % 400) && m == 2 ))
        (( d = RANDOM % (daysmonth[m - 1] + leapfeb) + 1 ))
        (( h = RANDOM % 23 + 1, mi = RANDOM % 59 + 1 , s = RANDOM % 59 + 1 ))

        new="$(printf "%02d/%02d/%02d/%02d%02d%02d" $y $m $d $h $mi $s)"
        [[ -z "${results[$new]:-}" ]] && {
            (( results[$new] = count-- ))
            echo "$destination/$new"
        }
    done | sort -dr | tokenize_path | check_retention --all | rotate_test
}

cmd_showcfg() {
    header 'Configuration file contents'
    cat "$config"
}

cmd_editcfg() {
    header "Opening configuration file with ${EDITOR} ..."
    [[ -z "$EDITOR" ]] && error "\$EDITOR is not defined"
    "$EDITOR" "$config"
}

cmd_dumpcfg() {
    header 'Current configuration values'

    for configvar in config{,_{locations,suffixes}} destination sources filters \
                     retention rotate_handler weekstart dryrun \
                     rsync{flags{,_{verbose,progress}},_progress}; do
        declare -p "$configvar" | sed -r 's/^declare -[^[:space:]]+ (.*$)/\1/' 2>/dev/null
    done
}


# MAIN -------------------------------------------------------------------------
init() {
    for section in "$@"; do
        case $section in
            basics)
                # basic information about the script
                script_name="$0"
                script_dir="$(dirname $(readlink -f "$0"))"
                script_title="btrfs-backup"
                [[ -f "$script_dir/VERSION" ]] && {
                    read script_version < "$script_dir/VERSION"
                }

                # some btrfs subcommands need to be run as root via sudo
                # skip when we already are root, as then it might not be allowed
                sudo=$(cond $EUID sudo '')

                # locations where to search for config files
                config_locations=()
                config_locations+=("$script_dir")
                config_locations+=("$script_dir/config")
                config_locations+=('.')

                # file suffixes to use when searching
                config_suffixes=()
                config_suffixes+=('')
                config_suffixes+=(.conf)
                config_suffixes+=(.cf)

                # rsync progress indicator switch combos
                rsyncflags_progress=()
                rsyncflags_progress+=('')
                rsyncflags_progress+=('--progress')
                rsyncflags_progress+=('--info=progress2')
                rsyncflags_progress+=('--info=progress2 --no-inc-recursive')

                readonly script_name script_dir script_title script_version sudo
                readonly -a config_locations config_suffixes rsyncflags_progress
                ;;
        esac
    done
}

get_config() {
    local file="$@"

    # naked name: search files ending in $config_suffixes at $config_locations
    [[ ! "$@" =~ ^[./].* ]] && {
        for location in "${config_locations[@]}"; do
            for suffix in "${config_suffixes[@]}"; do
                file="$location/$(basename "${@}${suffix}")"
                [[ -f "$file" ]] && {
                    echo "$file"
                    exit 0
                }
            done
        done
    }

    error "Configuration file not found: \"$@\""
}

cmdline() {
    local token numtokens=$# skip_else
    local -a commands=()
    local -A command_args=()

    while token="$1"; do
        shift

        skip_else=0
        case "$token" in
            snap|find|remove|rotate|test|@(show|edit|dump)cfg)
                commands+=("$token")
                skip_else=1
                ;;&

            find|remove|test)
                (( $# )) || error "Expected an argument for the \"$token\" command"
                [[ "$token" == "test" && -n "${1//[0-9]/}" ]] && error "Argument for command \"$token\" must be numeric"
                command_args[$(( ${#commands[@]} - 1 ))]="$1"
                shift
                ;;

            -@(h|-help))
                (( numtokens > 1 )) && error <<EOF
Extra tokens on command line: ${@//${token}/}
"$token" must be passed alone, ie: $script_name $token

EOF
                cmd_help
                ;;

            -c) (( $# )) || error 'Expected a config file name after -c'
                config="$1"
                shift
                ;;

            --config=*)
                config="${token#*=}"
                [[ -z "$config" ]] && error 'Expected a config file name after --config'
                ;;

            -@(d|-dry-run)) dryrun='msg'
                ;;

            -@(p*([[:digit:]])|-progress?(=*[[:digit:]])))
                rsync_progress=${token##-@(p|-progress?(=))}
                token=${token%%?(=)${rsync_progress}*}
                if [[ -z "$rsync_progress" ]]; then
                    rsync_progress=1
                else
                    (( rsync_progress < ${#rsyncflags_progress[@]} )) || error "Argument to $token must be a number between 0 and $((${#rsyncflags_progress[@]} - 1))"
                fi
                ;;

            -@(q|-quiet)) unset flags_verbose rsyncflags_verbose rsync_progress
                ;;

            -@(y|-yes)) assume_yes=1
                ;;

            -*) error "Invalid option: $token"
                ;;

            '') break
                ;;

             *) (( skip_else )) || error "Token not recognized: $token"
                ;;
        esac
    done

    (( ${#commands[@]} )) || error 'Please specify a command, or -h for help'

    [[ -n "$config" ]] && {
        config="$(get_config "$config")" || exit $?

        msg "Using configuration file: $config"
        . "$config"
    }

    [[ -n "$dryrun" ]] && msg '\nDRY-RUN MODE - this is a simulationn'

    for cmd in ${!commands[@]}; do
        cmd_${commands[$cmd]} ${command_args[$cmd]}
    done
}

init basics
msg "$script_title $script_version\n"
cmdline "$@"
