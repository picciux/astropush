#    Log backend for Astroberry-Push, a simple push notification layer for Astroberry.
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

# Log backend implementation

if [ ! -f "$CONFIG_DIR/backend.log.conf" ]; then
    echo "Missing backend config file '$CONFIG_DIR/backend.log.conf" 1>&2
    exit 1
fi

source "$CONFIG_DIR/backend.log.conf"

push_log() {
    case $3 in
        #verbose
        1)
            prio="verbose"
            ;;

        #info
        2)
            prio="info   "
            ;;

        #warn
        3)
            prio="warning"
            ;;

        #error
        4)
            prio="error  "
            ;;
    esac

    echo "$prio $1 $2" >> "$LOGFILE"
}

