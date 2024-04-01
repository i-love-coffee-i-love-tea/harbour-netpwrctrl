# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-netpwrctrl

CONFIG += sailfishapp

DISTFILES += qml/harbour-netpwrctrl.qml \
    qml/cover/CoverPage.qml \
    qml/netpwrctrl.js \
    qml/pages/FirstPage.qml \
    qml/pages/SettingsPage.qml \
    rpm/harbour-netpwrctrl.changes.in \
    rpm/harbour-netpwrctrl.changes.run.in \
    rpm/harbour-netpwrctrl.spec \
    translations/*.ts \
    harbour-netpwrctrl.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-netpwrctrl-de.ts
