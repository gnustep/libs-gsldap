/** GSLDAPEntry.m - <title>GSLDAP: Class GSLDAPEntry</title>

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

#include <Foundation/NSValue.h>
#include <Foundation/NSNull.h>
#include <Foundation/NSException.h>
#include <Foundation/NSSet.h>
#include <Foundation/NSCalendarDate.h>
#include "GSLDAPCom.h"
#include "GSLDAPEntry.h"

//NSMapTable *cToNSStringPropertyNames=NULL;

NSString* propertyNameFromCStringPropertyName(const char* cStringPropertyName)
{
  return [NSString stringWithCString:cStringPropertyName];
};

//====================================================================
@implementation GSLDAPEntry

//--------------------------------------------------------------------
+(void)initialize
{
  static BOOL initialized=NO;
  if (!initialized)
    {
      initialized=YES;
/*      cToNSStringPropertyNames = NSCreateMapTable(NSObjectMapKeyCallBacks,
                                                  NSObjectMapValueCallBacks,
                                                  128);
*/
    };
};

//--------------------------------------------------------------------
+(GSLDAPEntry*)ldapEntry
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
+(GSLDAPEntry*)ldapEntryWithConnection:(GSLDAPConnection*)conn
                           ldapMessage:(LDAPMessage*)entryMessage
{
  return [[[self alloc]initWithConnection:conn
                       ldapMessage:entryMessage]autorelease];
}

//--------------------------------------------------------------------
-(id)initWithConnection:(GSLDAPConnection*)conn
            ldapMessage:(LDAPMessage*)entryMessage
{
  if ((self=[self init]))
    {
      [self setFromConnection:conn
            ldapMessage:entryMessage];
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
  DESTROY(_kv);
  DESTROY(_dn);
  DESTROY(_rdn);
  [super dealloc];
}

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat: @"<%s %p - dn: %@ rdn: %@ values: %@",
		   object_get_class_name(self),
		   (void*)self,
                   _dn,
                   _rdn,
		   _kv];
};

//--------------------------------------------------------------------
-(NSString*)dn
{
  NSDebugMLog(@"dn:%@",_dn);
  return _dn;
}

//--------------------------------------------------------------------
-(void)setDN:(NSString*)dn
{
  ASSIGN(_dn,[dn cleanedDN]);
  NSDebugMLog(@"dn:%@",_dn);
};

//--------------------------------------------------------------------
-(NSString*)rdn
{
  return _rdn;
}

//--------------------------------------------------------------------
-(void)setRDN:(NSString*)rdn
{
  ASSIGN(_rdn,rdn);
};

//--------------------------------------------------------------------
-(void)setRdn:(NSString*)rdn
{
  [self setRDN:rdn];
};

//--------------------------------------------------------------------
-(NSString*)parentDN
{
  NSString *parentDN=nil;
  char **explodedDn = ldap_explode_dn([[self dn]cString],0);
  NSMutableArray* dnArray=[[[NSArray arrayWithCStringArray:explodedDn] mutableCopy] autorelease];
  freeMallocArray (explodedDn);
  explodedDn=NULL;

  [dnArray removeObjectAtIndex:0];
  parentDN = [dnArray componentsJoinedByString:@","];
  return parentDN;  
};

//--------------------------------------------------------------------
-(void)setParentDN:(NSString*)parentDN
{
  [self setDN:[NSString stringWithFormat:@"%@,%@",[self rdn],parentDN]];
};

//--------------------------------------------------------------------
+(NSString*)rdnFromDN:(NSString*)dn
{
  NSString* rdn=nil;
  if (dn)
    {
      char **explodedDn = ldap_explode_dn([dn cString],0);
      if (explodedDn)
        {
          rdn=[NSString stringWithCString:explodedDn[0]];
          freeMallocArray(explodedDn);
          explodedDn=NULL;
        };
    };
  return rdn;  
};

