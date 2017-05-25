//
//  VMDataBaseManager.m
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/6.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import "VMDataBaseManager.h"
#import "VMTools.h"
#import "VMLog.h"
#import "NSString+VMKit.h"

#define VMDataBase @"shuji.db"

@interface VMDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@end

@implementation VMDataBaseManager


-(void)dealloc{
    [self.dbQueue close];
}

+(VMDataBaseManager *)shareDBManager{
    static dispatch_once_t once;
    static VMDataBaseManager* __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[VMDataBaseManager alloc] init]; } );
    return __singleton__;
}

-(id)init{

    self = [super init];
    if (self) {
        [VMLog initializeDefaultLogSystem];
        self.dispatchQueue = dispatch_queue_create("VMDatabase_Queue_seious", DISPATCH_QUEUE_SERIAL);
        self.dbQueue =  [FMDatabaseQueue databaseQueueWithPath:[VMDataBaseManager dbPath]];
        if ([self openDB] == NO) {
        }
        return self;
    }
    return nil;
}

-(BOOL)hasTable:(NSString *)table{
    
    __block BOOL tableExist = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db){
        tableExist = [db tableExists:table];
    }];
    return tableExist;
}

+(BOOL)dbExistWithName:(NSString *)dbName{
    if ([dbName isValid] == NO) {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL dbExist = [manager fileExistsAtPath:[VMDataBaseManager dbPathWithName:dbName]];
    if (dbExist) {
        VMLogDebug(@"数据库文件已经创建成功");
    }else
        VMLogDebug(@"数据库文件还没有创建");
    return dbExist;
}

+(BOOL)magicBoxDBExist{
    return [VMDataBaseManager dbExistWithName:VMDataBase];
}

+(NSString *)dbPath{
    return [VMDataBaseManager dbPathWithName:VMDataBase];
}

+(NSString *)dbPathWithName:(NSString *)dbName{
    NSString *docPath = [VMTools documentPath];
    NSString *dbPath = [docPath stringByAppendingPathComponent:dbName];
    NSLog(@"%@",dbPath);
    
    return dbPath;
}


-(BOOL)openDB{
    
    NSLog(@"=-=-=-=-=-=-=-=-opendb time");
    NSLog(@"========>>>>>>>>>%@",[NSThread currentThread]);
    /*
    if (self.db == nil) {
        self.db = [FMDatabase databaseWithPath:[self dbPath]];
    }
     return [self.db open];
     */
    __block BOOL openResult = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        openResult = [db open];
    }];
    if (openResult) {
        VMLogInfo(@"打开数据库成功！！！！");
    }else
        VMLogError(@"打开数据库失败了！！！！");
    return openResult;
}

#pragma mark-
#pragma mark------actions------

-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info{
    return [self createTable:table withInfo:info byQueue:self.dbQueue];
}



