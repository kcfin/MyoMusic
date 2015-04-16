//
//  BasicCell.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "BasicCell.h"
#import "UIColor+MyoMusicColors.h"

@implementation BasicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor darkerBlue];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.textLabel setTextColor:[UIColor whiteColor]];
    self.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:[UIFont systemFontSize]];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor = [UIColor darkerBlue];
    NSLog(@"DID SELECT CELL");
}


@end
