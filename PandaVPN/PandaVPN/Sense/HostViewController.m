//
//  HostViewController.m
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import "HostViewController.h"
#import <AFNetworking.h>
#import "HostModel.h"

@interface HostViewController ()

@property (strong, nonatomic) AFHTTPSessionManager *requeset;


@end

@implementation HostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requeset = [AFHTTPSessionManager manager];
    self.requeset.requestSerializer = [AFJSONRequestSerializer serializer];
    self.requeset.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)popViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableViewDelegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hostArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HostCell"];
    HostModel *item = [[HostModel alloc]initWithDictionary:[self.hostArray objectAtIndex:indexPath.row] error:nil];
    cell.item = item;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HostModel *item = [[HostModel alloc]initWithDictionary:[self.hostArray objectAtIndex:indexPath.row] error:nil];
    if (self.block) {
        self.block(item);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation HostCell

- (void)setItem:(HostModel *)item {
    _item = item;
    self.hostName.text = item.nasName;
    self.selectedView.hidden = !item.select;
}

@end