//--------------------------------------------------------------------
-(void)setNewRDN:(NSString*)newRDN
    deleteOldRDN:(BOOL)deleteOldRDN
{  
  char ** explodedNewRdn=NULL;
  NSString* newRDNType=nil;
  NSString* newRDNValue=nil;
  char **explodedDn = NULL;
  NSMutableArray* dnArray=nil;
  NSString* newDN=nil;

  explodedNewRdn=ldap_explode_rdn([newRDN cString],0);
  newRDNType=[NSString stringWithCString:explodedNewRdn[0]];
  newRDNValue=[NSString stringWithCString:explodedNewRdn[1]];

  freeMallocArray (explodedNewRdn);
  explodedNewRdn=NULL;

  [self addValue:newRDNValue
        forAttributeNamed:newRDNType];

  if (deleteOldRDN)
    {
      char ** explodedOldRdn=ldap_explode_dn([[self rdn]cString],0);
      NSString* oldRDNType=[NSString stringWithCString:explodedOldRdn[0]];
      NSString* oldRDNValue=[NSString stringWithCString:explodedOldRdn[1]];
      freeMallocArray (explodedOldRdn);
      explodedOldRdn=NULL;
      
      [self removeValue:oldRDNValue
            forAttributeNamed:oldRDNType];
    };
  [self setRDN:newRDN];

  explodedDn = ldap_explode_dn([[self dn]cString],0);
  dnArray=[[[NSArray arrayWithCStringArray:explodedDn] mutableCopy] autorelease];
  freeMallocArray (explodedDn);
  explodedDn=NULL;

  [dnArray replaceObjectAtIndex:0
           withObject:newRDN];
  newDN = [dnArray componentsJoinedByString:@","];
  [self setDN:newDN];
};

//--------------------------------------------------------------------
-(NSArray*)objectClassNames
{
  return [self valuesForAttributeNamed:@"objectClass"];
};

//--------------------------------------------------------------------
-(int)attributesCount
{
  return [_kv count];
};

//--------------------------------------------------------------------
-(NSEnumerator*)attributeNameEnumerator
{
  return [_kv keyEnumerator];
};

//--------------------------------------------------------------------
-(NSArray*)attributeNames
{
  return [_kv allKeys];
};

//--------------------------------------------------------------------
-(NSArray*)valuesForAttributeNamed:(NSString*)attributeName
{
  return [_kv objectForKey:attributeName];
};

//--------------------------------------------------------------------
-(void)removeAttributeNamed:(NSString*)attributeName
{
  return [_kv setObject:[NSNull null]
              forKey:attributeName];
};

//--------------------------------------------------------------------
-(void)addValue:(id)value
forAttributeNamed:(NSString*)attributeName
{
  id vc=nil;
  NSDebugMLog(@"attributeName='%@' value='%@'",attributeName,value);
  if (!_kv)
    _kv=(NSMutableDictionary*)[NSMutableDictionary new];
  vc=[_kv objectForKey:attributeName];
  NSDebugMLog(@"attributeName: %@ vc %@=%@",attributeName,[vc class],vc);
  if (vc)
    {
      if ([vc isKindOfClass:[NSArray class]])
        [vc addObject:value];
      else
        [_kv setObject:[NSMutableArray arrayWithObjects:vc,value,nil]
             forKey:attributeName];
    }
  else
    [_kv setObject:[NSMutableArray arrayWithObject:value]
         forKey:attributeName];
  vc=[_kv objectForKey:attributeName];
  NSDebugMLog(@"attributeName: %@ vc %@=%@",attributeName,[vc class],vc);
};

//--------------------------------------------------------------------
-(void)removeValue:(id)value
forAttributeNamed:(NSString*)attributeName
{
  NSDebugMLog(@"attributeName='%@' value='%@'",attributeName,value);
  [self replaceValue:value
        byValue:nil
        forAttributeNamed:attributeName];
};

