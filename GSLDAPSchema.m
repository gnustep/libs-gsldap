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

#include <Foundation/NSData.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSNull.h>
#include <Foundation/NSException.h>
#include <Foundation/NSScanner.h>
#include <Foundation/NSSet.h>
#include "GSLDAPCom.h"
#include "GSLDAPSchema.h"

//====================================================================
@interface GSLDAPSchema (Private)
-(void)addAttributesWithLDAPAttributesStrings:(NSArray*)attributesStrings;
-(void)addObjectClassesWithLDAPObjectClassesStrings:(NSArray*)objectsClassesStrings;
-(void)addSyntaxesWithLDAPSyntaxesStrings:(NSArray*)syntaxesStrings;
-(void)addMatchingRulesWithLDAPMatchingRulesStrings:(NSArray*)matchingRulesStrings;
@end

//====================================================================
@implementation GSLDAPSchema

//--------------------------------------------------------------------
+(GSLDAPSchema*)ldapSchemaWithLDAPAttributesStrings:(NSArray*)attributesStrings
{
  return [[[self alloc]
            initWithLDAPAttributesStrings:attributesStrings]
           autorelease];
}

//--------------------------------------------------------------------
+(GSLDAPSchema*)ldapSchemaWithLDAPAttributesStrings:(NSArray*)attributesStrings
                                ldapSyntaxesStrings:(NSArray*)syntaxesStrings
                           ldapMatchingRulesStrings:(NSArray*)matchingRulesStrings
                          ldapObjectsClassesStrings:(NSArray*)objectsClassesStrings
{
  return [[[self alloc]initWithLDAPAttributesStrings:attributesStrings
                       ldapSyntaxesStrings:syntaxesStrings
                       ldapMatchingRulesStrings:matchingRulesStrings
                       ldapObjectsClassesStrings:objectsClassesStrings]autorelease];
}

//--------------------------------------------------------------------
-(id)initWithLDAPAttributesStrings:(NSArray*)attributesStrings
{
  if ((self=[self init]))
    {
      [self addAttributesWithLDAPAttributesStrings:attributesStrings];
    };
  return self;
}

//--------------------------------------------------------------------
-(id)initWithLDAPAttributesStrings:(NSArray*)attributesStrings
               ldapSyntaxesStrings:(NSArray*)syntaxesStrings
          ldapMatchingRulesStrings:(NSArray*)matchingRulesStrings
         ldapObjectsClassesStrings:(NSArray*)objectsClassesStrings
{
  if ((self=[self init]))
    {
      // Order is important: Attribute need syntaxes and object classes need attributes
      [self addSyntaxesWithLDAPSyntaxesStrings:syntaxesStrings];
      [self addMatchingRulesWithLDAPMatchingRulesStrings:matchingRulesStrings];
      [self addAttributesWithLDAPAttributesStrings:attributesStrings];
      [self addObjectClassesWithLDAPObjectClassesStrings:objectsClassesStrings];
    };
  return self;
}

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      _objectClasses=(NSMutableDictionary*)[NSMutableDictionary new];
      _objectClassesLC=(NSMutableDictionary*)[NSMutableDictionary new];
      _attributes=(NSMutableDictionary*)[NSMutableDictionary new];
      _attributesLC=(NSMutableDictionary*)[NSMutableDictionary new];
      _syntaxes=(NSMutableDictionary*)[NSMutableDictionary new];
      _matchingRules=(NSMutableDictionary*)[NSMutableDictionary new];
    };
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_objectClasses);
  DESTROY(_objectClassesLC);
  DESTROY(_attributes);
  DESTROY(_attributesLC);
  DESTROY(_matchingRules);
  DESTROY(_syntaxes);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p - objectClasses: %@ attributes: %@",
		   object_get_class_name(self),
		   (void*)self,
                   _objectClasses,
                   _attributes];
};

//--------------------------------------------------------------------
-(GSLDAPAttribute*)attributeNamed:(NSString*)name
{
  GSLDAPAttribute* attribute=nil;
  if ((id)name!=(id)[NSNull null])
    {
      attribute=[_attributes objectForKey:name];
      if (!attribute)
        attribute=[_attributesLC objectForKey:[name lowercaseString]];
    };
  return attribute;
};

//--------------------------------------------------------------------
-(NSArray*)attributeNames
{
  return [_attributes allKeys];
};

//--------------------------------------------------------------------
-(GSLDAPObjectClass*)objectClassNamed:(NSString*)name
{
  GSLDAPObjectClass* oc=nil;
  NSDebugMLog(@"name=%@",name);
  if ((id)name!=(id)[NSNull null])
    {
      NSDebugMLog(@"_objectClasses=%@",_objectClasses);
      oc=[_objectClasses objectForKey:name];
      NSDebugMLog(@"oc=%@",oc);
      if (!oc)
        oc=[_objectClassesLC objectForKey:[name lowercaseString]];
    };
  NSDebugMLog(@"oc=%@",oc);
  return oc;
};

