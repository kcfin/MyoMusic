//
//  BasicCell.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "BasicCell.h"

@implementation BasicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor blackColor];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    NSLog(@"DID SELECT CELL");
}


@end
