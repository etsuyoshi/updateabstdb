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



//categoryカラムを追加し、(textViewControllerでuploadボタン押下後に入力するような)更新プログラム(モジュール)を作成する
//phpファイル名称をキャピタル文字で区切る(例：FC2BlogManager.php)


//指定したカテゴリ(DBカラム名：category)内で、指定したID以下で最大のidを返す
+(NSString *)getLastIDFromDBUnder:(int)_idNo
                  category:(int)_category{
    
    
    //複合クエリだと遅いので、テスト用に試行錯誤によるid取得を試みる
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[NSString stringWithFormat:@"%d",_idNo] forKey:@"id"];
    [dict setObject:[NSString stringWithFormat:@"%d",_category] forKey:@"category"];
    
    NSData *data = [self formEncodedDataFromDictionary:dict];
    //    NSURL *url = [NSURL URLWithString:@"http://satoshi.upper.jp/user/shooting/getvalue.php"];
    //    NSURL *url = [NSURL URLWithString:@"http://test-lolipop-sql.lolipop.jp/junkai/managedb/getvalue.php"];
    NSURL *url = [NSURL URLWithString:@"http://newsdb.lolipop.jp/tmp/dir/test/getIdLastArticle.php"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setTimeoutInterval:60]; //タイムアウトを10秒に設定
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:data];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSLog(@"id取得中...");
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&response
                                                       error:&error];
    if(error){
        NSLog(@"同期通信失敗 at getLastIDFromDBUnder:error=%@", error);
        return nil;
    }else{

        NSLog(@"同期通信成功");
    }
    
    
    NSString* resultValue =
    [[NSString alloc]
     initWithData:result
     encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    
    //取得した文字列が整数値かどうか判定
//    NSCharacterSet *stringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *stringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:resultValue];
    NSCharacterSet *digitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    if ([digitCharacterSet isSupersetOfSet:stringCharacterSet]) {
        NSLog(@"数値であることを確認");
        
    } else {
        NSLog(@"数値ではないのでnilを返す：resultValue = %@", resultValue);
        return nil;
    }
    
    NSLog(@"getValueFromDB = %@", resultValue);
    
    //ない場合は(null)が返ってくるのでint変換すると0になる(ゼロはDB上で存在しないid)
    return resultValue;
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
        NSLog(@"同期通信失敗 at getValueFromDB");
        return nil;
    }else{
        NSLog(@"同期通信成功");
    }
    
    
    NSString* resultString = [[NSString alloc] initWithData:result
                                                   encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
    NSLog(@"resultString = %@", resultString);
    //改行の置換
    NSMutableArray *lines = [NSMutableArray array];
//    NSString *strLine = @"";
    [resultString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [lines addObject:line];
//        strLine = [NSString stringWithFormat:@"%@%@", strLine,line];
    }];
//    resultString = strLine;
    resultString = @"";//一旦初期化
    for(NSString *line in lines){
        if([resultString isEqualToString:@""]){
            resultString = line;
        }else{
            resultString = [NSString stringWithFormat:@"%@\n%@", resultString, line];
        }
        NSLog(@"line=%@", line);
    }
    
    NSLog(@"resultString = \"%@\" ", resultString);
    //シングルクオートやダブルクオートがある場合は誤動作回避のため置換
    if([resultString rangeOfString:@"\'"].location != NSNotFound){
        NSLog(@"シングルクオーテーションが存在：sql誤動作を回避するため大文字に変換します");
        resultString = [resultString stringByReplacingOccurrencesOfString:@"'"//半角
                                                               withString:@"’"];//全角
        
        NSLog(@"修正後newValue = %@", resultString);
    }
    
    if([resultString rangeOfString:@"\""].location != NSNotFound){
        NSLog(@"ダブルクオーテーションが存在：sql誤動作を回避するため大文字に変換します");
        resultString = [resultString stringByReplacingOccurrencesOfString:@""""//半角
                                                            withString:@"’"];//全角
        
        NSLog(@"修正後newValue = %@", resultString);
    }
    
    
    NSLog(@"getValueFromDB = %@", resultString);
    
    return resultString;
}



+(Boolean)updateValueToDB:(NSString *)user_id
                   column:(NSString *)column
                   newVal:(NSString *)newValue_arg{
    
    //他の値を更新しないように(念のため)チェック:abstforblogは更新すべきだよね？
    if(!([column isEqualToString:@"abstforblog"] ||
         [column isEqualToString:@"keywordblog"])){
        NSLog(@"column error %@", column);
        return false;
    }
    
    //文字列にクオーテーション「'」や「"」がある場合には全角’に置換する(sqlの文字列終了記号なので誤った実行がされてしまう)
    NSString *_newValue = newValue_arg;
    if([_newValue rangeOfString:@"\'"].location != NSNotFound){
        NSLog(@"シングルクオーテーションが存在：sql誤動作を回避するため大文字に変換します");
        _newValue = [newValue_arg stringByReplacingOccurrencesOfString:@"'"//半角
                                                            withString:@"’"];//全角
        
        NSLog(@"修正後newValue = %@", _newValue);
    }
    
    if([_newValue rangeOfString:@""""].location != NSNotFound){
        NSLog(@"ダブルクオーテーションが存在：sql誤動作を回避するため大文字に変換します");
        _newValue = [newValue_arg stringByReplacingOccurrencesOfString:@"\""//半角
                                                            withString:@"’"];//全角
        
        NSLog(@"修正後newValue = %@", _newValue);
    }
    
    
    
    
    //実行sql：$sql = "update dbusermanage SET $_POST[column] = '$_POST[value]' WHERE id = '$_POST[id]'";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:user_id forKey:@"id"];
    [dict setObject:column forKey:@"column"];
    [dict setObject:_newValue forKey:@"value"];
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
    
    
    NSString* resultString;
    
    if(error){
        NSLog(@"同期通信失敗 at updateValueToDB");
        return false;
    }else{
        NSLog(@"同期通信成功:user_id:%@,column:%@,value:%@",
              user_id, column, _newValue);
        
        
        resultString = [[NSString alloc]
                        initWithData:result
                        encoding:NSUTF8StringEncoding];//phpファイルのechoが返って来る
        
        //errorが発生しない場合でも発行した文字列によってはsqlによる更新が出来ていない場合がある
        //例えば、文字列の中にシングルクオーテーションがあってsqlが実行されない場合等(本ケースは対応済)
        if([resultString rangeOfString:@"You have an error in your SQL syntax"].location != NSNotFound){
            NSLog(@"シンタックスエラーが発生したので更新できませんでした(シングルクオートがあると生成できない可能性があります)。詳細：%@", resultString);
            return false;
        }
    }
    
    
    
    NSLog(@"DB-updated from DatabaseManage: php comment = %@", resultString);
    
    
    
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
    NSLog(@"str = \"%@\" from databasemanage.m", str);//ex.str = id=1&item=title
    NSLog(@"return data(NSData型) = \"%@\" ", data);//ex.return data = <69643d31 26697465 6d3d7469 746c65>
    return data;
}

@end
