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
#ifndef _GSLDAPAttribute_h__ 
#define _GSLDAPAttribute_h__ 

@class GSLDAPSyntax;

@interface GSLDAPAttribute: NSObject
{
  NSMutableArray* _names;
  NSString* _oid;
  GSLDAPSyntax* _syntax;
  NSString* _descriptionText;
}
+(GSLDAPAttribute*)ldapAttributeWithLDAPAttributeString:(NSString*)string
                                                 schema:(GSLDAPSchema*)schema;
+(GSLDAPAttribute*)ldapAttribute;
-(id)initWithLDAPAttributeString:(NSString*)string
                          schema:(GSLDAPSchema*)schema;

-(void)setOid:(NSString*)oid;
-(NSString*)oid;
-(void)setName:(NSString*)name;
-(void)addName:(NSString*)name;
-(NSString*)name;
-(NSArray*)names;
-(NSString*)namesString;
-(void)setSyntax:(GSLDAPSyntax*)syntax;
-(GSLDAPSyntax*)syntax;
-(void)setDescriptionText:(NSString*)desc;
-(NSString*)descriptionText;
@end

#endif // _GSLDAPAttribute_h__ 