-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info byQueue:(FMDatabaseQueue *)dbqueue{

    if (info == nil || info.allKeys.count == 0) {
        VMLogDebug(@"建表数据不能为空");
        return NO;
    }
    if (dbqueue == nil) {
        VMLogError(@"数据库对象为空");
        return NO;
    }
    if ([self hasTable:table]) {
        VMLogError(@"创建失败，表已经存在");
        return YES;
    }
    NSMutableString *createStr = [@""mutableCopy];
    [createStr appendFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT ,",table];
    NSArray *array = info.allKeys;
    for (int i = 0; i < array.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%@",array[i]];
        [createStr appendFormat:@"'%@' TEXT,",key];
    }
    
    if ([createStr hasSuffix:@","]) {
        [createStr replaceCharactersInRange:NSMakeRange(createStr.length - 1, 1) withString:@")"];
    }
    __block BOOL res = NO;
    [dbqueue inDatabase:^(FMDatabase *db){
        res = [db executeUpdate:createStr];
    }];
    if (!res) {
        VMLogError(@"创建失败,sql语句执行失败");
        return NO;
    }else{
        return YES;
    }

    VMLogError(@"创建失败，打开数据库失败");
    return NO;
}

-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info withUNIQUEkey:(NSString *)uniqueKey{
    return [self createTable:table withInfo:info byQueue:self.dbQueue withUNIQUEkey:uniqueKey];
}

-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info byQueue:(FMDatabaseQueue *)queue withUNIQUEkey:(NSString *)uniqueKey{
    if (info == nil || info.allKeys.count == 0) {
        VMLogDebug(@"建表数据不能为空");
        return NO;
    }
    if (queue == nil) {
        VMLogError(@"数据库对象为空");
        return NO;
    }
    if ([self hasTable:table]) {
        VMLogDebug(@"表已存在");
        return YES;
    }
    
    NSMutableString *createStr = [@""mutableCopy];
    [createStr appendFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT ,",table];
    NSArray *array = info.allKeys;
    for (int i = 0; i < array.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%@",array[i]];
        if ([key isEqualToString:uniqueKey]) {
            [createStr appendFormat:@"'%@' TEXT UNIQUE,",uniqueKey];
        }else
            [createStr appendFormat:@"'%@' TEXT,",key];
    }
    if ([createStr hasSuffix:@","]) {
        [createStr replaceCharactersInRange:NSMakeRange(createStr.length - 1, 1) withString:@")"];
    }
    __block BOOL res = NO;
    [queue inDatabase:^(FMDatabase *db){
        res = [db executeUpdate:createStr];
    }];
    if (!res) {
        VMLogError(@"create label error");
        return NO;
    }else{
        return YES;
    }
    
    VMLogError(@"数据库无法打开");
    return NO;
}

-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info withPRIVATEKey:(NSString *)privateKey{

    if (info == nil || info.allKeys.count == 0) {
        VMLogDebug(@"建表数据不能为空");
        return NO;
    }
    if ([self hasTable:table]) {
        VMLogDebug(@"表已存在");
        return YES;
    }
    
    NSMutableString *createStr = [@""mutableCopy];
    [createStr appendFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT PRIMARY KEY ,",table,privateKey];
    NSArray *array = info.allKeys;
    for (int i = 0; i < array.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%@",array[i]];
        if ([key isEqualToString:privateKey]) {
            
        }else
            [createStr appendFormat:@"'%@' TEXT,",key];
    }
    if ([createStr hasSuffix:@","]) {
        [createStr replaceCharactersInRange:NSMakeRange(createStr.length - 1, 1) withString:@")"];
    }
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db){
        res = [db executeUpdate:createStr];
    }];
    if (!res) {
        VMLogError(@"create label error");
        return NO;
    }else{
        return YES;
    }
    
    VMLogError(@"数据库无法打开");
    return NO;
}



#pragma mark-
#pragma mark------写方法------

-(NSString *)writeMethod:(NSString *)method table:(NSString *)table SQLFromDictionary:(NSDictionary *)dic{
    
    
    if (dic == nil || dic.count == 0) {
        return nil;
    }
    if (![[method lowercaseString] isEqualToString:@"insert"] && ![[method lowercaseString]isEqualToString:@"replace"]) {
        VMLogError(@"喂喂，你调用的啥鬼方法，重调用！");
        return nil;
    }
    
    NSMutableString *excleStr = [@""mutableCopy];
    [excleStr appendFormat:@"%@ INTO %@",method,table];
    NSMutableString *excleKeys = [@"("mutableCopy];
    NSMutableString *infoExcelKeys = [@"("mutableCopy];
    NSArray *keys = dic.allKeys;
    for (NSString *str in keys) {
        NSString *finKey = [NSString stringWithFormat:@"%@",str];
        [excleKeys appendFormat:@"%@,",finKey];
        [infoExcelKeys appendFormat:@":%@,",finKey];
    }
    if ([excleKeys hasSuffix:@","]) {
        [excleKeys replaceCharactersInRange:NSMakeRange(excleKeys.length - 1, 1) withString:@")"];
    }
    if ([infoExcelKeys hasSuffix:@","]) {
        [infoExcelKeys replaceCharactersInRange:NSMakeRange(infoExcelKeys.length - 1, 1) withString:@")"];
    }
    [excleStr appendFormat:@"%@ VALUES %@",excleKeys,infoExcelKeys];
    VMLogDebug(excleStr);
    return excleStr;
}

-(NSString *)replace:(NSString *)table SQLFromDictionary:(NSDictionary *)dic{
    return [self writeMethod:@"REPLACE" table:table SQLFromDictionary:dic];
}

-(NSString *)insert:(NSString *)table SQLFromDictionary:(NSDictionary *)dic{
    return [self writeMethod:@"INSERT" table:table SQLFromDictionary:dic];
}

-(BOOL)writeInfo:(NSDictionary *)dic toTable:(NSString *)table{
    return [self writeInfos:@[dic] toTable:table];
}


-(BOOL)writeInfos:(NSArray *)dics toTable:(NSString *)table{
    return [self writeMethod:@"INSERT" infos:dics toTable:table];
}

-(BOOL)replaceInfo:(NSDictionary *)dic toTable:(NSString *)table{
    return [self replaceInfos:@[dic] toTable:table];
}

-(BOOL)replaceInfos:(NSArray *)dics toTable:(NSString *)table{
    return [self writeMethod:@"REPLACE" infos:dics toTable:table];
}

-(BOOL)writeMethod:(NSString *)method infos:(NSArray *)dics toTable:(NSString *)table{
    __block BOOL rs = NO;
    __weak typeof(self)weakSelf = self;
    __block NSString *excleStr;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        for (NSDictionary *dic in dics) {
            if (dic == nil || dic.count == 0) {
                continue;
            }
            NSString *insertStr = [strongSelf writeMethod:method table:table SQLFromDictionary:dic];
            excleStr = insertStr;
            rs = [db executeUpdate:insertStr withParameterDictionary:dic];
        }
    }];
    if (rs) {
        VMLogInfo(@"卧槽！批量写入成功啦，你造吗，成功啦。功啦。啦！！！！");
        return YES;
    }
    NSString *errorLog = [NSString stringWithFormat:@"%@ 写文件失败",excleStr];
    VMLogError(errorLog);
    return NO;
}


