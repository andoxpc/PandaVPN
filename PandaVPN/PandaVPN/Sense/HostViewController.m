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
@property (strong, nonatomic) NSArray *hostArray;

@end

@implementation HostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requeset = [AFHTTPSessionManager manager];
    self.requeset.requestSerializer = [AFJSONRequestSerializer serializer];
    self.requeset.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.hostArray = [[NSArray alloc]initWithObjects:@"45.77.29.224", nil];
    
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
    NSString *host = [self.hostArray objectAtIndex:indexPath.row];
    NSString *url = [NSString stringWithFormat:@"http://ip.taobao.com/service/getIpInfo.php?ip=%@",host];
    NSString *UTFurl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.requeset POST:UTFurl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        HostModel *model = [[HostModel alloc]initWithDictionary:[responseObject objectForKey:@"data"] error:nil];
        cell.hostName.text = [NSString stringWithFormat:@"线路%ld    %@ %@",indexPath.row+1,model.country?model.country:@"",model.city?model.city:@""];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end
