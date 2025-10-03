if ! typeset -F gg-find >/dev/null; then
    gg-find() {
        find "$HOME" -maxdepth 3 -type d -name .git -exec dirname '{}' \; | sort -u
    }
fi

if [ -z "$GG_CACHE_FILE" ]; then
    GG_CACHE_FILE="$HOME/.gg/.cache"
fi

gg-cache() {
    if [ ! -f "$GG_CACHE_FILE" ]; then
        gg-find >"$GG_CACHE_FILE"
    fi
}

gg-find-all() {
    gg-cache
    cat "$GG_CACHE_FILE"
}

gg-find-by-id() {
    gg-cache
    sed "${1}q;d" "$GG_CACHE_FILE"
}

gg-exec() {
    local index list search_term match_count last_dir dirty branch
    index=$1
    shift
    if [ "$index" = "all" ]; then
        search_term="."
        list=$(gg-find-all)
        index=1
    elif [ "$index" = "search" ]; then
        list=$(gg-find-all)
        index=1
        search_term=${1:1}
        shift
    else
        search_term="."
        list=$(gg-find-by-id $index)
        if [ -z "$list" ]; then
            echo 'invalid id'
            return
        fi
    fi
    match_count=0
    while IFS= read -r dir; do
        if [[ "$dir" =~ $search_term ]]; then
            ((match_count++))
            last_dir="$dir"
            if [ $# -eq 0 ]; then
                # no command => show repository state
                dirty=$(git -C $dir status --porcelain | grep -q . && echo '[+]')
                branch=$(git -C $dir symbolic-ref --short -q HEAD || echo -e "\e[31mHEAD\e[0m")
                echo -e "\e[33m$index \e[34m$dir \e[32m$branch \e[31m$dirty\e[0m"
            else
                # execute git command in repo
                echo -e "\e[33m$index \e[34m$dir\e[0m: \e[32mgit $@\e[0m"
                git -C $dir $@
            fi
        fi

        ((index++))
    done <<< "$list"
    if [ $# -eq 0 ] && [ $match_count -eq 1 ]; then
        # 'gg 2' => cd into repo 2
        echo -e "\e[33mChanging directory...\e[0m"
        cd $last_dir
        return
    fi
}

gg() {
    if [ $# -eq 0 ]; then
        # no args => invalidate cache and list
        rm -f "$GG_CACHE_FILE"
        gg-exec all
    elif [ "$1" = "ls" ]; then
        # ls => list without invalidating cache
        gg-exec all
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        # 1st arg is a number => exec for a single repository
        gg-exec $@
    elif [[ "$1" =~ ^\\. ]]; then
        # 1st arg starts with '.' => search
        gg-exec search $@
    else
        # 1st arg is not a number => exec for all repositories
        gg-exec all $@
    fi
}
