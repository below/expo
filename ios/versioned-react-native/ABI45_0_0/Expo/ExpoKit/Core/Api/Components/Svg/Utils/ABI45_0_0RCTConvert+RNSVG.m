/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI45_0_0RCTConvert+RNSVG.h"

#import "ABI45_0_0RNSVGPainterBrush.h"
#import "ABI45_0_0RNSVGSolidColorBrush.h"
#import "ABI45_0_0RNSVGContextBrush.h"
#import <ABI45_0_0React/ABI45_0_0RCTLog.h>
#import <ABI45_0_0React/ABI45_0_0RCTFont.h>

NSRegularExpression *ABI45_0_0RNSVGDigitRegEx;

@implementation ABI45_0_0RCTConvert (ABI45_0_0RNSVG)

ABI45_0_0RCT_ENUM_CONVERTER(ABI45_0_0RNSVGCGFCRule, (@{
                                     @"evenodd": @(kRNSVGCGFCRuleEvenodd),
                                     @"nonzero": @(kRNSVGCGFCRuleNonzero),
                                     }), kRNSVGCGFCRuleNonzero, intValue)

ABI45_0_0RCT_ENUM_CONVERTER(ABI45_0_0RNSVGVBMOS, (@{
                                  @"meet": @(kRNSVGVBMOSMeet),
                                  @"slice": @(kRNSVGVBMOSSlice),
                                  @"none": @(kRNSVGVBMOSNone)
                                  }), kRNSVGVBMOSMeet, intValue)

ABI45_0_0RCT_ENUM_CONVERTER(ABI45_0_0RNSVGUnits, (@{
                                  @"objectBoundingBox": @(kRNSVGUnitsObjectBoundingBox),
                                  @"userSpaceOnUse": @(kRNSVGUnitsUserSpaceOnUse),
                                  }), kRNSVGUnitsObjectBoundingBox, intValue)

+ (ABI45_0_0RNSVGBrush *)ABI45_0_0RNSVGBrush:(id)json
{
    if ([json isKindOfClass:[NSNumber class]]) {
        return [[ABI45_0_0RNSVGSolidColorBrush alloc] initWithNumber:json];
    }
    if ([json isKindOfClass:[NSString class]]) {
        NSString *value = [self NSString:json];
        if (!ABI45_0_0RNSVGDigitRegEx) {
            ABI45_0_0RNSVGDigitRegEx = [NSRegularExpression regularExpressionWithPattern:@"[0-9.-]+" options:NSRegularExpressionCaseInsensitive error:nil];
        }
        NSArray<NSTextCheckingResult*> *_matches = [ABI45_0_0RNSVGDigitRegEx matchesInString:value options:0 range:NSMakeRange(0, [value length])];
        NSMutableArray<NSNumber*> *output = [NSMutableArray array];
        NSUInteger i = 0;
        [output addObject:[NSNumber numberWithInteger:0]];
        for (NSTextCheckingResult *match in _matches) {
            NSString* strNumber = [value substringWithRange:match.range];
            [output addObject:[NSNumber numberWithDouble:(i++ < 3 ? strNumber.doubleValue / 255 : strNumber.doubleValue)]];
        }
        if ([output count] < 5) {
            [output addObject:[NSNumber numberWithDouble:1]];
        }
        return [[ABI45_0_0RNSVGSolidColorBrush alloc] initWithArray:output];
    }
    NSArray *arr = [self NSArray:json];
    NSUInteger type = [self NSUInteger:arr.firstObject];

    switch (type) {
        case 0: // solid color
            // These are probably expensive allocations since it's often the same value.
            // We should memoize colors but look ups may be just as expensive.
            return [[ABI45_0_0RNSVGSolidColorBrush alloc] initWithArray:arr];
        case 1: // brush
            return [[ABI45_0_0RNSVGPainterBrush alloc] initWithArray:arr];
        case 2: // currentColor
            return [[ABI45_0_0RNSVGBrush alloc] initWithArray:nil];
        case 3: // context-fill
            return [[ABI45_0_0RNSVGContextBrush alloc] initFill];
        case 4: // context-stroke
            return [[ABI45_0_0RNSVGContextBrush alloc] initStroke];
        default:
            ABI45_0_0RCTLogError(@"Unknown brush type: %zd", (unsigned long)type);
            return nil;
    }
}

+ (ABI45_0_0RNSVGPathParser *)ABI45_0_0RNSVGCGPath:(NSString *)d
{
    return [[ABI45_0_0RNSVGPathParser alloc] initWithPathString: d];
}

