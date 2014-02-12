//
//  TextAnalysis.m
//  Newsab
//
//  Created by 遠藤 豪 on 2014/02/12.
//
//

#import "TextAnalysis.h"

@implementation TextAnalysis

NSString *strAllText;
NSArray *arrSentence;

NSMutableArray *arrStrToken;

-(id)initWithText:(NSString *)_strAllText{
    
    self = [super init];
    if(self) {
        //原文初期化
        strAllText = _strAllText;
        
        //トークン初期化
        arrStrToken =
        [NSMutableArray arrayWithObjects:
         @"\n",
         @"。",
         @"「",
         @"」",
         @" ",//半角スペース
         @"　",//全角スペース
         nil];
        
        arrSentence = [self getArrSentence];
        
    }
    
    return self;
}

- (NSArray *)getEachLine:(NSString*)string
{
    //http://hmdt.jp/cocoaProg/Foundation/NSString/NSString.html
    NSMutableArray *arrStrEachLine = [NSMutableArray array];
    NSString* parsedString;
    NSRange range, subrange;
    int length;
    
    length = [string length];
    range = NSMakeRange(0, length);
    int noLine = 0;
    while(range.length > 0) {
        //range で指定した範囲を含む、最小の行を取得
        //引き数のrangeに最初の一文字(0,0)を指定すると、一番最初の行を表すNSRangeを返す
        subrange = [string lineRangeForRange:
                    NSMakeRange(range.location, 0)];
        parsedString = [string substringWithRange:subrange];
        
        NSLog(@"line%d:%@",noLine, parsedString);
//        printf("line: %s¥n", [parsedString cString]);
        [arrStrEachLine addObject:parsedString];
        
        range.location = NSMaxRange(subrange);
        range.length -= subrange.length;
        noLine++;
    }
    
    return arrStrEachLine;
}

-(NSArray *)stringTokenizerFor:(NSString *)str by:(NSString *)token{
    return [str componentsSeparatedByString:token];
}


//methodology
//1.文字列を分解する
//2.配列を分解する
-(NSArray *)stringTokenizerFor:(NSString *)str
                    complexBy:(NSMutableArray *)tokens{
    
    NSLog(@"arrayTokenizerFor%@", str);
//    NSMutableArray *arrReturn = [NSMutableArray array];
    NSMutableArray *arrReturn = [NSMutableArray array];
//    NSMutableArray *_arrTokens = [NSMutableArray array];
//    for(int i = 0;i < [tokens count];i++){
//        [_arrTokens addObject:tokens[i]];
//    }
    
//    for(int noToken = 0; noToken < [tokens count];noToken++){
//        NSString *token = tokens[noToken];
    NSString *token = tokens[0];
    NSLog(@"token=%@", token);
    
    
    NSArray *arrTmp = [self stringTokenizerFor:str
                                            by:token];
    NSLog(@"str=%@=>devideTo%d", str, [arrTmp count]);
//    for(int i = 0;i < [arrTmp count];i++){
//        if([arrTmp[i] length] == 0){
//            
//        }
//    }
    
    for(NSString *_str in arrTmp){
        NSLog(@"_str=%@", _str);
    }
    
    //それ以外のトークン
//    [tokens removeObject:token];
    
    
    //それ以外のトークンで分割する
    if([tokens count] > 0){//まだトークンが残っている場合、それらのトークンで分解する
        for(int noTerm = 0;noTerm < [arrTmp count];noTerm++){
            if([((NSString *)arrTmp[noTerm]) length] > 0){
                //分割された文字に対して次のトークンを適用する
                
                //再帰構造
                NSArray *tmp = [self arrayTokenizerFor:arrTmp[noTerm]
                                             complexBy:tokens];
                
                
                if([tmp count] == 1){
                    NSLog(@"tmp0=%@", tmp[0]);//test
                    [arrReturn addObject:tmp[0]];
                    
                    for(int i = 0;i < [arrReturn count];i++){//test
                        NSLog(@"arrReturn%d = %@", i, arrReturn[i]);
                    }
                }
            }
        }
    }
    
    return arrReturn;
}

//methodology2
-(NSMutableArray *)arrayTokenizerFor:(NSMutableArray *)arrStr
                    complexBy:(NSMutableArray *)tokens{
    
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int i =0;i < [arrStr count];i++){//全ての文章に対して
        [arrReturn addObject:arrStr[i]];
    }
    
