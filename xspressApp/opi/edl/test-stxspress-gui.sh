#!/bin/bash
# Tests for the stxspress-gui launcher's options (-d, --colours). Needs no
# EPICS or EDM: it builds the launcher from stxspress-gui.in the way the
# Makefile does, with a stub edm that records what it was given.
#
# Usage: bash xspressApp/opi/edl/test-stxspress-gui.sh

# The checks are eval'd strings, expanded when they run.
# shellcheck disable=SC2016,SC2001
set -u

HERE=$(cd "$(dirname "$0")" && pwd)
TOP=$(cd "${HERE}/../../.." && pwd)
T=$(cd "$(mktemp -d)" && pwd -P)  # physical path, as readlink -f prints
trap 'rm -rf "${T}"' EXIT

# Installed EDM config, the env script that points EDMFILES at it, an ADOdin
# tree with the 4-card status screen, and the stub edm.
mkdir -p "${T}/edm" "${T}/adodin/odinApp/op/edl/odin" "${T}/bin" "${T}/run" "${T}/tmp-alt"
for f in colors.list fonts.list edmPrintDef edmObjects edmPvObjects; do
    echo "installed ${f}" > "${T}/edm/${f}"
done
touch "${T}/adodin/odinApp/op/edl/odin/OdinDataStatus4.edl"
echo "export EDMFILES=${T}/edm" > "${T}/gui-env.sh"
cat > "${T}/bin/edm" <<'EOF'
#!/bin/bash
{
    echo "EDMFILES=${EDMFILES}"
    for f in colors.list fonts.list edmPrintDef; do
        echo "${f}=$(readlink -f "${EDMFILES}/${f}")"
    done
    echo "args=$*"
} > "${STUB_OUT}"
EOF
chmod +x "${T}/bin/edm"

sed -e "s|@TOP@|${TOP}|g" -e 's|@ARCH@|linux-x86_64|g' \
    -e "s|@ASYN@|${T}/asyn|g" -e "s|@ADCORE@|${T}/adcore|g" \
    -e "s|@ADODIN@|${T}/adodin|g" \
    -e "s|@XSPRESS_GUI_ENV@|${T}/gui-env.sh|g" \
    -e 's|@XSPRESS_IOC_ENV@||g' \
    "${HERE}/stxspress-gui.in" > "${T}/stxspress-gui"
chmod +x "${T}/stxspress-gui"

QD_COLOURS=$(readlink -f "${TOP}/xspressApp/opi/colours/qd/colors.list")
FAILS=0

# run ARGS...: runs the launcher; sets STATUS, ERR and OUT (the stub's record,
# empty if edm was not started).
run() {
    rm -f "${T}/out"
    env -u DISPLAY PATH="${T}/bin:${PATH}" STUB_OUT="${T}/out" \
        XDG_RUNTIME_DIR="${T}/run" XSPRESS_NUM_CARDS=4 \
        "${T}/stxspress-gui" "$@" > /dev/null 2> "${T}/err"
    STATUS=$?
    ERR=$(cat "${T}/err")
    OUT=$(cat "${T}/out" 2>/dev/null)
}

# check NAME CONDITION...: records a pass or a failure.
check() {
    local name=$1
    shift
    if "$@"; then
        echo "ok   ${name}"
    else
        echo "FAIL ${name}"
        echo "     status=${STATUS} err=${ERR}"
        echo "${OUT}" | sed 's/^/     /'
        FAILS=$((FAILS + 1))
    fi
}

has() { grep -qxF "$1" <<< "${OUT}"; }
lacks_noedit() { ! grep -q -- '-noedit' <<< "${OUT}"; }
classic() { has "EDMFILES=${T}/edm"; }
qd() {
    ! has "EDMFILES=${T}/edm" && has "colors.list=${QD_COLOURS}" \
        && has "fonts.list=${T}/edm/fonts.list" \
        && has "edmPrintDef=${T}/edm/edmPrintDef"
}

run
check "no option: classic colours, execute-only" eval 'classic && grep -q -- "-noedit" <<< "${OUT}"'
run --colours classic
check "--colours classic: classic colours" classic
run --colours qd
check "--colours qd: QD colours.list, installed fonts.list and edmPrintDef" qd
run -d --colours qd
check "-d --colours qd: QD colours, edit mode" eval 'qd && lacks_noedit'
run --colours=qd -d
check "--colours=qd -d: QD colours, edit mode" eval 'qd && lacks_noedit'
run --colours qd --colours classic
check "last --colours wins" classic
run --colours pink
check "--colours pink: exit 2, schemes listed, no edm" \
    eval '[ "${STATUS}" = 2 ] && [ -z "${OUT}" ] && grep -q classic <<< "${ERR}" && grep -q qd <<< "${ERR}"'
run --colours
check "--colours without a name: exit 2, no edm" eval '[ "${STATUS}" = 2 ] && [ -z "${OUT}" ]'
run --bogus
check "unknown option: exit 2, no edm" eval '[ "${STATUS}" = 2 ] && [ -z "${OUT}" ]'
run --colours qd
run --colours qd
check "--colours qd twice in a row" qd
rm -f "${T}/out"
env -u DISPLAY -u XDG_RUNTIME_DIR PATH="${T}/bin:${PATH}" STUB_OUT="${T}/out" \
    TMPDIR="${T}/tmp-alt" XSPRESS_NUM_CARDS=4 \
    "${T}/stxspress-gui" --colours qd > /dev/null 2> "${T}/err"
STATUS=$?
ERR=$(cat "${T}/err")
OUT=$(cat "${T}/out" 2>/dev/null)
check "--colours qd without XDG_RUNTIME_DIR: uses TMPDIR" eval 'qd && [ -d "${T}/tmp-alt/stxspress-gui-$(id -u)/qd" ]'

# In a shared directory, a per-user directory planted by someone else (here a
# symlink to a directory the launcher would otherwise fill) must be refused.
mkdir -p "${T}/shared" "${T}/elsewhere"
ln -s "${T}/elsewhere" "${T}/shared/stxspress-gui-$(id -u)"
rm -f "${T}/out"
env -u DISPLAY PATH="${T}/bin:${PATH}" STUB_OUT="${T}/out" \
    XDG_RUNTIME_DIR="${T}/shared" XSPRESS_NUM_CARDS=4 \
    "${T}/stxspress-gui" --colours qd > /dev/null 2> "${T}/err"
STATUS=$?
ERR=$(cat "${T}/err")
OUT=$(cat "${T}/out" 2>/dev/null)
check "planted per-user directory refused" \
    eval '[ "${STATUS}" = 1 ] && [ -z "${OUT}" ] && [ -z "$(ls -A "${T}/elsewhere")" ]'

if [ "${FAILS}" -ne 0 ]; then
    echo "${FAILS} check(s) failed"
    exit 1
fi
echo "all checks passed"
