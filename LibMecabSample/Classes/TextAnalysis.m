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

NSMutableArray *arrImportantNode;//重要語句(Node形式)
NSMutableArray *arrImportantSentence;//重要文格納配列
NSMutableArray *arrAbstractSentence;
NSMutableArray *arrAllTokenNode;//重要語句、副詞、助詞、形容詞、動詞等全ての品詞を格納

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
        
        
        //テスト用
        
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
//        for(int i = 0;i < [arrSentence count];i++){
//            NSLog(@"sentence%d is %@", i, [arrSentence objectAtIndex:i]);
//        }
        
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
//        NSMutableArray *arrTmp =
//        [self getArrayInOrder:(NSMutableArray *)arrScoreNounTmp
//                        numOf:[arrScoreNounTmp count]];
////        for(int i = 0;i < [arrTmp count];i++){
////            NSLog(@"arrtmp%d is %@", i, arrTmp[i]);
////        }
//        
////        NSLog(@"arrtmp count=%d, arrscoreNounTmp=%d",
////              [arrTmp count], [arrScoreNounTmp count]);
//        
//        //初期化：降順(多い順)に格納する配列
//        arrScoreNoun = [NSMutableArray array];//スコア配列
//        arrNounUnique = [NSMutableArray array];//格納するユニーク名詞配列
//        for(int i =0;i < MIN([arrNounUniqueTmp count], [arrTmp count]);i++){
//            //ユニークかつ降順に名詞のみをNode型として配列作成
//            [arrNounUnique
//             addObject:
//             arrNounUniqueTmp[[arrTmp[i] integerValue]]
//             ];
//            
//            //スコア配列が降順(大きい順番)になっているか確認するため
//            [arrScoreNoun
//            addObject:
//            arrScoreNounTmp[[arrTmp[i] integerValue]]
//             ];
//            
//            //単語と出現頻度
////            NSLog(@"arrNou=%@, num=%d",
////                  ((Node *)arrNounUnique[i]).surface,
////                  [((NSString *)arrScoreNoun[i]) integerValue]);
//        }
//        NSLog(@"重複チェック");
        
        
        //テスト用
//        NSLog(@"加点終了");
//        
//        NSLog(@"並べ替え開始");
//        
//        for(int i = 0;i < [arrNounUniqueTmp count];i++){
//            NSLog(@"sentence%d(%d)=%@", i, [arrScoreNounTmp[i] integerValue], ((Node *)arrNounUniqueTmp[i]).surface);
//        }

        
        //名詞配列をarrScoreによる降順に
        arrNounUnique = [self getOrderedArrayFor:arrNounUniqueTmp
                                       withScore:arrScoreNounTmp];
        
        //scoreを降順に
        arrScoreNoun = [self getOrderedArrayFor:arrScoreNounTmp
                                      withScore:arrScoreNounTmp];
        
        