#pragma mark-
#pragma mark------selecte methods------

-(NSArray *)getUniqueInfoByKey:(NSString *)key value:(NSString *)value fromTable:(NSString *)table{
    
    if ([key isValid] == NO || [value isValid] == NO) {
        VMLogError(@"参数名以及参数的值不能为空");
        return nil;
    }
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db){
        NSString *selectStr = [NSString stringWithFormat:@"select * from %@ where %@ = %@",table,key,value];
        FMResultSet *result = [db executeQuery:selectStr];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            [array addObject:dic];
        }
        [result close];
    }];
    return [array copy];
}

-(NSString *)selecteStringFromDic:(NSDictionary *)dic table:(NSString *)table{
    
    NSMutableString *excleStr = [@""mutableCopy];
    [excleStr appendFormat:@"select * FROM %@",table];
    if (dic == nil || dic.count == 0) {
        VMLogDebug(excleStr);
        return excleStr;
    }
    [excleStr appendString:@" WHERE "];
    NSArray *keys = dic.allKeys;
    for (NSString *str in keys) {
        NSString *finKey = [NSString stringWithFormat:@"%@",str];
        [excleStr appendFormat:@"%@ = :%@,",finKey,finKey];
    }
    if ([excleStr hasSuffix:@","]) {
        [excleStr deleteCharactersInRange:NSMakeRange(excleStr.length - 1, 1)];
    }
    VMLogDebug(excleStr);
    return excleStr;

}


-(NSArray *)getInfoByKeysAndValues:(NSDictionary *)dic fromTable:(NSString *)tabele{
    
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *excelStr = [self selecteStringFromDic:dic table:tabele];

        VMLogDebug(excelStr);
        FMResultSet *result = [db executeQuery:excelStr withParameterDictionary:dic];
        while (result.next) {
            NSDictionary *resultDic = result.resultDictionary;
            [array addObject:resultDic];
        }
        [result close];
    }];
    return [array copy];
}

