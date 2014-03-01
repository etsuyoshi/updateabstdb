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

+(NSArray *)getRecordFromDBAll{
    //全部出すのは時間がかかるので最大100記事まで取得
    return [self getRecordFromDBFor:100];
}

+(NSArray *)getRecordFromDBFor:(int)num{
    @autoreleasepool {
        NSMutableArray *arrReturn = [NSMutableArray array];
        int _idNo = 1;
        NSDictionary *_dict;
        for(;_idNo < num;){//num個まで取得する
            _dict = [self getRecordFromDBAt:(int)_idNo];
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
+(NSDictionary *)getRecordFromDBAt:(int)idNo{
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
         @"abstforblog",
         @"ispostblog",
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


//20140228:やるべきこと
//TextViewControllerでアップロードボタンを押したときの挙動を実装->DatabaseManageクラスのupdateメソッドを使用
//動作チェック:getLastIDFromDBUnder:category<->http://newsdb.lolipop.jp/tmp/dir/test/getidlastarticle.php
//ViewControllerで記事読み込み(二重)ループ内でgetLastIDFrom...(上記メソッド)を実行
//phpファイル名称をキャピタル文字で区切る(例：FC2BlogManager.php)


//指定したカテゴリ(DBカラム名：category)内で、指定したID以下で最大のidを返す
+(int)getLastIDFromDBUnder:(int)_idNo
                  category:(int)_category{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[NSString stringWithFormat:@"%d",_idNo] forKey:@"id"];
    [dict setObject:[NSString stringWithFormat:@"%d",_category] forKey:@"category"];
    
    NSData *data = [self formEncodedDataFromDictionary:dict];
    //    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/getvalue.php"];
    //    NSURL *url = [NSURL URLWithString:@"http://test-lolipop-sql.lolipop.jp/junkai/managedb/getvalue.php"];
    NSURL *url = [NSURL URLWithString:@"http://newsdb.lolipop.jp/tmp/dir/test/getIdLastArticle.php"];
    
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
    
    
    NSString* resultValue =
    [[NSString alloc]
     initWithData:result
     encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    
    NSLog(@"getValueFromDB = %@", resultValue);
    
    //ない場合は(null)が返ってくるのでint変換すると0になる(ゼロはDB上で存在しないid)
    return [resultValue integerValue];
}


//指定したID(user_id)のレコードにおけるcolumnを取り出す
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



+(Boolean)updateValueToDB:(NSString *)user_id
                   column:(NSString *)column
                   newVal:(NSString *)newValue{
    //他の値を更新しないようにチェック
    if(!([column isEqualToString:@"abstforblog"] ||
         [column isEqualToString:@"ispostblog"])){
        NSLog(@"column error");
        return false;
    }
    
    //実行sql：$sql = "update dbusermanage SET $_POST[column] = '$_POST[value]' WHERE id = '$_POST[id]'";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:user_id forKey:@"id"];
    [dict setObject:column forKey:@"column"];
    [dict setObject:newValue forKey:@"value"];
    NSData *data = [self formEncodedDataFromDictionary:dict];
    //下記更新必要
//    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/updatevalue.php"];
    NSURL *url = [NSURL URLWithString:@"http://newsdb.lolipop.jp/tmp/dir/test/updatevaluenews.php"];
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
        return false;
    }else{
        NSLog(@"同期通信成功");
    }
    
    
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"userDB : updated : php comment = %@", resultString);
    
    
    
    return true;
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
