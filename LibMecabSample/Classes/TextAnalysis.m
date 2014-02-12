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

NSMutableArray *arrStrToken;//文章区切り
NSMutableArray *arrStrSemiToken;//文節区切り
NSMutableArray *arrStrIgnor;//無視語句


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
         nil];
        
        arrStrSemiToken =
        [NSMutableArray arrayWithObjects:
         @"、",
         nil];
        
        //無視語
        arrStrIgnor =
        [NSMutableArray arrayWithObjects:
         @" ",//半角スペース
         @"　",//全角スペース
         nil];
        
        arrSentence = [self getArrSentence];
        
    }
    
    return self;
}

- (NSMutableArray *)getEachLine:(NSString*)string
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


-(NSMutableArray *)arrayTokenizerFor:(NSMutableArray *)arrStr
                    complexBy:(NSMutableArray *)tokens{
    
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int i =0;i < [arrStr count];i++){//全ての文章に対して
        [arrReturn addObject:arrStr[i]];
    }
    
    if([arrReturn count] == 0 ||
       [tokens count] == 0){
        return nil;
    }
    
    for(int j = 0;j < [tokens count];j++){//全てのトークンに対して
        for(int k = 0;k < [arrReturn count];k++){
            NSRange range = [arrReturn[k] rangeOfString:tokens[j]];//トークン検索
            if(range.location != NSNotFound) {//トークンが含まれていれば
                //文字を当該トークンで分割した配列を作成
                NSArray *arrTokenized =
                [arrReturn[k] componentsSeparatedByString:tokens[j]];
                
                
                if([arrTokenized count] != 1){//分割できた場合
                    //その要素を削除して、代わりに分割された値を格納する
                    
                    //まずは削除
                    [arrReturn removeObjectAtIndex:k];
                    
                    
                    //ケツからinsertすることで順番通りにさせる
                    for(int L = [arrTokenized count]-1;L >= 0;L--){
                        if([arrTokenized[L] length] != 0){
                            [arrReturn insertObject:arrTokenized[L]
                                            atIndex:k];
                        }
                    }
                    
                    
                }
                
            }//if(range.location != NSNotFound) {//トークンが含まれていれば
        }
    }//for-j
    
    
    
    return arrReturn;
}

-(NSArray *)getArrSentence{
    @autoreleasepool {
        
        
        //行毎に抽出
        NSMutableArray *strEachLine =
        [self getEachLine:strAllText];
        
        for(int i = 0;i < [strEachLine count];i++){
            //空のものを削除(半角、全角スペースはarrayTokenizerによって削除される)
            if([strEachLine[i] length] == 0){
                [strEachLine removeObjectAtIndex:i];
            }
        }
        
        strEachLine =
        [self arrayTokenizerFor:strEachLine
                      complexBy:arrStrToken];
        
        
//        
//        
//        //test
//        NSString *str = @"ba11ab32cb2c3c3";
//        NSMutableArray *arraytest =
//        [NSMutableArray arrayWithObjects:
//         @"ab",
//         @"b",
//         @"c",
//         nil];
//        NSMutableArray *arr =
//        [self arrayTokenizerFor:[NSMutableArray arrayWithObjects:str,nil]
//                      complexBy:arraytest];
        
        
        
        
        for(int i = 0;i < [strEachLine count];i++){
            NSLog(@"strEachLine%d is 「%@」", i, strEachLine[i]);
        }
        
        
        
        
        
        
        
        
        
        
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
