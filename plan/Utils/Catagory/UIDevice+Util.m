//
//  UIDevice+Util.m
//  plan
//
//  Created by Fengzy on 15/9/3.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//


#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "UIDevice+Util.h"


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@interface NSDictionary(subscripts)

- (id)objectForKeyedSubscript:(id)key;

@end

@interface NSMutableDictionary(subscripts)

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end

@interface NSArray(subscripts)

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface NSMutableArray(subscripts)

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end

@implementation NSDictionary(subscripts)

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}
@end

#endif

@implementation UIDevice (Util)

#pragma mark sysctlbyname utils
- (NSString *)getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = @(answer);
    
    free(answer);
    return results;
}

- (NSString *)platform {
    return [self getSysInfoByName:"hw.machine"];
}


- (NSString *)hwmodel {
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger)getSysInfo:(uint) typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency {
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)cpuCount {
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger)totalMemory {
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)userMemory {
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger)maxSocketBufferSize {
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

- (NSNumber *)totalDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return fattributes[NSFileSystemSize];
}

- (NSNumber *)freeDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return fattributes[NSFileSystemFreeSize];
}

+( NSInteger )getSubmodel:( NSString* )platform {
    NSInteger submodel = -1;
    
    NSArray* components = [ platform componentsSeparatedByString:@"," ];
    if ( [ components count ] >= 2 )
    {
        submodel = [ [ components objectAtIndex:1 ] intValue ];
    }
    return submodel;
}

#pragma mark platform type and name utils
- (NSUInteger)platformType {
    return [UIDevice platformTypeForString:[self platform]];
}


- (NSString *)platformString {
    return [UIDevice platformStringForType:[self platformType]];
}

+ (NSUInteger)platformTypeForString:(NSString *)platform {
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDeviceiPhone1;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDeviceiPhone3G;
    if ([platform hasPrefix:@"iPhone2"])            return UIDeviceiPhone3GS;
    if ([platform isEqualToString:@"iPhone3,1"])    return UIDeviceiPhone4GSM;
    if ([platform isEqualToString:@"iPhone3,2"])    return UIDeviceiPhone4GSMRevA;
    if ([platform isEqualToString:@"iPhone3,3"])    return UIDeviceiPhone4CDMA;
    if ([platform hasPrefix:@"iPhone4"])            return UIDeviceiPhone4S;
    if ([platform isEqualToString:@"iPhone5,1"])    return UIDeviceiPhone5GSM;
    if ([platform isEqualToString:@"iPhone5,2"])    return UIDeviceiPhone5CDMA;
    if ([platform isEqualToString:@"iPhone5,3"])    return UIDeviceiPhone5CGSM;
    if ([platform isEqualToString:@"iPhone5,4"])    return UIDeviceiPhone5CGSMCDMA;
    if ([platform isEqualToString:@"iPhone6,1"])    return UIDeviceiPhone5SGSM;
    if ([platform isEqualToString:@"iPhone6,2"])    return UIDeviceiPhone5SGSMCDMA;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDeviceiPhone6Plus;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDeviceiPhone6;
    if ([platform isEqualToString:@"iPhone8,1"])    return UIDeviceiPhone6S;
    if ([platform isEqualToString:@"iPhone8,2"])    return UIDeviceiPhone6SPlus;
    if ([platform isEqualToString:@"iPhone8,3"])    return UIDeviceiPhoneSE;
    if ([platform isEqualToString:@"iPhone8,4"])    return UIDeviceiPhoneSE;
    if ([platform isEqualToString:@"iPhone9,1"])    return UIDeviceiPhone7;
    if ([platform isEqualToString:@"iPhone9,2"])    return UIDeviceiPhone7Plus;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDeviceiPod1;
    if ([platform isEqualToString:@"iPod2,2"])      return UIDeviceiPod3;
    if ([platform hasPrefix:@"iPod2"])              return UIDeviceiPod2;
    if ([platform hasPrefix:@"iPod3"])              return UIDeviceiPod3;
    if ([platform hasPrefix:@"iPod4"])              return UIDeviceiPod4;
    if ([platform hasPrefix:@"iPod5"])              return UIDeviceiPod5;
    if ([platform isEqualToString:@"iPod7,1"])      return UIDeviceiPod6;
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])       return UIDeviceiPad;
    if ([platform isEqualToString:@"iPad2,1"])       return UIDeviceiPad2;
    if ([platform isEqualToString:@"iPad2,2"])       return UIDeviceiPad2;
    if ([platform isEqualToString:@"iPad2,3"])       return UIDeviceiPad2;
    if ([platform isEqualToString:@"iPad2,4"])       return UIDeviceiPad2;
    if ([platform isEqualToString:@"iPad3,1"])       return UIDeviceiPad3;
    if ([platform isEqualToString:@"iPad3,2"])       return UIDeviceiPad3;
    if ([platform isEqualToString:@"iPad3,3"])       return UIDeviceiPad3;
    if ([platform isEqualToString:@"iPad3,4"])       return UIDeviceiPad4;
    if ([platform isEqualToString:@"iPad3,5"])       return UIDeviceiPad4;
    if ([platform isEqualToString:@"iPad3,6"])       return UIDeviceiPad4;
    
    //iPad Air
    if ([platform isEqualToString:@"iPad4,1"])       return UIDeviceiPadAir;
    if ([platform isEqualToString:@"iPad4,2"])       return UIDeviceiPadAir;
    if ([platform isEqualToString:@"iPad4,3"])       return UIDeviceiPadAir;
    if ([platform isEqualToString:@"iPad5,3"])       return UIDeviceiPadAir2;
    if ([platform isEqualToString:@"iPad5,4"])       return UIDeviceiPadAir2;
    
    //iPad mini
    if ([platform isEqualToString:@"iPad2,5"])       return UIDeviceiPadMini1G;
    if ([platform isEqualToString:@"iPad2,6"])       return UIDeviceiPadMini1G;
    if ([platform isEqualToString:@"iPad2,7"])       return UIDeviceiPadMini1G;
    if ([platform isEqualToString:@"iPad4,4"])       return UIDeviceiPadMini2;
    if ([platform isEqualToString:@"iPad4,5"])       return UIDeviceiPadMini2;
    if ([platform isEqualToString:@"iPad4,6"])       return UIDeviceiPadMini2;
    if ([platform isEqualToString:@"iPad4,7"])       return UIDeviceiPadMini3;
    if ([platform isEqualToString:@"iPad4,8"])       return UIDeviceiPadMini3;
    if ([platform isEqualToString:@"iPad4,9"])       return UIDeviceiPadMini3;
    if ([platform isEqualToString:@"iPad5,1"])       return UIDeviceiPadMini4;
    if ([platform isEqualToString:@"iPad5,2"])       return UIDeviceiPadMini4;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"]) {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceiPhoneSimulatoriPhone : UIDeviceiPhoneSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

