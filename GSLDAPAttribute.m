/** GSLDAPAttribute.m - <title>GSLDAP: Class GSLDAPAttribute</title>

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
#include "GSLDAPAttribute.h"


//====================================================================
@interface GSLDAPAttribute (Private)

- (void)setFromLDAPAttributeString:(NSString*)ldapAttributeString
                               schema:(GSLDAPSchema*)schema;
+(NSString*)cleanName:(NSString*)inName;
@end


//====================================================================
@implementation GSLDAPAttribute

//--------------------------------------------------------------------
+(GSLDAPAttribute*)ldapAttributeWithLDAPAttributeString:(NSString*)string
                                                  schema:(GSLDAPSchema*)schema
{
  return [[[self alloc]initWithLDAPAttributeString:string
                       schema:schema]autorelease];
};

//--------------------------------------------------------------------
+(GSLDAPAttribute*)ldapAttribute
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithLDAPAttributeString:(NSString*)string
                           schema:(GSLDAPSchema*)schema
{
  if ((self=[self init]))
    {
      [self setFromLDAPAttributeString:string
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
  DESTROY(_names);
  DESTROY(_oid);
  DESTROY(_syntax);
  DESTROY(_descriptionText);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p - names: %@",
		   object_get_class_name(self),
		   (void*)self,
                   _names];
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
-(void)setName:(NSString*)name
{
  [self addName:name];
};

//--------------------------------------------------------------------
-(void)addName:(NSString*)name
{
  if (name)
    {
      if (!_names)
        _names=[NSMutableArray new];
      if (![_names containsObject:name])
        [_names addObject:name];
    };
};

//--------------------------------------------------------------------
-(NSString*)name
{
  if ([_names count]>0)
    return [_names objectAtIndex:0];
  else
    return nil;
};

//--------------------------------------------------------------------
-(NSArray*)names
{
  return _names;
};

//--------------------------------------------------------------------
-(NSString*)namesString
{
  return [_names componentsJoinedByString:@", "];
}

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
-(void)setDescriptionText:(NSString*)desc
{
  ASSIGN(_descriptionText,desc);
};

//--------------------------------------------------------------------
-(NSString*)descriptionText
{
  return _descriptionText;
};


@end

//====================================================================
@implementation GSLDAPAttribute (Private)

//--------------------------------------------------------------------
/*
( 2.5.18.1 NAME 'createTimestamp' DESC 'xxx' 
EQUALITY generalizedTimeMatch 
ORDERING generalizedTimeOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.24 
SINGLE-VALUE NO-USER-MODIFICATION USAGE directoryOperation )
*/
-(void)setFromLDAPAttributeString:(NSString*)attributeString
                           schema:(GSLDAPSchema*)schema
{
  NSScanner *aScanner = [NSScanner scannerWithString:attributeString];
  NSString *name=nil;
  NSString *desc=nil;
  NSString *syntaxOid=nil;
  NSArray* names=nil;
  NSString* oid=nil;
  BOOL ok=NO;

  if ([aScanner scanDiscardString:@"( "]
      || [aScanner scanDiscardString:@"("])    
    {
      if ([aScanner scanThruAndDiscardString:@"NAME '"
                    discardedString:&oid])
        {
          ok=[aScanner scanUpToString:@"'"
                       intoString:&name];
          names=[NSArray arrayWithObject:name];
        }
      else if ([aScanner scanThruAndDiscardString:@"NAME ("
                         discardedString:&oid])
        {
          ok=[aScanner scanUpToString:@")"
                       intoString:&name];
          names=[name componentsSeparatedByString:@" "];
        };

      if(ok)
        {
          NSDebugMLog(@"name=%@",name);
          NSDebugMLog(@"names=%@",names);

          [aScanner scanThruAndDiscardString:@"DESC '"];
          [aScanner scanUpToString:@"'"
                    intoString:&desc];

          NSDebugMLog(@"desc=%@",desc);

          if ([aScanner scanThruAndDiscardString:@"SYNTAX '"])
            {
              ok=[aScanner scanUpToString:@"'"
                           intoString:&syntaxOid];
            }
          else if ([aScanner scanThruAndDiscardString:@"SYNTAX "])
            {
              ok=[aScanner scanUpToString:@" "
                           intoString:&syntaxOid];
            };

          if (ok)
            {
              int iName=0;

              oid=[oid stringByTrimmingSpaces];
              NSDebugMLog(@"oid=%@",oid);
              [self setOid:oid];

              if (desc)
                [self setDescriptionText:desc];

              NSDebugMLog(@"syntaxOid=%@",syntaxOid);
              if (syntaxOid)
                {
                  GSLDAPSyntax* syntax=nil;
                  NSRange range;

                  syntaxOid=[syntaxOid stringByTrimmingSpaces];

                  range = [syntaxOid rangeOfString:@"{"];
                  if (range.length) 
                    syntaxOid=[syntaxOid substringToIndex:range.location];

                  NSDebugMLog(@"syntaxOid=%@",syntaxOid);

                  syntax=[schema syntaxForOid:syntaxOid];
                  NSDebugMLog(@"syntax=%@",syntax);

                  if (syntax)
                    [self setSyntax:syntax];
                  else
                    NSDebugMLog(@"syntaxNames=%@",[schema syntaxNames]);
                };
              
              for(iName=0;iName<[names count];iName++)
                {
                  name=[names objectAtIndex:iName];

                  if ([name hasPrefix:@"'"])
                    name=[[name stringByDeletingPrefix:@"'"]
                           stringByDeletingSuffix:@"'"];

                  name = [[self class] cleanName:name];
                  NSDebugMLog(@"name=%@",name);
              
                  if (name)
                    {
                      /*if ([name isEqualToString:@"description"]) 
                        [self addName:@"descriptionText"];
                      else*/
                        [self addName:name];
                    };
                };
            }
          else
            {
              NSDebugMLog(@"Problem 3 parsing: %@",attributeString);
            };
        }
      else
        {
          NSDebugMLog(@"Problem 2 parsing: %@",attributeString);
        };
    }
  else
    {
      NSDebugMLog(@"Problem 1 parsing: %@",attributeString);
    };
};

//--------------------------------------------------------------------
+(NSString*)cleanName:(NSString*)name
{
  NSRange range;
  
  name=[name stringByTrimmingSpaces];

  range=[name rangeOfString:@";"];
  if (range.length) 
    name=[name substringToIndex:range.location];
  return name;
}

@end