//    for(int i =0;i < [arrReturn count];i++){
    int i = 0;
    for(;i<[arrReturn count];){
//        NSString *strTmp = (NSString *)arrReturn[i];
        NSLog(@"arrReturn%d = strTmp=%@, length=%d",i, arrReturn[i], [arrReturn[i] length]);
        if([arrReturn[i] length]>0){//文字列が空でなければ
            NSLog(@"arrReturn count=%d", [arrReturn count]);
            for(int j = 0;j < [tokens count];){//全てのトークンに対して
                NSRange range = [arrReturn[i] rangeOfString:tokens[j]];//トークン検索
                NSLog(@"arrReturn%d=%@, tokens%d is %@, range=%d",
                      i,
                      arrReturn[i],
                      j,
                      tokens[j],
                      range.location);
                if(range.location != NSNotFound) {//トークンが含まれていれば
                    //文字を当該トークンで分割した配列を作成
                    NSLog(@"aaa");
                    NSArray *arrTokenized =
                    [arrReturn[i] componentsSeparatedByString:tokens[j]];
                    
                    NSLog(@"bbb");
                    [tokens removeObject:tokens[j]];
                    //もしくは
//                    NSMutableArray *_arrTokens = [NSMutableArray array];
//                    for(int _j = 0; _j < [tokens count];_j++){
//                        if(_j != j){
//                            [_arrTokens addObject:tokens[_j]];
//                        }
//                    }
                    NSLog(@"ccc");
                    if([arrTokenized count] != 1){//分割できた場合
                        //test
                        NSLog(@"remove%d = %@", i, arrReturn[i]);
                        
                        
//                        NSArray
                        [arrReturn removeObjectAtIndex:i];
                        
                        
                        //ケツからinsertすることで順番通りにさせる
                        for(int L = [arrTokenized count]-1;L >= 0;L--){
                            if([arrTokenized[L] length] != 0){
                                [arrReturn insertObject:arrTokenized[L]
                                                atIndex:i];
                                
                                NSLog(@"index%d is removed and insert %@",i,  arrReturn[i]);
                            }
                        }
                        
                        
                    }
                    
                    //確認
                    for(int L = 0;L < [arrReturn count];L++){
                        NSLog(@"test:arrReturn%d is %@", L, arrReturn[L]);
                    }
//                    
//                    //全ての分割された文字列に対して
//                    for(int k = 0;k < [arrTokenized count];k++){
//                        
//                        
//                        [arrReturn addObject:arrTokenized[k]];
//                        NSLog(@"arrTokenized%d=%@", k, arrTokenized[k]);
//                    }
//                    //分割された文字に対して、それ以外のトークンで分解
//                    
//                    
//                    
//                    //それ以外のトークンを作成
//                    
//                    
//                    
//                    NSMutableArray *_arrReturn =
//                    [self arrayTokenizerFor:arrReturn
//                                  complexBy:_arrTokens];
                    
                }else{//トークンが含まれていなければ
                    //do nothing
                    //当該文字は既に全てのトークンを含んでいないのでarrReturnに追加
//                    [arrReturn addObject:strTmp];
                }
            }
        }
    }
    
    
    for(int i =0;i < [arrReturn count];i++){
        NSLog(@"arrReturn%d is %@", i, arrReturn[i]);
    }
    
    return nil;
}

-(NSArray *)getArrSentence{
    @autoreleasepool {
        
        
//        NSArray *arrStrEachLine = [self getEachLine:strAllText];
//        NSLog(@"complete getEachLine");
        
        //test
        NSString *str = @"b11a22c33";
        NSMutableArray *arraytest =
        [NSMutableArray arrayWithObjects:
         @"a",
         @"b",
         @"c",
         nil];
        [self arrayTokenizerFor:[NSMutableArray arrayWithObjects:str,nil]
                      complexBy:arraytest];
//        [self arrayTokenizerFor:str
//                      complexBy:arraytest];
//        [self arrayTokenizerFor:arrStrEachLine[0]
//                      complexBy:arrStrToken];
        
        
        
        
//        return arrStrEachLine;
        
//        for(int i =0;i < [arrStrEachLine count];i++){
////            NSString* string = @"abc, def gh,ijk";
//            NSEnumerator* enumerator = [(NSString *)arrStrEachLine[i]
//                                        tokenize:@", "];
//            id token;
//            
//            while((token = [enumerator nextObject])) {
//                NSLog(@"%@", token);
//            }
//        }
        
        
        
        
        
        
        
        //予め指定したトークンに応じて単語に分解
//        NSMutableArray *_arrSentence = [NSMutableArray array];//空配列
//        
//        NSArray *strArrTmp = [NSArray array];
//        //トークンの数だけ分割する
//        for(int i = 0;i < [arrStrToken count];i++){
//            strArrTmp = [self stringTokenizerFor:strAllText
//                                              by:arrStrToken[i]];
//            //各要素の中に更にトークンが含まれていないか確認
//            for(int j = 0;j < [strArrTmp count];j++){
//                NSRange range = [strArrTmp[j] rangeOfString:@"cd"];
//                if (range.location == NSNotFound) {
//                    NSLog(@"検索対象が存在しない場合の処理");
//                }else{
//                    
//                }
//            }
//        }
    }
    
    //トークンが文字単体の場合は以下で複数指定できるが、\n等は\とnで分けられてしまう
//    NSCharacterSet *spr = [NSCharacterSet characterSetWithCharactersInString:@"\n。"];//複数文字列を指定
//    arrSentence = [strReturnBody componentsSeparatedByCharactersInSet:spr];
    //以下トークン分割はcomponentsSeparatedByCharactersInSet:で複数指定可能
    //    arrSentence = [strReturnBody componentsSeparatedByString:@"。"];//句点で分割
    
    //参考：「」で囲われてる文字列は。で区切らない方が良い。むしろ、鍵カッコを区切り文字として、中の文章は一つのとして扱う
//    for(int i = 0;i < [arrSentence count];i++){
//        NSLog(@"sentence%d=%@", i, arrSentence[i]);
//    }
    
    //mecabによる形態素解析：別メソッド
//    NSArray *arrayNodes = [mecab parseToNodeWithString:arrSentence[0]];//テキストをメカブで形態素解析してnodes(UITableCell)に格納
//    for(int i = 0 ;i < [arrayNodes count];i++){
//        Node *node = arrayNodes[i];
//        NSLog(@"%@ : 品詞=%@", node.surface, node.partOfSpeech);
//    }
    
    return arrSentence;
}

@end
