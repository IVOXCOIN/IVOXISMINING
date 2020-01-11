//
//  SplashPasswordViewController.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 26/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "SplashPasswordViewController.h"

#import "SplashPasswordViewOutput.h"

#import "ApplicationConstants.h"

#import "PasswordTextField.h"
#import "UIView+LockFrame.h"

static CGFloat const kSplashPasswordShakeAnimationDistance = 10.0;
static CFTimeInterval const kSplashPasswordShakeAnimationDuration = 0.05;
static float const kSplashPasswordShakeAnimationRepeatCount = 3.0;

@interface SplashPasswordViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet PasswordTextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation SplashPasswordViewController {
  BOOL _makePasswordTextFieldActive;
}

#pragma mark - LifeCycle

- (void) viewDidLoad {
	[super viewDidLoad];
  self.modalPresentationCapturesStatusBarAppearance = YES;
	[self.output didTriggerViewReadyEvent];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.logoImageView.frame = CGRectMake(self.passwordTextField.frame.origin.x, self.passwordTextField.frame.origin.y + 32, 160, 36);

    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.passwordTextField.frame = CGRectMake(self.passwordTextField.frame.origin.x, self.passwordTextField.frame.origin.y + 96, self.passwordTextField.frame.size.width, 48);

    //[self.view layoutIfNeeded];
    
  if (_makePasswordTextFieldActive) {
    [self.passwordTextField becomeFirstResponder];
  }
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void) viewLayoutMarginsDidChange {
  [super viewLayoutMarginsDidChange];
  [self _updatePrefferedContentSize];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Override

- (void) setCustomTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)customTransitioningDelegate {
  _customTransitioningDelegate = customTransitioningDelegate;
  self.transitioningDelegate = customTransitioningDelegate;
}

#pragma mark - SplashPasswordViewInput

- (void) setupInitialStateWithAutoControl:(BOOL)autoControl {
  _makePasswordTextFieldActive = autoControl;
  [self _updatePrefferedContentSize];
}

- (void) becomePasswordInputActive {
  _makePasswordTextFieldActive = YES;
  [self.passwordTextField becomeFirstResponder];
}

- (void) shakeInput {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  animation.duration = kSplashPasswordShakeAnimationDuration;
  animation.repeatCount = kSplashPasswordShakeAnimationRepeatCount;
  animation.autoreverses = YES;
  animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.passwordTextField.center.x - kSplashPasswordShakeAnimationDistance, self.passwordTextField.center.y)];
  animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.passwordTextField.center.x + kSplashPasswordShakeAnimationDistance, self.passwordTextField.center.y)];
  [self.passwordTextField.layer addAnimation:animation forKey:@"position"];
}

- (void) lockPasswordField {
  [self.passwordTextField setText:nil];
  self.passwordTextField.inputEnabled = NO;
}

- (void) unlockPasswordField {
  self.passwordTextField.inputEnabled = YES;
}

- (void) updateLockWithTimeInterval:(NSTimeInterval)unlockIn {
  NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
  [formatter setUnitsStyle:NSDateComponentsFormatterUnitsStylePositional];
  [formatter setAllowedUnits:NSCalendarUnitMinute|NSCalendarUnitSecond];
  [formatter setZeroFormattingBehavior:NSDateComponentsFormatterZeroFormattingBehaviorPad];
  NSString *unlockInText = [formatter stringFromTimeInterval:unlockIn];
  [self.passwordTextField setRightViewText:unlockInText];
}

#pragma mark - IBActions

- (IBAction) passwordDidChanged:(__unused UITextField *)sender {
  
}

- (IBAction) forgotPasswordAction:(__unused UIButton *)sender {
  [self.output forgotPasswordAction];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(PasswordTextField *)textField shouldChangeCharactersInRange:(__unused NSRange)range replacementString:(__unused NSString *)string {
  return textField.inputEnabled;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.output doneActionWithPassword:textField.text];
  return NO;
}

#pragma mark - Private

- (void) _updatePrefferedContentSize {
  CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
  CGRect bounds = self.presentingViewController.view.window.bounds;
  CGSize size = bounds.size;
  size.height -= CGRectGetHeight(statusBarFrame);
  //size.height -= kCustomRepresentationTopBigOffset;
  if (!CGSizeEqualToSize(self.preferredContentSize, size)) {
    self.preferredContentSize = size;
  }
}

@end