+ (ABI45_0_0RNSVGLength *)ABI45_0_0RNSVGLength:(id)json
{
    if ([json isKindOfClass:[NSNumber class]]) {
        return [ABI45_0_0RNSVGLength lengthWithNumber:(CGFloat)[json doubleValue]];
    } else if ([json isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString *)json;
        return [ABI45_0_0RNSVGLength lengthWithString:stringValue];
    } else {
        return [[ABI45_0_0RNSVGLength alloc] init];
    }
}

+ (NSArray<ABI45_0_0RNSVGLength *>*)ABI45_0_0RNSVGLengthArray:(id)json
{
    if ([json isKindOfClass:[NSNumber class]]) {
        ABI45_0_0RNSVGLength* length = [ABI45_0_0RNSVGLength lengthWithNumber:(CGFloat)[json doubleValue]];
        return [NSArray arrayWithObject:length];
    } else if ([json isKindOfClass:[NSArray class]]) {
        NSArray *arrayValue = (NSArray*)json;
        NSMutableArray<ABI45_0_0RNSVGLength*>* lengths = [NSMutableArray arrayWithCapacity:[arrayValue count]];
        for (id obj in arrayValue) {
            [lengths addObject:[self ABI45_0_0RNSVGLength:obj]];
        }
        return lengths;
    }  else if ([json isKindOfClass:[NSString class]]) {
        NSString *stringValue = (NSString *)json;
        ABI45_0_0RNSVGLength* length = [ABI45_0_0RNSVGLength lengthWithString:stringValue];
        return [NSArray arrayWithObject:length];
    } else {
        return nil;
    }
}

+ (CGRect)ABI45_0_0RNSVGCGRect:(id)json offset:(NSUInteger)offset
{
    NSArray *arr = [self NSArray:json];
    if (arr.count < offset + 4) {
        ABI45_0_0RCTLogError(@"Too few elements in array (expected at least %zd): %@", (ssize_t)(4 + offset), arr);
        return CGRectZero;
    }
    return (CGRect){
        {[self CGFloat:arr[offset]], [self CGFloat:arr[offset + 1]]},
        {[self CGFloat:arr[offset + 2]], [self CGFloat:arr[offset + 3]]},
    };
}

+ (ABI45_0_0RNSVGColor *)ABI45_0_0RNSVGColor:(id)json offset:(NSUInteger)offset
{
    NSArray *arr = [self NSArray:json];
    if (arr.count == offset + 1) {
        return [self ABI45_0_0RNSVGColor:[arr objectAtIndex:offset]];
    }
    if (arr.count < offset + 4) {
        ABI45_0_0RCTLogError(@"Too few elements in array (expected at least %zd): %@", (ssize_t)(4 + offset), arr);
        return nil;
    }
    return [self ABI45_0_0RNSVGColor:[arr subarrayWithRange:(NSRange){offset, 4}]];
}

+ (CGGradientRef)ABI45_0_0RNSVGCGGradient:(id)json
{
    NSArray *arr = [self NSArray:json];
    NSUInteger count = arr.count / 2;
    NSUInteger values = count * 5;
    NSUInteger offsetIndex = values - count;
    CGFloat colorsAndOffsets[values];
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger stopIndex = i * 2;
        CGFloat offset = (CGFloat)[arr[stopIndex] doubleValue];
        NSUInteger argb = [self NSUInteger:arr[stopIndex + 1]];

        CGFloat a = ((argb >> 24) & 0xFF) / 255.0;
        CGFloat r = ((argb >> 16) & 0xFF) / 255.0;
        CGFloat g = ((argb >> 8) & 0xFF) / 255.0;
        CGFloat b = (argb & 0xFF) / 255.0;

        NSUInteger colorIndex = i * 4;
        colorsAndOffsets[colorIndex] = r;
        colorsAndOffsets[colorIndex + 1] = g;
        colorsAndOffsets[colorIndex + 2] = b;
        colorsAndOffsets[colorIndex + 3] = a;

        colorsAndOffsets[offsetIndex + i] = fmax(0, fmin(offset, 1));
    }

    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(
                                                                 rgb,
                                                                 colorsAndOffsets,
                                                                 colorsAndOffsets + offsetIndex,
                                                                 count
                                                                 );
    CGColorSpaceRelease(rgb);
    return (CGGradientRef)CFAutorelease(gradient);
}

@end

