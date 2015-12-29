_vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

vercomp () {
    [ -z "$2" ] && return 3
    _vercomp $1 $2
}

install () {
    fold=/home/$USER/.suibash
    shell="bash"
    if [ $# -eq 2 ]; then
        shell=$1
        fold=$2
    elif [ $# -eq 1 ]; then
        shell=$1
    else
        echo "Usage: ./install <shell> [install_folder]"
        return 0
    fi
    installed_version=$(cat ${fold}/.src/version)
    current_version=$(cat ./version)
    vercomp $installed_version $current_version
    case $? in
        0) echo "You already have installed this version (${installed_version} = ${current_version})"
            return 1;;
        1) echo "You have already installed a newer version. Are you sure about overwritting it (Y/n)?"
            read answer
            if [ -n "$answer" ] && [ "$answer" != 'Y' ] && [ "$answer" != 'y' ]; then
             return 1
            fi;;
        2) echo "Updating to ${current_version}"
            echo "Saving history files"
            mkdir -p backup
            cp $fold/*_command_usage backup/.
            echo "Deleting old version files"
            rm -rf $fold;;
        3) echo "Installing suibash version ${current_version} on ${fold}";;
    esac
    rcfile=~/.${shell}rc
    file=${shell}_command_usage
    mkdir -p $fold/.src && \
    touch $fold/$file && \
    if [ -n "`ls backup`" ]; then
        echo "Restoring history files"
        cp backup/*_command_usage $fold/.
        rm backup/*_command_usage
    fi
    cp -r * $fold/.src && \
    cat << EOF > $fold/.${shell}-env
export SUIBASH_HOME=$fold
export SUIBASH_VERSION=\`cat \$SUIBASH_HOME/.src/version\`
export SUIBASH_SHELL=${shell}
source \$SUIBASH_HOME/.src/prepare_${shell}.sh
EOF
    [ -z "`grep ${fold} ${rcfile}`" ] && echo "source $fold/.${shell}-env" >> ${rcfile}
    echo "Ready, execute:" && \
    echo "    source ${rcfile}" && \
    echo "to start using it."
}

install $@