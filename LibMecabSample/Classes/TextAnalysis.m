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
         nil];
        
        arrStrSemiToken =
        [NSMutableArray arrayWithObjects:
         @"、",
         @"「",
         @"」",
         nil];
        
        //無視語
        arrStrIgnor =
        [NSMutableArray arrayWithObjects:
         @" ",//半角スペース
         @"　",//全角スペース
         @"\n",//改行
         nil];
        
        //通常の文字列分解
        arrSentence = [self getArrSentence];
        for(int i = 0;i < [arrSentence count];i++){
            NSLog(@"sentence%d is %@", i, [arrSentence objectAtIndex:i]);
        }
        
        
        //mecabを使って分解
        NSArray *arrNodes = [self getUniqueNounFromArray:arrSentence];
        for(int i =0;i < [arrNodes count];i++){
            NSLog(@"noun%d is %@", i, ((Node *)arrNodes[i]).surface);
        }
        
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
        
        //文章の最後の文字が改行になっているので削除する
        parsedString = [parsedString substringToIndex:[parsedString length]-1];
        if([parsedString length] != 0){
//            NSLog(@"line%d[%d]:[%@]",
//                  noLine,[parsedString length], parsedString);
            [arrStrEachLine addObject:parsedString];
        }
        
        range.location = NSMaxRange(subrange);
        range.length -= subrange.length;
        noLine++;
    }
    
    return arrStrEachLine;
}

-(NSMutableArray *)textTokenizerFor:(NSString *)str
                          complexBy:(NSMutableArray *)tokens{
    
    return [self arrayTokenizerFor:
            [NSMutableArray arrayWithObjects:str, nil]
                         complexBy:tokens];
    
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
        
        //全角、半角の空白、タブ等はreplaceできないので以下のように接続する方法を採用
        
        //行毎に抽出して配列格納
        NSMutableArray *strEachLine =
        [self getEachLine:strAllText];
        
        for(int i = 0;i < [strEachLine count];i++){
            //無視語を削除
            for(int j =0;j < [arrStrIgnor count];j++){
//                NSRange range =
//                [strEachLine[i] rangeOfString:arrStrIgnor[j]];//トークン検索
//                if(range.location != NSNotFound) {//トークンが含まれている場合
//                    NSLog(@"replace %@ at %d",
//                          arrStrIgnor[j],
//                          range.location);
//                }
                [strEachLine[i]
                 stringByReplacingOccurrencesOfString:arrStrIgnor[j]
                 withString:@""];
            }
            
            
            //半角、全角スペースはarrayTokenizerによって削除されないようなので、ここで削除
            NSArray* words =
            [strEachLine[i]
             componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
            strEachLine[i] = [words componentsJoinedByString:@""];
            
            
            
            //無視語を削除した結果、空のものを削除
            if([strEachLine[i] length] == 0){
                [strEachLine removeObjectAtIndex:i];
            }
            
        }
        
        
        //トークンで分解したものを配列に格納
        NSArray *arrStrText =
        [self arrayTokenizerFor:strEachLine
                      complexBy:arrStrToken];
        
//        for(int i =0;i < [arrStrText count];i++){//test
//            NSLog(@"文章%d=[%@]", i, arrStrText[i]);
//            
//        }
        
        
        return arrStrText;
        
    }//autoreleasepool
}

-(NSArray *)getArrSemiSentence{
    
    
    @autoreleasepool {
        //文節区切り配列
        NSArray *arrStrText = [self getArrSentence];
        NSMutableArray *arrSemiText = [NSMutableArray array];
        for(int i = 0;i < [arrStrText count];i++){
            //各文章を文節に区切る
            NSArray *strTmp =
            [self textTokenizerFor:arrStrText[i]
                         complexBy:arrStrSemiToken];
            //区切った文節を格納する
            for(int j = 0;j < [strTmp count];j++){
                [arrSemiText addObject:strTmp[j]];
            }
        }
        
        return  arrSemiText;//宣言したのはmutableだがarrayで返す
    }//autoreleasepool
}

//mecabによる形態素解析
//文章単体から品詞に区切られたnode配列を出力
-(NSArray *)getNode:(NSString *)string{
    Mecab *mecab = [Mecab new];
    NSArray *arrNodes = [mecab parseToNodeWithString:string];
    
    return arrNodes;
}

-(NSMutableArray *)getNodeOnlyNoun:(NSString *)string{
    
    NSMutableArray *arrReturn = [NSMutableArray array];
    NSArray *arrNodes = [self getNode:string];
    for(int i =0;i < [arrNodes count];i++){
        
        //        Node *node = arrayNodes[i];
        //        NSLog(@"%@ : 品詞=%@", node.surface, node.partOfSpeech);
        if([((Node *)arrNodes[i]).partOfSpeech isEqualToString:@"名詞"])
            [arrReturn addObject:arrNodes[i]];
    }
    
    return arrReturn;
}


-(NSArray *)getUniqueNounFromSentence:(NSString *)strAllSentence{
    //まずは文節を取得(文章配列でも同じ)
    NSArray *arrSemiSentence = [self getArrSemiSentence];
    
    return [self getUniqueNounFromArray:arrSemiSentence];
}

//既に文章が配列に格納されている状態ならその配列からユニークな名詞のみ取り出す
-(NSArray *)getUniqueNounFromArray:(NSArray *)arrSentence{
    
    //各文節に対して名詞のみ抽出して重複がないものを格納
    NSMutableArray *arrNounUnique = [NSMutableArray array];
    for(int noSen = 0;noSen < [arrSentence count];noSen++){
        //まずはシンプルに名詞を取り出す
        NSMutableArray *arrNounDuplicate =
        [self getNodeOnlyNoun:arrSentence[noSen]];
        
        
        
        for(int noNounDup = 0;noNounDup < [arrNounDuplicate count];noNounDup++){
            if([arrNounUnique count] == 0){//格納庫にものが入っていなければそのまま格納
                [arrNounUnique addObject:arrNounDuplicate[noNounDup]];
            }else{//既に何かが入っていれば、格納庫の各要素と照合して最後まで一致しなければ格納
                
                int noNounUniq = 0;
                for(;noNounUniq < [arrNounUnique count];noNounUniq++){
//                    NSLog(@"unique?=%@, duplicate=%@",
//                          ((Node *)arrNounUnique[noNounUniq]).surface,
//                          ((Node *)arrNounDuplicate[noNounDup]).surface);
                    if([((Node *)arrNounUnique[noNounUniq]).surface
                        isEqualToString:
                        ((Node *)arrNounDuplicate[noNounDup]).surface]){
                        break;//for-noNounUniq
                    }else if(noNounUniq == [arrNounUnique count]-1){//最後まで検索して存在しなければ(ユニークなら)
                        //過去に格納されていないユニークなもののみ格納
                        [arrNounUnique addObject:arrNounDuplicate[noNounDup]];
                    }
                }
            }
        }
    }
    
    
    //test:pring
//    for(int i = 0;i < [arrNounUnique count];i++){
//        NSLog(@"arrUniqueNoun%d = %@", i, ((Node *)arrNounUnique[i]).surface);
//    }
    
    return arrNounUnique;//型はNode
}

@end
