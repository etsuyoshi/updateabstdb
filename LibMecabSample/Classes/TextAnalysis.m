//
//  TextAnalysis.m
//  Newsab
//
//  Created by 遠藤 豪 on 2014/02/12.
//
//

#import "TextAnalysis.h"

//重要語句及び重要文章の判定のためのパラメータ
#define PERCENTAGE_UPPERSIDE_IMPORTANT_SENTENCE 20//重要であると定義すべき文章の上位パーセンテージ位置
#define PERCENTAGE_UPPERCOUNTER_IMPORTANT_TERM 20//重要であると定義すべき単語の上位パーセンテージカウンター
//以下は使ってない
#define PERCENTAGE_UPPERSIDE_IMPORTANT_TERM 20//重要であると定義すべき単語の上位パーセンテージ位置：上位何パーセントを重要と判断するか

@implementation TextAnalysis

NSString *strAllText;//原文
NSString *strTitle;//タイトル
NSArray *arrSentence;//文章配列


NSArray *arrSemiSentence;//文節配列
NSArray *arrTerm;//単語(そのまま、重複あり)

NSMutableArray *arrStrToken;//文章区切り文字
NSMutableArray *arrStrSemiToken;//文節区切り文字
NSMutableArray *arrStrIgnor;//無視語句(文字)
NSMutableArray *arrNumber;

NSMutableArray *arrTFIDF;

//最も重要な以下２配列
NSMutableArray *arrNounUnique;//名詞(ユニークかつ出現頻度順番):Node型
NSMutableArray *arrScoreNoun;//名詞の出現回数
NSMutableArray *arrImportantSentence;//重要文格納配列
NSMutableArray *arrImportantNode;//重要語句(Node形式)

//selfフィールドにしても(selfが初期化されていないので)init内で初期化できずtextAnalysis.arrImportantNode等のような形で呼べない
//@synthesize arrImportantSentence;
//@synthesize arrImportantNode;


-(id)initWithText:(NSString *)_strAllText{
    
    self = [self initWithText:_strAllText withTitle:nil];
    
    return self;
}