//--------------------------------------------------------------------
-(void)replaceValue:(id)oldValue
            byValue:(id)newValue
  forAttributeNamed:(NSString*)attributeName
{
  NSDebugMLog(@"attributeName='%@' oldValue='%@' newValue='%@'",attributeName,oldValue,newValue);
  NSString* stringNewValue=newValue;
  if ([stringNewValue isKindOfClass:[NSNull class]])
    stringNewValue=nil;
  else if (![stringNewValue isKindOfClass:[NSString class]])
    stringNewValue=[newValue description];
  NSDebugMLog(@"newValue='%@' stringNewValue='%@'",
              newValue,stringNewValue);
  if (!_kv && [stringNewValue length]>0)
    _kv=[NSMutableDictionary new];
  if (_kv)
    {
      id vc=nil;
      vc=[_kv objectForKey:attributeName];
      NSDebugMLog(@"vc %@=%@",[vc class],vc);
      if (vc)
        {
          NSString* stringOldValue=oldValue;
          if ([stringOldValue isKindOfClass:[NSNull class]])
            stringOldValue=nil;
          else if (![stringOldValue isKindOfClass:[NSString class]])
            stringOldValue=[oldValue description];


          NSDebugMLog(@"oldValue='%@' stringOldValue='%@'",
                      oldValue,stringOldValue);

          if ([vc isKindOfClass:[NSArray class]])
            {
              int i=0;
              int count=[vc count];
              BOOL alreadyExistingNewValue=NO;
              BOOL replaced=NO;
              NSDebugMLog(@"vc=%@",vc);
              for(i=0;i<count;i++)
                {                  
                  id v=[vc objectAtIndex:i];
                  NSString* vString=[NSString stringWithFormat:@"%@",v];
                  NSDebugMLog(@"v='%@' vString='%@'",
                              v,vString);
                  if (([v isKindOfClass:[NSNull class]]
                       && !stringOldValue)
                      || [stringOldValue isEqual:vString])
                    {
                      NSDebugMLog(@"Found oldValue at index:%d alreadyExistingNewValue=%d",
                                  i,alreadyExistingNewValue);
                      if (newValue && stringNewValue && !alreadyExistingNewValue)
                        [vc replaceObjectAtIndex:i
                            withObject:newValue];
                      else
                        {
                          [vc removeObjectAtIndex:i];
                          count--;
                          i--;
                        }
                      replaced=YES;
                    }
                  else if (([v isKindOfClass:[NSNull class]]
                            && !stringNewValue)
                           || [stringNewValue isEqual:vString])
                    {
                      NSDebugMLog(@"Found newValue at index:%d replaced=%d",
                                  i,replaced);
                      if (replaced)
                        {
                          [vc removeObjectAtIndex:i];
                          count--;
                          i--;
                        };
                      alreadyExistingNewValue=YES;
                    };
                };
              NSDebugMLog(@"vc=%@",vc);
            };
        }
      else if ([stringNewValue length]>0)
        {
          [_kv setObject:[NSMutableArray arrayWithObject:newValue]
               forKey:attributeName];
        }
      vc=[_kv objectForKey:attributeName];
      NSDebugMLog(@"vc %@=%@",[vc class],vc);
    };
};

//--------------------------------------------------------------------
-(BOOL)hasNonNullValueForAttributeNamed:(NSString*)attributeName
{
  BOOL hasNonNull=NO;
  NSDebugMLog(@"attributeName=%@",attributeName);
  NSArray* values=[self valuesForAttributeNamed:attributeName];
  NSDebugMLog(@"values %@=%@",[values class],values);
  if (values)
    {
      int i=0;
      int count=[values count];
      for(i=0;!hasNonNull && i<count;i++)
        {
          id value=[values objectAtIndex:i];
          if ([value isKindOfClass:[NSString class]])
            hasNonNull=([value length]>0);
          else if ([value isKindOfClass:[NSData class]])
            hasNonNull=([value length]>0);
          else 
            hasNonNull=(![value isKindOfClass:[NSNull class]]);
        };
    };
  NSDebugMLog(@"hasNonNull=%d",hasNonNull);
  return hasNonNull;
};

//--------------------------------------------------------------------
-(void)setFromConnection:(GSLDAPConnection*)conn
             ldapMessage:(LDAPMessage*)entryMessage
{
  char *name=NULL;
  LDAP* ldapConn=NULL;
  if (_kv)
    [_kv removeAllObjects];
  else
    _kv=(NSMutableDictionary*)[NSMutableDictionary new];

  ldapConn=[conn ldapConn];
  name = ldap_get_dn(ldapConn,entryMessage);
  if (!name)
    {
      NSDebugMLog(@"NO NAME");
    }
  else
    {
      char **values=NULL;
      BerElement *ber=NULL;

      [self setDN:[NSString stringWithCString:name]];
      [self setRDN:[[self class] rdnFromDN:[NSString stringWithCString:name]]];
      free (name);
      
      name = ldap_first_attribute(ldapConn,entryMessage,&ber);
      do 
        {
          NSString *attribute = propertyNameFromCStringPropertyName(name);
          
          values = ldap_get_values(ldapConn,entryMessage,name);
          if (!values)
            {
              NSDebugMLog(@"NO VALUES");
              //TODO
            }
          else
            {
              if (*values)
                {
                  NSArray* valuesArray=[NSArray arrayWithCStringArray:values];
                  [_kv setObject:valuesArray
                       forKey:attribute];
                };
              ldap_value_free(values);
            };
        }
      while ((name =ldap_next_attribute(ldapConn,entryMessage,ber)));
      ber_free(ber,0);
    };
}

