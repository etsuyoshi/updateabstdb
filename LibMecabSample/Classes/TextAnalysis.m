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

NSArray *arrStrToken;

-(id)initWithText:(NSString *)_strAllText{
    
    self = [super init];
    if(self) {
        //原文初期化
        strAllText = _strAllText;
        
        //トークン初期化
        arrStrToken =
        [NSArray arrayWithObjects:
         @"\n",
         @"。",
         @"「",
         @"」",
         nil];
        
        arrSentence = [self getArrSentence];
        
    }
    
    return self;
}

-(NSArray *)stringTokenizerFor:(NSString *)str by:(NSString *)token{
    return [str componentsSeparatedByString:token];
}

-(NSArray *)arrayTokenizerFor:(NSString *)str complexBy:(NSArray *)tokens{
//    NSMutableArray *arrReturn = [NSMutableArray array];
    NSArray *arrReturn = [NSArray array];
    
    for(int noToken = 0; noToken < [tokens count];noToken++){
        NSString *token = tokens[noToken];
        NSArray *arrTmp = [self stringTokenizerFor:str by:token];
//        if([arrTmp count] > 1){//２個以上に分割されたら
        if(noToken < [tokens count] - 1){//最後のトークンでなければ
            for(int j =0; j < [arrTmp count];j++){
                //次のトークンを見る
                NSRange range = [arrTmp[j] rangeOfString:tokens[noToken+1]];
                if (range.location == NSNotFound) {
                    NSArray *array = [self nexttoken];
                }else{
                    NSArray *array = [self nexttoken+1];
                }
            }
        }else{
            arrReturn = [arrReturn arrayByAddingObjectsFromArray:arrTmp];
        }
        
        //当該トークンを排除した残りの配列で自分を回して返り値をarrReturnに格納していく
        
        
//        NSArray *arrTmp = [str componentsSeparatedByString:tokens[noToken]];
//        for(int i = 0;i < [arrTmp count];i++){
//            NSRange range = [arrTmp[i] rangeOfString:@"token"];
//        }
    }
    
    return nil;
}

-(NSArray *)getArrSentence{
    @autoreleasepool {
        
        //予め指定したトークンに応じて単語に分解
        NSMutableArray *_arrSentence = [NSMutableArray array];//空配列
        
        NSArray *strArrTmp = [NSArray array];
        //トークンの数だけ分割する
        for(int i = 0;i < [arrStrToken count];i++){
            strArrTmp = [self stringTokenizerFor:strAllText
                                              by:arrStrToken[i]];
            //各要素の中に更にトークンが含まれていないか確認
            for(int j = 0;j < [strArrTmp count];j++){
                NSRange range = [strArrTmp[j] rangeOfString:@"cd"];
                if (range.location == NSNotFound) {
                    NSLog(@"検索対象が存在しない場合の処理");
                }else{
                    
                }
            }
        }
    }
    
    //トークンが文字単体の場合は以下で複数指定できるが、\n等は\とnで分けられてしまう
//    NSCharacterSet *spr = [NSCharacterSet characterSetWithCharactersInString:@"\n。"];//複数文字列を指定
//    arrSentence = [strReturnBody componentsSeparatedByCharactersInSet:spr];
    //以下トークン分割はcomponentsSeparatedByCharactersInSet:で複数指定可能
    //    arrSentence = [strReturnBody componentsSeparatedByString:@"。"];//句点で分割
    
    //参考：「」で囲われてる文字列は。で区切らない方が良い。むしろ、鍵カッコを区切り文字として、中の文章は一つのとして扱う
    for(int i = 0;i < [arrSentence count];i++){
        NSLog(@"sentence%d=%@", i, arrSentence[i]);
    }
    
    //mecabによる形態素解析：別メソッド
//    NSArray *arrayNodes = [mecab parseToNodeWithString:arrSentence[0]];//テキストをメカブで形態素解析してnodes(UITableCell)に格納
//    for(int i = 0 ;i < [arrayNodes count];i++){
//        Node *node = arrayNodes[i];
//        NSLog(@"%@ : 品詞=%@", node.surface, node.partOfSpeech);
//    }
    
    return _arrSentence;
}

@end
