/** GSLDAPConnection.m - <title>GSLDAP: Class GSLDAPConnection</title>

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

static const char rcsId[]="$Id$";

#include "GSLDAPCom.h"
#include "GSLDAPConnection.h"

//====================================================================
@implementation GSLDAPConnection

//--------------------------------------------------------------------
+(GSLDAPConnection*)ldapConnection
{
  return [[[self alloc]init]autorelease];
};

//--------------------------------------------------------------------
+(GSLDAPConnection*)ldapConnectionWithHost:(NSString*)host
                                      port:(int)port
                                authMethod:(unsigned int)authMethod
                                    bindDN:(NSString*)bindDN
                              bindPassword:(NSString*)bindPassword
                                    baseDN:(NSString*)baseDN
                                     scope:(unsigned int)scope
                                     flags:(unsigned int)flags
{
  return [[[self alloc]initWithHost:host
                       port:port
                       authMethod:authMethod
                       bindDN:bindDN
                       bindPassword:bindPassword
                       baseDN:baseDN
                       scope:scope
                       flags:flags]autorelease];
};

//--------------------------------------------------------------------
+(GSLDAPConnection*)ldapConnectionWithAuthMethod:(unsigned int)authMethod
                                           scope:(unsigned int)scope
                                           flags:(unsigned int)flags
{
  return [[[self alloc]initWithAuthMethod:authMethod
                       scope:scope
                       flags:flags]autorelease];
};

//--------------------------------------------------------------------
-(id)initWithHost:(NSString*)host
             port:(int)port
       authMethod:(unsigned int)authMethod
           bindDN:(NSString*)bindDN
     bindPassword:(NSString*)bindPassword
           baseDN:(NSString*)baseDN
            scope:(unsigned int)scope
            flags:(unsigned int)flags
{
  if ((self=[self initWithAuthMethod:authMethod
                  scope:scope
                  flags:flags]))
    {
      ASSIGN(_host,host);
      _port=port;
      ASSIGN(_bindDN,bindDN);
      ASSIGN(_bindPassword,bindPassword);
      ASSIGN(_defaultBaseDN,baseDN);
    };
  return self;
}

//--------------------------------------------------------------------
-(id)initWithAuthMethod:(unsigned int)authMethod
                  scope:(unsigned int)scope
                  flags:(unsigned int)flags
{
  if ((self=[self init]))
    {
      _authMethod=authMethod;
      _defaultScope=scope;

      if ((flags & GSLDAPConnection__bindOnConnect)==GSLDAPConnection__bindOnConnect)
        _flags.bindOnConnect=1;

      if ((flags & GSLDAPConnection__autoConnect)==GSLDAPConnection__autoConnect)
        _flags.autoConnect=1;
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
  DESTROY(_host);
  DESTROY(_bindDN);
  DESTROY(_bindPassword);
  DESTROY(_defaultBaseDN);
  if (_ldapConn) // Close connection
    {
      ldap_unbind(_ldapConn);
      _ldapConn=NULL;
    }
  DESTROY(_schema);
  [super dealloc];
}

//--------------------------------------------------------------------
-(BOOL)isDebugEnabled
{
  return YES;
};

//--------------------------------------------------------------------
-(NSString*)host
{
  return _host;
};

//--------------------------------------------------------------------
-(void)setHost:(NSString*)host
{
  if (![host isEqualToString:_host])
    {
      [self disconnect];
      ASSIGN(_host,host);
    };
}

//--------------------------------------------------------------------
-(int)port
{
  return _port;
};

//--------------------------------------------------------------------
-(void)setPort:(int)port
{
  if (port!=_port)
    {
      [self disconnect];
      _port=port;
    };
}

//--------------------------------------------------------------------
-(unsigned int)authMethod
{
  return _authMethod;
};

//--------------------------------------------------------------------
-(void)setAuthMethod:(unsigned int)authMethod
{
  _authMethod=authMethod;
}

//--------------------------------------------------------------------
-(NSString*)bindDN
{
  return _bindDN;
};

//--------------------------------------------------------------------
-(void)setBindDN:(NSString*)bindDN
{
  if (![bindDN isEqualToString:_bindDN])
    {
      [self disconnect];
      ASSIGN(_bindDN,bindDN);
    };
}

//--------------------------------------------------------------------
-(NSString*)bindPassword
{
  return _bindPassword;
};

//--------------------------------------------------------------------
-(void)setBindPassword:(NSString*)bindPassword
{
  if (![bindPassword isEqualToString:_bindPassword])
    {
      [self disconnect];
      ASSIGN(_bindPassword,bindPassword);
    };
}

//--------------------------------------------------------------------
-(NSString*)defaultBaseDN
{
  return  _defaultBaseDN;
};

//--------------------------------------------------------------------
-(void)setDefaultBaseDN:(NSString*)defaultBaseDN
{
  ASSIGN(_defaultBaseDN,defaultBaseDN);
}

//--------------------------------------------------------------------
-(unsigned int)defaultScope
{
  return  _defaultScope;
};

//--------------------------------------------------------------------
-(void)setDefaultScope:(unsigned int)defaultScope
{
  _defaultScope=defaultScope;
}

//--------------------------------------------------------------------
-(BOOL)isBinded
{
  return _isBinded;
};

//--------------------------------------------------------------------
-(unsigned)timeoutValue
{
  return 0;
};

//--------------------------------------------------------------------
-(NSString*)schemaBaseKey
{
  return @"cn=subschema";
}

//--------------------------------------------------------------------
-(LDAP*)ldapConn
{
  return _ldapConn;
};

//--------------------------------------------------------------------
- (NSString *)errorStringWithLDAPErrorNum:(int)num
{
  return [NSString stringWithCString:ldap_err2string(num)];
}

-(BOOL)isOperationInProgress
{
  return NO; //TODO
};

//--------------------------------------------------------------------
-(BOOL)isConnected
{
  return (_ldapConn!=NULL);
};

//--------------------------------------------------------------------
-(BOOL)connect
{
  BOOL connected=NO;
  if (_ldapConn)
    {
      connected=YES;
    }
  else
    {
      if (_host)
        {
          int port=_port;
          if(!port)
            port=389;
          
          if ((_ldapConn = ldap_open([_host cString],port))) 
            {
              connected=YES;
              //NSDebugMLog(@"Connected");
              if (_flags.bindOnConnect && _authMethod!=LDAP_AUTH_NONE && [_bindDN length]>0)
                {
                  [self bind];
                };
            }
          else
            {
              //NSDebugMLog(@"Connection failed");
            };
        }
      else
        {
          //NSDebugMLog(@"Host non specifié");
        };
    }
  return connected;
};

//--------------------------------------------------------------------
-(BOOL)disconnect
{
  if (_ldapConn)
    {
      ldap_unbind(_ldapConn);
      _ldapConn=NULL;
      _isBinded=NO;
    };
  return YES;
};

//--------------------------------------------------------------------
-(BOOL)bind
{
  if (!_isBinded)
    {
      int result=0;
      switch(_authMethod)
        {
        case LDAP_AUTH_KRBV4:
        case LDAP_AUTH_KRBV41:
        case LDAP_AUTH_KRBV42:
#ifdef KERBEROS
          result = ldap_kerberos_bind_s(_ldapConn,[_bindDN cString]);
#else
          [NSException raise:NSInternalInconsistencyException
                       reason:@"Unhandled bind Kerberos auth method"];          
#endif
          break;
        case LDAP_AUTH_NONE:
          result=LDAP_SUCCESS;
          break;
        case LDAP_AUTH_SIMPLE:
          result = ldap_simple_bind_s(_ldapConn,[_bindDN cString],[_bindPassword cString]);
          break;
        case LDAP_AUTH_SASL:
          [NSException raise:NSInternalInconsistencyException
                       reason:@"Unimplemented bind SASL auth method"];          
          break;
        default:
          [NSException raise:NSInternalInconsistencyException
                       reason:@"Unknown bind auth method"];          
          break;
        };
      if (result==LDAP_SUCCESS) 
        _isBinded=YES;
    };
  return _isBinded;
}

//--------------------------------------------------------------------
-(NSString*)notConnectedExceptionMessageInSelector:(SEL)sel
{
  return [NSString stringWithFormat:@"%@ -- %@ 0x%x: Can't perform operation without LDAP server connection",
                   NSStringFromSelector(sel),
                   NSStringFromClass([self class]), self];
};

//--------------------------------------------------------------------
-(NSString*)operationStillInProgressExceptionMessageInSelector:(SEL)sel
{
  return [NSString stringWithFormat:@"%@ -- %@ 0x%x: Can't perform operation when one is still in progress",
                   NSStringFromSelector(sel),
                   NSStringFromClass([self class]), self];
};

//--------------------------------------------------------------------
-(NSString*)ldapErrorExceptionMessageInSelector:(SEL)sel
                                    withMessage:(NSString*)message
                                       errorNum:(int)errorNum
{
  return [NSString stringWithFormat:@"%@ -- %@ 0x%x: %@ LDAP Error 0x%x: %@",
                   NSStringFromSelector(sel),
                   NSStringFromClass([self class]),
                   self,
                   (message ? message : @""),
                   errorNum,
                   [self errorStringWithLDAPErrorNum:errorNum]];
};

-(NSString*)errorExceptionMessageInSelector:(SEL)sel
                                withMessage:(NSString*)message
{
  return [NSString stringWithFormat:@"%@ -- %@ 0x%x: %@",
                   NSStringFromSelector(sel),
                   NSStringFromClass([self class]),
                   self,
                   (message ? message : @"")];
};

//--------------------------------------------------------------------
-(void)assertCanRunOperationInSelector:(SEL)sel
{
  if (![self isConnected] && _flags.autoConnect)
    [self connect];

  if (![self isConnected])
    {
      [NSException raise:NSInternalInconsistencyException
                   reason:[self notConnectedExceptionMessageInSelector:sel]];
    }
  else if ([self isOperationInProgress])
    [NSException raise:NSInternalInconsistencyException
                 reason:[self operationStillInProgressExceptionMessageInSelector:sel]];
};

//--------------------------------------------------------------------
/** Returns array of GSLDAPEntry built from 'entries' ldap message
*/
-(NSArray*)entriesFromLDAPMessage:(LDAPMessage*)entries
{
  NSMutableArray *array=nil;
  LDAPMessage *entry=NULL;

  array = [NSMutableArray arrayWithCapacity:ldap_count_entries(_ldapConn,entries)];
  entry = ldap_first_entry(_ldapConn,entries);
  while (entry)
    {
      [array addObject:[GSLDAPEntry ldapEntryWithConnection:self
                                    ldapMessage:entry]];
      entry = ldap_next_entry(_ldapConn,entry);
    };
  return array;
}