-(NSArray *)getInfoByKeysAndValues:(NSDictionary *)dic
                         fromTable:(NSString *)tabele
                       butNotValue:(NSDictionary *)abandonDic{
    
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableString *selectStr = [@""mutableCopy];
        [selectStr appendFormat:@"select * from %@",tabele];
        if (dic == nil || dic.allKeys.count == 0) {
    
        }else{
            [selectStr appendString:@" where"];
            NSArray *keys = dic.allKeys;
            for (int i = 0; i < keys.count; i++) {
                NSString *keyStr = keys[i];
                NSString *valStr = dic[keyStr];
                [selectStr appendFormat:@" %@ = %@ and",keyStr,valStr];
                
            }
            if ([selectStr hasSuffix:@"and"]) {
                [selectStr replaceCharactersInRange:NSMakeRange(selectStr.length - 3, 3) withString:@""];
            }
        }
        NSArray *abandonAry = abandonDic.allKeys;
        for (int i = 0; i < abandonAry.count; i++) {
            NSString *abaKey = abandonAry[i];
            NSString *abaVal = abandonDic[abaKey];
            [selectStr appendFormat:@" and %@ != %@",abaKey,abaVal];
        }
        if (dic == nil || dic.allKeys.count == 0) {
            NSRange range = [selectStr rangeOfString:@"and"];
            [selectStr replaceCharactersInRange:range withString:@"where"];
        }
        
        VMLogDebug(selectStr);

        FMResultSet *result = [db executeQuery:selectStr];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            [array addObject:dic];
        }
        [result close];
    }];
    return [array copy];
}


-(NSArray *)getInfoByKeysAndValues:(NSDictionary *)dic fromTable:(NSString *)tabele butNotValues:(NSArray *)abandonArray{
    
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db){
        NSMutableString *selectStr = [@""mutableCopy];
        [selectStr appendFormat:@"select * from %@",tabele];
        if (dic == nil || dic.allKeys.count == 0) {
        }else{
            [selectStr appendString:@" where"];
            NSArray *keys = dic.allKeys;
            for (int i = 0; i < keys.count; i++) {
                NSString *keyStr = keys[i];
                NSString *valStr = dic[keyStr];
                [selectStr appendFormat:@" %@ = %@ and",keyStr,valStr];
                
            }
            if ([selectStr hasSuffix:@"and"]) {
                [selectStr replaceCharactersInRange:NSMakeRange(selectStr.length - 3, 3) withString:@""];
            }
        }
        if (abandonArray == nil || abandonArray.count == 0) {
            
        }else{
            for (int i = 0; i < abandonArray.count; i++) {
                NSDictionary *abandonDic = abandonArray[i];
                NSArray *abandonAry = abandonDic.allKeys;
                for (int i = 0; i < abandonAry.count; i++) {
                    NSString *abaKey = abandonAry[i];
                    NSString *abaVal = abandonDic[abaKey];
                    if ([abaVal isValid] == NO) {
                        abaVal = @"''";
                    }
                    [selectStr appendFormat:@" and %@ != %@",abaKey,abaVal];
                }
            }
        }
        if (dic == nil || dic.allKeys.count == 0) {
            NSRange range = [selectStr rangeOfString:@"and"];
            [selectStr replaceCharactersInRange:range withString:@"where"];
        }
        VMLogDebug(selectStr);
        FMResultSet *result = [db executeQuery:selectStr];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            [array addObject:dic];
        }
        [result close];
    }];

    return [array copy];
}

//符合当前key的所有数据的集合，返回一个字典数组
-(NSArray *)getInfoByKey:(NSString *)key value:(NSString *)value fromTable:(NSString *)table{
    if ([value isValid] == NO) {
        return nil;
    }
    NSArray *array = [self getInfoByKeysAndValues:@{key:value} fromTable:table];
    return array;
}

-(NSArray *)getInfoFromTable:(NSString *)table{
    NSArray *array = [self getInfoByKeysAndValues:nil fromTable:table];
    return array;
}