//--------------------------------------------------------------------
+(NSMutableArray*)ldapAttributeValuesAsStrings:(NSArray*)values
                                      keepNull:(BOOL)keepNull
{
  int i=0;
  int count=[values count];
  NSMutableArray* valuesStrings=nil;
  for(i=0;i<count;i++)
    {
      id value=[values objectAtIndex:i];
      if ([value isKindOfClass:[NSNull class]])
        {
          if (keepNull)
            value=@"";
          else
            value=nil;
        }
      if (value)
        {
          NSString* valueString=nil;
          if ([value isKindOfClass:[NSString class]])
            {
              if ([value length]>0 || keepNull)
                valueString=value;
            }
          else
            valueString=[value description];
          if (valueString)
            {
              if (!valuesStrings)
                valuesStrings=(NSMutableArray*)[NSMutableArray array];
              [valuesStrings addObject:valueString];
            };
        };
    };
  return valuesStrings;
}

//--------------------------------------------------------------------
+(int)ldapAttributeValuesNotNullCount:(NSArray*)values
{
  int i=0;
  int count=[values count];
  int resultCount=0;
  for(i=0;i<count;i++)
    {
      id value=[values objectAtIndex:i];
      if (![value isKindOfClass:[NSNull class]])
        {
          if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSData class]])
            {
              if ([value length]>0)
                resultCount++;
            }
          else
            {
              value=[value description];
              if ([value length]>0)
                resultCount++;
            };
        };
    };
  return resultCount;
}

//--------------------------------------------------------------------
+(BOOL)diffBetweenNewValues:(NSArray*)newValues
               andOldValues:(NSArray*)oldValues
            intoAddedValues:(NSArray**)addedValuesPtr
              deletedValues:(NSArray**)deletedValuesPtr
             replacedValues:(NSArray**)replacedValuesPtr
{
  NSMutableArray* addedValues=nil;
  NSMutableArray* deletedValues=nil;
  NSMutableArray* replacedValues=nil;
  BOOL areAllDeleted=YES;
  BOOL areAllAdded=YES;
  BOOL isChange=NO;
  int i=0;
  NSMutableArray* newValuesStrings=[self ldapAttributeValuesAsStrings:newValues
                                         keepNull:YES];
  NSMutableArray* oldValuesStrings=[self ldapAttributeValuesAsStrings:oldValues
                                         keepNull:YES];
  int newValuesCount=[newValues count];
  int oldValuesCount=[oldValues count];
  NSDebugMLog(@"newValues=%@",newValues);
  NSDebugMLog(@"oldValues=%@",oldValues);
  NSDebugMLog(@"newValuesStrings=%@",newValuesStrings);
  NSDebugMLog(@"oldValuesStrings=%@",oldValuesStrings);
  if (newValuesCount==0)
      areAllAdded=NO;
  if (oldValuesCount==0)
      areAllDeleted=NO;
  for(i=newValuesCount-1;i>=0;i--)
    {
      NSString* value=[newValuesStrings objectAtIndex:i];
      NSDebugMLog(@"value=%@",value);
      if ([value length]>0)
        {
          int index=[oldValuesStrings indexOfObject:value];
          NSDebugMLog(@"index=%d",index);
          if (!oldValuesStrings || index==NSNotFound) //No Old Values
            {
              if (!addedValues)
                addedValues=(NSMutableArray*)[NSMutableArray array];
              [addedValues addObject:[newValues objectAtIndex:i]];
              NSDebugMLog(@"added: %@",[newValues objectAtIndex:i]);
              isChange=YES;
            }
          else
            {
              areAllAdded=NO;
              areAllDeleted=NO;
              [oldValuesStrings replaceObjectAtIndex:index
                                withObject:@""]; // Won't consider it again.
            };
        };
    };
  NSDebugMLog(@"oldValuesStrings=%@",oldValuesStrings);
  for(i=oldValuesCount-1;i>=0;i--)
    {
      NSString* value=[oldValuesStrings objectAtIndex:i];
      if ([value length]>0)
        {
          if (!deletedValues)
            deletedValues=(NSMutableArray*)[NSMutableArray array];
          [deletedValues addObject:[oldValues objectAtIndex:i]];
          NSDebugMLog(@"deleted: %@",[oldValues objectAtIndex:i]);
          isChange=YES;
        };
    };
  NSDebugMLog(@"areAllDeleted=%d areAllAdded=%d isChange=%d",areAllDeleted,areAllAdded,isChange);
  if (areAllDeleted && areAllAdded)
    {
      replacedValues=addedValues;
      deletedValues=nil;
      addedValues=nil;
    };
  *addedValuesPtr=addedValues;
  *deletedValuesPtr=deletedValues;
  *replacedValuesPtr=replacedValues;
  NSDebugMLog(@"addedValues: %@",addedValues);
  NSDebugMLog(@"deletedValues: %@",deletedValues);
  NSDebugMLog(@"replacedValues: %@",replacedValues);
  return isChange;
};

