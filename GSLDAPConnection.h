/** GSLDAPConnection.h - <title>GSLDAP: Class GSLDAPConnection</title>

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

#ifndef _GSLDAPConnection_h__ 
#define _GSLDAPConnection_h__ 

@class GSLDAPEntry;
@class GSLDAPSchema;

#define GSLDAPConnection__bindOnConnect 0x00000001L	/** Try to bind when connecting */
#define GSLDAPConnection__autoConnect	0x00000002L	/** Try to connect if not connected when running an operation */

@interface GSLDAPConnection: NSObject
{
  LDAP* _ldapConn;			/** LDAP connection handle */
  NSString* _host;			/** Host */
  int _port;				/** Port: 0 mean default port (389) */
  unsigned int _authMethod;		/** Authentification Method: LDAP_AUTH_KRBV4, 
						LDAP_AUTH_KRBV41, LDAP_AUTH_KRBV42, 
						LDAP_AUTH_NONE, LDAP_AUTH_SIMPLE, LDAP_AUTH_SASL */
  NSString* _bindDN;			/** Bind DN */
  NSString* _bindPassword;		/** Bind Password */
  NSString* _defaultBaseDN;		/** Default base DN */
  unsigned int _defaultScope;		/** Default Scope: LDAP_SCOPE_BASE,  
						LDAP_SCOPE_ONELEVEL, LDAP_SCOPE_SUBTREE */
  BOOL _isBinded;			/** YES if bind success */
  GSLDAPSchema* _schema;		/** LDAP Server cached schema */

  struct {
    unsigned int bindOnConnect:1;	/** Try to bind when connecting */
    unsigned int autoConnect:1;		/** Try to connect if not connected when running an operation */

    unsigned int reserved:30;
  } _flags;
}

/** Create an autorelease ldapConnection */
+(GSLDAPConnection*)ldapConnection;

/** Create an autorelease ldapConnection with parameters */
+(GSLDAPConnection*)ldapConnectionWithHost:(NSString*)host
                                      port:(int)port
                                authMethod:(unsigned int)authMethod
                                    bindDN:(NSString*)bindDN
                              bindPassword:(NSString*)bindPassword
                                    baseDN:(NSString*)baseDN
                                     scope:(unsigned int)scope
                                     flags:(unsigned int)flags;

+(GSLDAPConnection*)ldapConnectionWithAuthMethod:(unsigned int)authMethod
                                           scope:(unsigned int)scope
                                           flags:(unsigned int)flags;

/** Init with parameters */
-(id)initWithHost:(NSString*)host
             port:(int)port
       authMethod:(unsigned int)authMethod
           bindDN:(NSString*)bindDN
     bindPassword:(NSString*)bindPassword
           baseDN:(NSString*)baseDN
            scope:(unsigned int)scope
            flags:(unsigned int)flags;

-(id)initWithAuthMethod:(unsigned int)authMethod
                  scope:(unsigned int)scope
                  flags:(unsigned int)flags;

/** Debugging purpose */
-(BOOL)isDebugEnabled;

/** Set LDAP Server Host */
-(void)setHost:(NSString*)host;

/** Set LDAP Server Port. 0 mean default port (389)  */
-(void)setPort:(int)port;

/** Set Authentification Method
    LDAP_AUTH_KRBV4, LDAP_AUTH_KRBV41, LDAP_AUTH_KRBV42, 
    LDAP_AUTH_NONE, LDAP_AUTH_SIMPLE, LDAP_AUTH_SASL */
-(void)setAuthMethod:(unsigned int)authMethod;

/** Set bind DN */
-(void)setBindDN:(NSString*)bindDN;

/** Set Bind Password */
-(void)setBindPassword:(NSString*)bindPassword;

/** Set default Base DN */
-(void)setDefaultBaseDN:(NSString*)defaultBaseDN;

/** Set Default Search Scope 
    LDAP_SCOPE_BASE, LDAP_SCOPE_ONELEVEL, LDAP_SCOPE_SUBTREE */
-(void)setDefaultScope:(unsigned int)defaultScope;

/** returns LDAP Server Host */
-(NSString*)host;

/** returns LDAP Server Port */
-(int)port;

/** returns LDAP Authentification Method */
-(unsigned int)authMethod;

/** returns bindDN */
-(NSString*)bindDN;

/** returns bindPassword */
-(NSString*)bindPassword;

/** returns default Base DN */
-(NSString*)defaultBaseDN;

/** returns Default Search Scope */
-(unsigned int)defaultScope;

/** returns YES if bind was successful */ 
-(BOOL)isBinded;

/** return timeout value */
-(unsigned)timeoutValue;

/** returns schema base key (for schema interrogation) */
-(NSString*)schemaBaseKey;

/** return LDAP handler */
-(LDAP*)ldapConn;

/** Try to bind with bindDN/bindPassword */
-(BOOL)bind;

-(BOOL)isConnected;

/** Try to connect */
-(BOOL)connect;

/** Try to disconnect */
-(BOOL)disconnect;

/** Search DN 'dn' and retrieve attributes 'attributes'
if attributes is nil, retrieves all attributes */
-(GSLDAPEntry*)searchDN:(NSString*)dn
             attributes:(NSArray*)attributes;

/** Search with filter and retrieve attributes 'attributes'
if attributes is nil, retrieves all attributes */
-(NSArray*)searchFilter:(NSString*)filter
             attributes:(NSArray*)attributes;

/** Search with filter, scope 'scope' starting at base 'baseDN'
    and retrieve attributes 'attributes'
    if attributes is nil, retrieves all attributes */
-(NSArray*)searchWithBaseDN:(NSString*)baseDN
                      scope:(unsigned int)scope
                     filter:(NSString*)filter
                 attributes:(NSArray*)attributes;

/** Search one level entries DNs */
-(NSArray*)searchOneLevelDNsWithBaseDN:(NSString*)baseDN;

/** Search subtree entries DNs */
-(NSArray*)searchSubtreeDNsWithBaseDN:(NSString*)baseDN;

/** Search entries DNs */
-(NSArray*)searchDNsWithBaseDN:(NSString*)baseDN
                         scope:(unsigned int)scope;

/** adds entry 'entry' */
- (BOOL)addEntry:(GSLDAPEntry*)entry;

/** deletes entry 'entry' */
- (BOOL)deleteEntry:(GSLDAPEntry*)entry;

/** deletes entry 'entry' */
- (BOOL)deleteEntry:(GSLDAPEntry*)entry
        isRecursive:(BOOL)isRecursive;

/** deletes entry referenced by DN 'dn' */
- (BOOL)deleteEntryWithDN:(NSString*)dn;

/** deletes entry referenced by DN 'dn' */
- (BOOL)deleteEntryWithDN:(NSString*)dn
              isRecursive:(BOOL)isRecursive;

/** updates entry 'entry' */
-(BOOL)updateEntry:(GSLDAPEntry*)entry;

/** updates entry 'entry' and change RDN 
if deleteOldRDN is YES, delete entry referenced by old RDN */
- (BOOL)updateEntry:(GSLDAPEntry*)entry
                rdn:(NSString*)rdn
       deleteOldRDN:(BOOL)deleteOldRDN;

/** returns ldapSchema or nil if server doesn't 
allow/support this feature */
- (GSLDAPSchema*)schema;

@end
#endif 
