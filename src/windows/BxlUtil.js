    console.logCopy = console.log.bind(console);

    console.log = function()
    {
        if (arguments.length)
        {
            var timestamp = new Date().toJSON();
            var args = arguments;
            args[0] = timestamp + ' > ' + arguments[0];
            this.logCopy.apply(this, args);
        }
    };

    var BxlUtil = {
        messageDialog: function (msg) {
            new Windows.UI.Popups.MessageDialog(msg).showAsync().done(function () {
                console.log("BxlUtil : " + msg);
            });			
        },
        encodedStringToBytes: function (string) {
            var data = atob(string);
            var bytes = new Uint8Array(data.length);
            for (var i = 0; i < bytes.length; i++) {
                bytes[i] = data.charCodeAt(i);
            }
            return bytes;
        },
        bytesToEncodedString: function (bytes) {
            return btoa(String.fromCharCode.apply(null, bytes));
        },
        stringToBytes: function (string) {
            var bytes = new ArrayBuffer(string.length * 2);
            var bytesUint16 = new Uint16Array(bytes);
            for (var i = 0; i < string.length; i++) {
                bytesUint16[i] = string.charCodeAt(i);
            }
            return new Uint8Array(bytesUint16);
        },
        bytesToString: function (bytes) {
            return String.fromCharCode.apply(null, new Uint16Array(bytes));
        },
        bytesToHex: function (bytes) {
            var string = [];
            for (var i = 0; i < bytes.length; i++) {
                string.push("0x" + ("0" + (bytes[i].toString(16))).substr(-2).toUpperCase());
            }
            return string.join(" ");
        },
    };