//--------------------------------------------------------------------
/** Returns array of DNs from 'entries' ldap message
*/
-(NSArray*)dnsFromLDAPMessage:(LDAPMessage*)entries
{
  NSMutableArray *array=nil;
  LDAPMessage *entry=NULL;

  array = [NSMutableArray arrayWithCapacity:ldap_count_entries(_ldapConn,entries)];
  entry = ldap_first_entry(_ldapConn,entries);
  while (entry)
    {
      char* dnCString = ldap_get_dn(_ldapConn,entry);
      if (!dnCString)
        {
          NSDebugMLog(@"NO DN");
        }
      else
        {
          [array addObject:[NSString stringWithCString:dnCString]];
          ldap_memfree(dnCString);
        }
      entry = ldap_next_entry(_ldapConn,entry);
    };
  return array;
}

//--------------------------------------------------------------------
-(unsigned)initiateSearchWithBaseDN:(NSString*)baseDN
                              scope:(unsigned int)scope
                             filter:(NSString*)filter
                         attributes:(NSArray*)attributes
{
  char ** ldapAttributes=NULL;
  int ldapMsgId = 0;

  NSDebugMLog(@"baseDN=%@",baseDN);
  NSDebugMLog(@"scope=%d",scope);
  NSDebugMLog(@"filter=%@",filter);
  NSDebugMLog(@"attributes=%@",attributes);

  [self assertCanRunOperationInSelector:_cmd];

  if ([attributes count]>0)
    ldapAttributes = (char **)[attributes cStringArray];

  ldapMsgId = ldap_search(_ldapConn,
                          (char*)[baseDN cString],
                          scope,
                          (char*)[filter cString],
                          ldapAttributes,
                          0);

  if (ldapAttributes)
    freeMallocArray(ldapAttributes);

  if (ldapMsgId<0) // Error ?
    {
      ldapMsgId = 0;
      [NSException raise:NSInternalInconsistencyException 
                   format:@"%@ -- %@ 0x%x: Error initiating search with filter: '%@': LDAP error: '%@'", 
                   NSStringFromSelector(_cmd), 
                   NSStringFromClass([self class]), 
                   self, 
                   filter, 
                   [self errorStringWithLDAPErrorNum:-1]];
    };
  return ldapMsgId;
}

