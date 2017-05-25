//
//  UIImage+VMImage.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/18.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "UIImage+VMImage.h"
#import "UIColor+VMColor.h"
#import "VMTools.h"
#import "UIView+VMKit.h"
@implementation UIImage(VMImage)

+(UIImage*)imageNamed:(NSString *)name withBundleName:(NSString*)bundleName{
    NSString* path  = [NSString stringWithFormat:@"%@.bundle/%@",bundleName,name];
    return [UIImage imageNamed:path];
}

-(NSString *)base64String{
    
    NSData *data = UIImagePNGRepresentation(self);
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return str;
}

- (UIImage*)transformWidth:(CGFloat)width
                    height:(CGFloat)height{
    
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    
    CGImageRef imageRef = self.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                destW,
                                                destH,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4*destW,
                                                CGImageGetColorSpace(imageRef),
                                                (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, sourceW, sourceH), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}


-(UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    
    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    
    //create image buffers
    CGImageRef imageRef = self.CGImage;
    
    //convert to ARGB if it isn't
    if (CGImageGetBitsPerPixel(imageRef) != 32 ||
        CGImageGetBitsPerComponent(imageRef) != 8 ||
        !((CGImageGetBitmapInfo(imageRef) & kCGBitmapAlphaInfoMask)))
    {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        [self drawAtPoint:CGPointZero];
        imageRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();
    }
    
    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    
    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

+(UIImage *)imageWithURL:(NSString *)url inDocumentFolder:(NSString *)folder{
    
    NSString *hashName = [NSString stringWithFormat:@"%ld",[url hash]];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:[[VMTools documentPath]stringByAppendingPathComponent:folder]];
    if (isExist == NO) {
        [manager createDirectoryAtPath:[[VMTools documentPath]stringByAppendingPathComponent:folder]  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[[VMTools documentPath]stringByAppendingPathComponent:folder] stringByAppendingPathComponent:hashName]];
    if (data == nil) {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [data writeToFile:[[[VMTools documentPath]stringByAppendingPathComponent:folder] stringByAppendingPathComponent:hashName] atomically:YES];
    }
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

+(UIImage *)imageWithURL:(NSString *)url inDocumentFolder:(NSString *)folder autoDownload:(BOOL)download{
    if (download == YES) {
        return [UIImage imageWithURL:url inDocumentFolder:folder];
    }else{
        NSString *hashName = [NSString stringWithFormat:@"%ld",[url hash]];
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL isExist = [manager fileExistsAtPath:[[VMTools documentPath]stringByAppendingPathComponent:folder]];
        if (isExist == NO) {
            [manager createDirectoryAtPath:[[VMTools documentPath]stringByAppendingPathComponent:folder]  withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSData *data = [NSData dataWithContentsOfFile:[[[VMTools documentPath]stringByAppendingPathComponent:folder] stringByAppendingPathComponent:hashName]];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
}




+(UIImage *)imageWithURL:(NSString *)url timeOut:(NSInteger)timeOut{
    
    NSString *hashName = [NSString stringWithFormat:@"%ld",[url hash]];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:[[VMTools documentPath]stringByAppendingPathComponent:@"SWWeiBoEmotion"]];
    if (isExist == NO) {
        [manager createDirectoryAtPath:[[VMTools documentPath]stringByAppendingPathComponent:@"SWWeiBoEmotion"]  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[[VMTools documentPath]stringByAppendingPathComponent:@"SWWeiBoEmotion"] stringByAppendingPathComponent:hashName]];
    if (data == nil) {
        data = [NSData dataWithContentOfURL:url timeOut:timeOut];
        [data writeToFile:[[[VMTools documentPath]stringByAppendingPathComponent:@"SWWeiBoEmotion"] stringByAppendingPathComponent:hashName] atomically:YES];
    }
    UIImage *image = [UIImage imageWithData:data];
    return image;
}


- (UIImage *) imageWithTintColor:(UIColor *)tintColor{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+(UIImage *)changeWhiteColorTransparent: (UIImage *)image{
    CGImageRef rawImageRef=image.CGImage;
    const CGFloat colorMasking[6] = {10, 25, 22, 255, 222, 1};
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}




+ (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, image.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, image.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

+(UIImage *)imageWithBGColor:(UIColor *)bgColor image:(UIImage *)img{
    UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
    imgView.backgroundColor = bgColor;
    [imgView sizeToFit];
    return [imgView screenShotWithRect:imgView.bounds save:NO];
}



@end
