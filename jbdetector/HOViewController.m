#import "HOViewController.h"
#import <mach-o/dyld.h>
#import <sys/stat.h>
#import <dlfcn.h>

@interface HOViewController ()


@end

@implementation HOViewController

-(BOOL)isJailBreakCheck{
    
    //check cydia
    NSString *cydiaPath = @"/Applications/Cydia.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]){
        return YES;
    }
    
    NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        return YES;
    }
    
    //check cydia if hook NSFileManager
    struct stat stat_info;
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        return YES;
    }
    
    //check JailBreak generate Data Structure
    if (0 == stat("/private/var/lib/apt/", &stat_info)) {
        return YES;
    }
    
    if (0 == stat("/User/Applications/", &stat_info)) {
        return YES;
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //check hook stat
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSLog(@"lib :%s", dylib_info.dli_fname);
        char* kernal = "/usr/lib/system/libsystem_kernel.dylib";
        
        if (strcmp(dylib_info.dli_fname,kernal)!=0) {
            return YES;
        }
    }
    
    
    //checkDylibs
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0 ; i < count; ++i) {
        char* substrate = "Library/MobileSubstrate/MobileSubstrate.dylib";
        
        if (strcmp(_dyld_get_image_name(i),substrate)==0) {
            return YES;
        }
    }
    
    //check Env
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env) {
        return YES;
    }
#endif
    return NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self isJailBreakCheck]) {
        self.statusLabel.text = @"You're Jailbreak";
    }
    else{
        self.statusLabel.text = @"You're not Jailbreak";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