//--------------------------------------------------------------------
-(unsigned)initiateSearchWithFilter:(NSString*)filter
                         attributes:(NSArray*)attributes
{
  return [self initiateSearchWithBaseDN:_defaultBaseDN
               scope:_defaultScope
               filter:filter
               attributes:attributes];
};


//--------------------------------------------------------------------
-(unsigned)initiateSubschemaSearch
{     
  return [self initiateSearchWithBaseDN:[self schemaBaseKey]
               scope:LDAP_SCOPE_BASE
               filter:@"(objectclass=subschema)"
               attributes:[NSArray arrayWithObject:[NSString stringWithCString:LDAP_ALL_OPERATIONAL_ATTRIBUTES]]];
}


//--------------------------------------------------------------------
-(int)requestResultWithLDAPMsgId:(unsigned)ldapMsgId
                     LDAPMessage:(LDAPMessage**)ldapMessage
                     retrieveAll:(BOOL)all
{
  int result=0;

  [self assertCanRunOperationInSelector:_cmd];

  if ([self timeoutValue]>0)
    {
      struct timeval tv;
      tv.tv_sec = (unsigned long) [self timeoutValue];
      tv.tv_usec = 0;
      result = ldap_result(_ldapConn, ldapMsgId, all, &tv, ldapMessage);
    }
  else 
    {
      result = ldap_result(_ldapConn, ldapMsgId, all, NULL, ldapMessage);
    }
  
  if (all || (!all && result == LDAP_RES_SEARCH_RESULT)) 
    {
      //The operation is complete if it is synchronous or if we retrieved all entries
      ldapMsgId = 0;
    };
  
  if (result<1)
    {
      [NSException raise:NSGenericException
                   reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                withMessage:nil
                                errorNum:errno]];
    };
  return result;
}

