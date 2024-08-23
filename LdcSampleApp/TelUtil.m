#import "TelUtil.h"

@implementation TelUtil

-(void)openTelScreen:(NSString *)telNumber
{
    NSURL *phoneCallURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"tel:", telNumber]];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    if([application canOpenURL:phoneCallURL])
    {
        [application openURL:phoneCallURL options:@{} completionHandler:nil];
    }
    else
    {
        
    }
    
}

+(NSString *)AES256Encode:(NSString *)target key:(NSString *)key
{
    int keySize = kCCKeySizeAES128;
    
//    NSString *key = @"secretKey1234567";
    
    NSData *data = [target dataUsingEncoding:NSUTF8StringEncoding];
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[keySize+1]; // room for terminator (unused) // oorspronkelijk 256
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = calloc(4, bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          //kCCOptionECBMode + kCCOptionPKCS7Padding,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          keySize, // oorspronkelijk 256
                                          nil, /* initialization vector (optional) */
                                          [data bytes],
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [Util createBASE64:[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted]];
    }
    
    free(buffer); //free the buffer;
    return nil;
    
    
    
    
    
    
    
    
    
    
    /*
    NSString *key = @"secretKey1234567";
    
    NSData *data = [target dataUsingEncoding:NSUTF8StringEncoding];
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = calloc(4, bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES128, NULL, [data bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
//    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, NULL, [data bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);

    if(cryptStatus == kCCSuccess)
    {
        NSLog(@"%@", [Util createBASE64:[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted]]);
        
        return [Util createBASE64:[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted]];
//        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted] encoding:NSMacOSRomanStringEncoding];
    }
    
    free(buffer);
    
    return nil;
     */
}

+(NSString *)AES256Decode:(NSString *)target key:(NSString *)key
{
    int keySize = kCCKeySizeAES128;
    
//    NSString *key = @"secretKey1234567";
    NSData *data = [self getBase64decode:target];
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[keySize+1]; // room for terminator (unused) // oorspronkelijk 256
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = calloc(4, bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
//                                          kCCOptionECBMode +kCCOptionPKCS7Padding,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, keySize, // oorspronkelijk 256
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted] encoding:NSUTF8StringEncoding];
    }
    
    free(buffer); //free the buffer;
    return nil;
    
    /*
    NSString *key = @"secretKey1234567";
    
//    NSData *data = [target dataUsingEncoding:NSMacOSRomanStringEncoding];
//    NSData *data = [self getBase64decode:target];
    NSData *data = target;
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t buffersize = dataLength + kCCBlockSizeAES128;
    void *buffer = calloc(4, buffersize);
    
    size_t numBytesDecrypted = 0;
    
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, NULL, [data bytes], dataLength, buffer, buffersize, &numBytesDecrypted);
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, NULL, [data bytes], dataLength, buffer, buffersize, &numBytesDecrypted);
    
    if(cryptStatus == kCCSuccess)
    {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted] encoding:NSUTF8StringEncoding];
    }
    
    free(buffer);
    
    return nil;
     */
}

+(NSData *)getBase64decode:(NSString *)encoding
{
    NSData *data = nil;
    unsigned char *decodedBytes = NULL;
    @try {
#define __ 255
        static char decodingTable[256] = {
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
            __,__,__,__, __,__,__,__, __,__,__,62, __,__,__,63,  // 0x20 - 0x2F
            52,53,54,55, 56,57,58,59, 60,61,__,__, __, 0,__,__,  // 0x30 - 0x3F
            __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x40 - 0x4F
            15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x50 - 0x5F
            __,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,  // 0x60 - 0x6F
            41,42,43,44, 45,46,47,48, 49,50,51,__, __,__,__,__,  // 0x70 - 0x7F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
        };
        encoding = [encoding stringByReplacingOccurrencesOfString:@"=" withString:@""];
        NSData *encodedData = [encoding dataUsingEncoding:NSASCIIStringEncoding];
        unsigned char *encodedBytes = (unsigned char *)[encodedData bytes];
        
        NSUInteger encodedLength = [encodedData length];
        if( encodedLength >= (NSUIntegerMax - 3) ) return nil; // NSUInteger overflow check
        NSUInteger encodedBlocks = (encodedLength+3) >> 2;
        //NSUInteger expectedDataLength = encodedBlocks * 3;
        
        unsigned char decodingBlock[4];
        
        decodedBytes = calloc(3, encodedBlocks);
        if( decodedBytes != NULL ) {
            
            NSUInteger i = 0;
            NSUInteger j = 0;
            NSUInteger k = 0;
            unsigned char c;
            while( i < encodedLength ) {
                c = decodingTable[encodedBytes[i]];
                i++;
                if( c != __ ) {
                    decodingBlock[j] = c;
                    j++;
                    if( j == 4 ) {
                        decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                        decodedBytes[k+1] = (decodingBlock[1] << 4) | (decodingBlock[2] >> 2);
                        decodedBytes[k+2] = (decodingBlock[2] << 6) | (decodingBlock[3]);
                        j = 0;
                        k += 3;
                    }
                }
            }
            
            // Process left over bytes, if any
            if( j == 3 ) {
                decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                decodedBytes[k+1] = (decodingBlock[1] << 4) | (decodingBlock[2] >> 2);
                k += 2;
            } else if( j == 2 ) {
                decodedBytes[k] = (decodingBlock[0] << 2) | (decodingBlock[1] >> 4);
                k += 1;
            }
            data = [[NSData alloc] initWithBytes:decodedBytes length:k];
        }
    }
    @catch (NSException *exception) {
        data = nil;
        NSLog(@"WARNING: error occured while decoding base 32 string: %@", exception);
    }
    @finally {
        if( decodedBytes != NULL ) {
            free( decodedBytes );
        }
    }
    return data;
}

@end