-(NSArray *)getInfoFromTable:(NSString *)table
               withKeyValues:(NSDictionary *)keyValue
                 leftOnTabel:(NSString *)table2
              refertableKeys:(NSArray *)key1
                tableTwoKeys:(NSArray *)key3{
    
    if ([table isValid] == NO || [table2 isValid] == NO) {
        VMLogError(@"关联表不能为空，查询失败");
        return nil;
    }
    if (key1.count != key3.count) {
        VMLogError(@"关联表的依赖健数目不能不一致");
        return nil;
    }
//SELECT * FROM user_comment_tb LEFT OUTER JOIN video_detail_tb ON user_comment_tb.postid = video_detail_tb.post_id where commentid='226392' and postid='66571'
    
    if ([self hasTable:table] && [self hasTable:table2]) {
        NSMutableString *excelStr = [@"SELECT * FROM" mutableCopy];
        [excelStr appendFormat:@" %@ LEFT OUTER JOIN %@ ON ",table,table2];

        for (int i = 0; i < key1.count; i++) {
            NSString *keyStr = key1[i];
            NSString *key2Str = key3[i];
            [excelStr appendFormat:@"%@.%@ = %@.%@ and ",table,keyStr,table2,key2Str];
        }
        if ([excelStr hasSuffix:@"and "]) {
            [excelStr replaceCharactersInRange:NSMakeRange(excelStr.length - 4, 4) withString:@""];
        }
    
        if (keyValue == nil || keyValue.count == 0) {
            
        }else{
            [excelStr appendString:@" WHERE"];
            for (NSString *str in keyValue.allKeys) {
                NSString *key = str;
                NSString *value = keyValue[key];
                [excelStr appendFormat:@" %@ = %@ and",key,value];
            }
        }
        if ([excelStr hasSuffix:@"and"]) {
            [excelStr replaceCharactersInRange:NSMakeRange(excelStr.length - 4, 4) withString:@""];
        }
        VMLogDebug(excelStr);
        NSMutableArray *result = [@[]mutableCopy];
        __block FMResultSet *set;
        
        [self.dbQueue inDatabase:^(FMDatabase *db){
            set = [db executeQuery:excelStr];
            while (set.next) {
                [result addObject:set.resultDictionary];
            }
            [set close];
        }];
        return [result copy];
        
    }else{
        
        VMLogError(@"数据库内暂时没有相关的表，查询失败");
        return nil;
    }
    return nil;
}

-(NSArray *)getInfoFromTable:(NSString *)table
                 leftOnTable:(NSString *)table1
               referTableKey:(NSString *)key
                 tabelTwoKey:(NSString *)key1{
    NSArray *array = [self getInfoFromTable:table
                              withKeyValues:nil
                                leftOnTabel:table1
                             refertableKeys:@[key]
                               tableTwoKeys:@[key1]];
    return array;
}

-(NSArray *)getInfoFromTable:(NSString *)table
                 leftOnTable:(NSString *)table1
               referTableKey:(NSString *)key
                 butNotValue:(NSString *)value
                 tabelTwoKey:(NSString *)key1{
    
    if ([table isValid] == NO || [table1 isValid] == NO) {
        VMLogError(@"关联表不能为空，查询失败");
        return nil;
    }
    if ([self hasTable:table] && [self hasTable:table1]) {
        NSMutableString *excelStr = [@"SELECT"mutableCopy];
        [excelStr appendFormat:@"*"];
        [excelStr appendFormat:@" FROM %@ LEFT OUTER JOIN %@ ON ",table,table1];
        [excelStr appendFormat:@"%@.%@ = %@.%@ ",table,key,table1,key1];
        
        [excelStr appendFormat:@"WHERE %@.%@ IS NOT '%@'",table,key,value];
        VMLogDebug(excelStr);
        NSMutableArray *result = [@[]mutableCopy];
        __block FMResultSet *set;
        [self.dbQueue inDatabase:^(FMDatabase *db){
            set = [db executeQuery:excelStr];
            while (set.next) {
                [result addObject:set.resultDictionary];
            }
            [set close];
        }];
        return [result copy];
        
    }else{
        VMLogError(@"数据库内暂时没有相关的表，查询失败");
        return nil;
    }
    return nil;
}

