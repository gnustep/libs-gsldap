/** GSLDAPCom.h - <title>GSLDAP: Common</title>

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

#ifndef _GSLDAPCom_h__ 
#define _GSLDAPCom_h__ 

#include <stdio.h>
#include <string.h>
#include <ldap.h>
#include <lber.h>
#include <sys/time.h>
#include <Foundation/NSObject.h>
#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSData.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSDebug.h>
#include <Foundation/NSScanner.h>
#include <Foundation/NSCalendarDate.h>
#include <Foundation/NSException.h>
#include <base/GSCategories.h>
#include <gsldap/GSLDAPUtils.h>
#include <gsldap/GSLDAPConnection.h>
#include <gsldap/GSLDAPEntry.h>
#include <gsldap/GSLDAPAttribute.h>
#include <gsldap/GSLDAPObjectClass.h>
#include <gsldap/GSLDAPSyntax.h>
#include <gsldap/GSLDAPMatchingRule.h>
#include <gsldap/GSLDAPSchema.h>

#endif //_GSLDAPCom_h__ 