+ (NSString *)platformStringForType:(NSUInteger)platformType {
    switch (platformType) {
        case UIDeviceiPhone1:               return IPHONE_1_NAMESTRING;
        case UIDeviceiPhone3G:              return IPHONE_3G_NAMESTRING;
        case UIDeviceiPhone3GS:             return IPHONE_3GS_NAMESTRING;
        case UIDeviceiPhone4GSM:            return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4GSMRevA:        return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4CDMA:           return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4S:              return IPHONE_4S_NAMESTRING;
        case UIDeviceiPhone5GSM:            return IPHONE_5_NAMESTRING;
        case UIDeviceiPhone5CDMA:           return IPHONE_5_NAMESTRING;
        case UIDeviceiPhone5CGSM:           return IPHONE_5C_NAMESTRING;
        case UIDeviceiPhone5CGSMCDMA:       return IPHONE_5C_NAMESTRING;
        case UIDeviceiPhone5SGSM:           return IPHONE_5S_NAMESTRING;
        case UIDeviceiPhone5SGSMCDMA:       return IPHONE_5S_NAMESTRING;
        case UIDeviceiPhone6:               return IPHONE_6_NAMESTRING;
        case UIDeviceiPhone6GSM:            return IPHONE_6_NAMESTRING;
        case UIDeviceiPhone6GSMCDMA:        return IPHONE_6_NAMESTRING;
        case UIDeviceiPhone6Plus:           return IPHONE_6Plus_NAMESTRING;
        case UIDeviceiPhone6PlusGSM:        return IPHONE_6Plus_NAMESTRING;
        case UIDeviceiPhone6PlusGSMCDMA:    return IPHONE_6Plus_NAMESTRING;
        case UIDeviceiPhone6S:              return IPHONE_6S_NAMESTRING;
        case UIDeviceiPhone6SPlus:          return IPHONE_6SPlus_NAMESTRING;
        case UIDeviceiPhoneSE:              return IPHONE_SE_NAMESTRING;
        case UIDeviceiPhone7:               return IPHONE_7_NAMESTRING;
        case UIDeviceiPhone7Plus:           return IPHONE_7Plus_NAMESTRING;
        case UIDeviceUnknowniPhone:         return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPod1:                 return IPOD_1_NAMESTRING;
        case UIDeviceiPod2:                 return IPOD_2_NAMESTRING;
        case UIDeviceiPod3:                 return IPOD_3_NAMESTRING;
        case UIDeviceiPod4:                 return IPOD_4_NAMESTRING;
        case UIDeviceiPod5:                 return IPOD_5_NAMESTRING;
        case UIDeviceiPod6:                 return IPOD_6_NAMESTRING;
        case UIDeviceUnknowniPod:           return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPad :                 return IPAD_1_NAMESTRING;
        case UIDeviceiPad2 :                return IPAD_2_NAMESTRING;
        case UIDeviceiPad3 :                return IPAD_3_NAMESTRING;
        case UIDeviceiPad4 :                return IPAD_4_NAMESTRING;

        case UIDeviceiPadAir :              return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadAir2 :             return IPAD_AIR2_NAMESTRING;
        
        case UIDeviceiPadMini1G :           return IPAD_MINI_1G_NAMESTRING;
        case UIDeviceiPadMini2 :            return IPAD_MINI_2_NAMESTRING;
        case UIDeviceiPadMini3 :            return IPAD_MINI_3_NAMESTRING;
        case UIDeviceiPadMini4 :            return IPAD_MINI_4_NAMESTRING;
        case UIDeviceUnknowniPad :          return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 :             return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 :             return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 :             return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV:        return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPhoneSimulator:       return IPHONE_SIMULATOR_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPad:   return IPHONE_SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV:      return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA:                 return IFPGA_NAMESTRING;
            
        default:                            return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

+ (NSString *)platformStringForPlatform:(NSString *)platform {
    NSUInteger platformType = [UIDevice platformTypeForString:platform];
    return [UIDevice platformStringForType:platformType];
}

+ (BOOL)hasRetinaDisplay {
    return ([UIScreen mainScreen].scale == 2.0f);
}

+ (NSString *)imageSuffixRetinaDisplay {
    return @"@2x";
}

+ (BOOL)has4InchDisplay {
    return ([UIScreen mainScreen].bounds.size.height == 568);
}

+ (NSString *)imageSuffix4InchDisplay {
    return @"-568h";
}

- (UIDeviceFamily)deviceFamily {
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}

#pragma mark MAC addy
- (NSString *)macaddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}


@end
