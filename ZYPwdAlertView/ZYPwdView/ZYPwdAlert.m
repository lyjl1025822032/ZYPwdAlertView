//
//  ZYPwdAlert.h
//  ZYPwdAlertView
//
//  Created by yao on 2017/6/10.
//  Copyright © 2017年 yao. All rights reserved.
//

#import "ZYPwdAlert.h"
#import "UIView+Extension.h"
#import "UIColor+AdditionColor.h"

//原点颜色
#define kDotColor      [UIColor blackColor]
#define kScreenW       [UIScreen mainScreen].bounds.size.width
#define kScreenH       [UIScreen mainScreen].bounds.size.height
#define kColorComplete [UIColor colorWithHexString:@"#0fa2f6"]
#define kColorNormal   [UIColor colorWithHexString:@"#aaaaaa"]
#define kColorLine     [UIColor colorWithHexString:@"#dcdcdc"]
#define kColorBorder   [UIColor colorWithHexString:@"#dcdcdc"]
#define kColorMask     [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.3]

//原点直径
static const CGFloat dotDiameter = 10.f;
//动画执行速度
static const CGFloat duration = 0.25;
//密码位数
static const NSInteger pwdNumber = 8;

@interface ZYPwdInputView ()
/**
 原点数组
 */
@property (strong, nonatomic) NSMutableArray *secureDots;
/**
 数字数组
 */
@property (strong, nonatomic) NSMutableArray *pwdLabels;
/**
 键盘响应者
 */
@property (strong, nonatomic) UITextField *responder;
@end

@implementation ZYPwdInputView

#pragma mark - Life cycle

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    [self addNotifications];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    [self addNotifications];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat margin = dotDiameter*0.5;
    CGFloat lineX = 0.f;
    CGFloat lineY = 0.f;
    CGSize lineSize = CGSizeMake(0.5, self.frame.size.height);
    CGFloat w = self.frame.size.width / self.length;
    
    for (int i = 0; i < self.length-1; i++) {
        UIView *line = self.subviews[i];
        lineX = w*(i+1);
        line.frame = CGRectMake(lineX, lineY, lineSize.width, lineSize.height);
    }
    
    
    for (int i = 0; i < self.pwdLabels.count; i++) {
        UILabel *label = self.pwdLabels[i];
        label.frame = CGRectMake(0.5+self.frame.size.height*i, 0, self.frame.size.height-1, self.frame.size.height-1);
        label.hidden = YES;
        if (_visibleFlage && _responder.text.length) {
            label.hidden = i < _responder.text.length ? NO : YES;
        }
    }
    
    for (int i = 0; i < self.secureDots.count; i++) {
        CAShapeLayer *dot = self.secureDots[i];
        dot.position = CGPointMake(w * (0.5 + i) - margin, self.frame.size.height * 0.5 - margin);
        dot.hidden = YES;
        if (!_visibleFlage && _responder.text.length) {
            dot.hidden = i < _responder.text.length ? NO : YES;
        }
    }
    
}

#pragma mark - Overwrite

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    [self addSubview:self.responder];
    [self.responder becomeFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    [self endEditing:YES];
    return YES;
}

- (BOOL)endEditing:(BOOL)force {
    [super endEditing:force];
    if (force) {
        self.responder.text = nil;
        [self.secureDots enumerateObjectsUsingBlock:^(CAShapeLayer *_Nonnull dot, NSUInteger idx, BOOL * _Nonnull stop) {
            dot.hidden = YES;
        }];
    }
    return force;
}

#pragma mark - Setter/Getter

- (void)setLength:(NSUInteger)length {
    _length = length;
    if (length > 0) {
        [self configurViewWithLength:length];
    }
}

- (void)setVisibleFlage:(BOOL)visibleFlage {
    _visibleFlage = visibleFlage;
}

- (NSMutableArray *)secureDots {
    if (!_secureDots) {
        _secureDots = [NSMutableArray arrayWithCapacity:self.length];
    }
    return _secureDots;
}

- (NSMutableArray *)pwdLabels {
    if (!_pwdLabels) {
        _pwdLabels = [NSMutableArray arrayWithCapacity:self.length];
    }
    return _pwdLabels;
}

