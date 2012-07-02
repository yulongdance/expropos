//
//  exproposShowDealsViewController.m
//  expropos
//
//  Created by haitao chen on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "exproposShowDealsSelectedViewController.h"
#import "ExproDealItem.h"
#import "ExproStore.h"
#import "exproposDealSelectedViewController.h"

@interface exproposShowDealsSelectedViewController ()
@property (nonatomic,strong) UIActivityIndicatorView *spinner;
@property (nonatomic,strong) UIBarButtonItem *spinnerIteam;
@property (nonatomic,strong)  UIBarButtonItem *updateItem;

@end

@implementation exproposShowDealsSelectedViewController
@synthesize popover = _popover;
@synthesize dealSelect = _dealSelect;
@synthesize data = _data;
@synthesize tableView = _tableView;
@synthesize mainViewController = _mainViewController;
@synthesize updateDeals = _updateDeals;
@synthesize spinner = _spinner;
@synthesize spinnerIteam = _spinnerIteam;
@synthesize updateItem = _updateItem;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableArray *items = [[NSMutableArray alloc]initWithArray:[self.mainViewController.menuTool.items mutableCopy]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"条件筛选" style: UIBarButtonItemStyleBordered   target:self action:@selector(showSelected:)];
    int num = 0;
    for(UIBarButtonItem *i in items){
        if([i.title isEqualToString:@"菜单"]){
            num = 1;
        }
    }
    [items insertObject:item atIndex:num];
    if(_updateItem == nil){
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithTitle:@"更新" style: UIBarButtonItemStyleBordered   target:self action:@selector(updates:)];
        [items insertObject:item2 atIndex:items.count -1];
        self.mainViewController.menuTool.items = items;
    }else {
        [items insertObject:_spinnerIteam atIndex:items.count-1];
        self.mainViewController.menuTool.items = items;
    }
}

-(void)updates:(UIBarButtonItem *)sender {

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_spinner startAnimating];
    _spinnerIteam = [[UIBarButtonItem alloc] initWithCustomView:_spinner];
    NSMutableArray *items = [[NSMutableArray alloc]initWithArray:[self.mainViewController.menuTool.items mutableCopy]];
   
    for(UIBarButtonItem *item in items){
        if([item.title isEqualToString:@"更新"]){
            _updateItem = item;
        }
    }
    [items removeObject:_updateItem];
    [items insertObject:_spinnerIteam atIndex:items.count -1];
    self.mainViewController.menuTool.items = items;

dispatch_queue_t downloadQueue = dispatch_queue_create("deals downloader", NULL);
dispatch_async(downloadQueue, ^{
    _updateDeals.reserver = self;
    _updateDeals.succeedCallBack =  @selector(updateSuccess);
     [_updateDeals  upDateDealStart:1 end:100 bt:nil et:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
      //  [self updateSuccess];      
    });
});
dispatch_release(downloadQueue);    
}

-(void)updateSuccess
{
    dispatch_queue_t updateQueue = dispatch_queue_create("dealItems update", NULL);
    dispatch_async(updateQueue, ^{
        [_updateDeals updateDeal];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *items = [[NSMutableArray alloc]initWithArray:[self.mainViewController.menuTool.items mutableCopy]];
            NSMutableArray *removeItems = [NSMutableArray arrayWithCapacity:2];
            for(UIBarButtonItem *item in items){
                if(item == _spinnerIteam){
                    [removeItems addObject: item];
                }
            }
            [items removeObjectsInArray:removeItems];
            [items insertObject:_updateItem atIndex:items.count-1];
            self.mainViewController.menuTool.items = items;
            _spinnerIteam = nil;
            exproposDealSelectedViewController *s =(exproposDealSelectedViewController*)  [_dealSelect.viewControllers objectAtIndex:0];
            self.data = [s searchInLoacl];
            [self.tableView reloadData];
        });
    });

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSMutableArray *items = [[NSMutableArray alloc]initWithArray:[self.mainViewController.menuTool.items mutableCopy]];
    NSMutableArray *removeItems = [NSMutableArray arrayWithCapacity:10];
    for(UIBarButtonItem *item in items){
        if([item.title isEqualToString:@"条件筛选"]){
            [removeItems addObject: item]; 
        }
        if([item.title isEqualToString:@"更新"]){
            [removeItems addObject: item];
        }
    }
    [items removeObjectsInArray:removeItems];
    [items removeObject:self.spinnerIteam];
    self.mainViewController.menuTool.items = items;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dealSelect = [self.storyboard instantiateViewControllerWithIdentifier:@"showChoose"];
  exproposDealSelectedViewController *s =(exproposDealSelectedViewController*)  [_dealSelect.viewControllers objectAtIndex:0];
    
    if (_popover == nil) {
        _popover = [[UIPopoverController alloc] initWithContentViewController:_dealSelect];
    }
    s.myPopover  =  _popover;
    s.showDeals = self;
    _updateDeals = [[exproposUpdateDeals alloc]init];
 
    
}

