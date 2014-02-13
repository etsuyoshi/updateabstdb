//
//  TextAnalysis.m
//  Newsab
//
//  Created by 遠藤 豪 on 2014/02/12.
//
//

#import "TextAnalysis.h"

@implementation TextAnalysis

NSString *strAllText;//原文
NSArray *arrSentence;//文章配列


NSArray *arrSemiSentence;//文節配列
NSArray *arrTerm;//単語(そのまま、重複あり)
NSMutableArray *arrNounUnique;//名詞(ユニークかつ出現頻度順番):Node型？
NSMutableArray *arrScoreNoun;//名詞の出現回数

NSMutableArray *arrStrToken;//文章区切り文字
NSMutableArray *arrStrSemiToken;//文節区切り文字
NSMutableArray *arrStrIgnor;//無視語句(文字)


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
         @" ",//半角スペース:実際にはこれで削除できなかったのでcomponentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
         @"　",//全角スペース
         @"\n",//改行
         nil];
        
        //通常の文字列分解で文章配列を作成
        arrSentence = [self getArrSentence];
        
        //確認
        for(int i = 0;i < [arrSentence count];i++){
            NSLog(@"sentence%d is %@", i, [arrSentence objectAtIndex:i]);
        }
        
        arrSemiSentence = [self getArrSemiSentenceFrom:arrSentence];
        
        
        //mecabを使って分解：重複ありの配列にする必要！！
//        NSArray *arrNodes = [self getUniqueNodeFromArray:arrSentence];
        NSArray *arrNodes = [self getDuplicateNodeFromArrSentence:arrSentence];
        for(int i =0;i < [arrNodes count];i++){
            NSLog(@"arrNodes%d is %@", i, ((Node *)arrNodes[i]).surface);
        }
        
        //重複ありの純粋な単語の分割のみ(集計していないので重複あり)
        arrTerm = [self getArrStrFromArrNode:arrNodes];
        
        //重複なしの単語の格納:並べ替えなしなのでtmpとした
        NSArray *arrNounUniqueTmp =
        [self getUniqueNodeFromDuplicate:arrNodes];
        for(int i =0;i < [arrNounUniqueTmp count];i++){
            NSLog(@"arrNounUnique%d is %@", i, ((Node *)arrNounUniqueTmp[i]).surface);
        }
        
        
        //出現頻度配列:Node型とNSString型の両方適用可能：並べ替えなしなのでtmpとした
        NSArray *arrScoreNounTmp = nil;
//        NSLog(@"before getEmerge, cout arrterm=%d", [arrTerm count]);//test
        arrScoreNounTmp = [self getEmergeNumAt:arrNounUniqueTmp
                                            in:arrTerm];
        for(int i = 0;i < [arrScoreNounTmp count];i++){
            NSLog(@"arrScoretmp%d is %@", i, arrScoreNounTmp[i]);
        }
        

        //重複なしの単語の格納:出現頻度順に並べ替え済 : ex.arrArg５番目が3番目の大きさならarrInd[2(=1の次)]=5)
        NSMutableArray *arrTmp =
        [self getArrayInOrder:(NSMutableArray *)arrScoreNounTmp
                        numOf:[arrScoreNounTmp count]];
        for(int i = 0;i < [arrTmp count];i++){
            NSLog(@"arrtmp%d is %@", i, arrTmp[i]);
        }
        
        arrNounUnique = [NSMutableArray array];//初期化
        for(int i =0;i < [arrTmp count];i++){
            [arrNounUnique
             addObject:
             arrNodes[[((NSString *)arrTmp[i]) integerValue]]
             ];
            
            
            //純粋にスコア順番にすれば良いが、念のため確認
            [arrScoreNoun
            addObject:
            arrScoreNounTmp[[arrTmp[i] integerValue]]
             ];
            
            NSLog(@"arrNou=%@, num=%d",
                  ((Node *)arrNounUnique[i]).surface,
                  [arrScoreNoun[i] integerValue]);//出現頻度を出したい
        }
        
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

