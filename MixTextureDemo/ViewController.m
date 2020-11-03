//
//  ViewController.m
//  MixTextureDemo
//
//  Created by guoyf on 2020/11/2.
//

#import "ViewController.h"
#import "GLSLView.h"

@interface ViewController ()

@property(nonnull,strong)GLSLView *myView;

@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myView = (GLSLView *)self.view;
    self.myView.mixAlpha = self.alphaSlider.value;
}

- (IBAction)alphaChange:(UISlider *)sender {
    
    self.myView.mixAlpha = sender.value;
    
}

@end
