//
//  HZChatInputView.m
//  ChatInputView
//
//  Created by zz go on 2018/11/8.
//  Copyright © 2018年 zenonhuang. All rights reserved.
//
#import "HZChatInputView.h"

@interface HZChatInputView ()<UITextViewDelegate>
///整个 input 的最小高
//@property (nonatomic,assign) int minHeight;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UILabel    *placeholderLabel;
@property (nonatomic,strong) UIButton   *sendButton;
@property (nonatomic,strong) UIButton   *imageButton;

@property (nonatomic,strong) NSLayoutConstraint *heightConstraint;

//判断刘海屏, VC 中的 viewDidLayoutSubviews 才生效
@property (nonatomic,assign) CGFloat inputViewBottom;
//用于比对text高度变化
@property (nonatomic,assign) NSInteger textHeight;
@end

@implementation HZChatInputView

@synthesize inputTextFont = _inputTextFont;

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor whiteColor];
    self.verticalSpace = 10;
    self.minHeight     = (self.verticalSpace*2)+35;
    self.maxTextHeight = 80;
    
    [self addSubview:self.sendButton];
    {
        [self addSubview:self.textView];
        [self.textView addSubview:self.placeholderLabel];
        [self.textView addSubview:self.imageButton];
    }
  
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self setupLayout];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - override
-(CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0) {
        size.height = self.minHeight;
    }
    return size;
}

#pragma mark - public
+ (HZChatInputView *)addFromChatView:(UIView *)chatView{
    HZChatInputView *chatInputView = [[HZChatInputView alloc] init];
    [chatView addSubview:chatInputView];
    
    [chatInputView layoutChatInputView:chatView];
    
    return chatInputView;
}

#pragma mark - private
- (void)setupLayout{
    CGFloat viewHeigt = self.frame.size.height;
    CGFloat textHeight  = ( viewHeigt > 0? viewHeigt : self.minHeight ) - (self.verticalSpace*2)-self.inputViewBottom;
    
    self.textView.frame = CGRectMake(15, 10, 287, textHeight );
    self.imageButton.frame = CGRectMake(244, 5, 29, 25);
    UIEdgeInsets insets = self.textView.textContainerInset;
    self.placeholderLabel.frame = CGRectMake(insets.left, 7, self.textView.frame.size.width-7, 21);
    
    [self layoutSendButton];
}

- (void)layoutChatInputView:(UIView *)chatView{
    //防止与autosize冲突，一定要写，否则不能正常进行
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:chatView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    //距离superView的左边0
    NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:chatView
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1
                                                                       constant:0];
    //距离superView的右边0像素
    NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:chatView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1
                                                                        constant:0];
    //自身高度为
    CGFloat height = (self.minHeight + self.inputViewBottom);
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1                                                                         constant:height];
    
    [chatView addConstraint:bottomConstraint];
    [chatView addConstraint:leadConstraint];
    [chatView addConstraint:trailConstraint];
    [chatView addConstraint:self.heightConstraint];
}

- (void)layoutSendButton{
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
  
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:-10-(self.inputViewBottom)];
    
    NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1
                                                                        constant:-14];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1                                                                         constant:35];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1                                                                         constant:46];
    [self  addConstraint:bottomConstraint];
    [self  addConstraint:trailConstraint];
    [self  addConstraint:heightConstraint];
    [self  addConstraint:widthConstraint];
}

#pragma mark - delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        [self tapSendButton:nil];
        return NO;
    }
    return YES;
}

#pragma mark - action
- (void)tapImageButton:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(hz_chatInputView:tapImageButton:)]) {
        [self.delegate hz_chatInputView:self tapImageButton:sender];
    }
}

- (void)tapSendButton:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(hz_chatInputView:sendText:)]) {
        [self.delegate hz_chatInputView:self sendText:self.textView.text];
    }
    
    [self.textView resignFirstResponder];
}

#pragma mark  notification
- (void)textDidChange:(NSNotification *)notification
{
    UITextView *textView = notification.object;
    BOOL hasText = self.text.length > 0;
    // 占位文字是否显示
    self.placeholderLabel.hidden = hasText;
    // 图片按钮是否显示
    self.imageButton.hidden = hasText;
    //发送按钮状态
    self.sendButton.enabled = hasText;
    self.sendButton.backgroundColor = self.sendButton.enabled ? self.sendButtonNormalColor : self.sendButtonDisableColor;
    
    NSInteger height = ceilf([textView sizeThatFits:CGSizeMake(textView.bounds.size.width, MAXFLOAT)].height);
    
    if (self.textHeight != height) {
        self.textHeight = height;
        // 最大高度，可以滚动
        textView.scrollEnabled = (height > self.maxTextHeight) && (self.maxTextHeight > 0);
        
        if (textView.scrollEnabled == NO) {
            
            CGRect textRect = textView.frame;
            CGSize textSize = textRect.size;
            // height 计算有误差，通过比较，不让 textheight 小于最小高度
            CGFloat space = self.verticalSpace*2;
            CGFloat textViewHeight = (self.minHeight-space);
            textSize.height = height> textViewHeight ? height : textViewHeight ;
            textView.frame = CGRectMake( textRect.origin.x, textRect.origin.y,textSize.width,textSize.height);

            self.heightConstraint.constant = textSize.height+space+ self.inputViewBottom  ;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(hz_chatInputView:textChange:)]) {
        [self.delegate hz_chatInputView:self textChange:textView.text];
    }
    
}