-(NSArray *)getArrSemiSentenceFrom:(NSArray *)arrSentence{
    
    
    @autoreleasepool {
        //文節区切り配列
//        NSArray *arrStrText = [self getArrSentence];
        NSArray *arrStrText = arrSentence;
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

-(NSArray *)getArrStrFromArrNode:(NSArray *)nodes{
    NSMutableArray *arrReturn =
    [NSMutableArray array];
    
    //surfaceのみ取得
    for(int i =0;i < [nodes count];i++){
        [arrReturn addObject:((Node *)nodes[i]).surface];
    }
    return arrReturn;
}


//-(NSArray *)getUniqueNounFromSentence:(NSString *)strAllSentence{
//    //まずは文節を取得(文章配列でも同じ)
//    NSArray *arrSemiSentence =
//    [self getArrSemiSentenceFrom:
//     [NSArray arrayWithObjects:strAllSentence,
//     nil]
//     ];
//    
//    return [self getUniqueNodeFromDuplicate:arrSemiSentence];
//}

//文章配列から(重複ありの)名詞配列を取り出す
-(NSArray *)getDuplicateNodeFromArrSentence:(NSArray *)arrSentence{
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int noSen = 0;noSen < [arrSentence count];noSen++){
        //まずはシンプルに名詞を取り出す
        NSMutableArray *arrNounDuplicate =
        [self getNodeOnlyNoun:arrSentence[noSen]];//Node型で定義
        
        //取り出した名詞を一つずつ格納する
        for(int i =0;i < [arrNounDuplicate count];i++){
            [arrReturn addObject:arrNounDuplicate[i]];
        }
        
    }
    
    return arrReturn;
}

//既に文章が配列に格納されている状態ならその配列からユニークな名詞のみ取り出す：X
//重複ありのnodeからユニークノード配列を作成する
-(NSArray *)getUniqueNodeFromDuplicate:(NSArray *)arrNodeDup{
    
    //各文節に対して名詞のみ抽出して重複がないものを格納
    NSMutableArray *_arrNounUnique = [NSMutableArray array];
    for(int noSen = 0;noSen < [arrSentence count];noSen++){
        for(int noNounDup = 0;noNounDup < [arrNodeDup count];noNounDup++){
            if([_arrNounUnique count] == 0){//格納庫にものが入っていなければそのまま格納
                [_arrNounUnique addObject:arrNodeDup[noNounDup]];
            }else{//既に何かが入っていれば、格納庫の各要素と照合して最後まで一致しなければ格納
                
                int noNounUniq = 0;
                for(;noNounUniq < [_arrNounUnique count];noNounUniq++){
//                    NSLog(@"unique=%@,%d, duplicate=%@,%d",
//                          ((Node *)_arrNounUnique[noNounUniq]).surface,
//                          noNounUniq,
//                          ((Node *)arrNounDuplicate[noNounDup]).surface,
//                          noNounDup);
                    if([((Node *)_arrNounUnique[noNounUniq]).surface
                        isEqualToString:
                        ((Node *)arrNodeDup[noNounDup]).surface]){
                        break;//for-noNounUniq
                    }else if(noNounUniq == [_arrNounUnique count]-1){//最後まで検索して存在しなければ(ユニークなら)
                        //過去に格納されていないユニークなもののみ格納
//                        NSLog(@"「%@」は過去に格納されていないユニークな単語なので格納",
//                              ((Node *)arrNounDuplicate[noNounDup]).surface);
                        [_arrNounUnique addObject:
                         ((Node *)arrNodeDup[noNounDup])];
                    }
                }
            }
        }
    }
    
    
    //test:pring
    for(int i = 0;i < [_arrNounUnique count];i++){
        NSLog(@"arrUniqueNoun%d = %@", i, ((Node *)_arrNounUnique[i]).surface);
    }
    
    return _arrNounUnique;//型はNode
}


//arrArg配列に対し降順(多い順)にてnum個の要素を返す:ex. arrArg５番目が3番目の大きさならarrInd[2(=1の次)]=5)
-(NSMutableArray *)getArrayInOrder:(NSMutableArray *)arrArg numOf:(int)num{
    NSMutableArray *arrInd = [NSMutableArray array];
    NSMutableArray *arrVal = [NSMutableArray array];
    for(int i = 0;i < [arrArg count];i++){
        [arrInd addObject:[NSNumber numberWithInteger:i]];//インデックス配列
        [arrVal addObject:[NSNumber numberWithInteger:[arrArg[i] integerValue]]];//値配列
        //        NSLog(@"%dを追加", [arrVal[i] integerValue]);
    }
    
    //bubble sort start
    for(int i =0;i < [arrVal count];i++){
        for(int j = 1;j < [arrVal count] - i;j++){//j=1〜
            if([arrVal[j-1] integerValue] < [arrVal[j] integerValue]){
                //swap of arrArg
                id tmp = arrVal[j];
                arrVal[j] = arrVal[j-1];
                arrVal[j-1] = tmp;
                
                
                //swap of arrInd
                tmp = arrInd[j];
                arrInd[j] = arrInd[j-1];
                arrInd[j-1] = tmp;
            }
        }
    }
    //bubble sort complete
    
    //確認用
    //    for(int i = 0;i < [arrVal count];i++){
    //        NSLog(@"confirm %d : score is %d", [arrInd[i] integerValue], [arrVal[i] integerValue]);
    //    }
    
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int i = 0;i < num;i++){
        [arrReturn addObject:arrInd[i]];
    }
    return arrReturn;
    
    
}


//arrBigの中にarrUniqueの各要素が何回出現するか
-(NSArray *)getEmergeNumAt:(NSArray *)arrUnique in:(NSArray *)arrBig{
    NSMutableArray *arrReturn = [NSMutableArray array];
    
    
    for(int i = 0;i < [arrBig count];i++){
        [arrReturn addObject:[NSNumber numberWithInteger:0]];
    }
    
    for(int i =0;i < [arrBig count];i++){
        for(int j =0;j < [arrUnique count];j++){
//            NSLog(@"uniq = %@, big=%@", arrUnique[j], arrBig[i]);
            
            if([arrUnique[j]
                isKindOfClass:[Node class]]){
                
                //引数のarrUnique配列がNodeクラス前提
                if([((Node *)arrUnique[j]).surface
                    isEqualToString:arrBig[i]]){
                    
                    arrReturn[j] = [NSNumber numberWithInteger:
                                    [arrReturn[j] integerValue] + 1];
                }
            }else if([arrUnique[j]
                      isKindOfClass:[NSString class]]){
                
                //文字列クラスの前提
                if([arrUnique[j]
                    isEqualToString:arrBig[i]]){
                    arrReturn[j] = [NSNumber numberWithInteger:
                                    [arrReturn[j] integerValue] + 1];
                }
            }
        }
    }
    
    return arrReturn;
}

@end