//--------------------------------------------------------------------
+(NSString*)descriptionFromMods:(LDAPMod**)mods
{
  NSMutableString* dscr=[NSMutableString string];
  NSDebugMLog(@"mods=%p",mods);
  NSDebugMLog(@"*mods=%p",*mods);
  while(*mods)
    {
      LDAPMod* mod=*mods;
      if ([dscr length]>0)
        [dscr appendString:@"-\n"];
      BOOL isBinary=(((mod->mod_op) & LDAP_MOD_BVALUES)==LDAP_MOD_BVALUES);
      NSDebugMLog(@"OP=%d",(int)((mod->mod_op) & ~LDAP_MOD_BVALUES));
      NSDebugMLog(@"modType=%p",mod->mod_type);
      NSDebugMLog(@"modType=%s",mod->mod_type);
      switch((mod->mod_op) & ~LDAP_MOD_BVALUES)
        {
        case LDAP_MOD_ADD:
          [dscr appendFormat:@"add: %s\n",mod->mod_type];
          if (isBinary)
            {
              [dscr appendFormat:@"%s: [Binary]\n",mod->mod_type];
            }
          else
            {
              char** values=mod->mod_values;
              NSDebugMLog(@"values=%p",values);
              if (values)
                {
                  while(*values)
                    {
                      NSDebugMLog(@"*values=%p",*values);
                      NSDebugMLog(@"*values=%s",*values);
                      [dscr appendFormat:@"%s: %s\n",mod->mod_type,*values];
                      values++;
                    };
                };
            }
          break;
        case LDAP_MOD_REPLACE:          
          [dscr appendFormat:@"replace: %s\n",mod->mod_type];
          if (isBinary)
            {
              [dscr appendFormat:@"%s: [Binary]\n",mod->mod_type];
            }
          else
            {
              char** values=mod->mod_values;
              NSDebugMLog(@"values=%p",values);
              if (values)
                {
                  while(*values)
                    {
                      NSDebugMLog(@"*values=%p",*values);
                      NSDebugMLog(@"*values=%s",*values);
                      [dscr appendFormat:@"%s: %s\n",mod->mod_type,*values];
                      values++;
                    };
                };
            }
          break;
        case LDAP_MOD_DELETE:
          [dscr appendFormat:@"delete: %s\n",mod->mod_type];
          if (isBinary)
            {
              [dscr appendFormat:@"%s: [Binary]\n",mod->mod_type];
            }
          else
            {
              char** values=mod->mod_values;
              NSDebugMLog(@"values=%p",values);
              if (values)
                {
                  while(*values)
                    {
                      NSDebugMLog(@"*values=%p",*values);
                      NSDebugMLog(@"*values=%s",*values);
                      [dscr appendFormat:@"%s: %s\n",mod->mod_type,*values];
                      values++;
                    };
                };
            }
          break;
        default:
          [dscr appendFormat:@"*** Unknown op:%x *****\n",mod->mod_op];
        };
      mods++;
    };
  NSDebugMLog(@"dscr=%@",dscr);
  return dscr;
};

