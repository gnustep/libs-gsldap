/** GSLDAPSchema.m - <title>GSLDAP: Class GSLDAPSchema</title>

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

#ifndef _GSLDAPSchema_h__ 
#define _GSLDAPSchema_h__ 

@interface GSLDAPSchema: NSObject
{
  NSMutableDictionary* _objectClasses;
  NSMutableDictionary* _objectClassesLC;
  NSMutableDictionary* _attributes;
  NSMutableDictionary* _attributesLC;
  NSMutableDictionary* _matchingRules;
  NSMutableDictionary* _syntaxes;
}

+(GSLDAPSchema*)ldapSchemaWithLDAPAttributesStrings:(NSArray*)attributesStrings;

+(GSLDAPSchema*)ldapSchemaWithLDAPAttributesStrings:(NSArray*)attributesStrings
                                ldapSyntaxesStrings:(NSArray*)syntaxesStrings
                           ldapMatchingRulesStrings:(NSArray*)matchingRulesStrings
                          ldapObjectsClassesStrings:(NSArray*)objectsClassesStrings;

-(id)initWithLDAPAttributesStrings:(NSArray*)attributesStrings;

-(id)initWithLDAPAttributesStrings:(NSArray*)attributesStrings
               ldapSyntaxesStrings:(NSArray*)syntaxesStrings
          ldapMatchingRulesStrings:(NSArray*)matchingRulesStrings
         ldapObjectsClassesStrings:(NSArray*)objectsClassesStrings;

-(GSLDAPAttribute*)attributeNamed:(NSString*)name;
-(NSArray*)attributeNames;

-(GSLDAPObjectClass*)objectClassNamed:(NSString*)name;
-(NSArray*)objectClassNames;

-(NSArray*)attributeNames;

-(GSLDAPMatchingRule*)matchingRuleNamed:(NSString*)name;
-(NSArray*)matchingRuleNames;

-(GSLDAPSyntax*)syntaxForOid:(NSString*)oid;
-(GSLDAPSyntax*)syntaxNamed:(NSString*)oid;
-(NSArray*)syntaxNames;


-(void)addObjectClass:(GSLDAPObjectClass*)objectClass;
-(void)addAttribute:(GSLDAPAttribute*)attribute;
-(void)addSyntax:(GSLDAPSyntax*)syntax;
-(void)addMatchingRule:(GSLDAPMatchingRule*)matchingRule;

//-(NSArray*)attributesForObjectClassNames:(NSArray*)objectClassNames;
-(NSArray*)attributeNamesForObjectClassNames:(NSArray*)objectClassNames;
-(NSArray*)mandatoryAttributeNamesForObjectClassNames:(NSArray*)objectClassNames;
-(NSArray*)nonMandatoryAttributeNamesForObjectClassNames:(NSArray*)objectClassNames;
@end
#endif // _GSLDAPGSLDAPSchema_h__ 
