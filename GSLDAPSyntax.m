/** GSLDAPSyntax.m - <title>GSLDAP: Class GSLDAPSyntax</title>

   Copyright (C) 2002-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sep 2002
   
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

#include <Foundation/NSData.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSNull.h>
#include <Foundation/NSException.h>
#include <Foundation/NSScanner.h>
#include "GSLDAPCom.h"
#include "GSLDAPSyntax.h"

//====================================================================
@implementation GSLDAPSyntax

//--------------------------------------------------------------------
+(GSLDAPSyntax*)ldapSyntaxWithLDAPSyntaxString:(NSString*)string
                                        schema:(GSLDAPSchema*)schema
{
  return [[[self alloc]initWithLDAPSyntaxString:string
                       schema:schema]autorelease];
}

//--------------------------------------------------------------------
+(GSLDAPSyntax*)ldapSyntax
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithLDAPSyntaxString:(NSString*)string
                       schema:(GSLDAPSchema*)schema
{
  if ((self=[self init]))
    {
      [self setFromLDAPSyntaxString:string
            schema:schema];
    };
  return self;
}

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
    };
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_oid);
  DESTROY(_descriptionText);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p - oid: %@ desc: %@",
		   object_get_class_name(self),
		   (void*)self,
                   _oid,
                   _descriptionText];
};

//--------------------------------------------------------------------
-(void)setOid:(NSString*)oid
{
  ASSIGN(_oid,oid);
};

//--------------------------------------------------------------------
-(NSString*)oid
{
  return _oid;
};

//--------------------------------------------------------------------
-(void)setDescriptionText:(NSString*)desc
{
  ASSIGN(_descriptionText,desc);
};

//--------------------------------------------------------------------
-(NSString*)descriptionText
{
  return _descriptionText;
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return [self oid];
};

@end
    
//====================================================================
@implementation GSLDAPSyntax (Private)
//( 1.3.6.1.4.1.1466.115.121.1.49 DESC 'Supported Algorithm' X-BINARY-TRANSFER-REQUIRED 'TRUE' X-NOT-HUMAN-READABLE 'TRUE' )
- (void)setFromLDAPSyntaxString:(NSString*)ldapSyntaxString
                                schema:(GSLDAPSchema*)schema
{
  BOOL ok=YES;
  NSScanner *aScanner = [NSScanner scannerWithString:ldapSyntaxString];
  NSDebugMLog(@"ldapSyntaxString=%@",ldapSyntaxString);
  if ([aScanner scanDiscardString:@"( "]
      || [aScanner scanDiscardString:@"("])    
    {
      NSString* oid=nil;
      NSString* desc=nil;
      if ([aScanner scanThruAndDiscardString:@"DESC '"
                    discardedString:&oid])
        {
          ok=[aScanner scanUpToString:@"'"
                       intoString:&desc];
        }
      if (ok)
        {
          NSDebugMLog(@"oid=%@",oid);      
          NSDebugMLog(@"desc=%@",desc);

          oid=[oid stringByTrimmingSpaces];
          [self setOid:oid];

          [self setDescriptionText:desc];
          NSDebugMLog(@"self=%@",self);
        }
      else
        {
          NSDebugMLog(@"Problem 2 parsing: %@",ldapSyntaxString);
        };
    }
  else
    {
      NSDebugMLog(@"Problem 1 parsing: %@",ldapSyntaxString);
    };
};
@end
