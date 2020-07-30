//
//  DMWEasyView.h
//  VideoDonwload
//
//  Created by FDadmin on 2020/7/24.
//  Copyright © 2020 FDadmin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EasyViewEventType) {
    EventType_Placeholder   = -9999,
    EventType_Cancel        = -100000,
    EventType_Confirm       = -100001,
    EventType_Click         = -4444,
};

@protocol EasyViewDelegate <NSObject>

@optional

/* Code Snippet
 @warning 指定视图事件处理代理方法(视图内部通过NSInvocation优先触发此指定方法<#TargetView#>由视图viewIdentifier属性指定)，未指定的情况下视图调用DMWEasyViewDelegate方法
- (void)handleEventFrom<#TargetView#>:(<#TargetView#> *)targetView eventType:(NSInteger)eventType model:(id _Nullable)model userInfo:(NSDictionary * _Nullable)userInfo {
    
}
*/
- (void)targetView:(UIView *)targetView
         eventType:(NSInteger)eventType
             model:(id _Nullable)model
          userInfo:(NSDictionary * _Nullable)userInfo;

@end

@protocol ViewDataModelProtocol <NSObject>

@property(nullable, nonatomic, weak) id delegate;

/// 控制视图自身点击手势开关
@property(nonatomic, assign) BOOL disableTap;

@end


typedef void(^EventHandlerBlock)(UIView *targetView, NSInteger eventType, id model, NSDictionary * _Nullable userInfo);

@interface DMWEasyView : UIView

@property(nullable, nonatomic, strong) id<ViewDataModelProtocol> model;
@property(nullable, nonatomic, strong) NSDictionary *userInfo;

/// 事件处理block,当block有值时，delegate回调不会触发
@property(nullable, nonatomic, copy) EventHandlerBlock eventHandler;
@property(nonatomic, weak) id<EasyViewDelegate> delegate;

/// The identifier of self, 默认为NSStringFromClass([self class])
@property(nonatomic, copy) NSString *viewIdentifier;


/// 视图自身的默认点击手势。默认打开点击手势
@property(nonatomic, readonly, strong) UITapGestureRecognizer *tap;

/// 用作弹框视图时的蒙层视图，点击蒙层时会调用dismiss方法
@property(nonatomic, strong) UIView *maskView;

/// 用作弹框视图时的显示内容容器视图
@property(nonatomic, strong) UIView *containerView;

/// 绑定视图数据模型
/// @param model 视图数据模型
- (void)bindingModel:(id<ViewDataModelProtocol>)model;

/// 视图布局入口
- (void)layout;

/// 事件触发
/// @param sender 触发事件对象
- (void)eventTriggeredBy:(id)sender;


/// 通知需处理事件(block or delegate)
/// @param eventType 事件内型
/// @param userInfo 用户信息
- (void)sendEvent:(NSInteger)eventType userInfo:(NSDictionary * _Nullable)userInfo;


/// 显示当前视图到目标视图
/// @param targetView 目标视图
/// @param userInfo 用户信息，可以用来传递显示数据
- (void)showInView:(UIView *)targetView userInfo:(NSDictionary * _Nullable)userInfo;


/// 显示当前视图到目标视图
/// @param targetView 目标视图
/// @param userInfo 用户信息
/// @param eventHandler 事件处理block
- (void)showInView:(UIView *)targetView
          userInfo:(NSDictionary * _Nullable)userInfo
        eventHandler:(EventHandlerBlock _Nullable)eventHandler;


/// 移除当前视图显示,会发送取消事件
- (void)dismiss;


/// 移除当前视图显示,不会发送任何事件
- (void)dismissSilently;

@end

NS_ASSUME_NONNULL_END