//--------------------------------------------------------------------
-(GSLDAPEntry*)searchDN:(NSString*)dn
             attributes:(NSArray*)attributes
{
  GSLDAPEntry* entry=nil;
  NSArray* entriesArray=[self searchWithBaseDN:dn
                              scope:LDAP_SCOPE_BASE
                              filter:nil
                              attributes:attributes];

  if ([entriesArray count]==1)
    entry=[entriesArray lastObject];
  else if ([entriesArray count]>1)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:[NSString stringWithFormat:@"More than one entry for %@",dn]]];
    };
  return entry;
};

//--------------------------------------------------------------------
-(NSArray*)searchFilter:(NSString*)filter
             attributes:(NSArray*)attributes
{
  return [self searchWithBaseDN:_defaultBaseDN
               scope:_defaultScope
               filter:filter
               attributes:attributes];
};

//--------------------------------------------------------------------
-(NSArray*)searchWithBaseDN:(NSString*)baseDN
                      scope:(unsigned int)scope
                     filter:(NSString*)filter
                 attributes:(NSArray*)attributes
{
  LDAPMessage *result=NULL;
  char** ldapAttributes=NULL;
  int errorNum=0;

  [self assertCanRunOperationInSelector:_cmd];

  if ([attributes count]>0)
    ldapAttributes = (char **)[attributes cStringArray];

  errorNum = ldap_search_s (_ldapConn,
                            (char *)[baseDN cString],
                            scope,
                            (char *)[filter cString],
                            ldapAttributes,
                            0,
                            &result);

  if (ldapAttributes)
    freeMallocArray(ldapAttributes);

  if (errorNum!=LDAP_SUCCESS)
    {
      [NSException raise:NSGenericException
                   reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                withMessage:nil
                                errorNum:errorNum]];
    };
  return [self entriesFromLDAPMessage:result];
};

//--------------------------------------------------------------------
/** Search one level entries DNs */
-(NSArray*)searchOneLevelDNsWithBaseDN:(NSString*)baseDN
{
  return [self searchDNsWithBaseDN:baseDN
               scope:LDAP_SCOPE_ONELEVEL];
};

//--------------------------------------------------------------------
/** Search subtree entries DNs */
-(NSArray*)searchSubtreeDNsWithBaseDN:(NSString*)baseDN
{
  return [self searchDNsWithBaseDN:baseDN
               scope:LDAP_SCOPE_SUBTREE];
};

//--------------------------------------------------------------------
/** Search entries DNs */
-(NSArray*)searchDNsWithBaseDN:(NSString*)baseDN
                         scope:(unsigned int)scope
{
  LDAPMessage *result=NULL;
  char* ldapAttributes[]={ "dn", NULL };
  int errorNum=0;

  [self assertCanRunOperationInSelector:_cmd];

  errorNum = ldap_search_s (_ldapConn,
                            (char *)[baseDN cString],
                            scope,
                            NULL,
                            ldapAttributes,
                            0,
                            &result);

  if (errorNum!=LDAP_SUCCESS)
    {
      [NSException raise:NSGenericException
                   reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                withMessage:nil
                                errorNum:errorNum]];
    };
  return [self dnsFromLDAPMessage:result];
};

