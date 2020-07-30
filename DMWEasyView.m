//
//  DMWEasyView.m
//  VideoDonwload
//
//  Created by FDadmin on 2020/7/24.
//  Copyright © 2020 FDadmin. All rights reserved.
//

#import "DMWEasyView.h"

@interface DMWEasyView()
@property(nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation DMWEasyView

#pragma mark - LifeCircle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tag = EventType_Click;
        [self addGestureRecognizer:self.tap];
        [self layout];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tag = EventType_Click;
    [self addGestureRecognizer:self.tap];
    [self layout];
}

- (void)layout {
    
}

#pragma mark - Override Method


#pragma mark - Public
- (void)bindingModel:(id<ViewDataModelProtocol>)model {
    self.model = model;
    self.delegate = model.delegate;
    self.tap.enabled = !model.disableTap;
    
}

- (void)sendEvent:(NSInteger)eventType userInfo:(NSDictionary *)userInfo {
    
    if (self.eventHandler) {
        self.eventHandler(self, eventType, self.model, userInfo);
        return;
    }
    
    NSString *methodString = [NSString stringWithFormat:@"handleEventFrom%@:eventType:model:userInfo:", self.viewIdentifier ?: NSStringFromClass([self class])];
    SEL selector = NSSelectorFromString(methodString);
    
    BOOL endCallback = NO;
    if (![self.delegate respondsToSelector:selector]) {//指定响应代理代理方法缺失
        methodString = @"targetView:eventType:model:userInfo:";
        selector = NSSelectorFromString(methodString);
        
        if (![self.delegate respondsToSelector:selector]) {
            endCallback = YES;
        }
    }
    
    if (endCallback) {
        return;
    }
    
    UIView *targetView = self;
    id model = self.model;
    
    NSMethodSignature *signature = [[self.delegate class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self.delegate];
    [invocation setSelector:selector];
    [invocation setArgument:&targetView atIndex:2];
    [invocation setArgument:&eventType atIndex:3];
    [invocation setArgument:&model atIndex:4];
    [invocation setArgument:&userInfo atIndex:5];
    [invocation invoke];
    return;
}

- (void)eventTriggeredBy:(id)sender {
    NSInteger eventType = 0;
    if ([sender isKindOfClass:[UIView class]]) {
        eventType = ((UIView *)sender).tag;
    }
    else if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        eventType = ((UIGestureRecognizer *)sender).view.tag;
    }
    
    [self sendEvent:eventType userInfo:nil];
}

- (void)dismiss {
    [self sendEvent:EventType_Cancel userInfo:nil];
    [self removeFromSuperview];
}

- (void)dismissSilently {
    [self removeFromSuperview];
}


- (void)showInView:(UIView *)targetView userInfo:(NSDictionary *)userInfo {
    [self showInView:targetView userInfo:userInfo eventHandler:nil];
}

- (void)showInView:(UIView *)targetView userInfo:(NSDictionary *)userInfo eventHandler:(EventHandlerBlock)eventHandler {
    self.userInfo = userInfo;
    self.eventHandler = eventHandler;
    
    [targetView addSubview:self];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:targetView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:targetView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:targetView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:targetView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    topConstraint.active    = YES;
    bottomConstraint.active = YES;
    leftConstraint.active   = YES;
    rightConstraint.active  = YES;
    
    //蒙层
    [self addSubview:self.maskView];
    [self sendSubviewToBack:self.maskView];
    topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    topConstraint.active    = YES;
    bottomConstraint.active = YES;
    leftConstraint.active   = YES;
    rightConstraint.active  = YES;
    
    
}


#pragma mark - Private
- (UIViewController *)_viewController {
    
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}



#pragma mark - Delegate



#pragma mark - Setter Getter
- (NSString *)viewIdentifier {
    if (!_viewIdentifier) {
        _viewIdentifier = NSStringFromClass([self class]);
    }
    return _viewIdentifier;
}

- (id<EasyViewDelegate>)delegate {
    if (!_delegate) {
        _delegate = (id<EasyViewDelegate>)[self _viewController];
    }
    return _delegate;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSilently)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTriggeredBy:)];
    }
    return _tap;
}
@end
