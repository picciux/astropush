#! /bin/bash

#    AstroPush. A simple push notification layer for KStars/Ekos on linux.
#    Copyright (C) 2022  Matteo Piscitelli <matteo@matteopiscitelli.it>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This is the installation script

PREFIX=
LIVE_INSTALL=no
UNINSTALL=no

print_usage() {
    echo " USAGE: $0 [options]"
    echo "   OPTIONS"
    echo "    -p, --prefix <prefix>        prepend <prefix> to file installation paths"
    echo "    -u, --uninstall              uninstall previously installed files"
    echo "    -h, --help                   prints this help"
    echo
    exit 0
}

ARG=
OPTS=$( getopt -q -u -l prefix:,live,uninstall,help p:luh $* )
if [ $? != 0 ]; then
    echo "ERROR: invalid options"
    print_usage
    exit 1
fi

for o in $OPTS; do
    case $ARG in
        prefix)
            ARG=
            if [ "${o:0:2}" = "'-" ]; then
                echo "ERROR: Missing argument for -p|--prefix option" 1>&2
                echo
                exit 1
            fi
            PREFIX=$o
            continue
            ;;
    esac
    
    case $o in
        --uninstall|-u)
            UNINSTALL=yes
            ;;

        --prefix|-p)
            ARG=prefix
            ;;
        --help|-h)
            print_usage
            ;;
    esac
done

MYDIR=$( dirname $0 )

if [ "$UNINSTALL" = "yes" ]; then
    echo "### Uninstalling astropush..."
    rm -R $PREFIX/etc/astropush
    rm -R $PREFIX/usr/share/astropush
    rm -R $PREFIX/usr/share/doc/astropush
    rm $PREFIX/usr/bin/astropush
    rm $PREFIX/usr/bin/notify-indi-watchdog
    echo "### Done!"
    exit 0
fi

do_install() {
    install -d $PREFIX/usr/bin
    install -d $PREFIX/etc/astropush
    install -d $PREFIX/usr/share/astropush
    install -d $PREFIX/usr/share/doc/astropush

    install "$MYDIR/astropush" "$MYDIR/notify-indi-watchdog" $PREFIX/usr/bin
    install -m 644 "$MYDIR/push.conf.sample" $PREFIX/etc/astropush/push.conf
    install -m 644 "$MYDIR/kstars.notifyrc" $PREFIX/usr/share/astropush/kstars.notifyrc
    install -m 644 "$MYDIR/LICENSE" "$MYDIR/README.md" $PREFIX/usr/share/doc/astropush/
}

do_install

echo "### Done!"
echo


