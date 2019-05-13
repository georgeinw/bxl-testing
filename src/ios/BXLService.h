
#define METHOD_ADD_ENTRY                    @"addEntry"
#define METHOD_OPEN                         @"open"
#define METHOD_CLOSE                        @"close"
#define METHOD_CLAIM                        @"claim"
#define METHOD_RELEASE                      @"release"
#define METHOD_CHECK_HEALTH                 @"checkHealth"
#define METHOD_CUT_PAPER                    @"cutPaper"
#define METHOD_MARK_FFED                    @"markFeed"
#define METHOD_PAGE_MODE_PRINT              @"pageModePrint"
#define METHOD_PRINT_BAR_CODE               @"printBarCode"
#define METHOD_PRINT_BITMAP                 @"printBitmap"
#define METHOD_PRINT_BITMAP_WITH_BASE64     @"printBitmapWithBase64"
#define METHOD_PRINT_BITMAP_WITH_URL        @"printBitmapWithURL"
#define METHOD_PRINT_IMMEDIATE              @"printImmediate"
#define METHOD_PRINT_NORMAL                 @"printNormal"
#define METHOD_TRANSACTION_PRINT            @"transactionPrint"
#define METHOD_GET_CLAIMED                  @"getClaimed"
#define METHOD_GET_DEVICE_ENABLED           @"getDeviceEnabled"
#define METHOD_SET_DEVICE_ENABLED           @"setDeviceEnabled"
#define METHOD_GET_FREEZE_EVENTS            @"getFreezeEvents"
#define METHOD_SET_FREEZE_EVENTS            @"setFreezeEvents"
#define METHOD_GET_STATE                    @"getState"
#define METHOD_GET_DEVICE_SERVICE_DESCRIPTION       @"getDeviceServiceDescription"
#define METHOD_GET_DEVICE_SERVICE_VERSION           @"getDeviceServiceVersion"
#define METHOD_GET_PHYSICAL_DEVICE_DESCRIPTION      @"getPhysicalDeviceDescription"
#define METHOD_GET_PHYSICAL_DEVICE_NAME     @"getPhysicalDeviceName"
#define METHOD_GET_CAP_CHARACTER_SET        @"getCapCharacterSet"
#define METHOD_GET_CAP_COVER_SENSOR         @"getCapCoverSensor"
#define METHOD_GET_CAP_REC_BAR_CODE         @"getCapRecBarCode"
#define METHOD_GET_CAP_REC_BITMAP           @"getCapRecBitmap"
#define METHOD_GET_CAP_REC_BOLD             @"getCapRecBold"
#define METHOD_GET_CAP_REC_DHIGH            @"getCapRecDhigh"
#define METHOD_GET_CAP_REC_DWIDE            @"getCapRecDwide"
#define METHOD_GET_CAP_REC_DWIDE_DHIGH      @"getCapRecDwideDhigh"
#define METHOD_GET_CAP_REC_EMPTY_SENSOR     @"getCapRecEmptySensor"
#define METHOD_GET_CAP_REC_ITALIC           @"getCapRecItalic"
#define METHOD_GET_CAP_REC_NEAR_END_SENSOR  @"getCapRecNearEndSensor"
#define METHOD_GET_CAP_REC_PAPERCUT         @"getCapRecPapercut"
#define METHOD_GET_CAP_REC_PRESENT          @"getCapRecPresent"
#define METHOD_GET_CAP_REC_UNDERLINE        @"getCapRecUnderline"
#define METHOD_GET_CAP_TRANSACTION          @"getCapTransaction"
#define METHOD_GET_ASYNC_MODE               @"getAsyncMode"
#define METHOD_SET_ASYNC_MODE               @"setAsyncMode"
#define METHOD_GET_CHARACTER_SET            @"getCharacterSet"
#define METHOD_SET_CHARACTER_SET            @"setCharacterSet"
#define METHOD_GET_CHARACTER_SET_LIST       @"getCharacterSetList"
#define METHOD_GET_COVER_OPEN               @"getCoverOpen"
#define METHOD_GET_ERROR_LEVEL              @"getErrorLevel"
#define METHOD_GET_ERROR_STATION            @"getErrorStation"
#define METHOD_GET_ERROR_STRING             @"getErrorString"
#define METHOD_GET_FLAG_WHEN_IDLE           @"getFlagWhenIdle"
#define METHOD_SET_FLAG_WHEN_IDLE           @"setFlagWhenIdle"
#define METHOD_GET_MAP_MODE                 @"getMapMode"
#define METHOD_SET_MAP_MODE                 @"setMapMode"
#define METHOD_GET_OUTPUT_ID                @"getOutputID"
#define METHOD_GET_REC_EMPTY                @"getRecEmpty"
#define METHOD_GET_REC_NEAR_END             @"getRecNearEnd"
#define METHOD_GET_CAP_POWER_REPORTING      @"getCapPowerReporting"
#define METHOD_GET_POWER_NOTIFY             @"getPowerNotify"
#define METHOD_SET_POWER_NOTIFY             @"setPowerNotify"
#define METHOD_GET_POWER_STATE              @"getPowerState"
#define METHOD_GET_CAP_REC_MARK_FEED        @"getCapRecMarkFeed"
#define METHOD_GET_CAP_MAP_CHARACTER_SET    @"getCapMapCharacterSet"
#define METHOD_GET_MAP_CHARACTER_SET        @"getMapCharacterSet"
#define METHOD_SET_MAP_CHARACTER_SET        @"setMapCharacterSet"
#define METHOD_GET_CAP_REC_PAGE_MODE        @"getCapRecPageMode"
#define METHOD_GET_PAGE_MODE_AREA           @"getPageModeArea"
#define METHOD_GET_PAGE_MODE_DESCRIPTOR     @"getPageModeDescriptor"
#define METHOD_GET_PAGE_MODE_HORIZONTAL_POSITION     @"getPageModeHorizontalPosition"
#define METHOD_SET_PAGE_MODE_HORIZONTAL_POSITION     @"setPageModeHorizontalPosition"
#define METHOD_GET_PAGE_MODE_PRINT_AREA     @"getPageModePrintArea"
#define METHOD_SET_PAGE_MODE_PRINT_AREA     @"setPageModePrintArea"
#define METHOD_GET_PAGE_MODE_PRINT_DIRECTION     @"getPageModePrintDirection"
#define METHOD_SET_PAGE_MODE_PRINT_DIRECTION     @"setPageModePrintDirection"
#define METHOD_GET_PAGE_MODE_STATION        @"getPageModeStation"
#define METHOD_SET_PAGE_MODE_STATION        @"setPageModeStation"
#define METHOD_GET_PAGE_MODE_VERTICAL_POSITION     @"getPageModeVerticalPosition"
#define METHOD_SET_PAGE_MODE_VERTICAL_POSITION     @"setPageModeVerticalPosition"
#define METHOD_CLEAR_PRINT_AREA             @"clearPrintArea"
#define METHOD_GET_PAIRED_DEVICE            @"getPairedDevice"
#define METHOD_GET_PRINTER_STATUS           @"getPrinterStatus"
#define METHOD_DIRECT_IO                    @"directIO"
#define METHOD_GET_NETWORK_DEVICE           @"getNetworkDevice"