//--------------------------------------------------------------------
-(BOOL)addEntry:(GSLDAPEntry*)entry
{  
  if (!entry)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:@"No entry"]];
    }
  else if ([[entry dn] length]==0)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:[NSString stringWithFormat:@"Entry has no dn: %@",entry]]];
    }
  else
    {
      LDAPMod **mods=NULL;
      int errorNum=0;

      [self assertCanRunOperationInSelector:_cmd];

      mods=[entry ldapMods];
      if (mods)
        {
          errorNum = ldap_add_s(_ldapConn,
                                (char *)[[entry dn] cString],
                                mods);
          ldap_mods_free(mods,1);
          
          if (errorNum!=LDAP_SUCCESS)
            {
              [NSException raise:NSGenericException
                           reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                        withMessage:nil
                                        errorNum:errorNum]];
            };
        };
    };
    
  return YES;
};

//--------------------------------------------------------------------
-(BOOL)deleteEntry:(GSLDAPEntry*)entry
{
  return [self deleteEntryWithDN:[entry dn]
               isRecursive:NO];
};

//--------------------------------------------------------------------
-(BOOL)deleteEntry:(GSLDAPEntry*)entry
       isRecursive:(BOOL)isRecursive
{
  return [self deleteEntryWithDN:[entry dn]
               isRecursive:isRecursive];
};

//--------------------------------------------------------------------
-(BOOL)deleteEntryWithDN:(NSString*)dn
{
  return [self deleteEntryWithDN:dn
               isRecursive:NO];
};

//--------------------------------------------------------------------
-(BOOL)deleteEntryWithDN:(NSString*)dn
             isRecursive:(BOOL)isRecursive
{
  if ([dn length]==0)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:@"No dn: %@"]];
    }
  else
    {  
      int errorNum=0;

      if (isRecursive)
        {
          NSArray* dns=[self searchSubtreeDNsWithBaseDN:dn];
          int i=0;
          int count=[dns count];
          [self assertCanRunOperationInSelector:_cmd];
          for(i=count-1;errorNum==LDAP_SUCCESS && i>=0;i--)//Start from leaf :-)
            {
              NSString* aDN=[dns objectAtIndex:i];
              errorNum = ldap_delete_s(_ldapConn,(char *)[aDN cString]);
              if (errorNum!=LDAP_SUCCESS) 
                {
                  [NSException raise:NSGenericException
                               reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                            withMessage:[NSString stringWithFormat:@"Delete %@ (recusrsive from %@)",aDN,dn]
                                            errorNum:errorNum]];
                };
            };
        }
      else
        {
          [self assertCanRunOperationInSelector:_cmd];
          if (!errorNum)
            {
              errorNum = ldap_delete_s(_ldapConn,(char *)[dn cString]);
              if (errorNum!=LDAP_SUCCESS) 
                {
                  [NSException raise:NSGenericException
                               reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                            withMessage:[NSString stringWithFormat:@"Delete %@",dn]
                                            errorNum:errorNum]];
                };
            };
        };
    };
  return YES;
};

//--------------------------------------------------------------------
-(BOOL)updateEntry:(GSLDAPEntry*)entry
{
  if (!entry)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:@"No entry"]];
    }
  else if ([[entry dn] length]==0)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:[NSString stringWithFormat:@"Entry has no dn: %@",entry]]];
    }
  else
    {
      GSLDAPEntry* origEntry=nil;
      
      [self assertCanRunOperationInSelector:_cmd];
      
      origEntry=[self searchDN:[entry dn]
                      attributes:nil];

      if (!origEntry)
        {
          [NSException raise:NSGenericException
                       reason:[self errorExceptionMessageInSelector:_cmd
                                    withMessage:[NSString stringWithFormat:@"No entry for DN: %@",[entry dn]]]];
        }
      else
        {
          LDAPMod **ldapMods=NULL;
          ldapMods=[entry ldapModsDiffFromEntry:origEntry];
          
          if (ldapMods)
            {
              int errorNum=0;
              errorNum = ldap_modify_s(_ldapConn,(char *)[[entry dn] cString],ldapMods);
              ldap_mods_free(ldapMods,1);
    
              if (errorNum!=LDAP_SUCCESS) 
                {
                  [NSException raise:NSGenericException
                               reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                            withMessage:nil
                                            errorNum:errorNum]];
                };
            };
        };
    };
  
  return YES;
}

