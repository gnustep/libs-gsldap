/** GSLDAPObjectClass.m - <title>GSLDAP: Class GSLDAPObjectClass</title>

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
#include "GSLDAPObjectClass.h"

//====================================================================
@implementation GSLDAPObjectClass

//--------------------------------------------------------------------
+(GSLDAPObjectClass*)ldapObjectClassWithLDAPObjectClassString:(NSString*)string
                                                       schema:(GSLDAPSchema*)schema
{
  return [[[self alloc]initWithLDAPObjectClassString:string
                       schema:schema]autorelease];
}

//--------------------------------------------------------------------
+(GSLDAPObjectClass*)ldapObjectClass
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithLDAPObjectClassString:(NSString*)string
                            schema:(GSLDAPSchema*)schema
{
  if ((self=[self init]))
    {
      [self setFromLDAPObjectClassString:string
            schema:schema];
    };
  return self;
}

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      _attributes=(NSMutableDictionary*)[NSMutableDictionary new];
      _mandatoryAttributeNames=(NSMutableArray*)[NSMutableArray new];
      _nonMandatoryAttributeNames=(NSMutableArray*)[NSMutableArray new];
    };
  return self;
}

-(void)dealloc
{
  DESTROY(_attributes);
  DESTROY(_mandatoryAttributeNames);
  DESTROY(_nonMandatoryAttributeNames);
  DESTROY(_oid);
  DESTROY(_names);
  DESTROY(_superiors);
  DESTROY(_descriptionText);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p - name: %@ superiors: %@ attributes: %@",
		   object_get_class_name(self),
		   (void*)self,
                   _names,
                   _superiors,
		   _attributes];
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
-(void)addSuperior:(GSLDAPObjectClass*)superior
{
  if (!_superiors)
    _superiors=[NSMutableArray new];
  [_superiors addObject:superior];
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
-(GSLDAPAttribute*)attributeNamed:(NSString*)name
{
  return [_attributes objectForKey:name];
};

//--------------------------------------------------------------------
-(void)addNonMandatoryAttribute:(GSLDAPAttribute*)attribute
{
  [_attributes setObject:attribute
               forKey:[attribute name]];
  [_nonMandatoryAttributeNames addObject:[attribute name]];
};

//--------------------------------------------------------------------
-(void)addMandatoryAttribute:(GSLDAPAttribute*)attribute
{
  [_attributes setObject:attribute
               forKey:[attribute name]];
  [_mandatoryAttributeNames addObject:[attribute name]];
};

//--------------------------------------------------------------------
-(void)addAttributesNamed:(NSArray*)names
               withSchema:(GSLDAPSchema*)schema
               allowsNull:(BOOL)allowsNull
{
  int i=0;
  int count=[names count];
  for(i=0;i<count;i++)
    {
      NSString* name=[names objectAtIndex:i];
      name=[name stringByTrimmingSpaces];
/*      if ([name isEqualToString:@"description"]) 
        name=@"descriptionText";
*/
      GSLDAPAttribute* attribute=[schema attributeNamed:name];
      NSAssert1(attribute,@"No attribute Named:%@",name);
      NSDebugMLog(@"Add %smandatory attribute named %@",(allowsNull ? "Non " : ""),name);
      if (allowsNull)
        [self addNonMandatoryAttribute:attribute];
      else
        [self addMandatoryAttribute:attribute];
    };
};

//--------------------------------------------------------------------
-(NSArray*)attributeNames
{
  return [_attributes allKeys];
}

//--------------------------------------------------------------------
-(NSArray*)attributes
{
  return [_attributes allValues];
};

//--------------------------------------------------------------------
-(NSArray*)mandatoryAttributeNames
{
  return _mandatoryAttributeNames;
};

//--------------------------------------------------------------------
-(NSArray*)nonMandatoryAttributeNames
{
  return _nonMandatoryAttributeNames;
};

//--------------------------------------------------------------------
-(NSArray*)allAttributeNames
{
  NSArray* allAttributeNames=nil;
  NSDebugMLog(@"self=%@",self);
  NSDebugMLog(@"_superiors=%@",_superiors);
  int superiorsCount=[_superiors count];
  if (superiorsCount>0)
    {
      int i=0;
      NSMutableSet* set=(NSMutableSet*)[NSMutableSet set];
      for(i=0;i<superiorsCount;i++)
        {
          GSLDAPObjectClass* superior=[_superiors objectAtIndex:i];
          if (superior!=self)
            {
              NSArray* names=[superior allAttributeNames];
              NSDebugMLog(@"superior names=%@",names);
              if (names)
                [set addObjectsFromArray:names];
            };
        };
      [set addObjectsFromArray:[self attributeNames]];
      allAttributeNames=[set allObjects];
    }
  else
    allAttributeNames=[self attributeNames];
  NSDebugMLog(@"allAttributeNames=%@",allAttributeNames);
  return allAttributeNames;
}

