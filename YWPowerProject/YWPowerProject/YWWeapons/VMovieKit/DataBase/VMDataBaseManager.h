//
//  VMDataBaseManager.h
//  VMovieKit
//
//  Created by 蒋正峰 on 15/11/6.
//  Copyright © 2015年 蒋正峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface VMDataBaseManager : NSObject

+(VMDataBaseManager *)shareDBManager;

/**检测是否包含名称为dbname的db文件，这个方法必须要在数据库初始化之前调用，不然会默认创建一个空的，这样会导致结果恒为yes
 */
+(BOOL)dbExistWithName:(NSString *)dbName;

/**检测是否包含魔力盒的db文件，这个方法必须要在数据库初始化之前调用，不然会默认创建一个空的，这样会导致结果恒为yes
 */
+(BOOL)magicBoxDBExist;

/**是否包含某张表
 */
-(BOOL)hasTable:(NSString *)table;

/**创建一个表，这个字典传的是数据，但是不会将数据插入表内
 */
 -(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info;

/**创建一个表，字典里传的是数据，uniquekey是需要做唯一处理的值
 */
-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info withUNIQUEkey:(NSString *)uniqueKey;

/**创建表
 *table:表名
 *info:创建表所用的数据
 *privatekey:做为主键的key，如果info内不包含这个key，则自动添加，如果包含，则不会重复添加
 */
-(BOOL)createTable:(NSString *)table withInfo:(NSDictionary *)info withPRIVATEKey:(NSString *)privateKey;

//符合当前key对应的值的第一条数据，返回一个字典
-(NSDictionary *)getUniqueInfoByKey:(NSString *)key value:(NSString *)value fromTable:(NSString *)table;
//符合当前key的所有数据的集合，返回一个字典数组
-(NSArray *)getInfoByKey:(NSString *)key value:(NSString *)value fromTable:(NSString *)table;
//传入一个字典，数组里面放的是key，value键值对的字典。如：@{@"uid":@"123",@"name":@"magic"};
-(NSArray *)getInfoByKeysAndValues:(NSDictionary *)dic fromTable:(NSString *)tabele;

-(NSArray *)getInfoFromTable:(NSString *)table;

//将数据写入数据库
-(BOOL)writeInfo:(NSDictionary *)dic toTable:(NSString *)table;
-(BOOL)writeInfos:(NSArray *)dic toTable:(NSString *)table;

/**sqlite大招，replace！
 *dic:新的数据，
 *table:需要操作的表
 */
-(BOOL)replaceInfo:(NSDictionary *)dic toTable:(NSString *)table;
-(BOOL)replaceInfos:(NSArray *)dics toTable:(NSString *)table;


#pragma mark-
#pragma mark------selecte actions------

//根据键值对获得数据，同时排除掉那些准备放弃的数据
-(NSArray *)getInfoByKeysAndValues:(NSDictionary *)dic fromTable:(NSString *)tabele butNotValue:(NSDictionary *)abandonDic;
//根据减值获得数据，同时派出掉那些准备放弃的数据，这个方法跟上一个方法的却别就是，里面可以传同一个键的多个值，
-(NSArray *)getInfoByKeysAndValues:(NSDictionary *)dic fromTable:(NSString *)tabele butNotValues:(NSArray *)abandonArray;

//外左关联查询
-(NSArray *)getInfoFromTable:(NSString *)table withKeyValues:(NSDictionary *)keyValue leftOnTabel:(NSString *)table2 refertableKeys:(NSArray *)key1 tableTwoKeys:(NSArray *)key3;

-(NSArray *)getInfoFromTable:(NSString *)table leftOnTable:(NSString *)table1 referTableKey:(NSString *)key tabelTwoKey:(NSString *)key1;

/**三张表统一的关联查询
 *key，查询表的键
 *value，查询表的值
 *referKey，关联的表
 *table2，关联的表2
 *referKey1，table2关联的键
 *tabel3，关联的表3
 *referKey2，table3关联键
 */
-(NSArray *)getInfoFromTable:(NSString *)table
                     withKey:(NSString *)key
                       value:(NSString *)value
                    referKey:(NSString *)referKey
                 leftOnTable:(NSString *)table2
                    referKey:(NSString *)referKey1
              andLeftOnTable:(NSString *)tabel3
                    referKey:(NSString *)referKey2;

/**三张表统一的关联查询
 *referKey，关联的表
 *table2，关联的表2
 *referKey1，table2关联的键
 *tabel3，关联的表3
 *referKey2，table3关联键
 */
-(NSArray *)getInfoFromTable:(NSString *)table
                    referKey:(NSString *)referKey
                 leftOnTable:(NSString *)table2
                    referKey:(NSString *)referKey1
              andLeftOnTable:(NSString *)tabel3
                    referKey:(NSString *)referKey2;

/**关联查询
 * butNotValue:需要排除的值
 */
-(NSArray *)getInfoFromTable:(NSString *)table leftOnTable:(NSString *)table1 referTableKey:(NSString *)key butNotValue:(NSString *)value tabelTwoKey:(NSString *)key1;

/**关联查询
 * butNotValue:特定查询的值
 */
-(NSArray *)getInfoFromTable:(NSString *)table leftOnTable:(NSString *)table1 referTableKey:(NSString *)key withValue:(NSString *)value tabelTwoKey:(NSString *)key1;

#pragma mark-
#pragma mark------update acitons------

-(BOOL)updateTable:(NSString *)table withDictionary:(NSDictionary *)dic referKey:(NSString *)referKey referValue:(NSString *)referValue;
#pragma mark-
#pragma mark------delete actions------
/**删除table表中的对应数据
 */
-(BOOL)deleteTable:(NSString *)table byDic:(NSDictionary *)dic;

/**删除table表中的对应数据
 */
-(BOOL)deleteTable:(NSString *)table byKey:(NSString *)key value:(NSString *)value;
/**删除table表中的所有数据
 */
-(BOOL)deleteTable:(NSString *)table;


#pragma mark-时间原因，直接写的和喜欢相关的一些数据库操作方法，以后在抽象--
/**
 *从本地获取未同步的喜欢数据
 */
-(NSArray *)getLocalUnSyncedDataList:(NSInteger)count withVideoInfo:(BOOL)withVideoInfo;
/**
 *根据时间获取喜欢的数据,count，是条数，
 */
-(NSArray *)getLocalLikeDataList:(NSInteger)count withVideoInfo:(BOOL)withVideoInfo withTime:(NSString *)lastUpTime;

/**
 *根据时间获取历史的数据，count，是条数
 */
-(NSArray *)getLocalHistoryDataList:(NSInteger)count withVideoInfo:(BOOL)withVideoInfo withTime:(NSString *)lastUpTime;



#pragma mark-表结构更改-------
/** 修改表结构的方法 \n
 *  tableName:需要修改的表的名字 \n
 *  void
 */
-(void)alterTable:(NSString *)tableName withDefaultAttribution:(NSDictionary *)attribution;


/**
 *  为表添加某个字段，这里没有找到可以添加多个字段的方法
 *
 *  @param colum 需要添加的字段名
 *  @param defaultValue 默认值
 *
 *  @return BOOL, alert add是否成功
 */
-(BOOL)alertVideoDetailTBWithColum:(NSString *)colum withDefaultValue:(NSString *)defaultValue;


/**
 *  是否包含了某个字段
 *
 *  @param colum 字段的名字，目前判断 is_magictv
 *
 *  @return BOOL, has or has't
 */
-(BOOL)videoDetailHasColum:(NSString *)colum;



@end