- (UITextField *)responder {
    if (!_responder) {
        _responder = [[UITextField alloc] initWithFrame:CGRectZero];
        _responder.clearsOnBeginEditing = YES;
        _responder.keyboardType = UIKeyboardTypeNumberPad;
        _responder.hidden = YES;
    }
    return _responder;
}

#pragma mark - Privite

- (void)configurViewWithLength:(NSUInteger)length {
    
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = kColorBorder.CGColor;
    
    //竖直分割线
    for (int i = 0; i < length - 1; i++) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kColorBorder;
        [self addSubview:line];
    }
    
    //密码原点
    [self.secureDots removeAllObjects];
    for (int i = 0; i < length; i++) {
        CAShapeLayer *dot = [CAShapeLayer layer];
        dot.fillColor = kDotColor.CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, dotDiameter, dotDiameter)];
        dot.path = path.CGPath;
        dot.hidden = YES;
        [self.layer addSublayer:dot];
        [self.secureDots addObject:dot];
    }
    
    //密码数字
    [self.pwdLabels removeAllObjects];
    for (int i = 0; i < length; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 100+i;
        label.hidden = YES;
        [self addSubview:label];
        [self.pwdLabels addObject:label];
    }
}

- (void)addNotifications {
    __weak typeof(&*self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSUInteger length = weakSelf.responder.text.length;
        if (length <= weakSelf.length && weakSelf.inputDidCompletion) {
            if (weakSelf.responder.text.length) {
                UILabel *label = [self viewWithTag:100+length-1];
                label.text = [weakSelf.responder.text substringFromIndex:length-1];
            }
            self.inputDidCompletion(weakSelf.responder.text);
        }else if (length > weakSelf.length) {
            self.responder.text = [weakSelf.responder.text substringToIndex:weakSelf.length];
        }
        
        
        [self.pwdLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_visibleFlage) {
                label.hidden = idx < length ? NO : YES;
            }
        }];
        
        [self.secureDots enumerateObjectsUsingBlock:^(CAShapeLayer *dot, NSUInteger idx, BOOL * stop) {
            if (!_visibleFlage) {
                dot.hidden = idx < length ? NO : YES;
            }
        }];
    }];
}

@end

@interface ZYPwdAlert()
/**
 遮罩
 */
@property (strong, nonatomic) UIView *maskView;
/**
 标题
 */
@property (strong, nonatomic) UILabel *titleLabel;
/**
 是否可见
 */
@property (strong, nonatomic) UIButton *visibleBtn;
/**
 输入区
 */
@property (strong, nonatomic) ZYPwdInputView *pwdInputView;
/**
 确定
 */
@property (strong, nonatomic) UIButton *completeBtn;
/**
 是否完成
 */
@property (assign, nonatomic, getter=isComplete) BOOL complete;
/**
 密码
 */
@property (copy, nonatomic) NSString *pwd;
@end

@implementation ZYPwdAlert

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    //set default value
    self.length = pwdNumber;
    
    CGFloat padding = 15.f;
    CGFloat margin = 15.f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width-padding*2;
    CGFloat titleH = 20.f;
    CGFloat inputH = (width-padding*2)/self.length;
    CGFloat btnH = 44.f;
    CGFloat height = titleH+inputH+btnH+margin*4+1.f;
    
    self.frame = CGRectMake(0, 0, width, height);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    
    /** 标题 */
    self.titleLabel.frame = CGRectMake(padding, margin, inputH*self.length, titleH);
    
    /** 可见按钮 */
    self.visibleBtn.frame = CGRectMake(self.width-inputH-padding, margin, inputH, titleH);
    
    /** 标题分割线 */
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(padding, self.titleLabel.bottom+margin, self.width-padding*2, 0.5)];
    topLine.backgroundColor = kColorLine;
    
    /** 密码输入框 */
    self.pwdInputView.frame = CGRectMake(padding, topLine.bottom+margin, inputH*self.length, inputH);
    self.pwdInputView.visibleFlage = NO;
    
    /** 按钮横向分割线 */
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.pwdInputView.bottom+margin, self.width, 0.5)];
    bottomLine.backgroundColor = kColorLine;
    
    /** 按钮竖直分割线 */
    UIView *bottomVLine = [[UIView alloc] initWithFrame:CGRectMake((self.width-0.5)*0.5, bottomLine.bottom, 0.5, btnH)];
    bottomVLine.backgroundColor = kColorLine;
    
    /** 取消按钮 */
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setFrame:CGRectMake(0, bottomLine.bottom, (self.width-0.5)*0.5, btnH)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kColorComplete forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    /** 完成按钮 */
    self.completeBtn.frame = CGRectMake(bottomVLine.right, bottomLine.bottom, (self.width-0.5)*0.5, btnH);
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.visibleBtn];
    [self addSubview:topLine];
    [self addSubview:self.pwdInputView];
    [self addSubview:bottomLine];
    [self addSubview:bottomVLine];
    [self addSubview:self.completeBtn];
    [self addSubview:cancelBtn];
    
    __weak typeof(&*self)weakSelf = self;
    self.pwdInputView.inputDidCompletion = ^(NSString *pwd) {
        if (pwd.length == weakSelf.pwdInputView.length) {
            weakSelf.pwd = pwd;
            weakSelf.complete = YES;
        }else {
            weakSelf.pwd = @"";
            weakSelf.complete = NO;
        }
    };
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Setter/Getter

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setLength:(NSUInteger)length {
    _length = length;
    self.pwdInputView.length = length;
}

