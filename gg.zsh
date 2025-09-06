if ! typeset -f gg-find > /dev/null; then
    gg-find() {
        find "$HOME" -maxdepth 3 -type d -name .git -exec dirname '{}' \; | sort -u
    }
fi

if [[ -z "$GG_CACHE_FILE" ]]; then
    GG_CACHE_FILE="$HOME/.gg/.cache"
fi

gg-cache() {
    if [[ ! -f "$GG_CACHE_FILE" ]]; then
        gg-find > "$GG_CACHE_FILE"
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

gg-ls() {
    local dirty branch index list
    index=1
    list=$(gg-find-all)
    while IFS= read -r dir; do
        dirty=$(git -C $dir status --porcelain | grep -q . && echo '[+]')
        branch=$(git -C $dir symbolic-ref --short -q HEAD || echo -e "\e[31mHEAD\e[0m")
        echo -e "\e[33m$index \e[34m$dir \e[32m$branch \e[31m$dirty\e[0m"
        ((index++))
    done <<< "$list"
}

gg-exec() {
    local index list
    index=$1
    shift
    if [[ "$index" == "all" ]]; then
        list=$(gg-find-all)
        index=1
    else
        list=$(gg-find-by-id $index)
        if [[ ! -n "$list" ]]; then
            echo 'invalid id'
            return
        fi
    fi
    while IFS= read -r dir; do
        if [[ "$@" == "" ]]; then
            # 'gg 2' => cd into repo 2
            cd $dir
            return
        fi

        # execute git command in repo
        echo -e "\e[33m$index \e[34m$dir\e[0m: \e[32mgit $@\e[0m"
        git -C $dir $@

        ((index++))
    done <<< "$list"
}

gg() {
    if [[ "$@" == "" ]]; then
        # no args => invalidate cache and list
        rm -f "$GG_CACHE_FILE"
        gg-ls
    elif [[ "$1" == "ls" ]]; then
        # ls => list without invalidating cache
        gg-ls
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        # 1st arg is a number => exec for a single repository
        gg-exec $@
    else
        # 1st arg is not a number => exec for all repositories
        gg-exec all $@
    fi
}

