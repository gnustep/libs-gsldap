/** GSLDAPUtils.m - <title>GSLDAP</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 2003
   
   $Revision$
   $Date$
   $Id$

   This file is part of the GNUstep LDAP Library.
   
   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "GSLDAPCom.h"
#include "GSLDAPUtils.h"

//====================================================================
@implementation NSScanner (LDAPScannerExtension)

//--------------------------------------------------------------------
-(BOOL)scanDiscardString:(NSString*)string
{
  int startLoc = [self scanLocation];
  BOOL ok=[self scanString:string
                intoString:NULL];
  if (!ok)
    [self setScanLocation:startLoc]; // rewind

  return ok;
}


//--------------------------------------------------------------------
-(BOOL)scanThruAndDiscardString:(NSString*)string
{
  BOOL ok=NO;
  int startLoc = [self scanLocation];

  [self scanUpToString:string
        intoString:NULL];

  ok=[self scanString:string
           intoString:NULL];

  if (!ok)
    [self setScanLocation:startLoc]; // rewind

  return ok;
}

//--------------------------------------------------------------------
-(BOOL)scanThruAndDiscardString:(NSString*)string
                discardedString:(NSString**)discarded
{
  BOOL ok=NO;
  int startLoc = [self scanLocation];

  ok=[self scanUpToString:string 
           intoString:discarded];

  if (ok)
    {
      ok=[self scanString:string 
               intoString:NULL];
    };

  if (!ok)
    [self setScanLocation:startLoc]; // rewind

  return ok;
};

@end

//====================================================================
void freeMallocArray(char **array)
{
  if (array)
    {
      char **originalPtr = array;

      for (;*array;array++)
        free(*array);
      free(originalPtr);
    };
}

//====================================================================
char *cStringCopy(NSString *string)
{
  char *result=NULL;
  int len = [string cStringLength];

  result = (char*)malloc((len+1)*sizeof(char));
  strncpy(result,[string cString],len+1);
  result[len]='\0';

  return result;
}

//====================================================================
@implementation NSArray (CStringArray)

//--------------------------------------------------------------------
-(char**)cStringArray
{
  char **result=NULL;
  int i=0;
  int len = [self count];

  result = (char**)malloc((len*sizeof(char*))+1);

  for (i = 0 ; i < len; i++)
    result[i] = cStringCopy([self objectAtIndex:i]);
    
  result[i] = NULL; // Null terminated

  return result;
}

//--------------------------------------------------------------------
+ (NSArray *)arrayWithCStringArray:(char **)array
{
  NSMutableArray *result=nil;

  if (array && *array)
    {
      result = [NSMutableArray array];
      for (;*array;array++) 
        [result addObject:[NSString stringWithCString:*array]];
    }

  return result;	
}
@end

//====================================================================
@implementation NSException (GSLDAP)

//--------------------------------------------------------------------
+(void)raise:(NSString*)name
      reason:(NSString*)reason
{
  NSException  *exception=[self exceptionWithName:name
                                reason:reason
                                userInfo:nil];
  [exception raise];
};

@end

//====================================================================
@implementation NSString (LDAPDN)

//--------------------------------------------------------------------
/** Remove spaces in DN:
dc=a, dc=b, dc=c ==> dc=a,dc=b,dc=c
*/
-(NSString*)cleanedDN
{
  NSRange range=[self rangeOfString:@", "];
  if (range.length>0)
    {
      NSMutableString* str=[[self mutableCopy]autorelease];
      unichar   (*caiImp)(NSString*, SEL, unsigned int);
      SEL caiSel = @selector(characterAtIndex:);
      caiImp = (unichar (*)())[str methodForSelector: caiSel];
      int length=[str length];

      do
      {
        int index=range.location+2;

        while (index<length && isspace((*caiImp)(str, caiSel,index)))
          index++;

        [str deleteCharactersInRange:NSMakeRange(range.location+1,index-1-(range.location+1)+1)];

        length=[str length];

        if (range.location+1<length)
          {
            range=[str rangeOfString:@", "
                       options:0
                       range:NSMakeRange(range.location+1,length-(range.location+1))];
          }
        else
          range.length=0;
      }
      while (range.length>0);
      return [NSString stringWithString:str];
    }
  else
    return self;
};

@end