//--------------------------------------------------------------------
-(void)makeDiffForAttributeNamed:(NSString*)attribute
                          values:(NSArray*)values
                           modOp:(int)modOp // LDAP_MOD_REPLACE or LDAP_MOD_ADD or LDAP_MOD_DELETE
                      withModPtr:(LDAPMod**)modPtr
                    stringModPtr:(NSString**)modStringPtr
{
  NSString* modOpString=nil;
  int count=0;
  int i=0;
  int modIndex=0;
  BOOL fValueIsData=NO;

  NSDebugMLog(@"modPtr=%p",modPtr);
  NSDebugMLog(@"modStringPtr=%p",modStringPtr);
  if (modPtr)
    *modPtr=NULL;
  if (modStringPtr)
    *modStringPtr=nil;
  NSAssert(modPtr || modStringPtr,@"No mod or string");
    
  NSDebugMLog(@"makeDiffForAttributeNamed: name=%@ arrayValues=%@",
        attribute,
        values);

  NSAssert2([values isKindOfClass:[NSArray class]] && [values count]>0,
            @"values is not an array (%@) or it has not elements: %@",
            [values class],values);

  count=[values count];
  if (modPtr)
    {
      (*modPtr) = (LDAPMod *)malloc(sizeof(LDAPMod));
      /*          if ([attribute caseInsensitiveCompare:@"descriptionText"]==NSOrderedSame)
                  (*modPtr)->mod_type = cStringCopy(@"description");
                  else*/
      (*modPtr)->mod_type = cStringCopy(attribute);
      (*modPtr)->mod_op = modOp;
    };
  
  for ( i=0; i < count; i++ )
    {
      id aValue=[values objectAtIndex:i];
      NSDebugMLog(@"aValue=%@",aValue);
      if (![aValue isKindOfClass:[NSNull class]])
        {              
          BOOL isEmpty=NO;
          if ([aValue isKindOfClass:[NSData class]])
            {
              if ([aValue length]==0)
                isEmpty=YES;
              else if (modIndex==0)
                fValueIsData=YES;
              else if (!fValueIsData)
                {
                  NSAssert1(NO,@"First value is not a data but %d one is a data",
                            i);
                }
            }
          else
            {
              if (![aValue isKindOfClass:[NSString class]])
                aValue=[aValue description];
              if ([aValue length]==0)
                isEmpty=YES;
              else if (modIndex==0)
                fValueIsData=NO;
              else if (fValueIsData)
                {
                  NSAssert1(NO,@"First value is a data but %d one is not a data",
                            i);
                };
            };
          
          NSDebugMLog(@"fValueIsData=%d",fValueIsData);
          NSDebugMLog(@"isEmpty=%d",isEmpty);
          if (!isEmpty)
            {
              if (modPtr)
                {
                  if (fValueIsData)
                    {
                      if (modIndex==0)
                        (*modPtr)->mod_bvalues = (struct berval **)malloc((count+1)*sizeof(struct berval *));
                      (*modPtr)->mod_bvalues[modIndex] = (struct berval *)malloc(sizeof(struct berval));
                      (*modPtr)->mod_bvalues[modIndex]->bv_val = (void *)[aValue bytes];
                      (*modPtr)->mod_bvalues[modIndex]->bv_len = [aValue length];
                    }
                  else
                    {
                      if (modIndex==0)
                        (*modPtr)->mod_values = (char **)malloc((count+1)*sizeof(char *));
                      (*modPtr)->mod_values[modIndex] = cStringCopy(aValue);
                    };
                };
              if (modStringPtr)
                {
                  if (i==0)
                    {
                      *modStringPtr=[NSMutableString string];
                      switch(modOp)
                        {
                        case LDAP_MOD_ADD:
                          modOpString=@"add";
                              break;
                        case LDAP_MOD_REPLACE:          
                          modOpString=@"replace";
                          break;
                        case LDAP_MOD_DELETE:
                          modOpString=@"delete";
                        };
                      [((NSMutableString*)(*modStringPtr)) appendFormat:@"%@: %@\n",modOpString,attribute];
                    };
                  [((NSMutableString*)(*modStringPtr)) appendFormat:@"%@: %@\n",attribute,aValue];
                }
              modIndex++;
            };              
        };      
    }
  if (modPtr)
    {
      if (fValueIsData)
        {
          (*modPtr)->mod_op |= LDAP_MOD_BVALUES;
          (*modPtr)->mod_bvalues[modIndex] = NULL; // end of list
        }
      else
        (*modPtr)->mod_values[modIndex] = NULL; // end of the list
    };
};

