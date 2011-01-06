
#import <Foundation/Foundation.h>

int main(int argc, char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  if (argc <= 1)
    goto bail;
  
  NSMutableArray * plists = [NSMutableArray array];
  for (int i=1; i<argc; ++i) {
    [plists addObject:[NSString stringWithFormat:@"%s", argv[i]]];
  }

  NSMutableDictionary * joined = [NSMutableDictionary dictionary];
  for (NSString * plist in plists) {
    NSDictionary * plistDict = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSDictionary * images = [plistDict objectForKey:@"images"];
    [joined addEntriesFromDictionary:images];
  }
  NSMutableDictionary * joinedPlistDict = [NSMutableDictionary dictionary];
  [joinedPlistDict setObject:joined forKey:@"images"];
  [joinedPlistDict writeToFile:@"joined.plist" atomically:NO];

  goto done;
 bail:

  fprintf(stderr, "usage: joinPlists [plist1, plist2, ...]\n");
  
 done:
  
  [pool release];
  
  return 0;
}
