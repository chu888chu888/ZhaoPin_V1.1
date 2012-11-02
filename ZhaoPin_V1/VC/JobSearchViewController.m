//
//  PPJobSearchViewController.m
//  PPZhiLian
//
//  Created by 马朋震 /Users/ibokan/Desktop/图片/523194.gif on 12-10-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JobSearchViewController.h"
#import "JobTableViewController.h"
#import "HistoryCell.h"

@implementation JobSearchViewController
@synthesize searchURL;
@synthesize searchConditionTitles;
@synthesize searchConditionDetailTitles;
@synthesize selectedConditionArr;
@synthesize selectedParametersForConditions;
@synthesize selctedConditionAndParameterDic;
@synthesize historysCells;
@synthesize historysPara;
- (void)dealloc
{
    self.historysPara = nil;
    self.historysCells = nil;
    self.searchConditionTitles = nil;
    self.searchConditionDetailTitles = nil;
    self.searchURL = nil;
    self.selectedParametersForConditions = nil;
    self.selctedConditionAndParameterDic = nil;
    self.selectedConditionArr = nil;
    
    [super dealloc];

}

- (void)getSendingData//（搜索条件数组及对应的参数）
{
    self.selectedConditionArr = [[NSMutableArray alloc] init];
    self.selectedParametersForConditions = [[NSMutableArray alloc] init];
    NSMutableArray *temp = [[NSMutableArray alloc] initWithObjects:@"请输入关键字",@"请选择职位名称",@"请选择行业类别",@"请选择工作地点", nil];
    NSMutableArray *paraArr = [[NSMutableArray alloc] initWithObjects:@"key_word",@"schJobType",@"industry",@"city",nil];
    for (int i=0; i<4; i++) 
    {
        if (![[searchConditionDetailTitles objectAtIndex:i]isEqualToString:[temp objectAtIndex:i]]) 
        {
            [self.selectedConditionArr addObject:[searchConditionDetailTitles objectAtIndex:i]];
            [self.selectedParametersForConditions addObject:[paraArr objectAtIndex:i]];
        }
    }
    self.selctedConditionAndParameterDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.selectedConditionArr,self.selectedParametersForConditions, nil];
    NSLog(@"%@",[self.selctedConditionAndParameterDic allKeys]);
}

#pragma mark - 初始化:数据和视图
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initTitles//初始化字符串数组
{
    searchConditionTitles = [[NSMutableArray alloc] initWithObjects:@"关键字:",@"职位名称:",@"行业类别:",@"工作地点:", nil];
    searchConditionDetailTitles = [[NSMutableArray alloc] initWithObjects:@"请输入关键字",@"请选择职位名称",@"请选择行业类别",@"请选择工作地点", nil];
}

- (void)initTableView//初始化表视图
{
    searchConditionTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, 416) style:UITableViewStyleGrouped];
    searchConditionTV.delegate = self;
    searchConditionTV.dataSource = self;
    [searchConditionTV setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]]];
    [self.view addSubview:searchConditionTV];
}

- (void)initTextField:(UIView *)view//初始化关键字搜索框
{
    keywordTF = [[UITextField alloc] initWithFrame:CGRectMake(90, 8, 210, 30)];
    [keywordTF setBorderStyle:UITextBorderStyleRoundedRect];
    keywordTF.placeholder = [self.searchConditionDetailTitles objectAtIndex:0];
    keywordTF.delegate = self;
    [view addSubview:keywordTF];
    [keywordTF release];
}

- (UIView *)initSectionHeaderViewWithLeftLabel:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle//初始化section头部视图
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    //头部视图左边的label
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    leftLabel.text = leftTitle;
    [leftLabel setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:leftLabel];
    //头部视图右边的label
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 40, 30)];
    rightLabel.text = rightTitle;
    [rightLabel setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:rightLabel];
    [leftTitle release];
    [rightLabel release];
    return [headerView autorelease];
}


- (UIView *)initSectionFooterView//初始化section底部视图
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom ];//搜索按钮
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"white-button.png"] forState:UIControlStateNormal];
 
    searchBtn.frame = CGRectMake(50, 20, 220, 40);
    [searchBtn addTarget:self action:@selector(searchJob) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:searchBtn];
    return [footerView autorelease];
}

- (void)initClearButtonInView:(UIView *)view
{
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearBtn setTitle:@"清除搜索条件" forState:UIControlStateNormal];
    [clearBtn setBackgroundImage:[UIImage imageNamed:@"white-button.png"] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearConditions) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn setFrame:CGRectMake(210, 6, 100, 35)];
    [clearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearBtn.titleLabel setFont:[UIFont fontWithName:@"Georgia-Bold" size:14]];
    [view addSubview:clearBtn];
}
- (UIColor *)setDetailTitleColorForCell:(NSIndexPath *)indexPath//返回cell上detailLabel的颜色
{
    NSMutableArray *compareArr = [[NSMutableArray alloc] initWithObjects:@"请输入关键字",@"请选择职位名称",@"请选择行业类别",@"请选择工作地点", nil];
    if (![[self.searchConditionDetailTitles objectAtIndex:indexPath.row] isEqualToString:[compareArr objectAtIndex:indexPath.row]]) 
    {
        return [UIColor blackColor];
    }else
    {
        return [UIColor grayColor];
    }
}

#pragma mark - 点击cell进入到下一个界面（push），选择搜索条件
- (void)pushToParameter:(NSInteger)row
{
    ParameterViewController *parameter = [[ParameterViewController alloc]initWithNibName:@"ParameterViewController" bundle:nil];
    parameter.delegate = self;
    parameter.selectRow = row;
    [self.navigationController pushViewController:parameter animated:YES];
}