//--------------------------------------------------------------------
-(void)makeDiffDeleteForAttributeNamed:(NSString*)attribute
                            withModPtr:(LDAPMod**)modPtr
                          stringModPtr:(NSString**)modStringPtr
{
  NSDebugMLog(@"modPtr=%p",modPtr);
  NSDebugMLog(@"modStringPtr=%p",modStringPtr);
  if (modPtr)
    *modPtr=NULL;
  if (modStringPtr)
    *modStringPtr=nil;
  NSAssert(modPtr || modStringPtr,@"No mod or string");

  NSDebugMLog(@"deleteModForAttributeNamed: name=%@",
        attribute);
  if (modPtr)
    {
      // this mod will be freed by ldap_mod_free, so must use malloc.
      (*modPtr) = (LDAPMod *)malloc(sizeof(LDAPMod));
      (*modPtr)->mod_op = LDAP_MOD_DELETE;
      (*modPtr)->mod_type = cStringCopy(attribute);
      (*modPtr)->mod_values = NULL;
    }
  if (modStringPtr)
    {
      *modStringPtr=[NSMutableString string];
      [((NSMutableString*)(*modStringPtr)) appendFormat:@"delete: %@\n",attribute];
    }
}

//--------------------------------------------------------------------
-(void)makeDiffFromEntry:(GSLDAPEntry*)entry
             withModsPtr:(LDAPMod***)modsPtr
           stringModsPtr:(NSString**)modsStringPtr
{
  NSEnumerator *selfAttributeNameEnum=nil;
  NSMutableDictionary* addedValuesByAttributeName=nil;
  NSMutableDictionary* replacedValuesByAttributeName=nil;
  NSMutableDictionary* deletedValuesByAttributeName=nil;
  NSString* selfAttributeName=nil;
  NSMutableString* modsString=nil;
  NSString* tmpString=nil;
  int modsCount=0;
  int modIndex=0;
  int i=0;
  int iRound=0;

  NSDebugMLog(@"modsPtr=%p",modsPtr);
  NSDebugMLog(@"modsStringPtr=%p",modsStringPtr);
  if (modsPtr)
    *modsPtr=NULL;
  if (modsStringPtr)
    *modsStringPtr=[NSMutableString string];
  NSAssert(modsPtr || modsStringPtr,@"No mod or string");

  NSDebugMLog(@"self=%@",self);
  NSDebugMLog(@"entry=%@",entry);

  if (modsStringPtr)
    {
      *modsStringPtr=nil;
      modsString=(NSMutableString*)[NSMutableString string];
    };
  
  NSMutableArray* entryAttributeNames=[[[entry attributeNames] mutableCopy]autorelease];
  NSDebugMLog(@"entryAttributeNames=%@",entryAttributeNames);

  selfAttributeNameEnum = [self attributeNameEnumerator];
  while ((selfAttributeName = [selfAttributeNameEnum nextObject])) 
    {
      NSArray* addedValues=nil;
      NSArray* deletedValues=nil;
      NSArray* replacedValues=nil;
      [entryAttributeNames removeObject:selfAttributeName];

      NSDebugMLog(@"attributeName=%@",selfAttributeName);
      NSArray* selfValues = [self valuesForAttributeNamed:selfAttributeName];
      NSDebugMLog(@"selfValues=%@",selfValues);

      NSArray* entryValues = [entry valuesForAttributeNamed:selfAttributeName];
      NSDebugMLog(@"entryValues=%@",entryValues);

      NSAssert1(selfValues,@"No values for %@",selfAttributeName);
      if ([[self class]diffBetweenNewValues:selfValues
                       andOldValues:entryValues
                       intoAddedValues:&addedValues
                       deletedValues:&deletedValues
                       replacedValues:&replacedValues])
        {
          if ([addedValues count]>0)
            {
              if (!addedValuesByAttributeName)
                addedValuesByAttributeName=(NSMutableDictionary*)[NSMutableDictionary dictionary];
              [addedValuesByAttributeName setObject:addedValues
                                          forKey:selfAttributeName];
              modsCount++;
            };
          if ([deletedValues count]>0)
            {
              if (!deletedValuesByAttributeName)
                deletedValuesByAttributeName=(NSMutableDictionary*)[NSMutableDictionary dictionary];
              [deletedValuesByAttributeName setObject:deletedValues
                                            forKey:selfAttributeName];
              modsCount++;
            };
          if ([replacedValues count]>0)
            {
              if (!replacedValuesByAttributeName)
                replacedValuesByAttributeName=(NSMutableDictionary*)[NSMutableDictionary dictionary];
              [replacedValuesByAttributeName setObject:replacedValues
                                          forKey:selfAttributeName];
              modsCount++;
            };
        };
    };

  NSDebugMLog(@"entryAttributeNames=%@",entryAttributeNames);
  NSDebugMLog(@"modsCount=%d",modsCount);
  modsCount+=[entryAttributeNames count]; //attributes to delete
  NSDebugMLog(@"modsCount=%d",modsCount);
  if (modsPtr)
    {
      *modsPtr = (LDAPMod **)malloc((modsCount+1)*sizeof(LDAPMod*));
      memset(*modsPtr,0,((modsCount+1)*sizeof(LDAPMod*)));
      NSDebugMLog(@"modsPtr=%p",modsPtr);
      NSDebugMLog(@"*modsPtr=%p",*modsPtr);
    };

  // Attributes To delete
  for(i=0;i<[entryAttributeNames count];i++)
    {
      NSString* entryAttributeName=[entryAttributeNames objectAtIndex:i];
      [self makeDiffDeleteForAttributeNamed:entryAttributeName
            withModPtr:(modsPtr ? &(*modsPtr)[modIndex] : NULL)
            stringModPtr:(modsStringPtr ? &tmpString : NULL)];
      if (modsStringPtr)
        [modsString appendFormat:@"%@-\n",tmpString];
      modIndex++;
    };
  NSDebugMLog(@"modIndex=%d",modIndex);

  for(iRound=0;iRound<3;iRound++)
    {
      int modOp=0;
      NSDictionary* valuesByAttributeName=nil;
      NSEnumerator* attributeNameEnum=nil;
      NSString* attributeName=nil;
      switch(iRound)
        {
        case 0:
          valuesByAttributeName=deletedValuesByAttributeName;
          modOp=LDAP_MOD_DELETE;
          break;
        case 1:
          valuesByAttributeName=replacedValuesByAttributeName;
          modOp=LDAP_MOD_REPLACE;
          break;
        case 2:
          valuesByAttributeName=addedValuesByAttributeName;
          modOp=LDAP_MOD_ADD;
          break;
        };
      attributeNameEnum = [valuesByAttributeName keyEnumerator];
      while ((attributeName = [attributeNameEnum nextObject])) 
        {
          NSArray* values=[valuesByAttributeName objectForKey:attributeName];
          [self makeDiffForAttributeNamed:attributeName
                values:values
                modOp:modOp
                withModPtr:(modsPtr ? &(*modsPtr)[modIndex] : NULL)
                stringModPtr:(modsStringPtr ? &tmpString : NULL)];              
          if (modsStringPtr)
            [modsString appendFormat:@"%@-\n",tmpString];
          modIndex++;
        };
      NSDebugMLog(@"modIndex=%d",modIndex);
    };
  NSDebugMLog(@"modIndex=%d",modIndex);
  if (modsPtr)
    {
      (*modsPtr)[modIndex] = NULL; // end of the list
      NSDebugMLog(@"modIndex=%d",modIndex);
      
      NSDebugMLog(@"==> %@",[[self class]descriptionFromMods:*modsPtr]);
    };
  if (modsStringPtr)
    *modsStringPtr=modsString;
};

