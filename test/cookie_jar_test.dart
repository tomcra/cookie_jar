// Copyright (c) 2016, tomcra. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:cookie_jar/cookie_jar.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    Awesome awesome;

    setUp(() {
      awesome = new Awesome();
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });

  group('Group of cookie date parsing test.', (){
    test('Testing date in RFC 822, updated by RFC 1123 style', () {
      expect(CookieDateTime.parseCookieDate("Sun, 06 Nov 1994 08:49:37 GMT"),
        equals(new DateTime.utc(1994,11,6,8,49,37,0,0)));
    });
    test('Testing date in RFC 850, obsoleted by RFC 1036 style', () {
      expect(CookieDateTime.parseCookieDate("Sunday, 06-Nov-94 08:49:37 GMT"),
          equals(new DateTime.utc(1994,11,6,8,49,37,0,0)));
    });
    test('Testing date in RFC 850, obsoleted by RFC 1036 style with 2006 date', () {
      expect(CookieDateTime.parseCookieDate("Sunday, 06-Nov-06 08:49:37 GMT"),
          equals(new DateTime.utc(2006,11,6,8,49,37,0,0)));
    });
    test("Testing date in ANSI C's asctime() format style", () {
      expect(CookieDateTime.parseCookieDate("Sun Nov  6 08:49:37 1994"),
          equals(new DateTime.utc(1994,11,6,8,49,37,0,0)));
    }, skip: "No support for ANSI C's asctime() format currently and propably "
        "won't be");
    test('Testing date in from real world cookie from Jira (probaly Java) style', () {
      expect(CookieDateTime.parseCookieDate("Thu, 01-Jan-1970 00:00:10 GMT"),
          equals(new DateTime.utc(1970,1,1,0,0,10,0,0)));
    });
  });

  group('Group of cookie set from String tests', (){
    test('Testing standard Jira set-cookie header', () {
      String cjString = 'atlassian.xsrf.token=BEL6-MTA9-V5SQ-PQIT|07fc58d03ffa'
          '8118441bff98f3fe91524bf1683e|lout; Path=/; Secure,JSESSIONID=7422E9'
          'EC2CE19467B53CA4C09D04C490; Path=/; Secure; HttpOnly,studio.crowd.t'
          'okenkey=""; Domain=.newrah.atlassian.net; Expires=Thu, 01-Jan-1970 '
          '00:00:10 GMT; Path=/; Secure; HttpOnly,studio.crowd.tokenkey=KV6Rz6'
          'Za5jXnwZMmnvrK8A00; Domain=.newrah.atlassian.net; Path=/; Secure; H'
          'ttpOnly';
      String requestString = 'atlassian.xsrf.token=BEL6-MTA9-V5SQ-PQIT|07fc58d'
          '03ffa8118441bff98f3fe91524bf1683e|lout; JSESSIONID=7422E9EC2CE19467'
          'B53CA4C09D04C490; studio.crowd.tokenkey=KV6Rz6Za5jXnwZMmnvrK8A00';
      CookieJar cj =  new CookieJar(cjString);
      expect(cj.toCookiePairString('test'), equals(requestString));
    });
  });
}