typedef enum : int {
    BXL_INF_BLUETOOTH = 0,
    BXL_INF_ETHERNET = 1,
    BXL_INF_WIFI = 3
}BxlPrinterInterface;


#import <Cordova/CDV.h>
#import "UPOSPrinterController.h"
//#import <frmBixolonUPOS/UPOSPrinterController.h>

@interface BXLService : CDVPlugin<UPOSDeviceControlDelegate>
{
    UPOSPrinterController* posPrinter;
}

-(BOOL) executePrinter:(CDVInvokedUrlCommand *)command;
-(BOOL) addEntry:(CDVInvokedUrlCommand *)command;
-(BOOL) open:(CDVInvokedUrlCommand *)command;
-(BOOL) claim:(CDVInvokedUrlCommand *)command;
-(BOOL) setDeviceEnabled:(CDVInvokedUrlCommand *)command;
-(BOOL) release:(CDVInvokedUrlCommand *)command;
-(BOOL) close:(CDVInvokedUrlCommand *)command;
-(BOOL) printNormal:(CDVInvokedUrlCommand *)command;
-(BOOL) printBitmap:(CDVInvokedUrlCommand *)command;
-(BOOL) printBitmapWithURL:(CDVInvokedUrlCommand *)command;
-(BOOL) printBitmapWithBase64:(CDVInvokedUrlCommand *)command;
-(BOOL) printBarcode:(CDVInvokedUrlCommand *)command;
-(BOOL) getPairedDevice:(CDVInvokedUrlCommand *)command;
-(BOOL) getNetworkDevice:(CDVInvokedUrlCommand *)command;
-(BOOL) getPrinterStatus:(CDVInvokedUrlCommand *)command;
-(BOOL) pageModePrint:(CDVInvokedUrlCommand *)command;
-(BOOL) setPageModePrintArea:(CDVInvokedUrlCommand *)command;
-(BOOL) setPageModePrintDirection:(CDVInvokedUrlCommand *)command;
-(BOOL) setPageModeHorizontalPosition:(CDVInvokedUrlCommand *)command;
-(BOOL) setPageModeVerticalPosition:(CDVInvokedUrlCommand *)command;
-(BOOL) setCharacterSet:(CDVInvokedUrlCommand *)command;
-(BOOL) directIO:(CDVInvokedUrlCommand *)command;
-(BOOL) cutPaper:(CDVInvokedUrlCommand *)command;
-(BOOL) markFeed:(CDVInvokedUrlCommand *)command;
-(BOOL) transactionPrint:(CDVInvokedUrlCommand *)command;
-(BOOL) checkHealth:(CDVInvokedUrlCommand *)command;

@end


