/** GSLDAPEntry.h - <title>GSLDAP: Class GSLDAPEntry</title>

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

#ifndef _GSLDAPEntry_h__ 
#define _GSLDAPEntry_h__ 

@interface GSLDAPEntry: NSObject
{
  NSMutableDictionary* _kv;
  NSString* _dn;
  NSString* _rdn;
}

+(GSLDAPEntry*)ldapEntry;

+(GSLDAPEntry*)ldapEntryWithConnection:(GSLDAPConnection*)conn
                           ldapMessage:(LDAPMessage*)entryMessage;

-(id)initWithConnection:(GSLDAPConnection*)conn
            ldapMessage:(LDAPMessage*)entryMessage;

-(NSString*)dn;

-(void)setDN:(NSString*)dn;

-(NSString*)rdn;

-(void)setRDN:(NSString*)rdn;

-(void)setRdn:(NSString*)rdn;

-(NSString*)parentDN;
-(void)setParentDN:(NSString*)parentDN;

+(NSString*)rdnFromDN:(NSString*)dn;

-(void)setNewRDN:(NSString*)newRDN
    deleteOldRDN:(BOOL)deleteOldRDN;

-(NSArray*)objectClassNames;

-(int)attributesCount;

-(NSEnumerator*)attributeNameEnumerator;

-(NSArray*)attributeNames;

-(NSArray*)valuesForAttributeNamed:(NSString*)attributeName;

-(void)removeAttributeNamed:(NSString*)attributeName;

-(void)addValue:(id)value
forAttributeNamed:(NSString*)attributeName;

-(void)removeValue:(id)value
 forAttributeNamed:(NSString*)attributeName;

-(void)replaceValue:(id)oldValue
            byValue:(id)newValue
  forAttributeNamed:(NSString*)attributeName;

-(BOOL)hasNonNullValueForAttributeNamed:(NSString*)attributeName;

-(void)setFromConnection:(GSLDAPConnection*)conn
             ldapMessage:(LDAPMessage*)entryMessage;

-(LDAPMod**)ldapMods;
-(NSString*)ldapDiff;
-(LDAPMod**)ldapModsDiffFromEntry:(GSLDAPEntry*)entry;
-(NSString*)ldapDiffFromEntry:(GSLDAPEntry*)entry;

@end

#endif // _GSLDAPEntry_h__