-(id)initWithText:(NSString *)_strAllText
        withTitle:(NSString *)_strTitle{
    
    self = [super init];
    
//    self.arrImportantNode = [NSMutableArray array];//重要語句格納配列の初期化
//    self.arrImportantSentence = [NSMutableArray array];//重要文章格納配列の初期化

    
    if(self) {
        //原文初期化
        strAllText = _strAllText;
        
        //タイトル初期化
        strTitle = _strTitle;
        
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
        
        arrNumber =
        [NSMutableArray arrayWithObjects:
         @"１",@"２",@"３",@"４",@"５",@"６",@"７",@"８",@"９",@"０",
         @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",nil];
        
        //通常の文字列分解で文章配列を作成
        arrSentence = [self getArrSentence];
        
        //確認
        for(int i = 0;i < [arrSentence count];i++){
            NSLog(@"sentence%d is %@", i, [arrSentence objectAtIndex:i]);
        }
        
        arrSemiSentence = [self getArrSemiSentenceFrom:arrSentence];
        
        
        //mecabを使って分解：重複ありの配列にする必要！！
        NSArray *arrNodes = [self getDuplicateNodeFromArrSentence:arrSentence];
//        for(int i =0;i < [arrNodes count];i++){
//            NSLog(@"arrNodes%d is %@", i, ((Node *)arrNodes[i]).surface);
//        }
        
        
        
        
        //重複ありの純粋な単語の分割のみ(集計していないので重複あり)
        arrTerm = [self getArrStrFromArrNode:arrNodes];
        
        //重複なしの単語の格納:並べ替えなしなのでtmpとした
        NSArray *arrNounUniqueTmp =
        [self getUniqueNodeFromDuplicate:arrNodes];
        for(int i =0;i < [arrNounUniqueTmp count];i++){
//            NSLog(@"arrNounUnique%d is %@",
//                  i, ((Node *)arrNounUniqueTmp[i]).surface);
        }
        
        
        //出現頻度配列:Node型とNSString型の両方適用可能：並べ替えなしなのでtmpとした
        NSArray *arrScoreNounTmp = nil;
//        NSLog(@"before getEmerge, cout arrterm=%d", [arrTerm count]);//test
        arrScoreNounTmp = [self getEmergeNumAt:arrNounUniqueTmp
                                            in:arrTerm];
//        for(int i = 0;i < [arrScoreNounTmp count];i++){
//            NSLog(@"arrScoretmp%d is %@", i, arrScoreNounTmp[i]);
//        }
        
//        NSLog(@"arrNou")
        

        //重複なしの単語の格納:出現頻度順に並べ替え済
        //ex.arrArg５番目が3番目の大きさならarrInd[2(=1の次)]=5)
        NSMutableArray *arrTmp =
        [self getArrayInOrder:(NSMutableArray *)arrScoreNounTmp
                        numOf:[arrScoreNounTmp count]];
//        for(int i = 0;i < [arrTmp count];i++){
//            NSLog(@"arrtmp%d is %@", i, arrTmp[i]);
//        }
        
//        NSLog(@"arrtmp count=%d, arrscoreNounTmp=%d",
//              [arrTmp count], [arrScoreNounTmp count]);
        
        //初期化：降順(多い順)に格納する配列
        arrScoreNoun = [NSMutableArray array];//スコア配列
        arrNounUnique = [NSMutableArray array];//格納するユニーク名詞配列
        for(int i =0;i < MIN([arrNounUniqueTmp count], [arrTmp count]);i++){
            //ユニークかつ降順に名詞のみをNode型として配列作成
            [arrNounUnique
             addObject:
             arrNounUniqueTmp[[arrTmp[i] integerValue]]
             ];
            
            //スコア配列が降順(大きい順番)になっているか確認するため
            [arrScoreNoun
            addObject:
            arrScoreNounTmp[[arrTmp[i] integerValue]]
             ];
            
            //単語と出現頻度
//            NSLog(@"arrNou=%@, num=%d",
//                  ((Node *)arrNounUnique[i]).surface,
//                  [((NSString *)arrScoreNoun[i]) integerValue]);
        }
//        NSLog(@"重複チェック");
        
        //重複チェック
        for(int i =0;i < [arrNounUnique count]-1;i++){
            for(int j =i+1;j < [arrNounUnique count];j++){
                if([((Node *)arrNounUnique[i]).surface
                   isEqualToString:
                   ((Node *)arrNounUnique[j]).surface]){
                    
                    NSLog(@"break! at %d %d, %@", i, j, ((Node *)arrNounUnique[i]).surface);
                    break;
                }
            }
            //最後のループになったら
            if(i == [arrNounUnique count]-2){
                NSLog(@"unique check complete");
                
                
            }
        }
        
        
        
        
    }
    
    //arrSentenceとarrNounUnique計算前提
//    arrTFIDF = [self getTfIdf];
//    for(int j =0;j < [arrSentence count];j++){
//        NSLog(@"doc of %d 's tfidf=%f",
//              j, [arrTFIDF[j] doubleValue]);
//    }
    
    
    [self setImportantSentence];//arrImportantSentence,Nodeに格納
    
    NSLog(@"complete initialization");
    return self;
}

-(NSArray *)getImportantSentence{
    
    return arrImportantSentence;
}

-(NSArray *)getImportantNode{
    
    return arrImportantNode;
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
    Node *node;
    NSString *strForAppend = @"";//連結用文字列
    int numOfAppend = 0;//連結した文字の個数(連結していない状態をゼロ)
    for(int i =0;i < [arrNodes count];i++){
        numOfAppend = 0;
        node = arrNodes[i];
        if([[node.features objectAtIndex:1] isEqualToString:@"非自立"]){
            //こと、ため、の(名詞格)は非自立の名詞であるが、arrNounとしては不要
            continue;
        }else if([node.partOfSpeech isEqualToString:@"名詞"]){
            
            
            //数字である場合
            if([self isInArrayAt:arrNumber value:node.surface]){//数字であるかどうか確認する
                for(int j = 0;j < [arrNumber count];j++){//数字配列の全てを検索する
                    if([node.surface isEqualToString:arrNumber[j]]){//数字を特定する
                        strForAppend = node.surface;//これから接続する数字を格納する
                        //前が数字である可能性はない(数字であれば既にこのループにひっかかっているため)
                        //後ろのみを探索:次「以降」のnodeを検索して数字がないか確認
                        int k = i + 1;
                        for(;k < [arrNodes count];k++){//次のindex:iを検索していく
                            Node *nodeTmp = arrNodes[k];
                            //以下、後ろにある単語に数字が続かないか検索していく
                            if([self isInArrayAt:arrNumber value:nodeTmp.surface]){//まずは検索
                                for(int L = 0;L < [arrNumber count];L++){//全ての数字との一致検索
                                    if([nodeTmp.surface isEqualToString:arrNumber[L]]){
                                        strForAppend = [NSString stringWithFormat:@"%@%@",
                                                     strForAppend,arrNumber[L]];
                                        numOfAppend++;
                                        break;//for-L
                                    }
                                }//for-L
                            }else{//後ろの文字が数字ではない場合
                                
                                //後ろの文字(index:k)のが接尾語である場合、
                                //ここのブロックでは数字の後に続くことになるので単位である可能性があるので接続する
                                //ex.2001年、２月、５日等
                                NSArray *arrFeatures = nodeTmp.features;
                                
                                //arrFeaturesの中に入る配列の例
                                //例：名詞,接尾,・・・
                                //例：名詞,固有名詞,人名,姓,*,*,伊藤,イトウ,イトー
                                if([arrFeatures[1] isEqualToString:@"接尾"]){
                                    //数字と接尾語を連結
                                    strForAppend = [NSString stringWithFormat:@"%@%@",
                                                 strForAppend, nodeTmp.surface];
                                    k++;//次のノードを先取りしたので、次はi = k+1番目から調べていく
                                    numOfAppend++;
                                    
                                }
                                
                                
                                //(数字の後ろが接尾語である場合に接続したら)終了
                                break;//for-k
                            }
                        }//for-k
                        
                        //kはi+1からスタートしているためループ実行判定条件はkがi+2以上であるということ
                        if(k > i + 1){//「上記for-kループが一回以上実行された」＝「arrNodes配列に数字が含まれていた」
                            //次のiループで続きは(数字ではない)k番目のnodeから実行させる
                            i=k-1;//重要！
                            
                            //一回ループが回った＝連続した数字は連結済(※離れた場所に数字がある可能性は残されたまま)
                            break;//for-j:数字チェックループの終了
                        }
                        
                    }//if:node==arrayNumber
                }//for-j
            }//if:number
            else if([[node.features objectAtIndex:1] isEqualToString:@"固有名詞"] ||
                    [[node.features objectAtIndex:1] isEqualToString:@"一般"]
                    ){//ターゲットの品詞分類１が固有名詞等の場合
                strForAppend = node.surface;//これから接続する固有名詞(または接尾辞)を格納する
                //次も固有名詞であれば連結された固有名詞である可能性が高い
//                int k = i + 1;
                Node *nodeTmp = nil;
                for(int k = i + 1;k < [arrNodes count];k++){
                    nodeTmp = arrNodes[k];
                    //固有(又は一般)名詞の後に固有(もしくは一般)名詞が来た場合は連結する
                    if([[nodeTmp.features objectAtIndex:1] isEqualToString:@"固有名詞"] ||
                       [[nodeTmp.features objectAtIndex:1] isEqualToString:@"一般"]){
                        strForAppend = [NSString stringWithFormat:@"%@%@",
                                        strForAppend,nodeTmp.surface];
                        
                        NSLog(@"%@に%@を連結=>%@", node.surface, nodeTmp.surface, strForAppend);
                        numOfAppend++;
                        
                    }else{
                        
                        NSLog(@"固有名詞「%@」の後に「%@(%@)」",
                              strForAppend,
                              ((Node *)nodeTmp).surface,
                              [((Node *)nodeTmp).features objectAtIndex:1]);
                        
                        //if:ターゲット(固有名詞)の後に接尾辞の出現
                        
                        if([[nodeTmp.features objectAtIndex:1] isEqualToString:@"接尾"]){
//                        if([[((Node *)arrNodes[i+1]).features objectAtIndex:1] isEqualToString:@"接尾"]){
                            NSLog(@"%@に%@を連結", strForAppend, nodeTmp.surface);
                            strForAppend = [NSString stringWithFormat:@"%@%@",
                                            strForAppend,nodeTmp.surface];
                            
                            k++;
                            numOfAppend++;
                            
                            
                            
                        }//if:ターゲット(固有名詞)の後に接尾辞の出現
                        
                        
                        
                        
                        //kはi+1からスタートしているためループ実行判定条件はkがi+2以上であるということ
                        if(k > i + 1){//「上記for-kループが一回以上実行された」＝「arrNodes配列に数字が含まれていた」
                            //続きは(数字ではない)k番目のnodeから実行させる
                            i=k-1;//重要！
                            
                            //一回ループが回った＝連続した固有名詞(接尾辞)は連結済
                            
                        }
                        
                        break;//for-k
                    }//if:ターゲット(固有名詞)の後に固有名詞の連続出現
                    
                }//for-k
                
            }//if:ターゲットが固有名詞である場合
        //        Node *node = arrayNodes[i];
        //        NSLog(@"%@ : 品詞=%@", node.surface, node.partOfSpeech);
        
            if([strForAppend isEqualToString:@""]){
                [arrReturn addObject:arrNodes[i]];
            }else{
                NSLog(@"arrReturnに%@を追加", strForAppend);
                Node *oldNode = arrNodes[i];
                Node *newNode = [Node new];
                newNode.surface = strForAppend;
                newNode.feature = oldNode.feature;//格納の仕方がよくわからないので連結された中の最後のnodeのfeatureを格納
                [arrReturn addObject:newNode];
                strForAppend = @"";//初期化
            }
        }//if-名詞
    }//for-i
    
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
//    for(int i = 0;i < [_arrNounUnique count];i++){
//        NSLog(@"arrUniqueNoun%d = %@", i, ((Node *)_arrNounUnique[i]).surface);
//    }
    
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



//重要文arrImportantSentenceと重要語句の抽出arrImportantNode
//重要文抽出方法
//    ①タイトルに含まれている単語を含む文章は本文の要約をしている可能性が高い
//    ②上の方にある文章ほどその重要度が高い
//    ③文章全体のキーワードをカウントした時、特に上位に来るワードの重要さが大きい
//    ④tfidfが大きい文書
//使用する材料
//arrSentence:全文配列
//arrNounUnique:ユニーク名詞配列(in descent order:多い順)
//arrScoreNoun:arrNounUnique配列に対応する単語の出現頻度配列(in descent order)
//strTitle:タイトル文字列
-(void)setImportantSentence{
    
    NSLog(@"start setimportantsentence");
    //加算点数
    //文章に対して加算するスコア
    int scoreAddingToSentence = 1;
    //Nodeに対して加算されるスコア
    int scoreAddingToNode = 1;
    
    NSMutableArray *_arrScoreSentence = [NSMutableArray array];
    NSMutableArray *_arrScoreNode = [NSMutableArray array];
    for(int i = 0;i < [arrSentence count];i++){
        [_arrScoreSentence addObject:[NSNumber numberWithInteger:0]];
    }
    for(int i =0;i < [arrNounUnique count];i++){
        [_arrScoreNode addObject:[NSNumber numberWithInteger:0]];
    }
    
    
    //文章及び加点への加点開始①〜④
    
    //①タイトルの包含
    //タイトルに含まれる語句に加点
    //「タイトルに含まれる語句」を含む文章に加点
    for(int j = 0;j < [arrNounUnique count];j++){
        Node *node = (Node *)arrNounUnique[j];
        NSRange rangeTitle = [strTitle rangeOfString:node.surface];//Node検索
        if(rangeTitle.location != NSNotFound) {//Nodeが含まれていれば
            //単語に加点
            _arrScoreNode[j] =
            [NSNumber numberWithInteger:
             [_arrScoreNode[j] integerValue] + scoreAddingToNode];
            
            for(int i =0;i < [arrSentence count];i++){//全ての文章に対して
                NSRange rangeSentence = [arrSentence[i] rangeOfString:node.surface];//Node検索
                if(rangeSentence.location != NSNotFound) {//Nodeが含まれていれば
                    //文章への加点
                    _arrScoreSentence[i] =
                    [NSNumber numberWithInteger:
                     [_arrScoreSentence[i] integerValue] + scoreAddingToSentence];
                }
            }
        }
    }
    
    
    //②上の方にある文章ほどその重要度が高い
    //単語配列と文章配列への加点
    for(int j = 0;j < [arrNounUnique count];j++){
        Node *node = (Node *)arrNounUnique[j];
        for(int i = 0;i < [arrSentence count] * PERCENTAGE_UPPERSIDE_IMPORTANT_SENTENCE/100;i++){
            NSRange range = [arrSentence[i] rangeOfString:node.surface];//Node検索
            if(range.location != NSNotFound) {//Nodeが含まれていれば
                //単語への加点
                _arrScoreNode[j] =
                [NSNumber numberWithInteger:
                 [_arrScoreNode[j] integerValue] + scoreAddingToNode];
                //文章への加点
                _arrScoreSentence[i] =
                [NSNumber numberWithInteger:
                 [_arrScoreSentence[i] integerValue] + scoreAddingToSentence];
            }
        }
    }
    
    
    //③文章全体のキーワードをカウントした時、特に（カウンター)上位に来るワードの重要さが大きい
    for (int j = 0; j < [arrNounUnique count] * PERCENTAGE_UPPERCOUNTER_IMPORTANT_TERM/100; j++){
        Node *node = (Node *)arrNounUnique[j];
        for(int i = 0;i < [arrSentence count];i++){
            NSRange range = [arrSentence[i] rangeOfString:node.surface];//Node検索
            if(range.location != NSNotFound) {//Nodeが含まれていれば
                //単語への加点
                _arrScoreNode[j] =
                [NSNumber numberWithInteger:
                 [_arrScoreNode[j] integerValue] + scoreAddingToNode];
                //文章への加点
                _arrScoreSentence[i] =
                [NSNumber numberWithInteger:
                 [_arrScoreSentence[i] integerValue] + scoreAddingToSentence];
            }
        }
    }
    
    
    //④tfidfの設定
    NSMutableArray *arrTFIDF =
    [self getTfIdfWithArrSentence:(NSMutableArray *)arrSentence
                withArrNounUnique:(NSMutableArray *)arrNounUnique];
    for(int j = 0;j < [arrTFIDF count];j++){
//        NSLog(@"tfidf%d : %@ is %f",
//              j ,arrSentence[j], [arrTFIDF[j] doubleValue]);
        if([arrTFIDF[j] doubleValue] > 1.5f){//tfidf is bigger than 1.5f
            _arrScoreSentence[j] =
            [NSNumber numberWithInteger:
             [_arrScoreSentence[j] integerValue] + scoreAddingToSentence];
        }
    }
    
    
    //文章、及びキーワードへの加点終了
    
    int threasholdForSentence = 3;
    int threasholdForNode = 2;
    
    NSLog(@"重要文章の表示:%d点以上", threasholdForSentence);
    for(int i = 0;i < [arrSentence count];i++){
        if([_arrScoreSentence[i] integerValue] >= threasholdForSentence){
            NSLog(@"score=%d:index%d:%@",
                  [_arrScoreSentence[i] integerValue],
                  i,
                  arrSentence[i]);
            
            //重要文章の格納:順番通りになっていないが、必ずしも上位語句では順位自体が重要とは限らない
            [arrImportantSentence
             addObject:arrSentence[i]];
        }
    }
    
    
    NSLog(@"重要語句の表示:%d点以上", threasholdForNode);
    for(int j = 0;j < [arrNounUnique count];j++){
        if([_arrScoreNode[j] integerValue] >= threasholdForNode){
            NSLog(@"score=%d:index:%d:%@(品詞分類１:%@,品詞分類２:%@)",
                  [_arrScoreNode[j] integerValue],
                  j,
                  ((Node *)arrNounUnique[j]).surface,
                  [((Node *)arrNounUnique[j]).features objectAtIndex:0],
                  [((Node *)arrNounUnique[j]).features objectAtIndex:1]);
            
            //[[nodeTmp.features objectAtIndex:1] isEqualToString:@"固有名詞"]){
            
            //重要語句の格納:順番通りになっていない
            [arrImportantNode
             addObject:arrNounUnique[j]];
        }
    }
    
    NSLog(@"complete setting important sentence & node");
    
}

//valueがarrayの中に含まれているか(valueがarrayの一つの要素として完全一致するかどうか)
-(BOOL)isInArrayAt:(NSMutableArray *)array value:(id)value{
    for(int i = 0 ;i < [array count];i++){
        if([array[i] isEqual:value]){
            return YES;
        }
    }
    return NO;
}


-(NSMutableArray *)getTfIdfWithArrSentence:(NSMutableArray *)_arrSentenceArg
                         withArrNounUnique:(NSMutableArray *)_arrNounUniqueArg{
    
    /*
     tf[i,j]=nij/sigm[nkj]k;短い文書の中に表れる単語の重要度を上げる
     *nij=単語iの文書jにおける出現頻度
     *idf[i]=log(|D|/|{d:d<ti}|=総ドキュメント数/単語iが含まれる文章数
     *重複した単語を調べても意味がないので単語は_arrNounUniqueArgを使用
     */
    int D = [_arrSentenceArg count];//idf分子
    NSMutableArray *_arrTFIDF = [NSMutableArray array];//tfidf:num=[_arrSentenceArg count]
    NSMutableArray *_arrTF = [NSMutableArray array];//tf:num=[_arrNounUniqueArg count]x[_arrSentenceArg count]
    
    NSMutableArray *_arrIDF = [NSMutableArray array];//idf:num=[_arrNounUniqueArg count]
    
    
    NSString *_term;//検索したい単語
    for(int i = 0;i < [_arrNounUniqueArg count];i++){//全ての単語に対して
        int _d_i = 0;//単語iのidf値の分母
        _term = ((Node *)_arrNounUniqueArg[i]).surface;
        
        //idf[j]配列の計算
        for(int noSen = 0;noSen < [_arrSentenceArg count];noSen++){//全ての文章に対して
            if([(NSString *)_arrSentenceArg[noSen] rangeOfString:_term].location
               != NSNotFound){//単語iが文章noSenに含まれていれば
                _d_i++;
                
                //test
                NSLog(@"単語%d「%@」は文章%d:「%@」に含まれる＝＞score=%d",
                      i,_term,noSen,_arrSentenceArg[noSen],_d_i);
            }
        }
        
        //_d_iは単語iを含む文章数なので必ずDより小さくなる
//        NSLog(@"error at %d is _d_i=%d,D=%d => log=%f",
//              i, _d_i, D, log(D/_d_i));
        
        
        _arrIDF[i] = [NSNumber numberWithDouble:log(D/_d_i)];
        //[_arr_di addObject:[NSNumber numberWithFloat:log(D/_score)]];
        
        //完了
//        NSLog(@"単語%d「%@」のidf値は%f",
//              i,_term,[_arrIDF[i] floatValue]);
        
        //単語iのための文章の数の要素数を持つ配列：nijの計算用
        NSMutableArray *_arrTmp = [NSMutableArray array];
        //tf[i,j]の計算:単語iが文章jに含まれる個数
        for(int j = 0;j < [_arrSentenceArg count];j++){
            
            //http://stackoverflow.com/questions/2166809/number-of-occurrences-of-a-substring-in-an-nsstring
            NSUInteger count = 0, length = [_arrSentenceArg[j] length];
            NSRange range = NSMakeRange(0, length);
            
            while(range.location != NSNotFound){
                range =
                [_arrSentenceArg[j] rangeOfString: _term
                                      options:0
                                        range:range];
                if(range.location != NSNotFound){
                    //次のループに向けてrangeを修正
                    range =
                    NSMakeRange(range.location + range.length,
                                length - (range.location + range.length));
                    count++;//カウンター
                }
            }
            
            [_arrTmp addObject:[NSNumber numberWithInt:count]];
            
        }//for-j
        
        //_arrTF:文章jに存在する単語iの個数を格納した配列
        [_arrTF addObject:_arrTmp];//正確にはまだtf値を計算していない:下の複数ブロックで分母計算＆規格化
    }//for-i
    
    //nkj：nijの分母の計算
    //文章の個数だけある配列の定義
    NSMutableArray *_arrDenominatorOfTf = [NSMutableArray array];
    //_arrTF配列を横方向(_arrSentenceArgと同じ)、縦方向に見ていく
    for(int j =0;j < [_arrSentenceArg count];j++){//_arrTfを横方向に見ていく
        //その文章の中に全ての単語が幾つ含まれるか(規格化するための分母)
        int _score = 0;
        for(int i = 0;i < [_arrTF count];i++){//_arrTFを縦方向に見ていく
            _score += [[_arrTF[i] objectAtIndex:j] integerValue];
        }
        
        //各文章に格納する
        [_arrDenominatorOfTf addObject:[NSNumber numberWithInt:_score]];
    }
    
    //上記nkjで規格化(_arrDenominatorOfTfで除算)して
    for(int j = 0;j < [_arrSentenceArg count];j++){
        double _denominator = [_arrDenominatorOfTf[j] doubleValue];
        for(int i = 0;i < [_arrNounUniqueArg count];i++){
            _arrTF[i][j] =
            [NSNumber numberWithDouble:
             ([_arrTF[i][j] doubleValue]/_denominator)
             ];
        }
    }
    
    //tfidf値の計算
    for(int noSen = 0;noSen < [_arrSentenceArg count];noSen++){//全文章に対して
        double _tfidf = 0;
        for(int noTerm = 0;noTerm < [_arrNounUniqueArg count];noTerm++){//全単語に対して
            _tfidf +=
            [_arrTF[noTerm][noSen] doubleValue] * [_arrIDF[noTerm] doubleValue];
            
        }
        
        //tfidf値を格納
        [_arrTFIDF addObject:[NSNumber numberWithDouble:_tfidf]];
        
        
    }
    
    return _arrTFIDF;
}




@end
