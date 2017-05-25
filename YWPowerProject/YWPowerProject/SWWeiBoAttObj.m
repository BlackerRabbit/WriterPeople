//
//  SWWeiBoDataManager.m
//  YWPowerProject
//
//  Created by 蒋正峰 on 2016/12/15.
//  Copyright © 2016年 蒋正峰. All rights reserved.
//

#import "SWWeiBoAttObj.h"
#import "VMovieKit.h"
#import "SWWeiBoEmotionManager.h"

@implementation SWWeiBoAttObj

-(NSAttributedString *)attStringFrom:(NSDictionary *)infoDic hasLocation:(BOOL)location{
    return [[self attStringFrom:infoDic withLocation:location completeHandler:nil] copy];
}



-(NSMutableAttributedString *)attStringFrom:(NSDictionary *)infoDic withLocation:(BOOL)location completeHandler:(void (^)(NSMutableAttributedString *, BOOL, NSError *))handler{
    if (infoDic == nil || infoDic.count == 0) {
        
        if (handler) {
            handler(nil, NO, nil);
        }
        return nil;
    }
    
    //首先处理url
    
    NSString *att = [NSString stringWithFormat:@"%@",infoDic[@"text"]];
    if ([att isValid] == NO) {
        return nil;
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:att];
    //设置下行距
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc]init];
    para.lineSpacing = 4.f;
    [attString addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, attString.length)];
    
    NSDataDetector *dateDectc = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [dateDectc matchesInString:att options:0 range:NSMakeRange(0, att.length)];
    if (matches && matches.count) {
        //这里可以开始进行字符串的替换了。
        NSRange tempRange = NSMakeRange(0, 0);
        NSInteger changedCount = 0;
        for (NSTextCheckingResult *textCheck in matches) {
            
            NSString *url = textCheck.URL.absoluteString;
            NSRange range = textCheck.range;
            tempRange = NSMakeRange(range.location + changedCount, range.length);
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:tempRange];
    
            NSAttributedString *urlAtt = [self findReplaceBy:infoDic url:url location:location];
            [attString replaceCharactersInRange:tempRange withAttributedString:urlAtt];
                
            NSInteger length = urlAtt.length;
            changedCount += length - range.length;
            
   
        }
    }
    //处理#...#
    NSString *pre = @"#(.*?)#";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pre options:0 | NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *preAry = [regex matchesInString:attString.string options:0 range:NSMakeRange(0, attString.length)];
    
    if (preAry && preAry.count) {
        
        for (NSTextCheckingResult *result in preAry) {
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:result.range];
        }
    }
    
    //处理表情
    
    NSString *imgPre = @"\\[(.*?)\\]";
    NSError *imgError = nil;
    NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:imgPre options:0 | NSRegularExpressionDotMatchesLineSeparators error:&imgError];
    NSArray *imgPreAry = [imgRegex matchesInString:attString.string options:0 range:NSMakeRange(0, attString.length)];
    
    if (imgPreAry && imgPreAry.count) {
        for (NSTextCheckingResult *result in imgPreAry) {
            
            NSString *imgName = [attString.string substringWithRange:result.range];
            SWWeiBoEmotionManager *emoManager = [SWWeiBoEmotionManager shareManager];
            NSLog(@"img name is %@",imgName);
            
            __block NSInteger count = 0;
            NSAttributedString *att = [emoManager checkEmotion:imgName];
            if (att == nil) {
                continue;
            }else{
                [attString replaceCharactersInRange:result.range withAttributedString:att];
                [attString addAttribute:NSBaselineOffsetAttributeName value:@(-2.5) range:NSMakeRange(result.range.location, 1)];
            }
        }
    }else{
        if (handler) {
            handler(attString, NO, nil);
        }
    }
    return attString;
}

-(NSAttributedString *)findReplaceBy:(NSDictionary *)infoDic url:(NSString *)url location:(BOOL)location{
    
    if ([url isValid] == NO) {
        return nil;
    }
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:url];
    NSString *replecStr = nil;
    if ([infoDic objectForKey:@"url_struct"] != nil) {
        id urlStruct = infoDic[@"url_struct"];
        if ([[urlStruct class]isSubclassOfClass:[NSArray class]]) {
            for (NSDictionary *urlDic in urlStruct) {
                NSString *shortUrl = [urlDic objectForKey:@"short_url"];
                if ([url isEqualToString:shortUrl]) {
                    
                    //如果是有地址信息的，需要把这个链接给删除掉。不然就继续
                    if (location) {
                        [att replaceCharactersInRange:NSMakeRange(0, att.length) withString:@""];
                        continue;
                    }
                    //找出需要进行替换的数据，
                    NSString *urlTitle = [urlDic objectForKey:@"url_title"];
                    NSString *urlIcon = [urlDic objectForKey:@"url_type_pic"];
                    replecStr = urlTitle;
                    [att replaceCharactersInRange:NSMakeRange(0, att.length) withString:urlTitle];
                    if ([urlIcon isValid] == NO) {
                        break;
                    }
                    NSArray *iconAry = [urlIcon componentsSeparatedByString:@"."];
                    NSMutableArray *iconMuAry = [iconAry mutableCopy];
                    if (iconMuAry.count > 1) {
                        NSString *lastIcon = [iconMuAry[iconMuAry.count - 2] stringByAppendingString:@"_default"];
                        [iconMuAry replaceObjectAtIndex:iconMuAry.count - 2 withObject:lastIcon];
                    }
                    NSString *finalURLIcon = [iconMuAry componentsJoinedByString:@"."];
                    NSLog(@"the url icon is ==>> %@",finalURLIcon);
                    
                    //首先去检查是不是有了这个图片，如果有了的话，直接进行替换，如果没有的话，则通知图片下载中心，需要进行图片的下载
                    UIImage *iconImage = [UIImage imageWithURL:finalURLIcon inDocumentFolder:@"URLIcons"];
                    if (iconImage != nil) {
                        //如果存在相应的iconimage，则直接创建最终的attributestring，并用于返回
                        NSTextAttachment *achment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
                        achment.image = iconImage;
                        achment.bounds = CGRectMake(0, 0, 15, 15);
                        NSAttributedString *attString = [NSAttributedString attributedStringWithAttachment:achment];
                        [att insertAttributedString:attString atIndex:0];
                        [att addAttribute:NSBaselineOffsetAttributeName value:@(-2.5) range:NSMakeRange(0, 1)];
                    }else{
                        //如果图片不存在，则向图片管理中心进行一次注册
                        SWWeiBoEmotionManager *emotionManager = [SWWeiBoEmotionManager shareManager];
                        NSDictionary *downloadDic = @{
                                                      SWWeiBoDownloadImageName:urlTitle,
                                                      SWWeiBoDownloadImageURL:finalURLIcon,
                                                      SWWeiBoDownloadImageSaveFolder:@"URLIcons"
                                                      };
                        [emotionManager downloadImage:urlTitle userInfo:downloadDic completeHandler:^(NSString *url, NSString *imgPath, UIImage *image, NSError *error) {
                            
                        }];
                    }
                    break;
                }
            }
        }
    }
    [att addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, att.length)];
    return att;
}





@end