#pragma mark - 点击按钮执行的方法
- (void)clearConditions
{
    [self initTitles];
    [searchConditionTV reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}
- (NSString *)filePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"hitory"];
    return filePath;
}



- (void)writeTofile
{
    self.historysCells = [[NSMutableArray alloc] init];
    self.historysPara = [[NSMutableArray alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) 
    {
        self.historysCells = [NSMutableArray arrayWithContentsOfFile:[self filePath]];
        self.historysPara = [NSMutableArray arrayWithContentsOfFile:[[[self filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"parameter"]];
    }
    if ([self.selectedConditionArr count] > 0) 
    {
        [self.historysCells addObject:self.selectedConditionArr];
        NSLog(@"%@",self.historysCells);
        [self.historysPara addObject:self.selectedParametersForConditions];
        [self.historysCells writeToFile:[self filePath] atomically:YES]; 
        [self.historysPara writeToFile:[[[self filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"parameter"] atomically:YES];
    }
    

}
- (void)searchJob
{
    [self getSendingData];
    [self writeTofile];
    
    JobTableViewController *jobtable = [[JobTableViewController alloc]initWithNibName:@"JobTableViewController" bundle:nil];
    NSLog(@"?????????????????%@",self.selctedConditionAndParameterDic);
    jobtable.parameterDic = self.selctedConditionAndParameterDic;
    [self.navigationController pushViewController:jobtable animated:YES];

}
#pragma mark - GetData代理方法
- (void)getData:(NSString *)parameter selectRow:(NSInteger)row
{
    [self.searchConditionDetailTitles replaceObjectAtIndex:row withObject:parameter];
    [searchConditionTV reloadData];
}
#pragma mark - textField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [keywordTF resignFirstResponder];
    
    return  YES;
}//输入关键字之后，回收键盘

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    [self.searchConditionDetailTitles replaceObjectAtIndex:0 withObject:keywordTF.text];
}

#pragma mark - tableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }else
    {
        NSArray *historys = [[NSArray alloc] initWithContentsOfFile:[self filePath]];
        if ([historys count]>0) 
        {
            if ([historys count]<6) {
                return [historys count];
            }else
            {
                return 5;
            }
        }else
        {
            return 1;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) 
    {
        UIView *firstSectionHeaderV = [self initSectionHeaderViewWithLeftLabel:@"选择职位搜索条件" andRightTitle:nil];
        [self initClearButtonInView:firstSectionHeaderV];
        return firstSectionHeaderV;
    }else
    {
        NSArray *historys1 = [[NSArray alloc] initWithContentsOfFile:[self filePath]];
        UIView *secondSectionHeaderV = [self initSectionHeaderViewWithLeftLabel:@"我的历史搜索" andRightTitle:[NSString stringWithFormat:@"%d条",[historys1 count]>5?5:[historys1 count]]];
        UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowup.png"]] autorelease];
        arrow.frame = CGRectMake(290, 18, 10, 10);
        [secondSectionHeaderV addSubview:arrow];
        return secondSectionHeaderV;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) 
    {
        return 80.0f;
    }else
    {
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return [self initSectionFooterView];
    }else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) 
    {
        if (indexPath.row) 
        {
            cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryArrow.png"]] autorelease];
            cell.textLabel.text = [self.searchConditionTitles objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [self.searchConditionDetailTitles objectAtIndex:indexPath.row];
        }else
        {
            cell.textLabel.text = [self.searchConditionTitles objectAtIndex:indexPath.row];
            [self initTextField:cell];
        }
        [cell.detailTextLabel setTextColor:[self setDetailTitleColorForCell:indexPath]];
        
    }else 
    {       
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) 
        {
            NSArray *historyDics = [[NSArray alloc] initWithContentsOfFile:[self filePath]];
            NSArray *temp = [historyDics objectAtIndex:[historyDics count]-1-indexPath.row];
            cell.historySearch.text = [temp objectAtIndex:0];
            for (int i=1;i<[temp count];i++) 
            {
                cell.historySearch.text = [cell.historySearch.text stringByAppendingFormat:@"+%@",[temp  objectAtIndex:i]];
            }
            
        }else
        {
            cell.historySearch.text = @"无近期搜索记录";
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath//推到下一个界面，选择搜索条件
{
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                
                break;
            case 1:
                [self pushToParameter:indexPath.row];
                break;
            case 2:
                [self pushToParameter:indexPath.row];
                break;
            case 3:
                [self pushToParameter:indexPath.row];
                break;
            default:
                break;
        }
        
    }else
    {        
        NSArray *paraTmp = [NSArray arrayWithContentsOfFile:[[[self filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"parameter"]];
        NSArray *conditionTmp = [NSArray arrayWithContentsOfFile:[self filePath]];
        NSArray *para = [paraTmp objectAtIndex:[paraTmp count]-1-indexPath.row];
        NSArray *condition = [conditionTmp objectAtIndex:[conditionTmp count]-1-indexPath.row];

        NSMutableDictionary *searchDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:condition,para, nil];
        JobTableViewController *jobtable = [[JobTableViewController alloc]initWithNibName:@"JobTableViewController" bundle:nil];
        jobtable.parameterDic = searchDic;
        NSLog(@"~~~~~~~~~~~~~~~%@",searchDic);
        [self.navigationController pushViewController:jobtable animated:YES];
    }
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [searchConditionTV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTitles];
    [self initTableView];
}

- (void)viewDidUnload
{

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
