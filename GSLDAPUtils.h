/** GSLDAPUtils.h - <title>GSLDAP</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 2003
   
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

#ifndef _GSLDAPUtils_h__ 
#define _GSLDAPUtils_h__ 

@interface NSScanner (LDAPScannerExtension)
-(BOOL)scanDiscardString:(NSString*)string;
-(BOOL)scanThruAndDiscardString:(NSString*)string;
-(BOOL)scanThruAndDiscardString:(NSString*)string
                 discardedString:(NSString**)discarded;
@end


@interface NSArray (DoublePointerConveniences)
-(char**)cStringArray;
+(NSArray*)arrayWithCStringArray:(char**)array;
@end

extern void freeMallocArray(char **array);
extern char *cStringCopy(NSString *string);


@interface NSArray (CStringArray)
-(char**)cStringArray;
+(NSArray*)arrayWithCStringArray:(char**)array;
@end

@interface NSException (GSLDAP)
+(void)raise:(NSString*)name
      reason:(NSString*)reason;
@end

@interface NSString (LDAPDN)
-(NSString*)cleanedDN;
@end
#endif // _GSLDAPUtils_h__ 