- (void)setComplete:(BOOL)complete {
    _complete = complete;
    if (complete) {
        self.completeBtn.enabled = YES;
        [self.completeBtn setTitleColor:kColorComplete forState:UIControlStateNormal];
    }else {
        self.completeBtn.enabled = NO;
        [self.completeBtn setTitleColor:kColorNormal forState:UIControlStateNormal];
    }
}

- (ZYPwdInputView *)pwdInputView {
    if (!_pwdInputView) {
        _pwdInputView = [[ZYPwdInputView alloc] init];
    }
    return _pwdInputView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication].windows lastObject].bounds];
        _maskView.backgroundColor = kColorMask;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismiss:)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#222222"];
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UIButton *)visibleBtn {
    if (!_visibleBtn) {
        _visibleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_visibleBtn setImage:[UIImage imageNamed:@"visible"] forState:UIControlStateNormal];
        [_visibleBtn setTitleColor:kColorNormal forState:UIControlStateNormal];
        [_visibleBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_visibleBtn addTarget:self action:@selector(handleChangeVisible:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _visibleBtn;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_completeBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_completeBtn setTitleColor:kColorNormal forState:UIControlStateNormal];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_completeBtn setEnabled:NO];
        [_completeBtn addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

#pragma mark - Public

- (void)showView:(UIView *)fatherView {
    [fatherView addSubview:self.maskView];
    [fatherView addSubview:self];
    
    self.center = CGPointMake(fatherView.center.x, (kScreenH - 216) * 0.5);
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    
    __weak typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.maskView.alpha = 1.f;
        weakSelf.alpha = 1.f;
        weakSelf.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.pwdInputView becomeFirstResponder];
        }
    }];
}

#pragma mark - Privite

- (void)dismiss {
    [self.pwdInputView endEditing:YES];
    __weak typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.alpha = 0.f;
        weakSelf.maskView.alpha = 0.f;
        weakSelf.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished) {
        if (finished) {
            weakSelf.complete = NO;
            [weakSelf removeFromSuperview];
            [weakSelf.maskView removeFromSuperview];
        }
    }];
}

- (void)handleChangeVisible:(UIButton *)sender {
    if ([sender.currentImage isEqual:[UIImage imageNamed:@"visible"]]) {
        self.pwdInputView.visibleFlage = YES;
        [sender setImage:[UIImage imageNamed:@"unvisible"] forState:UIControlStateNormal];
    } else {
        self.pwdInputView.visibleFlage = NO;
        [sender setImage:[UIImage imageNamed:@"visible"] forState:UIControlStateNormal];
    }
    [self.pwdInputView layoutSubviews];
}

- (void)complete:(id)sender {
    if (_completeAction) {
        _completeAction(self.pwd);
    }
    [self dismiss];
}

- (void)cancel:(id)sender {
    [self dismiss];
}

- (void)handleDismiss:(UITapGestureRecognizer *)sender {
    [self dismiss];
}

@end
