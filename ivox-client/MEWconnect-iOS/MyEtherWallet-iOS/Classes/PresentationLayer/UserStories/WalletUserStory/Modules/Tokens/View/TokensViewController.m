//
//  InfoViewController.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import libextobjc.EXTScope;
@import MessageUI;

#import "TokensViewController.h"

#import "TokensViewOutput.h"

#import "ApplicationConstants.h"

#import "UIView+LockFrame.h"
#import "UIScreen+ScreenSizeType.h"

#import "GenericToken.h"
#import "IvoxTokenModelObject.h"
#import "EtherTokenModelObject.h"

#import "HeadlineTableViewCell.h"

#import "MyEtherWallet_iOS-Swift.h"

@interface TokensViewController ()
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *versionTopOffsetConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleTopOffsetConstraint;
@property (nonatomic, strong) NSNumber *selectedTokensIndex;
@property (nonatomic, strong) NSMutableArray *tokensArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TokensViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
  [super viewDidLoad];
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    self.selectedTokensIndex = [[NSNumber alloc] initWithInt:0];
    self.tokensArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.output didTriggerViewReadyEvent];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewLayoutMarginsDidChange {
  [super viewLayoutMarginsDidChange];
  [self _updatePrefferedContentSize];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Override

- (void)setCustomTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)customTransitioningDelegate {
  _customTransitioningDelegate = customTransitioningDelegate;
  self.transitioningDelegate = customTransitioningDelegate;
}

#pragma mark - InfoViewInput

- (void)setupInitialStateWithVersion:(NSString *)version backupAvailability:(BOOL)available backedStatus:(BOOL)isBackedUp {
  switch ([UIScreen mainScreen].screenSizeType) {
    case ScreenSizeTypeInches35:
    case ScreenSizeTypeInches40: {
      self.versionTopOffsetConstraint.constant = 20.0;
    }
    case ScreenSizeTypeInches47: {
      self.titleTopOffsetConstraint.constant = 24.0;
      break;
    }
    default:
      break;
  }
  
  [self _updatePrefferedContentSize];
}

-(void) addIvoxTokensAndRefresh:(NSArray <IvoxTokenModelObject *> *)tokens{
    self.tokensArray = [[NSMutableArray alloc] initWithCapacity:tokens.count];
    tokens = [tokens sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];

    NSUInteger count = [tokens count];
    for (NSUInteger index = 0; index<count ; index++) {
        IvoxTokenModelObject* token = [tokens objectAtIndex:index];
        GenericToken* genericToken = [[GenericToken alloc] init];
        genericToken.identifier = [NSNumber numberWithInt:index + 1];
        
        genericToken.paypal = token.paypal;
        genericToken.txIdentifier = token.identifier;
        genericToken.wallet = token.wallet;
        genericToken.currency = token.currency;
        genericToken.date = token.date;
        genericToken.source = token.source;
        genericToken.destination = token.destination;
        genericToken.value = token.value;
        genericToken.purchase = token.purchase;
        genericToken.status = token.status;
        genericToken.image = @"mew_logo";
        
        [self.tokensArray addObject:genericToken];
    }
    
    [self.tableView reloadData];
}


-(void) addEtherTokensAndRefresh:(NSArray <EtherTokenModelObject *> *)tokens{
    self.tokensArray = [[NSMutableArray alloc] initWithCapacity:tokens.count];
    tokens = [tokens sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]]];

    
    NSUInteger count = [tokens count];
    for (NSUInteger index = 0; index<count ; index++) {
        EtherTokenModelObject* token = [tokens objectAtIndex:index];
        GenericToken* genericToken = [[GenericToken alloc] init];
        genericToken.identifier = [NSNumber numberWithInt:index + 1];
        
        genericToken.paypal = token.paypal;
        genericToken.txIdentifier = token.identifier;
        genericToken.wallet = token.wallet;
        genericToken.currency = token.currency;
        genericToken.date = token.date;
        genericToken.source = token.source;
        genericToken.destination = token.destination;
        genericToken.value = token.value;
        genericToken.purchase = token.purchase;
        genericToken.status = token.status;
        genericToken.image = @"mew_logo";
        
        [self.tokensArray addObject:genericToken];
    }
    
    [self.tableView reloadData];
}