//        NSLog(@"並べ替え完了");
//        for(int i = 0;i < [arrNounUniqueTmp count];i++){
//            NSLog(@"sentence%d(%d)=%@", i, [arrScoreNoun[i] integerValue], ((Node *)arrNounUnique[i]).surface);
//        }

        
        //重複チェック
        for(int i =0;i < [arrNounUnique count]-1;i++){
            for(int j =i+1;j < [arrNounUnique count];j++){
                if([((Node *)arrNounUnique[i]).surface
                   isEqualToString:
                   ((Node *)arrNounUnique[j]).surface]){
                    
//                    NSLog(@"break! at %d %d, %@", i, j, ((Node *)arrNounUnique[i]).surface);
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
    NSLog(@"get important sentence count=%d,",
          [arrImportantSentence count]);
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

/*
 *引数のstringをnodeに変更
 *以下の条件で名詞のみをノード型のまま配列に格納して返す
 *まず接尾語である場合はその前の単語に連結する※
 *「非自立」名詞は無視
 *「数」名詞である場合は、その後に数字が続く場合は連結
 *
 
 
 *返り値は重要語を格納した配列
 
 
 *旧アルゴリズムによるエラー=>改善済
 *数字の後の数字が連結されていない
 *文末に接尾語がある場合、直前の名詞に連結されていない
 
 
 *(参考)node特性
 *node.features:ノードの特性を配列で取得
 *node.partOfSpeech:ノードの第一品詞をstring型で取得
 
 
 
 *createAbstメソッド内において人名や地名、時間データを取得する必要ー＞氏名や日付など、トークンを連結する必要がある：[self getNodeOnlyNoun]と同じことを二回やる必要ないのでそこでarrAllTermに単語を連結することにする
 
 
 */
-(NSMutableArray *)getNodeOnlyNoun:(NSString *)string{
    @autoreleasepool {//この中で生成した変数については制御がメソッドの外に移ると削除される:arrAllTokenについては既に外で定義されているので削除されない
        
    
        
        
        NSMutableArray *arrReturn = [NSMutableArray array];
        NSArray *arrNodes = [self getNode:string];
        Node *node;
        NSString *strForAppend = @"";//連結用文字列
        
        
        //全てのノードに対してサーチ
        
        //サーチ対象のノードをstring型に変更してstrForAppendに格納
        
        //数字(：名詞)の場合はその後に品詞を調べて数字かどうか調査
        //＝＞数字である場合は連結してstrForAppendに格納
        //。。。繰り返す
        
        //その後に続くのが接尾語である場合は直前の名詞(かどうか判定)を連結
        
            
            
            
        for(int i = 0;i < [arrNodes count];i++){//次の単語を探すのは連結した単語の数に応じて。
            node = arrNodes[i];
            
            
            TermObject *termObject = [[TermObject alloc]init];
            [termObject setNode:node];
            
            strForAppend = node.surface;
            
            int original_i = i;
            Node *newNode = node;//[Node new];
            if([node.features[0] isEqualToString:@"名詞"]){

                //格納済のその後の名詞を探索していく
                for(int j = 1;i+j < [arrNodes count];j++){//iが最後ならこのループは実行されない
                    Node *nodeNext = arrNodes[original_i + j];
                    
                    //test
                    NSLog(@"now:%@(%@) next:%@(%@)",
                          strForAppend,node.features[1],
                          nodeNext.surface, nodeNext.features[1]);
                    
                    //今の数字が数字でその後も数字ならば連結
//                    if([node.features[1] isEqualToString:@"数"]){//今の単語が数字で
//    //                    NSLog(@"次の品詞は数字");
//                        if([nodeNext.features[1] isEqualToString:@"数"]){//次の単語も数字である場合
//                            strForAppend = [NSString stringWithFormat:@"%@%@",
//                                            strForAppend,nodeNext.surface];
//                            
//                            [termObject setNode:nodeNext];
//                            
//                            i++;
//                            continue;//次の単語j+1の探査へ
//                        }
//                    }
//                    
//                    
//                    //今の名詞が一般名詞、固有名詞、サ変接続、形容動詞語幹で、次の同じような名詞の場合は連結(住民投票、投資行動)
//                    if([node.features[1] isEqualToString:@"一般"]||
//                       [node.features[1] isEqualToString:@"固有名詞"]||
//                       [node.features[1] isEqualToString:@"サ変接続"]||
//                       [node.features[1] isEqualToString:@"形容動詞語幹"]
//                       ){//今の単語が一般名詞、もしくは固有名詞の場合
//                        
//                        if([nodeNext.features[1] isEqualToString:@"一般"]||
//                           [nodeNext.features[1] isEqualToString:@"固有名詞"]||
//                           [nodeNext.features[1] isEqualToString:@"サ変接続"]||
//                           [nodeNext.features[1] isEqualToString:@"形容動詞語幹"]
//                           ){//次の単語も一般名詞か固有名詞の場合
//                            strForAppend = [NSString stringWithFormat:@"%@%@",
//                                            strForAppend,nodeNext.surface];
//                            
//                            [termObject setNode:nodeNext];
//                            
//                            i++;
//                            continue;//次の単語j+1の探査へ
//                        }
//                    }
//                    
//
//                    //次の単語の品詞が接尾語である場合はどんな名詞に対しても連結
//                    if([nodeNext.features[1] isEqualToString:@"接尾"]){
////                    NSLog(@"次の品詞は接続詞");
//                        strForAppend = [NSString stringWithFormat:@"%@%@",
//                                        strForAppend,nodeNext.surface];
//                        
//                        [termObject setNode:nodeNext];
//                        
//                        i++;
//                        break;//次の単語を探査せずに強制的に連結(格納)する
//                    }
                    
                    //名詞の次に名詞が来たら全て連結させる
                    if([nodeNext.features[0] isEqualToString:@"名詞"]){
                        //                    NSLog(@"次の品詞は接続詞");
                        strForAppend = [NSString stringWithFormat:@"%@%@",
                                        strForAppend,nodeNext.surface];
                        
                        [termObject setNode:nodeNext];
                        
                        i++;
                        if([nodeNext.features[1] isEqualToString:@"接尾"]){
                            break;//次の単語を探査せずに強制的に連結(格納)する
                        }else{
                            continue;//次の単語j+1の探査して名詞なら連結していく
                        }
                    }

                    
                    //上記サブifの全てに当てはまらない場合はbreakしてarrReturnに格納
                    break;//for-j
                    
                }//for-j
                
                
                //非自立型以外の名詞(で始まる単語)は全て格納
                if(![node.features[1] isEqualToString:@"非自立"]){
//            NSLog(@"arrReturnに『%@(%@)』を追加", strForAppend, node.features[1]);
                    Node *oldNode = node;
                    
                    newNode.surface = strForAppend;
                    newNode.feature = oldNode.feature;//格納の仕方がよくわからないので連結された中の最後のnodeのfeatureを格納
                    [arrReturn addObject:newNode];
                }
                
            }//if-noun
            
            //名詞は上記で作成したものを採用するとして名詞以外も全て格納:最終的にはTermObjectに全てのデータを格納する
//            NSLog(@"arrAllTokenNode.count =  %d", [arrAllTokenNode count]);
//            for(int cnt = 0;cnt < [termObject.partOfSpeechSubtypes1 count];cnt++){
//                NSLog(@"newTerm %d = %@(%@)", cnt , termObject.surface,termObject.partOfSpeechSubtypes1[cnt]);
//                NSLog(@"newTerm %d = %@(%@)", cnt , termObject.surface,termObject.partOfSpeechSubtypes2[cnt]);
//                NSLog(@"newTerm %d = %@(%@)", cnt , termObject.surface,termObject.partOfSpeechSubtypes3[cnt]);
//            }
            [arrAllTokenNode addObject:termObject];//createAbstにおいて品詞等から５w１hデータを取得する
            
        }//for-i
        
        
        
        return arrReturn;
    
        
        
    }//autopoolrelease
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
    
    arrAllTokenNode = [NSMutableArray array];
    
    
    for(int noSen = 0;noSen < [arrSentence count];noSen++){
        //まずはシンプルに名詞を取り出す(同時にarrAllTokenNodeを作成している)
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
    
//    NSLog(@"start setimportantsentence");
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
    
    //テスト用出力
//    NSLog(@"加点終了");
//    
//    NSLog(@"並べ替え開始");
//    
//    for(int i = 0;i < [_arrScoreSentence count];i++){
//        NSLog(@"sentence%d(%d)=%@", i, [_arrScoreSentence[i] integerValue], arrSentence[i]);
//    }
    
    
    //arrSentenceをスコアで並べ替え
    arrSentence = [self getOrderedArrayFor:arrSentence
                                 withScore:_arrScoreSentence];
    //スコアを自分自身で降順に並べ替え
    _arrScoreSentence = [self getOrderedArrayFor:_arrScoreSentence
                                       withScore:_arrScoreSentence];
    
    
//    NSLog(@"並べ替え完了");
//    for(int i = 0;i < [_arrScoreSentence count];i++){
//        NSLog(@"sentence%d(%d)=%@", i, [_arrScoreSentence[i] integerValue], arrSentence[i]);
//    }
    
    
    
    //閾値で下位スコアを切り捨て
    int threasholdForSentence = 0;//5;
    int threasholdForNode = 0;//2;
    
    
    arrImportantNode = [NSMutableArray array];
    arrImportantSentence = [NSMutableArray array];
    arrAbstractSentence = [NSMutableArray array];
    
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
            
            
            
            //重要語句を作成するために一旦、停止
            //文章から要約文を生成してarrAbstractSentenceに格納
            [arrAbstractSentence
             addObject:[self createAbstract:arrSentence[i]]];
            
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


/*
 *目標：文中から重要でない句を見つけ、それを除外しつつ重要な文章を自然な形で終わるように整形する
 *自然な文章とは5w1hがあること
 */
-(NSString *)createAbstract:(NSString *)strOrigin{
    
//    for(int i = 0;i < [arrAllTokenNode count];i++){
//        NSLog(@"i=%d, %@", i, arrAllTokenNode[i]);
//    }
    
    NSLog(@"createAbst(original):%@", strOrigin);
    
    @autoreleasepool {
        NSString *strAbst = @"";
        
        //test
        strOrigin = @"ウクライナで将来的に軍事衝突や信用収縮など「最悪」の事態が起きる可能性は小さいとの見方が多いものの、これは残念だけれども、明日は我が身ということで先行きの不透明感は極めて濃く、3月14日をピークに市場における緊張感が高まっている";//やってくる";
        
        
        
        NSMutableArray *arrReturn = [NSMutableArray array];
        NSArray *arrNodes = [self getNode:strOrigin];
        Node *node;
        NSString *strForAppend = @"";//連結用文字列
        
        //5w1hに変換
        
        NSString *who;
        //市場
        
        NSString *what;
        //やってくる、高まっている
        
        NSString *when;
        //3月14日をピークに:日付データの後に「に(助詞,格助詞,一般,*)」、「における、において」がある場合はwhen
        
        NSString *where;
        //地名データを文章から探す。
        
        NSString *why;
        //文章全体から「だから、なぜなら」、等の理由を取得
        
        NSString *how;
        //文章全体から、「によって」、「を使って」を拾ってくる
        
        //軍事衝突や信用収縮など「最悪」の事態が起きる可能性は小さいとの見方が多いものの、先行きの不透明感は極めて濃く、市場における緊張感が高まっている

        
        
        //まずは読点「、」で文章を分割
        NSArray *array = [strOrigin componentsSeparatedByString:@"、"];
        for (NSString *component in array) {
            NSLog(@"%@", component);
        }
        
        
        
        //方針：
        //①句読点や接続助詞等により文章を文節に区切る
        //①−１文節毎に重要語句が含まれているか否かで採用非採用を決定：非重要単語が含まれていない文章の後に接続助詞(ものの)が続く場合はその前の文章を除外する
        //
        //②形容詞の前の副詞も除外
        //③など(助詞,副助詞,*,*)は除外
        //③−１名詞A1(や)名詞A2...＋等＋名詞B：名詞Bのみ
        //④つまり、すわなち、要するに、等の接続語は直前の文章を要約するので、直後の文章さえあれば良い
        //⑤例えば、等は本質的なないようでない可能性があり重要度を下げる
        
        //30代という成人は人生において曖昧である
        //30代という成人　は　人生において　曖昧である
        //1 2 3 4 5という記号に分けてニューラルネットに学習？
        
        //言い換え
        //ものの＝＞一方で
        //における＝＞の
        //動詞、自立「・・っている」＝＞「・・る」
        
        
//        NSString *
        for(int i = 0;i < [arrNodes count];i++){//次の単語を探すのは連結した単語の数に応じて。
            
            node = arrNodes[i];
            
            
            NSLog(@"%@(%@,%@,%@,%@)",
                  node.surface,node.features[0],node.features[1],
                  node.features[2], node.features[3]);
            
            
            
            //人名や地名、時間データを取得する必要ー＞氏名や日付など、トークンを連結する必要がある：[self getNodeOnlyNoun]と同じことを二回やる必要ないのでそこでarrAllTermを生成することにする
            
            //係助詞を探索
            if([node.features[1] isEqualToString:@"係助詞"]){
                if(i > 0){
                    who = ((Node *)arrNodes[i-1]).surface;
                    NSLog(@"who = %@", who);
                }
                
                //後ろの動詞を探す
                NSMutableArray *arrVerb = [NSMutableArray array];
                for(int j = i+1;j < [arrNodes count];j++){
                    Node *nextNode = arrNodes[j];
                    if([nextNode.features[0] isEqualToString:@"動詞"]){
                        [arrVerb addObject:nextNode.surface];
                        NSLog(@"surface:[%@]", nextNode.surface);
                        NSLog(@"original:[%@]", nextNode.originalForm);
                        NSLog(@"partOfSpeech:[%@]", nextNode.partOfSpeech);
                        NSLog(@"partOfSpeechSubtype1:[%@]", nextNode.partOfSpeechSubtype1);
                        NSLog(@"partOfSpeechSubtype2:[%@]", nextNode.partOfSpeechSubtype2);
                        NSLog(@"partOfSpeechSubtype3:[%@]", nextNode.partOfSpeechSubtype3);
                        NSLog(@"inflection:[%@]", nextNode.inflection);
                        NSLog(@"useOfType:[%@]", nextNode.useOfType);
                        NSLog(@"reading:[%@]", nextNode.reading);
                        NSLog(@"pronunciation:[%@]", nextNode.pronunciation);
                        
                    }
                }
                //動詞が一つしかなければwhatとして採用
                if([arrVerb count] == 1){
                    what = arrVerb[0];
                    NSLog(@"what = %@", what);
                }else if([arrVerb count] == 0){
                    NSLog(@"動詞が見つかりません");
                }else{
                    NSLog(@"動詞が複数見つかりました");
                }
            }
            
            
            continue;//
            
            
            //以下は必要に応じてコピペ用に残しておく
            
            
            //original：[self getNodeOnlyNoun]
            
            //非自立語の場合はスルー
            if([node.features[1] isEqualToString:@"非自立"]){
                continue;
            }
            
            strForAppend = node.surface;
            
            int original_i = i;
            if([node.features[0] isEqualToString:@"名詞"]){
                //格納済のその後の名詞を探索していく
                for(int j = 1;i+j < [arrNodes count];j++){//iが最後ならこのループは実行されない
                    Node *nodeNext = arrNodes[original_i + j];
                    
                    //test
                    //                NSLog(@"now:%@(%@) next:%@(%@)",
                    //                      strForAppend,node.features[1],
                    //                      nodeNext.surface, nodeNext.features[1]);
                    
                    //今の数字が数字でその後も数字ならば連結
                    if([node.features[1] isEqualToString:@"数"]){//今の単語が数字で
                        //                    NSLog(@"次の品詞は数字");
                        if([nodeNext.features[1] isEqualToString:@"数"]){//次の単語も数字である場合
                            strForAppend = [NSString stringWithFormat:@"%@%@",
                                            strForAppend,nodeNext.surface];
                            
                            i++;
                            continue;//次の単語j+1の探査へ
                        }
                    }
                    
                    
                    //今の名詞が一般名詞もしくは固有名詞で、次の一般もしくは固有名詞の場合は連結
                    if([node.features[1] isEqualToString:@"一般"]||
                       [node.features[1] isEqualToString:@"固有名詞"]
                       ){//今の単語が一般名詞、もしくは固有名詞の場合
                        
                        //                    NSLog(@"次の品詞は一般、固有名詞");
                        if([nodeNext.features[1] isEqualToString:@"一般"]||
                           [nodeNext.features[1] isEqualToString:@"固有名詞"]
                           ){//次の単語も一般名詞か固有名詞の場合
                            strForAppend = [NSString stringWithFormat:@"%@%@",
                                            strForAppend,nodeNext.surface];
                            
                            i++;
                            continue;//次の単語j+1の探査へ
                        }
                    }
                    
                    
                    //次の単語の品詞が接尾語である場合は連結
                    if([nodeNext.features[1] isEqualToString:@"接尾"]){
                        //                    NSLog(@"次の品詞は接続詞");
                        strForAppend = [NSString stringWithFormat:@"%@%@",
                                        strForAppend,nodeNext.surface];
                        
                        i++;
                        //                    continue;//次の単語j+1の探査へ
                        break;//次の単語を探査せずに格納する
                    }
                    
                    //上記サブifの全てに当てはまらない場合はbreak;
                    break;//for-j
                    
                }//for-j
                
                
                //            NSLog(@"arrReturnに『%@(%@)』を追加", strForAppend, node.features[1]);
                Node *oldNode = node;
                Node *newNode = [Node new];
                newNode.surface = strForAppend;
                newNode.feature = oldNode.feature;//格納の仕方がよくわからないので連結された中の最後のnodeのfeatureを格納
                [arrReturn addObject:newNode];
                strForAppend = @"";//初期化
            }//if-noun
        }//for-i
        
        return strAbst;
        
        
    }
    
    
    
    
    
    
    
    
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
//                NSLog(@"単語%d「%@」は文章%d:「%@」に含まれる＝＞score=%d",
//                      i,_term,noSen,_arrSentenceArg[noSen],_d_i);
            }
        }
        
        //_d_iは単語iを含む文章数なので必ずDより小さくなる
//        NSLog(@"error at %d is _d_i=%d,D=%d => log=%f",
//              i, _d_i, D, log(D/_d_i));
        
        
        _arrIDF[i] = [NSNumber numberWithDouble:log(_d_i==0?-10:D/_d_i)];//-10に根拠はない(とりあえず)
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



/*
 *前提：arrContentsに対応するスコアがarrScoreに格納されている
 *機能：arrScoreの降順(大きい順)にarrContensを並べ替えて返す
 */
-(NSMutableArray *)getOrderedArrayFor:(NSArray *)arrContents
                     withScore:(NSArray *)_arrScore{
    
    NSMutableArray *_arrReturn = [NSMutableArray array];
    
    NSMutableArray *arrTmp =
    [self getArrayInOrder:(NSMutableArray *)_arrScore
                    numOf:[_arrScore count]];
    //        for(int i = 0;i < [arrTmp count];i++){
    //            NSLog(@"arrtmp%d is %@", i, arrTmp[i]);
    //        }
    
    //        NSLog(@"arrtmp count=%d, arrscoreNounTmp=%d",
    //              [arrTmp count], [arrScoreNounTmp count]);
    
    for(int i =0;i < MIN([arrContents count], [arrTmp count]);i++){
        //ユニークかつ降順に名詞のみをNode型として配列作成
        [_arrReturn
         addObject:
         arrContents[[arrTmp[i] integerValue]]
         ];
    }
    
    //並べ替えられた配列を返す
    return _arrReturn;
}


@end
