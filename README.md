
# Astroberry-push

## A simple push notification abstraction layer for Astroberry (or any other linux platform with KStars/Ekos).

Standing during an all-night-long deep sky photography session could be hard, especially if you have to conciliate other activities (going to work in the morning, to say...). [KStars and Ekos](https://edu.kde.org/kstars/) offer a fully-automated observatory environment, but we all know that something can go wrong requiring our intervention; since KStars provides a fully configurable notification system, I came up with the idea of abstracting the actual push notification transport using a simple frontend/backend architecture: the frontend offers a constant interface for KStars to send notifications to, forwarding them to the configured backend, that in turn will carry on through the actual push notifications transport.

The backend could be a simple email notification, a custom client/server application, or one of many (free or paid) push notification services available online: as long as it can be used through a shell script, any system will do the job.

While this system was initially developed for [Astroberry Server](https://astroberry.io/) distro, it can be used (or adapted with ease) to any linux system.

Frontend and backend are relatively simple shell scripts, detailed as follows.


### The frontend {#section-frontend}

The frontend has the following syntax:

    astroberry-push <module> <message> [<priority>]
    
where:
- **module** is the module generating the notification; it corresponds to KStars modules, plus two more general modules, and should be one of:
    - astroberry
    - kstars
    - alignment
    - capture
    - focus
    - guide
    - mount
    - scheduler
- **message** is the notification message text
- **priority** is an optional priority level. Levels are: *error*, *warn*, *info*, *verbose*. If omitted, priority defaults to *warn*. The priority will determine if the notification actually goes through or is filtered out, and possibly some other indication to the user (e.g. different sounds or colors) if the actual notification backend supports it.

Configuration for the frontend resides in the file:

    /etc/astroberry-push/push.conf
    
There you can choose which backend to use and define which is the minimum priority level below of which notifications will be filtered out.

### The backend

The backend is the script that do the hard work: when receving a notification from the frontend, it does what it's needed to pass it through the actual notification system: from reformatting the data, to spawning specialized process(es), it ensures that the information is at least sent for delivery. 

The backend can have its configuration file: if present, it usually is located in `/etc/astroberry-push` directory, and named `backend.<backend-name>.conf`. Its content is peculiar of the backend itself, so can't be documented here.

### Installation

*Frontend* installation is just a matter of launching `install.sh` script. Care should be taken to launch it from the same user you will run Kstars under, and will require password for sudo. If you want KStars notifications to go through Astroberry-Push, KStars should be configured to do so: the script will ask if you want to overwrite current KStars notifications config with the one provided with Astroberry-Push, which basically will disable all sound notifications and direct them to Astroberry-Push itself. It's just a starting point: texts and priorities can be further customized at will, using the same KStars UI (under menu *Settings|Configure notifications...*). If you choose not to overwrite your current KStars notification config, you can always change it by hand from KStars UI: open provided kstart.notifyrc as an example of how to configure it to notify through Astroberry-Push.

*Backend* installation is dependent of how backend is implemented, and should be documented by the backend itself.

### Backends {#section-backends}

Astroberry-Push provides a simple testing/debugging backend called **Log**, which, guess what, simply logs received notifications to a text file: its config file `/etc/astroberry-push/backend.log.conf` merely let us choose the path and name of the log file; keep in mind that Astroberry-Push (and related backend) will run under the same user Kstars is running under, so take care that user has the rights to write to the log file. You can find it in *log-backend* subdir inside this package, together with its installation script.

Also available is a backend for [Gotify](https://gotify.net/) push notification server: it allows me to have a working notification system in the wild without an internet connection (that is where I photograph the most). It's source is available at [this Github repo](https://github.com/picciux/astroberry-push-backend-gotify.git) where you'll find relevant documentation.

### Developing new backends {#section-backend-development}
The backend is a bash script the will be sourced (not executed) by the frontend. The frontend expects to find the backend in a directory under its backends path (`/usr/share/astroberry-push/backends`) named after the backend name (the same name configured in push.conf), in a file named `backend.sh`. When the frontend needs to forward a notification, it will source the backend script, and try to execute a function named `push_<backend-name>` with following parameters:

    push_<backend-name> <module> <message> <priority>
    
`<module>` and `<message>` are the same as specified in [The frontend](#section-frontend) section. `<priority>` is specified as a number in range 1-4, corresponding to following priority levels:

1. verbose
2. info
3. warn
4. error

What to do with this data, is responsibility of the backend implementation itself.

### Project home

Project home is [this Github repo](https://github.com/picciux/astroberry-push.git).

### Licensing

Astroberry-Push is copyright of Matteo Piscitelli (matteo AT matteopiscitelli DOT it) and is licensed under the [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).