#pragma mark - IBActions

- (IBAction)closeButtonAction:(__unused id)sender {
    [self.output closeAction];
}
- (IBAction) closeAction:(__unused id)sender {
  [self.output closeAction];
}

- (IBAction) unwindToTokens:(__unused UIStoryboardSegue *)sender {}


#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(__unused id)sender{
    if([[segue identifier] isEqualToString:@"TokensToSingleTokenSegueIdentifier"]){
        SingleTokenPopOverViewController *popover = (SingleTokenPopOverViewController *)((UINavigationController *) segue.destinationViewController);

        GenericToken* token = [self.tokensArray objectAtIndex:[self.selectedTokensIndex longValue]];

        NSString* paypal = token.paypal;
        NSString* txIdentifier  = token.txIdentifier;
        NSString* wallet  = token.wallet;
        NSString* currency  = token.currency;
        NSString* date  = token.date;
        NSString* source  = token.source;
        NSString* destination  = token.destination;
        NSString* value  = token.value;
        NSString* purchase  = token.purchase;
        NSString* status = token.status;
        
        
        NSArray<NSString*> * titles = [[NSArray<NSString*> alloc] init];

        NSArray<NSString*> * properties = [[NSArray<NSString*> alloc] init];
        
        titles = [properties arrayByAddingObjectsFromArray:@[@"PayPal ID", @"Transaction Identifier", @"Wallet", @"Currency", @"Date", @"Source Wallet", @"Destination Wallet", @"Token Value", @"Purchase Value", @"Status"]];

        
        properties = [properties arrayByAddingObjectsFromArray:@[paypal, txIdentifier, wallet, currency, date, source, destination, value, purchase, status]];
        
        popover.titles = titles;
        popover.names = properties;
    }
}

#pragma mark - Private

- (void) _updatePrefferedContentSize {
  CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
  CGRect bounds = self.presentingViewController.view.window.bounds;
  CGSize size = bounds.size;
  size.height -= CGRectGetHeight(statusBarFrame);
  size.height -= kCustomRepresentationTopSmallOffset;
  if (!CGSizeEqualToSize(self.preferredContentSize, size)) {
    self.preferredContentSize = size;
  }
}

#pragma mark - InfoDataDisplayManagerDelegate

- (void) didTapUserGuide {
  [self.output userGuideAction];
}

#pragma mark - TableView


- (IBAction)tapGestureTapCell:(__unused UITapGestureRecognizer *)sender {
    
    HeadlineTableViewCell *cell = (HeadlineTableViewCell *)sender;
    
    self.selectedTokensIndex = [NSNumber numberWithLong:[self.tableView indexPathForCell:cell].row];
    
    [self performSegueWithIdentifier:@"TokensToSingleTokenSegueIdentifier" sender:self];
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");

    HeadlineTableViewCell *cell = (HeadlineTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"LabelCell" forIndexPath:indexPath];
   
    if (indexPath.row < [self.tokensArray count]){
        GenericToken* genericToken = [self.tokensArray objectAtIndex:indexPath.row];
        cell.headlineTitleLabel.text = genericToken.date;
        cell.headlineTextLabel.text = genericToken.value;
        cell.headlineImageView.image = [UIImage imageNamed:genericToken.image];
        
        cell.headlineTitleLabel.numberOfLines = 0;
        cell.headlineTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTapCell:)];

    [cell addGestureRecognizer:gesture];

    return cell;

}

- (NSInteger)tableView:(nonnull __unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return [self.tokensArray count];
}



@end
