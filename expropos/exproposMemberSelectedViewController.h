//
//  exproposMemberSelectedViewController.h
//  expropos
//
//  Created by haitao chen on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "exproposSysLoad.h"

@interface exproposMemberSelectedViewController : UITableViewController <UISearchBarDelegate>
@property (nonatomic,strong) UIViewController *viewController;
@property (nonatomic,strong) NSDictionary *allMembers;
@property (nonatomic,strong) NSMutableDictionary *members;
@property (nonatomic,strong) NSMutableArray *memberTypes;
@property (nonatomic,strong) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *updateTime;

- (IBAction)update:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *freshButton;

@property (nonatomic,strong)exproposSysLoad *sysLoad;
@property (nonatomic,strong) UIPopoverController *popover;

@end