-(NSArray *)getInfoFromTable:(NSString *)table
                 leftOnTable:(NSString *)table1
               referTableKey:(NSString *)key
                   withValue:(NSString *)value
                 tabelTwoKey:(NSString *)key1{
    if ([table isValid] == NO || [table1 isValid] == NO) {
        VMLogError(@"关联表不能为空，查询失败");
        return nil;
    }
    if ([self hasTable:table] && [self hasTable:table1]) {
        NSMutableString *excelStr = [@"SELECT"mutableCopy];
        [excelStr appendFormat:@"*"];
        [excelStr appendFormat:@" FROM %@ LEFT OUTER JOIN %@ ON ",table,table1];
        [excelStr appendFormat:@"%@.%@ = %@.%@ ",table,key,table1,key1];

        [excelStr appendFormat:@"WHERE %@.%@ IS '%@'",table,key,value];
        VMLogDebug(excelStr);
        NSMutableArray *result = [@[]mutableCopy];
        __block FMResultSet *set;
        
        [self.dbQueue inDatabase:^(FMDatabase *db){
            set = [db executeQuery:excelStr];
            while (set.next) {
                [result addObject:set.resultDictionary];
            }
            [set close];
        }];

      
        return [result copy];
        
    }else{
        VMLogError(@"数据库内暂时没有相关的表，查询失败");
        return nil;
    }
    return nil;
}

/**一般来说。这些referKey应该都是一样的
 */
-(NSArray *)getInfoFromTable:(NSString *)table
                     withKey:(NSString *)key
                       value:(NSString *)value
                    referKey:(NSString *)referKey
                 leftOnTable:(NSString *)table2
                    referKey:(NSString *)referKey1
              andLeftOnTable:(NSString *)tabel3
                    referKey:(NSString *)referKey2{
    
    NSMutableString *excleStr = [@"SELECT * FROM "mutableCopy];
    [excleStr appendFormat:@"%@ LEFT OUTER JOIN %@ ON %@.%@ = %@.%@ LEFT OUTER JOIN %@ ON %@.%@ = %@.%@ WHERE %@.%@ = '%@'",table,table2,table,referKey,table2,referKey1,tabel3,table,referKey,tabel3,referKey2,table,key,value];
    VMLogInfo(excleStr);
    NSMutableArray *dataAry = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:excleStr];
        if (result.next) {
            [dataAry addObject:result.resultDictionary];
        }
    }];
    return [dataAry copy];
}

/**一般来说。这些referKey应该都是一样的
 */
-(NSArray *)getInfoFromTable:(NSString *)table
                    referKey:(NSString *)referKey
                 leftOnTable:(NSString *)table2
                    referKey:(NSString *)referKey1
              andLeftOnTable:(NSString *)tabel3
                    referKey:(NSString *)referKey2{
    
    NSMutableString *excleStr = [@"SELECT * FROM "mutableCopy];
    [excleStr appendFormat:@"%@ LEFT OUTER JOIN %@ ON %@.%@ = %@.%@ LEFT OUTER JOIN %@ ON %@.%@ = %@.%@",table,table2,table,referKey,table2,referKey1,tabel3,table,referKey,tabel3,referKey2];
    VMLogInfo(excleStr);
    NSMutableArray *dataAry = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:excleStr];
        if (result.next) {
            [dataAry addObject:result.resultDictionary];
        }
    }];
    return [dataAry copy];
}



/*
 SELECT *  FROM  hot_tb  LEFT OUTER JOIN video_info_tb ON hot_tb.post_id = video_info_tb.post_id LEFT OUTER JOIN video_detail_tb ON video_detail_tb.post_id = video_info_tb.post_id WHERE hot_tb.post_id = '6856'
 */

#pragma mark-
#pragma mark------update actions------

/**字典为@{@"sql":sql语句，@"param":sql语句里对应的?的值}
 *@"update namedparamcounttest set a = :a, b = :b where b = 'Text2'"这句话非常重要，请牢记，同时字典里也一定要有b的key value
 */

-(NSString *)update:(NSString *)table SQLFromDictionary:(NSDictionary *)dic byeKey:(NSString *)key keyValue:(NSString *)keyValue{
    
    if (dic == nil || dic.count == 0) {
        return nil;
    }

    NSMutableString *excleStr = [@""mutableCopy];
    [excleStr appendFormat:@"UPDATE %@ SET ",table];
    NSArray *keys = dic.allKeys;
    for (NSString *str in keys) {
        NSString *finKey = [NSString stringWithFormat:@"%@",str];
        [excleStr appendFormat:@"%@ = :%@,",finKey,finKey];
    }
    [excleStr appendFormat:@"%@ = :%@",key,key];

    if ([excleStr hasSuffix:@","]) {
        [excleStr deleteCharactersInRange:NSMakeRange(excleStr.length - 1, 1)];
    }
    [excleStr appendFormat:@" WHERE %@ = '%@'",key,keyValue];
//    VMLogDebug(excleStr);
    return excleStr;
}


