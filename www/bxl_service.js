
var BXLService = function(){ };

BXLService.prototype.addEntry = function(successCallback, errorCallback, productName, ifType, bluetoothAddress){
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "addEntry", productName, ifType, bluetoothAddress]);
};
BXLService.prototype.open = function(successCallback,errorCallback,logicalDeviceName) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "open", logicalDeviceName ]);
};
BXLService.prototype.claim = function(successCallback,errorCallback, timeout) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "claim", timeout ]);
};
BXLService.prototype.setDeviceEnabled = function(successCallback,errorCallback, deviceEnabled) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "setDeviceEnabled",deviceEnabled ]);
};
BXLService.prototype.release = function(successCallback,errorCallback) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "release" ]);
};
BXLService.prototype.close = function(successCallback,errorCallback) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "close" ]);
};
BXLService.prototype.printNormal = function(successCallback,errorCallback, station, data) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "printNormal", station, data ]);
};
BXLService.prototype.printBitmapWithURL = function(successCallback,errorCallback, station, imageURL, width, alignment) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "printBitmapWithURL", station, imageURL,width, alignment ]);
};
BXLService.prototype.printBitmapWithBase64 = function(successCallback,errorCallback, station, base64Data, width, alignment) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "printBitmapWithBase64", station, base64Data,width, alignment ]);
};
BXLService.prototype.printBarCode = function(successCallback,errorCallback, station, data, symbology, height, width,alignment, textPosition) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "printBarCode", station, data,symbology, height, width, alignment,textPosition ]);
};
BXLService.prototype.pageModePrint = function(successCallback,errorCallback, control) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "pageModePrint", control ]);
};
BXLService.prototype.setPageModePrintArea = function(successCallback, errorCallback, area) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "setPageModePrintArea", area ]);
};
BXLService.prototype.setPageModePrintDirection = function(successCallback, errorCallback, direction) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "setPageModePrintDirection",direction ]);
};
BXLService.prototype.setPageModeHorizontalPosition = function(successCallback, errorCallback, position) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "setPageModeHorizontalPosition",position ]);
};
BXLService.prototype.setPageModeVerticalPosition = function(successCallback, errorCallback, position) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "setPageModeVerticalPosition",position ]);
};
BXLService.prototype.cutPaper = function(successCallback,errorCallback, percentage) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "cutPaper", percentage ]);
};
BXLService.prototype.markFeed = function(successCallback,errorCallback, type) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "markFeed", type ]);
};
BXLService.prototype.directIO = function(successCallback,errorCallback, data) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "directIO", data ]);
};
BXLService.prototype.transactionPrint = function(successCallback,errorCallback, station, control) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "transactionPrint", station, control ]);
};
BXLService.prototype.getPairedDevice = function(successCallback, errorCallback){
	cordova.exec(successCallback, errorCallback,"BXLService", "executePrinter", [ "getPairedDevice" ]);
};
BXLService.prototype.getNetworkDevice = function(successCallback, errorCallback, wireless, searchTime){
	cordova.exec(successCallback, errorCallback,"BXLService", "executePrinter", [ "getNetworkDevice", wireless, searchTime ]);
};
BXLService.prototype.getPrinterStatus = function(successCallback,errorCallback, level) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "getPrinterStatus" ]);
};
BXLService.prototype.setCharacterSet = function(successCallback,errorCallback, characterSet) {
	cordova.exec(successCallback, errorCallback, "BXLService","executePrinter", [ "setCharacterSet", characterSet ]);
};

BXLService.prototype.setOutputCompleteEvent = function(outputCallback) {
	cordova.exec(outputCallback, function(err){console.log(err);}, "BXLService","executePrinter", [ "outputCompleteEvent" ]);
};

module.exports = new BXLService();


