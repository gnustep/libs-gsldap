/** GSLDAPMatchingRule.m - <title>GSLDAP: Class GSLDAPMatchingRule</title>

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
#include "GSLDAPMatchingRule.h"

//====================================================================
@implementation GSLDAPMatchingRule

//--------------------------------------------------------------------
+(GSLDAPMatchingRule*)ldapMatchingRuleWithLDAPMatchingRuleString:(NSString*)string
                                                        schema:(GSLDAPSchema*)schema
{
  return [[[self alloc]initWithLDAPMatchingRuleString:string
                       schema:schema]autorelease];
}

//--------------------------------------------------------------------
+(GSLDAPMatchingRule*)ldapMatchingRule
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithLDAPMatchingRuleString:(NSString*)string
                             schema:(GSLDAPSchema*)schema
{
  if ((self=[self init]))
    {
      [self setFromLDAPMatchingRuleString:string
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
  DESTROY(_name);
  DESTROY(_syntax);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p - oid: %@ name: %@ syntaxOid: %@",
		   object_get_class_name(self),
		   (void*)self,
                   _oid,
                   _name,
		   [_syntax oid]];
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
-(void)setSyntax:(GSLDAPSyntax*)syntax

{
  ASSIGN(_syntax,syntax);
};

//--------------------------------------------------------------------
-(GSLDAPSyntax*)syntax
{
  return _syntax;
};

//--------------------------------------------------------------------
-(void)setName:(NSString*)name
{
  ASSIGN(_name,name);
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return _name;
};

@end
    
//====================================================================
@implementation GSLDAPMatchingRule (Private)
//( 1.3.6.1.4.1.4203.1.2.1 NAME 'caseExactIA5SubstringsMatch' SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
- (void)setFromLDAPMatchingRuleString:(NSString*)ldapMatchingRuleString
                                schema:(GSLDAPSchema*)schema
{
  BOOL ok=YES;
  NSScanner *aScanner = [NSScanner scannerWithString:ldapMatchingRuleString];

  NSLog(@"ldapMatchingRuleString=%@",ldapMatchingRuleString);

  if ([aScanner scanDiscardString:@"( "]
      || [aScanner scanDiscardString:@"("])    
    {
      NSString* oid=nil;
      NSString* name=nil;

      if ([aScanner scanThruAndDiscardString:@"NAME '"
                    discardedString:&oid])
        {
          ok=[aScanner scanUpToString:@"'"
                       intoString:&name];
        };

      if (ok)
        {
          NSString* syntaxOid=nil;

          NSDebugMLog(@"oid=%@",oid);      
          NSDebugMLog(@"name=%@",name);

          oid=[oid stringByTrimmingSpaces];
          [self setOid:oid];

          name=[name stringByTrimmingSpaces];
          [self setName:name];
          NSDebugMLog(@"scan=[%@]",[ldapMatchingRuleString substringFromIndex:[aScanner scanLocation]]);

          if ([aScanner scanThruAndDiscardString:@"SYNTAX "])
            {
              NSDebugMLog(@"scan=[%@]",[ldapMatchingRuleString substringFromIndex:[aScanner scanLocation]]);

              if (![aScanner scanThruAndDiscardString:@" "
                            discardedString:&syntaxOid])
                ok=[aScanner scanUpToString:@")"
                             intoString:&syntaxOid];

              if (ok)
                {
                  GSLDAPSyntax* syntax=nil;

                  NSDebugMLog(@"syntaxOid=%@",syntaxOid);

                  syntaxOid=[syntaxOid stringByTrimmingSpaces];
                  
                  syntax=[schema syntaxForOid:syntaxOid];
                  if (!syntax)
                    {
                      //TODO
                    }
                  else
                    {
                      [self setSyntax:syntax];
                    };
                  NSDebugMLog(@"self=%@",self);
                }
              else
                {
                  NSDebugMLog(@"Problem 4 parsing: %@",ldapMatchingRuleString);
                  NSDebugMLog(@"scan=[%@]",[ldapMatchingRuleString substringFromIndex:[aScanner scanLocation]]);
                };
            }
          else
            {
              NSDebugMLog(@"Problem 3 parsing: %@",ldapMatchingRuleString);
            };
        }
      else
        {
          NSDebugMLog(@"Problem 2 parsing: %@",ldapMatchingRuleString);
        };
    }
  else
    {
      NSDebugMLog(@"Problem 1 parsing: %@",ldapMatchingRuleString);
    };
};
@end