//--------------------------------------------------------------------
-(NSArray*)objectClassNames
{
  return [_objectClasses allKeys];
};

//--------------------------------------------------------------------
-(NSArray*)attributeTypeNames
{
  return [self attributeNames];
};

//--------------------------------------------------------------------
-(GSLDAPMatchingRule*)matchingRuleNamed:(NSString*)name
{
  return [_matchingRules objectForKey:name];
};

//--------------------------------------------------------------------
-(NSArray*)matchingRuleNames
{
  return [_matchingRules allKeys];
};

//--------------------------------------------------------------------
-(GSLDAPSyntax*)syntaxForOid:(NSString*)oid
{
  return [_syntaxes objectForKey:oid];
};

//--------------------------------------------------------------------
-(GSLDAPSyntax*)syntaxNamed:(NSString*)oid
{
  return [self syntaxForOid:oid];
};

//--------------------------------------------------------------------
-(NSArray*)syntaxNames
{
  return [_syntaxes allKeys];
};

//--------------------------------------------------------------------
-(void)addObjectClass:(GSLDAPObjectClass*)objectClass
{
  NSArray* objectClassNames=nil;
  int i=0;
  int count=0;
  NSDebugMLog(@"objectClass=%@",objectClass);
  objectClassNames=[objectClass names];
  NSDebugMLog(@"objectClass names=%@",objectClassNames);
  count=[objectClassNames count];
  NSAssert1(count,@"No name for %@",objectClass);
  for(i=0;i<count;i++)
    {
      NSString* name=[objectClassNames objectAtIndex:i];
      if (![self objectClassNamed:name])
        {
          [_objectClasses setObject:objectClass
                       forKey:name];
          [_objectClassesLC setObject:objectClass
                         forKey:[name lowercaseString]];
        };
    };
};

//--------------------------------------------------------------------
-(void)addAttribute:(GSLDAPAttribute*)attribute
{
  NSArray* attributeNames=nil;
  int i=0;
  int count=0;
  NSDebugMLog(@"attribute=%@",attribute);
  attributeNames=[attribute names];
  NSDebugMLog(@"attribute names=%@",attributeNames);
  count=[attributeNames count];
  NSAssert1(count,@"No name for %@",attribute);
  for(i=0;i<count;i++)
    {
      NSString* name=[attributeNames objectAtIndex:i];
      if (![self attributeNamed:name])
        {
          [_attributes setObject:attribute
                       forKey:name];
          [_attributesLC setObject:attribute
                         forKey:[name lowercaseString]];
        };
    };
};

//--------------------------------------------------------------------
-(void)addSyntax:(GSLDAPSyntax*)syntax
{
  NSDebugMLog(@"syntax=%@",syntax);
  [_syntaxes setObject:syntax
             forKey:[syntax oid]];
};

//--------------------------------------------------------------------
-(void)addMatchingRule:(GSLDAPMatchingRule*)matchingRule
{
  NSDebugMLog(@"matchingRule=%@",matchingRule);
  [_matchingRules setObject:matchingRule
                  forKey:[matchingRule name]];
};
/*
-(NSArray*)attributesForObjectClassNames:(NSArray*)objectClassNames
{
  NSMutableSet* attributesSet=(NSMutableSet*)[NSMutableSet set];
  int count=0;
  int i=0;
  NSDebugMLog(@"objectClassNames=%@",objectClassNames);
  count=[objectClassNames count];  
  for(i=0;i<count;i++)
    {
      NSString* objectClassName=[objectClassNames objectAtIndex:i];
      GSLDAPObjectClass* objectClass=[self objectClassNamed:objectClassName];
      NSDebugMLog(@"objectClass=%@",objectClass);
      NSArray* attributes=[objectClass allAttributes];
      NSDebugMLog(@"attributes=%@",attributes);
      [attributesSet addObjectsFromArray:attributes];
    };
  NSDebugMLog(@"attributesSet=%@",attributesSet);
  return [attributesSet allObjects];
}
*/

//--------------------------------------------------------------------
-(NSArray*)attributeNamesForObjectClassNames:(NSArray*)objectClassNames
{
  NSMutableSet* attributesSet=(NSMutableSet*)[NSMutableSet set];
  int count=0;
  int i=0;
  count=[objectClassNames count];
  for(i=0;i<count;i++)
    {
      NSString* objectClassName=[objectClassNames objectAtIndex:i];
      GSLDAPObjectClass* objectClass=[self objectClassNamed:objectClassName];
      NSArray* attributeNames=[objectClass allAttributeNames];
      [attributesSet addObjectsFromArray:attributeNames];
    };
  NSDebugMLog(@"attributesSet=%@",attributesSet);
  return [attributesSet allObjects];
}

