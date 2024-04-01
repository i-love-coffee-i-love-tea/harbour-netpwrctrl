.pragma library

.import QtQuick 2.0 as Qt

function togglePower(address, username, password, outlet,  newComboIndex) {

    console.log("switching socket " + outlet);
    var xhr = new XMLHttpRequest();

    xhr.onreadystatechange = (function(myxhr) {
        return function() {
            if(myxhr.readyState === 4) {
                console.log("response was " + myxhr.status)
            }
        }
    })(xhr);

    var cmd = "";
    if (newComboIndex === 0) {
        cmd = "Sw_on"
    } else {
        cmd = "Sw_off"
    }
    var credentials = Qt.btoa(username + password)
    var url = 'http://' + address + '?'+ cmd +'=' + outlet + ',' + credentials;

    console.log("GET " + url);
    xhr.open('GET', url, true);
    xhr.send('\n\n');
}