-(BOOL)updateTable:(NSString *)table withDictionary:(NSDictionary *)dic referKey:(NSString *)referKey referValue:(NSString *)referValue{
    
    __block BOOL success;
    __weak typeof(self)weakSelf = self;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //UPDATE VMDownloadTask SET state = ?,modify = ?,progress = ? WHERE task_id = '(null)360'
        __strong typeof(weakSelf)selfStrong = weakSelf;
        NSString *excelStr = [selfStrong update:table SQLFromDictionary:dic byeKey:referKey keyValue:referValue];
//        NSLog(@"update sqldic is %@",excelStr);
        NSMutableDictionary *exDic = [dic mutableCopy];
        if ([exDic.allKeys containsObject:referKey]) {
            
        }else
            exDic[referKey] = referValue;
        success = [db executeUpdate:excelStr withParameterDictionary:exDic];
    }];
    if (success == NO) {
        VMLogError(@"数据库更新失败了，更新失败了，新失败了，失败了，败了，了");
    }
    return success;
}



#pragma mark-
#pragma mark------delete actions------

-(BOOL)deleteTable:(NSString *)table byDic:(NSDictionary *)dic{
    __block BOOL deleteSuccess = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL hasTable = [db tableExists:table];
        if (hasTable) {
            NSMutableString *excelStr = [@""mutableCopy];
            if (dic == nil || dic.count == 0) {
                [excelStr appendFormat:@"DELETE FROM %@",table];
            }else{
                [excelStr appendFormat:@"DELETE FROM %@ WHERE ",table];
                NSArray *allKey = dic.allKeys;
                for (int i = 0; i < allKey.count; i++) {
                    NSString *key = allKey[i];
                    NSString *value = dic[key];
                    [excelStr appendFormat:@" %@ = %@ AND",key,value];
                }
                if ([excelStr hasSuffix:@"AND"]) {
                    [excelStr deleteCharactersInRange:NSMakeRange(excelStr.length - 3, 3)];
                }
            }
            
            deleteSuccess = [db executeUpdate:excelStr];
            if (deleteSuccess) {
                VMLogInfo(@"删除成功了！成功了！功了！了！");
            }else{
                VMLogError(@"删除失败了，失败了，败了，了");
            }
        }else{
            deleteSuccess = NO;
            VMLogError(@"删除失败，因为压根没有这个表");
        }
    }];
    return deleteSuccess;
}



-(BOOL)deleteTable:(NSString *)table byKey:(NSString *)key value:(NSString *)value{
    __block BOOL deleteSuccess = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL hasTable = [db tableExists:table];
        if (hasTable) {
            NSMutableString *excelStr = [@""mutableCopy];
            if (key == nil || value == nil) {
                [excelStr appendFormat:@"DELETE FROM %@",table];
            }else
                [excelStr appendFormat:@"DELETE FROM %@ WHERE %@ = %@",table,key,value];
            deleteSuccess = [db executeUpdate:excelStr];
            if (deleteSuccess) {
                 VMLogInfo(@"删除成功了！成功了！功了！了！");
            }else{
                VMLogError(@"删除失败了，失败了，败了，了");
            }
        }else{
            deleteSuccess = NO;
            VMLogError(@"删除失败，因为压根没有这个表");
        }
    }];
    return deleteSuccess;
}

-(BOOL)deleteTable:(NSString *)table{
    return [self deleteTable:table byKey:nil value:nil];
}


#pragma mark-
#pragma mark------喜欢的一些便捷方法，以后在抽象了------

-(NSArray *)getLocalUnSyncedDataList:(NSInteger)count withVideoInfo:(BOOL)withVideoInfo{
    
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db){
        NSString *selectStr;
        if (!withVideoInfo) {
            selectStr = [NSString stringWithFormat:@"select * from user_like_tb where sync = 0 order by create_time desc limit %ld",(long)count];
        }else
            selectStr = [NSString stringWithFormat:@"select * from user_like_tb LEFT OUTER JOIN video_detail_tb ON user_like_tb.post_id = video_detail_tb.post_id where sync = 0 order by create_time desc limit %ld",(long)count];
        
        FMResultSet *result = [db executeQuery:selectStr];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            [array addObject:dic];
        }
        [result close];
    }];
    return [array copy];
}

