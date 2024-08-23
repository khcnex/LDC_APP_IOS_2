//
//  main.m
//  LdcSampleApp
//
//  Created by Woo HeeMyeong on 2018. 9. 4..
//  Copyright © 2018년 nexgrid. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AppDelegate.h"
#import <dlfcn.h>
#import <sys/types.h>
#import <stdio.h>
#import <stdlib.h>
#import "AppTestDelegate.h"

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

void disable_gdb()
{
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

static inline int sandbox_integrity_compromised(void) __attribute__((always_inline));

int sandbox_integrity_compromised(void)
{
    int result = fork();
    
    if(!result)
        exit(0);
    if(result >= 0)
        return 1;
    return 0;
}
                                                       
int main(int argc, char * argv[])
{
    if(sandbox_integrity_compromised())
    {
        NSLog(@"조작 대응 함수 호출");
        exit(0);
    }
    else
    {
        NSLog(@"정상 호출");
    }
    
    // 디버깅 하지 못하도록 설정한다. 디버깅 하려면 주석으로 막고, 상용 빌드 할때는 풀어줘야 한다. 이것때문에 1시간 날림. 2020.08.21 희명에게 확인해서 알아냄.
    disable_gdb();
    
    @autoreleasepool
    {   
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
		@try
		{
			NSString *runCnt = [defaults stringForKey:@"RUN_CNT"];
		
			runCnt = [NSString stringWithFormat:@"%d", (int)((runCnt == nil)?1:[runCnt integerValue] + 1)];
		
			[defaults setObject:runCnt forKey:@"RUN_CNT"];
			
			if ([defaults synchronize] == false)
			{
				@throw [NSException exceptionWithName:@"Exception" reason:@"APP Run Count Set Fail" userInfo:nil];
			}
		
			NSLog(@"%@%@", @"App Run Cnt : ", runCnt);
		}
		@catch (NSException *exception)
		{
			NSLog(@"Caught %@%@", exception.name, exception.reason);
		}
		
//		return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppTestDelegate class]));
    }
}