//--------------------------------------------------------------------
-(NSArray*)mandatoryAttributeNamesForObjectClassNames:(NSArray*)objectClassNames
{
  NSMutableSet* attributeNamesSet=(NSMutableSet*)[NSMutableSet set];
  int count=0;
  int i=0;
  count=[objectClassNames count];
  for(i=0;i<count;i++)
    {
      NSString* objectClassName=[objectClassNames objectAtIndex:i];
      if ((id)objectClassName!=(id)[NSNull null])
        {
          GSLDAPObjectClass* objectClass=[self objectClassNamed:objectClassName];
          NSArray* attributeNames=[objectClass allMandatoryAttributeNames];
          NSDebugMLog(@"Mandatory attributeNames for %@=%@",[objectClass namesString],attributeNames);
          [attributeNamesSet addObjectsFromArray:attributeNames];
        };
    };
  NSDebugMLog(@"attributeNamesSet=%@",attributeNamesSet);
  return [attributeNamesSet allObjects];
}

//--------------------------------------------------------------------
-(NSArray*)nonMandatoryAttributeNamesForObjectClassNames:(NSArray*)objectClassNames
{
  NSArray* mandatoryAttributeNames=[self mandatoryAttributeNamesForObjectClassNames:objectClassNames];
  NSMutableArray* attributeNames=[[[self attributeNamesForObjectClassNames:objectClassNames] copy]autorelease];
  NSDebugMLog(@"Mandatory attributeNames for %@=%@",objectClassNames,mandatoryAttributeNames);
  [attributeNames removeObjectsInArray:mandatoryAttributeNames];
  NSDebugMLog(@"Non mandatory attributeNames for objectClasses %@=%@",objectClassNames,attributeNames);
  return attributeNames;
}
@end


//====================================================================
@implementation GSLDAPSchema (Private)

//--------------------------------------------------------------------
-(void)addAttributesWithLDAPAttributesStrings:(NSArray*)attributesStrings
{
  int i=0;
  int count=[attributesStrings count];
  for (i=0;i<count;i++)
    {
      GSLDAPAttribute* attribute=nil;
      NSString* ldapString=[attributesStrings objectAtIndex:i];

      NSDebugMLog(@"ldapString=%@",ldapString);

      attribute=[GSLDAPAttribute ldapAttributeWithLDAPAttributeString:ldapString
                                 schema:self];

      NSDebugMLog(@"attribute=%@",attribute);

      NSAssert1([[attribute names]count]>0,@"No name for %@",attribute);

      [self addAttribute:attribute];
    };
};

//--------------------------------------------------------------------
-(void)addObjectClassesWithLDAPObjectClassesStrings:(NSArray*)objectsClassesStrings
{
  int i=0;
  int count=[objectsClassesStrings count];
  for (i=0;i<count;i++)
    {
      GSLDAPObjectClass* objectClass=nil;
      NSString* ldapString=[objectsClassesStrings objectAtIndex:i];

      NSDebugMLog(@"ldapString=%@",ldapString);

      objectClass=[GSLDAPObjectClass ldapObjectClassWithLDAPObjectClassString:ldapString
                                     schema:self];

      NSDebugMLog(@"objectClass=%@",objectClass);
      NSDebugMLog(@"objectClass name=%@",[objectClass name]);

      NSAssert1([objectClass name],@"No name for %@",objectClass);

      if (![self objectClassNamed:[objectClass name]])
        [self addObjectClass:objectClass];
    };
}

//--------------------------------------------------------------------
-(void)addSyntaxesWithLDAPSyntaxesStrings:(NSArray*)syntaxesStrings
{
  int i=0;
  int count=[syntaxesStrings count];
  for (i=0;i<count;i++)
    {
      GSLDAPSyntax* syntax=nil;
      NSString* ldapString=[syntaxesStrings objectAtIndex:i];

      NSDebugMLog(@"ldapString=%@",ldapString);

      syntax=[GSLDAPSyntax ldapSyntaxWithLDAPSyntaxString:ldapString
                           schema:self];

      NSDebugMLog(@"syntax=%@",syntax);
      NSDebugMLog(@"syntax name=%@",[syntax name]);

      NSAssert1([syntax name],@"No name for %@",syntax);

      if (![self syntaxNamed:[syntax name]])
        [self addSyntax:syntax];
    };
};

//--------------------------------------------------------------------
-(void)addMatchingRulesWithLDAPMatchingRulesStrings:(NSArray*)matchingRulesStrings
{
  int i=0;
  int count=[matchingRulesStrings count];
  for (i=0;i<count;i++)
    {
      GSLDAPMatchingRule* matchingRule=nil;
      NSString* ldapString=[matchingRulesStrings objectAtIndex:i];

      NSDebugMLog(@"ldapString=%@",ldapString);

      matchingRule=[GSLDAPMatchingRule ldapMatchingRuleWithLDAPMatchingRuleString:ldapString
                                       schema:self];

      NSDebugMLog(@"matchingRule=%@",matchingRule);
      NSDebugMLog(@"matchingRule name=%@",[matchingRule name]);

      NSAssert1([matchingRule name],@"No name for %@",matchingRule);

      if (![self matchingRuleNamed:[matchingRule name]])
        [self addMatchingRule:matchingRule];
    };
};


@end
