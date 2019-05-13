    cordova.commandProxy.add("BXLService", {
        executePrinter: function(successCallback, errorCallback, args) {
            this._bxlWinCompLibAPIs = this._bxlWinCompLibAPIs || new BxlCordovaWinAPIs();
            // Get a method name, and shift 
            switch(args.shift().trim())
            {
                case "addEntry":                        _bxlWinCompLibAPIs.addEntry(successCallback, errorCallback, args);                       break;
                case "open":                            _bxlWinCompLibAPIs.open(successCallback, errorCallback, args);                           break;
                case "claim":                           _bxlWinCompLibAPIs.claim(successCallback, errorCallback, args);                          break;
                case "close":                           _bxlWinCompLibAPIs.close(successCallback, errorCallback);                                break;
                case "release":                         _bxlWinCompLibAPIs.release(successCallback, errorCallback);                              break;
                case "setDeviceEnabled":                _bxlWinCompLibAPIs.setDeviceEnable(successCallback, errorCallback, args);                break;
                case "getDeviceEnabled":                _bxlWinCompLibAPIs.getDeviceEnable(successCallback, errorCallback);                      break;
                case "printNormal":                     _bxlWinCompLibAPIs.printNormal(successCallback, errorCallback, args);                    break;
                case "printBarCode":                    _bxlWinCompLibAPIs.printBarCode(successCallback, errorCallback, args);                   break;
                case "printBitmapWithBase64":           _bxlWinCompLibAPIs.printBitmapWithBase64(successCallback, errorCallback, args);          break;
                case "printBitmapWithURL":              _bxlWinCompLibAPIs.printBitmapWithURL(successCallback, errorCallback, args);             break;
                case "checkHealth":                     _bxlWinCompLibAPIs.checkHealth(successCallback, errorCallback, args);                    break;
                case "pageModePrint":                   _bxlWinCompLibAPIs.pageModePrint(successCallback, errorCallback, args);                  break;
                case "setPageModePrintArea":            _bxlWinCompLibAPIs.setPageModePrintArea(successCallback, errorCallback, args);           break;
                case "setPageModePrintDirection":       _bxlWinCompLibAPIs.setPageModePrintDirection(successCallback, errorCallback, args);      break;
                case "setPageModeVerticalPosition":     _bxlWinCompLibAPIs.setPageModeVerticalPosition(successCallback, errorCallback, args);    break;
                case "setPageModeHorizontalPosition":   _bxlWinCompLibAPIs.setPageModeHorizontalPosition(successCallback, errorCallback, args);  break;

                case "directIO":                        _bxlWinCompLibAPIs.directIO(successCallback, errorCallback, args);                       break;
                case "cutPaper":                        _bxlWinCompLibAPIs.cutPaper(successCallback, errorCallback, args);                       break;
                case "markFeed":                        _bxlWinCompLibAPIs.markFeed(successCallback, errorCallback, args);                       break;
                case "transactionPrint":                _bxlWinCompLibAPIs.transactionPrint(successCallback, errorCallback, args);               break;

                case "getPrinterStatus":                _bxlWinCompLibAPIs.getPrinterStatus(successCallback, errorCallback, args);               break;
                case "getPairedDevice":                 _bxlWinCompLibAPIs.getPairedDevice(successCallback, errorCallback, args);                break;
                case "getNetworkDevice":                _bxlWinCompLibAPIs.getNetworkDevice(successCallback, errorCallback, args);               break;
                case "setCharacterSet":                 _bxlWinCompLibAPIs.setCharacterSet(successCallback, errorCallback, args);                break;
                default:                                errorCallback("not supported method.");                                                  break;
            }
        }
    });

    function BxlCordovaWinAPIs() { 
        var nativeAPIs = new WinRT.BxlComponent.BxlPrinterAPIs();
        var addEntry = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.addEntry");
            nativeAPIs.addEntry(args[0], args[1], args[2]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(result);
                }
            );
        };
    
        var open = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.open");
            if(nativeAPIs.open(args[0]) == 0){
                successCallback();
            }else{
                errorCallback();
            }
        };
        var claim = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.claim");
            nativeAPIs.claim(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                },
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var release = function (successCallback, errorCallback) {
            console.log("BxlCordovaWinAPIs.release");
            nativeAPIs.release().then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var close = function (successCallback, errorCallback) {
            console.log("BxlCordovaWinAPIs.close");
            nativeAPIs.close().then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var directIO = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.directIO");
            nativeAPIs.directIO(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var setDeviceEnable = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.setDeviceEnable");
            nativeAPIs.setDeviceEnable(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var getDeviceEnable = function (successCallback, errorCallback) {
            console.log("BxlCordovaWinAPIs.getDeviceEnable");
            nativeAPIs.getDeviceEnable().then(
                function (result) {
                    successCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var printNormal = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.printNormal");
            nativeAPIs.printNormal(args[1]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var printBitmapWithBase64 = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.printBitmapWithBase64");
            nativeAPIs.printBitmapWithBase64(args[1], args[2], args[3]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var printBitmapWithURL = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.printBitmapWithURL");
            nativeAPIs.printBitmapWithURL(args[1], args[2], args[3]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var printBarCode = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.printBarCode");
            nativeAPIs.printBarCode(args[1], args[2], args[3], args[4], args[5], args[6]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var getPairedDevice = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.getPairedDevice");
            nativeAPIs.getPairedDevice().then(
                function (result) {
                    result.length > 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var getNetworkDevice = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.getNetworkDevice");
            nativeAPIs.getNetworkDevice(args[0], args[1]).then(
                function (result) {
                    console.log("BxlCordovaWinAPIs.getNetworkDevice : " + result);
                    result.length > 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var checkHealth = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.checkHealth");
            nativeAPIs.checkHealth(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var pageModePrint = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.pageModePrint");
            nativeAPIs.pageModePrint(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var setPageModePrintArea = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.setPageModePrintArea");
            nativeAPIs.setPageModePrintArea(args[0][0],args[0][1],args[0][2],args[0][3]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var setPageModePrintDirection = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.setPageModePrintDirection");
            nativeAPIs.setPageModePrintDirection(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var setPageModeVerticalPosition = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.setPageModeVerticalPosition");
            nativeAPIs.setPageModeVerticalPosition(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };
        var setPageModeHorizontalPosition = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.setPageModeHorizontalPosition");
            nativeAPIs.setPageModeHorizontalPosition(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };

        var transactionPrint = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.transactionPrint");
            nativeAPIs.transactionPrint(args[1]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };

        var setCharacterSet = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.setCharacterSet");
            if(nativeAPIs.setCharacterSet(args[0]) == 0){
                successCallback();
            }else{
                errorCallback();
            }
        };

        var markFeed = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.markFeed");
            nativeAPIs.markFeed().then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };

        var cutPaper = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.cutPaper");
            nativeAPIs.cutPaper(args[0]).then(
                function (result) {
                    result === 0 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };

        var getPrinterStatus = function (successCallback, errorCallback, args) {
            console.log("BxlCordovaWinAPIs.getPrinterStatus");
            nativeAPIs.getPrinterStatus(args[0]).then(
                function (result) {
                    // Cover open or paper empty is detected, reset OFFLINE bit.
                    if(result & 1 || result & 2){
                        result &= ~32;
                    }
                    result <= 256 ? successCallback(result) : errorCallback(result);
                }, 
                function (error) {
                    errorCallback(error);
                }
            );
        };

        return {
            // CONNECTION APIs
            addEntry: addEntry, 
            open: open, 
            claim: claim, 
            release: release,
            close: close, 
            // PRINT APIs
            printNormal: printNormal, 
            printBarCode: printBarCode,
            printBitmapWithBase64: printBitmapWithBase64,
            printBitmapWithURL: printBitmapWithURL,            
            // PAGE MODE APIs
            pageModePrint: pageModePrint,
            setPageModePrintArea: setPageModePrintArea,
            setPageModePrintDirection: setPageModePrintDirection,
            setPageModeVerticalPosition: setPageModeVerticalPosition,
            setPageModeHorizontalPosition: setPageModeHorizontalPosition,
            // OTHERS
            setDeviceEnable: setDeviceEnable,
            getDeviceEnable: getDeviceEnable,
            getPairedDevice: getPairedDevice,
            checkHealth: checkHealth, 
            directIO : directIO, 
            cutPaper : cutPaper, 
            markFeed : markFeed, 
            transactionPrint : transactionPrint, 
            setCharacterSet : setCharacterSet, 
            getPrinterStatus : getPrinterStatus,
            getNetworkDevice : getNetworkDevice
        }
    }