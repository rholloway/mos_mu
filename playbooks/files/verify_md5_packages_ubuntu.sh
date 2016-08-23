#!/bin/bash

# This script verifies MD5 sum for all installed python packages
# Return:
#     0 - ok
#     1 - some packets were installed not from configured repositories
#     2 - some other error
# Output:
#     List of customized packages and unidentified packages
APT_CONF=${APT_CONF:-$1}
APT_CONF=${APT_CONF:-"/etc/apt/apt.conf"}

# Return:
#     0 - ok
#     1 - installed package was customized
#     x - some other error
function md5_verify()
{
    PKG=${1:?"Please specify package name."}
    cd / || return 2

    RESULT=$(nice -n 19 ionice -c 3 dpkg -V "${PKG}")
    (( $? != 0 )) &&
        return 2
    RESULT=$(echo -e "${RESULT}" | awk '{if ($2 != "c") print $2}')
    [ -n "${RESULT}" ]  &&
        return 1
    return 0
}


# Get list of all installed packages and check md5 sum for them
CUSTOMIZED_PKGS=""
ALL_PKGS=$(dpkg-query -W -f='${Package}\n') || exit -1

RET=0
for PKG in ${ALL_PKGS}; do
    md5_verify "${PKG}"
    case $? in
        0)
            ;;
        1)
            [[ "${CUSTOMIZED_PKGS}" != "" ]] &&
                CUSTOMIZED_PKGS+="\n"
            CUSTOMIZED_PKGS+="${PKG}"

            PKG_POLICY=$(apt-cache -c "${APT_CONF}" policy "${PKG}") || exit -1
            echo "${PKG_POLICY}" | grep -F "***" -A1 | grep Packages &> /dev/null
            if [ $? != 0 ]; then
                echo "Unidentified package: \"${PKG}\" was installed not from the configured repositories."
                let "RET|=1"
            fi
            ;;
        *)
            let "RET|=2"
            ;;
    esac
done

# Make sure that all upgradable packages were installed from configured repos
ALL_PKGS=$(apt-get -c "${APT_CONF}" --just-print upgrade | grep "Inst" | awk '{print $2}' ) || exit -1
for PKG in ${ALL_PKGS}; do
    PKG_POLICY=$(apt-cache -c "${APT_CONF}" policy "${PKG}") || exit -1
    echo "${PKG_POLICY}" | grep -F "***" -A1 | grep Packages &> /dev/null
    if [ $? != 0 ]; then
        echo "Unidentified package: \"${PKG}\" was installed not from the configured repositories."
        let "RET|=1"
    fi
done

[ -z "${CUSTOMIZED_PKGS}" ] || echo -e "${CUSTOMIZED_PKGS}"

exit "${RET}"