//--------------------------------------------------------------------
-(NSArray*)allMandatoryAttributeNames
{
  NSArray* allMandatoryAttributeNames=nil;
  NSDebugMLog(@"self=%@",self);
  NSDebugMLog(@"_superiors=%@",_superiors);
  int superiorsCount=[_superiors count];
  if (superiorsCount>0)
    {
      int i=0;
      NSMutableSet* set=(NSMutableSet*)[NSMutableSet set];
      for(i=0;i<superiorsCount;i++)
        {
          GSLDAPObjectClass* superior=[_superiors objectAtIndex:i];
          if (superior!=self)
            {
              NSArray* names=[superior allMandatoryAttributeNames];
              NSDebugMLog(@"superior names=%@",names);
              if (names)
                [set addObjectsFromArray:names];
            };
        };
      [set addObjectsFromArray:[self mandatoryAttributeNames]];
      allMandatoryAttributeNames=[set allObjects];
    }
  else
    allMandatoryAttributeNames=[self mandatoryAttributeNames];
  NSDebugMLog(@"allMandatoryAttributeNames=%@",allMandatoryAttributeNames);
  return allMandatoryAttributeNames;
};

//--------------------------------------------------------------------
-(NSArray*)allNonMandatoryAttributeNames
{
  NSSet* allMandatoryAttributeNames=[NSSet setWithArray:[self allMandatoryAttributeNames]];
  NSMutableSet* allAttributeNames=(NSMutableSet*)[NSMutableSet setWithArray:[self allAttributeNames]];
  [allAttributeNames minusSet:allMandatoryAttributeNames];
  NSDebugMLog(@"self=%@",self);
  NSDebugMLog(@"allAttributeNames=%@",allAttributeNames);
  return [allAttributeNames allObjects];
};


@end
    
//====================================================================
@implementation GSLDAPObjectClass (Private)