//--------------------------------------------------------------------
-(BOOL)updateEntry:(GSLDAPEntry*)entry
               rdn:(NSString*)rdn
      deleteOldRDN:(BOOL)deleteOldRDN
{
  if (!entry)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:@"No entry"]];
    }
  else if ([[entry dn] length]==0)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:[NSString stringWithFormat:@"Entry has no dn: %@",entry]]];
    }
  else if ([rdn length]==0)
    {
      [NSException raise:NSGenericException
                   reason:[self errorExceptionMessageInSelector:_cmd
                                withMessage:@"No RDN"]];
    }
  else
    {
      int errorNum=0;

      [self assertCanRunOperationInSelector:_cmd];

      errorNum = ldap_modrdn2_s(_ldapConn,[[entry dn]cString],[rdn cString],(deleteOldRDN ? 1 : 0));

      if (errorNum!=LDAP_SUCCESS) 
        {
          [NSException raise:NSGenericException
                       reason:[self ldapErrorExceptionMessageInSelector:_cmd
                                    withMessage:nil
                                    errorNum:errorNum]];
        }
      else
        {
          [entry setNewRDN:rdn
                 deleteOldRDN:deleteOldRDN];
        };
    };
  return YES;
}

//--------------------------------------------------------------------
-(GSLDAPSchema*)schema
{    
  if (!_schema)
    {
      unsigned ldapMsgId=0;
      LDAPMessage *ldapEntryMessage=NULL;
      [self assertCanRunOperationInSelector:_cmd];
      
      ldapMsgId=[self initiateSubschemaSearch];
    
      if ([self requestResultWithLDAPMsgId:ldapMsgId
                LDAPMessage:&ldapEntryMessage
                retrieveAll:NO] == LDAP_RES_SEARCH_ENTRY) 
        {
          char **values = NULL;  
          char **syntaxValues = NULL;
          char **matchingRuleValues = NULL;
          NSArray* objectClassesStrings=nil;

          // Retrieve Object Classes
          values = ldap_get_values(_ldapConn,ldapEntryMessage,"objectclasses");
          if (values && **values) 
            {
              objectClassesStrings=[NSArray arrayWithCStringArray:values];
              ldap_value_free(values);
              values = NULL;
            };
          
          // Retrieve attributes
          values = ldap_get_values(_ldapConn,ldapEntryMessage,"attributetypes" );

          // Retrieve syntaxes
          syntaxValues = ldap_get_values (_ldapConn, ldapEntryMessage, "ldapsyntaxes" );

          // Retrieve Matching Rules
          matchingRuleValues = ldap_get_values (_ldapConn, ldapEntryMessage, "matchingrules" );
          
          // Problem ?
          if ([self requestResultWithLDAPMsgId:ldapMsgId
                    LDAPMessage:&ldapEntryMessage
                    retrieveAll:NO] != LDAP_RES_SEARCH_RESULT) 
            {
              ldap_value_free(values);
              values=NULL;
              ldap_value_free(syntaxValues);
              syntaxValues=NULL;
              ldap_value_free(matchingRuleValues);
              matchingRuleValues=NULL;
            }
          else
            {
              GSLDAPSchema *schema = nil;
              NSArray* attributesStrings=nil;
              NSArray* syntaxesStrings=nil;
              NSArray* matchingRulesStrings=nil;
              
              attributesStrings=[NSArray arrayWithCStringArray:values];
              ldap_value_free(values);
              values=NULL;
              
              syntaxesStrings=[NSArray arrayWithCStringArray:syntaxValues];
              ldap_value_free(syntaxValues);
              syntaxValues=NULL;
              
              matchingRulesStrings=[NSArray arrayWithCStringArray:matchingRuleValues];
              ldap_value_free(matchingRuleValues);
              matchingRuleValues=NULL;
              
              schema=[GSLDAPSchema ldapSchemaWithLDAPAttributesStrings:attributesStrings
                                   ldapSyntaxesStrings:syntaxesStrings
                                   ldapMatchingRulesStrings:matchingRulesStrings
                                   ldapObjectsClassesStrings:objectClassesStrings];
              
              ASSIGN(_schema,schema);
            };
        };      
    };
  return _schema;
}


@end
    