-(void)showSelected:(id)sender
{
    
    if (_popover == nil) {
        _popover = [[UIPopoverController alloc] initWithContentViewController:_dealSelect];
    }else {
        _popover.contentViewController = _dealSelect;
    }
    [self showOrderNumPopover:sender];

}

-(void)showOrderNumPopover:(UIBarButtonItem *)item {
    
    [_popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
       
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - MultipleTable view data source and delegate

- (NSInteger)numberOfSegmentInMultipleTableView:(ExproMultipleTableView *)tableView
{
    return 7;
}
- (CGFloat)multipleTableView:(ExproMultipleTableView *)tableView proportionForSegment:(NSInteger)segment
{
    if(segment == 0){
        return 0.25;
    }else {
        return 0.125;
    }
}
- (NSString *)multipleTableView:(ExproMultipleTableView *)tableView titleForSegment:(NSInteger)segment
{
    switch (segment) {
        case 0:
            return @"项目";
            break;
        case 1:
            return @"金额";
            break;
        case 2:
            return @"时间";
            break;
        case 3:
            return @"方式";
            break;
        case 4:
            return @"客户";
            break;
        case 5:
            return @"网点";
            break;
        case 6:
            return @"备注";
            break;
        default:
            break;
    }
    return nil;
}

- (UIView *)multipleTableView:(ExproMultipleTableView *)tableView viewForSegment:(NSInteger)segment indexPath:(NSIndexPath *)indexPath
{
    CGFloat _width = [self multipleTableView:tableView proportionForSegment:segment]*tableView.bounds.size.width;
    ExproDeal *deal = (ExproDeal*)[_data objectAtIndex:indexPath.row];
    switch (segment) {
        case 0:
        {
            UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _width, 44)];
          NSArray *types =  [NSArray arrayWithObjects:@"消费撤",@"消费",@"充值",@"充值撤销",@"积分增加",@"积分消费",@"积分撤销",@"退货退款",@"抽奖",@"手工调整", nil];
            name.text = [types objectAtIndex:[deal type].intValue];
            if(segment%2==0){
                name.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                name.backgroundColor = [UIColor lightGrayColor];
            }
            name.font = [UIFont systemFontOfSize:12];
            return name;
        }
            break;
        case 1:
        {
            UILabel *menoy = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
            double menoys = 0.0;
            NSSet *dealItems = deal.items;
            for(ExproDealItem *item in dealItems){
                menoys += item.totalCost.doubleValue;
            }
            menoy.text = [NSString stringWithFormat:@"%g",menoys];
            if(segment%2==0){
                menoy.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                menoy.backgroundColor = [UIColor lightGrayColor];
            }
            menoy.font = [UIFont systemFontOfSize:12];
            return menoy;
        }
            break;
        case 2:
        {
            UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
            //实例化一个NSDateFormatter对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            //用[NSDate date]可以获取系统当前时间
            NSString *createDateStr = [dateFormatter stringFromDate:deal.createTime];
            //输出格式为：2010-10-27
            time.text = createDateStr;
            if(segment%2==0){
                time.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                time.backgroundColor = [UIColor lightGrayColor];
            }
            time.font = [UIFont systemFontOfSize:12];
            return time;
        }
            break;
        case 3:
        {
            NSArray *payTypes = [NSArray arrayWithObjects:@"现金",@"银行卡",@"积分",@"现金+积分",@"银行卡+积分", nil];
            UILabel *payTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
            NSString *payType = [payTypes objectAtIndex:deal.payType.intValue];
            payTypeLabel.text = payType;
            if(segment%2==0){
                payTypeLabel.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                payTypeLabel.backgroundColor = [UIColor lightGrayColor];
            }
            payTypeLabel.font = [UIFont systemFontOfSize:12];
            return payTypeLabel;
        }
            break;
        case 4:
        {
             UILabel *customer = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
            customer.text = [deal.customer petName];
            if(segment%2==0){
                customer.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                customer.backgroundColor = [UIColor lightGrayColor];
            }
            customer.font = [UIFont systemFontOfSize:12];
            return customer;
        }
            break;
        case 5:
        {
            UILabel *store = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
            store.text = deal.store.name;
            if(segment%2==0){
                store.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                store.backgroundColor = [UIColor lightGrayColor];
            }
            store.font = [UIFont systemFontOfSize:12];
            return store;
        }
        case 6:
        {
             UILabel *comment = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _width, 44)];
            comment.text = @"";
            if(segment%2==0){
                comment.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
            }else {
                comment.backgroundColor = [UIColor lightGrayColor];
            }
            comment.font = [UIFont systemFontOfSize:12];
            return comment;
        }
            
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)multipleTableView:(ExproMultipleTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UIColor *)multipleTableView:(ExproMultipleTableView *)tableView backgroundColorForHeaderInSection:(NSInteger)section
{
    return [UIColor grayColor];
}
- (UIColor *)multipleTableView:(ExproMultipleTableView *)tableView backgroundColorSegment:(NSInteger)segment
{
    if(segment%2==0){
        return [UIColor colorWithWhite:0.75 alpha:1];
    }else {
        return [UIColor lightGrayColor];
    }
}

@end