//--------------------------------------------------------------------
-(void)setFromLDAPObjectClassString:(NSString*)ldapObjectClassString
                             schema:(GSLDAPSchema*)schema
{
  BOOL ok=YES;
  NSScanner *aScanner = [NSScanner scannerWithString:ldapObjectClassString];

  NSDebugMLog(@"ldapObjectClassString=%@",ldapObjectClassString);

  if ([aScanner scanDiscardString:@"( "]
      || [aScanner scanDiscardString:@"("])    
    {
      NSArray* objClassNames=nil;
      NSString* oid=nil;
      NSString *objClassName=nil;

      if ([aScanner scanThruAndDiscardString:@"NAME '"
                    discardedString:&oid])
        {
          ok=[aScanner scanUpToString:@"'"
                       intoString:&objClassName];
          objClassNames=[NSArray arrayWithObject:objClassName];
        }
      else if ([aScanner scanThruAndDiscardString:@"NAME ("
                         discardedString:&oid])
        {
          ok=[aScanner scanUpToString:@")"
                       intoString:&objClassName];
          objClassNames=[objClassName componentsSeparatedByString:@" "];
        }

      if (ok)
        {
          NSString *desc=nil;
          
          if ([aScanner scanThruAndDiscardString:@"DESC '"])
            ok=[aScanner scanUpToString:@"'"
                         intoString:&desc];

          if (ok)
            {
              NSString *superiorName=nil;
              NSString *musts=nil;
              NSString *mays=nil;
              NSArray *mustArray = nil;
              NSArray *mayArray = nil;
              NSArray *superiorNames=nil;
          
              NSDebugMLog(@"objClassName=%@",objClassName);
              if([aScanner scanThruAndDiscardString:@"SUP '"]) 
                {
                  [aScanner scanUpToString:@"'"
                            intoString:&superiorName];
                } 
              else if([aScanner scanThruAndDiscardString:@"SUP ("]) 
                {
                  NSString* tmpString=nil;
                  [aScanner scanUpToString:@")"
                            intoString:&tmpString];
                  superiorNames=[tmpString componentsSeparatedByString:@"$"];
                } 
              else if([aScanner scanThruAndDiscardString:@"SUP "]) 
                {
                  [aScanner scanUpToString:@" "
                            intoString:&superiorName];
                } 
              else
                {
                  superiorName =nil;
                }

              NSDebugMLog(@"superiorName=%@",superiorName);

              if([aScanner scanThruAndDiscardString:@"MUST ("]) 
                {
                  [aScanner scanUpToString:@" )" 
                            intoString:&musts];
                  NSDebugMLog(@"musts=[%@]",musts);
                  mustArray = [musts componentsSeparatedByString:@"$"];
                }
              else if([aScanner scanThruAndDiscardString:@"MUST "]) 
                {
                  [aScanner scanUpToString:@" "
                            intoString:&musts];
                  NSDebugMLog(@"musts=[%@]",musts);
                  mustArray = [musts componentsSeparatedByString:@"$"];
                }

              NSDebugMLog(@"mustArray=%@",mustArray);
              NSDebugMLog(@"ldapObjectClassString=%@",ldapObjectClassString);
              NSDebugMLog(@"scanLocation=%u",[aScanner scanLocation]);
              NSDebugMLog(@"scan=[%@]",[ldapObjectClassString substringFromIndex:[aScanner scanLocation]]);

              if([aScanner scanThruAndDiscardString:@"MAY ("]) 
                {
                  [aScanner scanUpToString:@" )" 
                            intoString:&mays];
                  NSDebugMLog(@"mays=[%@]",mays);
                  mayArray = [mays componentsSeparatedByString:@"$"];
                } 
              else if([aScanner scanThruAndDiscardString:@"MAY "]) 
                {
                  [aScanner scanUpToString:@" " 
                            intoString:&mays];
                  NSDebugMLog(@"mays=[%@]",mays);
                  mayArray = [mays componentsSeparatedByString:@"$"];
                }

              
              NSDebugMLog(@"scanLocation=%u",[aScanner scanLocation]);
              NSDebugMLog(@"scan=[%@]",[ldapObjectClassString substringFromIndex:[aScanner scanLocation]]);
              NSDebugMLog(@"scan str=[%@]",[aScanner string]);
              NSDebugMLog(@"oid=%@",oid);
              NSDebugMLog(@"mayArray=%@",mayArray);
              NSDebugMLog(@"objClassName=%@",objClassName);
              NSDebugMLog(@"mayArray=%@",mayArray);
              NSDebugMLog(@"mustArray=%@",mustArray);

              oid=[oid stringByTrimmingSpaces];
              [self setOid:oid];

              if (objClassNames)
                {
                  int iName=0;
                  for(iName=0;iName<[objClassNames count];iName++)
                    {
                      NSString* name=[objClassNames objectAtIndex:iName];

                      if ([name hasPrefix:@"'"])
                        name=[[name stringByDeletingPrefix:@"'"]
                               stringByDeletingSuffix:@"'"];

                      name=[name stringByTrimmingSpaces];
                      NSDebugMLog(@"name=%@",name);                      

                      if ([name length]>0)
                        [self addName:name];                  
                    };
                };

              [self setDescriptionText:desc];

              if (superiorName)
                {
                  superiorName=[superiorName stringByTrimmingSpaces];
                  GSLDAPObjectClass* superior=[schema objectClassNamed:superiorName];
                  //TODONSAssert1(superior,@"No superior named: '%@'",superiorName);
                  if (superior)
                    [self addSuperior:superior];
                }
              else if (superiorNames)
                {
                  int i=0;
                  for(i=0;i<[superiorNames count];i++)
                    {
                      superiorName=[[superiorNames objectAtIndex:i] stringByTrimmingSpaces];
                      GSLDAPObjectClass* superior=[schema objectClassNamed:superiorName];
                      //TODONSAssert1(superior,@"No superior named:%@",superiorName);
                      if (superior)
                        [self addSuperior:superior];
                    };            
                }
              if ([mustArray count]>0)
                [self addAttributesNamed:mustArray
                      withSchema:schema
                      allowsNull:NO];

              if ([mayArray count]>0)
                [self addAttributesNamed:mayArray
                      withSchema:schema
                      allowsNull:YES];
      
              NSDebugMLog(@"self=%@",self);
            }
          else
            {
              NSDebugMLog(@"Problem 3 parsing: %@",ldapObjectClassString);
            };
        }
      else
        {
          NSDebugMLog(@"Problem 2 parsing: %@",ldapObjectClassString);
        };
    }
  else
    {
      NSDebugMLog(@"Problem 1 parsing: %@",ldapObjectClassString);
    };
};
@end
