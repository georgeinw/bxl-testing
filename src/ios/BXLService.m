
#import "BXLService.h"

@implementation BXLService
{
    NSInteger currentStatus;
}

-(BOOL) createInstance
{
    if(posPrinter != nil)
        return YES;
    posPrinter = [[UPOSPrinterController alloc] init];
    if(!posPrinter)
        return nil;
    // Set delegate
    posPrinter.delegate = self;
    return YES;
}
-(BOOL) isPrnObjectNil:(CDVInvokedUrlCommand *)command
{
    if (posPrinter == nil) {
        NSLog(@"isPrnObjectNil: instance not created yet");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"instance not created"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return YES;
    }
    return NO;
}

-(BOOL) addEntry:(CDVInvokedUrlCommand *)command
{
    [self createInstance];
    if([self isPrnObjectNil:command]){
        return NO;
    }
    
    // Check the numer of count of the arguments
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 4){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    // Check that model name is valid or not
    UPOSPrinter* device = [[UPOSPrinter alloc] init];
    
    NSString* modelName = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:1 /*DeviceName*/]];
    modelName = [modelName stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [modelName length])];
    device.modelName = [NSString stringWithString:modelName];
    
    if([device.modelName isEqualToString:@""] || device.modelName == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"device name not allowed"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    // Check that communication interface is supported or not
    NSInteger ifType = [[command.arguments objectAtIndex:2 /* communication interface */] integerValue];
    switch (ifType) {
        case 0:
            ifType = _INTERFACETYPE_BLUETOOTH;
            break;
        case 1:
            ifType = _INTERFACETYPE_ETHERNET;
            device.port = @"9100";
            break;
        case 3:
            ifType = _INTERFACETYPE_WIFI;
            device.port = @"9100";
            break;
        default:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not supported interface"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return NO;
    }
    
    // Connection Information Setting
    device.interfaceType = [NSNumber numberWithInteger:ifType];
    if(ifType == _INTERFACETYPE_ETHERNET || ifType == _INTERFACETYPE_WIFI){
        NSArray* addressWithPortNumber = [[command.arguments objectAtIndex:3] componentsSeparatedByString:@":"];
        if(addressWithPortNumber != nil && [addressWithPortNumber count] >= 2){
            device.address = [addressWithPortNumber objectAtIndex:0];   // IP Address
            device.port = [addressWithPortNumber objectAtIndex:1];      // Port Number
            NSLog(@"addEntry: IP address = %@, Port Number = %@", device.address, device.port);
        }else{
            device.address = [addressWithPortNumber objectAtIndex:0];   // IP Address
            device.port =  @"9100"; // Port Number
            NSLog(@"addEntry: IP address = %@, Port Number = %@ (default)", device.address, device.port);
        }
    }else{
        device.serialNumber = [command.arguments objectAtIndex:3/*Bluetooth Serial Number*/];
        NSLog(@"addEntry: Serial Number = %@", device.serialNumber);
    }
    
    // Removes all the devices already registered
    UPOSPrinters* deviceList = (UPOSPrinters*)[posPrinter getRegisteredDevice];
    NSArray* list = [deviceList getList];
    if(list != nil){
        for(UPOSPrinter* printer in list){
            //if([printer.modelName caseInsensitiveCompare:device.modelName] == NSOrderedSame)
                [deviceList removeDevice:printer];
        }
    }
    
    // Register the device
    if(deviceList != nil){
        [deviceList removeDevice:device];
        [deviceList addDevice:device];
        [deviceList save];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return YES;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"failed to register the device info"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return NO;
}
-(BOOL) open:(CDVInvokedUrlCommand *)command
{
    [self createInstance];
    if([self isPrnObjectNil:command]){
        return NO;
    }
    
    // Check the numer of count of the arguments
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 2){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    NSLog(@"posPrinter open");
    //NSInteger result = [posPrinter open:[command.arguments objectAtIndex:1]];
    NSInteger result = [posPrinter connect:[command.arguments objectAtIndex:1]];
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    NSLog(@"posPrinter open : OK");
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) claim:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    
    NSLog(@"posPrinter claim");
    CDVPluginResult* pluginResult = nil;
    NSInteger result = [posPrinter claim:[[command.arguments objectAtIndex:1/* device name */] integerValue]];
    if(result != UPOS_SUCCESS){
        [posPrinter releaseDevice];
        [posPrinter close];
        posPrinter = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"claim error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) setDeviceEnabled:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    NSLog(@"posPrinter setDeviceEnabled");
    [posPrinter setDeviceEnabled:[[command.arguments objectAtIndex:1] boolValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) release:(CDVInvokedUrlCommand *)command
{
    NSLog(@"posPrinter releaseDevice");
    if([self isPrnObjectNil:command]){
        return NO;
    }
    [posPrinter setDeviceEnabled:NO];
    [posPrinter releaseDevice];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) close:(CDVInvokedUrlCommand *)command
{
    NSLog(@"posPrinter close");
    if([self isPrnObjectNil:command]){
        return NO;
    }
    [posPrinter close];
    posPrinter = nil;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) printNormal:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 3){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSLog(@"posPrinter printNormal");
    NSInteger result = [posPrinter printNormal:[[command.arguments objectAtIndex:1]  integerValue] data: [command.arguments objectAtIndex:2]];
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) printBitmapWithURL:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not supported method"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return NO;
}
-(BOOL) printBitmap:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 5){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSInteger result = [posPrinter printBitmap:[[command.arguments objectAtIndex:1]integerValue]
                                      fileName:[command.arguments objectAtIndex:2]
                                         width:[[command.arguments objectAtIndex:3] integerValue]
                                     alignment:[[command.arguments objectAtIndex:4] integerValue]];
    
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) printBitmapWithBase64:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 5){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSString* strImgData = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:2]];
    UIImage* image = [self decodeBase64ToImage:strImgData];
    NSInteger result = [posPrinter printBitmap:[[command.arguments objectAtIndex:1]integerValue]
                                         image:[UIImage imageWithCGImage:image.CGImage]
                                         width:[[command.arguments objectAtIndex:3] integerValue]
                                     alignment:[[command.arguments objectAtIndex:4] integerValue]];
    
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
    
}
-(BOOL) printBarcode:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 8){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSInteger result = [posPrinter printBarcode:[[command.arguments objectAtIndex:1] integerValue]
                                           data: [command.arguments objectAtIndex:2]
                                      symbology:[[command.arguments objectAtIndex:3] integerValue]
                                         height:[[command.arguments objectAtIndex:4] integerValue]
                                          width:[[command.arguments objectAtIndex:5] integerValue]
                                      alignment:[[command.arguments objectAtIndex:6] integerValue]
                                    textPostion:[[command.arguments objectAtIndex:7] integerValue]];
    
    
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) getPairedDevice:(CDVInvokedUrlCommand *)command
{
    NSLog(@"getPairedDevice");
    [self createInstance];
    if([self isPrnObjectNil:command]){
        return NO;
    }
    [self lookupDevice:command interface:BXL_INF_BLUETOOTH];
    return YES;
}
-(BOOL) getNetworkDevice:(CDVInvokedUrlCommand *)command
{
    NSLog(@"getNetworkDevice");
    [self createInstance];
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    bool wireless = [[command.arguments objectAtIndex:1/*wireless or wired*/] boolValue];
    [self lookupDevice:command interface: wireless ? BXL_INF_WIFI : BXL_INF_ETHERNET];
    return YES;
}
-(BOOL) getPrinterStatus:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = nil;
    
    if(!posPrinter.DeviceEnabled){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    if(currentStatus & 1){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:1];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return YES;
    }
    else if (currentStatus & 2){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:2];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return YES;
    }
    else if (currentStatus & 4){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:4];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return YES;
    }
    else if (currentStatus & 32){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:8];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return YES;
        
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:currentStatus];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return YES;
    }
}
-(BOOL) pageModePrint:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    if([[command.arguments objectAtIndex:1] integerValue] == 0){
        [posPrinter printDataInPageMode];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) setPageModePrintArea:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 2){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSArray* array = [command.arguments objectAtIndex: 1];
    int area[] = { 0, 0, 0, 0};
    for( int i = 0; i < array.count; i++){
        NSNumber* number = [array objectAtIndex:i];
        int byte = (int)number.integerValue;
        area[i] = byte;
        if(i > (sizeof(area)/sizeof(area[0])))
            break;
    }
    
    if(array.count < 4){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    [posPrinter setPageArea:area[0] startingY:area[1] width:area[2] height:area[3]];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) setPageModePrintDirection:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter setPageModeDirection:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) setPageModeHorizontalPosition:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter setLeftPosition:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) setPageModeVerticalPosition:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter setVerticalPosition:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) setCharacterSet:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter setCharacterSet:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) directIO:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 2){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSArray* array = [command.arguments objectAtIndex:1];
    NSMutableData* writeBytes = [NSMutableData data];
    for( int i=0; i<array.count; i++){
        NSNumber* number = [array objectAtIndex:i];
        unsigned char byte = number.integerValue;
        [writeBytes appendBytes:&byte length:1];
    }
    NSInteger result = [posPrinter directIO:0 data:(void*)writeBytes object:nil];
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
    
}
-(BOOL) cutPaper:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter cutPaper:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) markFeed:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter markFeed:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) checkHealth:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    if([command.arguments count] < 2){
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return NO;
    }
    [posPrinter checkHealth:[[command.arguments objectAtIndex:1] integerValue]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}