-(NSArray *)getLocalLikeDataList:(NSInteger)count withVideoInfo:(BOOL)withVideoInfo withTime:(NSString *)lastUpTime{
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db){
        NSString *selectStr;
        //select * from user_like_tb LEFT OUTER JOIN video_detail_tb ON user_like_tb.post_id = video_detail_tb.post_id  where create_time < 123124   order by create_time desc limit 10
        if (!withVideoInfo) {
            selectStr = [NSString stringWithFormat:@"select * from user_like_tb where create_time < %@ and like = 1 order by create_time desc limit %ld",lastUpTime,(long)count];
        }else
            selectStr = [NSString stringWithFormat:@"select * from user_like_tb LEFT OUTER JOIN video_detail_tb ON user_like_tb.post_id = video_detail_tb.post_id  where create_time < %@ and like = 1 order by create_time desc limit %ld",lastUpTime,(long)count];
        
        FMResultSet *result = [db executeQuery:selectStr];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            [array addObject:dic];
        }
        [result close];
    }];
    return [array copy];
}

-(NSArray *)getLocalHistoryDataList:(NSInteger)count withVideoInfo:(BOOL)withVideoInfo withTime:(NSString *)lastUpTime{
    NSMutableArray *array = [@[]mutableCopy];
    [self.dbQueue inDatabase:^(FMDatabase *db){
        NSString *selectStr;
        if (!withVideoInfo) {
            selectStr = [NSString stringWithFormat:@"select * from user_history_tb where create_time < %@ order by create_time desc limit %ld",lastUpTime,(long)count];
        }else
            selectStr = [NSString stringWithFormat:@"select * from user_history_tb LEFT OUTER JOIN video_detail_tb ON user_like_tb.post_id = video_detail_tb.post_id  where create_time < %@ order by create_time desc limit %ld",lastUpTime,(long)count];
        
        FMResultSet *result = [db executeQuery:selectStr];
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            [array addObject:dic];
        }
        [result close];
    }];
    return [array copy];
}

#pragma mark- 修改表结构的一些方法------

-(void)alterTable:(NSString *)tableName withDefaultAttribution:(NSDictionary *)attribution{
    
}

/**
 *  为表添加某个字段，这里没有找到可以添加多个字段的方法
 *
 *  @param colum 需要添加的字段名
 *
 *  @return BOOL, alert add是否成功
 */

-(BOOL)alertVideoDetailTBWithColum:(NSString *)colum withDefaultValue:(NSString *)defaultValue{
    //    alter table banner_tb add muha TEXT NOT NULL DEFAULT 0
    __block BOOL alertResult;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *alterStr = [NSString stringWithFormat:@"alter table video_detail_tb add %@ TEXT NOT NULL DEFAULT %@",colum,defaultValue];
//        alterStr = @"alter table video_detail_tb add is_magictv TEXT NOT NULL DEFAULT -1";
        alertResult = [db executeUpdate:alterStr];
    }];
    if (alertResult) {
        VMLogInfo(@"video_detail_tb add cloum is_magictv success");
    }else
        VMLogError(@"video_detail_tb add cloum is_magictv failure");
    return alertResult;
}

/**
 *  是否包含了某个字段
 *
 *  @param colum 字段的名字，目前判断 is_magictv
 *
 *  @return BOOL, has or has't
 */

-(BOOL)videoDetailHasColum:(NSString *)colum{
    __block BOOL hasColum = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *pragmaStr;
        pragmaStr = @"pragma table_info(video_detail_tb)";
        FMResultSet *result = [db executeQuery:pragmaStr];
        
        while (result.next) {
            NSDictionary *dic = result.resultDictionary;
            NSString *name = dic[@"name"];
            if ([name isEqualToString:colum]) {
                hasColum = YES;
                break;
            }
        }
        [result close];
    }];
    if (hasColum) {
        VMLogInfo(@"video_detail_tb has colum named %@",colum);
    }else{
        VMLogError(@"video_detail_tb has no colum named %@",colum);
    }
    return hasColum;
}


@end
