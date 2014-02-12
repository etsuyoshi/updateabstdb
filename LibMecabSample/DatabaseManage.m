//
//  DatabaseManage.m
//  NewsAbst
//
//  Created by 遠藤 豪 on 2014/02/08.
//  Copyright (c) 2014年 endo.news. All rights reserved.
//

#import "DatabaseManage.h"

@implementation DatabaseManage

//ラッパークラスを作成する

//DB名称を他クラスから指定しないようにする

+(NSArray *)getValueFromDB{
    //全部出すのは時間がかかるので最大100記事まで取得
    return [self getValueFromDBFor:100];
}

+(NSArray *)getValueFromDBFor:(int)num{
    @autoreleasepool {
        NSMutableArray *arrReturn = [NSMutableArray array];
        int _idNo = 1;
        NSDictionary *_dict;
        for(;_idNo < num;){//num個まで取得する
            _dict = [self getValueFromDBAt:(int)_idNo];
            if([[_dict objectForKey:@"id"] isEqual:nil]){
                break;
            }
            [arrReturn addObject:_dict];
            
            _idNo++;
        }
        
        //キー(カラム名)と値(DB値)が格納された辞書が格納された配列を返す
        return arrReturn;
    }
    
    
}
+(NSDictionary *)getValueFromDBAt:(int)idNo{
    @autoreleasepool {
        //カラム配列定義
        NSArray *arrColumn =
        [NSArray arrayWithObjects:
         @"id",
         @"datetime",
         @"blog_id",
         @"title",
         @"url",
         @"body_with_tags",
         @"body",
         @"hatebu",
         @"saveddate",
         nil];
        
        //カラムに対応するだけループしてデータを取り出す
        NSMutableArray *arrReturned = [NSMutableArray array];
        for(id columnName in arrColumn){
            //id１のみ取り出す
            [arrReturned addObject:
             [self getValueFromDB:[NSString stringWithFormat:@"%d", idNo]
                           column:columnName]];
        }
    
        //column名をキー値、文字列を値とする辞書を返す(具体的なキーは上記arrColumn)
        NSDictionary *_dict =
        [NSDictionary dictionaryWithObjects:arrReturned forKeys:arrColumn];
        
        return _dict;
    }
}
//
+(NSString *)getValueFromDB:(NSString *)user_id column:(NSString *)column{
    
    //phpファイルの以下の変数にそれぞれ格納される：$sql = "select $_POST[item] from dbusermanage where id = '$_POST[id]'";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:user_id forKey:@"id"];
    [dict setObject:column forKey:@"item"];
    NSData *data = [self formEncodedDataFromDictionary:dict];
    //    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/getvalue.php"];
//    NSURL *url = [NSURL URLWithString:@"http://test-lolipop-sql.lolipop.jp/junkai/managedb/getvalue.php"];
    NSURL *url = [NSURL URLWithString:@"http://newsdb.lolipop.jp/db/getvalue/getvalue.php"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:data];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&response
                                                       error:&error];
    if(error){
        NSLog(@"同期通信失敗");
        return nil;
    }else{
        NSLog(@"同期通信成功");
    }
    
    
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"getValueFromDB = %@", resultString);
    
    return resultString;
}

+(NSData *)formEncodedDataFromDictionary:(NSDictionary *)dict
{
    NSMutableString *str;
    
    str = [NSMutableString stringWithCapacity:0];
    
    // 「キー=値」のペアを「&」で結合して列挙する
    // キーと値はどちらもURLエンコードを行い、スペースは「+」に置き換える
    for (NSString __strong *key in [dict allKeys])
    {
        //        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *value = [dict objectForKey:key];
        
        // スペースを「+」に置き換える
        key = [key stringByReplacingOccurrencesOfString:@" "
                                             withString:@"+"];
        value = [value stringByReplacingOccurrencesOfString:@" "
                                                 withString:@"+"];
        
        
        // URLエンコードを行う
        key = [key stringByAddingPercentEscapesUsingEncoding:
               NSUTF8StringEncoding];
        value = [value stringByAddingPercentEscapesUsingEncoding:
                 NSUTF8StringEncoding];
        
        // 文字列を連結する
        if ([str length] > 0)
        {
            [str appendString:@"&"];
        }
        
        [str appendFormat:@"%@=%@", key, value];
        //        [pool drain];
    }
    
    // 作成した文字列をUTF-8で符号化する
    NSData *data;
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"str = %@", str);//ex.str = id=1&item=title
    NSLog(@"return data = %@", data);//ex.return data = <69643d31 26697465 6d3d7469 746c65>
    return data;
}

@end