//--------------------------------------------------------------------
-(LDAPMod**)ldapModsDiffFromEntry:(GSLDAPEntry*)entry
{
  LDAPMod** ldapMods=NULL;
  [self makeDiffFromEntry:(GSLDAPEntry*)entry
        withModsPtr:&ldapMods
        stringModsPtr:NULL];
  NSDebugMLog(@"ldapMods=%p",ldapMods);
  if (ldapMods)
    NSDebugMLog(@"*ldapMods=%p",*ldapMods);
  return ldapMods;
};

//--------------------------------------------------------------------
-(NSString*)ldapDiffFromEntry:(GSLDAPEntry*)entry
{
  NSString* string=nil;
  [self makeDiffFromEntry:entry
        withModsPtr:NULL
        stringModsPtr:&string];
  return string;
};

//--------------------------------------------------------------------
-(void)makeDiffWithModsPtr:(LDAPMod***)modsPtr
             stringModsPtr:(NSString**)modsStringPtr
{
  return [self makeDiffFromEntry:NULL
               withModsPtr:modsPtr
               stringModsPtr:modsStringPtr];

};

//--------------------------------------------------------------------
-(LDAPMod**)ldapMods
{
  LDAPMod** ldapMods=NULL;
  [self makeDiffWithModsPtr:&ldapMods
        stringModsPtr:NULL];
  return ldapMods;
};

//--------------------------------------------------------------------
-(NSString*)ldapDiff
{
  NSString* string=nil;
  [self makeDiffWithModsPtr:NULL
        stringModsPtr:&string];
  return string;
};


@end
    