-(BOOL) transactionPrint:(CDVInvokedUrlCommand *)command
{
    if([self isPrnObjectNil:command]){
        return NO;
    }
    CDVPluginResult* pluginResult = nil;
    if([command.arguments count] < 3){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"argument count error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    
    NSInteger result = [posPrinter transactionPrint:[[command.arguments objectAtIndex:1] integerValue]
                                            control:[[command.arguments objectAtIndex:2] integerValue]];
    if(result != UPOS_SUCCESS){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsNSInteger:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return YES;
}

-(void) callback:(NSString*) callbackID isSuccess:(BOOL)isSuccess
{
    CDVPluginResult *pluginResult = [ CDVPluginResult resultWithStatus:(isSuccess?CDVCommandStatus_OK:CDVCommandStatus_ERROR)];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}
-(void) callback:(NSString*) callbackID isSuccess:(BOOL)isSuccess WithMessageInt:(NSInteger)value
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:(isSuccess?CDVCommandStatus_OK:CDVCommandStatus_ERROR)messageAsInt:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

-(void) callback:(NSString*) callbackID isSuccess:(BOOL)isSuccess WithMessageString:(NSString*)value
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:(isSuccess?CDVCommandStatus_OK:CDVCommandStatus_ERROR)messageAsString:value];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

-(BOOL) lookupDevice:(CDVInvokedUrlCommand *)command interface:(BxlPrinterInterface) prnInterface
{
    NSLog(@"lookupDevice : prnInterface= %d", prnInterface);
    //UPOSPrinterController* prtTemp = [[UPOSPrinterController alloc] init];
    NSMutableArray* printerList = [[NSMutableArray alloc] init];
    NSString* loookupStartMsg    = __NOTIFICATION_NAME_BT_FOUND_PRINTER_;
    NSString* loookupCompleteMsg = __NOTIFICATION_NAME_BT_LOOKUP_COMPLETE_;
    
    switch(prnInterface)
    {
        case BXL_INF_BLUETOOTH:
            loookupStartMsg    = __NOTIFICATION_NAME_BT_FOUND_PRINTER_;
            loookupCompleteMsg = __NOTIFICATION_NAME_BT_LOOKUP_COMPLETE_;
            break;
        case BXL_INF_ETHERNET:
            loookupStartMsg    = __NOTIFICATION_NAME_ETHERNET_FOUND_PRINTER_;
            loookupCompleteMsg = __NOTIFICATION_NAME_ETHERNET_LOOKUP_COMPLETE_;
            break;
        case BXL_INF_WIFI:
            loookupStartMsg    = __NOTIFICATION_NAME_WIFI_FOUND_PRINTER_;
            loookupCompleteMsg = __NOTIFICATION_NAME_WIFI_LOOKUP_COMPLETE_;
            break;
        default:
            return NO;
    }
    
    __block id obsFound = [[NSNotificationCenter defaultCenter] addObserverForName:loookupStartMsg
                                                                            object:nil
                                                                             queue:nil
                                                                        usingBlock:^(NSNotification *notification) {
                                                                            UPOSPrinter* lookupDevice = (UPOSPrinter*)[[notification userInfo] objectForKey:loookupStartMsg];
                                                                            NSDictionary* dic = nil;
                                                                            if(prnInterface == BXL_INF_BLUETOOTH){
                                                                                dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", lookupDevice.modelName], @"modelName", [NSString stringWithFormat:@"%@", lookupDevice.serialNumber], @"address", nil];
                                                                            }else{
                                                                                dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", lookupDevice.address], @"address", [NSString stringWithFormat:@"%@", lookupDevice.port], @"portNumber", nil];
                                                                            }
                                                                            [printerList addObject:dic];
                                                                        }];
    
    __block id obsFinish = [[NSNotificationCenter defaultCenter] addObserverForName:loookupCompleteMsg
                                                                             object:nil
                                                                              queue:nil
                                                                         usingBlock:^(NSNotification *notification) {
                                                                             NSMutableString *jsonString = [NSMutableString string];
                                                                             for(NSDictionary *p in printerList){
                                                                                 if(jsonString.length>3)
                                                                                     [jsonString appendString:@","];
                                                                                 NSError *writeError = nil;
                                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:p options:NSJSONWritingPrettyPrinted error:&writeError];
                                                                                 [jsonString appendString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                                                                             }
                                                                             [[NSNotificationCenter defaultCenter] removeObserver:obsFound];
                                                                             [[NSNotificationCenter defaultCenter] removeObserver:obsFinish];
                                                                             [self callback:command.callbackId isSuccess:YES WithMessageString:jsonString];
                                                                         }];
    
    switch(prnInterface)
    {
        case BXL_INF_BLUETOOTH: [posPrinter refreshBTLookup]; break;
        case BXL_INF_ETHERNET: [posPrinter refreshEthernetLookup]; break;
        case BXL_INF_WIFI: [posPrinter refreshWifiLookup]; break;
    }
    
    return true;
}
-(BOOL) executePrinter:(CDVInvokedUrlCommand *)command
{
    NSString* action = [command.arguments objectAtIndex:0 /*Method Name*/];
    NSLog(@"executePrinter: action name = %@, argument count = %ld", action, [command.arguments count]);
    for (int index = 0; index < [command.arguments count]; index++){
        NSLog(@"executePrinter: argument[%d] = %@", index, [command.arguments objectAtIndex:index]);
    }
    
    @try {
        //[self.commandDelegate runInBackground:^{
        if([action isEqualToString:METHOD_GET_PAIRED_DEVICE])
            [self getPairedDevice:command];
        else if([action isEqualToString:METHOD_GET_NETWORK_DEVICE])
            [self getNetworkDevice:command];
        else if([action isEqualToString:METHOD_OPEN])
            [self open:command];
        else if([action isEqualToString:METHOD_ADD_ENTRY])
            [self addEntry:command];
        else if([action isEqualToString:METHOD_SET_DEVICE_ENABLED])
            [self setDeviceEnabled:command];
        else if([action isEqualToString:METHOD_RELEASE])
            [self release:command];
        else if([action isEqualToString:METHOD_CLAIM])
            [self claim:command];
        else if([action isEqualToString:METHOD_SET_CHARACTER_SET])
            [self setCharacterSet:command];
        else if([action isEqualToString:METHOD_PAGE_MODE_PRINT])
            [self pageModePrint:command];
        else if([action isEqualToString:METHOD_SET_PAGE_MODE_PRINT_AREA])
            [self setPageModePrintArea:command];
        else if([action isEqualToString:METHOD_SET_PAGE_MODE_PRINT_DIRECTION])
            [self setPageModePrintDirection:command];
        else if([action isEqualToString:METHOD_SET_PAGE_MODE_HORIZONTAL_POSITION])
            [self setPageModeHorizontalPosition:command];
        else if([action isEqualToString:METHOD_SET_PAGE_MODE_VERTICAL_POSITION])
            [self setPageModeVerticalPosition:command];
        else if([action isEqualToString:METHOD_CHECK_HEALTH])
            [self checkHealth:command];
        else if([action isEqualToString:METHOD_PRINT_NORMAL])
            [self printNormal:command];
        else if([action isEqualToString:METHOD_PRINT_BAR_CODE])
            [self printBarcode:command];
        else if([action isEqualToString:METHOD_PRINT_BITMAP])
            [self printBitmap:command];
        else if([action isEqualToString:METHOD_PRINT_BITMAP_WITH_URL])
            [self printBitmapWithURL:command];
        else if([action isEqualToString:METHOD_PRINT_BITMAP_WITH_BASE64])
            [self printBitmapWithBase64:command];
        else if([action isEqualToString:METHOD_CUT_PAPER])
            [self cutPaper:command];
        else if([action isEqualToString:METHOD_TRANSACTION_PRINT])
            [self transactionPrint:command];
        else if([action isEqualToString:METHOD_DIRECT_IO])
            [self directIO:command];
        else if([action isEqualToString:METHOD_GET_PRINTER_STATUS])
            [self getPrinterStatus:command];
        else{
            NSLog(@"executePrinter: (%@) is not supported", action);
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not supported method"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        //}];
    }
    @catch (NSException* e) {
        NSLog(@"executePrinter: NSException e = %@", e.name);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"exception occured"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return NO;
    }
    return YES;
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

#pragma mark - UPOSDeviceControlDelegate Protocol implement
-(void)StatusUpdateEvent:(NSNumber*) Status
{
    //    currentStatus  = 0;
    if([Status integerValue] == PTR_SUE_COVER_OPEN){
        currentStatus = (currentStatus | 1);
    }
    if([Status integerValue] == PTR_SUE_COVER_OK){
        currentStatus = (currentStatus & ~1);
    }
    if([Status integerValue] == PTR_SUE_REC_EMPTY){
        currentStatus = (currentStatus | 2);
    }
    if([Status integerValue] == PTR_SUE_REC_PAPEROK){
        currentStatus = (currentStatus & ~2);
        currentStatus = (currentStatus & ~4);
    }
    if([Status integerValue] == PTR_SUE_REC_NEAREMPTY){
        currentStatus = (currentStatus | 4);
    }
    if([Status integerValue] == UPOS_SUE_POWER_OFF ||
       [Status integerValue] == UPOS_SUE_POWER_OFF_OFFLINE ||
       [Status integerValue] == UPOS_SUE_POWER_OFFLINE) {
        currentStatus = (currentStatus | 32);
    }
    if([Status integerValue] == UPOS_SUE_POWER_ONLINE){
        currentStatus = (currentStatus & ~32);
    }
    if([Status integerValue] == PTR_SUE_REC_BATTERY_NORMAL){
        //        currentStatus = 0;
    }
    if([Status integerValue] == PTR_SUE_REC_BATTERY_LOW){
        //        currentStatus = 0;
    }
}

@end
