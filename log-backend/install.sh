#! /bin/bash

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

# AstroPush log backend install script                 #

PREFIX=
LIVE_INSTALL=no
UNINSTALL=no

print_usage() {
    echo " USAGE: $0 [options]"
    echo "   OPTIONS"
    echo "    -p, --prefix <prefix>        prepend <prefix> to file installation paths"
    echo "    -l, --live                   symlink file from files in package instead of copying" 
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
        --live|-l)
            LIVE_INSTALL=yes
            ;;
            
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

if [ ! -d $PREFIX/etc/astropush ]; then
    echo "Error: config directory missing. Is frontend installed?" 1>&2
    exit 1
fi

if [ ! -d $PREFIX/usr/share/astropush/backends ]; then
    echo "Error: backends directory missing. Is frontend installed?" 1>&2
    exit 1
fi

if [ "$UNINSTALL" = "yes" ]; then
    echo "### Uninstalling astropush log backend..."
    sudo rm $PREFIX/etc/astropush/backend.log.conf
    sudo rm -R $PREFIX/usr/share/astropush/backends/log
    echo "### Done!"
    exit 0
fi

echo "### Installing astropush log backend..."

if [ "$LIVE_INSTALL" = "yes" ]; then
    sudo ln -s $( realpath "$MYDIR" ) $PREFIX/usr/share/astropush/backends/
    sudo ln -s $( realpath "$MYDIR/backend.log.conf" ) $PREFIX/etc/astropush/
else
    sudo mkdir -p $PREFIX/usr/share/astropush/backends/log
    sudo cp $MYDIR/backend.sh $PREFIX/usr/share/astropush/backends/log/
    sudo cp $MYDIR/backend.log.conf $PREFIX/etc/astropush
fi

echo "### Log backend installed!"
echo "### Don't forget to enable it editing /etc/astropush/push.conf"
echo