- (void)keyboardWillShowNotification:(NSNotification *)notification{
    if ([self.delegate respondsToSelector:@selector(hz_chatInputView:keyboardWillShow:)]) {
        [self.delegate hz_chatInputView:self keyboardWillShow:notification.userInfo];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification{
    if ([self.delegate respondsToSelector:@selector(hz_chatInputView:keyboardWillHide:)]) {
        [self.delegate hz_chatInputView:self keyboardWillHide:notification.userInfo];
    }
}


#pragma mark - getter
- (NSString *)text{
    
    return self.textView.text;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor grayColor];//#F7F7F7
        _textView.font       = self.inputTextFont;
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.textContainerInset = UIEdgeInsetsMake(7, 15, 7, 15);
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.returnKeyType = UIReturnKeySend ;
        _textView.delegate = self;
    }
    
    return _textView;
}

- (UIFont *)inputTextFont{
    if(!_inputTextFont) {
        _inputTextFont =  [UIFont fontWithName:@"PingFang-SC-Regular" size:15];
    }
    return _inputTextFont;
}

- (UILabel *)placeholderLabel{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textColor = [UIColor blackColor];
        _placeholderLabel.font      = self.inputTextFont;
        _placeholderLabel.text      = @"请输入";
    }
    return _placeholderLabel;
}


- (UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        [_sendButton addTarget:self
                        action:@selector(tapSendButton:)
              forControlEvents:UIControlEventTouchUpInside];
        _sendButton.backgroundColor = self.sendButtonDisableColor;
        _sendButton.enabled = NO;
        
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        
        {//Normal
            [_sendButton setTitleColor:[UIColor blackColor]
                              forState:UIControlStateNormal];
            [_sendButton setTitle:@"发送"
                         forState:UIControlStateNormal];
        }
        {//Disabled
            [_sendButton setTitleColor:[UIColor whiteColor]
                              forState:UIControlStateDisabled];
        }
    }
    return _sendButton;
}

- (UIButton *)imageButton{
    if (!_imageButton) {
        _imageButton = [[UIButton alloc] init];
        [_imageButton setImage:[UIImage imageNamed:@"Group"] forState:UIControlStateNormal];
        [_imageButton addTarget:self
                         action:@selector(tapImageButton:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}

- (CGFloat)inputViewBottom{
    _inputViewBottom = 0;
    if (@available(iOS 11.0, *)) {
        _inputViewBottom =  [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    return _inputViewBottom;
}

#pragma mark - setter
- (void)setTextViewBackgroundColor:(UIColor *)textViewBackgroundColor{
    _textViewBackgroundColor = textViewBackgroundColor;
    self.textView.backgroundColor = textViewBackgroundColor;
}

- (void)setInputTextFont:(UIFont *)inputTextFont{
    _inputTextFont = inputTextFont;
    self.placeholderLabel.font = self.textView.font = inputTextFont;
}

- (void)setTextInsets:(UIEdgeInsets)textInsets{
    self.textView.textContainerInset = textInsets;
}

- (void)setTextViewCornerRadius:(CGFloat)textViewCornerRadius{
    self.textView.layer.cornerRadius = textViewCornerRadius;
}

- (void)setSendButtonCornerRadius:(CGFloat)sendButtonCornerRadius{
    self.sendButton.layer.cornerRadius = sendButtonCornerRadius;
}

- (void)setPlaceholderText:(NSString *)placeholderText{
    _placeholderText = placeholderText;
    self.placeholderLabel.text = placeholderText;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}
- (void)setText:(NSString *)text{
    self.textView.text = text;
}

- (void)setSendButtonNormalColor:(UIColor *)sendButtonNormalColor{
    _sendButtonNormalColor = sendButtonNormalColor;
    if (self.sendButton.enabled) {
        self.sendButton.backgroundColor = sendButtonNormalColor;
    }
}

- (void)setSendButtonDisableColor:(UIColor *)sendButtonDisableColor{
    _sendButtonDisableColor = sendButtonDisableColor;
    if (!self.sendButton.enabled) {
        self.sendButton.backgroundColor = sendButtonDisableColor;
    }
}
@end
