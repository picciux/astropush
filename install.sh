#! /bin/bash

#    Astroberry-Push. A simple push notification layer for Astroberry.
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

if [ "$UNINSTALL" = "yes" ]; then
    echo "### Uninstalling astroberry-push..."
    sudo rm -R $PREFIX/etc/astroberry-push
    sudo rm -R $PREFIX/usr/share/astroberry-push
    sudo rm $PREFIX/usr/bin/astroberry-push
    sudo rm $PREFIX/usr/bin/notify-indi-watchdog
    if [ -e  "$HOME/.config/kstars.notifyrc" ]; then
        rm $HOME/.config/kstars.notifyrc
        if [ -f $HOME/.config/kstars.notifyrc.bak ]; then
            mv $HOME/.config/kstars.notifyrc.bak $HOME/.config/kstars.notifyrc
        fi
    fi
    echo "### Done!"
    exit 0
fi

make_dirs() {
    sudo mkdir -p $PREFIX/etc/astroberry-push
    sudo mkdir -p $PREFIX/usr/bin
    sudo mkdir -p $PREFIX/usr/share/astroberry-push/backends
    mkdir -p $PREFIX/$HOME/.config
}
do_install() {
    make_dirs
    # install -D --mode=755 "$MYDIR/astroberry-push" $PREFIX/usr/bin/
    # install -D --mode=755 "$MYDIR/notify-indi-watchdog" $PREFIX/usr/bin/
    # install -D --mode=644 "$MYDIR/push.conf.sample" $PREFIX/etc/astroberry-push/push.conf
    sudo cp "$MYDIR/astroberry-push" $PREFIX/usr/bin/
    sudo cp "$MYDIR/notify-indi-watchdog" $PREFIX/usr/bin/notify-indi-watchdog
    sudo cp "$MYDIR/push.conf.sample" $PREFIX/etc/astroberry-push/push.conf
}

do_live_install() {
    make_dirs
    sudo ln -s $( realpath "$MYDIR/astroberry-push" ) $PREFIX/usr/bin/
    sudo ln -s $( realpath "$MYDIR/push.conf.sample" ) $PREFIX/etc/astroberry-push/push.conf
}

install_kstars_notifyrc() {
    if [ -f "$PREFIX/$HOME/.config/kstars.notifyrc" ]; then
        echo 'You appear to already have a KStars notification config: you can choose to overwrite'
        echo 'it to let KStars notifications to go through astroberry-push. Note that overwriting'
        echo 'will disable any previous config you made. Anyways, your current notification'
        echo "config will be saved to '$PREFIX/$HOME/.config/kstars.notifyrc.bak'. If you choose not to"
        echo "overwrite it, you'll have to setup notifications through KStars UI to let them go"
        echo "through astroberry-push: read 'kstars.notifyrc' in this package as a starting "
        echo 'point.'
        read -p "Do you want to overwrite '$PREFIX/$HOME/.config/kstars.notifyrc' (yes/no)?" overwrite
        if [ "$overwrite" = "yes" ]; then
            mv $PREFIX/$HOME/.config/kstars.notifyrc $PREFIX/$HOME/.config/kstars.notifyrc.bak
        fi
    fi
    
    if [ "$LIVE_INSTALL" = "yes" ]; then
        ln -s $( realpath "$MYDIR/kstars.notifyrc" ) $PREFIX/$HOME/.config/
    else
        cp "$MYDIR/kstars.notifyrc" $PREFIX/$HOME/.config/
    fi
}

echo "### Installing astroberry-push..."

if [ "$LIVE_INSTALL" = "yes" ]; then
    do_live_install
    install_kstars_notifyrc
else
    do_install
    install_kstars_notifyrc
fi

echo "### Done!"
echo


